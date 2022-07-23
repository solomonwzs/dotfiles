scriptencoding utf-8

" let g:ale_linters_explicit = 1
let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_lint_delay = 500
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:airline#extensions#ale#enabled = 1

let g:ale_c_cc_options = '-Wall -O2 -std=gnu99 -I./include'
let g:ale_cpp_cc_options = '-Wall -O2 -std=c++14 -I./include'

let g:ale_c_parse_compile_commands = 1

let g:ale_sign_error = ''
let g:ale_sign_warning = ''

" genrate rc-file:
"   pylint --generate-rcfile > ~/.pylintrc
"
" let g:ale_python_pylint_executable = 'pylint'
" let g:ale_python_pylint_options = '--rcfile ~/.pylintrc

let g:ale_cpp_cpplint_options = '--filter=-legal/copyright,-build/header_guard,-runtime/references,-runtime/string'

let g:ale_python_flake8_options = '--ignore=E402,E241,E501,E302,E265,W503'

let g:ale_javascript_eslint_options = "--rule 'prettier/prettier:0'"

let g:ale_rust_cargo_use_check = 1
let g:ale_rust_cargo_check_tests = 1

let g:ale_fixers = {
        \ '*':          ['remove_trailing_lines', 'trim_whitespace'],
        \ 'javascript': ['eslint'],
        \ 'rust':       ['rustfmt'],
        \ }

let g:ale_linters = {
        \ 'c':      ['gcc'],
        \ 'cpp':    ['g++', 'cpplint'],
        \ 'python': ['flake8'],
        \ 'rust':   ['cargo'],
        \ 'sh':     ['shellcheck'],
        \ 'vim':    ['vint'],
        \ }

let g:ale_pattern_options = {
        \ '.*\.erl$': {'ale_enabled': 0},
        \ '.*\.json$': {'ale_enabled': 0},
        \ '.*\.cpp$': {'ale_enabled': 0},
        \ '.*\.hpp$': {'ale_enabled': 0},
        \ '.*\.c$': {'ale_enabled': 0},
        \ '.*\.h$': {'ale_enabled': 0},
        \ '.*\.ts$': {'ale_enabled': 0},
        \ '.*\.js$': {'ale_enabled': 0},
        \ }

let s:copts = lib#py#call('project', "get_cxx_gcc_options", v:null)
if s:copts.error == 0
  if has_key(s:copts.data, 'ale_c_cc_options')
    let g:ale_c_cc_options = s:copts.data.ale_c_cc_options
  endif
  if has_key(s:copts.data, 'ale_cpp_cc_options')
    let g:ale_cpp_cc_options = s:copts.data.ale_cpp_cc_options
  endif
endif
