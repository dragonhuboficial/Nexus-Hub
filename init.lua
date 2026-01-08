--[[
    NEXUS-HUB v7.0 APEX | DELTA EDITION
    Focado em compatibilidade total com Delta Executor (Mobile/PC)
]]

task.wait(0.5) -- Espera o executor estabilizar

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- [ FALLBACK DE PARENTESCO ]
local function getGuiParent()
    local success, parent = pcall(function() return CoreGui end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local Nexus = { Active = false, Logs = {} }

-- [ UI SIMPLIFICADA E ROBUSTA ]
local Screen = Instance.new("ScreenGui")
Screen.Name = "NexusHubUI"
Screen.Parent = getGuiParent()
Screen.ResetOnSpawn = false

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 500, 0, 350)
Main.Position = UDim2.new(0.5, -250, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(0, 170, 255)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Title.Text = "NEXUS-HUB v7.0 APEX | DELTA"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local CloseBtn = Instance.new("TextButton", Title)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.MouseButton1Click:Connect(function() Screen:Destroy() end)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(0.94, 0, 0.7, 0)
Container.Position = UDim2.new(0.03, 0, 0.15, 0)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
Container.ScrollBarThickness = 4

local ListLayout = Instance.new("UIListLayout", Container)
ListLayout.Padding = UDim.new(0, 5)

local toggleBtn = Instance.new("TextButton", Main)
toggleBtn.Size = UDim2.new(0, 150, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -75, 0.9, -20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
toggleBtn.Text = "START CAPTURE"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.SourceSansBold

toggleBtn.MouseButton1Click:Connect(function()
    Nexus.Active = not Nexus.Active
    toggleBtn.Text = Nexus.Active and "STOP CAPTURE" or "START CAPTURE"
    toggleBtn.BackgroundColor3 = Nexus.Active and Color3.fromRGB(120, 0, 0) or Color3.fromRGB(0, 120, 0)
end)

-- [ LOGICA DE CAPTURA ]
local function addLog(remote, method, args)
    local label = Instance.new("TextLabel", Container)
    label.Size = UDim2.new(1, 0, 0, 50)
    label.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.TextSize = 12
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    
    local argStr = ""
    for i, v in pairs(args) do
        argStr = argStr .. "[" .. tostring(i) .. "]: " .. tostring(v) .. " "
    end
    
    label.Text = string.format("[%s] %s\nArgs: %s", remote.Name, method, argStr)
    Container.CanvasPosition = Vector2.new(0, 9999)
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if Nexus.Active and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        task.spawn(function() addLog(self, method, args) end)
    end
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)
print("Nexus-Hub: Delta Edition Carregado!")
