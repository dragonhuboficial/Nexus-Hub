local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local UI = {}

function UI.init(Nexus)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "NexusHubUI"
    
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 550, 0, 400)
    Main.Position = UDim2.new(0.5, -275, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner", Main)
    Corner.CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Title.Text = "  NEXUS-HUB v7.0 APEX"
    Title.TextColor3 = Nexus.Settings.Theme
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)
    
    local Container = Instance.new("ScrollingFrame", Main)
    Container.Size = UDim2.new(0.95, 0, 0.7, 0)
    Container.Position = UDim2.new(0.025, 0, 0.15, 0)
    Container.BackgroundTransparency = 1
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.ScrollBarThickness = 4
    
    local ListLayout = Instance.new("UIListLayout", Container)
    ListLayout.Padding = UDim.new(0, 5)
    
    local Controls = Instance.new("Frame", Main)
    Controls.Size = UDim2.new(1, 0, 0, 50)
    Controls.Position = UDim2.new(0, 0, 0.87, 0)
    Controls.BackgroundTransparency = 1
    
    local function createBtn(text, pos, color, callback)
        local btn = Instance.new("TextButton", Controls)
        btn.Size = UDim2.new(0, 120, 0, 35)
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
    
    local toggleBtn = createBtn("START CAPTURE", UDim2.new(0.05, 0, 0, 0), Color3.fromRGB(0, 150, 0), function()
        Nexus.Active = not Nexus.Active
        _G.NexusActive = Nexus.Active
        toggleBtn.Text = Nexus.Active and "STOP CAPTURE" or "START CAPTURE"
        toggleBtn.BackgroundColor3 = Nexus.Active and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
    end)
    
    createBtn("CLEAR LOGS", UDim2.new(0.35, 0, 0, 0), Color3.fromRGB(150, 50, 50), function()
        for _, v in pairs(Container:GetChildren()) do
            if v:IsA("TextLabel") then v:Destroy() end
        end
        Nexus.Data.Logs = {}
    end)
    
    createBtn("EXPORT JSON", UDim2.new(0.65, 0, 0, 0), Color3.fromRGB(50, 50, 150), function()
        local json = HttpService:JSONEncode(Nexus.Data.Logs)
        setclipboard(json)
        print("Nexus-Hub: Logs copiados para o clipboard!")
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

function UI.addLog(Nexus, Decryption, remote, method, args)
    local timestamp = os.date("%H:%M:%S")
    local argStr = ""
    for i, v in pairs(args) do
        local val = Decryption.safeString(v)
        if Nexus.Settings.Decryption then
            local dec = Decryption.decrypt(val)
            if dec ~= val then val = dec end
        end
        argStr = argStr .. "[" .. i .. "]: " .. val .. "  "
    end
    
    local logText = string.format("[%s] %s -> %s\nArgs: %s", timestamp, remote.Name, method, argStr)
    
    local label = Instance.new("TextLabel", UI.LogContainer)
    label.Size = UDim2.new(1, 0, 0, 45)
    label.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    label.Text = "  " .. logText
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextWrapped = true
    Instance.new("UICorner", label)
    
    UI.LogContainer.CanvasSize = UDim2.new(0, 0, 0, #UI.LogContainer:GetChildren() * 50)
    if Nexus.Settings.AutoScroll then
        UI.LogContainer.CanvasPosition = Vector2.new(0, UI.LogContainer.CanvasSize.Y.Offset)
    end
end

return UI
