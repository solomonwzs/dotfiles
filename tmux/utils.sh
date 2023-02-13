#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-07-11
# @version  1.0
# @license  MIT

[ -f "$HOME/.my_conf.sh" ] && source "$HOME/.my_conf.sh"

g_Interval=1

g_StatusLine=""

g_PercentBlockList=(" " "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

g_BatteryPowerList=("" "" "" "" "" "" "" "" "" "" "")

# g_IsDarwin=""
# if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
#     g_IsDarwin=1
# fi

g_IsLinux=0
if [ -f "/proc/sys/kernel/ostype" ]; then
    read -r _ostype <"/proc/sys/kernel/ostype"
    if [[ "$_ostype" == "Linux" ]]; then
        g_IsLinux=1
    fi
fi

g_NetdevList=()
g_CpuStatStr="0000000000000000"
g_MemStatStr="0000000000000000"

g_NetRxList=()
g_NetTxList=()
g_CpuStat=()

# g_DotList=(
#     " " "⢀" "⣀" "⠠" "⢠" "⣠" "⠤" "⢤" "⣤"
#     "⠐" "⢐" "⣐" "⠰" "⢰" "⣰" "⠴" "⢴" "⣴"
#     "⠒" "⢒" "⣒" "⠲" "⢲" "⣲" "⠶" "⢶" "⣶"
#     "⠈" "⢈" "⣈" "⠨" "⢨" "⣨" "⠬" "⢬" "⣬"
#     "⠘" "⢘" "⣘" "⠸" "⢸" "⣸" "⠼" "⢼" "⣼"
#     "⠚" "⢚" "⣚" "⠺" "⢺" "⣺" "⠾" "⢾" "⣾"
#     "⠉" "⢉" "⣉" "⠩" "⢩" "⣩" "⠭" "⢭" "⣭"
#     "⠙" "⢙" "⣙" "⠹" "⢹" "⣹" "⠽" "⢽" "⣽"
#     "⠛" "⢛" "⣛" "⠻" "⢻" "⣻" "⠿" "⢿" "⣿"
# )

declare -A g_Cache

declare -A g_DotMap=(
    ["00"]=" " ["01"]="⢀" ["02"]="⢠" ["03"]="⢰" ["04"]="⢸"
    ["10"]="⡀" ["11"]="⣀" ["12"]="⣠" ["13"]="⣰" ["14"]="⣸"
    ["20"]="⡄" ["21"]="⣄" ["22"]="⣤" ["23"]="⣴" ["24"]="⣼"
    ["30"]="⡆" ["31"]="⣆" ["32"]="⣦" ["33"]="⣶" ["34"]="⣾"
    ["40"]="⡇" ["41"]="⣇" ["42"]="⣧" ["43"]="⣷" ["44"]="⣿"
)

function set_interval {
    g_Interval="$1"
}

function set_cache() {
    g_Cache["$1"]="$2"
}

function get_cache() {
    if [ -z "${g_Cache[$1]:+x}" ]; then
        echo ""
    else
        echo "${g_Cache[$1]}"
    fi
}

function init_net_dev_list() {
    g_NetdevList=()
    for i in "${!MY_TMUX_COMPONENTS[@]}"; do
        dev="${MY_TMUX_COMPONENTS[$i]}"
        if [ "${dev::4}" = "net:" ]; then
            g_NetdevList["$i"]="${dev:4}"
        fi
    done
}

function init_status_line() {
    g_NetRxList=()
    g_NetTxList=()
    g_CpuStat=()

    g_StatusLine=""
}

function show_status_line() {
    printf "%s" "$g_StatusLine"
}

function append_status_line() {
    g_StatusLine="${g_StatusLine}${1}"
}

function init_cpu_stat() {
    if [ ${#g_CpuStat[@]} -ne 0 ]; then
        return
    fi
    if [ "$g_IsLinux" -eq 1 ]; then
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
                g_CpuStat+=("$((\
                    a = stats[i - 1] - array[i - 1], \
                    b = stats[i] - array[i], \
                    100 - a * 100 / b))")
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
        # cpu_cores=$(sysctl hw.activecpu | cut -d' ' -f2)
        cpu_cores=$(sysctl hw.activecpu)
        cpu_cores=${cpu_cores#* }
        g_CpuStat+=($((cpu / cpu_cores)))
    fi
}

function init_net_stat() {
    if [ ${#g_NetRxList[@]} -ne 0 ]; then
        return
    fi
    # local now
    # now=$(date +%s%3N)
    for i in "${!g_NetdevList[@]}"; do
        local dev="${g_NetdevList[$i]}"

        local rx_bytes
        local tx_bytes
        read -r rx_bytes tx_bytes <<<"$(get_net_stat "$dev")"

        local key="net_$dev"
        local array
        read -r -a array <<<"$(get_cache "$key")"
        if [[ ${#array[@]} -eq 0 || "$g_Interval" -eq 0 ]]; then
            g_NetRxList["$i"]=0
            g_NetTxList["$i"]=0
        else
            g_NetRxList["$i"]="$((a = rx_bytes - array[0], \
                a / g_Interval))"
            g_NetTxList["$i"]="$((a = tx_bytes - array[1], \
                a / g_Interval))"
        fi
        set_cache "$key" "$rx_bytes $tx_bytes"
    done
}

function get_battery_icon() {
    read -r charging <"/sys/class/power_supply/BAT0/status"
    if [ "$charging" = "Charging" ]; then
        echo ""
    else
        i=$(($1 / 10))
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
    i=$(($1 * 10 / 125))
    echo "${g_PercentBlockList[$i]}"
}

function histogram() {
    local key="$2"
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
}

function get_cpu_cores() {
    if [ "$g_IsLinux" -eq 1 ]; then
        init_cpu_stat
        echo $(("${#g_CpuStat[@]}" - 1))
    else
        # sysctl hw.activecpu | cut -d' ' -f2
        local cores
        cores=$(sysctl hw.activecpu)
        echo "${cores#* }"
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
    if [ "$g_IsLinux" -eq 1 ]; then
        read -r rx_bytes <"/sys/class/net/${1}/statistics/rx_bytes"
        read -r tx_bytes <"/sys/class/net/${1}/statistics/tx_bytes"
        echo "$rx_bytes $tx_bytes"
    else
        local rx_bytes
        local tx_bytes
        read -r rx_bytes tx_bytes <<<"$(netstat -ib -I "$1" | awk 'NR == 2 {print $7, $10}')"
        echo "$rx_bytes $tx_bytes"
    fi
}

function get_mem_stat() {
    if [ "$g_IsLinux" -eq 1 ]; then
        awk '$1=="MemTotal:"{a=$2} $1=="MemAvailable:"{b=$2} END{print int((1-b/a)*100)}' \
            /proc/meminfo
    else
        ps -A -o %mem | awk '{m+=$1} END {print int(m)}'
    fi
}

function dot_histogram() {
    local str=""
    for i in $(seq 0 2 $((${#1} - 1))); do
        str="${str}${g_DotMap[${1:$i:2}]}"
    done
    set_cache "$2" "$str"
}

function component_cpu_dot_histogram() {
    local cpu
    local cpu_htg

    init_cpu_stat
    cpu="${g_CpuStat[0]}"
    g_CpuStatStr="${g_CpuStatStr:1:15}$((cpu / 25))"

    dot_histogram "$g_CpuStatStr" "dot_htg_cpu"
    cpu_htg="$(get_cache "dot_htg_cpu")"

    append_status_line "$(printf "%s%3d%%" "$cpu_htg" "$cpu")"
}

function component_mem_dot_histogram() {
    local mem
    local mem_htg

    mem="$(get_mem_stat)"
    g_MemStatStr="${g_MemStatStr:1:15}$((mem / 25))"

    dot_histogram "$g_MemStatStr" "dot_htg_mem"
    mem_htg="$(get_cache "dot_htg_mem")"

    append_status_line "$(printf "%s%3d%%" "$mem_htg" "$mem")"
}

function component_cpu_histogram() {
    local cpu
    local cpu_htg

    init_cpu_stat
    cpu="${g_CpuStat[0]}"
    histogram "$cpu" "htg_cpu"
    cpu_htg="$(get_cache "htg_cpu")"

    append_status_line "$(printf "%s%3d%%" "$cpu_htg" "$cpu")"
}

function component_cpu() {
    init_cpu_stat
    append_status_line "$(printf "%s%3d%%" \
        "$(percent_block "${g_CpuStat[0]}")" "${g_CpuStat[0]}")"
}

function component_mem_histogram() {
    local mem_htg
    local mem

    mem="$(get_mem_stat)"
    histogram "$mem" "htg_mem"
    mem_htg="$(get_cache "htg_mem")"

    append_status_line "$(printf "%s%3d%%" "$mem_htg" "$mem")"
}

function component_mem() {
    local mem
    mem="$(get_mem_stat)"
    append_status_line "$(printf "%s%3d%%" \
        "$(percent_block "$mem")" "$mem")"
}

function component_net() {
    init_net_stat
    append_status_line "$(printf "%8s %8s" \
        "$(flow_digital "${g_NetRxList[$1]}")" "$(flow_digital "${g_NetTxList[$1]}")")"
}

function component_temp() {
    local temp
    temp=$(get_temp_stat)
    append_status_line "$(printf "%s" "$temp")"
}

function component_power() {
    read -r full <"/sys/class/power_supply/BAT0/energy_full"
    read -r now <"/sys/class/power_supply/BAT0/energy_now"
    percent=$((now * 100 / full))
    icon=$(get_battery_icon $percent)

    append_status_line "$(printf " %s %d%%" "$icon" "$percent")"
}

function component_cpus() {
    init_cpu_stat
    for i in $(seq 1 $((${#g_CpuStat[@]} - 1))); do
        append_status_line "$(printf "%s" \
            "$(percent_block "${g_CpuStat[$i]}")")"
    done
    append_status_line "$(printf "%3d%%" "${g_CpuStat[0]}")"
}
