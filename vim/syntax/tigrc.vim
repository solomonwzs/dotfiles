if exists("b:current_syntax")
  finish
endif
let b:current_syntax = "tigrc"

let groups = lib#color#xcterm256_color()

syn match TigComment "\v#.*"

syn match TigColor "\v^color\s+" contains=TigKeyword nextgroup=TigColorArea
syn match TigColorArea "\v(\w|-|\.)*\s+" contained nextgroup=TigColorFg
exec 'syn match TigColorFg "\v(default|(\d*))\s+" contained contains=TigKeyword,@'
    \ .groups[0].' nextgroup=TigColorBg'
exec 'syn match TigColorBg "\v(default|(\d*))" contained contains=TigKeyword,@'
    \ .groups[1].' nextgroup=TigColorAttribute'
syn match TigColorAttribute "\v\s+(\w)*" contains=TigAttribute

syn match TigSet "\vset\s+" contains=TigKeyword nextgroup=TigSetVariable
syn match TigSetVariable "\v(\w|-|\.)*\s*\="he=e-1 contained nextgroup=TigSetValue
syn match TigSetValue "\v.*" contained

syn match TigBind "\vbind\s+" contains=TigKeyword nextgroup=TigBindKeyMap
syn match TigBindKeyMap "\v(\w|-|\.)*\s+" contained nextgroup=TigBindKey
syn match TigBindKey "\v[^ ]+" contained nextgroup=TigBindAction
syn match TigBindAction "\v.*" contained

syn match TigSource "\vsource" contains=TigKeyword nextgroup=TigSourcePath
syn match TigSourcePath "\v.*" contained

syn keyword TigKeyword bind contained
syn keyword TigKeyword color contained
syn keyword TigKeyword default contained
syn keyword TigKeyword set contained
syn keyword TigKeyword source contained

syn keyword TigAttribute blink contained
syn keyword TigAttribute bold contained
syn keyword TigAttribute dim contained
syn keyword TigAttribute normal contained
syn keyword TigAttribute reverse contained
syn keyword TigAttribute standout contained
syn keyword TigAttribute underline contained

hi def link TigAttribute Identifier
hi def link TigBindAction String
hi def link TigBindKey Character
hi def link TigBindKeyMap Identifier
hi def link TigColorArea Identifier
hi def link TigComment Comment
hi def link TigKeyword Keyword
hi def link TigSetValue String
hi def link TigSetVariable Identifier
hi def link TigSourcePath String
