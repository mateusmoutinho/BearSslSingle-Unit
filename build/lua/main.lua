local function main()
    print(ANSI_BLUE .. "Downloading Bear")
    dtw.remove_any("BearSSL")
    os.execute("git clone https://www.bearssl.org/git/BearSSL")

    local all_itens = dtw.list_files_recursively("BearSSL/src", true)
    for i = 1, #all_itens do
        current = all_itens[i]
        local content = dtw.load_file(current)
        local path_obj = dtw.newPath(current)
        local name = path_obj.get_name()
        local extension = path_obj.get_extension()
        if extension == "c" then
            content = content:gsub('#include "inner.h"', '')
            local new_name = "fdefine." .. name
            path_obj.set_only_name(new_name)
            dtw.write_file(path_obj.get_full_path(), content)
        end
        if extension == "h" then
            local new_name = "fdeclare." .. name
            path_obj.set_only_name(new_name)
            dtw.move_any_overwriting(current, path_obj.get_full_path())
        end
    end
end
main()
