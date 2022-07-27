#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-07-03
# @version  1.0
# @license  MIT

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
    EXECUTE_FILENAME=$(greadlink -f "$0")
else
    EXECUTE_FILENAME=$(readlink -f "$0")
fi
EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")
source "$EXECUTE_DIRNAME/utils.sh"

sess_idx=""
while getopts "i:s:" opt; do
    case "$opt" in
    s)
        sess_idx=${OPTARG}
        ;;
    *) ;;
    esac
done

for i in "${!MY_TMUX_COMPONENTS[@]}"; do
    dev="${MY_TMUX_COMPONENTS[$i]}"
    if [ "${dev::4}" = "net:" ]; then
        add_netdev "$i" "${dev:4}"
    fi
done

for i in "${!MY_TMUX_COMPONENTS[@]}"; do
    x="${MY_TMUX_COMPONENTS[$i]}"
    if [ "${x::4}" = "net:" ]; then
        component_net "$i"
    elif [ "$x" = "cpu" ]; then
        component_cpu "$sess_idx"
    elif [ "$x" = "mem" ]; then
        component_mem "$sess_idx"
    elif [ "$x" = "temp" ]; then
        component_temp
    else
        printf "%s" "$x"
    fi
done
