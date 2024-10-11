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
    copy_path.replace_dirs(SINGLE_UNIT_FOLDER, MODIFIER_FOLDER)
    return copy_path.get_full_path()
end

---@param path string
function Create_json_modifier_model_if_not_exist(path)
    if dtw.isfile(path) then
        return
    end


    dtw.write_file(path, DEFAULT_JSON_MODIFIER_MODEL)
end
