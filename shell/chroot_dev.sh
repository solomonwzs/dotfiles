#!/usr/bin/env bash
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
declare -a CHROOT_BIND_SOURCES=()
declare -a CHROOT_BIND_TARGETS=()

msg() {
    printf '\033[01;32m[MSG]\033[01;37m %s\033[0m\n' "$*"
}

error() {
    printf '\033[01;31m[ERR]\033[01;37m %s\033[0m\n' "$*" >&2
}

die() {
    error "$*"
    exit 1
}

usage() {
    printf 'Usage: %s setup --root <path> --mountpoint <path> [--home <path>] [--no-data] [--bind-mount <source>:<target>]...\n' "${0##*/}" >&2
    printf '       %s down --mountpoint <path>\n' "${0##*/}" >&2
}

add_bind_mount() {
    local mapping=$1
    local source
    local target
    local component
    local -a target_components=()

    [[ "$mapping" == *:* && "$mapping" != *:*:* ]] || die "invalid --bind-mount mapping: $mapping"
    source=${mapping%%:*}
    target=${mapping#*:}

    [[ "$source" == /* && ( -d "$source" || -f "$source" ) ]] || die "bind mount source must be an existing absolute directory or file: $source"
    [[ "$target" == /* && "$target" != / && "$target" != */ && "$target" != *//* ]] || die "bind mount target must be an absolute directory below the chroot root: $target"

    IFS=/ read -r -a target_components <<< "${target#/}"
    for component in "${target_components[@]}"; do
        [[ -n "$component" && "$component" != . && "$component" != .. ]] || die "invalid bind mount target: $target"
    done

    CHROOT_BIND_SOURCES+=("$source")
    CHROOT_BIND_TARGETS+=("$target")
}

parse_setup_args() {
    CHROOT_ROOT=''
    CHROOT_MOUNTPOINT=''
    CHROOT_HOME='/home'
    CHROOT_MOUNT_DATA=true
    CHROOT_BIND_SOURCES=()
    CHROOT_BIND_TARGETS=()

    while (($#)); do
        case "$1" in
            --root)
                (($# >= 2)) || die 'missing value for --root'
                CHROOT_ROOT=$2
                shift 2
                ;;
            --mountpoint)
                (($# >= 2)) || die 'missing value for --mountpoint'
                CHROOT_MOUNTPOINT=$2
                shift 2
                ;;
            --home)
                (($# >= 2)) || die 'missing value for --home'
                CHROOT_HOME=$2
                shift 2
                ;;
            --no-data)
                CHROOT_MOUNT_DATA=false
                shift
                ;;
            --bind-mount)
                (($# >= 2)) || die 'missing value for --bind-mount'
                add_bind_mount "$2"
                shift 2
                ;;
            *)
                die "unknown setup option: $1"
                ;;
        esac
    done

    [[ -n "$CHROOT_ROOT" ]] || die 'missing required option: --root'
    [[ -n "$CHROOT_MOUNTPOINT" ]] || die 'missing required option: --mountpoint'
}

parse_down_args() {
    CHROOT_MOUNTPOINT=''

    while (($#)); do
        case "$1" in
            --mountpoint)
                (($# >= 2)) || die 'missing value for --mountpoint'
                CHROOT_MOUNTPOINT=$2
                shift 2
                ;;
            *)
                die "unknown down option: $1"
                ;;
        esac
    done

    [[ -n "$CHROOT_MOUNTPOINT" ]] || die 'missing required option: --mountpoint'
}

chroot_add_mount() {
    msg "mounting $1 at $2"
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
    local mount_point
    local status=0

    for mount_point in "${CHROOT_ACTIVE_MOUNTS[@]}"; do
        msg "unmounting $mount_point"
        if ! umount "$mount_point"; then
            error "failed to unmount $mount_point"
            status=1
        fi
    done
    CHROOT_ACTIVE_MOUNTS=()

    return "$status"
}

chroot_prepare_bind_mount_target() {
    local chroot_root=$1
    local bind_source=$2
    local bind_target=$3
    local component
    local current_path=$chroot_root
    local index
    local last_index
    local -a target_components=()

    IFS=/ read -r -a target_components <<< "${bind_target#/}"
    last_index=$((${#target_components[@]} - 1))

    for index in "${!target_components[@]}"; do
        component=${target_components[$index]}
        current_path="$current_path/$component"
        [[ ! -L "$current_path" ]] || die "bind mount target contains symbolic link: $bind_target"

        if [[ -d "$bind_source" || "$index" -lt "$last_index" ]]; then
            mkdir -p "$current_path"
        else
            [[ ! -e "$current_path" ]] && touch "$current_path"
            [[ -f "$current_path" ]] || die "bind mount file target is not a regular file: $bind_target"
        fi
    done
}

chroot_prepare_mount_points() {
    local chroot_root=$1

    [[ -d "$chroot_root" ]] || die "chroot root does not exist or is not a directory: $chroot_root"

    msg "preparing mount points in $chroot_root"
    mkdir -p "$chroot_root"/{home,data,etc,proc,sys,dev/pts,dev/shm,run/udev,tmp}
    touch "$chroot_root"/etc/{hosts,passwd,shadow,resolv.conf}
}

chroot_prepare_bind_mount_targets() {
    local chroot_mountpoint=$1
    local bind_target
    local index

    for index in "${!CHROOT_BIND_TARGETS[@]}"; do
        bind_target=${CHROOT_BIND_TARGETS[$index]}
        msg "creating bind mount target $chroot_mountpoint$bind_target"
        chroot_prepare_bind_mount_target "$chroot_mountpoint" "${CHROOT_BIND_SOURCES[$index]}" "$bind_target"
    done
}

chroot_add_bind_mounts() {
    local index
    local bind_source
    local bind_target

    for index in "${!CHROOT_BIND_SOURCES[@]}"; do
        bind_source=${CHROOT_BIND_SOURCES[$index]}
        bind_target="$1${CHROOT_BIND_TARGETS[$index]}"
        [[ -d "$bind_source" || -f "$bind_source" ]] || die "bind mount source no longer exists: $bind_source"
        [[ ! -L "$bind_target" ]] || die "bind mount target contains symbolic link: ${CHROOT_BIND_TARGETS[$index]}"
        chroot_add_mount "$bind_source" "$bind_target" --bind || return
    done
}

chroot_setup() {
    msg "setting up chroot from $1 at $2"
    chroot_prepare_mount_points "$1"
    trap 'chroot_teardown' EXIT

    chroot_add_mount "$1" "$2" --bind &&
        msg "making $2 mount private" &&
        mount --make-private "$2" &&
        chroot_add_mount "$3" "$2/home" --bind &&
        {
            if [[ "$4" == true ]]; then
                chroot_add_mount /data "$2/data" --bind
            else
                msg 'skipping /data mount'
            fi
        } &&
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
        chroot_prepare_bind_mount_targets "$2" &&
        chroot_add_bind_mounts "$2" &&
        CHROOT_ACTIVE_MOUNTS=()
}

chroot_down() {
    local chroot_dir=$1
    local mount_point
    local status=0
    local -a mount_points=()

    msg "finding mounts below $chroot_dir"
    while IFS= read -r mount_point; do
        mount_points=("$mount_point" "${mount_points[@]}")
    done < <(findmnt --mountpoint "$chroot_dir" --submounts --list --noheadings --output TARGET 2>/dev/null || true)

    if ((${#mount_points[@]} == 0)); then
        msg "no mounts found below $chroot_dir"
    fi

    for mount_point in "${mount_points[@]}"; do
        msg "unmounting $mount_point"
        if ! umount "$mount_point"; then
            error "failed to unmount $mount_point"
            status=1
        fi
    done

    return "$status"
}

case "${1-}" in
    setup)
        shift
        parse_setup_args "$@"
        msg "creating chroot directory at $CHROOT_MOUNTPOINT"
        mkdir -p "$CHROOT_MOUNTPOINT" || die "failed to create chroot directory at $CHROOT_MOUNTPOINT"
        chroot_setup "$CHROOT_ROOT" "$CHROOT_MOUNTPOINT" "$CHROOT_HOME" "$CHROOT_MOUNT_DATA" || die "failed to set up chroot at $CHROOT_MOUNTPOINT"
        msg "setup ok"
        ;;
    down)
        shift
        parse_down_args "$@"
        chroot_down "$CHROOT_MOUNTPOINT" || die "failed to tear down chroot at $CHROOT_MOUNTPOINT"
        msg "down ok"
        ;;
    *)
        error "unknown command: ${1-}"
        usage
        exit 2
        ;;
esac
