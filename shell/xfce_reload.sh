#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2026-05-07
# @version  1.0
# @license  GPL-2.0+
#
# Reload XFCE configuration after editing xml files under
# ~/.config/xfce4/xfconf/xfce-perchannel-xml/.
#
# Background: xfconfd reads xml files once at startup into an in-memory
# tree; xfsettingsd then subscribes to xfconf property-changed signals
# and registers X keyboard grabs. Editing xml directly bypasses both,
# so neither sees your change. Restarting xfconfd alone is also not
# enough — when xfconfd dies, xfsettingsd's dbus subscription silently
# breaks and it keeps using the old key table.
#
# See memory/xfce_config_reload.md for details.
#
# Usage:
#   xfce_reload.sh                 # reload xfconfd + xfsettingsd
#   xfce_reload.sh -p              # also reload xfce4-panel
#   xfce_reload.sh -w              # also replace xfwm4
#   xfce_reload.sh -d              # also reload xfdesktop
#   xfce_reload.sh -a              # all of the above
#   xfce_reload.sh -h              # show help

set -euo pipefail

RELOAD_PANEL=0
RELOAD_WM=0
RELOAD_DESKTOP=0

function usage() {
    sed -n '/^# Usage:/,/^$/p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

while getopts "pwdah" opt; do
    case "$opt" in
        p) RELOAD_PANEL=1 ;;
        w) RELOAD_WM=1 ;;
        d) RELOAD_DESKTOP=1 ;;
        a) RELOAD_PANEL=1; RELOAD_WM=1; RELOAD_DESKTOP=1 ;;
        h) usage 0 ;;
        *) usage 1 ;;
    esac
done

function info() {
    printf '[xfce_reload] %s\n' "$*"
}

function warn() {
    printf '[xfce_reload] WARN: %s\n' "$*" >&2
}

function ensure_display() {
    if [[ -z "${DISPLAY:-}" ]]; then
        warn "DISPLAY not set; defaulting to :0"
        export DISPLAY=:0
    fi
}

# Wait up to N seconds for a command to appear / disappear in pgrep
# args: want (1=appear, 0=disappear) pattern max_seconds
function wait_for_proc() {
    local want="$1" pattern="$2" max="$3"
    local i=0
    while (( i < max * 10 )); do
        if pgrep -x "$pattern" >/dev/null 2>&1; then
            (( want == 1 )) && return 0
        else
            (( want == 0 )) && return 0
        fi
        sleep 0.1
        (( i++ ))
    done
    return 1
}

function reload_xfconfd() {
    if ! pgrep -x xfconfd >/dev/null 2>&1; then
        info "xfconfd not running; it will spawn on next xfconf call"
        return
    fi
    info "restarting xfconfd (re-reads xml files)"
    pkill -x xfconfd || true
    wait_for_proc 0 xfconfd 3 || warn "xfconfd did not exit in time"
    # xfconfd is dbus-activated; first query re-spawns it
    if hash xfconf-query 2>/dev/null; then
        xfconf-query -c xfce4-keyboard-shortcuts -l >/dev/null 2>&1 || true
    fi
    wait_for_proc 1 xfconfd 3 || warn "xfconfd did not respawn in time"
}

function reload_xfsettingsd() {
    info "restarting xfsettingsd (re-registers X key grabs)"
    pkill -x xfsettingsd || true
    wait_for_proc 0 xfsettingsd 3 || warn "xfsettingsd did not exit in time"
    # xfsettingsd is NOT auto-respawned under a minimal xfce session,
    # so start it manually and detach.
    setsid xfsettingsd >/dev/null 2>&1 & disown
    wait_for_proc 1 xfsettingsd 3 || warn "xfsettingsd did not start"
}

function reload_panel() {
    if hash xfce4-panel 2>/dev/null; then
        info "reloading xfce4-panel"
        xfce4-panel -r >/dev/null 2>&1 || warn "xfce4-panel -r failed"
    else
        warn "xfce4-panel not found"
    fi
}

function replace_wm() {
    if hash xfwm4 2>/dev/null; then
        info "replacing xfwm4"
        setsid xfwm4 --replace >/dev/null 2>&1 & disown
    else
        warn "xfwm4 not found"
    fi
}

function reload_desktop() {
    if hash xfdesktop 2>/dev/null; then
        info "reloading xfdesktop"
        xfdesktop --reload >/dev/null 2>&1 || warn "xfdesktop --reload failed"
    else
        warn "xfdesktop not found"
    fi
}

ensure_display
reload_xfconfd
reload_xfsettingsd
(( RELOAD_PANEL == 1 )) && reload_panel
(( RELOAD_WM == 1 )) && replace_wm
(( RELOAD_DESKTOP == 1 )) && reload_desktop
info "done"
