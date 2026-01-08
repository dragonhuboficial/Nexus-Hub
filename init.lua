--[[
    NEXUS TOTAL CAPTURE SYSTEM v8.0
    Interface Original Restaurada + Inteligência Phantom
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

-- [ ESTADO E MÓDULOS ]
local Nexus = {
    Active = false,
    Queue = {},
    ProcessedKeys = {}
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

function Decryption.smartDecrypt(str)
    if type(str) ~= "string" or #str < 3 then return str, nil end
    local s, b = pcall(HttpService.Base64Decode, HttpService, str)
    if s and #b > 2 then return b, "B64" end
    local rev = string.reverse(str)
    if #rev > 6 and not str:match(" ") and rev:match("^[%w%s%p]+$") then return rev, "REV" end
    return str, nil
end

-- [ INTERFACE ]
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
title.Text = "NEXUS • TOTAL CAPTURE SYSTEM"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(230,230,255)
title.TextXAlignment = Enum.TextXAlignment.Left

local function topButton(txt, x)
	local b = Instance.new("TextButton", header)
	b.Size = UDim2.new(0,80,0,26)
	b.Position = UDim2.new(1, x, 0.5, -13)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.TextColor3 = Color3.fromRGB(220,220,240)
	b.BackgroundColor3 = Color3.fromRGB(60,60,90)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

local btnPause = topButton("PAUSE", -260)
local btnClear = topButton("CLEAR", -170)
local btnCopy  = topButton("COPY",  -80)

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
sideButton("EXPORT", 212)

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
start.Text = "START CAPTURE"
start.Font = Enum.Font.GothamBold
start.TextSize = 13
start.TextColor3 = Color3.new(1,1,1)
start.BackgroundColor3 = Color3.fromRGB(0,170,130)
start.BorderSizePixel = 0
Instance.new("UICorner", start).CornerRadius = UDim.new(0,12)

start.MouseButton1Click:Connect(function()
	Nexus.Active = not Nexus.Active
	start.Text = Nexus.Active and "STOP" or "START CAPTURE"
	start.BackgroundColor3 = Nexus.Active and Color3.fromRGB(200,70,70) or Color3.fromRGB(0,170,130)
end)

btnClear.MouseButton1Click:Connect(function()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
end)

-- [ FUNÇÃO DE LOG ]
local function addLog(titleText, contentText)
    local logFrame = Instance.new("Frame", scroll)
    logFrame.Size = UDim2.new(1, -10, 0, 45)
    logFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 46)
    Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0, 8)
    
    local box = Instance.new("TextBox", logFrame)
    box.Size = UDim2.new(1, -80, 1, 0)
    box.Position = UDim2.new(0, 10, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = "<b>" .. titleText .. "</b> | " .. contentText
    box.TextColor3 = Color3.fromRGB(210, 210, 235)
    box.Font = Enum.Font.Code
    box.TextSize = 10
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ReadOnly = true
    box.ClearTextOnFocus = false
    box.RichText = true

    local copyBtn = Instance.new("TextButton", logFrame)
    copyBtn.Size = UDim2.new(0, 60, 0, 25)
    copyBtn.Position = UDim2.new(1, -65, 0.5, -12)
    copyBtn.Text = "COPY"
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 9
    Instance.new("UICorner", copyBtn)
    
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(contentText)
        copyBtn.Text = "OK!"
        task.wait(1)
        copyBtn.Text = "COPY"
    end)
    
    scroll.CanvasPosition = Vector2.new(0, 999999)
end

-- [ FILA ANTI-LAG ]
task.spawn(function()
    while true do
        if #Nexus.Queue > 0 then
            local data = table.remove(Nexus.Queue, 1)
            addLog(data.Name, data.Content)
        end
        task.wait(0.1)
    end
end)

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

-- [ CAPTURA INTELIGENTE ]
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" and self == player then return nil end
    if Nexus.Active and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        local argStr = ""
        for i, v in pairs(args) do
            local val = Decryption.safeString(v)
            local dec, tag = Decryption.smartDecrypt(val)
            argStr = argStr .. dec .. (tag and " ("..tag..")" or "") .. " "
        end
        local key = self.Name .. argStr
        if not Nexus.ProcessedKeys[key] then
            Nexus.ProcessedKeys[key] = true
            table.insert(Nexus.Queue, {Name = self.Name, Content = argStr})
        end
    end
    return old(self, ...)
end)

setreadonly(mt, true)
addLog("SYSTEM", "Nexus Core v8.0 Professional UI Restored")
