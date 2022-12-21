#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-05-29
# @version  1.0
# @license  MIT

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
# EXECUTE_FILENAME=$(readlink -f "$0")
# EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

function editdiff {
    DIFF="vimdiff"

    LEFT=$1
    RIGHT=$2

    options=("open" "exit")
    select opt in "${options[@]}"; do
        case $opt in
        "open")
            "$DIFF" "$LEFT" "$RIGHT"
            break
            ;;
        "exit")
            break
            ;;
        esac
    done
}

if [[ -n ${SVN_DIFF+x} ]] && [ "$SVN_DIFF" == "edit" ]; then
    editdiff "$6" "$7"
else
    diff --color=always "$@"
fi
