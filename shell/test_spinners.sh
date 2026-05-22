#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2026-05-22
# @version  3.0
# @license  GPL-2.0+
#
# Side-by-side preview of CLI spinner alphabets, including the
# "star" / "asterisks" sets (the ones used by npm cli-spinners).
#
# Each spinner is rendered on its own row, advancing in place. Use this
# to:
#   1. Identify which spinner alphabet a given CLI uses (e.g. codebuddy).
#   2. Visually inspect whether each frame stays vertically centred /
#      on-baseline as it advances — useful when tuning kitty's
#      `modify_font baseline N` or `symbol_map`.
#
# Usage:
#     test_spinners.sh           # 80ms per frame, looped
#     test_spinners.sh 200       # slower (200ms / frame)
#     test_spinners.sh 30        # fast (30ms)
#     Ctrl-C to quit.

set -euo pipefail

DELAY_MS="${1:-80}"

# Each entry: "label|frame1 frame2 frame3 ..."  (frames separated by
# single spaces). Frames here are all single characters so this is safe.
SPINNERS=(
    "star         |✶ ✸ ✹ ✺ ✹ ✷"
    "asterisks    |✱ ✲ ✳ ✴ ✵ ✶ ✷ ✸ ✹ ✺ ✻ ✼ ✽"
    "rot-asterisk |✱ ✻ ✽ ✼ ✺ ✸"
    "sparkles     |✢ ✣ ✤ ✥ ✦ ✧ ✨ ✩"
    "dots (8-dot) |⠇ ⠋ ⠙ ⠹ ⠸ ⠼ ⠬ ⠦"
    "dots5 gear   |⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷"
    "arc          |◜ ◝ ◞ ◟"
    "circleQrt    |◰ ◳ ◱ ◲"
    "circleHalf   |◐ ◑ ◒ ◓"
    "line         |- \\ | /"
    "growVertical |▁ ▃ ▄ ▅ ▆ ▇ ▆ ▅ ▄ ▃"
)

function cleanup() {
    printf '\e[?25h\n'
}
trap cleanup EXIT INT TERM

printf '\e[?25l'  # hide cursor

cat <<'EOF'

  Spinner alphabet preview — find your animation by name.
  Ctrl-C to quit.

EOF

# Reserve one row per spinner.
for _ in "${SPINNERS[@]}"; do printf '\n'; done

n=${#SPINNERS[@]}

# Convert delay → sleep arg.
if [[ "$DELAY_MS" -le 0 ]]; then
    SLEEP_CMD=()
else
    SLEEP_CMD=(sleep "$(awk -v ms="$DELAY_MS" 'BEGIN { print ms/1000 }')")
fi

declare -a IDX
for ((i = 0; i < n; i++)); do IDX[i]=0; done

while :; do
    # Move cursor up `n` rows to the start of the spinner block.
    printf '\e[%dA' "$n"
    for ((i = 0; i < n; i++)); do
        entry="${SPINNERS[$i]}"
        label="${entry%%|*}"
        rest="${entry#*|}"
        IFS=' ' read -r -a frames <<<"$rest"

        idx=${IDX[i]}
        frame="${frames[$idx]}"
        printf '\r\e[2K  %-14s %s\n' "$label" "$frame"
        IDX[i]=$(( (idx + 1) % ${#frames[@]} ))
    done

    if [[ "${#SLEEP_CMD[@]}" -gt 0 ]]; then
        "${SLEEP_CMD[@]}"
    fi
done
