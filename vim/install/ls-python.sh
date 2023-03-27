#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-06-08
# @version  1.0
# @license  GPL-2.0+

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
# EXECUTE_FILENAME=$(readlink -f "$0")
# EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

pip install python-language-server --user
