local function main()
    print(ANSI_BLUE .. "Downloading Bear")
    dtw.remove_any("BearSSL")
    os.execute("git clone https://www.bearssl.org/git/BearSSL")

    local all_itens = dtw.newTree_from_hardware("BearSSL/src")
    all_itens.map(function(current)
        if current.path.get_extension() == "c" then
            content = current.get_value()
            content = content:gsub('#include "inner.h"', '')
            local new_name = "fdefine." .. current.path.get_name()
            current.path.set_name(new_name)
        end

        if current.path.get_extension() == "h" then
            local new_name = "fdeclare." .. current.path.get_name()
            current.path.set_name(new_name)
        end
        current.hardware_modify()
    end)

    all_itens.commit()



    silver_chain.generate_code(
        "BearSSL",
        "BearSSL/imports",
        "bear_ssl",
        { "fdeclare", "fdefine" }
    )
end
main()
