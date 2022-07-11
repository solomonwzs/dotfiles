#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-07-03
# @version  1.0
# @license  MIT

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
EXECUTE_FILENAME=$(readlink -f "$0")
EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")
source "$EXECUTE_DIRNAME/utils.sh"

netdev=""
sess_idx=""
while getopts "i:s:" opt; do
    case "$opt" in
    i)
        netdev=${OPTARG}
        ;;
    s)
        sess_idx=${OPTARG}
        ;;
    *) ;;

    esac
done

netdev_ok=""
[ -d "/sys/class/net/${netdev}" ] && [ -n "$netdev" ] && netdev_ok=1

if [ -n "$netdev_ok" ]; then
    r0=$(cat "/sys/class/net/${netdev}/statistics/rx_bytes")
    t0=$(cat "/sys/class/net/${netdev}/statistics/tx_bytes")
fi

cpu=$(vmstat -n 1 2 | tail -n 1 | awk '{print 100 - $15}')

if [ -n "$netdev_ok" ]; then
    r1=$(cat "/sys/class/net/${netdev}/statistics/rx_bytes")
    t1=$(cat "/sys/class/net/${netdev}/statistics/tx_bytes")

    rbps=$((r1 - r0))
    tbps=$((t1 - t0))

    rs=$(flow_digital $rbps)
    ts=$(flow_digital $tbps)
fi

cpu_cores=$(nproc)
mem=$(free | awk '$1 == "Mem:" {print ($2 - $7) / $2 * 100}')
cpu_htg="$(histogram "$cpu" "/tmp/.tmux_cpu_htg_$sess_idx")"
mem_htg="$(histogram "$mem" "/tmp/.tmux_mem_htg_$sess_idx")"
load=$(uptime | awk -F'[, ]' '{print $(NF-4), $(NF-2), $(NF)}')

if [ -n "$netdev_ok" ]; then
    printf " %s %s |%s %2d%% |%s %2d%% \n" \
        "$rs" "$ts" "$cpu_htg" "$cpu" "$mem_htg" "$mem"
else
    printf " %2d%% | %2d%% | %s [%d] \n" "$cpu" "$mem" "$load" "$cpu_cores"
fi
