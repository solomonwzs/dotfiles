let g:lightline = {
        \ 'active': {
        \   'left': [
        \     [ 'mode', 'paste' ],
        \     [ 'ctrlpmark', 'git', 'diagnostic', 'cocstatus', 'filename', 'method' ]
        \   ],
        \   'right':[
        \     [ 'filetype', 'fileencoding', 'lineinfo', 'percent' ],
        \     [ 'blame', 'cocstatus' ],
        \   ],
        \ },
        \ 'component_function': {
        \   'cocstatus': 'coc#status',
        \   'blame': 'LightlineGitBlame',
        \ }
        \ }

function! MyStatusGitChanges() abort
  let gutter = get(b:, 'gitgutter', {})
  if empty(gutter) | return 'x' | endif
  let summary = gutter['summary']
  if summary[0] == 0 && summary[1] == 0 && summary[2] == 0
    return 'y'
  endif
  return '  +'.summary[0].' ~'.summary[1].' -'.summary[2].' '
endfunction

function! LightlineGitBlame() abort
  let blame = get(b:, 'coc_git_status', '')
  return winwidth(0) > 120 ? blame : ''
endfunction
