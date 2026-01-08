local HttpService = game:GetService("HttpService")

local Decryption = {}

-- [ UTILITÁRIOS ]
function Decryption.isReadable(str)
    if type(str) ~= "string" or #str < 2 then return false end
    local readableChars = 0
    for i = 1, #str do
        local c = str:byte(i)
        if (c >= 32 and c <= 126) or c == 10 or c == 13 then
            readableChars = readableChars + 1
        end
    end
    return (readableChars / #str) > 0.75
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
            if count > 8 then s = s .. "...," break end
            s = s .. tostring(k) .. ":" .. Decryption.safeString(val, depth + 1) .. ","
        end
        return (count > 0 and s:sub(1, #s-1) or s) .. "}"
    elseif t == "Instance" then
        return v.ClassName .. ":" .. v.Name
    elseif t == "string" then
        return #v > 100 and v:sub(1, 97) .. "..." or v
    end
    return tostring(v)
end

-- [ ALGORITMOS DE ELITE ]
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
        return (rev ~= str and Decryption.isReadable(rev)) and rev or nil, "REV"
    end,
    XOR_Brute = function(str)
        -- Tenta chaves comuns e chaves baseadas no tamanho da string
        local keys = {"key", "auth", "secret", "nexus", "delta", "roblox", "encrypt"}
        for _, k in pairs(keys) do
            local res = ""
            for i = 1, #str do
                res = res .. string.char(bit.bxor(str:byte(i), k:byte((i-1)%#k+1)))
            end
            if Decryption.isReadable(res) then return res, "XOR-"..k end
        end
        
        -- Brute-force de 1 byte (muito comum em jogos simples)
        for i = 1, 255 do
            local res = ""
            for j = 1, #str do
                res = res .. string.char(bit.bxor(str:byte(j), i))
            end
            if Decryption.isReadable(res) and #res > 4 then
                return res, "XOR-1B("..i..")"
            end
        end
        return nil
    end,
    ByteShift = function(str)
        -- Tenta deslocamento de bytes simples
        local res = ""
        for i = 1, #str do
            res = res .. string.char((str:byte(i) - 1) % 256)
        end
        if Decryption.isReadable(res) then return res, "SHIFT-1" end
        return nil
    end
}

-- [ MOTOR DE NORMALIZAÇÃO ]
function Decryption.decrypt(str, depth)
    depth = depth or 0
    if depth > 4 or type(str) ~= "string" or #str < 2 then return str, nil end
    
    for name, algo in pairs(Algorithms) do
        local res, tag = algo(str)
        if res and res ~= str then
            -- Recursão para quebrar múltiplas camadas
            local deeperRes, deeperTags = Decryption.decrypt(res, depth + 1)
            if deeperRes ~= res then
                return deeperRes, tag .. "+" .. (deeperTags or "")
            end
            return res, tag
        end
    end
    
    return str, nil
end

return Decryption
