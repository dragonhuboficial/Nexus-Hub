--[[
    NEXUS CORE v8.3 | FINAL VISION
    Menu Superior + Captura Corrigida + Sem RichText Bug
]]

task.wait(0.5)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- [ LIMPEZA ]
for _, v in pairs(PlayerGui:GetChildren()) do
    if v.Name:find("Nexus") then v:Destroy() end
end

local Nexus = {
    Active = false,
    Category = "ALL",
    Queue = {},
    ProcessedKeys = {},
    AllLogs = ""
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
gui.Name = "NexusUI_v83"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 600, 0, 400)
main.Position = UDim2.new(0.5, -300, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(18,18,26)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,44)
header.BackgroundColor3 = Color3.fromRGB(30,30,48)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0, 180, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "NEXUS CORE v8.3"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(230,230,255)
title.TextXAlignment = Enum.TextXAlignment.Left

-- [ MENU SUPERIOR ]
local menuBtn = Instance.new("TextButton", header)
menuBtn.Size = UDim2.new(0, 100, 0, 26)
menuBtn.Position = UDim2.new(0, 180, 0.5, -13)
menuBtn.Text = "ALL"
menuBtn.Font = Enum.Font.GothamBold
menuBtn.TextSize = 10
menuBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
menuBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", menuBtn)

local menuFrame = Instance.new("Frame", main)
menuFrame.Size = UDim2.new(0, 120, 0, 150)
menuFrame.Position = UDim2.new(0, 180, 0, 45)
menuFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
menuFrame.Visible = false
menuFrame.ZIndex = 10
Instance.new("UICorner", menuFrame)

local function addMenuOption(txt, y, cat)
    local b = Instance.new("TextButton", menuFrame)
    b.Size = UDim2.new(1, -10, 0, 25)
    b.Position = UDim2.new(0, 5, 0, y)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Nexus.Category = cat
        menuBtn.Text = cat
        menuFrame.Visible = false
    end)
end

addMenuOption("ALL", 5, "ALL")
addMenuOption("REMOTES", 35, "REMOTES")
addMenuOption("OBJECTS", 65, "OBJECTS")
addMenuOption("MODULES", 95, "MODULES")
addMenuOption("FOLDERS", 125, "FOLDERS")

menuBtn.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)

-- [ BOTÕES DE AÇÃO ]
local function topBtn(txt, x, color)
    local b = Instance.new("TextButton", header)
    b.Size = UDim2.new(0, 60, 0, 26)
    b.Position = UDim2.new(1, x, 0.5, -13)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.BackgroundColor3 = color or Color3.fromRGB(60, 60, 90)
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    return b
end

local btnClose = topBtn("X", -35, Color3.fromRGB(150, 50, 50))
local btnCopyAll = topBtn("COPY", -100)
local btnClear = topBtn("CLEAR", -165)

btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

-- [ CONTEÚDO ]
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -20, 1, -110)
content.Position = UDim2.new(0, 10, 0, 50)
content.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
Instance.new("UICorner", content)

local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(1, -10, 1, -10)
scroll.Position = UDim2.new(0, 5, 0, 5)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 3
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

local bottom = Instance.new("Frame", main)
bottom.Size = UDim2.new(1, 0, 0, 50)
bottom.Position = UDim2.new(0, 0, 1, -50)
bottom.BackgroundColor3 = Color3.fromRGB(26, 26, 40)
Instance.new("UICorner", bottom)

local start = Instance.new("TextButton", bottom)
start.Size = UDim2.new(0, 200, 0, 35)
start.Position = UDim2.new(0.5, -100, 0.5, -17)
start.Text = "START CAPTURE"
start.Font = Enum.Font.GothamBold
start.TextSize = 13
start.TextColor3 = Color3.new(1, 1, 1)
start.BackgroundColor3 = Color3.fromRGB(0, 170, 130)
Instance.new("UICorner", start)

start.MouseButton1Click:Connect(function()
	Nexus.Active = not Nexus.Active
	start.Text = Nexus.Active and "STOP" or "START CAPTURE"
	start.BackgroundColor3 = Nexus.Active and Color3.fromRGB(200, 70, 70) or Color3.fromRGB(0, 170, 130)
end)

btnClear.MouseButton1Click:Connect(function()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    Nexus.AllLogs = ""
end)

btnCopyAll.MouseButton1Click:Connect(function()
    setclipboard(Nexus.AllLogs)
    btnCopyAll.Text = "OK!"
    task.wait(1)
    btnCopyAll.Text = "COPY"
end)

-- [ FUNÇÃO DE LOG CORRIGIDA ]
local function addLog(titleText, contentText, category)
    if Nexus.Category ~= "ALL" and Nexus.Category ~= category then return end

    local logFrame = Instance.new("Frame", scroll)
    logFrame.Size = UDim2.new(1, -10, 0, 50)
    logFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 46)
    Instance.new("UICorner", logFrame)
    
    local box = Instance.new("TextBox", logFrame)
    box.Size = UDim2.new(1, -70, 1, 0)
    box.Position = UDim2.new(0, 10, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = "[" .. category .. "] " .. titleText .. " | " .. contentText
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Code
    box.TextSize = 10
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ReadOnly = true
    box.ClearTextOnFocus = false
    box.RichText = false -- DESATIVADO PARA EVITAR BUG

    local copyBtn = Instance.new("TextButton", logFrame)
    copyBtn.Size = UDim2.new(0, 50, 0, 25)
    copyBtn.Position = UDim2.new(1, -55, 0.5, -12)
    copyBtn.Text = "COPY"
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 8
    Instance.new("UICorner", copyBtn)
    
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(contentText)
        copyBtn.Text = "OK!"
        task.wait(1)
        copyBtn.Text = "COPY"
    end)
    
    Nexus.AllLogs = Nexus.AllLogs .. "[" .. category .. "] " .. titleText .. " | " .. contentText .. "\n"
    scroll.CanvasPosition = Vector2.new(0, 999999)
end

-- [ FILA ANTI-LAG ]
task.spawn(function()
    while true do
        if #Nexus.Queue > 0 then
            local data = table.remove(Nexus.Queue, 1)
            addLog(data.Name, data.Content, data.Category)
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

-- [ CAPTURA ]
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
            table.insert(Nexus.Queue, {Name = self.Name, Content = argStr, Category = "REMOTES"})
        end
    end
    return old(self, ...)
end)

setreadonly(mt, true)
addLog("SYSTEM", "Nexus Core v8.3 Loaded Successfully", "ALL")
