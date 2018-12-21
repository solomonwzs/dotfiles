let s:bundledir = fnameescape(g:vimhome).'/bundle'

call plug#begin(s:bundledir)

" A tree explorer plugin for vim
Plug 'https://github.com/scrooloose/nerdtree'

" Ascii drawing plugin: lines, ellipses, arrows, fills,
" and more!
Plug 'https://github.com/vim-scripts/DrawIt'

" Fuzzy file, buffer, mru, tag, etc finder.
" Plug 'https://github.com/kien/ctrlp.vim'

" Lean & mean status/tabline for vim that's light as air
Plug 'https://github.com/bling/vim-airline'

" Generate Vim tags for Erlang files
Plug 'https://github.com/vim-erlang/vim-erlang-tags'

" Vim python-mode. PyLint, Rope, Pydoc, breakpoints from box.
" Plug 'https://github.com/klen/python-mode'

" A nicer Python indentation style for vim.
Plug 'https://github.com/hynek/vim-python-pep8-indent'

" Go development plugin for Vim
Plug 'https://github.com/fatih/vim-go'

" Vim plugin to diff two directories
Plug 'https://github.com/will133/vim-dirdiff'

" Perform all your vim insert mode completions with Tab
Plug 'https://github.com/ervandew/supertab'

" Run Async Shell Commands in Vim 8.0 / NeoVim and Output
" to Quickfix Window
Plug 'https://github.com/skywind3000/asyncrun.vim.git'

" Asynchronous Lint Engine
Plug 'https://github.com/w0rp/ale.git'

" Show a diff using Vim its sign column.
" Plug 'https://github.com/mhinz/vim-signify.git'

" A Vim plugin which shows a git diff in the gutter
" (sign column) and stages/undoes hunks.
Plug 'https://github.com/airblade/vim-gitgutter.git', {'commit': '7b81a8a'}

" Commentary.vim: comment stuff out
Plug 'https://github.com/tpope/vim-commentary'

" An asynchronous fuzzy finder which is used to quickly
" locate files, buffers, mrus, tags, etc. in large project.
Plug 'https://github.com/Yggdroot/LeaderF.git', {'do': './install.sh'}

" Vim plugin that displays tags in a window, ordered by scope
Plug 'https://github.com/majutsushi/tagbar'

" Vim plugin for the Perl module / CLI script 'ack'
Plug 'https://github.com/mileszs/ack.vim.git'

" A Vim plugin that manages your tag files
Plug 'https://github.com/ludovicchabant/vim-gutentags.git'

" Directory viewer for Vim
Plug 'https://github.com/justinmk/vim-dirvish.git'

" Awesome Python autocompletion
Plug 'https://github.com/davidhalter/jedi-vim.git'

" Syntax checking hacks for vim
Plug 'https://github.com/vim-syntastic/syntastic.git'

" Updated javacomplete plugin for vim
Plug 'https://github.com/artur-shaik/vim-javacomplete2.git'

" Plugin to toggle, display and navigate marks
Plug 'https://github.com/kshenoy/vim-signature.git'

" A Git wrapper so awesome, it should be illegal
Plug 'https://github.com/tpope/vim-fugitive.git'

" Vim script for text filtering and alignment
Plug 'https://github.com/godlygeek/tabular.git'

" Markdown Vim Mode
Plug 'https://github.com/plasticboy/vim-markdown.git'

" Twitter client for Vim
Plug 'https://github.com/twitvim/twitvim.git'

" Next generation completion framework after neocomplcache
Plug 'https://github.com/Shougo/neocomplete.vim.git'

" Retro groove color scheme for Vim
Plug 'https://github.com/morhetz/gruvbox.git'

" An arctic, north-bluish clean and elegant Vim theme.
Plug 'https://github.com/arcticicestudio/nord-vim.git'

" Rainbow Parentheses Improved, shorter code, no level limit,
" smooth and fast, powerful configuration.
Plug 'https://github.com/luochen1990/rainbow.git'

" Vim configuration for Rust.
Plug 'https://github.com/rust-lang/rust.vim.git'

" Preview colours in source code while editing
Plug 'https://github.com/ap/vim-css-color.git'

" Maktaba is a vimscript plugin library.
Plug 'https://github.com/google/vim-maktaba.git'

" Glaive is a utility for configuring maktaba plugins.
Plug 'https://github.com/google/vim-glaive.git'

" Syntax-aware code formatting, depends on maktaba.
Plug 'https://github.com/google/vim-codefmt.git'

" Syntax Highlight for Vue.js components.
Plug 'https://github.com/posva/vim-vue.git'

" Vim syntax for TOML.
Plug 'https://github.com/cespare/vim-toml.git'

" Vastly improved Javascript indentation and syntax support in Vim.
Plug 'https://github.com/pangloss/vim-javascript.git'

" Erlang omnicomplete plugin for Vim.
Plug 'https://github.com/vim-erlang/vim-erlang-omnicomplete.git'

" Language Server Protocol (LSP) support for vim and neovim.
Plug 'https://github.com/autozimu/LanguageClient-neovim.git', {
            \ 'branch': 'next',
            \ 'do': 'bash install.sh',
            \ }

" Dark powered asynchronous completion framework for neovim/Vim8.
Plug 'https://github.com/Shougo/deoplete.nvim.git'

" Yet Another Remote Plugin Framework for Neovim.
Plug 'https://github.com/roxma/nvim-yarp.git'

" EXPERIMENTAL
Plug 'https://github.com/roxma/vim-hug-neovim-rpc.git'

" async language server protocol plugin for vim and neovim.
" Plug 'https://github.com/prabirshrestha/vim-lsp.git'

" Racer support for Vim.
Plug 'https://github.com/racer-rust/vim-racer.git'

" fzf heart vim.
" Plug 'https://github.com/junegunn/fzf.vim.git'

" The fancy start screen for Vim.
Plug 'https://github.com/mhinz/vim-startify.git'

" Vim motions on speed!
" Plug 'https://github.com/easymotion/vim-easymotion.git'

" The ultimate snippet solution for Vim.
Plug 'https://github.com/SirVer/ultisnips.git'

call plug#end()

" call LoadBundle(s:bundledir)
