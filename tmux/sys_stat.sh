#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-07-03
# @version  1.0
# @license  MIT

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
    EXECUTE_FILENAME=$(greadlink -f "$0")
else
    EXECUTE_FILENAME=$(readlink -f "$0")
fi
EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")
source "$EXECUTE_DIRNAME/utils.sh"

sess_idx=""
while getopts "i:s:" opt; do
    case "$opt" in
    s)
        sess_idx=${OPTARG}
        ;;
    *) ;;

    esac
done

printf "|"
for i in "${MY_TMUX_COMPONENTS[@]}"; do
    if [ "$i" = "download" ]; then
        component_download_speed
    elif [ "$i" = "upload" ]; then
        component_upload_speed
    elif [ "$i" = "cpu" ]; then
        component_cpu "$sess_idx"
    elif [ "$i" = "mem" ]; then
        component_mem "$sess_idx"
    elif [ "$i" = "temp" ]; then
        component_temp
    fi
done
