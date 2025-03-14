#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2021-08-06
# @version  1.0
# @license  MIT

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
# EXECUTE_FILENAME=$(readlink -f "$0")
# EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

declare -a CHROOT_ACTIVE_MOUNTS=()

msg() {
    echo -e "\033[01;32m[MSG]\033[01;37m $1\033[0m"
}

error() {
    echo -e "\033[01;31m[ERR]\033[01;37m $1\033[0m"
}

die() {
    error "$@"
    exit 1
}

chroot_add_mount() {
    if ((${#CHROOT_ACTIVE_MOUNTS[@]})); then
        mount "$@" && CHROOT_ACTIVE_MOUNTS=("$2" "${CHROOT_ACTIVE_MOUNTS[@]}")
    else
        mount "$@" && CHROOT_ACTIVE_MOUNTS=("$2")
    fi
}

chroot_maybe_add_mount() {
    local cond=$1
    shift
    if eval "$cond"; then
        chroot_add_mount "$@"
    fi
}

chroot_teardown() {
    if ((${#CHROOT_ACTIVE_MOUNTS[@]})); then
        umount "${CHROOT_ACTIVE_MOUNTS[@]}"
    fi
    unset CHROOT_ACTIVE_MOUNTS
}

chroot_setup() {
    [[ $(trap -p EXIT) ]] && die '(BUG): attempting to overwrite existing EXIT trap'
    trap 'chroot_teardown' EXIT

    chroot_add_mount "$1" "$2" --bind &&
        mount --make-private "$2" &&
        chroot_add_mount /home "$2/home" --bind &&
        chroot_add_mount /data "$2/data" --bind &&
        chroot_add_mount /etc/hosts "$2/etc/hosts" --bind &&
        chroot_add_mount /etc/passwd "$2/etc/passwd" --bind &&
        chroot_add_mount /etc/shadow "$2/etc/shadow" --bind &&
        chroot_add_mount /etc/resolv.conf "$2/etc/resolv.conf" --bind &&
        chroot_add_mount proc "$2/proc" -t proc -o nosuid,noexec,nodev &&
        chroot_add_mount sys "$2/sys" -t sysfs -o nosuid,noexec,nodev,ro &&
        chroot_add_mount udev "$2/dev" -t devtmpfs -o mode=0755,nosuid &&
        chroot_add_mount devpts "$2/dev/pts" -t devpts -o mode=0620,gid=5,nosuid,noexec &&
        chroot_add_mount shm "$2/dev/shm" -t tmpfs -o mode=1777,nosuid,nodev &&
        chroot_add_mount /run "$2/run" --bind &&
        chroot_add_mount /run/udev "$2/run/udev" --bind &&
        chroot_add_mount tmp "$2/tmp" -t tmpfs -o mode=1777,strictatime,nodev,nosuid &&
        CHROOT_ACTIVE_MOUNTS=()
}

if [ "$1" == "setup" ]; then
    chroot_setup "$2" "/mnt/$3" || die "failed to setup chroot %s" "$2"
    msg "setup ok"
elif [ "$1" == "down" ]; then
    grep "/mnt/$2" /etc/mtab | awk '{print $2}' | tac | xargs -I{} umount {}
    msg "down ok"
else
    echo "unknown commad"
    exit 255
fi
