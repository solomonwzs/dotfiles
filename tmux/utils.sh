#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-07-11
# @version  1.0
# @license  MIT

[ -f "$HOME/.my_conf.sh" ] && source "$HOME/.my_conf.sh"

is_darwin=""
if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
    is_darwin=1
fi

size_unit=("" "KB" "MB" "GB" "TB")
function flow_digital() {
    local bps=$1
    local i=0
    while [ "$bps" -gt 1024 ]; do
        bps=$((bps / 1024))
        i=$((i + 1))
    done
    u=${size_unit[$i]}
    echo "${bps}${u}/s"
}

percent_block_list=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
function percent_block() {
    if [ "$1" == 100 ]; then
        echo "${percent_block_list[7]}"
    else
        i=$(bc <<<"$1/12.5")
        echo "${percent_block_list[$i]}"
    fi
}

function histogram() {
    local fn="$2"
    local str=""

    [ -f "$fn" ] && str=$(cat "$fn")
    str="$str$(percent_block "$1")"
    len=${#str}
    if [ ${#str} -gt 8 ]; then
        str="${str:$((len - 8)):8}"
    fi
    while [ ${#str} -lt 8 ]; do
        str="${percent_block_list[0]}${str}"
    done
    echo "$str" >"$fn"
    echo "$str"
}

cpu=""
mem=""
rs=""
ts=""
temp=""
netdev_list=()
netdev_id_list=()
rs_list=()
ts_list=()

function add_netdev() {
    netdev_list["$1"]="$2"
}

function get_cpu_cores() {
    if [ -z "$is_darwin" ]; then
        echo "$(nproc)"
    else
        echo "$(sysctl hw.activecpu | cut -d' ' -f2)"
    fi
}

function get_temp_stat() {
    if type "osx-cpu-temp" >/dev/null; then
        temp=$(osx-cpu-temp)
    else
        temp="Nan"
    fi
}

function get_cpu_and_net_stat() {
    local r0_list=()
    local t0_list=()

    for i in "${!netdev_list[@]}"; do
        local dev="${netdev_list[$i]}"
        local r0
        r0=$(cat "/sys/class/net/${dev}/statistics/rx_bytes")
        local t0
        t0=$(cat "/sys/class/net/${dev}/statistics/tx_bytes")
        r0_list["$i"]=$r0
        t0_list["$i"]=$t0
    done

    cpu=$(vmstat -n "${MY_TMUX_STATUS_INTERVAL:-1}" 2 | tail -n 1 | awk '{print 100 - $15}')

    for i in "${!netdev_list[@]}"; do
        local dev="${netdev_list[$i]}"
        local r1
        r1=$(cat "/sys/class/net/${dev}/statistics/rx_bytes")
        local t1
        t1=$(cat "/sys/class/net/${dev}/statistics/tx_bytes")

        local r0="${r0_list[$i]}"
        local t0="${t0_list[$i]}"

        local rbps=$((r1 - r0))
        local tbps=$((t1 - t0))

        rs_list["$i"]=$(flow_digital $rbps)
        ts_list["$i"]=$(flow_digital $tbps)
    done
}

function get_net_stat() {
    local r0_list=()
    local t0_list=()

    for i in "${!netdev_list[@]}"; do
        local dev="${netdev_list[$i]}"
        local rt=($(netstat -ib -I "$dev" | awk 'NR == 2 {print $7, $10}'))
        local r0="${rt[0]}"
        local t0="${rt[1]}"
        r0_list["$i"]=$r0
        t0_list["$i"]=$t0
    done

    sleep "${MY_TMUX_STATUS_INTERVAL:-1}"

    for i in "${!netdev_list[@]}"; do
        local dev="${netdev_list[$i]}"
        local rt=($(netstat -ib -I "$dev" | awk 'NR == 2 {print $7, $10}'))
        local r1="${rt[0]}"
        local t1="${rt[1]}"

        local r0="${r0_list[$i]}"
        local t0="${t0_list[$i]}"

        local rbps=$((r1 - r0))
        local tbps=$((t1 - t0))

        rs_list["$i"]=$(flow_digital $rbps)
        ts_list["$i"]=$(flow_digital $tbps)
    done
}

function get_mem_stat() {
    mem=$(free | awk '$1 == "Mem:" {printf("%d", ($2 - $7) / $2 * 100)}')
}

function get_cpu_and_mem_stat() {
    local cpu_mem=($(ps -A -o %cpu,%mem | awk '{c+=$1; m+=$2} END {print c, m}'))
    local cpu_cores=$(sysctl hw.activecpu | cut -d' ' -f2)

    cpu="${cpu_mem[0]}"
    mem="${cpu_mem[1]}"

    cpu=${cpu%.*}
    mem=${mem%.*}
    cpu=$((cpu / cpu_cores))
}

function component_cpu() {
    local sess_idx="$1"
    local cpu_htg
    if [ -z "$cpu" ]; then
        if [ -z "$is_darwin" ]; then
            get_cpu_and_net_stat
        else
            get_cpu_and_mem_stat
        fi
    fi
    cpu_htg="$(histogram "$cpu" "/tmp/.tmux_cpu_htg_$sess_idx")"
    printf "%s%3d%%|" "$cpu_htg" "$cpu"
}

function component_mem() {
    local sess_idx="$1"
    local mem_htg
    if [ -z "$mem" ]; then
        if [ -z "$is_darwin" ]; then
            get_mem_stat
        else
            get_cpu_and_mem_stat
        fi
    fi
    mem_htg="$(histogram "$mem" "/tmp/.tmux_mem_htg_$sess_idx")"
    printf "%s%3d%%|" "$mem_htg" "$mem"
}

function component_net() {
    if [ "${#rs_list[@]}" -eq 0 ]; then
        if [ -z "$is_darwin" ]; then
            get_cpu_and_net_stat
        else
            get_net_stat
        fi
    fi
    printf "%8s %8s|" "${rs_list[$1]}" "${ts_list[$1]}"
}

function component_temp() {
    if [ -z "$temp" ]; then
        get_temp_stat
    fi
    printf "%s|" "$temp"
}
