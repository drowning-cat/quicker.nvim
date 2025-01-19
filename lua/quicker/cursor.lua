local M = {}

local function constrain_cursor()
  local display = require("quicker.display")
  local cur = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_buf_get_lines(0, cur[1] - 1, cur[1], true)[1]
  local idx = line:find(display.EM_QUAD, 1, true)
  if not idx then
    return
  end
  local min_col = idx + display.EM_QUAD_LEN - 1
  if cur[2] < min_col then
    vim.api.nvim_win_set_cursor(0, { cur[1], min_col })
  end
end

M.l_constrain_cursor = constrain_cursor

---Utility that checks if event(-s) is already defined
---@param aug integer|string
---@param bufnr integer|integer[]
---@param ... string|string[]
local event_defined = function(aug, bufnr, ...)
  return #vim.api.nvim_get_autocmds({
    group = aug,
    buffer = bufnr,
    event = { ... },
  }) > 0
end

---@param bufnr number
function M.constrain_cursor(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local aug = vim.api.nvim_create_augroup("quicker", { clear = false })
  if event_defined(aug, bufnr, "InsertEnter", "CursorMoved", "ModeChanged") then
    return
  end
  vim.api.nvim_create_autocmd("InsertEnter", {
    desc = "Constrain quickfix cursor position",
    group = aug,
    nested = true,
    buffer = bufnr,
    callback = function()
      constrain_cursor()
    end,
  })
  vim.api.nvim_create_autocmd({ "CursorMoved", "ModeChanged" }, {
    desc = "Constrain quickfix cursor position",
    nested = true,
    group = aug,
    buffer = bufnr,
    callback = function()
      constrain_cursor()
    end,
  })
end

return M
