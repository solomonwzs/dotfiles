# Chroot 开发环境脚本

`shell/chroot_dev.sh` 用于把一个准备好的根目录挂载为临时 chroot 开发环境。

## 调用方式

脚本需要 Bash；不要用 `sh` 执行，因为脚本使用 Bash 数组和 `[[ ... ]]`。

```bash
bash shell/chroot_dev.sh setup \
    --root /path/to/root \
    --mountpoint /path/to/mountpoint \
    [--home /path/to/home] \
    [--user user] \
    [--no-data] \
    [--bind-mount /path/on/host:/path/in/chroot]...

bash shell/chroot_dev.sh down \
    --mountpoint /path/to/mountpoint
```

- `--root`：chroot 根目录。
- `--mountpoint`：chroot 挂载位置；`setup` 会自动创建它。
- `--home`：可选，默认 `/home`；默认挂载到 `<mountpoint>/home`。
- `--user`：可选。指定时，`--home` 目录改为挂载到 `<mountpoint>/home/<user>`；未指定时保持挂载到 `<mountpoint>/home`。
- `--no-data`：可选，跳过宿主机 `/data` 到 `<mountpoint>/data` 的挂载。
- `--bind-mount <source>:<target>`：可重复使用，将宿主机的绝对目录或常规文件 `source` 挂载到 chroot 内的绝对路径 `target`；例如 `--bind-mount /workspace/project:/workspace/project` 会挂载到 `<mountpoint>/workspace/project`。脚本会按 source 类型自动创建目标目录或文件；不接受相对路径、`/`、`.`、`..`、符号链接或路径中包含冒号的映射。

## 挂载点准备

文件 bind mount 要求 chroot 根目录中存在目标文件，目录挂载也要求目标目录存在。因此在根目录 bind mount 前，应创建以下目标：

- 目录：`home`、`data`、`etc`、`proc`、`sys`、`dev/pts`、`dev/shm`、`run/udev`、`tmp`。
- 文件：`etc/hosts`、`etc/passwd`、`etc/shadow`、`etc/resolv.conf`。

缺少这些目标时，`mount` 会报 `mount point does not exist`。

## 清理与诊断

- 根目录 bind mount 后应执行 `mount --make-private`，避免挂载传播到宿主机的共享挂载命名空间。
- setup 期间将成功挂载的目标按逆序记录；发生错误时通过 `EXIT` trap 逆序卸载，避免残留挂载。
- `down` 使用 `findmnt --mountpoint <path> --submounts --list --noheadings --output TARGET` 获取纯路径列表；`--list` 很重要，否则默认树形输出会含 `├─`、`└─` 等字符，无法直接传给 `umount`。
- 卸载必须从子挂载到父挂载的逆序执行；单个卸载失败时仍继续处理剩余挂载点。
- 每次创建、挂载、查询和卸载均记录 `[MSG]` 日志。挂载失败时，最后一条 `mounting <source> at <target>` 日志可定位失败操作。
