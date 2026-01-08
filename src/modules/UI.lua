local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local UI = {}

function UI.init(Nexus)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "NexusHubUI"
    
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 650, 0, 480)
    Main.Position = UDim2.new(0.5, -325, 0.5, -240)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Main.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner", Main)
    Corner.CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Title.Text = "  NEXUS-HUB v7.0 APEX | DEEP INSPECTOR"
    Title.TextColor3 = Nexus.Settings.Theme
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)
    
    local Container = Instance.new("ScrollingFrame", Main)
    Container.Size = UDim2.new(0.96, 0, 0.75, 0)
    Container.Position = UDim2.new(0.02, 0, 0.12, 0)
    Container.BackgroundTransparency = 1
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.ScrollBarThickness = 2
    
    local ListLayout = Instance.new("UIListLayout", Container)
    ListLayout.Padding = UDim.new(0, 8)
    
    local Controls = Instance.new("Frame", Main)
    Controls.Size = UDim2.new(1, 0, 0, 60)
    Controls.Position = UDim2.new(0, 0, 0.88, 0)
    Controls.BackgroundTransparency = 1
    
    local function createBtn(text, pos, color, callback)
        local btn = Instance.new("TextButton", Controls)
        btn.Size = UDim2.new(0, 140, 0, 40)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local toggleBtn = createBtn("START CAPTURE", UDim2.new(0.05, 0, 0, 0), Color3.fromRGB(0, 180, 120), function()
        Nexus.Active = not Nexus.Active
        _G.NexusActive = Nexus.Active
        toggleBtn.Text = Nexus.Active and "STOP CAPTURE" or "START CAPTURE"
        toggleBtn.BackgroundColor3 = Nexus.Active and Color3.fromRGB(220, 60, 60) or Color3.fromRGB(0, 180, 120)
    end)
    
    createBtn("CLEAR LOGS", UDim2.new(0.38, 0, 0, 0), Color3.fromRGB(180, 50, 50), function()
        for _, v in pairs(Container:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        Nexus.Data.Logs = {}
    end)
    
    createBtn("EXPORT JSON", UDim2.new(0.71, 0, 0, 0), Color3.fromRGB(50, 100, 220), function()
        local json = HttpService:JSONEncode(Nexus.Data.Logs)
        setclipboard(json)
        print("Nexus-Hub: Dados exportados!")
    end)

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    UI.LogContainer = Container
    return Container
end

function UI.addLog(Nexus, Decryption, remote, method, args, extra)
    local timestamp = os.date("%H:%M:%S")
    
    local logFrame = Instance.new("Frame", UI.LogContainer)
    logFrame.Size = UDim2.new(1, 0, 0, 85)
    logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    logFrame.BorderSizePixel = 0
    Instance.new("UICorner", logFrame)
    
    local title = Instance.new("TextLabel", logFrame)
    title.Size = UDim2.new(1, -10, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = string.format("[%s] %s (%s) <font color='#AAAAAA'>via %s</font>", timestamp, remote.Name, method, extra.Caller)
    title.TextColor3 = Nexus.Settings.Theme
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.RichText = true
    
    local content = Instance.new("TextLabel", logFrame)
    content.Size = UDim2.new(1, -20, 0, 55)
    content.Position = UDim2.new(0, 10, 0, 25)
    content.BackgroundTransparency = 1
    content.TextColor3 = Color3.new(0.85, 0.85, 0.85)
    content.Font = Enum.Font.Code
    content.TextSize = 11
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.RichText = true
    
    local argStr = "<b>Args:</b> "
    for i, v in pairs(args) do
        local val = Decryption.safeString(v)
        local dec, tag = Decryption.decrypt(val)
        
        if tag then
            argStr = argStr .. string.format("[%d]: %s <font color='#00FF00'>(%s)</font>  ", i, dec, tag)
        else
            argStr = argStr .. string.format("[%d]: %s  ", i, val)
        end
    end
    
    -- Adiciona upvalues se encontrados
    local upStr = ""
    local upCount = 0
    for k, v in pairs(extra.Upvalues) do
        upCount = upCount + 1
        if upCount > 3 then break end
        upStr = upStr .. string.format("%s=%s ", tostring(k), Decryption.safeString(v))
    end
    
    if upCount > 0 then
        argStr = argStr .. "\n<font color='#FFAA00'><b>Upvalues:</b> " .. upStr .. "</font>"
    end
    
    content.Text = argStr
    
    UI.LogContainer.CanvasSize = UDim2.new(0, 0, 0, #UI.LogContainer:GetChildren() * 93)
    if Nexus.Settings.AutoScroll then
        UI.LogContainer.CanvasPosition = Vector2.new(0, UI.LogContainer.CanvasSize.Y.Offset)
    end
    
    table.insert(Nexus.Data.Logs, {Time = timestamp, Remote = remote.Name, Method = method, Args = args, Extra = extra})
end

return UI
