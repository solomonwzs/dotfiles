" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-04
" @license    MIT


function! lib#color#xcterm256_color() abort
  let prefix_fg = 'xCtermFg_'
  let prefix_bg = 'xCtermBg_'
  let groups_bg = []
  let groups_fg = []

  for i in range(0, 255)
    let group_name = prefix_fg.i
    exec 'hi '.group_name.' ctermfg='.i
    exec 'syn match '.group_name.' contained "'.i.'"'
    call add(groups_fg, group_name)

    let group_name = prefix_bg.i
    exec 'hi '.group_name.' ctermbg='.i
    exec 'syn match '.group_name.' contained "'.i.'"'
    call add(groups_bg, group_name)
  endfor

  let cluster_fg = 'Xcterm256_FG'
  let cluster_bg = 'Xcterm256_BG'
  exec 'syn cluster '.cluster_fg.' contains='.join(groups_fg, ',')
  exec 'syn cluster '.cluster_bg.' contains='.join(groups_bg, ',')
  return [cluster_fg, cluster_bg]
endfunction
