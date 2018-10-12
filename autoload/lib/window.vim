" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2018-10-10
" @license    MIT


function! s:setStatusLine(stl)
    let a:bufnr = bufnr('%')
    for a:n in range(1, winnr('$'))
        if winbufnr(a:n) == a:bufnr
            call setwinvar(a:n, '&statusline', a:stl)
        endif
    endfor
endfunc


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

    silent! exec printf('noa keepa keepj %s sp %s', a:position, a:bufname)
    silent! exec printf('resize %s', a:lines)
    silent! exec printf('setlocal filetype=%s', a:winname)

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

    let a:stl = printf('%!airline#statusline(%s)', winnr())
    exec printf('augroup Lib_win_%s_Colorscheme', a:bufname)
    exec printf('au ColorScheme * call s:setStatusLine(%s)', a:stl)
    exec printf('au WinEnter,FileType * call s:setStatusLine(%s)', a:stl)
    exec printf('augroup END')
endfunc


function! lib#window#test()
python3 << EOF
argv = {'position': 'top'}
vim.command(f"call lib#window#new({argv})")
EOF
endfunc
