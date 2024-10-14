


---@param start_point string
---@param already_included_list  StringArray | nil
---@return string
  function Generate_amalgamation_recursive(start_point,already_included_list)


    if already_included_list == nil then
    	already_included_list = Created_already_included()
    end

    local start_point_sha = dtw.generate_sha_from_file(start_point)
    if already_included_list.is_included(start_point_sha) then
    	clib.print(ANSI_YELLOW.."file"..start_point.."already included\n")
    	return ""
    end

    already_included_list.append(start_point_sha)


    local content = dtw.load_file(start_point)

    local size = clib.get_str_size(content)
    local inside_string = false
    local waiting_include = false
    local string_buffer = ""
    local final_text = ""
    for i=1,size do
        local is_start_string = Verify_if_is_start_string_char(content,i,inside_string)
        if is_start_string  then
        	inside_string = true
        end

        local is_end_string = Verify_if_is_end_string_char(is_start_string,content,i,inside_string)

       if Include_char_to_string_buffer(is_start_string,is_end_string,inside_string) then
            string_buffer = string_buffer..clib.get_char(content,i)
        end

       if Include_string_buffer_to_final(waiting_include,is_end_string) then
            final_text = final_text..'"'..string_buffer..'"'
        end

        if Is_include_point(content,i,inside_string) then
        	waiting_include = true
        end

        if Anulate_inclusion(waiting_include,content,i) then
            final_text = final_text.."#include "
        	waiting_include = false
        end

        if Include_char_to_final(waiting_include,inside_string) then
        	final_text = final_text..clib.get_char(content,i)
        end



        if Make_recursive_call(waiting_include,is_end_string) then
            local dir = dtw.newPath(start_point).get_dir()
            local full_path = dtw.concat_path(dir,string_buffer)

            local acumulated = Generate_amalgamation_recursive(full_path,already_included_list)
            final_text = final_text.. acumulated.."\n"

        	waiting_include = false
        end

        if is_end_string then
           inside_string = false
           string_buffer = ""
        end

    end

    clib.print(ANSI_GREEN.."amalgamated: "..start_point.."\n")
    return final_text
end


---@param waiting_include boolean
---@param inside_string boolean
 function Include_char_to_final(waiting_include,inside_string)

    if waiting_include then
    	return false
    end
    if inside_string then
    	return false
    end
    return true
end
---@param waiting_include boolean
---@param is_end_string boolean
 function Include_string_buffer_to_final(waiting_include,is_end_string)

    if waiting_include then
    	return false
    end
    if is_end_string then
    	return true
    end

    return false
end
---@param content string
---@param index number
---@param inside_string boolean
 function Is_include_point(content,index,inside_string)

    if inside_string then
    	return false
    end

    local INCLUDE_TEXT  = "#include"
    local content_size = clib.get_str_size(content)
    local include_size = clib.get_str_size(INCLUDE_TEXT)
    if index + include_size >= content_size then
    	return false
    end
    local buffer = ""
    for i=index,index + include_size -1 do
    	buffer = buffer..clib.get_char(content,i)
    end

    return buffer == INCLUDE_TEXT
end

---@param is_start_string boolean
---@param is_end_string boolean
---@param is_inside_string boolean
 function Include_char_to_string_buffer(is_start_string,is_end_string,is_inside_string)
    if is_start_string then
    	return false
    end
    if is_end_string then
    	return false
    end
    if is_inside_string then
    	return true
    end

    return false
end

---@param  waiting_include boolean
---@param is_end_string boolean
 function Make_recursive_call(waiting_include,is_end_string)
	if waiting_include and is_end_string then
		return true
	end
end

---@param waiting_include boolean
---@param content string
---@param index number
 function Anulate_inclusion(waiting_include,content,index)
    if waiting_include == false then
    	return false
    end
    if clib.get_char(content,index) == "<" then
    	return true
    end
    return false
end


