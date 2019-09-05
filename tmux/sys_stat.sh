#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-07-03
# @version  1.0
# @license  MIT

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
# EXECUTE_FILENAME=$(readlink -f "$0")
# EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

size_unit=("" "KB" "MB" "GB" "TB")
size_symbol=("." "-"  "="  "*"  "#")

function flow_digital() {
    bps=$1
    i=0
    while [ ${#bps} -gt 3 ]; do
        bps=$((bps / 1024))
        i=$((i + 1))
    done
    u=${size_unit[$i]}
    echo "${bps}${u}/s"
}

function flow_symbol() {
    bps=$1
    i=0
    while [ "$bps" -gt 1024 ]; do
        bps=$((bps / 1024))
        i=$((i + 1))
    done
    u=${size_symbol[$i]}

    if [ $bps -eq 0 ]; then
        echo "[   ]"
    elif [ $bps -lt 341 ]; then
        echo "[  ${u}]"
    elif [ $bps -lt 683 ]; then
        echo "[ ${u}${u}]"
    else
        echo "[${u}${u}${u}]"
    fi
}

netdev=""
while getopts "i:" opt; do
    case "$opt" in
        i)
            netdev=${OPTARG}
            ;;
        *)
            ;;
    esac
done

netdev_ok=""
[ -d "/sys/class/net/${netdev}" ] && [ -n "$netdev" ] && netdev_ok=1

if [ -n "$netdev_ok" ]; then
    r0=$(cat "/sys/class/net/${netdev}/statistics/rx_bytes")
    t0=$(cat "/sys/class/net/${netdev}/statistics/tx_bytes")
fi

# cpu_cores=$(nproc)
cpu=$(vmstat -n 1 2 | tail -n 1 | awk '{print 100 - $15}')

if [ -n "$netdev_ok" ]; then
    r1=$(cat "/sys/class/net/${netdev}/statistics/rx_bytes")
    t1=$(cat "/sys/class/net/${netdev}/statistics/tx_bytes")

    rbps=$((r1 - r0))
    tbps=$((t1 - t0))

    rs=$(flow_symbol $rbps)
    ts=$(flow_symbol $tbps)
fi

mem=$(free | awk '$1 == "Mem:" {print ($2 - $7) / $2 * 100}')
load=$(uptime | awk -F'[, ]' '{print $(NF-4), $(NF-2), $(NF)}')

if [ -n "$netdev_ok" ]; then
    printf " %2d%% | %2d%% | %s |%s%s \n" "$cpu" "$mem" "$load" "$rs" "$ts"
else
    printf " %2d%% | %2d%% | %s \n" "$cpu" "$mem" "$load"
fi
