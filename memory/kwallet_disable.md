# 禁用 kwalletd6（KDE 钱包弹窗）

## 现象

kwalletd6 弹出"创建钱包"向导要求设置密码。本机状态：`kwallet` 6.31（仅运行时），
未装 `kwalletmanager`，`~/.config/kwalletrc` 不存在（从未创建过钱包）。

## 机制

- kwalletd6 **纯 dbus 激活**：应用调用 `org.kde.kwalletd6` →
  `/usr/share/dbus-1/services/org.kde.kwalletd6.service` 的 `Exec=` 直接拉起进程
- 无 systemd unit、无 /etc/xdg/autostart 项 → 想让进程"根本不出现"只能改系统文件，不值得
- 常见触发者：**chromium**（KDE 桌面下默认用 kwallet 存密码）、plasma-nm（用户连接的 secrets）

## 禁用（写配置即可，不用装 GUI）

```bash
# 官方开关：整体关闭钱包子系统（GUI 里那个勾选框写的就是这个）
kwriteconfig6 --file kwalletrc --group Wallet --key Enabled false
# 杀掉已运行的实例（正在跑的进程不会重读配置，下次 dbus 激活时自然读到新值）
pkill -x kwalletd6
```

等价 GUI：系统设置 → 账户详细信息 → KDE 钱包 → 取消"启用 KDE 钱包子系统"。
注意该设置模块（KCM）在 **`kwalletmanager`** 包里（旧名 kwalletmanager6）；只装 `kwallet`
的话系统设置里没有这一项。

## 效果与代价

- 应用调用 kwallet 直接得到"子系统已禁用"错误，**弹窗消失**；kwalletd 进程可能仍被
  dbus 拉起但处于惰性状态，无害
- chromium 密码存储退回 profile 内明文；只想让 chromium 不碰 kwallet 可用
  `chromium --password-store=basic`
- wifi 系统连接的密码存在 `/etc/NetworkManager/system-connections`，不经过 kwallet，不受影响

## 备选方案

- 只烦弹窗但想要功能：把向导走完一次，创建钱包时**密码留空** → 之后静默自动打开，永不再弹
  （不安全警告可忽略，本就只是省事）

## 验证

```bash
kreadconfig6 --file kwalletrc --group Wallet --key Enabled   # → false
pgrep -a kwalletd                                              # 空或无弹窗行为
```
