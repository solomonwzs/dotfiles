#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-08-06
# @version  1.0
# @license  MIT

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
EXECUTE_FILENAME=$(greadlink -f "$0")
EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")
source "$EXECUTE_DIRNAME/utils.sh"

cpu_cores=$(sysctl hw.activecpu | cut -d' ' -f2)

netdev=""
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

cpu_mem=($(ps -A -o %cpu,%mem | awk '{c+=$1; m+=$2} END {print c, m}'))
cpu="${cpu_mem[0]}"
mem="${cpu_mem[1]}"
load=$(uptime | awk '{print $(NF-2), $(NF-1), $(NF)}')

rt=($(netstat -ib -I "$netdev" | awk 'NR == 2 {print $7, $10}'))
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
cpu_htg="$(histogram "$cpu" "/tmp/.tmux_cpu_htg_$sess_idx")"
mem_htg="$(histogram "$mem" "/tmp/.tmux_mem_htg_$sess_idx")"

temp="Nan"
if type "osx-cpu-temp" >/dev/null; then
    temp=$(osx-cpu-temp)
fi

# printf " %s %s | %2d%% | %2d%% | %s [%d] | %s \n" \
#     "$rs" "$ts" "$cpu" "$mem" "$load" "$cpu_cores" "$temp"
printf " %s %s |%s %2d%% |%s %2d%% | %s \n" \
    "$rs" "$ts" "$cpu_htg" "$cpu" "$mem_htg" "$mem" "$temp"
