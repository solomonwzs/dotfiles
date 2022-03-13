local status, actions = pcall(require, "telescope.actions")
if (not status) then return end

require('telescope').setup {
  defaults = {mappings = {i = {['<Esc>'] = actions.close}}},
  -- pickers = {find_files = {theme = "dropdown", previewer = false}},
  extensions = {}
}

vim.api.nvim_set_keymap('n', '<C-P>p', '<CMD>Telescope find_files<CR>', {})
vim.api.nvim_set_keymap('n', '<C-P>f', '<CMD>Telescope treesitter<CR>', {})
