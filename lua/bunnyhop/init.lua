local bhop_log = require("bunnyhop.log")
local bhop_prediction = require("bunnyhop.prediction")
local bhop_context = require("bunnyhop.context")
local bhop_jsona = require("bunnyhop.jsona")

local _bhop_adapter = {
    process_api_key = function(api_key, callback) end, --luacheck: no unused args
    get_models = function(config, callback) end, --luacheck: no unused args
    complete = function(prompt, config, callback) end, --luacheck: no unused args
}

---@type table<string, bhop.UndoEntry[]>
local _editlists = {}
---@type number
local _DEFAULT_PREVIOUS_WIN_ID = -1
---@type number
local _DEFAULT_ACTION_COUNTER = 0
---@type number
local _preview_win_id = _DEFAULT_PREVIOUS_WIN_ID
---@type number
local _action_counter = _DEFAULT_ACTION_COUNTER
---@type bhop.Prediction
local _prediction = bhop_prediction.create_default_prediction()
---@type string
local _edit_dir_path = vim.fn.stdpath("data") .. "/bunnyhop/edit_predictions/"

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
    if _preview_win_id < 0 then
        return
    end

    vim.api.nvim_win_close(_preview_win_id, false)
    _action_counter = _DEFAULT_ACTION_COUNTER
    _preview_win_id = _DEFAULT_PREVIOUS_WIN_ID
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
    local prediction_file = prediction.file

    local preview_win_title = vim.fs.basename(prediction_file) .. " : " .. prediction.line
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
    local byte_col = vim.str_byteindex(pred_line_content, vim.fn.min {prediction.column - 1, half_preview_win_width})
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_buf_add_highlight(buf, 0, "Cursor", 0, byte_col, byte_col + 1)
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

local function get_editlist_file_path(file_path)
    return _edit_dir_path .. file_path:sub(2):gsub("/", "|") .. ".jsona"
end

---Returns the lastest n elements in a list.
---@param list table
---@param n number
---@return table
local function latest_n(list, n)
    local list_latest_n = {}
    for edit_indx = #list - n, #list do
        table.insert(list_latest_n, list[edit_indx])
    end
    return list_latest_n
end

---Empty stub for hop function
function M.hop() end

--- Initializes all the autocommands and hop function.
local function init()
    -- Functions initialization
    function M.hop()
        bhop_prediction.hop(_prediction)
        close_preview_win()
    end

    --- Autocommands initialization
    vim.api.nvim_create_autocmd({ "ModeChanged" }, {
        group = vim.api.nvim_create_augroup("PredictCursor", { clear = true }),
        pattern = "i:n",
        callback = function()
            local current_win_config = vim.api.nvim_win_get_config(0)
            if current_win_config.relative ~= "" then
                return
            end
            bhop_prediction.predict(_bhop_adapter, M.config, function(prediction)
                if vim.api.nvim_get_mode().mode ~= "n" then return end

                if _preview_win_id ~= _DEFAULT_PREVIOUS_WIN_ID then
                    close_preview_win()
                end
                _prediction.line = prediction.line
                _prediction.column = prediction.column
                _prediction.file = prediction.file
                _preview_win_id = open_preview_win(prediction, M.config.max_prev_width)

                -- Data collection
                local latest_edit = bhop_context.build_editlist(1)[1]
                if latest_edit == nil then
                    return
                end
                latest_edit["prediction_line"] = prediction.line
                latest_edit["prediction_file"] = prediction.file
                latest_edit["model"] = M.config.model
                bhop_jsona.append(get_editlist_file_path(prediction.file), {latest_edit})
                -- TODO: This if statement is a patch, find the root cause and fix it.
                if _editlists[prediction.file] == nil then
                    return
                end
                table.insert(_editlists[prediction.file], latest_edit)
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
            if _preview_win_id < 0 then
                return
            end
            if _action_counter < 1 then
                vim.api.nvim_win_set_config(
                    _preview_win_id,
                    { relative = "cursor", row = 1, col = 0 }
                )
                _action_counter = _action_counter + 1
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
    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("GetEditlist", {clear = true}),
        pattern = "*",
        callback = function()
            local buffer_name = vim.api.nvim_buf_get_name(0)
            local valid_file_name = buffer_name:match("^.+/([%w_-]+)%.([%w]+)$")
            if valid_file_name == nil then
                return
            end

            vim.fn.mkdir(_edit_dir_path, "p")
            local edit_file_path = get_editlist_file_path(buffer_name)
            local file_exists = vim.fn.filereadable(edit_file_path) == 1
            if file_exists then
                local content = bhop_jsona.read(edit_file_path)
                _editlists[buffer_name] = latest_n(content, 40)
                return
            end
            local editlist = bhop_context.build_editlist()
            bhop_jsona.append(edit_file_path, editlist)
            _editlists[buffer_name] = latest_n(editlist, 40)
        end
    })
end

---Setup function
---@param opts? bhop.Opts
function M.setup(opts)
    ---@diagnostic disable-next-line: param-type-mismatch
    for opt_key, opt_val in pairs(opts) do
        M.config[opt_key] = opt_val
    end

    _bhop_adapter = require("bunnyhop.adapters." .. M.config.adapter)
    _bhop_adapter.process_api_key(
        M.config.api_key,
        function(api_key)
            M.config.api_key = api_key
        end
    )
    local config_ok = M.config.api_key ~= nil
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
