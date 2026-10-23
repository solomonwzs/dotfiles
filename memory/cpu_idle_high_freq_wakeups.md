# 空闲却高频：唤醒风暴排查（timerfd 复现 + wineserver 案例）

## 现象

CPU 空闲率高（如 94%），但各核频率不降反升（800 MHz → 2.2 GHz），
风扇/温度/耗电异常。关掉某个应用（本例：Wine 跑的企业微信）后恢复正常。

**关键判别**：不要看 `%CPU`，要看**上下文切换速率**。真正空闲的系统 ctxt 只有几百/秒，
问题的系统可达数万/秒。

## 判定流程

### 1. 排除硬性限制（排除法，先做）

```bash
c=/sys/devices/system/cpu/cpu0/cpufreq
cat $c/scaling_driver $c/scaling_governor $c/scaling_min_freq $c/scaling_max_freq
cat $c/energy_performance_preference
cat /sys/devices/system/cpu/intel_pstate/{min_perf_pct,max_perf_pct,no_turbo,hwp_dynamic_boost}
cat /sys/firmware/acpi/platform_profile          # balanced / low-power / performance
```

若 `min_perf_pct` 仍是很小值、min_freq=800 MHz、无 PM QoS 约束，
说明**不是配置把频率钉死**，可以往下查动态因素。

PM QoS 约束持有者（低延迟请求会抬 min_perf）：

```bash
for p in /proc/[0-9]*; do for f in $p/fd/*; do
  t="$(readlink "$f" 2>/dev/null)" || continue
  [[ "$t" == *cpu_dma_latency* ]] && echo "${p#/proc/} $(tr '\0' ' ' < $p/comm)"
done; done 2>/dev/null
```

### 2. 量唤醒率（核心指标）

```bash
# 系统总上下文切换/秒
c1=$(awk '/^ctxt/{print $2}' /proc/stat); sleep 3
c2=$(awk '/^ctxt/{print $2}' /proc/stat); echo "ctxt/s = $(( (c2-c1)/3 ))"

# 中断/软中断
grep -E '^(intr|softirq)' /proc/stat
```

参考值：**< 1000/s = 真空闲**；数千 = 有轮询程序；**> 20000/s = 唤醒风暴**。

### 3. 定位元凶进程（增量差分）

```bash
# 两次快照 /proc/*/status 的 voluntary+nonvoluntary_ctxt_switches，取增量 Top
: > /tmp/cs1; for p in /proc/[0-9]*; do
  v=$(awk '/^voluntary_ctxt_switches/{print $2}' $p/status 2>/dev/null) || continue
  n=$(awk '/^nonvoluntary_ctxt_switches/{print $2}' $p/status 2>/dev/null)
  [[ -n "$n" ]] && echo "${p#/proc/} $((v+n))" >> /tmp/cs1
done
sleep 3
# 再采一次 /tmp/cs2 后 join 求差，按增量倒序
```

注意 `join` 要求按第一列**字典序**排序（`sort -k1,1` 而非 `sort -n`），否则会报
"input is not in sorted order" 并错位输出。

### 4. 看深睡态是否被阻断

```bash
for s in /sys/devices/system/cpu/cpu0/cpuidle/state*; do
  printf '%-8s latency=%-6s usage=%s\n' "$(cat $s/name)" "$(cat $s/latency)" "$(cat $s/usage)"
done
# 间隔 3s 再采一次 usage 做差，看各状态进入次数
```

判读：某睡眠态的 **latency（µs）** 与「唤醒间隔」比较。唤醒间隔 < latency 时该状态
基本进不去。本例 C3 latency=1034 µs，而唤醒间隔约 0.4 ms → C3 进入次数远少于 C1/C2，
CPU 一直浅睡。

### 5. 确认是否「唤醒驱动」而非「负载驱动」

两个证据指向唤醒驱动：

