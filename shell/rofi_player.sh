#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2026-05-09
# @version  2.0
# @license  GPL-2.0+
#
# rofi-driven media-player toggle on top of playerctl.
#
#   - 0 players : no-op (brief rofi popup).
#   - 1 player  : `playerctl play-pause` immediately, no menu.
#   - 2+ players: rofi list with an icon per source (firefox / chromium
#     / mpv / vlc / ...); selecting a row issues play-pause on that
#     specific player.
#
# The player id from `playerctl -l` looks like `firefox.instance_1_599`
# or `chromium.instance856690` — we split on '.' to pick the MPRIS
# namespace and use that as an icon name (falls back to
# multimedia-player if the theme does not ship one).
#
# Bind from a window manager / panel keybinding, e.g. xfce:
#   <Mod4>m  -> /home/solomon/dotfiles/shell/rofi_player.sh
#
# Requires: playerctl, rofi.

set -euo pipefail

ROFI_PROMPT=" "
FALLBACK_ICON="multimedia-player"

function need() {
    if ! _loc="$(type -p "$1")" || [[ -z "$_loc" ]]; then
        echo "missing dependency: $1" >&2
        exit 1
    fi
}

need playerctl
need rofi

# Map an MPRIS player id to a likely icon name. "firefox.instance_1_599"
# -> "firefox"; "org.mpris.MediaPlayer2.spotify" style ids are already
# collapsed by playerctl -l so we just take the prefix before the first
# dot. Caller is expected to fall back to FALLBACK_ICON if the result
# is not found by the icon theme.
function icon_for() {
    local id="$1"
    printf '%s\n' "${id%%.*}"
}

# Build the rofi menu rows. Each row is written straight to rofi's
# stdin using the dmenu icon syntax:
#
#     <visible label>\0icon\x1f<icon-name>\n
#
# Note the \0 is a real NUL byte — bash strings cannot hold NUL, so we
# must write each row with printf directly (not build it into a shell
# variable and then echo it, or the NUL gets silently dropped and rofi
# renders the literal "icon<US>firefox" text we saw in v2.0).
function run_menu() {
    local -a players=("$@")
    local id label status artist title glyph icon

    for id in "${players[@]}"; do
        status="$(playerctl --player="$id" status 2>/dev/null || echo "?")"
        artist="$(playerctl --player="$id" metadata artist 2>/dev/null || true)"
        title="$(playerctl --player="$id" metadata title 2>/dev/null || true)"

        # Nerd Font / Font Awesome glyphs for playback state.
        # Requires a Nerd Font (e.g. Mononoki Nerd Font) in the rofi
        # theme font fallback chain.
        case "$status" in
            Playing) glyph=$'\uf04b' ;;  #   media-play
            Paused)  glyph=$'\uf04c' ;;  #   media-pause
            Stopped) glyph=$'\uf04d' ;;  #   media-stop
            *)       glyph=$'\uf141' ;;  #   ellipsis / unknown
        esac

        # Compose visible label: glyph + artist/title (omit empty
        # halves so we don't show stray dashes).
        if [[ -n "$artist" && -n "$title" ]]; then
            label=" ${glyph} ${artist} — ${title}"
        elif [[ -n "$title" ]]; then
            label=" ${glyph} ${title}"
        elif [[ -n "$artist" ]]; then
            label=" ${glyph} ${artist}"
        else
            label=" ${glyph} ${id%%.*}"
        fi

        icon="$(icon_for "$id")"
        # %b in printf would process \0 as a C-escape; instead we use
        # printf format literals that emit raw bytes via \x escapes.
        printf '%s\0icon\x1f%s\n' "$label" "$icon"
    done
}

function show_menu() {
    run_menu "$@" \
        | rofi -dmenu \
               -i \
               -p "$ROFI_PROMPT" \
               -no-custom \
               -show-icons \
               -format i \
               -application-fallback-icon "$FALLBACK_ICON"
}

function main() {
    local players_raw
    if ! players_raw="$(playerctl -l 2>/dev/null)" || [[ -z "$players_raw" ]]; then
        rofi -e "no MPRIS players are running" >/dev/null
        exit 0
    fi

    # Split into an array, dropping blanks.
    local -a players=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && players+=("$line")
    done <<<"$players_raw"

    if [[ "${#players[@]}" -eq 1 ]]; then
        playerctl --player="${players[0]}" play-pause
        exit 0
    fi

    local idx
    idx="$(show_menu "${players[@]}")" || exit 0
    [[ -z "$idx" ]] && exit 0

    # Guard: idx should be a non-negative integer within range.
    if ! [[ "$idx" =~ ^[0-9]+$ ]] || (( idx >= ${#players[@]} )); then
        exit 0
    fi

    playerctl --player="${players[$idx]}" play-pause
}

main "$@"
