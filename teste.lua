-- Função para adicionar o prefixo "private_"
local function add_path_control(code)
    -- Adicionar "private_" a nomes de funções globais
    code = code:gsub("([%a_][%w_]*)%s*%(", "private_%1(")

    -- Adicionar "private_" a variáveis globais
    code = code:gsub("([%a_][%w_]*)%s*;", "private_%1;")
    code = code:gsub("([%a_][%w_]*)%s*=%s*[^;]*;", "private_%1 = %2;")
    return code
end
