#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2026-05-05
# @version  1.1
# @license  GPL-2.0+
#
# wine 运行 Chromium 类应用（如企业微信 wxwork.exe）时会创建一个
# 独立的 layered "drop-shadow" 窗口（WM_NAME 为空，比主窗口大约
# 36px 一圈）。即使设置了 _NET_WM_STATE_SKIP_TASKBAR/SKIP_PAGER，
# openbox 的 Alt+Tab (NextWindow) 仍然会列出它（openbox 的 NextWindow
# 不尊重 skip 标志，是已知设计选择）。
#
# 唯一稳定的解法：直接 unmap 该窗口。picom 不会绘制 unmapped 窗口，
# 所以它不会再有任何视觉/交互痕迹。
#
# 用法：作为长期后台任务在 X session 启动时运行。
# 依赖：xprop, xdotool, wmctrl

set -uo pipefail

DEPS=(xprop xdotool wmctrl)
for cmd in "${DEPS[@]}"; do
    if ! hash "$cmd" 2>/dev/null; then
        echo "wine_shadow_hide: missing dependency: $cmd" >&2
        exit 1
    fi
done

# 给定 wid，判断是否是 wxwork.exe 的"幻影窗"：WM_NAME 为空。
# 真窗口标题是 "企业微信"，子对话框可能有别的标题（搜索框/弹窗）。
function is_phantom() {
    local wid="$1"
    local cls name
    cls="$(xprop -id "$wid" WM_CLASS 2>/dev/null \
        | sed -nE 's/.*= "([^"]*)".*/\1/p')"
    [[ "$cls" != "wxwork.exe" ]] && return 1
    name="$(xprop -id "$wid" WM_NAME 2>/dev/null \
        | sed -nE 's/^WM_NAME[^=]*= "(.*)"$/\1/p')"
    [[ -z "$name" ]]
}

# 扫描当前所有受 WM 管理的 wxwork/wine 窗口，unmap 幻影窗。
# 不缓存 wid：X server 会复用 wid，缓存会让"重生"的幻影窗漏掉。
# 对已 unmapped 窗口重复 unmap 是无害 no-op。
function scan_once() {
    local wid
    while IFS= read -r wid; do
        [[ -z "$wid" ]] && continue
        if is_phantom "$wid"; then
            xdotool windowunmap "$wid" 2>/dev/null || true
        fi
    done < <(wmctrl -lx 2>/dev/null | awk '$3 ~ /\.exe$/ {print $1}')
}

# 监听 _NET_CLIENT_LIST 变化（窗口 map/unmap/destroy 时触发）
scan_once
xprop -root -spy _NET_CLIENT_LIST 2>/dev/null | while read -r _line; do
    scan_once
done
