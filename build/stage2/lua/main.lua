local function aply_replacment(path, content)
    content = content:gsub('#include "inner.h"', '')
    content = content:gsub('#include "config.h"', '')
    content = content:gsub('#include "bearssl.h"', '#include "../inc/bearssl.h"')


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
            content = aply_replacment(current.path, current.get_value())

            final = "namespace " .. current.path.get_only_name() .. "{\n"
            final = final .. content .. "\n}"

            current.set_value(final)
            local new_name = "fdefine." .. current.path.get_name()
            current.path.set_name(new_name)
        end

        if current.path.get_extension() == "h" then
            content = aply_replacment(current.path, current.get_value())
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
