" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2018-10-10
" @license    MIT


function! lib#window#new(argv)
    let a:position = get(a:argv, 'position', 'bottom')
    let a:size = get(a:argv, 'size', 0.3)
    let a:bufname = get(a:argv, 'bufname', 'undefined')
    let a:winname = get(a:argv, 'winname', 'undefined')

    if a:size >= 1
        let a:lines = a:size
    elseif a:size > 0
        let a:lines = &lines * a:size
    else
        return
    endif

    silent! exec 'noa keepa keepj '.a:position.' sp '.a:bufname
    silent! exec 'resize '.float2nr(a:lines)
    silent! exec 'setlocal filetype='.a:winname

    setlocal bufhidden=hide
    setlocal buftype=nofile
    setlocal cursorline
    setlocal foldcolumn=0
    setlocal foldmethod=manual
    setlocal nobuflisted
    setlocal nofoldenable
    setlocal nolist
    setlocal norelativenumber
    setlocal nospell
    setlocal noswapfile
    setlocal number
    setlocal shiftwidth=4
    setlocal undolevels=-1
    setlocal wrap

    redrawstatus
endfunc


function! lib#window#test()
python3 << EOF
argv = {'position': 'top'}
vim.command(f"call lib#window#new({argv})")
EOF
endfunc
