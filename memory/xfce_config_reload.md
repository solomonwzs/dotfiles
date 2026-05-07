# XFCE 配置重载

## 问题

修改 `~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml`（例如 `xfce4-keyboard-shortcuts.xml`）后，修改不会立即生效——按 Super+R 仍然是旧命令。

## 根因

xfconf 的工作模型是**读一次、内存常驻、写一次**：

```
xml 文件  ←  写回（logout 或 xfconf-query --save）
   ↓ 读取（xfconfd 启动时一次性）
xfconfd（守护进程，内存里维护配置树）
   ↓ dbus 通知 property-changed signal
xfsettingsd（监听 signal，把快捷键注册为 X grab）
   ↓ X grab
键盘事件 → 触发命令
```

- 手改 xml **不会** emit 任何 dbus signal，xfconfd 不知道
- 仅 `pkill xfconfd`（重读 xml）也不够：xfconfd 重启时 xfsettingsd 的 dbus connection 断了，xfsettingsd 继续用启动时的旧快捷键表注册 X grab
- **两个都必须重启**

## 标准操作

```sh
# 1. 重启 xfconfd —— 重读 xml 到内存
pkill xfconfd    # dbus 会自动拉起

# 2. 重启 xfsettingsd —— 重新注册 X 快捷键 grab
pkill xfsettingsd
sleep 1
DISPLAY=:0 setsid xfsettingsd >/dev/null 2>&1 & disown
```

## 按改动内容决定需要重启的组件

| 改的 xml 文件 | 需要重启 |
|---|---|
| `xfce4-keyboard-shortcuts.xml` | xfconfd + xfsettingsd |
| `xsettings.xml`（主题/字体/光标） | xfconfd + xfsettingsd |
| `xfwm4.xml`（窗口管理） | xfconfd + `xfwm4 --replace &` |
| `xfce4-panel.xml` | xfconfd + `xfce4-panel -r` |
| `thunar.xml` | xfconfd + 关闭再开 Thunar |
| `xfce4-desktop.xml` | xfconfd + `xfdesktop --reload` |

## 更干净的做法：不直接改 xml，用 `xfconf-query`

```sh
# 设置某个值
xfconf-query -c xfce4-keyboard-shortcuts \
    -p '/commands/custom/<Super>r' -s "xfce4-appfinder -c"

# 删除（让其回落到 default 命名空间）
xfconf-query -c xfce4-keyboard-shortcuts \
    -p '/commands/custom/<Super>r' -r -R
```

xfconf-query 会直接更新 xfconfd 内存值并 emit dbus signal，xfsettingsd 自动收到并重新 grab——**不需要重启任何东西**，立即生效。logout 时 xfconfd 把内存值写回 xml。

## 两种工作流建议

- **临时调试 / 探索**：用 `xfconf-query` 改，立刻生效。满意后 logout 让 xml 写回，再从 dotfiles 同步。
- **批量整理 dotfiles**：直接编辑 xml，然后跑上面的 pkill 两步，或注销重登（最干净）。

## xml 里有多个同名 property 的坑

xfce 加载 xml 时按出现顺序后写覆盖前写。但把"空 entry + 实 entry"混放看起来混乱，且部分 xfce 版本解析有微妙差异。**同一快捷键只保留一个 `<property>` 节点**，明确 type/value。

## dotfiles symlink 被破坏的现象

logout 时 xfconfd 写回 xml 用 "写 tmp + rename" 策略，**会替换 symlink 为普通文件**。表现：
- 改 `~/dotfiles/config/xfce4/.../xxx.xml` 对运行时无影响
- `ls -la ~/.config/xfce4/xfconf/xfce-perchannel-xml/` 发现 xml 是普通文件而非 symlink

解决方式：install.sh 里按**单文件 symlink** 链每个 xml（而不是整目录 symlink），或在每次 xfce 大改后重新跑 install.sh。
