" Syntax: Comment
syntax match jsonComment "\"#.*\":.*$"
syntax match jsonComment "\"//.*\":.*$"
highlight def link jsonComment Comment
