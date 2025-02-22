local M = {}

---Custom notification function for bunnyhop.
---This function adds the bunnyhop.nvim title to all notifications made with it.
---@param msg string Notification message to send. Gets passed right to `vim.notify`.
---@param level integer? Log level to give notification from `vim.log.levels`. Gets passed right to `vim.notify`.
---@param opts table? Option table that gets passed right into `vim.notify`.
function M.notify(msg, level, opts)
    if opts == nil then
        opts = {}
    end
    opts["title"] = "bunnyhop.nvim"
    vim.notify(msg, level, opts)
end

return M
