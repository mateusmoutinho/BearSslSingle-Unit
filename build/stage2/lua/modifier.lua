---@param path string
---@return string[]
function collect_tags(path)
    os.execute("ctags -R " .. path)
    local content = dtw.load_file("tags")
    lines = clib.split(content)
end

---@param part DtwTreePart
---@return Modifier[]
function create_modifier(part)
    local self = {}
    self.tree_part = part
    self.type_elements = collect_tags(part.path.get_full_path())
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
