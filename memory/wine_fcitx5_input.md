# Wine + fcitx5 输入法问题（KDE Plasma 6 Wayland）

## 环境

- KDE Plasma 6.8 / **Wayland** 会话；fcitx5 由 **KWin 作为"虚拟键盘"启动**（父进程就是 kwin_wayland）
- wine 11.20 (Staging)，企业微信装在 `~/.wine`
- 启动项：`~/.local/share/applications/wine/Programs/WeCom/WeCom.desktop`

## 症状

普通应用（kitty / Firefox / Qt 程序）fcitx5 一切正常，wine 下企业微信无法切换输入法。

## 根因（一句话）

Plasma 6 Wayland 下**原生应用走 text-input 协议、不需要 `XMODIFIERS`**，而 **wine 走 X11 驱动（XWayland）+ XIM、必须要 `XMODIFIERS=@im=fcitx`**；从 KDE 菜单启动的进程继承不到 shell rc 里 export 的变量 → 只有 wine/旧 X11 应用挂掉。

## 修复（最小配置）

desktop 文件的 Exec 行：

```ini
Exec=env XMODIFIERS=@im=fcitx "WINEPREFIX=/home/solomon/.wine" wine "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\WeCom\\WeCom.lnk"
```

| 项 | 是否需要 | 说明 |
|----|---------|------|
| `XMODIFIERS=@im=fcitx` | **必需** | 没有它 wine 的 X11 驱动根本不建立 XIM 连接 |
| `LANG=zh_CN.UTF-8` | 不需要 | 实测 fcitx5 的 XIM 对 en_US.UTF-8 客户端也正常 |
| wine 注册表 `Graphics=x11` | 不需要 | wine 11 默认就是 x11 驱动（XWayland）；设置了也无害 |

改完 .desktop 后**必须**刷新 KDE 菜单缓存（见下面坑 2），否则改了也白改。

## 验证命令

```sh
# 1. 进程实际环境（最关键的一步——别相信"我设置过了"）
tr '\0' '\n' < /proc/$(pgrep -f "WXWork\.exe" | head -1)/environ \
  | grep -E "^(LANG|XMODIFIERS|XAUTHORITY|WINEPREFIX)="

# 2. 输入法通路：焦点在企业微信输入框时执行
fcitx5-diagnose | grep -E "Group \[|IC \["
# 正常时 Group [x11::0] 会有 1 个 IC：program:wine-preloader frontend:xim
# （32 位程序由 wine-preloader 加载，XIM 客户端名就是这个）

# 3. XWayland 上 XIM server 是否注册（注意用现存的 xauth 文件）
XAUTHORITY=/run/user/1000/xauth_$(ls /run/user/1000 | grep -oP 'xauth_\w+$' | sed 's/xauth_//') \
  xprop -root XIM_SERVERS
# 应输出：XIM_SERVERS(ATOM) = @server=fcitx
```

## 踩过的坑（按出现顺序）

1. **desktop 文件 env 语法**：`env` 的每个变量必须单独一个参数。
   `env "WINEPREFIX=... XMODIFIERS=@im=fcitx" wine ...` ❌ 只会设置一个变量（值含空格），
   `env XMODIFIERS=@im=fcitx "WINEPREFIX=..." wine ...` ✅

2. **KDE 菜单缓存（ksycoca）不会自动刷新**：改了 .desktop，从菜单/任务栏启动的仍是旧条目。
   改完执行 `kbuildsycoca6`；任务栏固定图标不行就取消再固定。
   判断"改动是否真的生效"只看 `/proc/PID/environ`。

3. **fcitx5-diagnose 的 IC 分组是判断输入路径的最可靠指标**：
   - `Group [wayland]` = text-input 协议（原生应用）
   - `Group [x11::0]` = XIM（wine / 旧 X11 应用）
   - ⚠️ `program:WeCom frontend:wayland` 这种 IC 是 **KWin 侧**为聚焦窗口生成的输入法抓取
     上下文（名字来自 desktop 文件关联），**与 wine 用什么驱动无关、聚焦过窗口就会残留**。
     本次排查最大的误导源——不要把它当成 wine 的 wayland 客户端。

4. **XAUTHORITY 会过期**：kwin（重）启动后 `/run/user/1000/xauth_XXX` 换新文件，
   旧终端里指向已删除文件 → xprop 等诊断报 `Authorization required`（本次曾因此误判
   "XIM server 没注册"）。先 `ls /run/user/1000/xauth_*` 用现存的那个。

5. **判断 wine 连的是 X 还是 wayland**：`ss -xp` 解析容易翻车；更可靠的是
   `xprop -root _NET_CLIENT_LIST` 逐窗口查 WM_CLASS（wine x11 驱动的窗口 WM_CLASS 为
   `wxwork.exe`）。注意最小化到托盘的窗口不在 _NET_CLIENT_LIST 里，可能查不到。

6. **进程环境 ≠ 会话环境 ≠ shell 环境**：`~/.zshrc` 里 export 的变量只对终端里启动的
   进程生效；KDE 菜单启动的进程只继承 Plasma 会话环境。要给 GUI 启动的进程变量：
   写进 .desktop 的 Exec（`env VAR=... cmd`）或 `~/.config/environment.d/*.conf`（重登录生效）。

## 走过的弯路（避免重蹈）

- 误判 wine 11 默认用 wayland 驱动（被坑 3 的 KWin 侧 IC 误导 + ss 解析翻车）→ 实际一直走 x11
- 切过注册表 `Graphics=x11` → 不必要，已删（`wine reg delete "HKCU\Software\Wine\Drivers" /v Graphics`）
- 一度以为 `LANG=zh_CN.UTF-8` 是关键 → 对照实验证明只有 `XMODIFIERS` 起作用
- 前几轮"改了 Exec 还是不行"全是坑 1 + 坑 2：改动从未真正生效

## 架构速记（Plasma 6 Wayland 输入法）

```
原生应用 ──zwp_text_input_v3──▶ KWin ──input-method-v2──▶ fcitx5   （无需环境变量）
XWayland 应用（含 wine）──XIM──▶ fcitx5                        （需要 XMODIFIERS=@im=fcitx）
```

- fcitx5 由 KWin 启动并作为 input method 引擎；普通应用正常 ≠ wine 应用正常
- wine 输入路径是否接通：`fcitx5-diagnose` 看 `Group [x11::0]` 的 IC 数（0 = 没通）

## 可选（未验证）

- `~/.config/fcitx5/conf/xim.conf` 设 `UseOnTheSpot=True` + `fcitx5 -r`：
  XIM 预编辑/候选窗跟随光标（默认 root 风格显示在屏幕左下角）
