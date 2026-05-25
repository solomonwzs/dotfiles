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

# --- logging ---------------------------------------------------------
# Use the dotfiles repo path as a tilde substitute so log lines stay
# narrow even when paths get long.
function _short() {
    local p="$1"
    p="${p/#$HOME/\~}"
    p="${p/#$EXECUTE_DIRNAME/.}"
    printf '%s' "$p"
}

function section() {
    # Bold cyan banner with a leading blank line, used for major
    # phases: Common / XFCE / UI / etc.
    printf '\n\033[1;36m== %s ==\033[0m\n' "$1"
}

function group() {
    # Lightweight subsection (per-tool blocks). Shorter than `section`
    # so the script doesn't drown in banners when iterating over a
    # dozen single-link tools.
    printf '\033[1;34m──\033[0m \033[1m%s\033[0m\n' "$1"
}

function info() {
    # Green check mark for successful actions (created, linked, ...).
    printf '  \033[1;32m✔\033[0m %s\n' "$1"
}

function skip() {
    # Dim grey dot for idempotent no-ops (already linked / exists).
    printf '  \033[2m·\033[0m \033[2m%s\033[0m\n' "$1"
}

function warn() {
    # Yellow exclamation for things the user should notice but that
    # don't stop the script — kept on stderr so a `2>/dev/null` filter
    # can hide them.
    printf '  \033[1;33m!\033[0m %s\n' "$1" >&2
}

function err() {
    # Red cross + exit. Reserved for unrecoverable misconfiguration.
    printf '  \033[1;31m✘\033[0m %s\n' "$1" >&2
    exit 1
}

