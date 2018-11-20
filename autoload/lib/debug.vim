function! lib#debug#foo()
python << EOF
from project.project import find_cxx_header_files_dir, find
import vim

# print(vim.current.line)
# print(find_cxx_header_files_dir())
# print(find('compile_commands.json', '.'))
# d = vim.bindeval("g:ycm_semantic_triggers")
# d.update({'foo': 'bar'})
EOF

" echo g:ycm_semantic_triggers
endfunction
