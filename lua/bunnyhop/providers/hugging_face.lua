local bhop_log = require("bunnyhop.log")
local M = {}

---Gets the available models to use.
---@param config bhop.config User config. Used to get the api_key for now, mabye more things later.
---@param callback function Function that gets called after the request is made.
function M.get_models(config, callback) --luacheck: no unused args
    callback({ "Qwen/Qwen2.5-Coder-32B-Instruct" })
end

---Completes the given prompt.
---@param prompt string Input prompt.
---@param config bhop.config User config. Used to get the api_key for now, mabye more things later.
---@param callback function Function that gets called after the request is made.
---@return nil
function M.complete(prompt, config, callback)
    local hf_url =
        "https://api-inference.huggingface.co/models/" .. config.model .. "/v1/chat/completions"
    local request_body = vim.json.encode {
        model = config.model,
        messages = { { role = "user", content = prompt } },
        max_tokens = 30,
        stream = false,
    }
    vim.system({
        "curl",
        "-H",
        "Authorization: Bearer " .. config.api_key,
        "-H",
        "Content-Type: application/json",
        "-d",
        request_body,
        hf_url,
    }, {}, function(result)
        vim.schedule(function()
            if result.code ~= 0 then
                bhop_log.notify(result.stderr, vim.log.levels.ERROR)
                callback("")
                return
            end
            local response = vim.json.decode(result.stdout)
            if response.error ~= nil then
                bhop_log.notify("Hugging Face Error: '" .. response.error .. "'", vim.log.levels.ERROR)
                callback("")
                return
            end
            callback(response.choices[1].message.content)
        end)
    end)
end

return M
