local function main()
    print(ANSI_BLUE .. "Downloading Bear")

    if not dtw.isdir("BearSSL") then
        os.execute("git clone " .. PROVIDER_GIT)
    end
    local main_replace = json.load_from_file("main_replace.json")
    local src = dtw.newTree_from_hardware("BearSSL/src")
    dtw.remove_any(RELEASE_FODER)
    local modifiers = Create_modifiers(src)
    Generate_modifications(modifiers, main_replace)
    src.commit()
    --collect_tags()
    local single_unit_dir = dtw.concat_path(RELEASE_FODER, SINGLE_UNIT_FOLDER)
    dtw.copy_any_overwriting("BearSSL/inc", dtw.concat_path(single_unit_dir, "inc"))
    local src = dtw.concat_path(single_unit_dir, "src")
    silver_chain.generate_code(
        src,
        dtw.concat_path(src, "imports"),
        SILVER_CHAIN_NAME,
        { "bear", DECLARE_NAME, DEFINE_NAME }
    )
    Create_summary(modifiers)
end
main()
