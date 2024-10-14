function Aply_json_replace(main_replace_json, content)
    for key, value in pairs(main_replace_json) do
        content = content:gsub(key, value)
    end
    return content
end

---@param path DtwPath
---@retun string
function Generate_mdifier_model_path(path)
    local copy_path = dtw.newPath(path.get_full_path())
    copy_path.replace_dirs(dtw.concat_path(RELEASE_FOLDER, SINGLE_UNIT_FOLDER), MODIFIER_FOLDER)

    local name = copy_path.get_name()
    name = clib.replace(name, ".c", ".json")
    copy_path.set_name(name)
    return copy_path.get_full_path()
end

---@param content string
---@param line number
---@param col number
---@return number
function find_point(content, line, col)
    local lines = clib.split(content, "\n")
    size = 1
    for i = 1, #lines - line do
        local current_line = lines[i]
        size = size + clib.get_str_size(current_line)
    end
    return size + col
end

---comment
---@param content string
---@param line number
---@param col number
---@param old_content string
---@param new_content string
---@return string
function Replace_item_in_line_and_col(content, line, col, old_content, new_content)
    local size = clib.get_str_size(content)
    local insert_point = find_point(content, line, col)
    local old_content_size = clib.get_str_size(old_content);
    local start = clib.substr(content, 1, insert_point)
    local end_str = clib.substr(content, insert_point + old_content_size, size)
    return start
end

---@param json_modifier_path string
---@param content string
function Aply_json_modifier(json_modifier_path, content)
    local json_modifier = json.load_from_file(json_modifier_path)
    local new_content   = content
    for i = 1, #json_modifier do
        local current = json_modifier[i]
        local original = current['original_name']
        local line = current['point'][1]
        local col = current['point'][2]
        local new_name = current['new_name']
        new_content = Replace_item_in_line_and_col(new_content, line, col, original, new_name)
    end
    return new_content
end
