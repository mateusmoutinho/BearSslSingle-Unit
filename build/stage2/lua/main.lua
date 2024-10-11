local function main()
    print(ANSI_BLUE .. "Downloading Bear")

    if not dtw.isdir("BearSSL") then
        os.execute("git clone " .. PROVIDER_GIT)
    end
    local main_replace = json.load_from_file("main_replace.json")
    local src = dtw.newTree_from_hardware("BearSSL/src")

    local modifiers = Create_modifiers(src)
    Generate_modifications(modifiers)
    src.commit()
    --collect_tags()
    local single_unit_dir = dtw.concat_path(RELEASE_FODER, SINGLE_UNIT_FOLDER)
    dtw.copy_any_overwriting("BearSSL/inc", dtw.concat_path(single_unit_dir, "inc"))

    silver_chain.generate_code(
        dtw.concat_path(single_unit_dir, "src"),
        dtw.concat_path(single_unit_dir, "imports"),
        SILVER_CHAIN_NAME,
        { "bear", DECLARE_NAME, DEFINE_NAME }
    )
    Create_summary(modifiers)
end
main()
