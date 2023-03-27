" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2019-11-20
" @license    GPL-2.0+

if !lib#bundle#has_loaded('ale')
    finish
endif

nmap <silent> <space>ad <Plug>(ale_detail)
nmap <silent> <space>an <Plug>(ale_next)
nmap <silent> <space>ap <Plug>(ale_previous)
