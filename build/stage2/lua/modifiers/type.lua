---@class Token
---@field value string
---@field replace string|nil

---@class Sumary
---@field original_path string
---@field tokens Token


---@class Modifier
---@field tree_part DtwTreePart
---@field tokens Token[]
---@field create_sumary fun():Sumary
---@field is_defined fun(token:string):boolean
---@field resolve_redefinitions fun(all:Modifier[])
