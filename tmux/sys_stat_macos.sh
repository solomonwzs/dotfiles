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

cpu_cores=$(sysctl hw.activecpu | cut -d' ' -f2)

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

rs=$(flow_digital $rbps)
ts=$(flow_digital $tbps)

cpu=${cpu%.*}
mem=${mem%.*}
cpu=$((cpu / cpu_cores))

printf " %s %s | %2d%% | %2d%% | %s [%d] \n" "$rs" "$ts" "$cpu" "$mem" "$load" "$cpu_cores"
