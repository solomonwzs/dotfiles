let g:tagbar_type_rust = {
            \ 'ctagstype': 'rust',
            \ 'kinds': [
            \   'T:types,type definitions',
            \   'f:functions,function definitions',
            \   'g:enum,enumeration names',
            \   's:structure names',
            \   'm:modules,module names',
            \   'c:consts,static constants',
            \   't:traits',
            \   'i:impls,trait implementations',
            \ ],
            \ 'ctagsargs': [
            \   '-f', '-',
            \   '--format=2',
            \   '--excmd=pattern',
            \   '--fields=nksSaf',
            \   '--extra=',
            \   '--file-scope=yes',
            \   '--sort=no',
            \   '--append=no',
            \ ],
            \ }
