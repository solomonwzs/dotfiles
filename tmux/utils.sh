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

netdev="$MY_TMUX_STATUS_NETDEV"

size_unit=("" "KB" "MB" "GB" "TB")
function flow_digital() {
    local bps=$1
    local i=0
    while [ "$bps" -gt 1024 ]; do
        bps=$((bps / 1024))
        i=$((i + 1))
    done
    u=${size_unit[$i]}
    echo -n "${bps}${u}/s"
}

percent_block_list=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
function percent_block() {
    if [ "$1" == 100 ]; then
        echo -n "${percent_block_list[7]}"
    else
        i=$(bc <<<"$1/12.5")
        echo -n "${percent_block_list[$i]}"
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
    echo -n "$str" >"$fn"
    echo -n "$str"
}

cpu=""
mem=""
rs=""
ts=""
temp=""

function get_cpu_cores() {
    if [ -z "$is_darwin" ]; then
        echo -n "$(nproc)"
    else
        echo -n "$(sysctl hw.activecpu | cut -d' ' -f2)"
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
    else
        rs="0/s"
        ts="0/s"
    fi
}

function get_net_stat() {
    local rt=($(netstat -ib -I "$netdev" | awk 'NR == 2 {print $7, $10}'))
    local r0="${rt[0]}"
    local t0="${rt[1]}"

    sleep 1

    rt=($(netstat -ib -I "$netdev" | awk 'NR == 2 {print $7, $10}'))
    local r1="${rt[0]}"
    local t1="${rt[1]}"

    local rbps=$((r1 - r0))
    local tbps=$((t1 - t0))

    rs=$(flow_digital $rbps)
    ts=$(flow_digital $tbps)
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
    if [ -z "$is_darwin" ]; then
        if [ -z "$cpu" ]; then
            get_cpu_and_net_stat
        fi
    else
        if [ -z "$cpu" ]; then
            get_cpu_and_mem_stat
        fi
    fi
    cpu_htg="$(histogram "$cpu" "/tmp/.tmux_cpu_htg_$sess_idx")"
    printf "%s%3d%%│" "$cpu_htg" "$cpu"
}

function component_mem() {
    local sess_idx="$1"
    local mem_htg
    if [ -z "$is_darwin" ]; then
        if [ -z "$mem" ]; then
            get_mem_stat
        fi
    else
        if [ -z "$mem" ]; then
            get_cpu_and_mem_stat
        fi
    fi
    mem_htg="$(histogram "$mem" "/tmp/.tmux_mem_htg_$sess_idx")"
    printf "%s%3d%%│" "$mem_htg" "$mem"
}

function component_download_speed() {
    if [ -z "$is_darwin" ]; then
        if [ -z "$rs" ]; then
            get_cpu_and_net_stat
        fi
    else
        if [ -z "$ts" ]; then
            get_net_stat
        fi
    fi
    printf "%8s│" "$rs"
}

function component_upload_speed() {
    if [ -z "$is_darwin" ]; then
        if [ -z "$ts" ]; then
            get_cpu_and_net_stat
        fi
    else
        if [ -z "$ts" ]; then
            get_net_stat
        fi
    fi
    printf "%8s│" "$ts"
}

function component_temp() {
    if [ -z "$temp" ]; then
        get_temp_stat
    fi
    printf "%s│" "$temp"
}
