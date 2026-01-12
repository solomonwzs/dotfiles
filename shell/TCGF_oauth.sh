#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2025-12-16
# @version  1.0
# @license  GPL-2.0+

set -euo pipefail

ENDPOINT="U2FsdGVkX18uZdMcCAWk7P1OK45VDd3QZ9qjXpM4AlUexlNR6yatW60I+Pv9MkkH"
CLIENT_ID="U2FsdGVkX1/SpNIDTHzRVVH1P+d5vOr1JcoVSYoguV0KRTxnuC6eA4Z8uB6RVcS83W/Sf9qV7OJs7NzXNhqIkQ=="

read -rsp "enter the password to continue: " PASSWORD

ENDPOINT=$(openssl enc -aes-256-cbc -d -salt -pbkdf2 -base64 -pass pass:"$PASSWORD" <<<"$ENDPOINT")
CLIENT_ID=$(openssl enc -aes-256-cbc -d -salt -pbkdf2 -base64 -pass pass:"$PASSWORD" <<<"$CLIENT_ID")

echo ""

RESP=$(curl "$ENDPOINT/api/v2/auth/device/code" \
    -sS \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=$CLIENT_ID")
USER_CODE=$(jq -r ".user_code" <<<"$RESP")
DEVICE_CODE=$(jq -r ".device_code" <<<"$RESP")

echo "visit $ENDPOINT/oauth/device and enter the code: $USER_CODE"
read -rp "after entered code in browser, Enter to continue..." _

curl "$ENDPOINT/api/v2/auth/device/token" \
    -sS \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "device_code=$DEVICE_CODE&client_id=$CLIENT_ID&grant_type=urn:ietf:params:oauth:grant-type:device_code"
