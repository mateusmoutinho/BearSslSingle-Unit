
//silver_chain_scope_start
//mannaged by silver chain
#include "../../imports/imports.fdeclare.h"
//silver_chain_scope_end
LuaCEmbedResponse * lua_get_str_size(LuaCEmbedTable *self,LuaCEmbed *args){
    long size;
    lua.args.get_raw_str(args,&size,0);
    if(lua.has_errors(args)){
        char *erro_msg = lua.get_error_message(args);
        return lua.response.send_error(erro_msg);
    }
    return  lua.response.send_long(size);
}

LuaCEmbedResponse * lua_get_char(LuaCEmbedTable *self,LuaCEmbed *args){

    long size;
    char *content = lua.args.get_raw_str(args,&size,0);
    long index = lua.args.get_long(args,1)-1;
    if(lua.has_errors(args)){
        char *erro_msg = lua.get_error_message(args);
        return lua.response.send_error(erro_msg);
    }
    if(index >=size || index < 0){
        return NULL;
    }

    char buffer[5] = {0};
    sprintf(buffer,"%c",content[index]);
    return lua.response.send_raw_string(buffer,1);

}

LuaCEmbedResponse * lua_index_of(LuaCEmbedTable *self,LuaCEmbed *args){

    char *content = lua.args.get_str(args,0);
    char *target = lua.args.get_str(args,1);

    if(lua.has_errors(args)){
        char *error_msg = lua.get_error_message(args);
        return lua.response.send_error(error_msg);
    }
    CTextStack *content_stack = stack.newStack_string(content);
    int index = stack.index_of(content_stack,target);
    stack.free(content_stack);
    return  lua.response.send_long(index);
}
LuaCEmbedResponse * lua_replace_string(LuaCEmbedTable *self,LuaCEmbed *args){

    char *content = lua.args.get_str(args,0);
    char *target = lua.args.get_str(args,1);
    char *value_to_replace  = lua.args.get_str(args,2);
    if(lua.has_errors(args)){
        char *error_msg = lua.get_error_message(args);
        return lua.response.send_error(error_msg);
    }
    CTextStack *content_stack = stack.newStack_string(content);
    stack.self_replace(content_stack,target,value_to_replace);

    LuaCEmbedResponse *response =  lua.response.send_str(content_stack->rendered_text);
    stack.free(content_stack);
    return  response;

}

LuaCEmbedResponse * lua_trim(LuaCEmbedTable *self,LuaCEmbed *args){

    char *content = lua.args.get_str(args,0);

    if(lua.has_errors(args)){
        char *error_msg = lua.get_error_message(args);
        return lua.response.send_error(error_msg);
    }

    CTextStack * content_stack = stack.newStack_string(content);
    stack.self_trim(content_stack);
    LuaCEmbedResponse *response =lua.response.send_str(content_stack->rendered_text);
    stack.free(content_stack);
    return  response;
}
LuaCEmbedResponse * lua_split(LuaCEmbedTable *self,LuaCEmbed *args){

    char *content = lua.args.get_str(args,0);
    char *target = lua.args.get_str(args,1);

    if(lua.has_errors(args)){
        char *error_msg = lua.get_error_message(args);
        return lua.response.send_error(error_msg);
    }

    CTextArray *all =CTextArray_split(content,target);
    LuaCEmbedTable *splited =lua.tables.new_anonymous_table(args);
    for(int i = 0; i < all->size;i++){
        lua.tables.append_string(splited,all->stacks[i]->rendered_text);
    }
    CTextArray_free(all);
    return  lua.response.send_table(splited);
}
