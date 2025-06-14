let s:bundledir = fnameescape(g:vimhome).'/bundle'

call plug#begin(s:bundledir)

" Vim plugin which formated javascript files by js-beautify.
" Plug 'https://github.com/maksimr/vim-jsbeautify.git'

" A Vim plugin for Prettier.
" Plug 'https://github.com/prettier/vim-prettier.git', {
"   \ 'do': 'yarn install',
"   \ 'branch': 'release/0.x'
"   \ }

" A tree explorer plugin for vim
Plug 'https://github.com/scrooloose/nerdtree'

" Ascii drawing plugin: lines, ellipses, arrows, fills,
" and more!
Plug 'https://github.com/vim-scripts/DrawIt'

" Fuzzy file, buffer, mru, tag, etc finder.
" Plug 'https://github.com/kien/ctrlp.vim'

" Lean & mean status/tabline for vim that's light as air
" Plug 'https://github.com/vim-airline/vim-airline'

" Generate Vim tags for Erlang files
" Plug 'https://github.com/vim-erlang/vim-erlang-tags'

" Vim python-mode. PyLint, Rope, Pydoc, breakpoints from box.
" Plug 'https://github.com/klen/python-mode'

" A nicer Python indentation style for vim.
" Plug 'https://github.com/hynek/vim-python-pep8-indent'

" Go development plugin for Vim
" Plug 'https://github.com/fatih/vim-go'

" Vim plugin to diff two directories
Plug 'https://github.com/will133/vim-dirdiff'

" Perform all your vim insert mode completions with Tab
" Plug 'https://github.com/ervandew/supertab'

" Run Async Shell Commands in Vim 8.0 / NeoVim and Output
" to Quickfix Window
" Plug 'https://github.com/skywind3000/asyncrun.vim.git'

" Asynchronous Lint Engine
" Plug 'https://github.com/w0rp/ale.git'

" Show a diff using Vim its sign column.
" Plug 'https://github.com/mhinz/vim-signify.git'

" A Vim plugin which shows a git diff in the gutter
" (sign column) and stages/undoes hunks.
" Plug 'https://github.com/airblade/vim-gitgutter.git'

" Commentary.vim: comment stuff out
Plug 'https://github.com/tpope/vim-commentary'

" An asynchronous fuzzy finder which is used to quickly
" locate files, buffers, mrus, tags, etc. in large project.
Plug 'https://github.com/Yggdroot/LeaderF.git', {'do': './install.sh'}

" A vim plugin to display the indention levels with thin vertical lines
" Topics.
" Plug 'https://github.com/Yggdroot/indentLine.git'

" Indent guides for Neovim
" Plug 'https://github.com/lukas-reineke/indent-blankline.nvim.git'

" Vim plugin that displays tags in a window, ordered by scope
Plug 'https://github.com/majutsushi/tagbar'

" Vim plugin for the Perl module / CLI script 'ack'
" Plug 'https://github.com/mileszs/ack.vim.git'

" A Vim plugin that manages your tag files
" Plug 'https://github.com/ludovicchabant/vim-gutentags.git'

" Directory viewer for Vim
" Plug 'https://github.com/justinmk/vim-dirvish.git'

" Awesome Python autocompletion
" Plug 'https://github.com/davidhalter/jedi-vim.git'

" Syntax checking hacks for vim
" Plug 'https://github.com/vim-syntastic/syntastic.git'

" Updated javacomplete plugin for vim
" Plug 'https://github.com/artur-shaik/vim-javacomplete2.git'

" Plugin to toggle, display and navigate marks
Plug 'https://github.com/kshenoy/vim-signature.git'

" A Git wrapper so awesome, it should be illegal
Plug 'https://github.com/tpope/vim-fugitive.git'

" Vim script for text filtering and alignment
Plug 'https://github.com/godlygeek/tabular.git'

" Markdown Vim Mode
" Plug 'https://github.com/plasticboy/vim-markdown.git'

" Twitter client for Vim
" Plug 'https://github.com/twitvim/twitvim.git'

" Next generation completion framework after neocomplcache
" Plug 'https://github.com/Shougo/neocomplete.vim.git'

" Retro groove color scheme for Vim
Plug 'https://github.com/morhetz/gruvbox.git'

" Lua port of the most famous vim colorscheme
Plug 'https://github.com/ellisonleao/gruvbox.nvim.git'

" An arctic, north-bluish clean and elegant Vim theme.
" Plug 'https://github.com/arcticicestudio/nord-vim.git'

" Rainbow Parentheses Improved, shorter code, no level limit,
" smooth and fast, powerful configuration.
" Plug 'https://github.com/luochen1990/rainbow.git'

" Vim configuration for Rust.
" Plug 'https://github.com/rust-lang/rust.vim.git'

" Preview colours in source code while editing
" Plug 'https://github.com/ap/vim-css-color.git'

" Maktaba is a vimscript plugin library.
" Plug 'https://github.com/google/vim-maktaba.git'

" Glaive is a utility for configuring maktaba plugins.
" Plug 'https://github.com/google/vim-glaive.git'

" Syntax-aware code formatting, depends on maktaba.
" Plug 'https://github.com/google/vim-codefmt.git'

" Syntax Highlight for Vue.js components.
" Plug 'https://github.com/posva/vim-vue.git'

" Vim syntax for TOML.
" Plug 'https://github.com/cespare/vim-toml.git'

" Vastly improved Javascript indentation and syntax support in Vim.
" Plug 'https://github.com/pangloss/vim-javascript.git'

