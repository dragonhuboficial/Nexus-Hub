--[[
    NEXUS CORE v7.7 | ADAPTIVE INTELLIGENCE
    "Strategy, Intelligence, Stealth."
]]

task.wait(1)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("NexusUI") then
	PlayerGui.NexusUI:Destroy()
end

-- [ ESTADO GLOBAL ]
local Nexus = {
    Active = false,
    StealthMode = false,
    Queue = {},
    ProcessedKeys = {},
    AntiCheatDetected = false
}

-- [ MOTOR DE DESCRIPTOGRAFIA INTELIGENTE ]
local Decryption = {}
function Decryption.safeString(v)
    local t = typeof(v)
    if t == "table" then
        local s = "{"
        for k, val in pairs(v) do s = s .. tostring(k) .. ":" .. tostring(val) .. "," end
        return (#s > 1 and s:sub(1, #s-1) or s) .. "}"
    elseif t == "Instance" then return v.Name end
    return tostring(v)
end

function Decryption.smartDecrypt(str)
    if type(str) ~= "string" or #str < 3 then return str, nil end
    
    -- Tenta Base64
    local s, b = pcall(HttpService.Base64Decode, HttpService, str)
    if s and #b > 2 then return b, "B64" end
    
    -- Tenta Reverse (apenas se parecer encriptado)
    if not str:match(" ") and #str > 6 then
        local rev = string.reverse(str)
        if rev:match("^[%w%s%p]+$") then return rev, "REV" end
    end
    
    -- Tenta XOR 1-Byte (Brute Force Inteligente)
    if #str > 5 and not str:match(" ") then
        for i = 1, 255 do
            local res = ""
            for j = 1, #str do res = res .. string.char(bit.bxor(str:byte(j), i)) end
            if res:match("^[%w%s%p]+$") and #res > 5 and res:match("[aeiou]") then
                return res, "XOR"
            end
        end
    end
    
    return str, nil
end

-- [ INTERFACE ]
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "NexusUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 350)
main.Position = UDim2.new(0.5, -250, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
Instance.new("UICorner", main)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
header.BorderSizePixel = 0
Instance.new("UICorner", header)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "NEXUS CORE v7.7 | ADAPTIVE"
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local close = Instance.new("TextButton", header)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.94, 0, 0.65, 0)
scroll.Position = UDim2.new(0.03, 0, 0.15, 0)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 2
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

local start = Instance.new("TextButton", main)
start.Size = UDim2.new(0, 200, 0, 40)
start.Position = UDim2.new(0.5, -100, 0.9, -20)
start.Text = "INITIALIZE PHANTOM"
start.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
start.TextColor3 = Color3.new(1, 1, 1)
start.Font = Enum.Font.GothamBold
Instance.new("UICorner", start)

-- [ LOGICA DE FILA (ANTI-LAG) ]
local function processQueue()
    while true do
        if #Nexus.Queue > 0 then
            local data = table.remove(Nexus.Queue, 1)
            local log = Instance.new("TextBox", scroll)
            log.Size = UDim2.new(1, -10, 0, 40)
            log.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            log.Text = " [" .. data.Type .. "] " .. data.Name .. " | " .. data.Content
            log.TextColor3 = Color3.new(1, 1, 1)
            log.Font = Enum.Font.Code
            log.TextSize = 10
            log.ReadOnly = true
            log.ClearTextOnFocus = false
            log.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", log)
            
            if #scroll:GetChildren() > 50 then scroll:GetChildren()[2]:Destroy() end -- Limita logs na tela
            scroll.CanvasPosition = Vector2.new(0, 99999)
        end
        task.wait(0.1) -- Processa 10 por segundo para não travar
    end
end
task.spawn(processQueue)

-- [ RECONHECIMENTO E CAPTURA ]
start.MouseButton1Click:Connect(function()
    Nexus.Active = not Nexus.Active
    start.Text = Nexus.Active and "PHANTOM ACTIVE" or "INITIALIZE PHANTOM"
    start.BackgroundColor3 = Nexus.Active and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(0, 150, 100)
    
    if Nexus.Active then
        table.insert(Nexus.Queue, {Type = "SYSTEM", Name = "RECON", Content = "Analyzing Game Defenses..."})
    end
end)

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    -- Anti-Kick Bypass Automático
    if method == "Kick" and self == player then
        table.insert(Nexus.Queue, {Type = "BYPASS", Name = "KICK", Content = "Blocked Kick Attempt!"})
        return nil
    end

    if Nexus.Active and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        local argStr = ""
        for i, v in pairs(args) do
            local val = Decryption.safeString(v)
            local dec, tag = Decryption.smartDecrypt(val)
            argStr = argStr .. "["..i.."]: " .. dec .. (tag and " ("..tag..")" or "") .. " "
        end
        
        -- Filtro de Duplicatas
        local key = self.Name .. argStr
        if not Nexus.ProcessedKeys[key] then
            Nexus.ProcessedKeys[key] = true
            table.insert(Nexus.Queue, {Type = "REMOTE", Name = self.Name, Content = argStr})
        end
    end
    return old(self, ...)
end)

setreadonly(mt, true)

-- Dragging
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
header.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
