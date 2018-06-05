" Encrypt
set cm=blowfish2
set viminfo=
set nobackup
set nowritebackup

set t_Co=256
colorscheme candy

syntax enable

set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
set smarttab
set autoindent
filetype plugin indent on

set modeline

set mouse=a

set number
set ruler

set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936

set foldmethod=indent
set nofoldenable
set foldlevel=1

set noea

" Setting for search
set hlsearch
set magic

" Setting for auto reload file
set autoread

" Setting for row control
set linebreak
set wrap

autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

set grepprg=grep\ -nH\ $*
let g:tex_flavor="latex"

autocmd FileType java setlocal omnifunc=javacomplete#Complete
autocmd Filetype c setlocal omnifunc=ccomplete#Complete
autocmd Filetype html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd Filetype xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd Filetype python setlocal omnifunc=pythoncomplete#CompleteTags
autocmd FileType python setlocal completeopt-=preview
autocmd Filetype tex setlocal omnifunc=syntaxcomplete#Complete
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
if executable('ghc-mod')
    autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
endif

let g:html_indent_inctags="li,body,head"
autocmd FileType html,xml,yaml setlocal sw=2 tabstop=2 softtabstop=2

let mapleader="\\"
let maplocalleader=","
let g:vimhome = fnamemodify(resolve(expand('<sfile>:p')), ':h')

nmap <leader>h :help <C-R>=expand("<cword>")<CR><CR>
vmap <C-c> "+y

" Restore cursor position
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

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


exec 'so '.fnameescape(g:vimhome).'/asc/terminal_meta.vim'

exec 'so '.fnameescape(g:vimhome).'/conf/vim-plug.vim'
exec 'so '.fnameescape(g:vimhome).'/conf/airline.vim'
exec 'so '.fnameescape(g:vimhome).'/conf/vim-go.vim'
exec 'so '.fnameescape(g:vimhome).'/conf/ale.vim'
exec 'so '.fnameescape(g:vimhome).'/conf/ycm.vim'
exec 'so '.fnameescape(g:vimhome).'/conf/leaderf.vim'
exec 'so '.fnameescape(g:vimhome).'/conf/gutentags.vim'
exec 'so '.fnameescape(g:vimhome).'/conf/syntastic.vim'
