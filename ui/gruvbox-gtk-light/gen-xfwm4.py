#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# @author   solomon <solomon.wzs@gmail.com>
# @date     2026-09-02
# @version  1.0
# @license  GPL-2.0+
#
# Generate the xfwm4 SVGs for Gruvbox-GTK-Light.
#
# Same geometry as gruvbox-material-gtk-dark-hidpi/xfwm4 (32x32 viewBox,
# 48x48 hidpi canvas, material icon paths) but recoloured to the gruvbox
# light palette:
#
#   active bg    #f2e5bc   inactive bg #ebdbb2
#   corners/edges follow the active/inactive titlebar
#   bottom edge follows the window body (#fbf1c7 / #f2e5bc)
#   glyph colour #3c3836  (active .55 / inactive .32 alpha)
#   glyph        #9d0006 (red) on prelight/pressed
#   title underline  #d5c4a1 (active) / #ebdbb2 (inactive)
import os

OUT = os.path.join(os.path.dirname(__file__), "xfwm4")

ACTIVE_BG = "#f2e5bc"
INACTIVE_BG = "#ebdbb2"
BODY_BG = "#fbf1c7"
FG = "#3c3836"
FG_PRELIGHT = "#9d0006"
ACTIVE_LINE = "#d5c4a1"
INACTIVE_LINE = "#ebdbb2"

TITLE_SVG = {
    "title-1": (5, 40), "title-2": (5, 40), "title-3": (5, 40),
    "title-4": (5, 40), "title-5": (5, 40),
}


def svg_header(w, h):
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" '
            'viewBox="0 0 %d %d">\n' % (w, h, w, h))


def bg_rect(w, h, fill):
    return '  <rect width="%d" height="%d" fill="%s"/>\n' % (w, h, fill)


def side_svg(name):
    """title-N-active / title-N-inactive — horizontal titlebar strips."""
    w, h = TITLE_SVG[name]
    out = [svg_header(w, h), bg_rect(w, h, "%BG%")]
    out.append('  <rect width="%d" height="1" y="%d" fill="_LINE_" fill-opacity=".9"/>\n'
               % (w, h - 1))
    out.append("</svg>\n")
    return "".join(out)


def edge_svg(kind):
    """left / right / top / bottom edges (2x48)."""
    if kind == "bottom":
        body = bg_rect(2, 48, "%BODY%")
    else:
        body = bg_rect(2, 48, "%BG%")
    return "".join([svg_header(2, 48), body, "</svg>\n"])


def corner_svg(name, side):
    """top-left/right (2x48) and bottom-left/right (2x2)."""
    if name.startswith("top"):
        fill = "%BODY%" if side == "inactive" else "%BG%"
        return "".join([svg_header(2, 48), bg_rect(2, 48, fill), "</svg>\n"])
    fill = "%BODY%" if side == "inactive" else "%BG%"
    return "".join([svg_header(2, 2), bg_rect(2, 2, fill), "</svg>\n"])


GLYPHS = {
    "close": ('<path d="M21 12.41L19.59 11 16 14.59 12.41 11 11 12.41 14.59 16 '
              '11 19.59 12.41 21 16 17.41 19.59 21 21 19.59 17.41 16z"/>'),
    "hide": '<path d="m12 18h8v2h-8z"/>',
    "maximize": '<path d="m12 12v8h8v-8zm2 2h4v4h-4z"/>',
    "shade": '<path d="m10 18 1.41 1.41 4.59-4.59 4.59 4.59 1.41-1.41-6-6z"/>',
    "shade-toggled": '<path d="m22 14-1.41-1.41-4.59 4.59-4.59-4.59-1.41 1.41l6 6z"/>',
    "stick": ('<path d="m16 10a6 6 0 0 0 -6 6 6 6 0 0 0 6 6 6 6 0 0 0 6 -6 6 6 0 '
              '0 0 -6 -6zm0 2a4 4 0 0 1 4 4 4 4 0 0 1 -4 4 4 4 0 0 1 -4 -4 4 4 0 '
              '0 1 4 -4z"/>'),
    "stick-toggled": ('<path d="m16 10a6 6 0 0 0 -6 6 6 6 0 0 0 6 6 6 6 0 0 0 6 '
                      '-6 6 6 0 0 0 -6 -6zm0 2a4 4 0 0 1 4 4 4 4 0 0 1 -4 4 4 4 0 '
                      '0 1 -4 -4 4 4 0 0 1 4 -4zm0 2a2 2 0 0 0 -2 2 2 2 0 0 0 2 2 '
                      '2 2 0 0 0 2 -2 2 2 0 0 0 -2 -2z"/>'),
    "maximize-toggled": '<path d="m13 13v6h6v-6zm2 2h2v2h-2z"/>',
    "menu": '<path d="M11 12h10M11 16h10M11 20h10"/>',
}

