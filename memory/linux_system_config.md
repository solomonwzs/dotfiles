# Linux 系统配置

## GRUB 配置

### 设置 GRUB 字体
```sh
grub-mkfont -s 30 -o /boot/grubfont.pf2 /usr/share/fonts/gnu-free/FreeMono.otf
```
在 `/etc/default/grub` 中设置 `GRUB_FONT="/boot/grubfont.pf2"`

### 禁用 gpe16 高 CPU 中断
查看活跃中断：`grep . -r /sys/firmware/acpi/interrupts | grep -v "  0"`
在 `/etc/default/grub` 的 `GRUB_CMDLINE_LINUX_DEFAULT` 中添加 `acpi_mask_gpe=0x16`：
```sh
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 acpi_mask_gpe=0x16 quiet"
```
更新：`grub-mkconfig -o /boot/grub/grub.cfg`

## BIOS 更新
```sh
sudo fwupdmgr refresh
sudo fwupdmgr get-updates
sudo fwupdmgr update
```

## Hibernate 休眠

**创建交换文件：**
```sh
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048  # 2G
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

**获取交换文件偏移量：**
```sh
sudo filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'
```

**获取设备 UUID：**
```sh
findmnt -no UUID -T /swapfile
```

**配置 GRUB**（`/etc/default/grub`）：
```conf
GRUB_CMDLINE_LINUX="resume=UUID=<UUID> resume_offset=<偏移量> zswap.enabled=1"
```

**配置 systemd 休眠模式**（`/etc/systemd/sleep.conf.d/hibernatemode.conf`）：
```conf
[Sleep]
HibernateMode=shutdown
```

**执行休眠：** `sudo systemctl hibernate`

## ThinkPad

**ACPI 模块：** 在 `/etc/modules-load.d/thinkpad.conf` 中添加 `thinkpad_acpi` 使其开机自动加载。

**重新加载触摸板驱动：**
```sh
sudo modprobe -r psmouse
sudo modprobe -r rmi_smbus rmi_core
sudo modprobe rmi_smbus rmi_core
sudo modprobe psmouse
```
