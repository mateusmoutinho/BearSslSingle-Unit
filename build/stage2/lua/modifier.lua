---@param path string
---@return Token[]
local function collect_tokens(path)
    os.execute("ctags -R " .. path)
    local content = dtw.load_file("tags")
    lines = clib.split(content, "\n")
    all_elements = {}
    for i = 1, #lines do
        local current = lines[i]
        if clib.get_char(current, 0) ~= "!" then
            local token = {}
            token.value = clib.split(current, " ")[0]
        end
    end
end

---@param part DtwTreePart
---@return Modifier[]
function create_modifier(part)
    local self = {}
    self.tree_part = part
    self.tokens = collect_tokens(part.path.get_full_path())

    return self
end

---@param src DtwTree
---@return Modifier[]
function create_modifiers(src)
    return src.map(function(item)
        local extension = item.path.get_extension()
        if extension == "c" or extension == "h" then
            return create_modifier()
        end
    end)
end
