


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
ANSI_RESET ="\x1b[0m"

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

---@type Clib
clib = clib


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
dtw = dtw