function check_pkg() {
    if _loc="$(type -p "$1")" && [[ -n $_loc ]]; then
        return 0
    fi
    warn "missing binary: $1"
    return 1
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
section "Dependencies"
missing=0
for p in "${pkg_list[@]}"; do
    if ! check_pkg "$p"; then
        missing=$((missing + 1))
    fi
done
if [ "$missing" -eq 0 ]; then
    info "all $(printf '%d' "${#pkg_list[@]}") binaries present"
fi

function make_link() {
    local target="$1"
    local link_name="$2"

    if [ ! -e "$target" ]; then
        err "missing source: $(_short "$target")"
    fi

    # Already a symlink that points to the right place — nothing to do.
    if [ -L "$link_name" ] && [ "$(readlink -f "$link_name")" = "$(readlink -f "$target")" ]; then
        skip "$(_short "$link_name") → $(_short "$target")"
        return
    fi

    # Some other file/dir/link exists at the destination; replace it.
    if [ -e "$link_name" ] || [ -L "$link_name" ]; then
        warn "replace $(_short "$link_name")"
        rm -rf "$link_name"
    fi

    ln -s "$target" "$link_name"
    info "link $(_short "$link_name") → $(_short "$target")"
}

function make_dir() {
    local target="$1"
    if [ -d "$target" ]; then
        skip "dir $(_short "$target")"
        return
    fi
    mkdir -p "$target"
    info "mkdir $(_short "$target")"
}

function copy_file() {
    local src="$1"
    local dst="$2"
    if [ -e "$dst" ]; then
        skip "keep $(_short "$dst")"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    info "copy $(_short "$src") → $(_short "$dst")"
}

function git_clone() {
    local addr="$1"
    local dir="$2"
    if [ -e "$dir" ]; then
        skip "git $(_short "$dir")"
        return
    fi
    info "clone $addr → $(_short "$dir")"
    git clone --quiet "$addr" "$dir"
}

function git_clone_or_pull() {
    local addr="$1"
    local dir="$2"
    if [ -d "$dir/.git" ]; then
        info "pull $(_short "$dir")"
        git -C "$dir" pull --ff-only --quiet
    else
        info "clone $addr → $(_short "$dir")"
        git clone --quiet "$addr" "$dir"
    fi
}

# deps=("fzf" "tmux" "rg")
# for i in "${deps[@]}"; do
#     (! hash "$i" && warn "Not install '$i'") || true
# done

section "Common"
make_dir "$HOME/bin"
make_dir "$HOME/.config"
make_dir "$HOME/.local/share"
copy_file "$EXECUTE_DIRNAME/shell/my_conf.sh" "$HOME/.my_conf.sh"
make_link "$EXECUTE_DIRNAME/shell/toolbox.txt" "$HOME/.toolbox.txt"
make_link "$EXECUTE_DIRNAME/shell/xinitrc" "$HOME/.xinitrc"
make_link "$EXECUTE_DIRNAME/shell/gtkrc-2.0" "$HOME/.gtkrc-2.0"
make_link "$EXECUTE_DIRNAME/shell/preview_file.sh" "$HOME/bin/preview_file"
make_link "$EXECUTE_DIRNAME/shell/gmail_oauth2_token.sh" "$HOME/bin/gmail_oauth2_token"
make_link "$EXECUTE_DIRNAME/python/image_view.py" "$HOME/bin/image_view"
make_link "$EXECUTE_DIRNAME/config/fontconfig" "$HOME/.config/fontconfig"
make_link "$EXECUTE_DIRNAME/config/themes" "$HOME/.themes"
make_link "$EXECUTE_DIRNAME/config/gtk-3.0" "$HOME/.config/gtk-3.0"

section "Niri"
make_link "$EXECUTE_DIRNAME/config/niri" "$HOME/.config/niri"
make_link "$EXECUTE_DIRNAME/config/waybar" "$HOME/.config/waybar"

section "XFCE"
copy_file "$EXECUTE_DIRNAME/config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml" \
    "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml"
copy_file "$EXECUTE_DIRNAME/config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml" \
    "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"

section "UI"
make_dir "$HOME/.local/share/icons"
make_dir "$HOME/.local/share/themes"

# Fetch / refresh gruvbox-plus-icon-pack into ~/.local/share/icons,
# then symlink the two themes one level up so GTK finds them at
# the canonical Gruvbox-Plus-{Dark,Light} names.
GRUVBOX_PLUS_DIR="$HOME/.local/share/icons/gruvbox-plus-icon-pack"
git_clone_or_pull \
    "https://github.com/SylEleuth/gruvbox-plus-icon-pack.git" \
    "$GRUVBOX_PLUS_DIR"
make_link "$GRUVBOX_PLUS_DIR/Gruvbox-Plus-Dark" \
    "${HOME}/.local/share/icons/Gruvbox-Plus-Dark"
make_link "$GRUVBOX_PLUS_DIR/Gruvbox-Plus-Light" \
    "${HOME}/.local/share/icons/Gruvbox-Plus-Light"

# Patch inherit chain: upstream Dark inherits from breeze-dark, Light from
# breeze; neither is shipped here, so symbolic icons (system-search,
# edit-find, tab-new, ...) fall back to "image-missing". Adwaita ships
# with gtk3 itself and has a complete symbolic set.
sed -i 's/^Inherits=breeze-dark,hicolor$/Inherits=Adwaita,hicolor/' \
    "$GRUVBOX_PLUS_DIR/Gruvbox-Plus-Dark/index.theme"
sed -i 's/^Inherits=Gruvbox-Plus-Dark,breeze,hicolor$/Inherits=Gruvbox-Plus-Dark,Adwaita,hicolor/' \
    "$GRUVBOX_PLUS_DIR/Gruvbox-Plus-Light/index.theme"

if hash gtk-update-icon-cache 2>/dev/null; then
    info "refresh gruvbox-plus-icon-pack icon cache"
    gtk-update-icon-cache -f -t "$GRUVBOX_PLUS_DIR/Gruvbox-Plus-Dark" >/dev/null 2>&1 || true
    gtk-update-icon-cache -f -t "$GRUVBOX_PLUS_DIR/Gruvbox-Plus-Light" >/dev/null 2>&1 || true
fi

make_link "$EXECUTE_DIRNAME/ui/gruvbox-material-gtk-dark-hidpi" \
    "${HOME}/.local/share/themes/gruvbox-material-gtk-dark-hidpi"

section "Apps"

if hash i3 2>/dev/null; then
    group "i3"
    make_dir "$HOME/.config/i3"
    make_link "$EXECUTE_DIRNAME/config/i3/config" "$HOME/.config/i3/config"
else
    skip "i3 (binary not found)"
fi

if hash openbox 2>/dev/null; then
    group "openbox"
    make_link "$EXECUTE_DIRNAME/config/openbox" "$HOME/.config/openbox"
else
    skip "openbox (binary not found)"
fi

if hash labwc 2>/dev/null; then
    group "labwc"
    make_link "$EXECUTE_DIRNAME/config/labwc" "$HOME/.config/labwc"
else
    skip "labwc (binary not found)"
fi

if hash rofi 2>/dev/null; then
    group "rofi"
    make_link "$EXECUTE_DIRNAME/config/rofi" "$HOME/.config/rofi"
else
    skip "rofi (binary not found)"
fi

if hash xsettingsd 2>/dev/null; then
    group "xsettingsd"
    make_dir "$HOME/.config/xsettingsd"
    make_link "$EXECUTE_DIRNAME/config/xsettingsd/xsettingsd.conf" \
        "$HOME/.config/xsettingsd/xsettingsd.conf"
else
    skip "xsettingsd (binary not found)"
fi

if hash tint2 2>/dev/null; then
    group "tint2"
    make_dir "$HOME/.config/tint2"
    make_link "$EXECUTE_DIRNAME/config/tint2/tint2rc" "$HOME/.config/tint2/tint2rc"
else
    skip "tint2 (binary not found)"
fi

if hash picom 2>/dev/null; then
    group "picom"
    make_dir "$HOME/.config/picom"
    make_link "$EXECUTE_DIRNAME/config/picom/picom.conf" "$HOME/.config/picom/picom.conf"
else
    skip "picom (binary not found)"
fi

if (hash vim 2>/dev/null || hash nvim 2>/dev/null); then
    group "vim/neovim"
    make_link "$EXECUTE_DIRNAME/vim" "$HOME/.vim"
    make_link "$EXECUTE_DIRNAME/vim" "$HOME/.config/nvim"
    make_link "$EXECUTE_DIRNAME/vim/vimrc" "$HOME/.config/nvim/init.vim"
else
    skip "vim/neovim (binary not found)"
fi

# info "Create terminfo"
# [ -e "$HOME/.terminfo/t/tmux-256color" ] ||
#     tic -x "$EXECUTE_DIRNAME/tmux/tmux-256color.terminfo"
# [ -e "$HOME/.terminfo/x/xterm-256color-italic" ] ||
#     tic -x "$EXECUTE_DIRNAME/tmux/xterm-256color-italic.terminfo"

if (hash zsh 2>/dev/null); then
    group "zsh"
    make_link "$EXECUTE_DIRNAME/config/zsh/zshrc" "$HOME/.zshrc"

    OH_MY_ZSH_PATH="$HOME/.oh-my-zsh"
    git_clone "https://github.com/ohmyzsh/ohmyzsh.git" "$OH_MY_ZSH_PATH"
    git_clone "https://github.com/zsh-users/zsh-autosuggestions.git" \
        "$OH_MY_ZSH_PATH/custom/plugins/zsh-autosuggestions"
    git_clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
        "$OH_MY_ZSH_PATH/custom/plugins/zsh-syntax-highlighting"
else
    skip "zsh (binary not found)"
fi

if (hash tmux 2>/dev/null); then
    group "tmux"
    make_link "$EXECUTE_DIRNAME/tmux/tmux.conf" "$HOME/.tmux.conf"
else
    skip "tmux (binary not found)"
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
    group "osx tools"
    cd "$EXECUTE_DIRNAME/osx"
    info "build"
    make
else
    skip "osx tools (not macOS)"
fi

if (hash tig 2>/dev/null); then
    group "tig"
    make_link "$EXECUTE_DIRNAME/config/tig/tigrc" "$HOME/.tigrc"
else
    skip "tig (binary not found)"
fi

if (hash btop 2>/dev/null); then
    group "btop"
    make_dir "$EXECUTE_DIRNAME/config/btop"
    copy_file "$EXECUTE_DIRNAME/config/btop/btop.conf" \
        "$HOME/.config/btop/btop.conf"
else
    skip "btop (binary not found)"
fi

if (hash kitty 2>/dev/null); then
    group "kitty"
    make_link "$EXECUTE_DIRNAME/config/kitty" "$HOME/.config/kitty"
else
    skip "kitty (binary not found)"
fi

if (hash alacritty 2>/dev/null); then
    group "alacritty"
    make_link "$EXECUTE_DIRNAME/config/alacritty" "$HOME/.config/alacritty"
else
    skip "alacritty (binary not found)"
fi

if (hash bat 2>/dev/null); then
    group "bat"
    make_link "$EXECUTE_DIRNAME/config/bat" "$HOME/.config/bat"
else
    skip "bat (binary not found)"
fi

if (hash fcitx5 2>/dev/null); then
    group "fcitx5"
    make_dir "$HOME/.local/share/fcitx5"
    make_link "$EXECUTE_DIRNAME/config/fcitx5/themes" \
        "$HOME/.local/share/fcitx5/themes"
else
    skip "bat (binary not found)"
fi
