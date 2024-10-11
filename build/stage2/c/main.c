
//silver_chain_scope_start
//mannaged by silver chain
#include "imports/imports.fdefine.h"
//silver_chain_scope_end


void add_callbacks(LuaCEmbed *main_obj){
    LuaCEmbedTable *clib = lua.globals.new_table(main_obj,"clib");
    lua.tables.set_method(clib,"print",custom_print);
    lua.tables.set_method(clib,"exit",generate_exit);
    lua.tables.set_method(clib,"get_str_size",lua_get_str_size);
    lua.tables.set_method(clib,"get_char",lua_get_char);
    lua.tables.set_method(clib,"system_with_status",system_function_with_status);
    lua.tables.set_method(clib,"system_with_string",system_with_text);
    lua.tables.set_method(clib,"indexof",lua_index_of);
    lua.tables.set_method(clib,"out_extension",get_out_extension);
    lua.tables.set_method(clib,"replace",lua_replace_string);
    lua.tables.set_method(clib,"trim",lua_trim);
    lua.tables.set_method(clib,"split",lua_split);
    LuaCEmbedTable *silverchain = lua.globals.new_table(main_obj,"silver_chain");
    lua.tables.set_method(silverchain,"generate_code",lua_cembed_generate_code);
}


int main(int argc,char *argv[]){

    lua  = newLuaCEmbedNamespace();
    dtw = newDtwNamespace();
    stack = newCTextStackModule();
    bool destroy_visualize = true;
    if(argc >= 2){
        if(strcmp(argv[1],"debug") ==0){
            dtw.write_string_file_content("visualize.lua",(const char*)lua_code);
            destroy_visualize = false;
        }
    }
    if(destroy_visualize){
        dtw.remove_any("visualize.lua");
    }

    LuaCEmbed * main_obj = lua.newLuaEvaluation();
    lua.load_lib_from_c(main_obj,load_luaDoTheWorld,"dtw");
    lua.load_lib_from_c(main_obj,load_lua,"json");
    lua.load_native_libs(main_obj);
    add_callbacks(main_obj);
    lua.evaluate(main_obj,"%s",(const char*)lua_code);
    if(lua.has_errors(main_obj)){
        char *error = lua.get_error_message(main_obj);
        if(strcmp(error,"") != 0){

            printf("\x1b[31m""%s\n",error);
        }

        printf("\x1b[0m");//resset colors
        lua.free(main_obj);
        return lua_exit;
    }
    lua.free(main_obj);
    return 0;
}
