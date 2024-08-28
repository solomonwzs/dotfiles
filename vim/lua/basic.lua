local api = vim.api

local M = {}

local x = 0

function M.foo()
  api.nvim_echo({{tostring(x), ""}}, false, {})
  x = 1
end

return M
