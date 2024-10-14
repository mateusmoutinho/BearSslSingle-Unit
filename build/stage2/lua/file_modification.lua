---@param json_main_replacer table
---@param file DtwTreePart
function Aply_file_modification(json_main_replacer, file)
    local is_c_file = false
    local original_path = dtw.newPath(file.path.get_full_path())
    local new_src = dtw.concat_path(RELEASE_FOLDER, SINGLE_UNIT_FOLDER)
    new_src = dtw.concat_path(new_src, "src")
    file.path.replace_dirs("BearSSL/src", new_src)

    if file.path.get_extension() == "c" then
        is_c_file = true
        local new_name = DEFINE_NAME .. "." .. file.path.get_name()
        file.path.set_name(new_name)
        file.hardware_modify()
    end

    if file.path.get_extension() == "h" then
        is_c_file = true
        file.get_value()
        local new_name = DECLARE_NAME .. "." .. file.path.get_name()
        file.path.set_name(new_name)
    end

    if is_c_file then
        local content = file.get_value()
        local formmated = Aply_json_replace(main_replace_json, content)

        file.set_value(formmated)
        file.hardware_write()
    end
end
