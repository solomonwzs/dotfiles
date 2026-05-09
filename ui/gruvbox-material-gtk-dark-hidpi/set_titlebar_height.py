#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2026-05-09
# @version  2.0
# @license  GPL-2.0+
#
# Adjust xfwm4 (server-side) titlebar height for the vendored
# gruvbox-material-gtk-dark-hidpi theme.
#
# xfwm4 sizes the titlebar from the height of the artwork in xfwm4/*.svg:
#
#   - Button SVGs (close/hide/maximize[-toggled]/menu/shade[-toggled]/
#     stick[-toggled] and their *-prelight/-pressed variants): drawn on
#     a 64x64 canvas with a 32x32 viewBox (HiDPI 2x). Changing the outer
#     width/height rescales the rendered pixel size while keeping the
#     internal path geometry untouched.
#
#   - Title strip SVGs (title-1..5-{active,inactive}, top-left-*,
#     top-right-*): shaped like `width=2 height=H viewBox="0 0 2 H"`
#     plus a background `<rect height="H">`. Their height MUST match
#     the button SVGs or xfwm4 will letterbox the row.
#
#   - Edge fillers (left/right/bottom/bottom-left/bottom-right, 2x2
#     platelets that xfwm4 tiles) are NOT touched.
#
# Upstream HiDPI default is 64 px. Typical useful values:
#   48 -> compact   56 -> medium   64 -> default   80 -> tall
#
# Usage:
#   set_titlebar_height.py 56           # shrink buttons + title strips to 56 px
#   set_titlebar_height.py --reset      # restore upstream default (64 px)
#   set_titlebar_height.py --dry-run 56 # preview without writing
#
# After patching, reload xfwm4: `xfwm4 --replace &` (or use
# shell/xfce_reload.sh -w).

import argparse
import pathlib
import re
import sys

THEME_DIR = pathlib.Path(__file__).resolve().parent
XFWM4_DIR = THEME_DIR / "xfwm4"

DEFAULT_HEIGHT = 64
MIN_HEIGHT = 24
MAX_HEIGHT = 128

# Files that follow the "64x64 canvas, 32x32 viewBox" button pattern.
BUTTON_STEMS = (
    "close",
    "hide",
    "maximize",
    "maximize-toggled",
    "menu",
    "shade",
    "shade-toggled",
    "stick",
    "stick-toggled",
)
BUTTON_VARIANTS = ("active", "inactive", "prelight", "pressed")

# Files that follow the "width=2 height=H viewBox='0 0 2 H'" strip pattern.
STRIP_FILES = [
    f"title-{i}-{state}.svg"
    for i in range(1, 6)
    for state in ("active", "inactive")
]
STRIP_FILES += [
    f"top-left-{state}.svg" for state in ("active", "inactive")
]
STRIP_FILES += [
    f"top-right-{state}.svg" for state in ("active", "inactive")
]


def button_files():
    for stem in BUTTON_STEMS:
        for variant in BUTTON_VARIANTS:
            path = XFWM4_DIR / f"{stem}-{variant}.svg"
            if path.exists():
                yield path


def strip_files():
    for name in STRIP_FILES:
        path = XFWM4_DIR / name
        if path.exists():
            yield path


def patch_button(text, height):
    """Buttons: rewrite only the outer `<svg ... height="..">` width/height."""
    # Match the root <svg ...> opening tag only (first occurrence).
    def repl(match):
        tag = match.group(0)
        tag = re.sub(r'width="\d+"', f'width="{height}"', tag, count=1)
        tag = re.sub(r'height="\d+"', f'height="{height}"', tag, count=1)
        return tag

    return re.sub(r"<svg\b[^>]*>", repl, text, count=1)


def patch_strip(text, height):
    """Strip tiles: rewrite svg height + viewBox height + first rect height."""
    # <svg ... height="N" viewBox="0 0 2 N">
    def svg_repl(match):
        tag = match.group(0)
        tag = re.sub(r'height="\d+"', f'height="{height}"', tag, count=1)
        tag = re.sub(
            r'viewBox="0 0 2 \d+"',
            f'viewBox="0 0 2 {height}"',
            tag,
            count=1,
        )
        return tag

    new_text = re.sub(r"<svg\b[^>]*>", svg_repl, text, count=1)
    # First <rect> is the full background fill — its height should match.
    new_text = re.sub(
        r'(<rect\s+width="2"\s+height=")\d+(")',
        lambda m: f"{m.group(1)}{height}{m.group(2)}",
        new_text,
        count=1,
    )
    return new_text


def process(path, patcher, height, dry_run):
    original = path.read_text()
    patched = patcher(original, height)
    if patched == original:
        return False
    if dry_run:
        print(f"--- {path.relative_to(THEME_DIR)} (dry-run) ---")
        for old, new in zip(original.splitlines(), patched.splitlines()):
            if old != new:
                print(f"  - {old}")
                print(f"  + {new}")
    else:
        path.write_text(patched)
    return True


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Adjust xfwm4 titlebar height for gruvbox-material-gtk-dark-hidpi "
            "by rescaling the button and title-strip SVGs."
        ),
    )
    parser.add_argument(
        "height",
        nargs="?",
        type=int,
        help=f"target titlebar height in px (upstream default: {DEFAULT_HEIGHT})",
    )
    parser.add_argument(
        "--reset",
        action="store_true",
        help=f"restore upstream default ({DEFAULT_HEIGHT}px)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="print planned edits without writing",
    )
    args = parser.parse_args()

    if args.reset:
        height = DEFAULT_HEIGHT
    elif args.height is not None:
        height = args.height
    else:
        parser.error("height is required (or pass --reset)")

    if not MIN_HEIGHT <= height <= MAX_HEIGHT:
        parser.error(f"height must be within [{MIN_HEIGHT}, {MAX_HEIGHT}]")

    if not XFWM4_DIR.is_dir():
        print(f"error: {XFWM4_DIR} not found", file=sys.stderr)
        return 1

    print(f"target xfwm4 titlebar height = {height}px")

    changed = 0
    for path in button_files():
        if process(path, patch_button, height, args.dry_run):
            changed += 1
            if not args.dry_run:
                print(f"patched button : {path.relative_to(THEME_DIR)}")
    for path in strip_files():
        if process(path, patch_strip, height, args.dry_run):
            changed += 1
            if not args.dry_run:
                print(f"patched strip  : {path.relative_to(THEME_DIR)}")

    verb = "would patch" if args.dry_run else "patched"
    print(f"\n{verb} {changed} SVG file(s).")
    if not args.dry_run and changed:
        print(
            "Reload xfwm4 to see the change:\n"
            "    xfwm4 --replace &        # or ./shell/xfce_reload.sh -w"
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
