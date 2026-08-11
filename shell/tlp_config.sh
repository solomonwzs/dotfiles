#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2026-08-11
# @version  1.0
# @license  GPL-2.0+
#
# Write TLP custom settings to /etc/tlp.d/01-dotfiles.conf.
# Settings are extracted from modifications to /etc/tlp.conf.
#
# Usage:
#   sudo tlp_config.sh               # write the drop-in and reload TLP
#   sudo tlp_config.sh -d            # delete the drop-in and reload TLP
#   tlp_config.sh -h                 # show help

set -euo pipefail

DROPIN="/etc/tlp.d/01-dotfiles.conf"

function usage() {
    sed -n '/^# Usage:/,/^$/p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

function die() {
    printf '[tlp_config] ERROR: %s\n' "$*" >&2
    exit 1
}

function info() {
    printf '[tlp_config] %s\n' "$*"
}

function require_root() {
    if [[ $EUID -ne 0 ]]; then
        die "this script needs root privileges (use sudo)"
    fi
}

function write_dropin() {
    info "writing $DROPIN"
    cat > "$DROPIN" <<'EOF'
# TLP custom settings – managed by tlp_config.sh
# See /etc/tlp.conf for defaults and documentation.

# CPU energy/performance policy on AC: reduce from balance_performance to balance_power
CPU_ENERGY_PERF_POLICY_ON_AC=balance_power

# Enable PCIe runtime power management on AC (default: on = disabled)
RUNTIME_PM_ON_AC=auto

# Battery charge stop threshold (Lenovo ThinkPad conservation mode)
STOP_CHARGE_THRESH_BAT0=80
EOF
}

function remove_dropin() {
    if [[ -f "$DROPIN" ]]; then
        info "removing $DROPIN"
        rm -f "$DROPIN"
    else
        info "$DROPIN does not exist, nothing to remove"
    fi
}

function reload_tlp() {
    if hash tlp 2>/dev/null; then
        info "reloading TLP configuration"
        tlp start
    else
        info "tlp not found; configuration will apply on next boot"
    fi
}

while getopts "dh" opt; do
    case "$opt" in
        d) REMOVE_ONLY=1 ;;
        h) usage 0 ;;
        *) usage 1 ;;
    esac
done

require_root

if [[ -n "${REMOVE_ONLY:-}" ]]; then
    remove_dropin
else
    write_dropin
fi

reload_tlp
info "done"
