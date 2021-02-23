let kk = 321

function! lib#debug#foo(arg)
python3 << EOF
from project.project import get_makefile_variable
import vim

# print(vim.current.line)
# print(find_cxx_header_files_dir())
# print(find('compile_commands.json', '.'))
# d = vim.bindeval("g:ycm_semantic_triggers")
# d.update({'foo': 'bar'})

d = vim.vars
d['foo'] = 'xx'
vim.command("let kk = 123")
EOF

echo g:foo
endfunction

function! lib#debug#bar()
  echo 'hello'
endfunction
