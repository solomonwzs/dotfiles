function! lib#debug#foo()
python << EOF
from project.project import find_cxx_header_files_dir
import vim
print(find_cxx_header_files_dir())
# d = vim.bindeval("g:ycm_semantic_triggers")
# d.update({'foo': 'bar'})
EOF
echo g:ycm_semantic_triggers
endfunction
