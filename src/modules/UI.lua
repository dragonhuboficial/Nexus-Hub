local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local UI = {}

function UI.init(Nexus)
    -- Limpeza de segurança
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "NexusHubUI" then v:Destroy() end
    end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "NexusHubUI"
    Screen.Parent = CoreGui
    Screen.ResetOnSpawn = false
    Screen.IgnoreGuiInset = true
    
    local Main = Instance.new("Frame", Screen)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 650, 0, 450)
    Main.Position = UDim2.new(0.5, -325, 0.5, -225)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true -- Fallback para executores simples
    
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

    -- [ BOTÕES DE CONTROLE ]
    local CloseBtn = Instance.new("TextButton", Title)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", CloseBtn)
    CloseBtn.MouseButton1Click:Connect(function() Screen:Destroy() end)

    -- [ CONTEÚDO ]
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
        _G.NexusActive = Nexus.Active
        toggleBtn.Text = Nexus.Active and "STOP CAPTURE" or "START CAPTURE"
        toggleBtn.BackgroundColor3 = Nexus.Active and Color3.fromRGB(220, 60, 60) or Color3.fromRGB(0, 180, 120)
    end)

    UI.LogContainer = Container
    print("Nexus-Hub: Interface carregada com sucesso!")
    return Container
end

function UI.addLog(Nexus, Decryption, remote, method, args, extra)
    if not UI.LogContainer then return end
    
    local logFrame = Instance.new("Frame", UI.LogContainer)
    logFrame.Size = UDim2.new(1, -10, 0, 100)
    logFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
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
        local code = Decryption.generateSnippet(remote, method, args)
        setclipboard(code)
        genBtn.Text = "COPIED!"
        task.wait(1)
        genBtn.Text = "GENERATE CODE"
    end)

    if Nexus.Settings.AutoScroll then
        UI.LogContainer.CanvasPosition = Vector2.new(0, 999999)
    end
end

return UI
