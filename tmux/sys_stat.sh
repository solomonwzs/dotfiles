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

cpu=$(vmstat -n 1 2 | tail -n 1 | awk '{printf("%2d%%", 100 - $15)}')

if [ -n "$netdev_ok" ]; then
    r1=$(cat "/sys/class/net/${netdev}/statistics/rx_bytes")
    t1=$(cat "/sys/class/net/${netdev}/statistics/tx_bytes")

    rbps=$((r1 - r0))
    tbps=$((t1 - t0))

    ri=0
    while [ ${#rbps} -gt 3 ]; do
        rbps=$((rbps / 1024))
        ri=$((ri + 1))
    done
    ru=${size_unit[$ri]}

    ti=0
    while [ ${#tbps} -gt 3 ]; do
        tbps=$((tbps / 1024))
        ti=$((ti + 1))
    done
    tu=${size_unit[$ti]}
fi

mem=$(free | awk '$1 == "Mem:" {printf("%2d%%", ($2 - $7) / $2 * 100)}')
load=$(uptime | awk -F'[, ]' '{print $(NF - 4), $(NF-2), $(NF)}')

if [ -n "$netdev_ok" ]; then
    echo "$cpu | $mem | $load | ${rbps}${ru}/s ${tbps}${tu}/s"
else
    echo "$cpu | $mem | $load"
fi
