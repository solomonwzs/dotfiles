" Encrypt
set cryptmethod=blowfish2
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

set noequalalways

set diffopt=vertical

" Setting for search
set hlsearch
set magic

" Setting for auto reload file
set autoread

" Setting for row control
set linebreak
set wrap

" Setting for cscope
if has('cscope')
    set cscopeprg=/usr/bin/cscope
    set cscopetagorder=0
    set cscopetag
    set nocscopeverbose
    set cscopeverbose
    set cscopequickfix=s-,d-,c-,t-,e-,f-,i-
endif

augroup cursor_group
    autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
    autocmd InsertLeave * if pumvisible() == 0|pclose|endif

    " Restore cursor position
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'

augroup fileType_group
    autocmd FileType java       setlocal omnifunc=javacomplete#Complete
    autocmd Filetype c          setlocal omnifunc=ccomplete#Complete
    autocmd Filetype html       setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd Filetype markdown   setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd Filetype xml        setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd Filetype python     setlocal omnifunc=pythoncomplete#CompleteTags
    autocmd FileType python     setlocal completeopt-=preview
    autocmd Filetype tex        setlocal omnifunc=syntaxcomplete#Complete
    autocmd FileType css        setlocal omnifunc=csscomplete#CompleteCSS
    if executable('ghc-mod')
        autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
    endif

    autocmd BufEnter,BufRead *.vue set filetype=vue.javascript

    autocmd FileType html,xml,yaml,vue.javascript,javascript
                \ setlocal sw=2 tabstop=2 softtabstop=2
    autocmd FileType nginx setlocal commentstring=#\ %s
    autocmd FileType make setlocal noet
augroup END

let g:html_indent_inctags='li,body,head'

let mapleader="\\"
let maplocalleader=','
let g:vimhome = fnameescape(fnamemodify(resolve(expand('<sfile>:p')), ':h'))

nmap <leader>h :help <C-R>=expand("<cword>")<CR><CR>
vmap <C-c> "+y

let g:loaded_youcompleteme = 1

if $VIM_GROUP ==? 'erl'
    let g:lib_bundle_ycm_load = 1
    let g:lib_bundle_blacklist = [
                \ 'ale',
                \ 'supertab',
                \ 'vim-gutentags',
                \ ]
elseif $VIM_GROUP ==? 'scheme'
    let g:lib_bundle_blacklist = [
                \ 'ale',
                \ 'vim-erlang-tags',
                \ 'vim-erlang-omnicomplete',
                \ ]
else
    let g:lib_bundle_ycm_load = 1
    let g:lib_bundle_blacklist = [
                \ 'syntastic',
                \ 'supertab',
                \ 'vim-erlang-tags',
                \ 'vim-erlang-omnicomplete',
                \ ]
endif
call lib#bundle#load()
