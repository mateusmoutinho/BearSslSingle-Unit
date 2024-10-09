-- Função para adicionar o prefixo "private_"
local function adicionar_private(codigo)
    -- Adicionar "private_" a nomes de funções globais
    codigo = codigo:gsub("([%a_][%w_]*)%s*%(", "private_%1(")

    -- Adicionar "private_" a variáveis globais
    codigo = codigo:gsub("([%a_][%w_]*)%s*;", "private_%1;")
    codigo = codigo:gsub("([%a_][%w_]*)%s*=%s*[^;]*;", "private_%1 = %2;")

    return codigo
end
