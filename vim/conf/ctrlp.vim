" set wildignore+=*/tmp/*,*.so,*.swp
let g:ctrlp_custom_ignore = {
        \   'dir'  : '\v[\/]\.(git|hg|svn)$',
        \   'file' : '\v\.(so|swp|zip|class|beam|tar|gz|o|pyc)$'
        \}
let g:ctrlp_switch_buffer = 'e'
let g:ctrlp_regexp = 1
let g:ctrlp_reuse_window = 'netrw\|help\|quickfix'
" let g:ctrlp_user_command={
"             \ 'types'   : {
"             \ 1 : ['.git', 'cd %s && git ls-files'],
"             \ 2 : ['.hg', 'hg --cwd %s locate -I .']
"             \ },
"             \ 'fallback': 'find %s -type f'}
" let g:ctrlp_open_new_file='h'
let g:ctrlp_working_path_mode = 'rw'
if executable('ag')
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif
