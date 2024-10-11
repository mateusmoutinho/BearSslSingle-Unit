---@param part DtwTreePart
---@return Modifier
function NewModifier(part)
    local self = {}
    self.tree_part = part
    self.tokens = Collect_tokens(part.path.get_full_path())

    self.create_sumary = function()
        return {
            original_path = self.tree_part.path.get_full_path(),
            tokens = self.tokens
        }
    end

    return self
end
