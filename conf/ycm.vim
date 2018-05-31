" Setting for ycm
let g:ycm_server_python_interpreter = "python2"
let g:ycm_global_ycm_extra_conf = '/usr/share/vim/vimfiles/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
let g:ycm_min_num_identifier_candidate_chars = 2
set completeopt=menu,menuone
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_show_diagnostics_ui = 0
" let g:ycm_filetype_whitelist = {
"             \ "c":1,
"             \ "cpp":1,
"             \ "objc":1,
"             \ "python":1,
"             \ "go":1,
"             \ "sh":1,
"             \ "zsh":1,
"             \ "zimbu":1,
"             \ "erlang":1,
"             \ "lua":1,
"             \ "rust":1,
"             \ }
let g:ycm_semantic_triggers = {
            \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
            \ 'cs,lua,javascript': ['re!\w{2}'],
            \ }
