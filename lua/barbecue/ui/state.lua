local M = {}

local VAR_WAS_AFFECTED = "barbecue_was_affected"
local VAR_LAST_WINBAR = "barbecue_last_winbar"
local VAR_ENTRIES = "barbecue_entries"

---returns `last_winbar` from `winnr`
---@param winnr number
---@return string|nil
function M.get_last_winbar(winnr)
  local last_winbar_ok, last_winbar =
    pcall(vim.api.nvim_win_get_var, winnr, VAR_LAST_WINBAR)

  return last_winbar_ok and last_winbar or nil
end

---returns `entries` from `winnr`
---@param winnr number
---@return barbecue.Entry[]|nil
function M.get_entries(winnr)
  local serialized_entries_ok, serialized_entries =
    pcall(vim.api.nvim_win_get_var, winnr, VAR_ENTRIES)
  if not serialized_entries_ok then return nil end

  return vim.json.decode(serialized_entries)
end

---clears the unneeded saved state from `winnr`
---@param winnr number
function M.clear(winnr)
  local was_affected_ok, was_affected =
    pcall(vim.api.nvim_win_get_var, winnr, VAR_WAS_AFFECTED)

  if was_affected_ok and was_affected then
    vim.api.nvim_win_del_var(winnr, VAR_WAS_AFFECTED)
  end
end

---save the current state inside `winnr`
---@param winnr number
---@param entries barbecue.Entry[]
function M.save(winnr, entries)
  local was_affected_ok, was_affected =
    pcall(vim.api.nvim_win_get_var, winnr, VAR_WAS_AFFECTED)
  if was_affected_ok and was_affected then
    pcall(vim.api.nvim_win_del_var, winnr, VAR_LAST_WINBAR)
  else
    vim.api.nvim_win_set_var(winnr, VAR_WAS_AFFECTED, true)
    vim.api.nvim_win_set_var(winnr, VAR_LAST_WINBAR, vim.wo[winnr].winbar)
  end

  local serialized_entries = vim.json.encode(vim.tbl_map(function(entry)
    local clone = vim.deepcopy(entry)
    return setmetatable(clone, nil)
  end, entries))
  vim.api.nvim_win_set_var(winnr, VAR_ENTRIES, serialized_entries)
end

return M
