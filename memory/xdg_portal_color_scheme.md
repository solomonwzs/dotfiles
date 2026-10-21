# xdg-desktop-portal 后端选择串环境 → Firefox 深浅色误判

## 环境

- Arch，多会话并存：Plasma 6.8 Wayland（tty 运行 `start-kde.sh`）+ XFCE 4.20（`startx` + `.xinitrc`）
- `loginctl show-user` → **Linger=yes**：systemd --user 跨登录存活，环境残留
- XFCE：gruvbox dark GTK 主题（gsettings `color-scheme='prefer-dark'`）；Plasma：BreezeLight

## 症状

Plasma（浅色 BreezeLight）会话里 Firefox 显示深色 UI，网页 `prefers-color-scheme: dark`。

## Firefox 判断深浅色的机制

```
网页 CSS / Firefox UI
  → xdg-desktop-portal: Settings.ReadOne("org.freedesktop.appearance", "color-scheme")
      主 portal 按【它自己进程启动时】的 XDG_CURRENT_DESKTOP 选后端
      ├─ KDE 后端（xdg-desktop-portal-kde，kde.portal 声明 UseIn=KDE）
      │     读 Qt 调色板：window 背景灰度 qGray < 192 → 深色，否则浅色
      │     （源码 readFdoColorScheme()，没有独立"深色模式"开关）
      └─ GTK 后端（内置兜底）：gsettings org.gnome.desktop.interface color-scheme
  → 返回 1=深 2=浅 0=无偏好；切换时 SettingChanged 信号实时通知 Firefox
```

## 根因链（全部已验证）

1. Linger=yes → systemd --user 跨会话存活，环境残留上次 XFCE 会话的 `XDG_CURRENT_DESKTOP=XFCE`
2. portal 被 dbus 激活（比 kwin 早 87 秒）时 user manager 环境还是 XFCE → **portal 进程环境冻结为 XFCE**
3. `kde.portal` 的 `UseIn=KDE` 不匹配 → 排除 KDE 后端，落到 GTK 后端兜底
4. GTK 后端读 gsettings `color-scheme='prefer-dark'`（gruvbox）→ Firefox 深色
5. `start-kde.sh` 里原有的 `import-environment XDG_CURRENT_DESKTOP` 一直是 **no-op**（tty shell
   里该变量未设置，导入未 set 的变量是静默跳过）

## 两个关键坑（记住这两个就能防住）

1. **xdg-desktop-portal 在进程启动那一刻冻结后端选择**，进程从不重读自己的环境。
   Linger=yes + 多会话切换（XFCE↔Plasma）时，portal 带着上一个会话的环境跨会话存活 → 必须重启。
2. **`systemctl --user import-environment` 只导入已设置的变量**——想导入什么，先 `export`。

## 修复（.xinitrc 与 start-kde.sh 对称修改，已完成）

会话启动脚本三段式：

```bash
export XDG_CURRENT_DESKTOP=KDE            # Plasma；XFCE 分支用 XFCE
export XDG_SESSION_DESKTOP=plasma         # 会话文件名；XFCE 分支用 XFCE
export DESKTOP_SESSION=plasma             # 会话文件名；XFCE 分支用 xfce

systemctl --user import-environment \
    GDK_DPI_SCALE DISPLAY XAUTHORITY \
    XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP DESKTOP_SESSION 2>/dev/null

# portal 冻结后端选择于进程启动时刻，重启让它按刚导入的环境重新选
systemctl --user try-restart \
    xdg-desktop-portal.service xdg-desktop-portal-gtk.service 2>/dev/null || true
```

立即修复当前会话（不等下次登录）：

```bash
systemctl --user try-restart xdg-desktop-portal.service xdg-desktop-portal-gtk.service
```

## 验证命令

```bash
# 1. portal 对外报的深浅（Firefox 读的就是这个）
gdbus call --session --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.portal.Settings.ReadOne org.freedesktop.appearance color-scheme
# (<<uint32 2>>,) = 浅色（Plasma：KDE 后端读 Qt 调色板）
# (<<uint32 1>>,) = 深色（XFCE：GTK 后端读 gsettings gruvbox）——各自正确

# 2. 排查用
gsettings get org.gnome.desktop.interface color-scheme        # GTK 后端读的
kreadconfig6 --file kdeglobals --group General --key ColorScheme
tr '\0' '\n' < /proc/$(pgrep -x xdg-desktop-portal | head -1)/environ | grep -E "XDG|DESKTOP_SESSION"
systemctl --user show-environment | grep -E "XDG|DESKTOP_SESSION"
loginctl show-user $USER | grep -i Linger
grep -H UseIn /usr/share/xdg-desktop-portal/portals/*.portal
```

## 相关知识

- portal 的 Settings 接口还提供 `accent-color`、`reduced-motion`（KDE 后端同样从 Qt 调色板/kdeglobals 推导）
- Firefox 强制深/浅不依赖系统：设置 → 常规 → 语言与外观 → 网站主题
- Plasma 里切配色方案会 paletteChanged → SettingChanged → Firefox **实时**跟随，无需重启
- 这也是"为什么装着 xdg-desktop-portal-kde 还会轮到 GTK 后端回答"的答案：UseIn 不匹配
  XFCE 时 KDE 后端不入选；gtk.portal 声明 UseIn=gnome，但它是 xdg-desktop-portal 的内置兜底
