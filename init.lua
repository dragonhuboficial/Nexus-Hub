--[[
    NEXUS PHANTOM v7.0 APEX | ABSOLUTE VISIBILITY
    Focado em resolver o bug de renderização do Delta
]]

task.wait(1)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("NexusUI") then
	PlayerGui.NexusUI:Destroy()
end

local Phantom = { Active = false }

-- [ INTERFACE ULTRA SIMPLES ]
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "NexusUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 400, 0, 300)
main.Position = UDim2.new(0.5, -200, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.new(1, 1, 1)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "NEXUS PHANTOM - F9 CONSOLE LOGS"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14

local close = Instance.new("TextButton", title)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -30, 0, 0)
close.Text = "X"
close.BackgroundColor3 = Color3.new(0.6, 0, 0)
close.TextColor3 = Color3.new(1, 1, 1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local logArea = Instance.new("Frame", main)
logArea.Size = UDim2.new(1, -20, 1, -80)
logArea.Position = UDim2.new(0, 10, 0, 40)
logArea.BackgroundColor3 = Color3.new(0, 0, 0)

local status = Instance.new("TextLabel", logArea)
status.Size = UDim2.new(1, 0, 1, 0)
status.BackgroundTransparency = 1
status.Text = "CHECK F9 CONSOLE FOR LOGS\n\nCapture is: OFF"
status.TextColor3 = Color3.new(0, 1, 0)
status.TextSize = 18
status.Font = Enum.Font.SourceSansBold

local start = Instance.new("TextButton", main)
start.Size = UDim2.new(0, 150, 0, 35)
start.Position = UDim2.new(0.5, -75, 1, -40)
start.Text = "START"
start.BackgroundColor3 = Color3.new(0, 0.5, 0)
start.TextColor3 = Color3.new(1, 1, 1)

start.MouseButton1Click:Connect(function()
	Phantom.Active = not Phantom.Active
	start.Text = Phantom.Active and "STOP" or "START"
	start.BackgroundColor3 = Phantom.Active and Color3.new(0.5, 0, 0) or Color3.new(0, 0.5, 0)
    status.Text = "CHECK F9 CONSOLE FOR LOGS\n\nCapture is: " .. (Phantom.Active and "ON" or "OFF")
end)

-- [ DRAGGING ]
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
title.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- [ CAPTURA REDUNDANTE ]
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if Phantom.Active and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        print("----------------------------------------")
        print("[NEXUS] Remote: " .. self.Name)
        print("[NEXUS] Method: " .. method)
        for i, v in pairs(args) do
            print(string.format("[NEXUS] Arg[%d]: %s", i, tostring(v)))
        end
    end
    return old(self, ...)
end)
setreadonly(mt, true)

print("NEXUS PHANTOM: Use F9 to see logs!")
