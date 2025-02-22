local bhop_context = require("bunnyhop.context")

local function clip_number(num, min, max)
    if min > max or num < min then
        return min
    elseif num > max then
        return max
    end
    return num
end

local M = {}

---@class bhop.Prediction
M.default_prediction = {
    line = 1,
    column = 1,
    file = "%",
}

---Predicts the next cursor position.
---@param adapter table
---@param config bhop.Opts
---@param callback fun(prediction: bhop.Prediction)
function M.predict(adapter, config, callback)
    adapter.complete(bhop_context.create_prompt(), config, function(completion_result)
        -- Processing the given curl result
        local success, pred_str = pcall(vim.json.decode, completion_result)
        local prediction = {
            line = M.default_prediction.line,
            column = M.default_prediction.column,
            file = M.default_prediction.file,
        }
        if success == true then
            if vim.fn.filereadable(pred_str[3]) == 1 then
                prediction.file = pred_str[3]
            end
            local pred_buf_num = vim.fn.bufadd(prediction.file)
            vim.fn.bufload(pred_buf_num)

            if type(pred_str[1]) == "number" then
                prediction.line =
                    clip_number(pred_str[2], 1, vim.api.nvim_buf_line_count(pred_buf_num))
            end

            if type(pred_str[2]) == "number" then
                local pred_line_content = vim.api.nvim_buf_get_lines(pred_buf_num, prediction.line - 1, prediction.line, true)[1]
                local white_space_ammount = #pred_line_content - #pred_line_content:gsub("^%s+", "")
                prediction.column = clip_number(pred_str[2], white_space_ammount + 1, #pred_line_content - 1)
            end
        end

        callback(prediction)
    end)
end


--- Hops to the given prediction
---@param prediction bhop.Prediction
function M.hop(prediction)
    if prediction.line == -1 or prediction.column == -1 then
        return
    end

    -- Adds current position to the jumplist so you can <C-o> back to it if you don't like where you hopped.
    vim.cmd("normal! m'")
    local buf_num = vim.fn.bufnr(prediction.file, true)
    vim.fn.bufload(buf_num)
    vim.api.nvim_set_current_buf(buf_num)
    vim.api.nvim_win_set_cursor(0, { prediction.line, prediction.column - 1 })
end

return M
