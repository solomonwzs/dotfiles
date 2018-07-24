" Setting for ycm
set completeopt=menu,menuone

let g:ycm_server_python_interpreter = 'python2'
let g:ycm_global_ycm_extra_conf = g:vimhome.'/ycm/ycm_extra_conf.py'
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_show_diagnostics_ui = 0

let g:ycm_python_binary_path = '/usr/bin/python3'

let g:ycm_filetype_blacklist = {
            \}
let g:ycm_semantic_triggers = {
            \ 'c,cpp,python,java,go,perl': ['re!\w{2}'],
            \ 'cs,lua,javascript': ['re!\w{2}'],
            \ 'erlang': [':'],
            \ }
