function Get_collect_tokens(code)
    local tokens = {}

    -- Patterns to capture different kinds of declarations
    local func_patterns = "%s*([%a_][%w_]+)%s*([%a_][%w_]+)%s*%b()%s*{([^}]*)}"  -- Captures function declarations
    local typedef_pattern = "%s*typedef%s+([%a_][%w_%s]*)%s+([%a_][%w_]*)%s*;"   -- Captures typedefs
    local struct_pattern = "%s*struct%s+([%a_][%w_]*)%s*{([^}]*)};"              -- Captures struct declarations

    local global_var_pattern = "%s*([%a_][%w_]*)%s+([%a_][%w_]*)%s*=%s*[^{};]*;" -- Captures global variables

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

    -- Capture global variables
    for var_type, var_name in string.gmatch(code, global_var_pattern) do
        table.insert(tokens, var_name)
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
