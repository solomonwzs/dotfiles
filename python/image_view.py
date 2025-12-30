#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-10-11
# @version  1.0
# @license  GPL-2.0+

from PIL import Image
from image_utils import resize_image, image2tstr
import cairosvg
import io
import optparse


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

    if arg[0].find(".svg") != -1:
        png_bytes = cairosvg.svg2png(url=arg[0])
        img = Image.open(io.BytesIO(png_bytes))
        format = "SVG"
    else:
        img = Image.open(arg[0])
        format = img.format
    print(f"size: {img.width}x{img.height}, format: {format}")

    img = resize_image(img, opt.width, opt.height, opt.ratio)
    img = img.convert("RGB")
    s = image2tstr(img)
    for i in s:
        print(i)
