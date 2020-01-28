" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2020-01-29
" @license    MIT

let g:clang_format#detect_style_file = 1

let s:format_default_style_options = {
        \ 'AlignConsecutiveMacros'           : 'true',
        \ 'AlignEscapedNewlines'             : 'Left',
        \ 'AllowShortFunctionsOnASingleLine' : 'Inline',
        \ 'BasedOnStyle'                     : 'Google',
        \ 'Standard'                         : 'C++11',
        \ }

let s:format_proto_style_options = {
        \ 'AlignConsecutiveAssignments'      : 'true',
        \ 'AlignConsecutiveDeclarations'     : 'true',
        \ 'AlignEscapedNewlines'             : 'Left',
        \ }

let g:clang_format#style_options = s:format_default_style_options

function! s:format_code(line1, line2, ...) abort
    let tmp = g:clang_format#detect_style_file
    let tmp_style = g:clang_format#style_options

    let g:clang_format#detect_style_file = 0
    let opts = get(s:, 'format_'.&filetype.'_style_options',
            \ s:format_default_style_options)
    let g:clang_format#style_options = opts
    call clang_format#replace(a:line1, a:line2)

    let g:clang_format#detect_style_file = tmp
    let g:clang_format#style_options = tmp_style
endfunction

command! -range=% -nargs=0 XClangFormat call s:format_code(<line1>, <line2>)
