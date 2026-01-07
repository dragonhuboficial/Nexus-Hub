local HttpService = game:GetService("HttpService")

local Decryption = {}

function Decryption.safeString(v, depth)
    depth = depth or 0
    if depth > 2 then return "..." end
    local t = typeof(v)
    if t == "table" then
        local s = "{"
        for k, val in pairs(v) do
            s = s .. tostring(k) .. ":" .. Decryption.safeString(val, depth + 1) .. ","
        end
        return s:sub(1, #s-1) .. "}"
    elseif t == "Instance" then
        return v.ClassName .. ":" .. v.Name
    end
    return tostring(v)
end

function Decryption.decrypt(str)
    if type(str) ~= "string" then return str end
    
    -- Base64
    local s, b = pcall(HttpService.Base64Decode, HttpService, str)
    if s then return "[B64] " .. b end
    
    -- JSON Check
    local s, j = pcall(HttpService.JSONDecode, HttpService, str)
    if s then return "[JSON] " .. Decryption.safeString(j) end
    
    -- XOR Heuristic (Simple)
    local xorKeys = {"key", "auth", "secret"}
    for _, k in pairs(xorKeys) do
        local res = ""
        for i = 1, #str do
            res = res .. string.char(bit.bxor(str:byte(i), k:byte((i-1)%#k+1)))
        end
        if res:match("^[%w%s%p]+$") and #res > 3 then
            return "[XOR-"..k.."] " .. res
        end
    end
    
    return str
end

return Decryption