---@class StringArray
---@field size number
---@field elements string[]
---@field append fun(element:string)
---@field is_included fun(element:string):boolean

---@return StringArray
function  Created_already_included()
	local self  = {
	    size = 0,
	    elements = {}
	}

	self.append = function (element)
	    self.size = self.size +1
        self.elements[self.size] = element
	end

	self.is_included = function (element)
		for i=1,self.size do
			if self.elements[i] == element then
				return true
			end
		end
		return false
	end
	return self

end

---@param content string
---@param index number
---@param inside_string boolean
 function Verify_if_is_start_string_char(content,index,inside_string)
	if inside_string == true then
		return false
	end
	local last_char = clib.get_char(content,index-1)
    if last_char == '\\' then
    	return false
    end
    local current_char = clib.get_char(content,index)
    if current_char == '"' then
    	return true
    end
    return false
end


 function Verify_if_is_end_string_char(is_start_string_char,content,index,inside_string)
    if is_start_string_char then
    	return false
    end

    if inside_string == false then
    	return false
    end

    local last_last_char = clib.get_char(content,index-2)
    local last_char = clib.get_char(content,index-1)
    local current_char = clib.get_char(content,index)
    local scape = last_char == '\\' and last_last_char ~="\\"
    if current_char == '"' and scape == false  then
    	return true
    end
    return false
end

ANSI_RED = "\x1b[31m"
ANSI_GREEN = "\x1b[32m"
ANSI_YELLOW = "\x1b[33m"
ANSI_BLUE = "\x1b[34m"
ANSI_MAGENTA= "\x1b[35m"
ANSI_CYAN= "\x1b[36m"
ANSI_RESET ="\x1b[0m"DEFAULT_JSON_MODIFIER_MODEL = [[{
        "replacers":{},
        "name":"#name#",
        "private":[]
    }
]]

MODIFIER_FOLDER             = "modifier"
RELEASE_FOLDER              = "release"
SINGLE_UNIT_FOLDER          = "BearSSLSingleUnit"
DECLARE_NAME                = "fdeclare"
DEFINE_NAME                 = "fdefine"
SILVER_CHAIN_NAME           = "bearssl"
PROVIDER_GIT                = "https://www.bearssl.org/git/BearSSL"
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
    copy_path.replace_dirs(dtw.concat_path(RELEASE_FOLDER, SINGLE_UNIT_FOLDER), MODIFIER_FOLDER)

    local name = copy_path.get_name()
    name = clib.replace(name, ".c", ".json")
    copy_path.set_name(name)
    return copy_path.get_full_path()
end

---@param content string
---@param line number
---@param col number
---@return number
function find_point(content, line, col)
    local content_size = clib.get_str_size(content)
    local total_lines  = 1
    local total_chars  = 0
    for i = 1, content_size do
        if total_lines == line then
            break
        end
        total_chars = i
        local current_char = clib.get_char(content, i)
        if current_char == '\n' then
            total_lines = total_lines + 1
        end
    end
    return total_chars + col
end

---comment
---@param content string
---@param line number
---@param col number
---@param old_content string
---@param new_content string
---@return string
function Replace_item_in_line_and_col(content, line, col, old_content, new_content)
    local size = clib.get_str_size(content)
    local insert_point = find_point(content, line, col)
    local old_content_size = clib.get_str_size(old_content);
    local start = clib.substr(content, 1, insert_point)
    local end_str = clib.substr(content, insert_point + old_content_size, size)
    return start .. new_content .. end_str
end

---@param json_modifier_path string
---@param content string
function Aply_json_modifier(json_modifier_path, content)
    local json_modifier = json.load_from_file(json_modifier_path)
    local new_content   = content
    for i = 1, #json_modifier do
        local current = json_modifier[i]
        local original = current['original_name']
        local line = current['point'][1]
        local col = current['point'][2]
        local new_name = current['new_name']
        new_content = Replace_item_in_line_and_col(new_content, line, col, original, new_name)
        local calls = current['calls']
        for x = 1, #calls do
            local current_call = calls[x]
            new_content = Replace_item_in_line_and_col(
                new_content,
                current_call[1],
                current_call[2],
                original,
                new_name
            )
        end
    end
    return new_content
