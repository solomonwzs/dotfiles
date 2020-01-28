" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2019-09-19
" @license    MIT

if !lib#bundle#has_loaded('tabular') || !exists(':Tabularize')
    finish
endif

let s:save_cpo = &cpoptions
set cpoptions&vim

AddTabularPipeline! single_space / \{1,}/
        \ map(a:lines, "substitute(v:val, ' \{1,}', ' ', 'g')") |
        \ tabular#TabularizeStrings(a:lines, ' ', 'l0')

" AddTabularPipeline multiple_spaces / \{2,}/
"         \ map(a:lines, "substitute(v:val, ' \{2,}', '  ', 'g')") |
"         \ tabular#TabularizeStrings(a:lines, '  ', 'l0')

AddTabularPipeline! remove_leading_spaces /^ /
        \ map(a:lines, "substitute(v:val, '^ *', '', '')")

AddTabularPipeline! remove_c_comment_unnecessary_spaces /\/\/ /
        \ map(a:lines, "substitute(v:val, '\/\/ *', '\/\/ ', '')")

AddTabularPipeline! fmt_c_struct /[^ ]*;/
        \ map(a:lines, "substitute(v:val, '\/\/ *', '\/\/ ', '')") |
        \ tabular#TabularizeStrings(a:lines, '[^ ]*;', 'l1')

let &cpoptions = s:save_cpo
unlet s:save_cpo
