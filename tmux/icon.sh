#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2021-08-06
# @version  1.0
# @license  MIT

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
# EXECUTE_FILENAME=$(readlink -f "$0")
# EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

INFO=$(uname -a 2>/dev/null || echo -n "linux")

ICON=""
if [[ "$INFO" =~ arch ]]; then
    ICON=""
elif [[ "$INFO" =~ ubuntu ]]; then
    ICON=""
elif [[ "$INFO" =~ centos ]]; then
    ICON=""
elif [[ "$INFO" =~ Darwin ]]; then
    ICON=""
elif [[ "$INFO" =~ Debian ]]; then
    ICON=""
elif [[ "$INFO" =~ fedora ]]; then
    ICON=""
elif [[ "$INFO" =~ freebsd ]]; then
    ICON=""
elif [[ "$INFO" =~ gentoo ]]; then
    ICON=""
elif [[ "$INFO" =~ suse ]]; then
    ICON=""
elif [[ "$INFO" =~ redhat ]]; then
    ICON=""
fi
echo $ICON
