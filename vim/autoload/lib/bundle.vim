" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-04
" @license    GPL-2.0+

let s:bundle_list = {
    \ 'DrawIt': {},
    \ 'LeaderF': {},
    \ 'coc.nvim': {'deps': ['render-markdown.nvim']},
    \ 'defx-git': {'vim': 0},
    \ 'defx-icons': {},
    \ 'defx.nvim': {'vim': 0},
    \ 'diffview.nvim': {'vim': 0},
    \ 'gruvbox': {'deps': ['lightline.vim'], 'nvim': 0},
    \ 'gruvbox.nvim': {'deps': ['lightline.vim'], 'vim': 0},
    \ 'lightline.vim': {},
    \ 'nerdtree': {'nvim': 0},
    \ 'nvim-treesitter': {'vim': 0},
    \ 'nvim-web-devicons': {'vim': 0},
    \ 'plenary.nvim': {'vim': 0},
    \ 'render-markdown.nvim': {'vim': 0, 'deps': ['nvim-web-devicons', 'nvim-treesitter']},
    \ 'tabular': {},
    \ 'tagbar': {},
    \ 'telescope.nvim': {'vim': 0},
    \ 'ultisnips': {},
    \ 'vim-commentary': {},
    \ 'vim-dirdiff': {},
    \ 'vim-fugitive': {},
    \ 'vim-signature': {},
    \ }

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

function! s:get_bundle_list()
  let blist = {}
  let dlist = {}
  for [name, conf] in items(s:bundle_list)
    if (get(conf, 'vim', 1) == 0 && !s:is_nvim) ||
        \ (get(conf, 'nvim', 1) == 0 && s:is_nvim)
      continue
    endif
    let blist[name] = 0

    let deps = get(conf, 'deps', [])
    for dep in deps
      if !has_key(s:bundle_list, dep)
        continue
      endif
      let dep_conf = s:bundle_list[dep]
      if (get(dep_conf, 'vim', 1) == 0 && !s:is_nvim) ||
          \ (get(dep_conf, 'nvim', 1) == 0 && s:is_nvim)
        continue
      endif

      let blist[name] += 1
      if has_key(dlist, dep)
        call add(dlist[dep], name)
      else
        let dlist[dep] = [name]
      endif
    endfor
  endfor

  let bundle_list = []
  while len(blist) != 0
    for name in keys(blist)
      if blist[name] != 0
        continue
      endif

      call add(bundle_list, name)
      call remove(blist, name)

      if has_key(dlist, name)
        for n in dlist[name]
          let blist[n] -= 1
        endfor
      endif
    endfor
  endwhile
  return bundle_list
endfunction

function! lib#bundle#load()
  let lib_bundle_list = s:get_bundle_list()

  let dir = g:vimhome.'/bundle'
  let s:loaded_bundles = {}
  call plug#begin(dir)
  for name in lib_bundle_list
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
