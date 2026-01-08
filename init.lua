-- NEXUS HUB - VELOCITY (ULTRA STABLE)
task.wait(1)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Remover GUI antiga
if PlayerGui:FindFirstChild("NexusHubUI") then
    PlayerGui.NexusHubUI:Destroy()
end

-- Criar ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "NexusHubUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Frame Principal
local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Parent = gui
main.Size = UDim2.new(0, 350, 0, 200)
main.Position = UDim2.new(0.5, -175, 0.5, -100)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(0, 170, 255)

-- Titulo
local title = Instance.new("TextLabel")
title.Parent = main
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "NEXUS HUB - VELOCITY"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16

-- Botao Fechar
local close = Instance.new("TextButton")
close.Parent = title
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -30, 0, 0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Botao START/STOP
local toggle = Instance.new("TextButton")
toggle.Parent = main
toggle.Size = UDim2.new(0, 150, 0, 40)
toggle.Position = UDim2.new(0.5, -75, 0.5, -10)
toggle.Text = "START"
toggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.SourceSansBold

_G.NexusActive = false

toggle.MouseButton1Click:Connect(function()
    _G.NexusActive = not _G.NexusActive
    toggle.Text = _G.NexusActive and "STOP" or "START"
    toggle.BackgroundColor3 = _G.NexusActive and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
end)

-- Drag Manual
local dragging = false
local dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Captura de Remotes (Simples)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if _G.NexusActive and (method == "FireServer" or method == "InvokeServer") then
        print("[NEXUS] Remote: " .. self.Name .. " | Method: " .. method)
    end
    return old(self, ...)
end)
setreadonly(mt, true)
