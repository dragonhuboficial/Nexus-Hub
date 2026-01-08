--[[
    NEXUS PHANTOM v7.0 APEX | VISIBILITY OVERHAUL
    Focado em garantir que o texto apareça no Delta
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

local Phantom = { Active = false }

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

function Decryption.deepDecrypt(str, depth)
    depth = depth or 0
    if depth > 2 or type(str) ~= "string" or #str < 2 then return str, nil end
    local s, b = pcall(HttpService.Base64Decode, HttpService, str)
    if s then return Decryption.deepDecrypt(b, depth + 1) end
    local rev = string.reverse(str)
    if #rev > 4 and rev:match("^[%w%s%p]+$") then return Decryption.deepDecrypt(rev, depth + 1) end
    return str, nil
end

-- [ INTERFACE ]
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "NexusUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 720, 0, 420)
main.Position = UDim2.new(0.5, -360, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(0, 170, 255)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "NEXUS PHANTOM - VISIBILITY MODE"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", header)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
close.TextColor3 = Color3.new(1, 1, 1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 140, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
sidebar.BorderSizePixel = 0

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -140, 1, -90)
content.Position = UDim2.new(0, 140, 0, 40)
content.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
content.BorderSizePixel = 0

local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(1, -10, 1, -10)
scroll.Position = UDim2.new(0, 5, 0, 5)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 4)

local bottom = Instance.new("Frame", main)
bottom.Size = UDim2.new(1, 0, 0, 50)
bottom.Position = UDim2.new(0, 0, 1, -50)
bottom.BackgroundColor3 = Color3.fromRGB(25, 25, 35)

local start = Instance.new("TextButton", bottom)
start.Size = UDim2.new(0, 200, 0, 35)
start.Position = UDim2.new(0.5, -100, 0.5, -17)
start.Text = "START CAPTURE"
start.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
start.TextColor3 = Color3.new(1, 1, 1)
start.Font = Enum.Font.SourceSansBold

start.MouseButton1Click:Connect(function()
	Phantom.Active = not Phantom.Active
	start.Text = Phantom.Active and "STOP CAPTURE" or "START CAPTURE"
	start.BackgroundColor3 = Phantom.Active and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
end)

local function addLog(txt)
    local label = Instance.new("TextLabel", scroll)
    label.Size = UDim2.new(1, -10, 0, 35)
    label.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    label.BorderSizePixel = 1
    label.BorderColor3 = Color3.fromRGB(60, 60, 70)
    label.Text = "  " .. tostring(txt)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.ZIndex = 10
    
    -- Ajuste de altura simples
    if #tostring(txt) > 50 then
        label.Size = UDim2.new(1, -10, 0, 50)
    end
    
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

-- [ CAPTURA ]
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if Phantom.Active and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        task.spawn(function()
            local argStr = ""
            for i, v in pairs(args) do argStr = argStr .. tostring(i) .. ":" .. Decryption.safeString(v) .. " " end
            addLog(self.Name .. " | " .. argStr)
        end)
    end
    return old(self, ...)
end)
setreadonly(mt, true)

addLog("SYSTEM: Nexus Phantom Loaded (Visibility Mode)")
