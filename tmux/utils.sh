#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-07-11
# @version  1.0
# @license  MIT

[ -f "$HOME/.my_conf.sh" ] && source "$HOME/.my_conf.sh"

g_SessionIndex="x"

g_PercentBlockList=(" " "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

g_BatteryPowerList=("" "" "" "" "" "" "" "" "" "" "")

g_IsDarwin=""
if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
    g_IsDarwin=1
fi

g_NetdevList=()
for i in "${!MY_TMUX_COMPONENTS[@]}"; do
    dev="${MY_TMUX_COMPONENTS[$i]}"
    if [ "${dev::4}" = "net:" ]; then
        g_NetdevList["$i"]="${dev:4}"
    fi
done

g_NetRxList=()
g_NetTxList=()
g_CpuStat=()

function init_cpu_stat() {
    if [ ${#g_CpuStat[@]} -ne 0 ]; then
        return
    fi
    if [ -z "$g_IsDarwin" ]; then
        local stats=()
        local cache=""
        while read -r idle all; do
            stats+=("$idle")
            stats+=("$all")
            cache="$cache $idle $all"
        done <<<"$(awk '$1~/cpu/{print $5, $2+$3+$4+$5+$6+$7+$8}' /proc/stat)"

        local array
        read -r -a array <<<"$(get_cache "cpus")"
        set_cache "cpus" "$cache"

        if [ ${#array[@]} -eq ${#stats[@]} ]; then
            for i in $(seq 1 2 ${#stats[@]}); do
                g_CpuStat+=("$((100 - (stats[i - 1] - array[i - 1]) * 100 / (stats[i] - array[i])))")
            done
        else
            for i in $(seq 1 2 ${#stats[@]}); do
                g_CpuStat+=(0)
            done
        fi
    else
        local cpu
        local cpu_cores
        cpu="$(ps -A -o %cpu | awk '{c+=$1} END {print c}')"
        cpu=${cpu%.*}
        cpu_cores=$(sysctl hw.activecpu | cut -d' ' -f2)
        g_CpuStat+=($((cpu / cpu_cores)))
    fi
}

function init_net_stat() {
    if [ ${#g_NetRxList[@]} -ne 0 ]; then
        return
    fi
    local now
    now=$(date +%s)
    for i in "${!g_NetdevList[@]}"; do
        local dev="${g_NetdevList[$i]}"

        local rx_bytes
        local tx_bytes
        read -r rx_bytes tx_bytes <<<"$(get_net_stat "$dev")"

        local key="net_$dev"
        local array
        read -r -a array <<<"$(get_cache "$key")"
        if [[ ${#array[@]} -eq 0 || "$now" -eq ${array[0]} ]]; then
            g_NetRxList["$i"]=0
            g_NetTxList["$i"]=0
        else
            g_NetRxList["$i"]=$(((rx_bytes - array[1]) / (now - array[0])))
            g_NetTxList["$i"]=$(((tx_bytes - array[2]) / (now - array[0])))
        fi
        set_cache "$key" "$now $rx_bytes $tx_bytes"
    done
}

function set_session_index() {
    g_SessionIndex="$1"
}

function set_cache() {
    local key="$1"
    local fn="/tmp/.tmux_${g_SessionIndex}_${key}"
    printf "%s" "$2" >"$fn"
}

function get_cache() {
    local key="$1"
    local fn="/tmp/.tmux_${g_SessionIndex}_${key}"
    if [ -f "$fn" ]; then
        cat "$fn"
    fi
}

function get_battery_icon() {
    charging=$(cat "/sys/class/power_supply/BAT0/status")
    if [ "$charging" = "Charging" ]; then
        echo ""
    else
        i=$(bc <<<"$1/10")
        echo "${g_BatteryPowerList[$i]}"
    fi
}

g_SizeUnit=("" "KB" "MB" "GB" "TB")
function flow_digital() {
    local bps=$1
    local i=0
    while [ "$bps" -gt 1024 ]; do
        bps=$((bps / 1024))
        i=$((i + 1))
    done
    u=${g_SizeUnit[$i]}
    echo "${bps}${u}/s"
}

function percent_block() {
    i=$(bc <<<"$1/12.5")
    echo "${g_PercentBlockList[$i]}"
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
        str="${g_PercentBlockList[0]}${str}"
    done
    set_cache "$key" "$str"
    echo "$str"
}

function get_cpu_cores() {
    if [ -z "$g_IsDarwin" ]; then
        nproc
    else
        sysctl hw.activecpu | cut -d' ' -f2
    fi
}

function get_temp_stat() {
    if type "osx-cpu-temp" >/dev/null; then
        osx-cpu-temp
    else
        echo "Nan"
    fi
}

function get_net_stat() {
    if [ -z "$g_IsDarwin" ]; then
        local dev="$1"
        local rx_bytes
        local tx_bytes
        rx_bytes=$(cat "/sys/class/net/${dev}/statistics/rx_bytes")
        tx_bytes=$(cat "/sys/class/net/${dev}/statistics/tx_bytes")
        echo "$rx_bytes $tx_bytes"
    else
        local rx_bytes
        local tx_bytes
        read -r rx_bytes tx_bytes <<<"$(netstat -ib -I "$1" | awk 'NR == 2 {print $7, $10}')"
        echo "$rx_bytes $tx_bytes"
    fi
}

function get_mem_stat() {
    if [ -z "$g_IsDarwin" ]; then
        free | awk '$1 == "Mem:" {printf("%d", ($2 - $7) / $2 * 100)}'
    else
        ps -A -o %mem | awk '{m+=$1} END {print int(m)}'
    fi
}

function component_cpu_histogram() {
    init_cpu_stat
    local cpu
    local cpu_htg
    cpu="${g_CpuStat[0]}"
    cpu_htg="$(histogram "$cpu" "cpu")"
    printf "%s%3d%%" "$cpu_htg" "$cpu"
}

function component_cpu() {
    init_cpu_stat
    printf "%s%3d%%" "$(percent_block "${g_CpuStat[0]}")" "${g_CpuStat[0]}"
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
    init_net_stat
    printf "%8s %8s" "$(flow_digital ${g_NetRxList[$1]})" "$(flow_digital ${g_NetTxList[$1]})"
}

function component_temp() {
    local temp
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
    init_cpu_stat
    for i in $(seq 1 $((${#g_CpuStat[@]} - 1))); do
        printf "%s" "$(percent_block "${g_CpuStat[$i]}")"
    done
    printf "%3d%%" "${g_CpuStat[0]}"
}
