function Get_collect_tokens(code)
    local tokens = {}
    local func_patterns =
    "%s*([%a_][%w_]*)%s+([%a_][%w_]*)%s*%b()%s*{([^}]*)}" -- Matches function declarations
    local typedef_pattern =
    "%s*typedef%s+([%a_][%w_%s]*)%s+([%a_][%w_]*)%s*;"    -- Matches typedefs
    local struct_pattern =
    "%s*struct%s+([%a_][%w_]*)%s*{([^}]*)};"              -- Matches struct declarations

    -- Capture functions
    for return_type, name in string.gmatch(code, func_patterns) do
        table.insert(tokens, name)
    end

    -- Capture typedefs
    for type, name in string.gmatch(code, typedef_pattern) do
        table.insert(tokens, name)
    end

    -- Capture structs
    for name, fields in string.gmatch(code, struct_pattern) do
        table.insert(tokens, name)
    end

    return tokens
end

---@param path string
---@return Token[]
function Collect_tokens(path)
    local content = dtw.load_file(path)
    local captured_tokens = Get_collect_tokens(content)
    -- Create an array of token objects
    local tokens = {}
    for i = 1, #captured_tokens do
        local created = {
            value = captured_tokens[i]
        }
        table.insert(tokens, created) -- Use table.insert here
    end
    return tokens
end
