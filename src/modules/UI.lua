local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local UI = {}

function UI.init(Nexus)
    pcall(function() CoreGui.NexusHubUI:Destroy() end)

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "NexusHubUI"
    Screen.ResetOnSpawn = false
    
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 700, 0, 500)
    Main.Position = UDim2.new(0.5, -350, 0.5, -250)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    Main.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner", Main)
    Corner.CornerRadius = UDim.new(0, 10)
    
    -- [ BARRA LATERAL / ABAS ]
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -160, 1, -60)
    Content.Position = UDim2.new(0, 155, 0, 55)
    Content.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Title.Text = "  NEXUS-HUB v7.0 APEX | ULTIMATE"
    Title.TextColor3 = Nexus.Settings.Theme
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

    -- [ SISTEMA DE ABAS ]
    local Pages = {
        Spy = Instance.new("ScrollingFrame", Content),
        Browser = Instance.new("ScrollingFrame", Content),
        Settings = Instance.new("ScrollingFrame", Content)
    }

    for name, page in pairs(Pages) do
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = (name == "Spy")
        page.ScrollBarThickness = 2
        page.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 5)
    end

    local function createTab(name, pos)
        local btn = Instance.new("TextButton", Sidebar)
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0, pos)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.Text = name:upper()
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 12
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(function()
            for n, p in pairs(Pages) do p.Visible = (n == name) end
        end)
    end

    createTab("Spy", 60)
    createTab("Browser", 110)
    createTab("Settings", 160)

    -- [ CONTROLES ]
    local Controls = Instance.new("Frame", Main)
    Controls.Size = UDim2.new(1, -160, 0, 50)
    Controls.Position = UDim2.new(0, 155, 1, -55)
    Controls.BackgroundTransparency = 1

    local toggleBtn = Instance.new("TextButton", Controls)
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    toggleBtn.Text = "START CAPTURE"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", toggleBtn)
    toggleBtn.MouseButton1Click:Connect(function()
        Nexus.Active = not Nexus.Active
        _G.NexusActive = Nexus.Active
        toggleBtn.Text = Nexus.Active and "STOP CAPTURE" or "START CAPTURE"
        toggleBtn.BackgroundColor3 = Nexus.Active and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(0, 150, 100)
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

    UI.LogContainer = Pages.Spy
    return Pages.Spy
end

function UI.addLog(Nexus, Decryption, remote, method, args, extra)
    if not UI.LogContainer then return end
    
    local logFrame = Instance.new("Frame", UI.LogContainer)
    logFrame.Size = UDim2.new(1, -10, 0, 110)
    logFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    logFrame.BorderSizePixel = 0
    Instance.new("UICorner", logFrame)
    
    local title = Instance.new("TextLabel", logFrame)
    title.Size = UDim2.new(1, -10, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = string.format("<b>%s</b> (%s)", remote.Name, method)
    title.TextColor3 = Nexus.Settings.Theme
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.RichText = true
    
    local content = Instance.new("TextLabel", logFrame)
    content.Size = UDim2.new(1, -20, 0, 50)
    content.Position = UDim2.new(0, 10, 0, 25)
    content.BackgroundTransparency = 1
    content.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    content.Font = Enum.Font.Code
    content.TextSize = 10
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.RichText = true
    
    local argStr = "<b>Args:</b> "
    for i, v in pairs(args) do
        local val = Decryption.safeString(v)
        local dec, tag = Decryption.decrypt(val)
        argStr = argStr .. string.format("[%d]: %s %s  ", i, dec, tag and "<font color='#00FF00'>("..tag..")</font>" or "")
    end
    content.Text = argStr

    -- Botão Gerar Script
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
        local code = Decryption.generateSnippet(remote, method, args)
        setclipboard(code)
        genBtn.Text = "COPIED!"
        task.wait(1)
        genBtn.Text = "GENERATE CODE"
    end)

    -- Info de Debug (Constants/Upvalues)
    local debugLabel = Instance.new("TextLabel", logFrame)
    debugLabel.Size = UDim2.new(1, -120, 0, 20)
    debugLabel.Position = UDim2.new(0, 10, 1, -25)
    debugLabel.BackgroundTransparency = 1
    debugLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    debugLabel.Font = Enum.Font.Gotham
    debugLabel.TextSize = 9
    debugLabel.TextXAlignment = Enum.TextXAlignment.Left
    local constCount = extra.Debug and #extra.Debug.Constants or 0
    local upCount = extra.Debug and #extra.Debug.Upvalues or 0
    debugLabel.Text = string.format("Constants: %d | Upvalues: %d | Line: %s", constCount, upCount, extra.Debug and extra.Debug.Line or "?")

    if Nexus.Settings.AutoScroll then
        UI.LogContainer.CanvasPosition = Vector2.new(0, 999999)
    end
    
    table.insert(Nexus.Data.Logs, {Remote = remote.Name, Method = method, Args = args, Extra = extra})
end

return UI
