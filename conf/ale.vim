" let g:ale_linters_explicit = 1
let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_lint_delay = 500
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:airline#extensions#ale#enabled = 1

let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++14'
let g:ale_c_cppcheck_options = ''
let g:ale_cpp_cppcheck_options = ''

" let g:ale_sign_error = "X"
" let g:ale_sign_warning = "!"
let g:ale_sign_error = "✖"
let g:ale_sign_warning = "⚠"

hi! clear SpellBad
hi! clear SpellCap
hi! clear SpellRare
hi! SpellBad gui=undercurl guisp=red
hi! SpellCap gui=undercurl guisp=blue
hi! SpellRare gui=undercurl guisp=magenta

let g:ale_python_pylint_executable = 'pylint'
" pylint --generate-rcfile > ~/.pylintrc
let g:ale_python_pylint_options = '--rcfile ~/.pylintrc'

let g:ale_rust_cargo_use_check = 1

let g:ale_linters = {
            \ 'python': ['flake8'],
            \ 'rust': ['cargo'],
            \ 'sh': ['shellcheck'],
            \ 'vim': ['vint'],
            \}

let g:ale_pattern_options = {
            \ '.*\.erl$': {'ale_enabled': 0},
            \}
