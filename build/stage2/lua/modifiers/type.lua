---@class Token
---field value string
---@field replace string|nil

---@class Sumary
---@field original_path string
---@field tokens Token


---@class Modifier
---@field tree_part DtwTreePart
---@field tokens Token[]
---@field create_sumary fun():Sumary
