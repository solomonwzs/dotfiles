" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2022-07-23
" @license    MIT

function! lib#py#call(module, func, arg) abort
  let null = v:null
  let true = 1
  let false = 0
python3 << EOF
from vim_ext import call
import vim
m = vim.eval("a:module")
f = vim.eval("a:func")
a = vim.eval("a:arg")
res = call(m, f, a)
vim.command("let out = %s" % res)
EOF
  return out
endfunction
