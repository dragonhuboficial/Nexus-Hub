local HttpService = game:GetService("HttpService")

local Decryption = {}

-- [ UTILITÁRIOS ]
function Decryption.safeString(v, depth)
    depth = depth or 0
    if depth > 2 then return "..." end
    local t = typeof(v)
    if t == "table" then
        local s = "{"
        local count = 0
        for k, val in pairs(v) do
            count = count + 1
            if count > 6 then s = s .. "...," break end
            local key = type(k) == "string" and "[\""..k.."\"]" or "["..tostring(k).."]"
            s = s .. key .. "=" .. Decryption.safeString(val, depth + 1) .. ","
        end
        return (count > 0 and s:sub(1, #s-1) or s) .. "}"
    elseif t == "string" then
        return "\"" .. v .. "\""
    elseif t == "Instance" then
        return "game." .. v:GetFullName()
    end
    return tostring(v)
end

-- [ GERADOR DE SNIPPETS ]
function Decryption.generateSnippet(remote, method, args)
    local path = "game." .. remote:GetFullName()
    local argList = {}
    for _, v in pairs(args) do
        table.insert(argList, Decryption.safeString(v))
    end
    local argsStr = table.concat(argList, ", ")
    
    if method == "FireServer" then
        return string.format("%s:FireServer(%s)", path, argsStr)
    else
        return string.format("local res = %s:InvokeServer(%s)\nprint(res)", path, argsStr)
    end
end

-- [ MOTOR DE DESCRIPTOGRAFIA ]
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
        return #str > 3 and rev or nil, "REV"
    end,
    XOR_1B = function(str)
        for i = 1, 255 do
            local res = ""
            for j = 1, #str do
                res = res .. string.char(bit.bxor(str:byte(j), i))
            end
            if res:match("^[%w%s%p]+$") and #res > 5 then
                return res, "XOR-1B"
            end
        end
        return nil
    end
}

function Decryption.decrypt(str, depth)
    depth = depth or 0
    if depth > 3 or type(str) ~= "string" or #str < 2 then return str, nil end
    
    for name, algo in pairs(Algorithms) do
        local res, tag = algo(str)
        if res and res ~= str then
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
