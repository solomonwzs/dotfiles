let s:bg_red = lib#color#theme_color('light_red')
let s:bg_green = lib#color#theme_color('light_green')
let s:bg_blue = lib#color#theme_color('light_blue')

let s:fg = lib#color#theme_color('bg0')

call lib#color#highlight('rtfRed', {'bg': s:bg_red, 'fg': s:fg, 'attr': 'underline'})
call lib#color#highlight('rtfGreen', {'bg': s:bg_green, 'fg': s:fg, 'attr': 'underline'})
call lib#color#highlight('rtfBlue', {'bg': s:bg_blue, 'fg': s:fg, 'attr': 'underline'})
