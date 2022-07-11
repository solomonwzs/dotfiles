#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-07-11
# @version  1.0
# @license  MIT

size_unit=("" "KB" "MB" "GB" "TB")
function flow_digital() {
    bps=$1
    i=0
    while [ "$bps" -gt 1024 ]; do
        bps=$((bps / 1024))
        i=$((i + 1))
    done
    u=${size_unit[$i]}
    echo "${bps}${u}/s"
}

percent_block_list=(" " "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
function percent_block() {
    i=$(bc <<<"$1/12.5")
    echo "${percent_block_list[$i]}"
}

function histogram() {
    fn="$2"
    str=""
    [ -f "$fn" ] && str=$(cat "$fn")
    str="$str$(percent_block "$1")"
    len=${#str}
    if [ ${#str} -gt 8 ]; then
        str="${str:$((len - 8)):8}"
    fi
    while [ ${#str} -lt 8 ]; do
        str=" ${str}"
    done
    echo -n "$str" > "$fn"
    echo -n "$str"
}
