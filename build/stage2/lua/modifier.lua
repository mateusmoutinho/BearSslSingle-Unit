---@param path string
---@return Token[]
local function collect_tokens(path)
    os.execute("ctags -R " .. path)
    local content = dtw.load_file("tags")
    lines = clib.split(content, "\n")
    all_elements = {}
    for i = 1, #lines do
        local current = lines[i]
        if clib.get_char(current, 1) ~= "!" then
            local token = {}
            token.value = clib.split(current, "\t")[1]
            if token.value ~= "" then
                all_elements[#all_elements + 1] = token
            end
        end
    end
    return all_elements
end

---@param part DtwTreePart
---@return Modifier
local function newModifier(part)
    local self = {}
    self.tree_part = part
    self.tokens = collect_tokens(part.path.get_full_path())

    self.create_sumary = function()
        return {
            original_path = self.tree_part.path.get_full_path(),
            tokens = self.tokens
        }
    end

    return self
end

---@param modifiers Modifier[]
function Create_summary(modifiers)
    all = {}
    for i = 1, #modifiers do
        local current = modifiers[i]
        all[#all + 1] = current.create_sumary()
    end

    json.dumps_to_file(all, "summary.json")
end

---@param src DtwTree
---@return Modifier[]
function Create_modifiers(src)
    return src.map(function(item)
        local extension = item.path.get_extension()
        if extension == "c" or extension == "h" then
            return newModifier(item)
        end
    end)
end
