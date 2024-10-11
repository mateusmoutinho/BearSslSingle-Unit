---@class LuaFluidJson
---@field load_from_string fun(str:string): any
---@field load_from_file fun(str:string):any
---@field dumps_to_string fun(entry:table,ident:boolean| nil): string
---@field dumps_to_file fun(entry:table,output:string,ident:boolean|nil)
---@field is_table_a_object fun(element:table):boolean
---@field set_null_code fun(null_code:string)


---@type LuaFluidJson
json = json
