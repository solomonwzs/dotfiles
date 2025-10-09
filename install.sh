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
    "npm"
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

    if [ -e "$target" ]; then
        (
            [[ -f "$link_name" || -L "$link_name" ]] &&
                warn "overwrite old conf, '$link_name'" &&
                rm "$link_name" &&
                ln -s "$target" "$link_name"
        ) || (
            [ -d "$link_name" ] &&
                warn "overwrite old conf dir, '$link_name'" &&
                rm -r "$link_name" &&
                ln -s "$target" "$link_name"
        ) || (
            info "Create '$link_name'" &&
                ln -s "$target" "$link_name"
        )
    else
        warn "no '$target'"
        exit 1
    fi

    # ([ -e "$link_name" ] && warn "'$link_name' has exists") || (
    #     info "Create '$link_name'" && ln -s "$target" "$link_name"
    # )
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

# deps=("fzf" "tmux" "rg")
# for i in "${deps[@]}"; do
#     (! hash "$i" && warn "Not install '$i'") || true
# done

info "Common settings"
make_dir "$HOME/bin"
make_dir "$HOME/.config"
make_dir "$HOME/.local/share"
copy_file "$EXECUTE_DIRNAME/shell/my_conf.sh" "$HOME/.my_conf.sh"
make_link "$EXECUTE_DIRNAME/shell/toolbox.txt" "$HOME/.toolbox.txt"
make_link "$EXECUTE_DIRNAME/shell/preview_file.sh" "$HOME/bin/preview_file"
make_link "$EXECUTE_DIRNAME/shell/gmail_oauth2_token.sh" "$HOME/bin/gmail_oauth2_token"
make_link "$EXECUTE_DIRNAME/python/image_view.py" "$HOME/bin/image_view"
make_link "$EXECUTE_DIRNAME/config/fontconfig" "$HOME/.config/fontconfig"
make_link "$EXECUTE_DIRNAME/config/themes" "$HOME/.themes"

if (hash vim 2>/dev/null || hash nvim 2>/dev/null); then
    info "Config for vim/neovim"
    make_link "$EXECUTE_DIRNAME/vim" "$HOME/.vim"
    make_link "$EXECUTE_DIRNAME/vim" "$HOME/.config/nvim"
    make_link "$EXECUTE_DIRNAME/vim/vimrc" "$HOME/.config/nvim/init.vim"
else
    info "Skip config for vim/neovim"
fi

# info "Create terminfo"
# [ -e "$HOME/.terminfo/t/tmux-256color" ] ||
#     tic -x "$EXECUTE_DIRNAME/tmux/tmux-256color.terminfo"
# [ -e "$HOME/.terminfo/x/xterm-256color-italic" ] ||
#     tic -x "$EXECUTE_DIRNAME/tmux/xterm-256color-italic.terminfo"

if (hash zsh 2>/dev/null); then
    info "Config for zsh"
    make_link "$EXECUTE_DIRNAME/config/zsh/zshrc" "$HOME/.zshrc"

    OH_MY_ZSH_PATH="$HOME/.oh-my-zsh"
    git_clone "https://github.com/ohmyzsh/ohmyzsh.git" "$OH_MY_ZSH_PATH"
    git_clone "https://github.com/zsh-users/zsh-autosuggestions.git" \
        "$OH_MY_ZSH_PATH/custom/plugins/zsh-autosuggestions"
    git_clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
        "$OH_MY_ZSH_PATH/custom/plugins/zsh-syntax-highlighting"
else
    info "Skip config for zsh"
fi

if (hash tmux 2>/dev/null); then
    info "Config for tmux"
    make_link "$EXECUTE_DIRNAME/tmux/tmux.conf" "$HOME/.tmux.conf"
else
    info "Skip config for tmux"
fi

# coc_ext_dir="$EXECUTE_DIRNAME/vim/coc-extensions"
# tiktoken_dir="$coc_ext_dir/node_modules/tiktoken"
# if [ -e "$tiktoken_dir" ]; then
#     warn "'$tiktoken_dir' has exists"
# else
#     info "install tiktoken"
#     cd "$EXECUTE_DIRNAME/vim/coc-extensions"
#     npm install tiktoken
#     cd -
# fi

if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
    cd "$EXECUTE_DIRNAME/osx"
    info "Build osx tools"
    make
else
    info "Skip build osx tools"
fi

if (hash tig 2>/dev/null); then
    info "Config for tig"
    make_link "$EXECUTE_DIRNAME/config/tig/tigrc" "$HOME/.tigrc"
else
    info "Skip config for tig"
fi

if (hash btop 2>/dev/null); then
    info "Config for btop"
    make_dir "$EXECUTE_DIRNAME/config/btop"
    make_link "$EXECUTE_DIRNAME/config/btop/btop.conf" \
        "$HOME/.config/btop/btop.conf"
else
    info "Skip config for btop"
fi

if (hash kitty 2>/dev/null); then
    info "Config for kitty"
    make_link "$EXECUTE_DIRNAME/config/kitty" "$HOME/.config/kitty"
else
    info "Skip config for kitty"
fi

if (hash bat 2>/dev/null); then
    info "Config for bat"
    make_link "$EXECUTE_DIRNAME/config/bat" "$HOME/.config/bat"
else
    info "Skip config for bat"
fi

if (hash fcitx5 2>/dev/null); then
    info "Config for fcitx5"
    make_dir "$HOME/.local/share/fcitx5"
    make_link "$EXECUTE_DIRNAME/config/fcitx5/themes" \
        "$HOME/.local/share/fcitx5/themes"
else
    info "Skip config for bat"
fi
