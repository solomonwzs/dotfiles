" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-04
" @license    GPL-2.0+

let s:bundle_list = [
    \ {'name': 'DrawIt'},
    \ {'name': 'LeaderF'},
    \ {'name': 'asyncrun.vim'},
    \ {'name': 'coc.nvim', 'priority': 2},
    \ {'name': 'defx-git', 'vim': 0},
    \ {'name': 'defx-icons'},
    \ {'name': 'defx.nvim', 'vim': 0},
    \ {'name': 'deol.nvim'},
    \ {'name': 'diffview.nvim', 'vim': 0},
    \ {'name': 'gruvbox', 'priority': 1},
    \ {'name': 'lightline.vim', 'priority': 2},
    \ {'name': 'nerdtree', 'nvim': 0},
    \ {'name': 'nvim-treesitter', 'vim': 0},
    \ {'name': 'nvim-web-devicons', 'vim': 0},
    \ {'name': 'plenary.nvim', 'vim': 0},
    \ {'name': 'rainbow'},
    \ {'name': 'tabular'},
    \ {'name': 'tagbar', 'priority': 2},
    \ {'name': 'telescope.nvim', 'vim': 0},
    \ {'name': 'ultisnips'},
    \ {'name': 'vim-commentary'},
    \ {'name': 'vim-delve'},
    \ {'name': 'vim-dirdiff'},
    \ {'name': 'vim-fugitive'},
    \ {'name': 'vim-markdown'},
    \ {'name': 'vim-signature'},
    \ {'name': 'vim-toml'},
    \ {'name': 'vim-vue'},
    \ {'name': 'vimproc.vim'},
    \ ]

let s:loaded_bundles = {}
let s:loaded_bundles_list = []
let s:is_nvim = has('nvim')

function! s:load_conf_file(name)
  if s:is_nvim
    let name0 = substitute(a:name, '\.', '-', 'g')
    let lua_cfile = g:vimhome.'/lua/plugin-conf/'.name0.'.lua'
    if filereadable(lua_cfile)
      exec 'lua require("plugin-conf/'.name0.'")'
    endif
  endif

  let vim_cfile = g:vimhome.'/conf/'.a:name.'.vim'
  if filereadable(vim_cfile)
    exec 'so '.vim_cfile
  endif
endfunc

function! s:priority_comp(i1, i2)
  let p1 = get(a:i1, 'priority', 0)
  let p2 = get(a:i2, 'priority', 0)
  return p1 == p2 ? 0 : p1 > p2 ? 1 : -1
endfunc

function! lib#bundle#load()
  let lib_bundle_list = sort(s:bundle_list, 's:priority_comp')

  let dir = g:vimhome.'/bundle'
  let s:loaded_bundles = {}
  call plug#begin(dir)
  for i in lib_bundle_list
    if (get(i, 'vim', 1) == 0 && !s:is_nvim) || 
        \ (get(i, 'nvim', 1) == 0 && s:is_nvim)
      continue
    endif

    let name = get(i, 'name', '')
    let plug = dir.'/'.name
    if !empty(glob(plug))
      call add(s:loaded_bundles_list, name)
      Plug plug
      let s:loaded_bundles[name] = 1
    endif
  endfor
  call plug#end()

  for i in s:loaded_bundles_list
    call s:load_conf_file(i)
  endfor
endfunc

function! lib#bundle#has_loaded(name)
  return has_key(s:loaded_bundles, a:name)
endfunc
