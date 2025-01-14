local M = {}

---moves the cursor to `to.win` and puts it on `to.pos`
---@param to barbecue.Entry.to
function M.navigate(to)
  vim.api.nvim_set_current_win(to.win)
  vim.api.nvim_win_set_cursor(to.win, to.pos)
end

setmetatable(M, {
  __index = function(self, key)
    if type(key) ~= "string" then return nil end

    local parts = vim.split(key, "_")
    if #parts == 4 and parts[1] == "navigate" then
      local win = tonumber(parts[2])
      local pos = { tonumber(parts[3]), tonumber(parts[4]) }

      return function(_, _, button)
        if button ~= "l" then return end
        self.navigate({ win = win, pos = pos })
      end
    end

    return nil
  end,
})

return M
