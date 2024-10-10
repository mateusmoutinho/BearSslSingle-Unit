-- Função para adicionar o prefixo "private_"
local function add_path_control(code)
    return code
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
            local content = add_path_control(current.get_value())
            current.set_value(content)

            local new_name = "fdefine." .. current.path.get_name()
            current.path.set_name(new_name)
            current.hardware_modify()
        end

        if current.path.get_extension() == "h" then
            --  content = add_path_control(current.get_value())
            --current.set_value(content)
            local new_name = "fdeclare." .. current.path.get_name()
            current.path.set_name(new_name)
            current.hardware_modify()
        end
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
