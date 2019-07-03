#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-06-25
# @version  1.0
# @license  MIT
set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
EXECUTE_FILENAME=$(readlink -f "$0")
EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

function make_link() {
    target="$1"
    link_name="$2"
    ([ -e "$link_name" ] && echo "$link_name has exists") || \
        ln -s "$target" "$link_name"
}

make_link "$EXECUTE_DIRNAME/vim" "$HOME/.vim"
make_link "$EXECUTE_DIRNAME/vim" "$HOME/.config/nvim"
make_link "$EXECUTE_DIRNAME/vim/vimrc" "$HOME/.config/nvim/init.vim"

make_link "$EXECUTE_DIRNAME/zsh/zshrc" "$HOME/.zshrc"

[ -e "$HOME/.terminfo/t/tmux-256color" ] || \
    tic -x "$EXECUTE_DIRNAME/tmux/tmux-256color.terminfo"
[ -e "$HOME/.terminfo/x/xterm-256color-italic" ] || \
    tic -x "$EXECUTE_DIRNAME/tmux/xterm-256color-italic.terminfo"
make_link "$EXECUTE_DIRNAME/tmux/tmux.conf" "$HOME/.tmux.conf"
