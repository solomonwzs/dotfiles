#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-06-25
# @version  1.0
# @license  GPL-2.0+

set -euo pipefail

if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
    EXECUTE_FILENAME=$(greadlink -f "$0")
else
    EXECUTE_FILENAME=$(readlink -f "$0")
fi
EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

function info() {
    echo -e "\033[01;32m[INFO]\033[01;37m $1\033[0m"
}

function warn() {
    echo -e "\033[01;31m[WARN]\033[01;37m $1\033[0m"
}

function check_pkg() {
    if _loc="$(type -p "$1")" && [[ -n $_loc ]]; then
        return
    else
        warn "Missing $1"
    fi
}

pkg_list=(
    "bat"
    "fd"
    "fzf"
    "git"
    "lua"
    "node"
    "nvim"
    "rg"
    "tig"
    "tmux"
    "vim"
    "yarn"
)
for p in "${pkg_list[@]}"; do
    check_pkg "$p"
done

function make_link() {
    target="$1"
    link_name="$2"
    ([ -e "$link_name" ] && warn "'$link_name' has exists") || (
        info "Create '$link_name'" && ln -s "$target" "$link_name"
    )
}

function make_dir() {
    target="$1"
    ([ -e "$target" ] && warn "'$target' has exists") || (
        info "Create '$target'" && mkdir -p "$target"
    )
}

function copy_file() {
    ([ -e "$2" ] && warn "'$2' has exists") || (info "Create '$2'" &&
        cp "$1" "$2")
}

function git_clone() {
    addr="$1"
    dir="$2"
    ([ -e "$dir" ] && warn "'$dir' has exists") || (info "Download '$1'" &&
        git clone "$addr" "$dir")
}

deps=("fzf" "tmux" "rg")
for i in "${deps[@]}"; do
    (! hash "$i" && warn "Not install '$i'") || true
done

make_link "$EXECUTE_DIRNAME/vim" "$HOME/.vim"
make_link "$EXECUTE_DIRNAME/vim" "$HOME/.config/nvim"
make_link "$EXECUTE_DIRNAME/vim/vimrc" "$HOME/.config/nvim/init.vim"

make_link "$EXECUTE_DIRNAME/zsh/zshrc" "$HOME/.zshrc"
copy_file "$EXECUTE_DIRNAME/zsh/my_conf.sh" "$HOME/.my_conf.sh"
make_link "$EXECUTE_DIRNAME/zsh/toolbox.txt" "$HOME/.toolbox.txt"

# info "Create terminfo"
# [ -e "$HOME/.terminfo/t/tmux-256color" ] ||
#     tic -x "$EXECUTE_DIRNAME/tmux/tmux-256color.terminfo"
# [ -e "$HOME/.terminfo/x/xterm-256color-italic" ] ||
#     tic -x "$EXECUTE_DIRNAME/tmux/xterm-256color-italic.terminfo"

make_link "$EXECUTE_DIRNAME/tmux/tmux.conf" "$HOME/.tmux.conf"
make_link "$EXECUTE_DIRNAME/tig/tigrc" "$HOME/.tigrc"

make_dir "$HOME/bin"

make_link "$EXECUTE_DIRNAME/zsh/fzf_preview_file.sh" "$HOME/bin/preview_file"
make_link "$EXECUTE_DIRNAME/zsh/gmail_oauth2_token.sh" "$HOME/bin/gmail_oauth2_token"
make_link "$EXECUTE_DIRNAME/python/image_view.py" "$HOME/bin/image_view"

OH_MY_ZSH_PATH="$HOME/.oh-my-zsh"
git_clone "https://github.com/ohmyzsh/ohmyzsh.git" "$OH_MY_ZSH_PATH"
git_clone "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$OH_MY_ZSH_PATH/custom/plugins/zsh-autosuggestions"
git_clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$OH_MY_ZSH_PATH/custom/plugins/zsh-syntax-highlighting"

if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
    cd "$EXECUTE_DIRNAME/osx"
    info "Build osx tools"
    make
fi
