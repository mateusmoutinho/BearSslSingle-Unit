local function main()
    print(ANSI_BLUE .. "Downloading Bear")

    if not dtw.isdir("BearSSL") then
        os.execute("git clone " .. PROVIDER_GIT)
    end

    dtw.remove_any(SINGLE_UNIT_FOLDER)
    dtw.copy_any_overwriting("BearSSL/inc", SINGLE_UNIT_FOLDER .. "/inc")
    dtw.copy_any_overwriting("BearSSL/src", SINGLE_UNIT_FOLDER .. "/src")

    local src = dtw.newTree_from_hardware(SINGLE_UNIT_FOLDER .. "/src")
    main_replace_json = json.load_from_file("main_replace.json")

    src.each(function(current)
        Aply_file_modification(main_replace_json, current)
    end)
    src.commit()
    dtw.copy_any_overwriting("one.c", SINGLE_UNIT_FOLDER .. "/one.c")

    silver_chain.generate_code(
        SINGLE_UNIT_FOLDER .. "/src",
        SINGLE_UNIT_FOLDER .. "/imports",
        SILVER_CHAIN_NAME,
        { "bear", DECLARE_NAME, DEFINE_NAME }
    )
end
main()
