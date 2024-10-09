local function concat_name_on_funcs(path, content)
    content = content:gsub("api_generator", path.get_only_name() .. "api_generator")
    content = content:gsub("api_order", path.get_only_name() .. "api_order")
    content = content:gsub("api_xoff", path.get_only_name() .. "api_xoff")
    content = content:gsub("api_mul", path.get_only_name() .. "api_mul")
    content = content:gsub("api_muladd", path.get_only_name() .. "api_muladd")
    content = content:gsub("byteswap", path.get_only_name() .. "byteswap")
    content = content:gsub("cswap", path.get_only_name() .. "cswap")
    content = content:gsub("reduce_final_f255", path.get_only_name() .. "reduce_final_f255")

    content = content:gsub("f255_add", path.get_only_name() .. "f255_add")
    content = content:gsub("f255_sub", path.get_only_name() .. "f255_sub")
    content = content:gsub("f255_mul", path.get_only_name() .. "f255_mul")
    content = content:gsub("f255_final_reduce", path.get_only_name() .. "f255_final_reduce")

    content = content:gsub("C255_R2", path.get_only_name() .. "C255_R2")
    content = content:gsub("C255_P", path.get_only_name() .. "C255_P")
    content = content:gsub("C255_A24", path.get_only_name() .. "C255_A24")
    content = content:gsub("GEN", path.get_only_name() .. "GEN")
    content = content:gsub("ORDER", path.get_only_name() .. "ORDER")

    return content
end
-- Função para adicionar o prefixo "private_"
local function add_path_control(content)
    -- Adicionar "private_" a nomes de funções globais
    content = content:gsub("([%a_][%w_]*)%s*%(", "private_%1(")

    -- Adicionar "private_" a variáveis globais
    content = content:gsub("([%a_][%w_]*)%s*;", "private_%1;")
    content = content:gsub("([%a_][%w_]*)%s*=%s*[^;]*;", "private_%1 = %2;")

    return content
end

local function main()
    print(ANSI_BLUE .. "Downloading Bear")
    if not dtw.isdir("BearSSL") then
        os.execute("git clone https://www.bearssl.org/git/BearSSL")
    end

    dtw.remove_any("Project")
    dtw.copy_any_overwriting("BearSSL/inc", "Project/inc")
    dtw.copy_any_overwriting("BearSSL/src", "Project/src")



    local src = dtw.newTree_from_hardware("Project/src")
    src.map(function(current)
        if current.path.get_extension() == "c" then
            content = add_path_control(current.get_value())
            current.set_value(content)
            local new_name = "fdefine." .. current.path.get_name()
            current.path.set_name(new_name)
        end

        if current.path.get_extension() == "h" then
            -- content = add_path_control(current.get_value())
            current.set_value(content)
            local new_name = "fdeclare." .. current.path.get_name()
            current.path.set_name(new_name)
        end
        current.hardware_modify()
    end)

    src.commit()

    silver_chain.generate_code(
        "Project/src",
        "Project/imports",
        "bear_ssl",
        { "bear", "fdeclare", "fdefine" }
    )
end
main()
