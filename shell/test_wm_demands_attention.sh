#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2026-05-14
# @version  1.0
# @license  GPL-2.0+

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
# EXECUTE_FILENAME=$(readlink -f "$0")
# EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

wid=$(xdotool getactivewindow)
while sleep 1; do
    wmctrl -i -r "$wid" -b add,demands_attention
    sleep 5
    wmctrl -i -r "$wid" -b remove,demands_attention
done
