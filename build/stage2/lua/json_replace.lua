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

---@param json_modifier_path string
---@param content string
function Aply_json_modifier(json_modifier_path, content)
    local json_modifier = json.load_from_file(json_modifier_path)

    return content
end
