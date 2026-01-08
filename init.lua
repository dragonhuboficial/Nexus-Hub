--[[
    NEXUS CORE v7.6 | SMOOTH BRUTALITY
    Otimizado para performance extrema e sem duplicatas.
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

local State = { 
    Active = false, 
    Category = "ALL",
    LastRemotes = {} -- Para filtro de duplicatas
}

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

-- [ INTERFACE ]
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "NexusUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 600, 0, 400)
main.Position = UDim2.new(0.5, -300, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
Instance.new("UICorner", main)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
header.BorderSizePixel = 0
Instance.new("UICorner", header)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "NEXUS CORE v7.6 - SMOOTH BRUTALITY"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", header)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 120, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
sidebar.BorderSizePixel = 0

local function sideBtn(txt, y, cat)
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(1, -10, 0, 30)
    b.Position = UDim2.new(0, 5, 0, y)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() State.Category = cat end)
end

sideBtn("ALL", 10, "ALL")
sideBtn("REMOTES", 45, "REMOTES")
sideBtn("OBJECTS", 80, "OBJECTS")

local container = Instance.new("ScrollingFrame", main)
container.Size = UDim2.new(1, -130, 1, -100)
container.Position = UDim2.new(0, 125, 0, 45)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.AutomaticCanvasSize = Enum.AutomaticSize.Y
container.ScrollBarThickness = 3
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 5)

local bottom = Instance.new("Frame", main)
bottom.Size = UDim2.new(1, 0, 0, 50)
bottom.Position = UDim2.new(0, 0, 1, -50)
bottom.BackgroundColor3 = Color3.fromRGB(20, 20, 30)

local start = Instance.new("TextButton", bottom)
start.Size = UDim2.new(0, 200, 0, 35)
start.Position = UDim2.new(0.5, -100, 0.5, -17)
start.Text = "START CAPTURE"
start.BackgroundColor3 = Color3.fromRGB(0, 160, 110)
start.TextColor3 = Color3.new(1, 1, 1)
start.Font = Enum.Font.GothamBold
Instance.new("UICorner", start)

start.MouseButton1Click:Connect(function()
	State.Active = not State.Active
	start.Text = State.Active and "STOP CAPTURE" or "START CAPTURE"
	start.BackgroundColor3 = State.Active and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(0, 160, 110)
end)

-- [ FUNÇÃO DE LOG OTIMIZADA ]
local function addLog(titleText, contentText, category)
    if State.Category ~= "ALL" and State.Category ~= category then return end

    local logFrame = Instance.new("Frame", container)
    logFrame.Size = UDim2.new(1, -10, 0, 75)
    logFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Instance.new("UICorner", logFrame)

    local t = Instance.new("TextLabel", logFrame)
    t.Size = UDim2.new(1, -80, 0, 20)
    t.Position = UDim2.new(0, 10, 0, 5)
    t.BackgroundTransparency = 1
    t.Text = "[" .. category .. "] " .. titleText
    t.TextColor3 = Color3.fromRGB(0, 180, 255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 11
    t.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", logFrame)
    box.Size = UDim2.new(1, -20, 0, 40)
    box.Position = UDim2.new(0, 10, 0, 25)
    box.BackgroundTransparency = 1
    box.Text = contentText
    box.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    box.Font = Enum.Font.Code
    box.TextSize = 10
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.ClearTextOnFocus = false
    box.ReadOnly = true
    box.TextWrapped = true

    -- BOTÃO DE CÓPIA (GRANDE E VISÍVEL)
    local copyBtn = Instance.new("TextButton", logFrame)
    copyBtn.Size = UDim2.new(0, 70, 0, 25)
    copyBtn.Position = UDim2.new(1, -75, 0, 5)
    copyBtn.Text = "COPY"
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 10
    Instance.new("UICorner", copyBtn)
    
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(contentText)
        copyBtn.Text = "COPIED!"
        task.wait(1)
        copyBtn.Text = "COPY"
    end)

    container.CanvasPosition = Vector2.new(0, 999999)
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

-- [ CAPTURA COM FILTRO ANTI-SPAM ]
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if State.Active and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        local argStr = ""
        for i, v in pairs(args) do argStr = argStr .. Decryption.safeString(v) .. "," end
        
        -- Filtro de Duplicatas (Evita travar o jogo)
        local key = self.Name .. "|" .. argStr
        if State.LastRemotes[key] then return old(self, ...) end
        State.LastRemotes[key] = true
        
        task.spawn(function()
            addLog(self.Name, "Args: " .. argStr, "REMOTES")
        end)
    end
    return old(self, ...)
end)
setreadonly(mt, true)

addLog("SYSTEM", "Nexus Core v7.6 Smooth Brutality Loaded.", "ALL")
