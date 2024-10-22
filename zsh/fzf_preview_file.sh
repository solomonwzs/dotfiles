#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-10-12
# @version  1.0
# @license  GPL-2.0+

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
if [[ "$mime" =~ text || "$mime" =~ us-ascii || "$mime" =~ utf-8 ||
    "$mime" =~ iso-8859-1 ]]; then
    (bat --style=numbers --color=always --theme=gruvbox-dark "$filename" ||
        highlight -O ansi -l "$filename" ||
        coderay "$filename" ||
        rougify "$filename" ||
        cat "$filename") 2>/dev/null | head -"$line"
elif [[ "$mime" =~ image ]]; then
    height=$((height * 2 - 1))
    image_view --width "$width" --height "$height" --ratio "$ratio" "$filename"
elif [[ "$mime" =~ application/zip ]]; then
    unzip -l "$filename"
elif [[ "$mime" =~ application/x-rar ]]; then
    unrar l "$filename"
elif [[ "$mime" =~ application/gzip || "$mime" =~ application/x-xz ]]; then
    tar tvf "$filename"
elif [[ "$mime" =~ application/pdf ||
    "$mime" =~ application/vnd.openxmlformats-officedocument ||
    "$mime" =~ application/msword ||
    "$mime" =~ application/vnd.ms-excel ||
    "$mime" =~ application/vnd.ms-powerpoint ]] &&
    _loc="$(type -p "document2text")" &&
    [[ -n $_loc ]]; then
    document2text "$filename"
else
    echo "$mime"
fi
