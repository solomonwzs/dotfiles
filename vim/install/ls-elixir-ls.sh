#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-06-08
# @version  1.0
# @license  GPL-2.0+

set -euo pipefail

EXECUTE_FILENAME=$(readlink -f "$0")
EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

src_dir="${EXECUTE_DIRNAME}/../language_servers/elixir-ls"
release_dir="${src_dir}/release"

[ -d "$src_dir" ] || git clone "https://github.com/JakeBecker/elixir-ls.git" "$src_dir"
[ -d "$release_dir" ] || mkdir "$release_dir"
cd "$src_dir"

mix deps.get
mix compile
mix elixir_ls.release -o "$release_dir"
