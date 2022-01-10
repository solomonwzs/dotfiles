" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2022-01-10
" @license    MIT

if !has('nvim')
  finish
endif

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",

  sync_install = false,

  highligh = {
    enable = true,
    additional_vim_regex_highlighting = false,
    },
  }
EOF
