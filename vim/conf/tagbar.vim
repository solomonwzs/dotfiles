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

let s:std_path = '$HOME/.vim'
if has('nvim')
    let s:std_path = stdpath('config')
endif

let g:md_ctags_bin = fnamemodify(s:std_path.'/tools/markdown2ctags.py', ':p')
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

let g:tagbar_type_typescript = {
    \ 'ctagstype': 'typescript',
    \ 'kinds': [
    \   'c:class',
    \   'n:namespace',
    \   'f:function',
    \   'G:generator',
    \   'v:variable',
    \   'm:method',
    \   'p:property',
    \   'i:interface',
    \   'g:enum',
    \   't:type',
    \   'a:alias',
    \ ],
    \'sro': '.',
    \ 'kind2scope' : {
    \   'c': 'class',
    \   'n': 'namespace',
    \   'i': 'interface',
    \   'f': 'function',
    \   'G': 'generator',
    \   'm': 'method',
    \   'p': 'property',
    \},
    \ }
