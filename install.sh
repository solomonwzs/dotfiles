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

[ -e "$HOME/.vim" ] || ln -s "$EXECUTE_DIRNAME/vim" "$HOME/.vim"
[ -e "$HOME/.zshrc" ] || ln -s "$EXECUTE_DIRNAME/zsh/zshrc" "$HOME/.zshrc"

[ -e "$HOME/.terminfo/t/tmux-256color" ] || tic -x "$EXECUTE_DIRNAME/tmux/tmux-256color.terminfo"
[ -e "$HOME/.terminfo/x/xterm-256color-italic" ] || tic -x "$EXECUTE_DIRNAME/tmux/xterm-256color-italic.terminfo"
[ -e "$HOME/.tmux.conf" ] || ln -s "$EXECUTE_DIRNAME/tmux/tmux.conf" "$HOME/.tmux.conf"
