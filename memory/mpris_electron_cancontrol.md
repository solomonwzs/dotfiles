# MPRIS 媒体控制（Electron 应用 CanControl=false 坑）

## 现象

QQMusic（Electron 应用）无法被 KDE 媒体控制操作：托盘"媒体控制器"小部件按钮无效、
键盘媒体键（播放/暂停等）无反应；但 `playerctl play-pause` 正常生效。

## MPRIS 链路（快速复习）

```
应用注册 D-Bus 名 org.mpris.MediaPlayer2.<name>[.instance<PID>]
    └─ Plasma: libkmpris (Mpris2SourceModel 监听 org.mpris.MediaPlayer2*)
         ├─ 身份过滤: Identity 为空 → 静默丢弃（playercontainer.cpp "isn't standard-compliant"）
         ├─ 有效能力 = CanControl && Can*   ← 全部控件的总开关
         └─ 媒体键 → mediacontrol 组件(kglobalaccel) → multiplexer → 跳过 CanControl=false 的玩家
playerctl: 不检查 CanControl，直接调 org.mpris.MediaPlayer2.Player 的方法
```

- 媒体键快捷键组件名 `[mediacontrol]`，由媒体控制器小部件注册
  （kglobalshortcutsrc：playpausemedia=Media Play\tMeta+P 等）
- 播放器对象路径恒为 `/org/mpris/MediaPlayer2`

## 根因（本案例）

Chromium/Electron 的 MPRIS 实现把 **CanControl 硬编码为 false**
（ui/base/mpris/mpris_service_impl.cc，Chromium bug 40676953，Chrome 79 时代至今）。
所有 Electron 应用（QQMusic、各种 Electron 音乐播放器）全部继承，应用侧无法配置。

QQMusic 实测属性（busctl get-property 逐项查询）：

```
Identity     = "Chromium"     ← 非空，通过 Plasma 身份检查，会显示出来（但名字是 Chromium）
DesktopEntry = 未实现（报错）  ← Plasma 容忍（回退 systemd unit 查找）
CanControl   = false          ← 罪魁；effectiveCanPause = false && true = false
CanPause/CanPlay/CanGoNext/CanGoPrevious = true   ← 单独看都正常
```

Plasma 按 MPRIS 规范把 CanControl=false 解释为"不可远程控制"：小部件按钮禁用、
媒体键 multiplexer 直接跳过（KDE 官方补丁 D26330 专门处理此事）。
**playerctl 不看 CanControl → 能用**。这是"playerctl 能控制、桌面控制不了"的判定特征。

## 排查方法论（下次媒体控制失灵时）

1. `playerctl -l` → 确认 MPRIS 注册（名字形如 `chromium.instance<PID>`，PID 随重启变化）
2. `playerctl -p chromium play-pause` → 能动 = 方法链路通 → 问题在**属性声明**，非 KDE/配置
3. 属性逐项对照（沙箱内 busctl 路径参数会被拦，写进 /tmp 脚本执行）：
   `busctl --user get-property <名> /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2(.Player)? <属性>`
   重点：Identity（空=被丢弃不显示）、CanControl（false=显示但不可控）
4. 两个截然不同的症状要分清：**不显示** = Identity 空/注册失败；**显示但不可控** = CanControl=false

## 解决方案（应用侧无解，绕过 Plasma 媒体控制）

自定义快捷键直连 playerctl（`-p chromium` 前缀匹配，重启后 instance 号变化不影响）：

1. 先解绑 Plasma 占用的媒体键：系统设置 → 快捷键 → 媒体控制器 → 清空"播放/暂停"等绑定
2. 系统设置 → 键盘 → 自定义快捷键：
   - `playerctl -p chromium play-pause` / `next` / `previous` → 绑到媒体键

偷懒版：alias `qqpp='playerctl -p chromium play-pause'`。

## 相关知识

- Electron 应用 MPRIS 名字是内核注册的 `chromium.instance*`，Identity="Chromium"——
  托盘小部件里显示为 "Chromium" 而非应用名，Flatpak 沙箱下还会因名字规则注册失败
- KDE 的 MPRIS 代码在 plasma-workspace `libkmpris/`（libkmpris + mediacontroller 小部件）
- playerctl 匹配规则：短名（chromium）可前缀匹配长名（chromium.instance123）
- `org.mpris.MediaPlayer2.playerctld`：playerctl 守护进程（多路复用器），可做 MPRIS 代理，
  但对绕过 CanControl 检查无帮助（playerctl 直连更简单）
