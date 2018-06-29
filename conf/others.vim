" Setting for ocamlmerlin (ocaml)
set rtp+=/usr/share/ocamlmerlin/vim

" Setting for cabal (haskell)
let $PATH=$PATH.':'.expand("$HOME/.cabal/bin")

" Setting for ack.vim
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Setting for asyncrun
let g:asyncrun_open = 6

" Setting for vim-commentary
autocmd FileType nginx setlocal commentstring=#\ %s

" Setting for jedi
let g:jedi#completions_enabled = 0

" Setting for vim-signify
let g:signify_sign_change = '~'

" Setting for twitvim
let twitvim_proxy = 'http://127.0.0.1:8118'