end

---@param file DtwTreePart
function generate_json_modification_in_part(file)
    local extension = file.path.get_extension()
    if extension ~= 'c' and extension ~= 'h' then
        return
    end
    local json_modifier_path = Generate_mdifier_model_path(file.path)
    if dtw.isfile(json_modifier_path) then
        local content = file.get_value()
        content = Aply_json_modifier(json_modifier_path, content)
        file.set_value(content)
        file.hardware_modify()
    end
end
---@class Clib
---@field load_string fun(path:string):string
---@field get_char fun(path:string,i:number):string
---@field get_str_size fun(value:string): number
---@field get_time fun():number
---@field exit fun(status:number):number
---@field system_with_status fun(comand:string):number
---@field system_with_string fun(comand:string):string
---@field indexof fun(content:string,comparation:string):number
---@field out_extension fun():string
---@field replace fun(content:string,target:string,value_to_replace:string):string
---@field trim fun(content:string):string
---@field split fun(content:string,target:string):string[]
---@field substr fun(content:string,start:number,end:number):string

---@type Clib
clib = clib
---@class LuaFluidJson
---@field load_from_string fun(str:string): any
---@field load_from_file fun(str:string):any
---@field dumps_to_string fun(entry:table,ident:boolean| nil): string
---@field dumps_to_file fun(entry:table,output:string,ident:boolean|nil)
---@field is_table_a_object fun(element:table):boolean
---@field set_null_code fun(null_code:string)


---@type LuaFluidJson
json = json


---@class DtwTreePart
---@field path DtwPath
---@field get_value fun():string
---@field set_value fun(value:string | number | boolean | DtwTreePart | DtwResource | DtwActionTransaction)
---@field hardware_remove fun(as_transaction:boolean|nil):DtwTreePart
---@field hardware_write fun(as_transaction:boolean|nil):DtwTreePart
---@field hardware_modify fun(as_transaction:boolean|nil):DtwTreePart
---@field get_sha fun():string
---@field is_blob fun():boolean
---@field unload fun():DtwTreePart
---@field load fun():DtwTreePart


---@class DtwTree
---@field newTreePart_empty fun ():DtwTreePart
---@field newTreePart_loading fun ():DtwTreePart
---@field get_tree_part_by_index fun(index:number):DtwTreePart
---@field insecure_hardware_write_tree fun():DtwTree
---@field insecure_hardware_remove fun():DtwTree
---@field commit fun():DtwTree
---@field get_size fun():number
---@field get_tree_part_by_name fun(name:string):DtwTreePart
---@field get_tree_part_by_path fun(name:string):DtwTreePart
---@field find fun(callback: fun(part:DtwTreePart):boolean):DtwTreePart
---@field count fun(callback: fun(part:DtwTreePart):boolean):number
---@field map fun(callback: fun(part:DtwTreePart):any):any[]
---@field each fun(callback: fun(part:DtwTreePart))
---@field dump_to_json_string fun():string
---@field dump_to_json_file fun():DtwTree

---@class DtwPath
---@field path_changed fun():boolean
---@field add_start_dir fun(start_dir:string):DtwPath
---@field add_end_dir_method fun (end_dir:string):DtwPath
---@field changed fun():boolean
---@field get_dir fun():string
---@field get_extension fun():string
---@field get_name fun():string
---@field get_only_name fun():string
---@field get_full_path fun():string
---@field set_name fun(new_name:string) DtwPath
---@field set_only_name fun(new_name:string) DtwPath
---@field set_extension fun(extension:string):DtwPath
---@field set_dir fun(dir:string):DtwPath
---@field set_path fun(path:string):DtwPath
---@field replace_dirs fun(old_dir:string,new_dir:string):DtwPath
---@field get_total_dirs fun():number
---@field get_sub_dirs_from_index fun(start:number,end:number):string
---@field insert_dir_at_index fun(index:number,dir:string):DtwPath
---@field remove_sub_dir_at_index fun(start:number,end:number):DtwPath
---@field insert_dir_after fun(point:string, dir:string):DtwPath
---@field insert_dir_before fun(point:string, dir:string):DtwPath
---@field remove_dir_at fun(point:string):DtwPath
---@field unpack fun():string[],number



