local function main()
    print(ANSI_BLUE .. "Downloading Bear")

    if not dtw.isdir("BearSSL") then
        os.execute("git clone " .. PROVIDER_GIT)
    end


        --collect_tags()
        [[
    dtw.remove_any(SINGLE_UNIT_FOLDER)
    dtw.copy_any_overwriting("BearSSL/inc", SINGLE_UNIT_FOLDER .. "/inc")
    dtw.copy_any_overwriting("BearSSL/src", SINGLE_UNIT_FOLDER .. "/src")



        silver_chain.generate_code(
        SINGLE_UNIT_FOLDER .. "/src",
        SINGLE_UNIT_FOLDER .. "/imports",
        SILVER_CHAIN_NAME,
        { "bear", DECLARE_NAME, DEFINE_NAME }
        )
        ]]
end
main()
