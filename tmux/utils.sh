#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-07-11
# @version  1.0
# @license  GPL-2.0+

[ -f "$HOME/.my_conf.sh" ] && source "$HOME/.my_conf.sh"

g_Interval=1

g_StatusLine=""

g_PercentBlockList=(" " "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

g_BatteryPowerList=("󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")

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

g_Return=""

g_SizeUnit=("" "KB" "MB" "GB" "TB")

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

g_Stack=()

function push_stack() {
    for i in "$@"; do
        g_Stack+=("$i")
    done
}

function pop_stack() {
    for ((i = 0; i < $1; ++i)); do
        unset 'g_Stack[${#g_Stack[@]}-1]'
    done
}

function set_interval {
    g_Interval="$1"
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

    local stats=()
    local cache=""
    if [ "$g_IsLinux" -eq 1 ]; then
        while read -r -a a; do
            if [ "${a[0]:0:3}" != "cpu" ]; then
                break
            fi
            local idle="${a[4]}"
            local all="$((a[1] + a[2] + a[3] + a[4] + a[5] + a[6] + a[7]))"
            stats+=("$idle")
            stats+=("$all")
            cache="$cache $idle $all"
        done </proc/stat
    else
        while IFS=" " read -r -a a; do
            stats+=("${a[0]}")
            stats+=("${a[1]}")
            cache="$cache ${a[0]} ${a[1]}"
        done <<<"$(simple_cpu)"
    fi

    local key="cpus"
    local array
    read -r -a array <<<"${g_Cache[$key]:-}"
    g_Cache[$key]="$cache"

    if [ ${#array[@]} -eq ${#stats[@]} ]; then
        local len=${#stats[@]}
        for ((i = 1; i < len; i += 2)); do
            g_CpuStat+=(
                "$((100 - (stats[i - 1] - array[i - 1]) * 100 / (stats[i] - array[i])))"
            )
        done
    else
        for i in $(seq 1 2 ${#stats[@]}); do
            g_CpuStat+=(0)
        done
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

        get_net_stat "$dev"
        local rx_bytes
        local tx_bytes
        read -r rx_bytes tx_bytes <<<"$g_Return"

        local key="net_$dev"
        local array
        read -r -a array <<<"${g_Cache[$key]:-}"
        if [[ ${#array[@]} -eq 0 || "$g_Interval" -eq 0 ]]; then
            g_NetRxList["$i"]=0
            g_NetTxList["$i"]=0
        else
            g_NetRxList["$i"]="$((a = rx_bytes - array[0], \
                a / g_Interval))"
            g_NetTxList["$i"]="$((a = tx_bytes - array[1], \
                a / g_Interval))"
        fi
        g_Cache[$key]="$rx_bytes $tx_bytes"
    done
}

function get_battery_icon() {
    read -r charging <"/sys/class/power_supply/BAT0/status"
    if [ "$charging" = "Charging" ]; then
        g_Return="󰂄"
    else
        i=$(($1 / 10))
        g_Return="${g_BatteryPowerList[$i]}"
    fi
}

function flow_digital() {
    local bps=$1
    local i=0
    while [ "$bps" -gt 1024 ]; do
        bps=$((bps / 1024))
        i=$((i + 1))
    done
    u=${g_SizeUnit[$i]}
    g_Return="${bps}${u}/s"
}

function histogram() {
    local key="$2"
    local str="${g_Cache[$key]:-}"
    str="${str}${g_PercentBlockList[$(($1 * 10 / 125))]}"
    local len=${#str}
    if [ "${len}" -gt 8 ]; then
        str="${str:$((len - 8)):8}"
    fi
    while [ ${#str} -lt 8 ]; do
        str="${g_PercentBlockList[0]}${str}"
    done
    g_Cache[$key]="$str"
    g_Return="$str"
}

function get_cpu_cores() {
    if [ "$g_IsLinux" -eq 1 ]; then
        init_cpu_stat
        g_Return=$(("${#g_CpuStat[@]}" - 1))
    else
        local cores
        cores=$(sysctl hw.activecpu)
        g_Return="${cores#* }"
    fi
}

function get_temp_stat() {
    if type "osx-cpu-temp" >/dev/null; then
        osx-cpu-temp
    else
        echo "Nan"
    fi
}

function linux_get_net_stat() {
    read -r rx_bytes <"/sys/class/net/${1}/statistics/rx_bytes"
    read -r tx_bytes <"/sys/class/net/${1}/statistics/tx_bytes"
    g_Return="$rx_bytes $tx_bytes"
}

function darwin_get_net_stat() {
    local rx_bytes
    local tx_bytes
    local ifname
    read -r ifname rx_bytes tx_bytes <<<"$(simple_net "$1")"
    g_Return="$rx_bytes $tx_bytes"
}

function get_net_stat() {
    if [ "$g_IsLinux" -eq 1 ]; then
        linux_get_net_stat "$1"
    else
        darwin_get_net_stat "$1"
    fi
}

function get_mem_stat() {
    if [ "$g_IsLinux" -eq 1 ]; then
        local total=1
        local freemem=0
        local cached=0
        local buffers=0
        local sreclaimable=0
        local used=0
        while read -r -a a; do
            if [ "${a[0]}" == "MemTotal:" ]; then
                total=${a[1]}
            elif [ "${a[0]}" == "MemFree:" ]; then
                freemem=${a[1]}
            elif [ "${a[0]}" == "Cached:" ]; then
                cached=${a[1]}
            elif [ "${a[0]}" == "Buffers:" ]; then
                buffers=${a[1]}
            elif [ "${a[0]}" == "SReclaimable:" ]; then
                sreclaimable=${a[1]}
            fi
        done </proc/meminfo
        ((\
        cached = cached + sreclaimable, \
        used = total - freemem - buffers - cached))
        g_Return="$((used * 100 / total))"
    else
        read free cached used available total <<<"$(simple_mem)"
        g_Return="$((used * 100 / total))"
    fi
}

function dot_histogram() {
    local str=""
    for ((i = 0; i <= ${#1} - 1; i += 2)); do
        str="${str}${g_DotMap[${1:$i:2}]}"
    done
    g_Cache[$2]="$str"
    g_Return="$str"
}

function component_cpu_dot_histogram() {
    local cpu
    local cpu_htg

    init_cpu_stat
    cpu="${g_CpuStat[0]}"
    g_CpuStatStr="${g_CpuStatStr:1:15}$((cpu / 25))"

    dot_histogram "$g_CpuStatStr" "dot_htg_cpu"
    cpu_htg=$g_Return
    for (( ; ${#cpu} < 3; )); do cpu=" $cpu"; done

    append_status_line "${cpu_htg}${cpu}%"
}

function component_mem_dot_histogram() {
    get_mem_stat
    local mem=g_Return
    g_MemStatStr="${g_MemStatStr:1:15}$((mem / 25))"

    dot_histogram "$g_MemStatStr" "dot_htg_mem"
    local mem_htg=$g_Return
    for (( ; ${#mem} < 3; )); do mem=" $mem"; done

    append_status_line "${mem_htg}${mem}%"
}

function component_cpu_histogram() {
    local cpu
    local cpu_htg

    init_cpu_stat
    cpu="${g_CpuStat[0]}"
    histogram "$cpu" "htg_cpu"
    cpu_htg="$g_Return"

    for (( ; ${#cpu} < 3; )); do cpu=" $cpu"; done
    append_status_line "${cpu_htg}${cpu}%"
}

function component_cpu() {
    init_cpu_stat

    local cpu="${g_CpuStat[0]}"
    local bar="${g_PercentBlockList[$((cpu * 10 / 125))]}"

    for (( ; ${#cpu} < 3; )); do cpu=" $cpu"; done
    append_status_line "${bar}${cpu}%"
}

function component_mem_histogram() {
    get_mem_stat
    local mem=$g_Return
    histogram "$mem" "htg_mem"
    local mem_htg="$g_Return"

    for (( ; ${#mem} < 3; )); do mem=" $mem"; done
    append_status_line "${mem_htg}${mem}%"
}

function component_mem() {
    get_mem_stat
    local mem=$g_Return
    local bar="${g_PercentBlockList[$((mem * 10 / 125))]}"

    for (( ; ${#mem} < 3; )); do mem=" $mem"; done
    append_status_line "${bar}${mem}%"
}

function component_net() {
    init_net_stat

    flow_digital "${g_NetRxList[$1]}"
    rx=$g_Return

    flow_digital "${g_NetTxList[$1]}"
    tx=$g_Return

    for (( ; ${#rx} < 8; )); do rx=" $rx"; done
    for (( ; ${#tx} < 8; )); do tx=" $tx"; done

    append_status_line "${rx} ${tx}"
}

function component_temp() {
    local temp
    temp=$(get_temp_stat)
    append_status_line "$temp"
}

function component_power() {
    read -r full <"/sys/class/power_supply/BAT0/energy_full"
    read -r now <"/sys/class/power_supply/BAT0/energy_now"
    percent=$((now * 100 / full))
    get_battery_icon "$percent"
    icon=$g_Return

    append_status_line " ${icon} ${percent}%"
}

function component_cpus() {
    init_cpu_stat

    local str=""
    for ((i = 1; i <= ${#g_CpuStat[@]} - 1; ++i)); do
        str="${str}${g_PercentBlockList[$((g_CpuStat[i] * 10 / 125))]}"
    done

    local cpu="${g_CpuStat[0]}"
    for (( ; ${#cpu} < 3; )); do cpu=" $cpu"; done
    append_status_line "${str}${cpu}%"
}
