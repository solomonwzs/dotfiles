#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-06-25
# @version  1.0
# @license  MIT
set -euo pipefail

if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
    EXECUTE_FILENAME=$(greadlink -f "$0")
else
    EXECUTE_FILENAME=$(readlink -f "$0")
fi
EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

function message() {
    echo -e "\033[01;32m[INFO]\033[01;37m $1\033[0m"
}

function make_link() {
    target="$1"
    link_name="$2"
    message "Create '$link_name'"
    ([ -e "$link_name" ] && message "'$link_name' has exists") || \
        ln -s "$target" "$link_name"
}

function copy_file() {
    message "Create '$2'"
    ([ -e "$2" ] && message "'$2' has exists") || \
        cp "$1" "$2"
}

function git_clone() {
    addr="$1"
    dir="$2"
    ([ -e "$dir" ] && message "'$dir' has exists" ) || \
        git clone "$addr" "$dir"
}

make_link "$EXECUTE_DIRNAME/vim" "$HOME/.vim"
make_link "$EXECUTE_DIRNAME/vim" "$HOME/.config/nvim"
make_link "$EXECUTE_DIRNAME/vim/vimrc" "$HOME/.config/nvim/init.vim"

make_link "$EXECUTE_DIRNAME/zsh/zshrc" "$HOME/.zshrc"
copy_file "$EXECUTE_DIRNAME/zsh/my_conf.sh" "$HOME/.my_conf.sh"

message "Create terminfo"
[ -e "$HOME/.terminfo/t/tmux-256color" ] || \
    tic -x "$EXECUTE_DIRNAME/tmux/tmux-256color.terminfo"
[ -e "$HOME/.terminfo/x/xterm-256color-italic" ] || \
    tic -x "$EXECUTE_DIRNAME/tmux/xterm-256color-italic.terminfo"

message "Create '$HOME/.tmux.conf'"
cp "$EXECUTE_DIRNAME/tmux/tmux.conf" "$HOME/.tmux.conf"

OH_MY_ZSH_PATH="$HOME/.oh-my-zsh"
message "Download 'oh-my-zsh'"
git_clone "https://github.com/ohmyzsh/ohmyzsh.git" "$OH_MY_ZSH_PATH"
message "Download 'zsh-autosuggestions'"
git_clone "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$OH_MY_ZSH_PATH/custom/plugins/zsh-autosuggestions"
message "Download 'zsh-syntax-highlighting'"
git_clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$OH_MY_ZSH_PATH/custom/plugins/zsh-syntax-highlighting"
