" Install rls:
"   rustup component add rls-preview rust-analysis rust-src
let g:LanguageClient_serverCommands = {
        \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
        \ }
let g:LanguageClient_hoverPreview = 'Never'

nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
