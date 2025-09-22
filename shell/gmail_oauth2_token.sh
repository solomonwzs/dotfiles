#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2023-03-24
# @version  1.0
# @license  GPL-2.0+

set -euo pipefail

source "$HOME/.my_conf.sh"

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
EXECUTE_FILENAME=$(readlink -f "$0")
EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

pyfile="$EXECUTE_DIRNAME/../python/gmail_oauth2_token.py"
python3 "$pyfile" \
    --client_id "$MY_GMAIL_CLIENT_ID" \
    --client_secret "$MY_GMAIL_CLIENT_SECRET" \
    --refresh_token "$MY_GMAIL_REFRESH_TOKEN"
