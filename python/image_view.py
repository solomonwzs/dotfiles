#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-10-11
# @version  1.0
# @license  GPL-2.0+

from PIL import Image
import optparse

RESET_STYLE = "\x1b[0m"


def terminal_style_str(
    *,
    fg: int | tuple[int, int, int] = 15,
    bg: int | tuple[int, int, int] = 0,
    bold: bool = False,
    faint: bool = False,
    italic: bool = False,
    underlined: bool = False,
    inverse: bool = False,
    strikethrough: bool = False,
):
    style_codes: list[str] = []
    if bold:
        style_codes += "1"
    if faint:
        style_codes += "2"
    if italic:
        style_codes += "3"
    if underlined:
        style_codes += "4"
    if inverse:
        style_codes += "7"
    if strikethrough:
        style_codes += "9"

    if isinstance(fg, int) and 0 <= fg <= 255:
        style_codes += ["38", "5", str(fg)]
    elif isinstance(fg, tuple) and len(fg) == 3:
        r, g, b = fg
        if 0 <= r <= 255 and 0 <= g <= 255 and 0 <= b <= 255:
            style_codes += ["38", "2", str(r), str(g), str(b)]

    if isinstance(bg, int) and 0 <= bg <= 255:
        style_codes += ["48", "5", str(bg)]
    elif isinstance(bg, tuple) and len(bg) == 3:
        r, g, b = bg
        if 0 <= r <= 255 and 0 <= g <= 255 and 0 <= b <= 255:
            style_codes += ["48", "2", str(r), str(g), str(b)]

    style = ";".join(style_codes) if len(style_codes) > 0 else "0"
    return f"\x1b[{style}m"


def resize_image(
    image: Image.Image,
    new_width: int = 100,
    new_height: int = 100,
    rate: float = 1.0,
) -> Image.Image:
    ori_width, ori_height = image.size
    aspect_ratio = ori_height / ori_width * rate
    height = int(new_width * aspect_ratio)

    width = new_width
    if height > new_height:
        height = new_height
        width = int(height / aspect_ratio)

    new_image = image.resize((width, height))
    return new_image


def pixel2rgb(pix) -> tuple[int, int, int] | None:
    rgb = None
    if isinstance(pix, int):
        rgb = (pix, pix, pix)
    elif isinstance(pix, tuple):
        if len(pix) == 3:
            rgb = pix
        elif len(pix) == 4:
            r, g, b, _ = pix
            rgb = (r, g, b)
    return rgb


def image2tstr(image: Image.Image) -> list[str]:
    width, height = image.size
    pixel_list = list(image.getdata())
    res = []
    for i in range(0, height, 2):
        s = ""
        for j in range(width):
            pix0 = pixel_list[i * width + j]
            pix1 = pixel_list[(i + 1) * width + j] if i + 1 < height else None

            fg = pixel2rgb(pix0)
            bg = pixel2rgb(pix1)
            s += terminal_style_str(
                fg=fg if fg is not None else -1, bg=bg if bg is not None else -1
            )
            s += "▀"
        s += RESET_STYLE
        res.append(s)
    return res


if __name__ == "__main__":
    parser = optparse.OptionParser(usage=__doc__)
    parser.add_option(
        "--width", type=int, default=120, help="max disply width (default: 120)"
    )
    parser.add_option(
        "--height",
        type=int,
        default=120,
        help="max disply height (default: 120)",
    )
    parser.add_option(
        "--ratio",
        type=float,
        default=1.0,
        help="height ratio (default: 1.0)",
    )
    opt, arg = parser.parse_args()

    img = Image.open(arg[0])
    print(f"size: {img.width}x{img.height}, format: {img.format}")

    img = resize_image(img, opt.width, opt.height, opt.ratio)
    img = img.convert("RGB")
    s = image2tstr(img)
    for i in s:
        print(i)
