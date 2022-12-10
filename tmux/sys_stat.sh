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
while getopts "i:s:" opt; do
    case "$opt" in
    s)
        g_sess_index=${OPTARG}
        ;;
    *) ;;
    esac
done

# force refresh tmux status
# printf "[%d %d]" "${MY_TMUX_STATUS_INTERVAL:-1}" "$(date +%s)"
sleep "${MY_TMUX_STATUS_INTERVAL:-1}"

for i in "${!MY_TMUX_COMPONENTS[@]}"; do
    x="${MY_TMUX_COMPONENTS[$i]}"
    if [ "${x::4}" = "net:" ]; then
        component_net "${x#*:}"
    elif [ "$x" = "cpu" ]; then
        component_cpu
    elif [ "$x" = "cpus" ]; then
        component_cpus
    elif [ "$x" = "mem" ]; then
        component_mem
    elif [ "$x" = "temp" ]; then
        component_temp
    elif [ "$x" = "power" ]; then
        component_power
    else
        printf "%s" "$x"
    fi
done
