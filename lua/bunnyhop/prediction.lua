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

---@return bhop.Prediction
function M.create_default_prediction()
    return {
        line = 1,
        column = 1,
        file = vim.api.nvim_buf_get_name(0),
    }
end

---Predicts the next cursor position.
---@param adapter table
---@param config bhop.Opts
---@param callback fun(prediction: bhop.Prediction)
function M.predict(adapter, config, callback)
    adapter.complete(bhop_context.create_prompt(), config, function(completion_result)
        local prediction = M.create_default_prediction()
        local json_match = completion_result:match('%[%d+, %d+, "[%w/\\.-_]+"%]')
        if json_match ~= nil then
            local prediction_json = vim.json.decode(json_match)
            if vim.fn.filereadable(prediction_json[3]) == 1 then
                prediction.file = prediction_json[3]
            end
            local pred_buf_num = vim.fn.bufadd(prediction.file)
            vim.fn.bufload(pred_buf_num)

            if type(prediction_json[1]) == "number" then
                prediction.line =
                    clip_number(prediction_json[2], 1, vim.api.nvim_buf_line_count(pred_buf_num))
            end

            if type(prediction_json[2]) == "number" then
                local pred_line_content = vim.api.nvim_buf_get_lines(pred_buf_num, prediction.line - 1, prediction.line, true)[1]
                local white_space_ammount = #pred_line_content - #pred_line_content:gsub("^%s+", "")
                prediction.column = clip_number(prediction_json[2], white_space_ammount + 1, #pred_line_content - 1)
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
