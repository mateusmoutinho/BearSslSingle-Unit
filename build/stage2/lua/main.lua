local function aply_replacment(content)
    content = content:gsub('#include "inner.h"', '')
    content = content:gsub('#include "config.h"', '')

    return content
end

local function main()
    print(ANSI_BLUE .. "Downloading Bear")
    if not dtw.isdir("BearSSL") then
        os.execute("git clone https://www.bearssl.org/git/BearSSL")
    end

    dtw.remove_any("Project")
    dtw.copy_any_merging("BearSSL", "Project")

    local inc = dtw.newTree_from_hardware("Project/inc")
    inc.map(function(current)
        content = aply_replacment(current.get_value())
        current.set_value(content)
        local new_name = "bearl." .. current.path.get_name()
        current.path.set_name(new_name)
        current.path.set_dir("Project/src/inc")
        current.hardware_modify()
    end)

    inc.commit()

    local src = dtw.newTree_from_hardware("Project/src")
    src.map(function(current)
        if current.path.get_extension() == "c" then
            content = aply_replacment(current.get_value())
            current.set_value(content)
            local new_name = "fdefine." .. current.path.get_name()
            current.path.set_name(new_name)
        end

        if current.path.get_extension() == "h" then
            content = aply_replacment(current.get_value())
            current.set_value(content)
            local new_name = "fdeclare." .. current.path.get_name()
            current.path.set_name(new_name)
        end
        current.hardware_modify()
    end)

    src.commit()

    silver_chain.generate_code(
        "Project",
        "Project/src/imports",
        "bear_ssl",
        { "bear", "fdeclare", "fdefine" }
    )
end
main()
