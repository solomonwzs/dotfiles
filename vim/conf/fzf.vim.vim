let g:fzf_action = {
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-x': 'split',
        \ 'ctrl-]': 'vsplit',
        \ }

let g:fzf_layout = { 'down': '~20%' }
let g:fzf_preview_window = 'right:50%'
let g:fzf_command_prefix = 'Fzf'

cnoreabbrev <expr> Rg ((getcmdtype() is# ':' && getcmdline() is# 'Rg') ? ('FzfRg') : ('Rg'))

noremap <C-F>p :FzfFiles .<CR>
noremap <C-F>b :FzfBuffers<CR>

noremap <silent> <C-F>gs :<C-U><C-R>=printf("FzfRg %s", expand('<cword>'))<CR><CR>
vnoremap <silent> <C-F>gs :<C-U><C-R>=printf("FzfRg %s", lib#common#visual_selection(1))<CR><CR>
