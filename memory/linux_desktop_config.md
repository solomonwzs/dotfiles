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
