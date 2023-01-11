#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2023-01-03
# @version  1.0
# @license  MIT

set -euo pipefail

pid_file="/tmp/.tmux_status.pid"
if [ -f "$pid_file" ]; then
    exit
fi

function clearup() {
    [ -f "$pid_file" ] && rm "$pid_file"
}

echo "$$" >"$pid_file"
trap 'clearup; exit' EXIT TERM INT

if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
    EXECUTE_FILENAME=$(greadlink -f "$0")
else
    EXECUTE_FILENAME=$(readlink -f "$0")
fi
EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")
source "$EXECUTE_DIRNAME/utils.sh"

init_net_dev_list
while true; do
    # sleep "${MY_TMUX_STATUS_INTERVAL:-1}"
    sleep 2

    has_clients=$(tmux list-clients)
    if [ -z "$has_clients" ]; then
        break
    fi

    init_status_line
    for i in "${!MY_TMUX_COMPONENTS[@]}"; do
        x="${MY_TMUX_COMPONENTS[$i]}"
        if [ "${x::4}" = "net:" ]; then
            component_net "$i"
        elif [ "$x" = "cpu" ]; then
            component_cpu
        elif [ "$x" = "cpus" ]; then
            component_cpus
        elif [ "$x" = "cpu_htg" ]; then
            component_cpu_histogram
        elif [ "$x" = "cpu_dot_htg" ]; then
            component_cpu_dot_histogram
        elif [ "$x" = "mem" ]; then
            component_mem
        elif [ "$x" = "mem_htg" ]; then
            component_mem_histogram
        elif [ "$x" = "mem_dot_htg" ]; then
            component_mem_dot_histogram
        elif [ "$x" = "temp" ]; then
            component_temp
        elif [ "$x" = "power" ]; then
            component_power
        else
            append_status_line "$x"
        fi
    done
    tmux set-environment "MY_TMUX_STATUS" "$(show_status_line)"
done
