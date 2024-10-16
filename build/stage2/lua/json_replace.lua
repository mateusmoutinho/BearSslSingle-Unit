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

---@param path string
---@param name_without_extension
function Create_json_modifier_model_if_not_exist(path, name_without_extension)
    if dtw.isfile(path) then
        return
    end
    local formmated = clib.replace(DEFAULT_JSON_MODIFIER_MODEL, "#name#", name_without_extension)
    dtw.write_file(path, formmated)
end

---@param json_modifier_path string
---@param content string
function Aply_json_modifier(json_modifier_path, content)
    local json_modifier = json.load_from_file(json_modifier_path)

    local private_name = "private_" .. json_modifier["name"]
    local private_replace = json_modifier['private']
    for i = 1, #private_replace do
        local name_to_replace = private_replace[i]
        local new_name        = private_name .. name_to_replace
        content               = clib.replace(content, name_to_replace, new_name)
    end
    content = Aply_json_replace(json_modifier["replacers"], content)

    return content
end
