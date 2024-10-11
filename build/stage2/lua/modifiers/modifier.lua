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

    self.is_defined = function(token)
        for i = 1, #self.tokens do
            local current = self.tokens[i]
            if current.value == token then
                return true
            end
        end
        return false
    end

    ---@param all Modifier[]
    ---@param token string
    ---@return boolean
    self.is_defined_by_others = function(all, token)
        for i = 1, #all do
            local current = all[i]

            if current ~= self then
                if current.is_defined(token) then
                    return true
                end
            end
        end
        return false
    end

    ---@param all Modifier[]
    self.resolve_redefinitions = function(all)
        for i = 1, #self.tokens do
            local current = self.tokens[i]
            if self.is_defined_by_others(all, current.value) then
                current.replace = "private_" .. self.tree_part.path.get_only_name() .. current.value
            end
        end
    end
    ---@param all Modifier[]
    self.generate_file_modifications = function(all)
        self.resolve_redefinitions(all)
    end

    return self
end
