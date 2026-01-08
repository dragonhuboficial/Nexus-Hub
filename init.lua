--[[
    NEXUS PHANTOM v7.0 APEX | INTELLIGENT CAPTURE
    "Strategy over Brutality"
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

-- [ MOTOR DE INTELIGÊNCIA PHANTOM ]
local Phantom = {
    Active = false,
    SafeMode = true,
    DetectedAntiCheats = {},
    Methods = {"B64", "REV", "XOR-1B", "ROT13"}
}

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

-- Descriptografia Recursiva (Tenta várias camadas)
function Decryption.deepDecrypt(str, depth)
    depth = depth or 0
    if depth > 3 or type(str) ~= "string" or #str < 2 then return str, nil end
    
    local current = str
    local methodsUsed = {}
    
    -- 1. Base64
    local s, b = pcall(HttpService.Base64Decode, HttpService, current)
    if s then 
        local res, sub = Decryption.deepDecrypt(b, depth + 1)
        return res, "B64" .. (sub and "+"..sub or "")
    end
    
    -- 2. Reverse
    local rev = string.reverse(current)
    if #rev > 4 and rev:match("^[%w%s%p]+$") then 
        local res, sub = Decryption.deepDecrypt(rev, depth + 1)
        return res, "REV" .. (sub and "+"..sub or "")
    end
    
    -- 3. XOR 1-Byte
    for i = 1, 255 do
        local res = ""
        for j = 1, #current do res = res .. string.char(bit.bxor(current:byte(j), i)) end
        if res:match("^[%w%s%p]+$") and #res > 5 then 
            local final, sub = Decryption.deepDecrypt(res, depth + 1)
            return final, "XOR" .. (sub and "+"..sub or "")
        end
    end
    
    return current, nil
end

-- [ INTERFACE NEXUS UI ]
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "NexusUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 720, 0, 420)
main.Position = UDim2.new(0.5, -360, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(18,18,26)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,44)
header.BackgroundColor3 = Color3.fromRGB(30,30,48)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-200,1,0)
title.Position = UDim2.new(0,16,0,0)
title.BackgroundTransparency = 1
title.Text = "NEXUS • PHANTOM INTELLIGENCE"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(230,230,255)
title.TextXAlignment = Enum.TextXAlignment.Left

local function topButton(txt, x, color)
	local b = Instance.new("TextButton", header)
	b.Size = UDim2.new(0,80,0,26)
	b.Position = UDim2.new(1, x, 0.5, -13)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = color or Color3.fromRGB(60,60,90)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

local btnClose = topButton("CLOSE", -90, Color3.fromRGB(150, 50, 50))
local btnClear = topButton("CLEAR", -180)

btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0,150,1,-44)
sidebar.Position = UDim2.new(0,0,0,44)
sidebar.BackgroundColor3 = Color3.fromRGB(22,22,36)
sidebar.BorderSizePixel = 0

local function sideButton(txt, y)
	local b = Instance.new("TextButton", sidebar)
	b.Size = UDim2.new(1,-16,0,34)
	b.Position = UDim2.new(0,8,0,y)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.TextColor3 = Color3.fromRGB(220,220,240)
	b.BackgroundColor3 = Color3.fromRGB(40,40,60)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	return b
end

sideButton("ALL", 12)
sideButton("REMOTES", 52)
sideButton("OBJECTS", 92)
sideButton("MODULES", 132)
sideButton("FOLDERS", 172)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,-150,1,-100)
content.Position = UDim2.new(0,150,0,44)
content.BackgroundColor3 = Color3.fromRGB(14,14,22)
content.BorderSizePixel = 0

local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(1,-10,1,-10)
scroll.Position = UDim2.new(0,5,0,5)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarImageTransparency = 0.6
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

local bottom = Instance.new("Frame", main)
bottom.Size = UDim2.new(1,0,0,56)
bottom.Position = UDim2.new(0,0,1,-56)
bottom.BackgroundColor3 = Color3.fromRGB(26,26,40)
bottom.BorderSizePixel = 0

local start = Instance.new("TextButton", bottom)
start.Size = UDim2.new(0,220,0,36)
start.Position = UDim2.new(0.5,-110,0.5,-18)
start.Text = "ACTIVATE PHANTOM"
start.Font = Enum.Font.GothamBold
start.TextSize = 13
start.TextColor3 = Color3.new(1,1,1)
start.BackgroundColor3 = Color3.fromRGB(0,170,130)
Instance.new("UICorner", start).CornerRadius = UDim.new(0,12)

start.MouseButton1Click:Connect(function()
	Phantom.Active = not Phantom.Active
	start.Text = Phantom.Active and "PHANTOM ACTIVE" or "ACTIVATE PHANTOM"
	start.BackgroundColor3 = Phantom.Active and Color3.fromRGB(200,70,70) or Color3.fromRGB(0,170,130)
end)

btnClear.MouseButton1Click:Connect(function()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
end)

local function addLog(text)
	local item = Instance.new("TextLabel", scroll)
	item.Size = UDim2.new(1,-8,0,32)
	item.BackgroundColor3 = Color3.fromRGB(30,30,46)
	item.Text = " "..text
	item.TextColor3 = Color3.fromRGB(210,210,235)
	item.Font = Enum.Font.Code
	item.TextSize = 11
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.RichText = true
	Instance.new("UICorner", item).CornerRadius = UDim.new(0,8)
    scroll.CanvasPosition = Vector2.new(0, 999999)
end

-- [ DRAGGING ]
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

-- [ LOGICA DE CAPTURA PHANTOM ]
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    -- Anti-Kick Detection (Monitora se o jogo tenta te expulsar)
    if method == "Kick" and self == player then
        addLog("<font color='#FF0000'>[WARNING]</font> Game tried to KICK you! Blocked.")
        return nil
    end

    if Phantom.Active and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        task.spawn(function()
            local argStr = ""
            for i, v in pairs(args) do
                local val = Decryption.safeString(v)
                local dec, tag = Decryption.deepDecrypt(val)
                argStr = argStr .. string.format("[%d]: %s %s ", i, dec, tag and "<font color='#00FF00'>("..tag..")</font>" or "")
            end
            addLog(string.format("<b>%s</b> | %s", self.Name, argStr))
        end)
    end
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)
addLog("SYSTEM | Nexus Phantom Intelligence Loaded")
