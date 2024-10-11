-- Função que detecta declarações de funções em C
function detectar_funcoes_c(codigo)
    -- Expressão regular para capturar declarações de funções
    local padrao =
    "%s*([%a_][%w_]*)%s+([%a_][%w_]*)%s*%b()"                -- captura tipo, nome da função, e os parâmetros entre parênteses

    -- Tabela para armazenar as funções encontradas
    local funcoes = {}

    -- Itera sobre todas as correspondências no código-fonte
    for tipo, nome in string.gmatch(codigo, padrao) do
        table.insert(funcoes, { tipo = tipo, nome = nome })
    end

    return funcoes
end

-- Exemplo de uso
local codigo_c = [[
    int soma(int a, int b);
    void imprime(char *mensagem);
    float calcular_media(float nota1, float nota2);
]]

local funcoes = detectar_funcoes_c(codigo_c)

-- Imprime as funções encontradas
for _, funcao in ipairs(funcoes) do
    print("Tipo de retorno: " .. funcao.tipo .. ", Nome da função: " .. funcao.nome)
end
