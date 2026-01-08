task.wait(1)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("NexusHubUI") then
    PlayerGui.NexusHubUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "NexusHubUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 400, 0, 260)
main.Position = UDim2.new(0.5, -200, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
main.BorderSizePixel = 0

local title = Instance.new("TextLabel")
title.Parent = main
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
title.Text = "NEXUS HUB - VELOCITY"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local close = Instance.new("TextButton")
close.Parent = title
close.Size = UDim2.new(0, 30, 0, 25)
close.Position = UDim2.new(1, -35, 0.5, -12)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(180, 60, 60)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local toggle = Instance.new("TextButton")
toggle.Parent = main
toggle.Size = UDim2.new(0, 180, 0, 40)
toggle.Position = UDim2.new(0.5, -90, 0.5, -20)
toggle.Text = "START"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 120)

_G.NexusActive = false

toggle.MouseButton1Click:Connect(function()
    _G.NexusActive = not _G.NexusActive
    toggle.Text = _G.NexusActive and "STOP" or "START"
    toggle.BackgroundColor3 = _G.NexusActive
        and Color3.fromRGB(200, 60, 60)
        or Color3.fromRGB(0, 170, 120)
end)

local dragging = false
local dragStart
local startPos

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
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
