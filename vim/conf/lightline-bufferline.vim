echo exists('g:lightline')
if !exists('g:lightline') ||
    \ !exists('g:lightline.component_expand') ||
    \ !exists('g:lightline.component_type')
  finish
endif

set showtabline=2

let g:lightline.tabline = {
    \   'left': [
    \       [ 'tabs' ],
    \   ],
    \   'right': [
    \       [ 'close' ],
    \   ],
    \ }

let g:lightline.tab = {
    \ 'active': [ 'tabnum', 'filename', 'modified' ],
    \ 'inactive': [ 'tabnum', 'filename', 'modified' ],
    \ }

let g:lightline.component_expand.bufferline = 'lightline#bufferline#buffers'
let g:lightline.component_type.bufferline = 'tabsel'