- 空闲率高（94%）但频率高 → 不是吞吐需求
- 频率抬升是**全局的**：连没跑目标线程的核心也一样高（`scaling_cur_freq` 读到的是
  HWP 被抬高的 **请求值**，空闲核上会保留上次唤醒抬升后的数值）→ 别用「哪核在跑谁」
  的对应关系去解释

## 复现实验（决定性证据，不碰被测应用）

一个只含 1 kHz 定时器、CPU 占用≈0 的进程，足以把全核频率从 800 MHz 顶到 2 GHz+：

```python
#!/usr/bin/env python3
# 1 kHz timerfd 唤醒循环：验证「唤醒频率」本身就能抬高 CPU 频率
import os, select, time

def read_freqs():
    vals = []
    for c in range(os.cpu_count() or 1):
        try:
            with open(f'/sys/devices/system/cpu/cpu{c}/cpufreq/scaling_cur_freq') as f:
                vals.append(round(int(f.read()) / 1000))
        except OSError:
            pass
    return vals

def ctxt():
    with open('/proc/stat') as f:
        for line in f:
            if line.startswith('ctxt'):
                return int(line.split()[1])

print("baseline freq:", read_freqs())      # 静置时应为 800 左右
c0, t0 = ctxt(), time.monotonic()

fd = os.timerfd_create(time.CLOCK_MONOTONIC)
os.timerfd_settime(fd, initial=0.001, interval=0.001)   # 1 ms 周期

end, wakes, samples = time.monotonic() + 8.0, 0, []
while time.monotonic() < end:
    select.select([fd], [], [], 0.25)
    os.read(fd, 8)
    wakes += 1
    if wakes % 800 == 0:
        samples.append(read_freqs())

print(f"wakeups/s = {wakes/8.0:.0f}, system ctxt/s = {(ctxt()-c0)/(time.monotonic()-t0):.0f}")
for s in samples:
    print("during freq:", s)
os.close(fd); time.sleep(1)
print("after freq:", read_freqs())
```

实测输出（本机 i7，12 线程）：baseline 全 800 → during 普遍 1800–2500（夹杂个别 800）
→ after 仍偏高需数十秒回落。

⚠️ Python 3.14 的 `os.timerfd_settime` 签名是 **keyword-only**：
`timerfd_settime(fd, *, flags=0, initial=0.0, interval=0.0)`（单位**秒**），
传 4 个位置参数会报 `takes exactly 1 positional argument`。
旧式 `(sec, nsec)` 元组参数写法只适用于 `os.timerfd_settime_ns`。

## 机制链

1. 应用以毫秒级周期轮询（Windows 程序常用 `timeBeginPeriod(1)`，浏览器/Electron/Node/
   Flutter 各有自己的高频定时器）。Wine 把 Windows 定时器映射到 `timerfd`/`epoll`，
   `wineserver` 被反复唤醒。
2. 唤醒间隔短于深睡态退出延迟 → 进不了 C3，长期停在 C1/C2。
3. `intel_pstate` 的 HWP 在**每次 idle 唤醒时抬高该核 P-state 请求**（wake boost），
   并维持一段时间。频繁唤醒 → 请求值一直高位；`scaling_cur_freq` 读的是请求值，
   空闲核会保留被抬高后的数字，于是「全核 2 GHz」。
4. 抬升幅度受 `platform_profile` / EPP 影响：`performance` 比 `balanced` 明显更高。

## 原生 Windows 也有同样问题（Wine 只是放大器）

现象**不是 Wine 独有**，根源在 Windows 自己的 API：应用调 `timeBeginPeriod(1)`
把系统时钟精度从默认 **15.6 ms** 提到 **1 ms**，时钟中断频率随之 15 倍化。
微软文档明确写「高精度定时器要求系统时钟中断更频繁，**会增加功耗**」，
Idle Energy Efficiency 评估把「System Timer Resolution」列为首要电池指标。
历史案例：Go 运行时在 Windows 上调 `timeBeginPeriod`，被大量投诉续航变短
（golang/go#8687）。

同一应用在原生 Windows 上唤醒量级**更低**，差别全在「定时器管道由谁实现」：

