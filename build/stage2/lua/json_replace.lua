function Aply_main_replace(main_replace_json, content)
    for key, value in pairs(main_replace_json) do
        content = content:gsub(key, value)
    end
    return content
end
