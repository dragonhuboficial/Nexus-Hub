--[[
    NEXUS-HUB v7.0 APEX | ULTIMATE CONSOLIDATED
    "The Ultimate Remote Intelligence Tool"
]]

-- [ CONFIGURAÇÃO ]
local Nexus = {
    Version = "7.0 Apex Ultimate",
    Active = false,
    Settings = {
        Theme = Color3.fromRGB(0, 170, 255),
        AutoScroll = true
    },
    Data = { Logs = {} }
}

-- [ SERVIÇOS ]
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- [ MOTOR DE DESCRIPTOGRAFIA ]
local Decryption = {}
function Decryption.safeString(v)
    local t = typeof(v)
    if t == "table" then
        local s = "{"
        for k, val in pairs(v) do
            s = s .. tostring(k) .. ":" .. tostring(val) .. ","
        end
        return (#s > 1 and s:sub(1, #s-1) or s) .. "}"
    elseif t == "Instance" then
        return v.Name
    end
    return tostring(v)
end

function Decryption.decrypt(str)
    if type(str) ~= "string" or #str < 2 then return str, nil end
    
    -- Base64
    local s, b = pcall(HttpService.Base64Decode, HttpService, str)
    if s then return b, "B64" end
    
    -- Reverse
    local rev = string.reverse(str)
    if #rev > 4 and rev:match("^[%w%s%p]+$") then return rev, "REV" end
    
    -- XOR 1-Byte Brute
    for i = 1, 255 do
        local res = ""
        for j = 1, #str do
            res = res .. string.char(bit.bxor(str:byte(j), i))
        end
        if res:match("^[%w%s%p]+$") and #res > 5 then
            return res, "XOR-1B"
        end
    end
    
    return str, nil
end

function Decryption.generateSnippet(remote, method, args)
    local path = "game." .. remote:GetFullName()
    local argList = {}
    for _, v in pairs(args) do
        table.insert(argList, Decryption.safeString(v))
    end
    return string.format("%s:%s(%s)", path, method, table.concat(argList, ", "))
end

-- [ INTERFACE GRÁFICA ]
local Screen = Instance.new("ScreenGui")
Screen.Name = "NexusHubUI"
Screen.Parent = CoreGui
Screen.ResetOnSpawn = false

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 600, 0, 400)
Main.Position = UDim2.new(0.5, -300, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Text = "  NEXUS-HUB v7.0 APEX | ULTIMATE"
Title.TextColor3 = Nexus.Settings.Theme
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local CloseBtn = Instance.new("TextButton", Title)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() Screen:Destroy() end)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(0.96, 0, 0.75, 0)
Container.Position = UDim2.new(0.02, 0, 0.15, 0)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.ScrollBarThickness = 2
Container.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y

local ListLayout = Instance.new("UIListLayout", Container)
ListLayout.Padding = UDim.new(0, 8)

local Controls = Instance.new("Frame", Main)
Controls.Size = UDim2.new(1, 0, 0, 60)
Controls.Position = UDim2.new(0, 0, 0.88, 0)
Controls.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", Controls)
toggleBtn.Size = UDim2.new(0, 140, 0, 40)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
toggleBtn.Text = "START CAPTURE"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", toggleBtn)

toggleBtn.MouseButton1Click:Connect(function()
    Nexus.Active = not Nexus.Active
    toggleBtn.Text = Nexus.Active and "STOP CAPTURE" or "START CAPTURE"
    toggleBtn.BackgroundColor3 = Nexus.Active and Color3.fromRGB(220, 60, 60) or Color3.fromRGB(0, 180, 120)
end)

-- [ LOGICA DE CAPTURA ]
local function addLog(remote, method, args)
    local logFrame = Instance.new("Frame", Container)
    logFrame.Size = UDim2.new(1, -10, 0, 90)
    logFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", logFrame)
    
    local title = Instance.new("TextLabel", logFrame)
    title.Size = UDim2.new(1, -10, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = string.format("<b>%s</b> (%s)", remote.Name, method)
    title.TextColor3 = Nexus.Settings.Theme
    title.Font = Enum.Font.GothamBold
    title.RichText = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local content = Instance.new("TextLabel", logFrame)
    content.Size = UDim2.new(1, -20, 0, 50)
    content.Position = UDim2.new(0, 10, 0, 25)
    content.BackgroundTransparency = 1
    content.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    content.Font = Enum.Font.Code
    content.TextSize = 10
    content.TextWrapped = true
    content.RichText = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    
    local argStr = "<b>Args:</b> "
    for i, v in pairs(args) do
        local val = Decryption.safeString(v)
        local dec, tag = Decryption.decrypt(val)
        argStr = argStr .. string.format("[%d]: %s %s  ", i, dec, tag and "<font color='#00FF00'>(%s)</font>" or "")
    end
    content.Text = argStr

    local genBtn = Instance.new("TextButton", logFrame)
    genBtn.Size = UDim2.new(0, 100, 0, 25)
    genBtn.Position = UDim2.new(1, -110, 1, -30)
    genBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 150)
    genBtn.Text = "GENERATE CODE"
    genBtn.TextColor3 = Color3.new(1,1,1)
    genBtn.Font = Enum.Font.GothamBold
    genBtn.TextSize = 10
    Instance.new("UICorner", genBtn)
    genBtn.MouseButton1Click:Connect(function()
        setclipboard(Decryption.generateSnippet(remote, method, args))
        genBtn.Text = "COPIED!"
        task.wait(1)
        genBtn.Text = "GENERATE CODE"
    end)
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
print("Nexus-Hub: Carregado com sucesso!")
