<!--
  @author   solomon <solomon.wzs@gmail.com>
  @date     2026-09-02
  @license  GPL-2.0+
-->

# Gruvbox-GTK-Light

参考 `gruvbox-material-gtk-dark-hidpi` 的结构写的 gruvbox 浅色主题（Xfce 适用）。
颜色全部取自 `ui/gruvbox-palette.html` 的 classic gruvbox 浅色部分。

## 结构

| 目录 | 内容 |
|------|------|
| `gtk-3.0/gtk.css` | GTK3 主样式（按钮/输入框/headerbar/菜单/notebook/滚动条/开关等） |
| `gtk-3.0/xfce4.css` | xfce4-panel、xfdesktop、xfce4-notifyd、xfwm4 tabwin 专属样式 |
| `gtk-2.0/*.rc` | GTK2（murrine 引擎纯色绘制，无 pixmap 资源；`main.rc` + `apps.rc` + `hacks.rc`） |
| `xfwm4/` | xfwm4 窗口装饰：`themerc` + 60 个 SVG（几何同暗色版，配色换浅色） |
| `gen-xfwm4.py` | 重新生成 `xfwm4/*.svg` 的脚本（`python3 gen-xfwm4.py`） |

## 配色速查

- 背景 `bg0 #fbf1c7`，面板/菜单/标题栏 `#f2e5bc`（bg0_s），非激活标题栏 `#ebdbb2`（bg1）
- 前景 `#282828`，次级文字 `#3c3836 … #7c6f64`
- 选中/强调 `#7c6f64`（中性灰，与暗色主题的做法一致）
- 图标悬停红 `#9d0006`（faded red）
- 链接 `#076678`，警告 `#b57614`，成功 `#427b58`

## 安装

```bash
ln -s "$(pwd)/ui/gruvbox-gtk-light" "$HOME/.themes/Gruvbox-GTK-Light"
# 窗口管理器
xfconf-query -c xfwm4 -p /general/theme -s "Gruvbox-GTK-Light"
# GTK3（外观设置里选，或命令行）
xfconf-query -c xsettings -p /Net/ThemeName -s "Gruvbox-GTK-Light"
# GTK2 如有需要：编辑 ~/.gtkrc-2.0 里 include ".../gtkrc"
```

与暗色主题一样不含 metacity / gnome-shell / cinnamon 等目录，保持精简。
