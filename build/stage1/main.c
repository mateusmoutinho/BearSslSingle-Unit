

#include "../dependencies/CTextEngine.h"
#include "../dependencies/doTheWorld.h"
#include "../dependencies/UniversalGarbage.h"
#include "../dependencies/silverchain/src/imports/imports.func_definition.h"

#include "conf.h"
#include <string.h>

DtwNamespace dtw;
CTextStackModule stack;

void parse_code(CTextStack *final,unsigned  char *content,long size){
    for(int i = 0; i < size; i++){
        stack.format(final," %d,",(unsigned char )content[i]);
    }
}
int  create_lua_code(){
    if(dtw.entity_type(LUA_FOLDER) != DTW_FOLDER_TYPE){
        printf("lua code its not a folder\n");
        return 1;
    }

    UniversalGarbage *garbage = newUniversalGarbage();


    CTextStack * final = stack.newStack_string_format("unsigned char  %s[]= {",LUA_VAR_NAME);
    UniversalGarbage_add(garbage,stack.free,final);

    DtwTree * tree = dtw.tree.newTree();
    UniversalGarbage_add(garbage,dtw.tree.free,tree);

    dtw.tree.add_tree_from_hardware(tree,LUA_FOLDER,(DtwTreeProps){
        .hadware_data = DTW_INCLUDE,
        .path_atributes = DTW_INCLUDE
    });

    DtwTreePart *main_code = NULL;
    for(int i = 0; i < tree->size;i++){

        DtwTreePart *current_file = tree->tree_parts[i];

        DtwPath *current_path = current_file->path;

        char *full_name = dtw.path.get_full_name(current_path);
        //means its a folder
        if(full_name == NULL){
            continue;
        }

        char *extension = dtw.path.get_extension(current_path);

        if(extension){
            if(strcmp(extension,"lua") != 0){
                continue;
            }
        }


        if(current_file->content == NULL || current_file->is_binary){
            char *full_path = dtw.path.get_path(current_path);
            printf("impossible to load content of %s\n",full_path);
            UniversalGarbage_free(garbage);
            return 1;
        }



        if(strcmp(full_name,"main.lua")==0){
            main_code = current_file;
            continue;
        }
        parse_code(final,current_file->content,current_file->content_size);
    }
    if(main_code == NULL){
        printf("main code not provided\n");
        UniversalGarbage_free(garbage);
        return 1;
    }
    parse_code(final,main_code->content,main_code->content_size);

    stack.text(final,"0};");


    dtw.write_string_file_content(OUTPUT,final->rendered_text);

    UniversalGarbage_free(garbage);
    return 0;
}
int main(){
    dtw = newDtwNamespace();
    stack = newCTextStackModule();


    int error = create_lua_code();
    if(error){
        return error;
    }


    DtwStringArray *tags = newDtwStringArray();
    dtw.string_array.append(tags,DEPENDENCIES_FLAG);
    dtw.string_array.append(tags,CONST_FLAGS);
    dtw.string_array.append(tags,TYPES_FLAG);
    dtw.string_array.append(tags,GLOBALS_FLAG);
    dtw.string_array.append(tags,FDECLARE_FLAG);
    dtw.string_array.append(tags,FDEFINE_FLAG);

    generate_code(STAGE_2_FOLDER,"stage2/c/imports","silverchain_stage2",tags,true,DEFAULT_MAIN_C_NAME,NULL);
    dtw.string_array.free(tags);

    CTextStack *final_compilation_linux = stack.newStack_string_format("gcc stage2/c/main.c -o %s",FINAL_OUPTUT_LINUX);
    error = system(final_compilation_linux->rendered_text);
    stack.free(final_compilation_linux);


    if(error){
        return error;
    }
    /*
    CTextStack *final_compilation_windows = stack.newStack_string_format("x86_64-w64-mingw32-gcc  stage2/c/main.c -o %s",FINAL_OUPTUT_WINDOWS);
    error = system(final_compilation_windows->rendered_text);
    stack.free(final_compilation_windows);
    */



    return 0;
}
