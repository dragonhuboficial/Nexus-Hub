local HttpService = game:GetService("HttpService")

local Decryption = {}

-- [ UTILITÁRIOS DE STRING ]
function Decryption.reverseString(str)
    return string.reverse(str)
end

function Decryption.isReadable(str)
    if type(str) ~= "string" or #str < 2 then return false end
    -- Verifica se contém caracteres comuns de texto e não apenas lixo binário
    local readableChars = 0
    for i = 1, #str do
        local c = str:byte(i)
        if (c >= 32 and c <= 126) or c == 10 or c == 13 then
            readableChars = readableChars + 1
        end
    end
    return (readableChars / #str) > 0.8
end

function Decryption.safeString(v, depth)
    depth = depth or 0
    if depth > 2 then return "..." end
    local t = typeof(v)
    if t == "table" then
        local s = "{"
        local count = 0
        for k, val in pairs(v) do
            count = count + 1
            if count > 10 then s = s .. "...," break end
            s = s .. tostring(k) .. ":" .. Decryption.safeString(val, depth + 1) .. ","
        end
        return (count > 0 and s:sub(1, #s-1) or s) .. "}"
    elseif t == "Instance" then
        return v.ClassName .. ":" .. v.Name
    end
    return tostring(v)
end

-- [ ALGORITMOS ]
local Algorithms = {
    Base64 = function(str)
        local s, b = pcall(HttpService.Base64Decode, HttpService, str)
        return s and b or nil, "B64"
    end,
    JSON = function(str)
        local s, j = pcall(HttpService.JSONDecode, HttpService, str)
        return s and Decryption.safeString(j) or nil, "JSON"
    end,
    Reverse = function(str)
        local rev = string.reverse(str)
        return rev ~= str and rev or nil, "REV"
    end,
    ROT13 = function(str)
        return str:gsub(".", function(c)
            local b = c:byte()
            if (b >= 65 and b <= 90) then
                return string.char((b - 65 + 13) % 26 + 65)
            elseif (b >= 97 and b <= 122) then
                return string.char((b - 97 + 13) % 26 + 97)
            else
                return c
            end
        end), "ROT13"
    end,
    XOR_Common = function(str)
        local keys = {"key", "auth", "secret", "nexus", "delta"}
        for _, k in pairs(keys) do
            local res = ""
            for i = 1, #str do
                res = res .. string.char(bit.bxor(str:byte(i), k:byte((i-1)%#k+1)))
            end
            if Decryption.isReadable(res) then return res, "XOR-"..k end
        end
        return nil
    end
}

-- [ MOTOR RECURSIVO ]
function Decryption.decrypt(str, depth)
    depth = depth or 0
    if depth > 3 or type(str) ~= "string" or #str < 2 then return str, nil end
    
    local bestResult = str
    local methodsUsed = {}

    for name, algo in pairs(Algorithms) do
        local res, tag = algo(str)
        if res and res ~= str then
            -- Se o resultado for legível ou uma tabela/JSON, tentamos recursão
            if Decryption.isReadable(res) or res:sub(1,1) == "{" then
                local deeperRes, deeperTags = Decryption.decrypt(res, depth + 1)
                if deeperRes ~= res then
                    return deeperRes, tag .. "->" .. (deeperTags or "")
                end
                return res, tag
            end
        end
    end
    
    return str, nil
end

return Decryption
