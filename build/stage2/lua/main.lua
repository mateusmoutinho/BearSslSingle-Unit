local function main()
    print(ANSI_BLUE .. "Downloading Bear")

    if not dtw.isdir("BearSSL") then
        os.execute("git clone " .. PROVIDER_GIT)
    end

    local single_unit_point = dtw.concat_path(RELEASE_FOLDER, SINGLE_UNIT_FOLDER)
    dtw.remove_any(single_unit_point)

    dtw.copy_any_overwriting("BearSSL/inc", single_unit_point .. "/inc")


    local src = dtw.newTree_from_hardware("BearSSL/src")
    main_replace_json = json.load_from_file("main_replace.json")

    src.each(function(current)
        Aply_file_modification(main_replace_json, current)
    end)
    src.commit()

    silver_chain.generate_code(
        single_unit_point .. "/src",
        single_unit_point .. "/imports",
        SILVER_CHAIN_NAME,
        { "bear", DECLARE_NAME, DEFINE_NAME }
    )
    local new_src = dtw.newTree_from_hardware(single_unit_point)
    new_src.each(generate_json_modification_in_part)
    new_src.commit()


    dtw.copy_any_merging("BearModel", single_unit_point)
end
main()
