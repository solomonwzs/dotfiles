local status, actions = pcall(require, "telescope.actions")
if (not status) then
  return
end

require("telescope").setup {
  defaults = {mappings = {i = {["<Esc>"] = actions.close}}},
  -- pickers = {find_files = {theme = "ivy", previewer = false}},
  extensions = {
    ctags_outline = {
      ctags = {"ctags"},
      ft_opt = {vim = "--vim-kinds=fk", lua = "--lua-kinds=fk"}
    }
  }
}

vim.api.nvim_set_keymap("n", "<C-T>p", "<CMD>Telescope find_files<CR>", {})
vim.api.nvim_set_keymap("n", "<C-T>f",
                        "<CMD>Telescope ctags_outline outline<CR>", {})
vim.api.nvim_set_keymap("n", "<C-T>r", "<CMD>Telescope live_grep<CR>", {})

require("telescope").load_extension("ctags_outline")
