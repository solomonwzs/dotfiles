" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-04
" @license    GPL-2.0+

let s:gb = {}

let s:gb.dark0_hard  = ['#1d2021', 234]     " 29-32-33
let s:gb.dark0       = ['#282828', 235]     " 40-40-40
let s:gb.dark0_soft  = ['#32302f', 236]     " 50-48-47
let s:gb.dark1       = ['#3c3836', 237]     " 60-56-54
let s:gb.dark2       = ['#504945', 239]     " 80-73-69
let s:gb.dark3       = ['#665c54', 241]     " 102-92-84
let s:gb.dark4       = ['#7c6f64', 243]     " 124-111-100
let s:gb.dark4_256   = ['#7c6f64', 243]     " 124-111-100

let s:gb.gray_245    = ['#928374', 245]     " 146-131-116
let s:gb.gray_244    = ['#928374', 244]     " 146-131-116

let s:gb.light0_hard = ['#f9f5d7', 230]     " 249-245-215
let s:gb.light0      = ['#fbf1c7', 229]     " 253-244-193
let s:gb.light0_soft = ['#f2e5bc', 228]     " 242-229-188
let s:gb.light1      = ['#ebdbb2', 223]     " 235-219-178
let s:gb.light2      = ['#d5c4a1', 250]     " 213-196-161
let s:gb.light3      = ['#bdae93', 248]     " 189-174-147
let s:gb.light4      = ['#a89984', 246]     " 168-153-132
let s:gb.light4_256  = ['#a89984', 246]     " 168-153-132

let s:gb.bright_red     = ['#fb4934', 167]     " 251-73-52
let s:gb.bright_green   = ['#b8bb26', 142]     " 184-187-38
let s:gb.bright_yellow  = ['#fabd2f', 214]     " 250-189-47
let s:gb.bright_blue    = ['#83a598', 109]     " 131-165-152
let s:gb.bright_purple  = ['#d3869b', 175]     " 211-134-155
let s:gb.bright_aqua    = ['#8ec07c', 108]     " 142-192-124
let s:gb.bright_orange  = ['#fe8019', 208]     " 254-128-25

let s:gb.neutral_red    = ['#cc241d', 124]     " 204-36-29
let s:gb.neutral_green  = ['#98971a', 106]     " 152-151-26
let s:gb.neutral_yellow = ['#d79921', 172]     " 215-153-33
let s:gb.neutral_blue   = ['#458588', 66]      " 69-133-136
let s:gb.neutral_purple = ['#b16286', 132]     " 177-98-134
let s:gb.neutral_aqua   = ['#689d6a', 72]      " 104-157-106
let s:gb.neutral_orange = ['#d65d0e', 166]     " 214-93-14

let s:gb.faded_red      = ['#9d0006', 88]      " 157-0-6
let s:gb.faded_green    = ['#79740e', 100]     " 121-116-14
let s:gb.faded_yellow   = ['#b57614', 136]     " 181-118-20
let s:gb.faded_blue     = ['#076678', 24]      " 7-102-120
let s:gb.faded_purple   = ['#8f3f71', 96]      " 143-63-113
let s:gb.faded_aqua     = ['#427b58', 66]      " 66-123-88
let s:gb.faded_orange   = ['#af3a03', 130]     " 175-58-3

