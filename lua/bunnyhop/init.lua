local bhop_log = require("bunnyhop.log")
local bhop_pred = require("bunnyhop.prediction")
local bhop_adapter = {
    process_api_key = function(api_key, callback) end, --luacheck: no unused args
    get_models = function(config, callback) end, --luacheck: no unused args
    complete = function(prompt, config, callback) end, --luacheck: no unused args
}

local globals = {
    DEFAULT_PREVIOUS_WIN_ID = -1,
    DEFAULT_ACTION_COUNTER = 0,
}
---@type number
globals.preview_win_id = globals.DEFAULT_PREVIOUS_WIN_ID
---@type number
globals.action_counter = globals.DEFAULT_ACTION_COUNTER
---@type bhop.Prediction
globals.pred = vim.fn.deepcopy(bhop_pred.default_prediction)

local M = {}
-- The default config, gets overriden with user config options as needed.
---@class bhop.Opts
M.config = {
    adapter = "copilot",
    -- Model to use for chosen provider.
    -- To know what models are available for chosen adapter,
    -- run `:lua require("bunnyhop.adapters.{adapter}").get_models()`
    model = "gpt-4o-2024-08-06",
    -- Copilot doesn't use the API key, Hugging Face does.
    api_key = "",
    -- Max width the preview window will be.
    -- Here for if you want to make the preview window bigger/smaller.
    max_prev_width = 20,
}

local function close_preview_win()
    if globals.preview_win_id < 0 then
        return
    end

    vim.api.nvim_win_close(globals.preview_win_id, false)
    globals.action_counter = globals.DEFAULT_ACTION_COUNTER
    globals.preview_win_id = globals.DEFAULT_PREVIOUS_WIN_ID
end

---Opens preview window and returns the window's ID.
---@param prediction bhop.Prediction
---@param max_prev_width number
---@return integer
local function open_preview_win(prediction, max_prev_width) --luacheck: no unused args
    local buf_num = vim.fn.bufnr(prediction.file)
    if vim.fn.bufexists(buf_num) == 0 then
        bhop_log.notify(
            "Buffer number: " .. buf_num .. " doesn't exist",
            vim.log.levels.WARN
        )
        return -1
    end
    if prediction.file == "%" then
        prediction.file = vim.api.nvim_buf_get_name(0)
    end

    local preview_win_title = vim.fs.basename(prediction.file) .. " : " .. prediction.line
    local pred_line_content = vim.api.nvim_buf_get_lines(buf_num, prediction.line - 1, prediction.line, true)[1]
    local preview_win_width = vim.fn.max {
        1,
        vim.fn.min {
            max_prev_width,
            vim.fn.max {
                #pred_line_content,
                #preview_win_title,
            },
        },
    }
    local half_preview_win_width = math.floor(preview_win_width/2)
    if half_preview_win_width < prediction.column and preview_win_width < #pred_line_content then
        pred_line_content = string.sub(
            pred_line_content,
            (prediction.column - half_preview_win_width),
            -1
        )
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, { pred_line_content })
    local namespace = vim.api.nvim_create_namespace("test") -- TODO: check if removing namespace creation helps.
    local byte_col = vim.str_byteindex(pred_line_content, vim.fn.min {prediction.column - 1, half_preview_win_width})
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_buf_add_highlight(buf, namespace, "Cursor", 0, byte_col, byte_col + 1)
    local id = vim.api.nvim_open_win(buf, false, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = preview_win_width,
        height = 1,
        style = "minimal",
        border = "single",
        title = preview_win_title,
    })
    return id
end

---Empty stub for hop function
function M.hop() end

--- Initializes all the autocommands and hop function.
local function init()
    vim.api.nvim_create_autocmd({ "ModeChanged" }, {
        group = vim.api.nvim_create_augroup("PredictCursor", { clear = true }),
        pattern = "i:n",
        callback = function()
            local current_win_config = vim.api.nvim_win_get_config(0)
            if current_win_config.relative ~= "" then
                return
            end
            bhop_pred.predict(bhop_adapter, M.config, function(prediction)
                globals.pred.line = prediction.line
                globals.pred.column = prediction.column
                globals.pred.file = prediction.file

                -- Makes sure to only display the preview mode when in normal mode
                if vim.api.nvim_get_mode().mode == "n" then -- TODO: Refactor to early return
                    if globals.preview_win_id ~= globals.DEFAULT_PREVIOUS_WIN_ID then
                        close_preview_win()
                    end
                    globals.preview_win_id = open_preview_win(prediction, M.config.max_prev_width)
                end
            end)
        end,
    })
    local prev_win_augroup =
        vim.api.nvim_create_augroup("UpdateHopWindow", { clear = true })
    -- TODO: Find an autocommand event or pattern that only activates when cursor is moved inside the current buffer/in normal mode.
    -- Not when switching between different files.
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = prev_win_augroup,
        pattern = "*",
        callback = function()
            if globals.preview_win_id < 0 then
                return
            end
            if globals.action_counter < 1 then
                vim.api.nvim_win_set_config(
                    globals.preview_win_id,
                    { relative = "cursor", row = 1, col = 0 }
                )
                globals.action_counter = globals.action_counter + 1
            else
                close_preview_win()
            end
        end,
    })
    vim.api.nvim_create_autocmd({"BufLeave", "InsertEnter"}, {
        group = prev_win_augroup,
        pattern = "*",
        callback = close_preview_win
    })
    function M.hop()
        bhop_pred.hop(globals.pred)
        close_preview_win()
    end
end

---Setup function
---@param opts? bhop.Opts
function M.setup(opts)
    ---@diagnostic disable-next-line: param-type-mismatch
    for opt_key, opt_val in pairs(opts) do
        M.config[opt_key] = opt_val
    end

    bhop_adapter = require("bunnyhop.adapters." .. M.config.adapter)
    bhop_adapter.process_api_key(
        M.config.api_key,
        function(api_key)
            M.config.api_key = api_key
        end
    )
    local config_ok = M.config.api_key ~= nil
    -- TODO: Alert user that the config was setup incorrectly and bunnyhop was not initialized.
    if config_ok then
        init()
    else
        bhop_log.notify(
            "Error: bunnyhop config was incorrect, not initializing",
            vim.log.levels.ERROR
        )
    end
end

return M
