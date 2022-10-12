#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-10-12
# @version  1.0
# @license  MIT

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
# EXECUTE_FILENAME=$(readlink -f "$0")
# EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

line=200

while getopts "l:w:r:" opt; do
    case $opt in
    l)
        line="$OPTARG"
        ;;
    w)
        width="$OPTARG"
        ;;
    r)
        ratio="$OPTARG"
        ;;
    *) ;;
    esac
done

echo $line
