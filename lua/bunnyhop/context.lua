local bhop_log = require("bunnyhop.log")

local function traverse_editlist(entries, n_latest)
    local editlist = {}
    -- create diffs for each entry in our undotree
    local stop = 1
    if n_latest ~= nil then
        stop = #entries - (n_latest - 1)
    end
    for i = #entries, stop, -1 do
        -- grab the buffer as it is after this iteration's undo state
        local success = pcall(function()
            vim.cmd("silent undo " .. entries[i].seq)
        end)
        if not success then
            vim.notify_once(
                "Encountered a bad state in nvim's native undolist for buffer "
                    .. vim.api.nvim_buf_get_name(0)
                    .. ", showing partial results.",
                vim.log.levels.ERROR
            )
            return editlist
        end

        local buffer_after_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}
        local buffer_after = table.concat(buffer_after_lines, "\n")

        -- grab the buffer as it is after this undo state's parent
        success = pcall(function()
            vim.cmd("silent undo")
        end)
        if not success then
            vim.notify_once(
                "Encountered a bad state in nvim's native undolist for buffer "
                    .. vim.api.nvim_buf_get_name(0)
                    .. ", showing partial results.",
                vim.log.levels.ERROR
            )
            return editlist
        end
        local buffer_before_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}
        local buffer_before = table.concat(buffer_before_lines, "\n")

        -- build diff header so that delta can go ahead and syntax highlight
        local filename = vim.fn.expand("%")
        local header = filename .. "\n--- " .. filename .. "\n+++ " .. filename .. "\n"

        ---@type string
        ---@diagnostic disable-next-line: assign-type-mismatch
        local diff = vim.diff(buffer_before, buffer_after)

        -- extract edited line number
        local line_num_match = diff:match("@@ %-%d+")
        ---@type number?
        local line_num = 1
        if line_num_match ~= nil then
            line_num = tonumber(line_num_match:sub(5))
        end

        -- use the data we just created to feed into our finder later
        table.insert(editlist, {
            seq = entries[i].seq, -- save state number, used in display and to restore
            time = entries[i].time, -- save state time, used in display
            diff = header .. diff, -- the proper diff, used for preview
            bufnr = vim.api.nvim_get_current_buf(), -- for which buffer this telescope was invoked, used to restore
            line_num = line_num, -- starting line number of the diff
            line_num_prediction = -1 -- TODO: this doesn't show up in undolist
        })
    end
    return editlist
end

local M = {}

function M.build_editlist(n_latest)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local ut = vim.fn.undotree()
    local editlist = traverse_editlist(ut.entries, n_latest)

    -- BUG: `gi` (last insert location) is being killed by our method, we should save that as well
    vim.cmd("silent undo " .. ut.seq_cur)
    vim.api.nvim_win_set_cursor(0, cursor)

    return editlist
end

---Creates prompt
---@return string
function M.create_prompt()
    -- Dict keys to column name convertor
    -- index (index of the table, 1 to n)
    -- lnum -> line_num
    -- bufnr -> buffer_name
    -- col -> column
    local jumplist = vim.fn.getjumplist()[1]
    local visited_files = {}

    for _, jump_row in pairs(jumplist) do
        local buf_num = jump_row["bufnr"]
        if
            vim.fn.bufexists(buf_num) == 0
            or vim.api.nvim_buf_is_valid(buf_num) == false
        then
            goto continue
        end
        local buf_name = vim.api.nvim_buf_get_name(buf_num)
        if
            #buf_name == 0
            or buf_name:match(".") == nil
            or buf_name:match(".git") ~= nil
            or buf_name:match(vim.fn.getcwd()) == nil
        then
            goto continue
        end
        if visited_files[buf_num] == nil then
            visited_files[buf_num] = buf_name
        end
        ::continue::
    end

    local CHANGELIST_COLUMNS = { "index", "line_num", "column" }
    local CHANGELIST_MAX_SIZE = 20
    local context = ""
    for buf_num, buf_name in pairs(visited_files) do
        local file_content = ""
        local file = io.open(buf_name, "r")
        if file == nil then
            bhop_log.notify("Wasn't able to open " .. buf_name, vim.log.levels.DEBUG)
        else
            file_content = file:read("*a")
            file:close()
            if file_content == nil then
                file_content = ""
            end
        end

        local changelist_csv = ""
        local changelist = vim.fn.getchangelist(buf_num)[1]
        local changelist_start = vim.fn.max { 1, #changelist - CHANGELIST_MAX_SIZE }
        changelist = vim.fn.slice(changelist, changelist_start, #changelist)
        if #changelist == 0 then
            goto continue
        end
        for indx, change_row in pairs(changelist) do
            changelist_csv = changelist_csv
                .. indx
                .. ","
                .. change_row["lnum"]
                .. ","
                .. change_row["col"]
                .. "\n"
        end
        context = context
            .. buf_name
            .. "\n"
            .. "## Buffer content"
            .. "\n"
            .. file_content
            .. "\n"
            .. "## Change history of buffer "
            .. "\n"
            .. table.concat(CHANGELIST_COLUMNS, ",")
            .. "\n"
            .. changelist_csv
            .. "\n"
        ::continue::
    end

    local prompt = "Predict next cursor position based on the following information.\n"
        .. "ONLY output the following format:\n"
        .. '[line_num, column, "buffer_name"].\n'
        .. "'line_num' is the line number the cursor should be on next\n"
        .. "'column' is the column the cursor should be on next\n"
        .. "'buffer_name' should be the name of the file the cursor should be on next\n"
        .. "DO NOT HALLUCINATE!\n" -- for the memes
        .. "# History of Cursor Jumps\n"
        .. context

    return prompt
end
return M
