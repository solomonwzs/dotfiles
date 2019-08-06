#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-08-06
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

cpu_mem=($(ps -A -o %cpu,%mem | awk '{c+=$1; m+=$2} END {print c, m}'))
cpu="${cpu_mem[0]}"
mem="${cpu_mem[1]}"
load=$(uptime | awk '{print $(NF-2), $(NF-1), $(NF)}')

rt=($(netstat -ib -I en0 | awk 'NR == 2 {print $7, $10}'))
r0="${rt[0]}"
t0="${rt[1]}"

sleep 1

rt=($(netstat -ib -I "$netdev" | awk 'NR == 2 {print $7, $10}'))
r1="${rt[0]}"
t1="${rt[1]}"

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
    
echo "$cpu% | $mem% | $load | ${rbps}${ru}/s ${tbps}${tu}/s"
