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
width=120
height=120
ratio=0.9

while getopts "l:w:r:h:" opt; do
    case $opt in
    l)
        line="$OPTARG"
        ;;
    w)
        width="$OPTARG"
        ;;
    h)
        height="$OPTARG"
        ;;
    r)
        ratio="$OPTARG"
        ;;
    *) ;;
    esac
done

shift $((OPTIND - 1))
filename="$1"

mime=$(file --mime "$filename")
if [[ "$mime" =~ "text" ]]; then
    (bat --style=numbers --color=always "$filename" ||
        highlight -O ansi -l "$filename" ||
        coderay "$filename" ||
        rougify "$filename" ||
        cat "$filename") 2>/dev/null | head -"$line"
elif [[ "$mime" =~ "image" ]]; then
    height=$((height * 2 - 1))
    image_view --width "$width" --height "$height" --ratio "$ratio" "$filename"
else
    echo "$mime"
fi