---@class DtwHasher
---@field digest fun(value:string | number | boolean | string ):DtwHasher
---@field digest_file fun(source:string):DtwHasher
---@field digest_folder_by_content fun(source:string):DtwHasher
---@field digest_folder_by_last_modification fun(source:string):DtwHasher
---@field get_value fun():string

---@class DtwActionTransaction
---@field get_type_code fun():number
---@field get_type fun():string
---@field get_content fun():string
---@field set_content fun()
---@field get_source fun():string
---@field get_dest fun():string
---@field set_dest fun():string




---@class DtwTransaction
---@field write fun(src :string , value:string | number | boolean | string | DtwResource ):DtwTransaction
---@field remove_any fun(src:string):DtwTransaction
---@field copy_any fun(src:string,dest:string):DtwTransaction
---@field move_any fun(src:string,dest:string):DtwTransaction
---@field dump_to_json_string fun():string
---@field dump_to_json_file fun(src:string):DtwTransaction
---@field each fun(callbac: fun(value:DtwActionTransaction))
---@field map fun(callbac: fun(value:DtwActionTransaction):any):any[]
---@field find fun(callbac: fun(value:DtwActionTransaction):boolean):DtwActionTransaction
---@field count fun(callbac: fun(value:DtwActionTransaction):boolean):number
---@field __index fun(index:number):DtwActionTransaction
---@field get_action fun(index:number):DtwActionTransaction
---@field commit fun():DtwTransaction


---@class DtwSchema
---@field add_primary_keys fun(values:string | string[])
---@field sub_schema fun(values:string | string[])

---@class DtwResource
---@field schema_new_insertion fun():DtwResource
---@field dangerous_remove_prop fun(primary_key:string)
---@field dangerous_rename_prop fun(primary_key:string ,new_name:string)
---@field get_resource_matching_primary_key fun(primary_key: string,  value:string | number | boolean | Dtwblobs | DtwResource ):DtwResource
---@field get_resource_by_name_id fun(id_name:string)
---@field schema_list fun(): DtwResource[]
---@field schema_each fun(callback:fun(value:DtwResource))
---@field schema_find fun(callback:fun(value:DtwResource):boolean):DtwResource
---@field schema_map fun(callback:fun(value:DtwResource):any)
---@field schema_count fun(callback:fun(value:DtwResource):boolean):number
---@field sub_resource fun(str:string) :DtwResource
---@field sub_resource_next fun(str:string) :DtwResource
---@field sub_resource_now fun(str:string) :DtwResource
---@field sub_resource_now_in_unix fun(str:string) :DtwResource
---@field __index fun(str:string) : number ,DtwResource
---@field get_value fun():string | number | boolean | nil | string
---@field get_string fun():string | nil
---@field get_number fun(): number | nil
---@field get_bool fun(): boolean | nil
---@field set_value fun(value:string | number | boolean | string | DtwResource )
---@field commit fun()  apply the modifications
---@field lock fun() lock the resource from other process
---@field unlock fun()
---@field unload fun() unload the content
---@field get_path_string fun() :string
---@field each fun(callback :fun(element:DtwResource))
---@field set_extension fun(extension:string)
---@field list fun(): DtwResource[]
---@field destroy fun()
---@field set_value_in_sub_resource fun(key:string ,value:string | number | boolean | string | DtwResource )
---@field get_value_from_sub_resource fun(key:string):string | number | boolean | nil | string
---@field newSchema fun():DtwSchema


