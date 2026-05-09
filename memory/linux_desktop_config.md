# Linux 桌面与应用配置

## 图标关联

查看图标文件名：
```sh
sed -En 's/(.*)\/(.*)\:.*.kdb.*/\1-\2/p' /usr/share/mime/globs
# 或
sed -En 's/(.*)\/(.*)\:.*.kdb.*/\1-\2/p' $HOME/.local/share/mime/globs
```

编辑覆盖：`$HOME/.local/share/mime/packages/Override.xml`

更新数据库：
```sh
update-mime-database $HOME/.local/share/mime
update-desktop-database $HOME/.local/share/applications
```

重载 xfce4 面板：`xfce4-panel -r`

## HiDPI 设置

Chromium 高分屏缩放：`chromium --force-device-scale-factor=2`

### xdg-desktop-portal-gtk 文件对话框 DPI 问题

Chromium/Firefox 的文件选择对话框通过 xdg-desktop-portal 弹出，portal 使用 gtk.portal，但其 `UseIn=gnome`，在 XFCE 下 GTK 实现未正确读取 DPI 设置。

**问题链路：**
1. X server 报告物理尺寸 344x193mm + 4K 分辨率 → 计算 DPI ≈ 284
2. 但 xdpyinfo 显示 resolution 96x96 — X 服务器忽略了真实 DPI
3. XFCE 设了 `Xft.dpi: 192`、GTK settings 也设了，但 xdg-desktop-portal-gtk 是独立进程，启动时不继承这些设置
4. Chromium/Firefox 的文件对话框走 portal，portal-gtk 用默认 96 DPI 渲染 → 在 4K 屏上对话框巨大

## 屏幕电源管理 (DPMS)

查看状态：`xset q`

锁屏并关闭显示器：
```sh
sh -c "xfce4-screensaver-command --lock && sleep 1 && xset dpms force off"
```

禁用自动关屏：`xset dpms 0 0 0`

## Waydroid（安卓容器）
```sh
weston
sudo systemctl restart waydroid-container.service
WAYLAND_DISPLAY=wayland-1 waydroid session start
```

## 电池省电

```sh
pacman -S powertop tlp tlp-rdw
pacman -S tp_smapi acpi_call  # ThinkPad 专用
pacman -S smartmontools        # S.M.A.R.T 信息
sudo systemctl enable tlp.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
```

CPU 能耗策略：修改 `/etc/tlp.conf` 中的 `CPU_ENERGY_PERF_POLICY_ON_AC`

## 字体配置

编辑 `$HOME/.config/fontconfig/fonts.conf`

## Kitty 终端输入法（fcitx）
```sh
env GLFW_IM_MODULE=ibus kitty
```

## 使用 NVIDIA GPU 运行 Steam
```sh
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia steam
```

## Wine/Chromium 应用的阴影幻影窗口

**现象：** 在 wine 下运行 Chromium 架构的 Windows 应用（典型：企业微信 wxwork.exe），主窗口上会"蒙"一层半透明灰色、比主窗口略大的幻影窗口。`wmctrl -lGx` 能看到同一应用有两个窗口：一个有标题（真窗口），一个空标题且尺寸比真窗口大约 72×72px（阴影窗）。

**根因：** Chromium 为原生 Windows drop-shadow 创建带 `WS_EX_LAYERED` 的辅助窗口。Windows 上由 DWM 合成不可见；没有 X compositor 的 X11 会话下，layered 窗口的 alpha 通道不被合成，半透明区渲染成不透明灰块。

**失败过的方案：** 注册表改 `UserPreferencesMask`/禁用 DWM 复合/关闭主题（Chromium 自己画阴影，不看这些）；openbox `<applications class="wxwork.exe" title="">` 规则（幻影窗口的行为不受 WM 规则控制）；winecfg virtual desktop（会破坏 fcitx 输入法切换）。

