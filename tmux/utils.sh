#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-07-11
# @version  1.0
# @license  MIT

[ -f "$HOME/.my_conf.sh" ] && source "$HOME/.my_conf.sh"

g_sess_index="x"

is_darwin=""
if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
    is_darwin=1
fi

function set_cache() {
    local key="$1"
    local fn="/tmp/.tmux_${g_sess_index}_${key}"
    printf "%s" "$2" >"$fn"
}

function get_cache() {
    local key="$1"
    local fn="/tmp/.tmux_${g_sess_index}_${key}"
    if [ -f "$fn" ]; then
        cat "$fn"
    fi
}

battery_power_list=("" "" "" "" "" "" "" "" "" "" "")
function get_battery_icon() {
    charging=$(cat "/sys/class/power_supply/BAT0/status")
    if [ "$charging" = "Charging" ]; then
        echo ""
    else
        i=$(bc <<<"$1/10")
        echo "${battery_power_list[$i]}"
    fi
}

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

percent_block_list=(" " "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
function percent_block() {
    i=$(bc <<<"$1/12.5")
    echo "${percent_block_list[$i]}"
}

function histogram() {
    local key="htg_$2"
    IFS=$'\t' read -r str <<<"$(get_cache "$key")"
    str="$str$(percent_block "$1")"
    len=${#str}
    if [ "${len}" -gt 8 ]; then
        str="${str:$((len - 8)):8}"
    fi
    while [ ${#str} -lt 8 ]; do
        str="${percent_block_list[0]}${str}"
    done
    set_cache "$key" "$str"
    echo "$str"
}

function get_cpu_cores() {
    if [ -z "$is_darwin" ]; then
        nproc
    else
        sysctl hw.activecpu | cut -d' ' -f2
    fi
}

function get_cpu_stat() {
    read -r idle all <<<"$(awk 'NR==1{print $5, $2+$3+$4+$5+$6+$7+$8}' /proc/stat)"
    IFS=" " read -r -a array <<<"$(get_cache "cpu")"
    if [ ${#array[@]} == 0 ]; then
        echo 0
    else
        echo $((100 - (idle - array[0]) * 100 / (all - array[1])))
    fi
    set_cache "cpu" "$idle $all"
}

function darwin_get_cpu_stat() {
    local cpu=($(ps -A -o %cpu | awk '{c+=$1; m+=$2} END {print c, m}'))
    local cpu_cores=$(sysctl hw.activecpu | cut -d' ' -f2)
    cpu=${cpu%.*}
    echo $((cpu / cpu_cores))
}

function get_temp_stat() {
    if type "osx-cpu-temp" >/dev/null; then
        osx-cpu-temp
    else
        echo "Nan"
    fi
}

function get_net_stat() {
    local dev="$1"
    local rx_bytes
    local tx_bytes
    rx_bytes=$(cat "/sys/class/net/${dev}/statistics/rx_bytes")
    tx_bytes=$(cat "/sys/class/net/${dev}/statistics/tx_bytes")
    echo "$rx_bytes $tx_bytes"
}

function darwin_get_net_stat() {
    dev="$1"
    rt=($(netstat -ib -I "$dev" | awk 'NR == 2 {print $7, $10}'))
    rx_bytes="${rt[0]}"
    tx_bytes="${rt[1]}"
    echo "$rx_bytes $tx_bytes"
}

function get_mem_stat() {
    free | awk '$1 == "Mem:" {printf("%d", ($2 - $7) / $2 * 100)}'
}

function component_cpu_histogram() {
    local cpu_htg
    local cpu
    if [ -z "$is_darwin" ]; then
        cpu=$(get_cpu_stat)
    else
        cpu=$(darwin_get_cpu_stat)
    fi
    cpu_htg="$(histogram "$cpu" "cpu")"
    printf "%s%3d%%" "$cpu_htg" "$cpu"
}

function component_cpu() {
    local cpu
    if [ -z "$is_darwin" ]; then
        cpu=$(get_cpu_stat)
    else
        cpu=$(darwin_get_cpu_stat)
    fi
    printf "%s%3d%%" "$(percent_block "$cpu")" "$cpu"
}

function component_mem_histogram() {
    local mem_htg
    local mem
    mem="$(get_mem_stat)"
    mem_htg="$(histogram "$mem" "mem")"
    printf "%s%3d%%" "$mem_htg" "$mem"
}

function component_mem() {
    local mem
    mem="$(get_mem_stat)"
    printf "%s%3d%%" "$(percent_block "$mem")" "$mem"
}

function component_net() {
    local dev="$1"
    local key="net_$dev"
    local now
    now=$(date +%s)
    if [ -z "$is_darwin" ]; then
        read -r rx_bytes tx_bytes <<<"$(get_net_stat "$1")"
    else
        read -r rx_bytes tx_bytes <<<"$(darwin_get_net_stat "$1")"
    fi
    IFS=" " read -r -a array <<<"$(get_cache "$key")"
    if [ ${#array[@]} == 0 ]; then
        printf "%8s %8s" 0 0
    else
        rbps=$(((rx_bytes - array[1]) / (now - array[0])))
        tbps=$(((tx_bytes - array[2]) / (now - array[0])))
        printf "%8s %8s" "$(flow_digital "$rbps")" "$(flow_digital "$tbps")"
    fi
    set_cache "$key" "$now $rx_bytes $tx_bytes"
}

function component_temp() {
    temp=$(get_temp_stat)
    printf "%s" "$temp"
}

function component_power() {
    full=$(cat "/sys/class/power_supply/BAT0/energy_full")
    now=$(cat "/sys/class/power_supply/BAT0/energy_now")
    percent=$((now * 100 / full))
    icon=$(get_battery_icon $percent)
    printf " %s %d%%" "$icon" "$percent"
}

function component_cpus() {
    local stats=()
    local cache=""
    while read -r idle all; do
        stats+=("$idle")
        stats+=("$all")
        cache="$cache $idle $all"
    done <<<"$(awk '$1~/cpu/{print $5, $2+$3+$4+$5+$6+$7+$8}' /proc/stat)"
    read -r -a array <<<"$(get_cache "cpus")"
    set_cache "cpus" "$cache"
    if [ ${#array[@]} == ${#stats[@]} ]; then
        for i in $(seq 3 2 ${#stats[@]}); do
            printf "%s" "$(percent_block $((100 - (stats[i - 1] - array[i - 1]) * 100 / (stats[i] - array[i]))))"
        done
        printf "%3d%%" "$((100 - (stats[0] - array[0]) * 100 / (stats[1] - array[1])))"
    else
        printf "Nan"
    fi
}
