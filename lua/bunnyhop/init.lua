local M = {}

---@class bhop.opts
M.defaults = {
    ---@type string
    api_key = "",
}

-- TODO: Remove all the ".git/..." jumps from the jumplist
local function _create_prompt()
    -- Dict keys to column name convertor
    -- index (index of the table, 1 to n)
    -- lnum -> line_num
    -- bufnr -> buffer_name
    -- col -> column
    local JUMPLIST_COLUMNS = { "index", "line_num", "column", "buffer_name" }
    local jumplist = vim.fn.getjumplist()[1]
    local csv_jumplist = table.concat(JUMPLIST_COLUMNS, ",") .. "\n"

    for indx, jump_row in pairs(jumplist) do
        csv_jumplist = csv_jumplist
            .. indx
            .. ","
            .. jump_row["lnum"]
            .. ","
            .. jump_row["col"]
            .. ","
            .. vim.api.nvim_buf_get_name(jump_row["bufnr"])
            .. "\n"
    end

    local prompt = "Predict next cursor position based on the following information.\n"
        .. 'ONLY output the row and column of the cursor in the format [line_num, column, "buffer_name"].\n'
        .. "DO NOT HALLUCINATE!\n"
        .. "# History of Cursor Jumps\n"
        .. csv_jumplist

    -- TODO: add the change list for each file in the jump list.
    -- local changelist = vim.api.getchangelist()
    return prompt
end

function M.predict()
    local hf_url =
        "https://api-inference.huggingface.co/models/Qwen/Qwen2.5-Coder-32B-Instruct/v1/chat/completions"
    local prompt = _create_prompt()
    local request_body = vim.json.encode {
        ["model"] = "Qwen/Qwen2.5-Coder-32B-Instruct",
        ["messages"] = { { ["role"] = "user", ["content"] = prompt } },
        ["max_tokens"] = 30,
        ["stream"] = false,
    }
    local response = vim.system {
        "curl",
        -- "-s",
        "-H", "Authorization: Bearer " .. M.config.api_key,
        "-H", "Content-Type: application/json",
        "-d", request_body,
        hf_url,
    }:wait()
    if response.code ~= 0 then
        vim.notify(response.stderr, vim.log.levels.ERROR)
        return
    end

    local json_response = vim.json.decode(response.stdout)
    local prediction = vim.json.decode(json_response.choices[1].message.content)
    vim.cmd("edit " .. prediction[3])
    vim.api.nvim_win_set_cursor(0, { prediction[1], prediction[2] - 1 })
end

-- TODO: Move jump logic to here and make predict into an Autocommand that activate everytime the person enters normal mode.
function M.jump() end

---Setup function
---@param opts? bhop.opts
function M.setup(opts)
    if opts == nil then
        M.config = M.defaults
    else
        M.config = opts
    end

    if #M.config.api_key == 0 then
        vim.notify(
            "API key wasn't given, please set the api_key in the opts table to an enviornment variable name.",
            vim.log.levels.ERROR
        )
    elseif M.config.api_key:match("[a-z]+") ~= nil then
        vim.notify(
            "Given API key is not a name of an enviornment variable.",
            vim.log.levels.ERROR
        )
    else
        local api_key = os.getenv(M.config.api_key)
        if api_key then
            M.config.api_key = api_key
        else
            vim.notify(
                "Wasn't able to get API key from the enviornment.",
                vim.log.levels.ERROR
            )
        end
    end
end

return M
