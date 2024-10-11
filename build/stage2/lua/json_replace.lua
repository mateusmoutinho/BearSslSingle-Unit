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

    local name = copy_path.get_name()
    name = clib.replace(name, ".c", ".json")
    copy_path.set_name(name)
    return copy_path.get_full_path()
end

---@param path string
function Create_json_modifier_model_if_not_exist(path)
    if dtw.isfile(path) then
        return
    end


    dtw.write_file(path, DEFAULT_JSON_MODIFIER_MODEL)
end

function Aply_json_modifier(json_modifier_path, content)
    local json_modifier = json.load_from_file(json_modifier_path)
    local private_name = "private_" .. dtw.newPath(json_modifier_path).get_only_name()
    for i = 1, json_modifier['private'] do
        new_name = private_name .. json_modifier[i]
        print(new_name)
    end
    return content
end
