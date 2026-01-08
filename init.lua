--[[
    NEXUS-HUB v7.0 APEX | VELOCITY EDITION
    Baseado no método de interface ultra-estável do usuário
]]

task.wait(1)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- [ LIMPEZA ]
if PlayerGui:FindFirstChild("NexusHubUI") then
    PlayerGui.NexusHubUI:Destroy()
end

-- [ MOTOR DE DESCRIPTOGRAFIA ]
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

function Decryption.decrypt(str)
    if type(str) ~= "string" or #str < 2 then return str, nil end
    local s, b = pcall(HttpService.Base64Decode, HttpService, str)
    if s then return b, "B64" end
    local rev = string.reverse(str)
    if #rev > 4 and rev:match("^[%w%s%p]+$") then return rev, "REV" end
    for i = 1, 255 do
        local res = ""
        for j = 1, #str do res = res .. string.char(bit.bxor(str:byte(j), i)) end
        if res:match("^[%w%s%p]+$") and #res > 5 then return res, "XOR-1B" end
    end
    return str, nil
end

-- [ INTERFACE ]
local gui = Instance.new("ScreenGui")
gui.Name = "NexusHubUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 450, 0, 320)
main.Position = UDim2.new(0.5, -225, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
Instance.new("UICorner", main)

local title = Instance.new("TextLabel")
title.Parent = main
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
title.Text = "NEXUS HUB - VELOCITY v7.0"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
Instance.new("UICorner", title)

local close = Instance.new("TextButton")
close.Parent = title
close.Size = UDim2.new(0, 30, 0, 25)
close.Position = UDim2.new(1, -35, 0.5, -12)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
Instance.new("UICorner", close)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- [ CONTAINER DE LOGS ]
local container = Instance.new("ScrollingFrame", main)
container.Size = UDim2.new(0.94, 0, 0.65, 0)
container.Position = UDim2.new(0.03, 0, 0.15, 0)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
container.ScrollBarThickness = 3
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 5)

local toggle = Instance.new("TextButton")
toggle.Parent = main
toggle.Size = UDim2.new(0, 180, 0, 40)
toggle.Position = UDim2.new(0.5, -90, 0.9, -25)
toggle.Text = "START"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 120)
Instance.new("UICorner", toggle)

_G.NexusActive = false

toggle.MouseButton1Click:Connect(function()
    _G.NexusActive = not _G.NexusActive
    toggle.Text = _G.NexusActive and "STOP" or "START"
    toggle.BackgroundColor3 = _G.NexusActive
        and Color3.fromRGB(200, 60, 60)
        or Color3.fromRGB(0, 170, 120)
end)

-- [ DRAGGING ]
local dragging = false
local dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
main.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- [ LOGICA DE CAPTURA ]
local function addLog(remote, method, args)
    local logFrame = Instance.new("Frame", container)
    logFrame.Size = UDim2.new(1, -5, 0, 70)
    logFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", logFrame)
    
    local txt = Instance.new("TextLabel", logFrame)
    txt.Size = UDim2.new(1, -10, 1, -10)
    txt.Position = UDim2.new(0, 5, 0, 5)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    txt.Font = Enum.Font.Code
    txt.TextSize = 10
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextYAlignment = Enum.TextYAlignment.Top
    txt.TextWrapped = true
    txt.RichText = true
    
    local argStr = "<b>Args:</b> "
    for i, v in pairs(args) do
        local val = Decryption.safeString(v)
        local dec, tag = Decryption.decrypt(val)
        argStr = argStr .. string.format("[%d]: %s %s ", i, dec, tag and "<font color='#00FF00'>("..tag..")</font>" or "")
    end
    
    txt.Text = string.format("<b>%s</b> (%s)\n%s", remote.Name, method, argStr)
    container.CanvasPosition = Vector2.new(0, 99999)
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if _G.NexusActive and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        task.spawn(function() addLog(self, method, args) end)
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

print("Nexus-Hub: Velocity Edition Carregada!")