# per-state (glyph alpha, hover circle, pressed circle)
STATES = {
    "active":     (".55", "0", "0"),
    "inactive":   (".32", "0", "0"),
    "prelight":   (".8", ".14", "0"),
    "pressed":    (".8", ".2", ".14"),
}


def button_svg(name, state):
    alpha, hover, pressed = STATES[state]
    color = "%FG%" if state in ("active", "inactive") else "%FGH%"
    glyph = GLYPHS[name].replace("/>", ' opacity="%s"/>' % alpha)
    hover_rect = ('<circle cx="16" cy="16" r="15" opacity="%s" fill-opacity="1" '
                  'fill="#3c3836"/>' % hover)
    pressed_rect = ('<circle cx="16" cy="16" r="12" opacity="%s" fill="#3c3836"/>'
                    % pressed)
    out = [svg_header(48, 48).replace('viewBox="0 0 48 48"', 'viewBox="0 0 32 32"'),
           bg_rect(32, 32, "%BG%")]
    out.append('  <rect width="32" height="1" fill="%LINE%" fill-opacity=".55"/>\n')
    out.append('  <g fill="%s">\n' % color)
    out.append("    %s\n" % hover_rect)
    out.append("    %s\n" % pressed_rect)
    if name == "menu":
        out.append('    <g opacity="%s" stroke="%s" stroke-width="2" '
                   'stroke-linecap="round" fill="none">\n' % (alpha, color))
        out.append("      %s\n" % glyph)
        out.append("    </g>\n")
    else:
        out.append("    %s\n" % glyph)
    out.append("  </g>\n</svg>\n")
    return "".join(out)


def main():
    os.makedirs(OUT, exist_ok=True)
    written = []
    # title strips
    for t in TITLE_SVG:
        for suffix in ("active", "inactive"):
            fn = "%s-%s.svg" % (t, suffix)
            open(os.path.join(OUT, fn), "w").write(
                side_svg(t).replace("_LINE_", "")
                          .replace("%BG%", ACTIVE_BG if suffix == "active"
                                    else INACTIVE_BG)
                          .replace("%LINE%", ACTIVE_LINE if suffix == "active"
                                    else INACTIVE_LINE))
            written.append(fn)
    # edges & corners
    for e in ("left", "right", "bottom"):
        for suffix in ("active", "inactive"):
            fn = "%s-%s.svg" % (e, suffix)
            open(os.path.join(OUT, fn), "w").write(
                edge_svg(e).replace("%BODY%", BODY_BG if e == "bottom" else "")
                           .replace("%BG%", ACTIVE_BG if suffix == "active"
                                     else INACTIVE_BG))
            written.append(fn)
    for c in ("top-left", "top-right", "bottom-left", "bottom-right"):
        for suffix in ("active", "inactive"):
            fn = "%s-%s.svg" % (c, suffix)
            fill = BODY_BG if suffix == "inactive" else ACTIVE_BG
            if c.startswith("top"):
                svg = "".join([svg_header(2, 48), bg_rect(2, 48, fill), "</svg>\n"])
            else:
                svg = "".join([svg_header(2, 2), bg_rect(2, 2, fill), "</svg>\n"])
            open(os.path.join(OUT, fn), "w").write(svg)
            written.append(fn)
    # buttons
    for b in GLYPHS:
        for state in STATES:
            fn = "%s-%s.svg" % (b, state)
            svg = button_svg(b, state).replace("%FG%", FG).replace("%FGH%", FG_PRELIGHT)
            svg = svg.replace("%LINE%", ACTIVE_LINE).replace("%BG%", ACTIVE_BG)
            open(os.path.join(OUT, fn), "w").write(svg)
            written.append(fn)
    print("wrote %d svgs to %s" % (len(written), OUT))


if __name__ == "__main__":
    main()
