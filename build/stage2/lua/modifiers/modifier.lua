---@param part DtwTreePart
---@return Modifier
function NewModifier(part)
    local self = {}
    self.tree_part = part
    self.tokens = Collect_tokens(part.path.get_full_path())

    self.create_sumary = function()
        return {
            original_path = self.tree_part.path.get_full_path(),
            modified_path = self.modified_path,
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
    ---@param json_main_replacer table
    self.generate_file_modifications = function(all, json_main_replacer)
        self.resolve_redefinitions(all)
        local single_unit_dir = dtw.concat_path(RELEASE_FODER, SINGLE_UNIT_FOLDER)
        local name = self.tree_part.path.get_name()
        local extension = self.tree_part.path.get_extension()
        if extension == "h" then
            self.tree_part.path.set_name(DECLARE_NAME .. "." .. name)
        end
        if extension == "c" then
            self.tree_part.path.set_name(DEFINE_NAME .. "." .. name)
        end
        self.tree_part.path.replace_dirs("BearSSL/src", dtw.concat_path(single_unit_dir, "src"))

        self.modified_path = self.tree_part.path.get_full_path()

        local content = self.tree_part.get_value()

        for key, value in pairs(json_main_replacer) do
            content = clib.replace(content, key, value)
        end
        if extension == "c" then
            for i = 1, #self.tokens do
                local current = self.tokens[i]
                if current.replace then
                    content = clib.replace(content, current.value, current.replace)
                end
            end
        end

        self.tree_part.set_value(content)

        self.tree_part.hardware_write()
    end

    return self
end