" Erlang omnicomplete plugin for Vim.
" Plug 'https://github.com/vim-erlang/vim-erlang-omnicomplete.git'

" coc-erlang_ls
" Plug 'https://github.com/hyhugh/coc-erlang_ls.git', {'do': 'yarn install --frozen-lockfile'}

" Language Server Protocol (LSP) support for vim and neovim.
" Plug 'https://github.com/autozimu/LanguageClient-neovim.git', {
"         \ 'branch': 'next',
"         \ 'do': 'bash install.sh',
"         \ }

" Dark powered asynchronous completion framework for neovim/Vim8.
" Plug 'https://github.com/Shougo/deoplete.nvim.git'

" Yet Another Remote Plugin Framework for Neovim.
" Plug 'https://github.com/roxma/nvim-yarp.git'

" EXPERIMENTAL
" Plug 'https://github.com/roxma/vim-hug-neovim-rpc.git'

" async language server protocol plugin for vim and neovim.
" Plug 'https://github.com/prabirshrestha/vim-lsp.git'

" Racer support for Vim.
" Plug 'https://github.com/racer-rust/vim-racer.git'

" fzf heart vim.
" Plug 'https://github.com/junegunn/fzf.vim.git'

" The fancy start screen for Vim.
" Plug 'https://github.com/mhinz/vim-startify.git'

" Vim motions on speed!
" Plug 'https://github.com/easymotion/vim-easymotion.git'

" The ultimate snippet solution for Vim.
Plug 'https://github.com/SirVer/ultisnips.git'

" Dark powered shell interface for NeoVim and Vim8.
" Plug 'https://github.com/Shougo/deol.nvim.git'

" Interactive command execution in Vim.
" Plug 'https://github.com/Shougo/vimproc.vim.git', {'do': 'make'}

" Unite and create user interfaces.
" Plug 'https://github.com/Shougo/unite.vim.git'

" Neovim / Vim integration for Delve. (for Golang)
" Plug 'https://github.com/sebdah/vim-delve.git'

" A code-completion engine for Vim http://valloric.github.io/YouCompleteMe/
" Plug 'https://github.com/Valloric/YouCompleteMe.git'

" Intellisense engine for vim8 & neovim, full language server protocol support
" as VSCode.
" Plug 'https://github.com/solomonwzs/coc.nvim.git', {'branch': 'release_plus'}
Plug 'https://github.com/neoclide/coc.nvim.git', {'branch': 'release'}

" A light and configurable statusline/tabline plugin for Vim.
Plug 'https://github.com/itchyny/lightline.vim.git'

" A lightweight plugin to display the list of buffers in the lightline vim
" plugin.
" Plug 'https://github.com/mengelbrecht/lightline-bufferline.git'

" Viewer & Finder for LSP symbols and tags in Vim.
" Plug 'https://github.com/liuchengxu/vista.vim.git'

" The dark powered file explorer implementation.
Plug 'https://github.com/Shougo/defx.nvim.git', {'do': ':UpdateRemotePlugins'}

" Git status implementation for https://github.com/Shougo/defx.nvim.
Plug 'https://github.com/kristijanhusak/defx-git.git'

" Filetype icons for https://github.com/Shougo/defx.nvim.
Plug 'https://github.com/kristijanhusak/defx-icons.git'

" Adds file type icons to Vim plugins such as: NERDTree, vim-airline, CtrlP,
" unite, Denite, lightline, vim-startify and many more.
" Plug 'https://github.com/ryanoasis/vim-devicons.git'

" Vim plugin for clang-format, a formatter for C, C++, Obj-C, Java,
" JavaScript, TypeScript and ProtoBuf.
" Plug 'https://github.com/rhysd/vim-clang-format.git'

" A Vim plugin for visually displaying indent levels in code.
" Plug 'https://github.com/nathanaelkane/vim-indent-guides.git'

" Display all accessible marks and their surrounding lines in a collapsible
" sidebar.
" Plug 'https://github.com/Yilin-Yang/vim-markbar.git'

" Nvim Treesitter configurations and abstraction layer.
Plug 'https://github.com/nvim-treesitter/nvim-treesitter.git', {'do': ':TSUpdate'}

" plenary: full; complete; entire; absolute; unqualified. All the lua functions
" I don't want to write twice.
Plug 'https://github.com/nvim-lua/plenary.nvim'

" Find, Filter, Preview, Pick. All lua, all the time.
Plug 'https://github.com/nvim-telescope/telescope.nvim'

" A fancy, configurable, notification manager for NeoVim.
" Plug 'https://github.com/rcarriga/nvim-notify'

" Single tabpage interface for easily cycling through diffs for all modified 
" files for any git rev.
Plug 'https://github.com/sindrets/diffview.nvim.git'

" Neovim plugin to improve the default vim.ui interfaces
" Plug 'https://github.com/stevearc/dressing.nvim.git'

" Plugin to improve viewing Markdown files in Neovim
Plug 'https://github.com/MeanderingProgrammer/render-markdown.nvim.git'

" Provides Nerd Font icons (glyphs) for use by neovim plugins
Plug 'https://github.com/nvim-tree/nvim-web-devicons.git'

" UI Component Library for Neovim.
Plug 'https://github.com/MunifTanjim/nui.nvim.git'

" Use your Neovim like using Cursor AI IDE!
Plug 'https://github.com/yetone/avante.nvim.git', {'branch': 'main', 'do': 'make'}

call plug#end()

" call LoadBundle(s:bundledir)