---@class DtwModule
---@field copy_any_overwriting fun(src:string,dest:string):boolean returns true if the operation were ok otherwise false
---@field copy_any_merging   fun(src:string,dest:string):boolean returns true if the operation were ok otherwise false
---@field move_any_overwriting fun(src:string,dest:string):boolean returns true if the operation were ok otherwise false
---@field move_any_merging fun(src:string,dest:string):boolean returns true if the operation were ok otherwise false
---@field remove_any fun(src:string):boolean returns true if the operation were ok otherwise false
---@field base64_encode_file fun(src:string):string transform file into base64
---@field base64_encode fun(value:string | number | boolean | string):string transform content into base64
---@field base64_decode fun(value:string): string | string retransform base64 into normal value
---@field list_files fun(src:string,concat_path:boolean|nil):string[],number
---@field list_dirs fun(src:string,concat_path:boolean|nil):string[],number
---@field list_all fun(src:string,concat_path:boolean|nil):string[],number
---@field list_files_recursively fun(src:string,concat_path:boolean|nil):string[],number
---@field list_dirs_recursively fun(src:string,concat_path:boolean|nil):string[],number
---@field list_all_recursively fun(src:string,concat_path:boolean|nil):string[],number
---@field load_file fun(src:string):string | string
---@field write_file fun(src:string,value:string | number | boolean | DtwTreePart | DtwResource | DtwActionTransaction)
---@field is_blob fun(value:any):boolean returns if a value is a blob
---@field newResource fun(src:string):DtwResource
---@field generate_sha fun(value:string | number | boolean | string):string
---@field generate_sha_from_file fun(src:string):string
---@field generate_sha_from_folder_by_content fun(src:string):string
---@field generate_sha_from_folder_by_last_modification fun(src:string):string
---@field newHasher fun():DtwHasher
---@field isdir fun(path:string):boolean
---@field isfile fun(path:string):boolean
---@field isfile_blob fun(path:string):boolean
---@field newTransaction fun():DtwTransaction
---@field newTransaction_from_file fun():DtwTransaction
---@field newTransaction_from_json_string fun():DtwTransaction
---@field newPath fun(path:string):DtwPath
---@field newTree fun():DtwTree
---@field newTree_from_hardware fun(path:string):DtwTree
---@field concat_path fun(path1:string,path2:string):string
---@field starts_with fun(comparation:string,prefix:string):boolean
---@field ends_with fun(comparation:string,sulfix:string):boolean



---@type DtwModule
dtw = dtw---@class silver_chain
---@field generate_code fun(src:string,imports:string,shortcut:string,flags:table,main_file:string|nil,main_path:string|nil)
local function main()
    print(ANSI_BLUE .. "Downloading Bear")

    if not dtw.isdir("BearSSL") then
        os.execute("git clone " .. PROVIDER_GIT)
    end

    local single_unit_point = dtw.concat_path(RELEASE_FOLDER, SINGLE_UNIT_FOLDER)
    dtw.remove_any(single_unit_point)

    dtw.copy_any_overwriting("BearSSL/inc", single_unit_point .. "/inc")


    local src = dtw.newTree_from_hardware("BearSSL/src")
    main_replace_json = json.load_from_file("main_replace.json")

    src.each(function(current)
        Aply_file_modification(main_replace_json, current)
    end)
    src.commit()

    silver_chain.generate_code(
        single_unit_point .. "/src",
        single_unit_point .. "/imports",
        SILVER_CHAIN_NAME,
        { "bear", DECLARE_NAME, DEFINE_NAME }
    )
    local new_src = dtw.newTree_from_hardware(single_unit_point)
    new_src.each(generate_json_modification_in_part)
    new_src.commit()


    dtw.copy_any_merging("BearModel", single_unit_point)
end
main()
