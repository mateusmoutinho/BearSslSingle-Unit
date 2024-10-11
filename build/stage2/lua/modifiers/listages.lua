---@param modifiers Modifier[]
function Create_summary(modifiers)
    all = {}
    for i = 1, #modifiers do
        local current = modifiers[i]
        all[#all + 1] = current.create_sumary()
    end

    json.dumps_to_file(all, "summary.json")
end

function Is_token_already_defined_by_other(modifier)

end

---@param modifiers Modifier[]
function Resolve_redefinitions(modifiers)

end

---@param src DtwTree
---@return Modifier[]
function Create_modifiers(src)
    return src.map(function(item)
        local extension = item.path.get_extension()
        if extension == "c" or extension == "h" then
            return NewModifier(item)
        end
    end)
end