let s:gui_color = [
    \ '#000000',
    \ '#800000',
    \ '#008000',
    \ '#808000',
    \ '#000080',
    \ '#800080',
    \ '#008080',
    \ '#c0c0c0',
    \ '#808080',
    \ '#ff0000',
    \ '#00ff00',
    \ '#ffff00',
    \ '#0000ff',
    \ '#ff00ff',
    \ '#00ffff',
    \ '#ffffff',
    \ '#000000',
    \ '#00005f',
    \ '#000087',
    \ '#0000af',
    \ '#0000d7',
    \ '#0000ff',
    \ '#005f00',
    \ '#005f5f',
    \ '#005f87',
    \ '#005faf',
    \ '#005fd7',
    \ '#005fff',
    \ '#008700',
    \ '#00875f',
    \ '#008787',
    \ '#0087af',
    \ '#0087d7',
    \ '#0087ff',
    \ '#00af00',
    \ '#00af5f',
    \ '#00af87',
    \ '#00afaf',
    \ '#00afd7',
    \ '#00afff',
    \ '#00d700',
    \ '#00d75f',
    \ '#00d787',
    \ '#00d7af',
    \ '#00d7d7',
    \ '#00d7ff',
    \ '#00ff00',
    \ '#00ff5f',
    \ '#00ff87',
    \ '#00ffaf',
    \ '#00ffd7',
    \ '#00ffff',
    \ '#5f0000',
    \ '#5f005f',
    \ '#5f0087',
    \ '#5f00af',
    \ '#5f00d7',
    \ '#5f00ff',
    \ '#5f5f00',
    \ '#5f5f5f',
    \ '#5f5f87',
    \ '#5f5faf',
    \ '#5f5fd7',
    \ '#5f5fff',
    \ '#5f8700',
    \ '#5f875f',
    \ '#5f8787',
    \ '#5f87af',
    \ '#5f87d7',
    \ '#5f87ff',
    \ '#5faf00',
    \ '#5faf5f',
    \ '#5faf87',
    \ '#5fafaf',
    \ '#5fafd7',
    \ '#5fafff',
    \ '#5fd700',
    \ '#5fd75f',
    \ '#5fd787',
    \ '#5fd7af',
    \ '#5fd7d7',
    \ '#5fd7ff',
    \ '#5fff00',
    \ '#5fff5f',
    \ '#5fff87',
    \ '#5fffaf',
    \ '#5fffd7',
    \ '#5fffff',
    \ '#870000',
    \ '#87005f',
    \ '#870087',
    \ '#8700af',
    \ '#8700d7',
    \ '#8700ff',
    \ '#875f00',
    \ '#875f5f',
    \ '#875f87',
    \ '#875faf',
    \ '#875fd7',
    \ '#875fff',
    \ '#878700',
    \ '#87875f',
    \ '#878787',
    \ '#8787af',
    \ '#8787d7',
    \ '#8787ff',
    \ '#87af00',
    \ '#87af5f',
    \ '#87af87',
    \ '#87afaf',
    \ '#87afd7',
    \ '#87afff',
    \ '#87d700',
    \ '#87d75f',
    \ '#87d787',
    \ '#87d7af',
    \ '#87d7d7',
    \ '#87d7ff',
    \ '#87ff00',
    \ '#87ff5f',
    \ '#87ff87',
    \ '#87ffaf',
    \ '#87ffd7',
    \ '#87ffff',
    \ '#af0000',
    \ '#af005f',
    \ '#af0087',
    \ '#af00af',
    \ '#af00d7',
    \ '#af00ff',
    \ '#af5f00',
    \ '#af5f5f',
    \ '#af5f87',
    \ '#af5faf',
    \ '#af5fd7',
    \ '#af5fff',
    \ '#af8700',
    \ '#af875f',
    \ '#af8787',
    \ '#af87af',
    \ '#af87d7',
    \ '#af87ff',
    \ '#afaf00',
    \ '#afaf5f',
    \ '#afaf87',
    \ '#afafaf',
    \ '#afafd7',
    \ '#afafff',
    \ '#afd700',
    \ '#afd75f',
    \ '#afd787',
    \ '#afd7af',
    \ '#afd7d7',
    \ '#afd7ff',
    \ '#afff00',
    \ '#afff5f',
    \ '#afff87',
    \ '#afffaf',
    \ '#afffd7',
    \ '#afffff',
    \ '#d70000',
    \ '#d7005f',
    \ '#d70087',
    \ '#d700af',
    \ '#d700d7',
    \ '#d700ff',
    \ '#d75f00',
    \ '#d75f5f',
    \ '#d75f87',
    \ '#d75faf',
    \ '#d75fd7',
    \ '#d75fff',
    \ '#d78700',
    \ '#d7875f',
    \ '#d78787',
    \ '#d787af',
    \ '#d787d7',
    \ '#d787ff',
    \ '#d7af00',
    \ '#d7af5f',
    \ '#d7af87',
    \ '#d7afaf',
    \ '#d7afd7',
    \ '#d7afff',
    \ '#d7d700',
    \ '#d7d75f',
    \ '#d7d787',
    \ '#d7d7af',
    \ '#d7d7d7',
    \ '#d7d7ff',
    \ '#d7ff00',
    \ '#d7ff5f',
    \ '#d7ff87',
    \ '#d7ffaf',
    \ '#d7ffd7',
    \ '#d7ffff',
    \ '#ff0000',
    \ '#ff005f',
    \ '#ff0087',
    \ '#ff00af',
    \ '#ff00d7',
    \ '#ff00ff',
    \ '#ff5f00',
    \ '#ff5f5f',
    \ '#ff5f87',
    \ '#ff5faf',
    \ '#ff5fd7',
    \ '#ff5fff',
    \ '#ff8700',
    \ '#ff875f',
    \ '#ff8787',
    \ '#ff87af',
    \ '#ff87d7',
    \ '#ff87ff',
    \ '#ffaf00',
    \ '#ffaf5f',
    \ '#ffaf87',
    \ '#ffafaf',
    \ '#ffafd7',
    \ '#ffafff',
    \ '#ffd700',
    \ '#ffd75f',
    \ '#ffd787',
    \ '#ffd7af',
    \ '#ffd7d7',
    \ '#ffd7ff',
    \ '#ffff00',
    \ '#ffff5f',
    \ '#ffff87',
    \ '#ffffaf',
    \ '#ffffd7',
    \ '#ffffff',
    \ '#080808',
    \ '#121212',
    \ '#1c1c1c',
    \ '#262626',
    \ '#303030',
    \ '#3a3a3a',
    \ '#444444',
    \ '#4e4e4e',
    \ '#585858',
    \ '#626262',
    \ '#6c6c6c',
    \ '#767676',
    \ '#808080',
    \ '#8a8a8a',
    \ '#949494',
    \ '#9e9e9e',
    \ '#a8a8a8',
    \ '#b2b2b2',
    \ '#bcbcbc',
    \ '#c6c6c6',
    \ '#d0d0d0',
    \ '#dadada',
    \ '#e4e4e4',
    \ '#eeeeee',
    \ ]

function! lib#color#gruvbox_color(name) abort
  return get(s:gb, a:name, s:gb.light0)
endfunction

function! lib#color#xcterm256_color() abort
  let prefix_fg = 'xCtermFg_'
  let prefix_bg = 'xCtermBg_'
  let groups_bg = []
  let groups_fg = []

  for i in range(0, 255)
    let group_name = prefix_fg.i
    exec 'hi '.group_name.' ctermfg='.i.' guifg='.s:gui_color[i]
    exec 'syn match '.group_name.' contained "'.i.'"'
    call add(groups_fg, group_name)

    let group_name = prefix_bg.i
    exec 'hi '.group_name.' ctermbg='.i.' guibg='.s:gui_color[i]
    exec 'syn match '.group_name.' contained "'.i.'"'
    call add(groups_bg, group_name)
  endfor

  let cluster_fg = 'Xcterm256_FG'
  let cluster_bg = 'Xcterm256_BG'
  exec 'syn cluster '.cluster_fg.' contains='.join(groups_fg, ',')
  exec 'syn cluster '.cluster_bg.' contains='.join(groups_bg, ',')
  return [cluster_fg, cluster_bg]
endfunction
