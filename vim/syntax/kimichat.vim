if exists("b:current_syntax")
  finish
endif
let b:current_syntax = "kimichat"

syntax region KcInput start="<<<<" end=">>>>"

hi def link KcInput Comment
