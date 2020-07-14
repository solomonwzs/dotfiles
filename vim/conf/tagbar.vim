let g:rust_use_custom_ctags_defs = 1
let g:tagbar_type_rust = {
        \ 'ctagstype': 'rust',
        \ 'kinds': [
        \   'T:types,type definitions',
        \   'f:functions',
        \   'g:enum,enumeration names',
        \   's:structure names',
        \   'n:modules,module names',
        \   'c:consts,static constants',
        \   't:traits',
        \   'i:impls,trait implementations',
        \   'm:fields',
        \   'P:-',
        \ ],
        \ 'sro': '::',
        \ }

let g:tagbar_type_go = {
        \ 'ctagstype': 'go',
        \ 'kinds': [
        \   'p:package',
        \   'i:imports:1',
        \   'c:constants',
        \   'v:variables',
        \   't:types',
        \   'n:interfaces',
        \   'w:fields',
        \   'e:embedded',
        \   'm:methods',
        \   'r:constructor',
        \   'f:functions'
        \ ],
        \ 'sro': '.',
        \ 'kind2scope': {
        \   't': 'ctype',
        \   'n': 'ntype'
        \ },
        \ 'scope2kind': {
        \   'ctype': 't',
        \   'ntype': 'n'
        \ },
        \ 'ctagsbin': 'gotags',
        \ 'ctagsargs': '-sort -silent',
        \ }

let g:md_ctags_bin = fnamemodify(stdpath('config').'/tools/markdown2ctags.py', ':p')
let g:tagbar_type_markdown = {
        \ 'ctagstype': 'markdown.pandoc',
        \ 'ctagsbin': g:md_ctags_bin,
        \ 'ctagsargs': '-f - --sort=yes',
        \ 'kinds': [
        \   's:sections',
        \   'i:images'
        \ ],
        \ 'sro': '|',
        \ 'kind2scope': {
        \   's': 'section',
        \ },
        \ 'sort': 0,
        \ }
