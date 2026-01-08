task.wait(1)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("NexusCoreUI") then
    PlayerGui.NexusCoreUI:Destroy()
end

local State = {
    Active = false,
    AutoScroll = true,
    Minimized = false,
    Logs = {}
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

local UI = {}

local gui = Instance.new("ScreenGui")
gui.Name = "NexusCoreUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 760, 0, 480)
main.Position = UDim2.new(0.5, -380, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(16,16,20)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,48)
header.BackgroundColor3 = Color3.fromRGB(22,22,28)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "  NEXUS CORE"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(200,220,255)

local function headerButton(text, offset)
    local b = Instance.new("TextButton", header)
    b.Size = UDim2.new(0,32,0,32)
    b.Position = UDim2.new(1,-offset,0.5,-16)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,60)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    return b
end

local btnClose = headerButton("X", 40)
local btnMin = headerButton("-", 80)

btnClose.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

btnMin.MouseButton1Click:Connect(function()
    State.Minimized = not State.Minimized
    main.Size = State.Minimized and UDim2.new(0,760,0,48) or UDim2.new(0,760,0,480)
end)

local body = Instance.new("Frame", main)
body.Position = UDim2.new(0,0,0,48)
body.Size = UDim2.new(1,0,1,-48)
body.BackgroundTransparency = 1

local actionPanel = Instance.new("Frame", body)
actionPanel.Size = UDim2.new(1,0,0,70)
actionPanel.BackgroundTransparency = 1

local masterButton = Instance.new("TextButton", actionPanel)
masterButton.Size = UDim2.new(0,260,0,46)
masterButton.Position = UDim2.new(0.5,-130,0.5,-23)
masterButton.Text = "ACTIVATE CORE"
masterButton.Font = Enum.Font.GothamBold
masterButton.TextSize = 15
masterButton.TextColor3 = Color3.new(1,1,1)
masterButton.BackgroundColor3 = Color3.fromRGB(0,160,120)
Instance.new("UICorner", masterButton).CornerRadius = UDim.new(0,10)

masterButton.MouseButton1Click:Connect(function()
    State.Active = not State.Active
    masterButton.Text = State.Active and "CORE ACTIVE" or "ACTIVATE CORE"
    masterButton.BackgroundColor3 = State.Active
        and Color3.fromRGB(200,70,70)
        or Color3.fromRGB(0,160,120)
end)

local logsFrame = Instance.new("ScrollingFrame", body)
logsFrame.Position = UDim2.new(0,0,0,70)
logsFrame.Size = UDim2.new(1,0,1,-70)
logsFrame.CanvasSize = UDim2.new(0,0,0,0)
logsFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
logsFrame.ScrollBarThickness = 3
logsFrame.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", logsFrame)
layout.Padding = UDim.new(0,10)

function UI.addLog(titleText, contentText)
    local card = Instance.new("Frame", logsFrame)
    card.Size = UDim2.new(1,-12,0,110)
    card.BackgroundColor3 = Color3.fromRGB(26,26,32)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)

    local title = Instance.new("TextLabel", card)
    title.Size = UDim2.new(1,-16,0,22)
    title.Position = UDim2.new(0,8,0,8)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(180,200,255)

    local bodyTxt = Instance.new("TextLabel", card)
    bodyTxt.Size = UDim2.new(1,-16,0,60)
    bodyTxt.Position = UDim2.new(0,8,0,34)
    bodyTxt.BackgroundTransparency = 1
    bodyTxt.TextWrapped = true
    bodyTxt.TextYAlignment = Enum.TextYAlignment.Top
    bodyTxt.TextXAlignment = Enum.TextXAlignment.Left
    bodyTxt.Font = Enum.Font.Code
    bodyTxt.TextSize = 11
    bodyTxt.TextColor3 = Color3.new(1,1,1)
    bodyTxt.Text = contentText
    bodyTxt.RichText = true

    if State.AutoScroll then
        logsFrame.CanvasPosition = Vector2.new(0,999999)
    end
end

-- [ DRAGGING ]
local dragging = false
local dragStart, startPos
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

-- [ LOGICA DE CAPTURA ]
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if State.Active and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        task.spawn(function()
            local argStr = ""
            for i, v in pairs(args) do
                local val = Decryption.safeString(v)
                local dec, tag = Decryption.decrypt(val)
                argStr = argStr .. string.format("[%d]: %s %s ", i, dec, tag and "<font color='#00FF00'>("..tag..")</font>" or "")
            end
            UI.addLog(self.Name .. " (" .. method .. ")", argStr)
        end)
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

UI.addLog("SYSTEM", "Nexus Core interface loaded successfully")