**有效方案：** 启动 X compositor（如 picom），让 alpha 正确合成。
```sh
picom --backend glx --vsync &
```
已写入 `config/openbox/autostart`。i3 session 有同样问题时也可加入 `exec --no-startup-id picom ...`。

**Why:** 经过 2026-05-05 在 niri/i3/openbox 多次尝试，只有这一条路有效。
**How to apply:** 未来遇到 wine 运行的 Chromium 类 Windows 应用的幻影窗，直接上 compositor，不用再绕注册表/WM 规则。

### 幻影窗仍出现在 Alt+Tab 列表里

picom 解决了视觉问题，但幻影窗仍是一个独立 X11 窗口，会出现在 openbox 的 `Alt+Tab` (`NextWindow`) 切换列表里（label 显示为"企业微信"或空，图标是 wine 默认图标）。

**重要：openbox 的 `NextWindow` 不尊重 `_NET_WM_STATE_SKIP_TASKBAR` / `SKIP_PAGER`** —— 这是 openbox 的设计选择，不是 bug。所以 `wmctrl -b add,skip_taskbar,skip_pager`、`<applications skip_taskbar>` 都无法把幻影窗从 Alt+Tab 列表剔除。

**有效方案：监听 `_NET_CLIENT_LIST` 变化，主动 `xdotool windowunmap` 幻影窗。**

实现见 `shell/wine_shadow_hide.sh`，关键点：
- 用 `wmctrl -lx` 列受 WM 管理的窗口（不能用 `wmctrl -l`，那个不显示 WM_CLASS 字段）
- 通过 `WM_CLASS=wxwork.exe` + `WM_NAME=空` 识别幻影窗
- **不能缓存"已 unmap 的 wid"**：X server 会复用 wid，缓存会让重生的幻影窗漏掉。每次扫描都重新尝试 unmap，对已 unmapped 窗口无害。
- 用 `xprop -root -spy _NET_CLIENT_LIST` 监听，比定时轮询更省资源

**Why:** 2026-05-05 试过 `<applications title="">` 规则、`wmctrl -b add,skip_*`、改 `_NET_WM_WINDOW_TYPE` 都无效；只有 unmap 物理移除了切换列表里的项。
**How to apply:** 同类问题（其他 wine Chromium 应用、QQ 等）出现 Alt+Tab 多余项时，复用同一脚本，按 WM_CLASS 加分支即可。

## xfce4-panel 任务栏 urgent 闪烁

xfce4-panel 4.20 的 tasklist 在窗口请求关注（`_NET_WM_STATE_DEMANDS_ATTENTION` / urgent hint）时，**给按钮加上 GTK 通用 style class `.suggested-action`**（不是 `.needs-attention`、不是 `.urgent`），靠周期性切这个 class 实现持续 strobing。

**坑：** 主题在 panel 段写了通配 `button` 透明背景规则，会用更高特异性把 `.suggested-action` 的高亮背景压掉，闪烁就看不见。例：

```css
/* 特异性 (0,2,1) — 会覆盖 button.suggested-action 的 (0,2,0) */
.xfce4-panel.background button {
  background-color: transparent;
}
```

**修复**（见 `ui/gruvbox-material-gtk-dark-hidpi/gtk-3.0/xfce4.css`）：

```css
.xfce4-panel.background button.suggested-action {
  background-color: #504945;
}
```

特异性 (0,3,1) 压过 panel 通配规则，class 切换才有视觉效果。

**Why:** 2026-05-09 排查 gruvbox-material 主题任务栏不闪、其他主题闪 ≈ 半天，错过 `.needs-attention`、`#tasklist-button`、`.flat` 等多条线索；最终通过最小化测试 CSS（剩 `.background` + `button.suggested-action` 两条规则即可闪）才定位到真正 class 名。
**How to apply:** 移植/魔改 GTK3 主题遇到 xfce 任务栏 urgent 不闪，先看主题里有没有 panel 段通配 `button { background: transparent }` 类规则压过 `button.suggested-action`；不要再去找 `needs-attention`。

