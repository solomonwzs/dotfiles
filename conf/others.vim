" Setting for ocamlmerlin (ocaml)
set runtimepath+=/usr/share/ocamlmerlin/vim

" Setting for cabal (haskell)
let $PATH=$PATH.':'.expand($HOME.'/.cabal/bin')

" Setting for ack.vim
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Setting for asyncrun
let g:asyncrun_open = 6

" Setting for jedi
let g:jedi#completions_enabled = 0

" Setting for vim-signify
let g:signify_sign_change = '~'

" Setting for twitvim
let twitvim_proxy = 'http://127.0.0.1:8118'

" Setting for vim-signature
highlight VimSignatureMarkLine ctermbg=96
let g:SignatureMarkTextHL = 'VimSignatureMarkLine'
" let g:SignatureMarkLineHL = 'VimSignatureMarkLine'
