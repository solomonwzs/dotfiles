local M = {}

local coc_status_record = {}

local function reset_coc_status_record(_) coc_status_record = {} end

function M.coc_status_notify(msg, level)
  local notify_opts = {
    title = "LSP Status",
    timeout = 500,
    hide_from_history = true,
    on_close = reset_coc_status_record
  }
  -- if coc_status_record is not {} then add it to notify_opts to key called
  -- "replace"
  if coc_status_record ~= {} then
    notify_opts["replace"] = coc_status_record.id
  end
  coc_status_record = vim.notify(msg, level, notify_opts)
end

local coc_diag_record = {}

local function reset_coc_diag_record(_) coc_diag_record = {} end

function M.coc_diag_notify(msg, level)
  local notify_opts = {
    title = "LSP Diagnostics",
    timeout = 500,
    on_close = reset_coc_diag_record
  }
  -- if coc_diag_record is not {} then add it to notify_opts to key called
  -- "replace"
  if coc_diag_record ~= {} then
    notify_opts["replace"] = coc_diag_record.id
  end
  coc_diag_record = vim.notify(msg, level, notify_opts)
end

function M.coc_notify(msg, level)
  local notify_opts = {title = "LSP Message", timeout = 2500}
  vim.notify(msg, level, notify_opts)
end

return M
