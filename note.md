# Set font for grub

```sh
grub-mkfont -s 30 -o /boot/grubfont.pf2 /usr/share/fonts/gnu-free/FreeMono.otf
```
set `GRUB_FONT="/boot/grubfont.pf2"` in `/etc/default/grub`

# Disable gpe16 cause high cpu (Invalid?)

```sh
grep . -r /sys/firmware/acpi/interrupts | grep -v "  0"
```
set `acpi_mask_gpe=0x16` at `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`:
```sh
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 acpi_mask_gpe=0x16 quiet"
```

and update grub:
```sh
grub-mkconfig -o /boot/grub/grub.cfg
```

# Run steam with nvidia GPU

```sh
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia steam
```

# About thinkpad_acpi (Invalid?)

Adding a file called thinkpad.conf to /etc/modules-load.d/ with the line thinkpad_acpi fixed it. I don't know why the other things I tried don't make it load the module at boot.

# About Icons

check which the icons file name was used by: 

```sh
sed -En 's/(.*)\/(.*)\:.*.kdb.*/\1-\2/p' /usr/share/mime/globs
```
or 
```sh
sed -En 's/(.*)\/(.*)\:.*.kdb.*/\1-\2/p' $HOME/.local/share/mime/globs
```

edit `$HOME/.local/share/mime/packages/Override.xml`

It may be necessary to update the database:
```sh
update-mime-database $HOME/.local/share/mime
update-desktop-database $HOME/.local/share/applications
```

# Start Waydroid

start weston first, then start waydroid session
```sh
weston
sudo systemctl restart waydroid-container.service
WAYLAND_DISPLAY=wayland-1 waydroid session start
```

# Saving laptop battery power

```sh
pacman -S powertop
pacman -S tlp tlp-rdw
pacman -S tp_smapi acpi_call # for ThinkPad
pacman -S smartmontools # show S.M.A.R.T info

sudo systemctl enable tlp.service

# avoid conflicts and ensure proper operation of TLP's radio device switching options
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
```

modify CPU energy/performance policies, set `CPU_ENERGY_PERF_POLICY_ON_AC` in `/etc/tlp.conf`

# fontconfig

edit [$HOME/.config/fontconfig/fonts.conf](https://catcat.cc/post/2021-03-07/)

# Update BIOS

check update
```sh
sudo fwupdmgr refresh
sudo fwupdmgr get-updates
```

update
```sh
sudo fwupdmgr update
```

# Chromium in HiDPI
```sh
chromium --force-device-scale-factor=2
```

# Hibernate

## create swap file:
```sh
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 # 1M * 2048, (2G)
```
or
```sh
sudo fallocate -l 2G /var/swapfile
```

then
```sh
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## get swapfile offset
```sh
sudo filefrag -v /swapfile
```
output:
Filesystem type is: ef53
File size of /var/swapfile is 8589934592 (2097152 blocks of 4096 bytes)
 ext:     logical_offset:        physical_offset: length:   expected: flags:
   0:        0..       0:   ***87500800***..  87500800:      1:            
   1:        1..   55295:   87500801..  87556095:  55295:             unwritten
   2:    55296..   57343:     493568..    495615:   2048:   87556096: unwritten
   3:    57344..   59391:     497664..    499711:   2048:     495616: unwritten
   4:    59392..   61439:     507904..    509951:   2048:     499712: unwritten
   5:    61440..   63487:    4614144..   4616191:   2048:     509952: unwritten
   6:    63488..   65535:    9486336..   9488383:   2048:    4616192: unwritten
or
```sh
sudo filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'
```

## get the UUID of the device where the swap file is located
```sh
findmnt -no UUID -T /swapfile
```
or find from `/etc/fstab`

## config grub
set `/etc/default/grub`
```conf
GRUB_CMDLINE_LINUX="resume=UUID=10c2b991-0126-4cfd-b2a4-1e0441e78917 resume_offset=87500800 zswap.enabled=1"
```
```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## config sleep.conf
`/etc/systemd/sleep.conf.d/hibernatemode.conf`
```conf
[Sleep]
HibernateMode=shutdown
```

## hibernate
```sh
sudo systemctl hibernate
```

# Reload psmouse for thinkpad
```sh
sudo modprobe -r psmouse
sudo modprobe psmouse
```

# About Kitty

## setting for fcitx
```
env GLFW_IM_MODULE=ibus kitty
```