| | 原生 Windows | Wine |
|---|---|---|
| 定时器实现 | 内核（`KeSetTimer` / DPC） | 应用 ↔ **wineserver 用户态进程** 往返 |
| 每次到期代价 | 内核内部，无用户态上下文切换 | 至少 2 次上下文切换 |
| 唤醒合并机制 | **Timer Coalescing**、**ITTD**（Win7+，合并 tick、只发给需要的核） | 无对应机制 |
| 量级 | 低 | 被放大数倍（本例 wineserver 自身 7728/s） |

结论：不是企业微信在 Wine 下「更忙」，而是**同一次定时器到期被翻译成了更多 Linux 唤醒**。

判别线索：这不是 Wine 专属——`firefox` 的 `Isolated Web Co` 同样有 173/s，
Chromium 系（Electron / CEF / Node / Flutter）都有此特征，只是量级小。
Wine 把倍数放大了而已。

对应手段：Windows 上 `powercfg /energy` 会直接点名「System Timer Resolution」及请求
高精度定时器的进程，Win11 可对后台应用开「效率模式」；Linux 没有等价的合并机制，
只能让轮询程序停下来。Linux 的 `timerslack_ns`（默认 50 µs）对 Wine 大量使用的
`timerfd`/`poll` 轮询基本无效，别指望靠它。
## 实测案例：Wine 企业微信

关不掉的前提下测得：

```
空闲率 94%，ctxt/s ≈ 29500
wineserver        7728/s   ← 每 0.13 ms 醒一次
WeCom MainThread  2919/s   (WeMail.exe)
WeCom UIThread    1253/s
FlutterPlugins     822/s
WeMailNode_x64     476/s
explorer.exe       259/s
```

企业微信系合计约 13,000/s（占系统 45%）；全核 2200–2300 MHz。
关闭后 ctxt 应回落到数百/秒、频率回 800 MHz。

## 缓解手段

| 措施 | 命令 | 说明 |
|---|---|---|
| 电源模式降档 | `echo balanced \| sudo tee /sys/firmware/acpi/platform_profile` | 最直接，降频率地板；重启/插拔电源可能被固件覆盖 |
| 调 EPP | `echo power \| sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference` | 偏向省电 |
| 关掉应用的附属模块 | 例：只留聊天，关 WeMail（邮件） | 唤醒量可减半 |
| 应用侧改计时器 | 基本不可行 | 由程序内部定时器决定 |

结论：这不是故障，是「唤醒频率」而非「计算负载」驱动的功耗行为；
需要 800 MHz 空闲时，只能让高频轮询的程序停下来。

## 相关知识

- `scaling_cur_freq`（intel_pstate/HWP）= **最近一次 P-state 请求值**，不是实时频率，
  空闲核上的读数会偏乐观，别单凭它下结论
- `idle%`（`/proc/stat`）只反映 CPU 时间分配，**不反映唤醒次数**——两者必须一起看
- 判断「谁在唤醒」比判断「谁在算」更接近功耗问题本质（类似 `powertop` 的思路，
  powertop 未安装时用本页的 ctxt 差分法替代）
- 同类元凶：轮询式鼠标/键盘驱动、`nvidia` 持久模式、某些 RGB/风扇控制守护进程、
  Chromium 的音乐可视化、虚拟机 guest 代理

## 参考

- `timeBeginPeriod`（微软文档，含功耗说明）
  https://learn.microsoft.com/en-us/windows/win32/api/timeapi/nf-timeapi-timebeginperiod
- 高精度定时器：https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/high-resolution-timers
- Idle Energy Efficiency 评估（System Timer Resolution 指标）
  https://learn.microsoft.com/en-us/windows-hardware/test/assessments/results-for-the-idle-energy-efficiency-assessment
- Core Parking / ITTD：https://techcommunity.microsoft.com/blog/askperf/windows-7--windows-server-2008-r2-core-parking--intelligent-timer-tick--timer/374196
- Go 因 `timeBeginPeriod` 被投诉耗电：https://github.com/golang/go/issues/8687
