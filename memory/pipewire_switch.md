# PulseAudio → PipeWire 切换（Arch / Plasma 6 Wayland + XFCE 双会话）

## 切换前的状态

- 真 PulseAudio 17 在服务音频（由 `pulseaudio.socket`（enabled）激活）；`pipewire` 空转、
  `wireplumber` 没跑、`pipewire-pulse` 没装——Plasma Wayland 的截屏/门户视频流本来就依赖 pipewire
- 依赖 pulseaudio 的包：plasma-pa、pulseaudio-bluetooth、waydroid
  （pipewire-pulse `provides=pulseaudio`，前者和 waydroid 不受影响；pulseaudio-bluetooth 变废件）

## 切换步骤

```bash
# 1. 先停老服务（趁单元文件还在；此刻声音会断几秒）
systemctl --user disable --now pulseaudio.socket pulseaudio.service

# 2. 装新包（pacman 提示 pulseaudio 与 pipewire-pulse 冲突 → 选 Y 替换）
sudo pacman -S pipewire-pulse pipewire-alsa

# 3. 移除废件（蓝牙改由 wireplumber 内建，支持 AAC/LDAC）
sudo pacman -Rdd pulseaudio-bluetooth

# 4. 启用 PipeWire 三件套
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

## 验证

```bash
pactl info | grep "Server Name"
#   成功标志：PulseAudio (on PipeWire 1.6.9)   ← 应用仍以为自己在连 PulseAudio，这就是 drop-in 替换

wpctl status        # pipewire 原生工具：看声卡/sink 拓扑
```

- 正在放音乐的应用可能要暂停/恢复一次让它重连 socket
- 遇到怪问题：注销重登一次

## 各环境影响

| 环境 | 影响 |
|------|------|
| XFCE / i3 / openbox（X11 会话） | **无感**。音频走 `$XDG_RUNTIME_DIR/pulse/native` socket，与显示协议无关；三个用户级单元按**用户**启用，任何会话登录都拉起 |
| plasma-pa 托盘音量 | 同一 socket，自动重连，无感 |
| wine（winepulse）/ waydoid | 同一 socket，无感 |
| pavucontrol / xfce4-pulseaudio-plugin / 播放器 | 同一 socket，无感 |
| 蓝牙 | wireplumber 内建接管（比 pulseaudio-bluetooth 编码支持更好） |

## 回滚

```bash
sudo pacman -S pulseaudio pulseaudio-bluetooth      # 提示与 pipewire-pulse 冲突 → Y
systemctl --user disable --now pipewire pipewire-pulse wireplumber
systemctl --user enable --now pulseaudio.socket
```

注意：即使留在 PulseAudio 阵营，**不要卸载 pipewire 本体**——Plasma Wayland 的截屏/屏幕共享/门户视频流依赖它。

## 相关知识

- PipeWire = 用户态多媒体服务器（音频+视频），走 UNIX socket，与 X11/Wayland 无绑定；
  "和 Wayland 绑定"的只是它的视频流（截屏）功能——Wayland 禁止应用互抓窗口所以必须走它，X11 则无所谓
- Fedora 34 (2021) 首个默认切换，此后 Ubuntu 22.10+/Debian 12/Arch 全部跟进；PulseAudio 上游事实停更
