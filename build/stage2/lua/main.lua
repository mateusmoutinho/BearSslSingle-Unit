local function main()
    print(ANSI_BLUE .. "Downloading Bear")

    if not dtw.isdir("BearSSL") then
        os.execute("git clone https://www.bearssl.org/git/BearSSL")
    end

    dtw.remove_any("BearSSLSingleUnit")
    dtw.copy_any_overwriting("BearSSL/inc", "BearSSLSingleUnit/inc")
    dtw.copy_any_overwriting("BearSSL/src", "BearSSLSingleUnit/src")

    local src = dtw.newTree_from_hardware("BearSSLSingleUnit/src")
    main_replace_json = json.load_from_file("main_replace.json")

    src.each(function(current)
        Aply_file_modification(main_replace_json, current)
    end)
    src.commit()
    dtw.copy_any_overwriting("one.c", "BearSSLSingleUnit/one.c")

    silver_chain.generate_code(
        "BearSSLSingleUnit/src",
        "BearSSLSingleUnit/imports",
        "bear_ssl",
        { "bear", "fdeclare", "fdefine" }
    )
end
main()
