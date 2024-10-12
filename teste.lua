r = [[
    int r+a;
    void ssa(){

    }
]]

local token_pattern = "([^%w])" .. "a" .. "([^%w])"

r = string.gsub(r, token_pattern, "%1teste%2")
print(r)
