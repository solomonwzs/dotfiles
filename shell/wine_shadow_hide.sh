#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2026-05-07
# @version  1.6
# @license  GPL-2.0+
#
# wine 运行 Chromium 类应用（如企业微信 wxwork.exe）时会为每个有阴影的
# 窗口（主窗、菜单、对话框）各配一个 layered "drop-shadow" 辅助窗口——
# 空标题、尺寸严格包住对应的"真"窗口。这些幻影窗会挡住点击区、出现在
# Alt+Tab / window switcher 里。
#
# 本脚本扫描所有空标题 wxwork 窗口，若其几何严格包住某个非空标题的
# wxwork 窗口，则判定为幻影并 unmap。
#
# 已知 trade-off：
#   * Chromium 菜单项悬停动画会高频重建菜单幻影（新 wid），脚本会跟着
#     unmap 新幻影，视觉上有闪烁。属可接受现象——只要主窗不被挡、
#     菜单最终可用即可。
#   * 全局最小间隔 MIN_INTERVAL_MS 限制脚本自身的 unmap 频率，避免在
#     Chromium 重建风暴下 fork 爆炸。
#
# 依赖：xprop, xdotool, wmctrl

set -uo pipefail

DEPS=(xprop xdotool wmctrl)
for cmd in "${DEPS[@]}"; do
    if ! hash "$cmd" 2>/dev/null; then
        echo "wine_shadow_hide: missing dependency: $cmd" >&2
        exit 1
    fi
done

# 全局最小 unmap 间隔（毫秒）：两次 scan_once 之间至少间隔这么久
MIN_INTERVAL_MS=150
LAST_SCAN_MS=0

function now_ms() {
    local s ns
    read -r s ns < <(date +'%s %N')
    # 清除 ns 前导 0（避免 bash 误当八进制）
    ns=${ns#"${ns%%[!0]*}"}
    ns=${ns:-0}
    echo $(( s * 1000 + ns / 1000000 ))
}

function get_geom() {
    xdotool getwindowgeometry --shell "$1" 2>/dev/null \
        | awk -F= '
            /^X=/{x=$2}
            /^Y=/{y=$2}
            /^WIDTH=/{w=$2}
            /^HEIGHT=/{h=$2}
            END{if(w) printf "%d %d %d %d", x, y, w, h}
        '
}

function get_wm_name() {
    xprop -id "$1" WM_NAME 2>/dev/null \
        | sed -nE 's/^WM_NAME[^=]*= "(.*)"$/\1/p'
}

function get_wm_class() {
    xprop -id "$1" WM_CLASS 2>/dev/null \
        | sed -nE 's/.*= "([^"]*)".*/\1/p'
}

# A 严格包住 B？ax ay aw ah bx by bw bh
function contains() {
    local ax=$1 ay=$2 aw=$3 ah=$4 bx=$5 by=$6 bw=$7 bh=$8
    (( ax < bx && ay < by && ax + aw > bx + bw && ay + ah > by + bh ))
}

function scan_once() {
    local cur
    cur="$(now_ms)"
    # 全局节流：距离上次扫描不足 MIN_INTERVAL_MS 毫秒则跳过
    if (( cur - LAST_SCAN_MS < MIN_INTERVAL_MS )); then
        return
    fi
    LAST_SCAN_MS="$cur"

    # 收集所有 wxwork 窗口的 name + geom
    # 显式初始化为空数组：bash 在 `set -u` 下对未追加过的 local
    # 数组在 ${#arr[@]} 上报 unbound variable（没 wxwork 窗口时就会发生）。
    local -a wids=() names=() geoms=()
    local wid name geom w h
    while IFS= read -r wid; do
        [[ -z "$wid" ]] && continue
        [[ "$(get_wm_class "$wid")" != "wxwork.exe" ]] && continue
        name="$(get_wm_name "$wid")"
        geom="$(get_geom "$wid")"
        [[ -z "$geom" ]] && continue
        read -r _ _ w h <<< "$geom"
        # 跳过 1×1 辅助窗
        (( w <= 2 || h <= 2 )) && continue
        wids+=("$wid")
        names+=("$name")
        geoms+=("$geom")
    done < <(wmctrl -lx 2>/dev/null | awk '$3 ~ /wxwork\.exe/ {print $1}')

    local n=${#wids[@]}
    local i j ax ay aw ah bx by bw bh
    for (( i=0; i<n; i++ )); do
        # 只考虑空标题候选
        [[ -n "${names[$i]}" ]] && continue
        read -r ax ay aw ah <<< "${geoms[$i]}"
        # 排除高度 <60px 的装饰带（主窗标题栏 ~28px）
        (( ah < 60 )) && continue

        local is_shadow=0
        for (( j=0; j<n; j++ )); do
            (( i == j )) && continue
            [[ -z "${names[$j]}" ]] && continue
            read -r bx by bw bh <<< "${geoms[$j]}"
            if contains "$ax" "$ay" "$aw" "$ah" "$bx" "$by" "$bw" "$bh"; then
                is_shadow=1
                break
            fi
        done

        if (( is_shadow )); then
            xdotool windowunmap "${wids[$i]}" 2>/dev/null || true
        fi
    done
}

scan_once
xprop -root -spy _NET_CLIENT_LIST 2>/dev/null | while read -r _line; do
    scan_once
done
