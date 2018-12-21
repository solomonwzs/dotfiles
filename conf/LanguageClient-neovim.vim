" Install rls:
"   rustup component add rls-preview rust-analysis rust-src
let g:LanguageClient_serverCommands = {
            \ 'rust': ['rustup', 'run', 'rls'],
            \ }
