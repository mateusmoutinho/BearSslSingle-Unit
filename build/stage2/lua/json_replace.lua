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
    local content_size = clib.get_str_size(content)
    local total_lines  = 1
    local total_chars  = 0
    for i = 1, content_size do
        if total_lines == line then
            break
        end
        total_chars = i
        local current_char = clib.get_char(content, i)
        if current_char == '\n' then
            total_lines = total_lines + 1
        end
    end
    return total_chars + col
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
    return start .. new_content .. end_str
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

---@param file DtwTreePart
function generate_json_modification_in_part(file)
    local extension = file.path.get_extension()
    if extension ~= 'c' and extension ~= 'h' then
        return
    end
    local json_modifier_path = Generate_mdifier_model_path(file.path)
    if dtw.isfile(json_modifier_path) then
        local content = file.get_value()
        content = Aply_json_modifier(json_modifier_path, content)
        file.set_value(content)
        file.hardware_modify()
    end
end
