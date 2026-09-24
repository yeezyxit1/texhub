-- ============================================================================
-- [TEXHUB APEX - BIBLIOTECA GRÁFICA UNIVERSAL PARA MOBILE]
-- ============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local TexHub = {}

local function getSafeParent()
    local parent = nil
    pcall(function()
        if gethui then
            parent = gethui()
        elseif syn and syn.protect_gui then
            local f = Instance.new("Folder")
            syn.protect_gui(f)
            f.Parent = CoreGui
            parent = f
        else
            parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    return parent or LocalPlayer:WaitForChild("PlayerGui")
end

local function makeDraggable(handle, frame)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function TexHub:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "TEXHUB APEX PRO"
    local parentGui = getSafeParent()

    if parentGui:FindFirstChild("TexHub_Apex_Pro") then
        parentGui.TexHub_Apex_Pro:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TexHub_Apex_Pro"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = parentGui

    -- Botão Flutuante Tátil (TEX)
    local FloatBtn = Instance.new("TextButton")
    FloatBtn.Name = "FloatButton"
    FloatBtn.Size = UDim2.new(0, 48, 0, 48)
    FloatBtn.Position = UDim2.new(0, 15, 0.45, 0)
    FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
    FloatBtn.Text = "TEX"
    FloatBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
    FloatBtn.TextSize = 14
    FloatBtn.Font = Enum.Font.GothamBold
    FloatBtn.Parent = ScreenGui

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(1, 0)
    FCorner.Parent = FloatBtn

    local FStroke = Instance.new("UIStroke")
    FStroke.Color = Color3.fromRGB(0, 255, 170)
    FStroke.Thickness = 1.8
    FStroke.Parent = FloatBtn

    -- Janela Principal
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 390, 0, 255)
    Main.Position = UDim2.new(0.5, -195, 0.5, -127)
    Main.BackgroundColor3 = Color3.fromRGB(13, 16, 23)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local MCorner = Instance.new("UICorner")
    MCorner.CornerRadius = UDim.new(0, 9)
    MCorner.Parent = Main

    local MStroke = Instance.new("UIStroke")
    MStroke.Color = Color3.fromRGB(35, 45, 62)
    MStroke.Thickness = 1.4
    MStroke.Parent = Main

    -- Barra Superior
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 34)
    Topbar.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -70, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = windowTitle
    TitleLabel.RichText = true
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -32, 0.5, -13)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(26, 32, 45)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Topbar

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 6)
    CCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
    end)

    FloatBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)

    makeDraggable(Topbar, Main)
    makeDraggable(FloatBtn, FloatBtn)

    -- Barra Lateral (Abas)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 105, 1, -34)
    Sidebar.Position = UDim2.new(0, 0, 0, 34)
    Sidebar.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Padding = UDim.new(0, 4)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SideLayout.Parent = Sidebar

    local SidePad = Instance.new("UIPadding")
    SidePad.PaddingTop = UDim.new(0, 6)
    SidePad.Parent = Sidebar

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -112, 1, -40)
    ContentArea.Position = UDim2.new(0, 108, 0, 36)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Main

    local WindowObj = {
        Tabs = {},
        FirstTab = true
    }

    function WindowObj:CreateTab(tabName)
        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
        Page.Visible = WindowObj.FirstTab
        Page.Parent = ContentArea

        local PLayout = Instance.new("UIListLayout")
        PLayout.Padding = UDim.new(0, 6)
        PLayout.Parent = Page

        local PPad = Instance.new("UIPadding")
        PPad.PaddingRight = UDim.new(0, 4)
        PPad.Parent = Page

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 95, 0, 28)
        TabBtn.BackgroundColor3 = WindowObj.FirstTab and Color3.fromRGB(24, 30, 44) or Color3.fromRGB(18, 22, 32)
        TabBtn.Text = tabName
        TabBtn.TextColor3 = WindowObj.FirstTab and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(150, 160, 180)
        TabBtn.TextSize = 12
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.Parent = Sidebar

        local TCorner = Instance.new("UICorner")
        TCorner.CornerRadius = UDim.new(0, 6)
        TCorner.Parent = TabBtn

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(WindowObj.Tabs) do
                t.Page.Visible = false
                t.Btn.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
                t.Btn.TextColor3 = Color3.fromRGB(150, 160, 180)
            end
            Page.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
            TabBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
        end)

        WindowObj.FirstTab = false
        table.insert(WindowObj.Tabs, {Page = Page, Btn = TabBtn})

        local TabMethods = {}

        -- Toggle
        function TabMethods:AddToggle(title, default, callback)
            local state = default or false
            callback = callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 32)
            Frame.BackgroundColor3 = Color3.fromRGB(20, 25, 36)
            Frame.Parent = Page

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = Frame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -55, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = title
            Label.TextColor3 = Color3.fromRGB(230, 230, 235)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 36, 0, 18)
            Switch.Position = UDim2.new(1, -44, 0.5, -9)
            Switch.BackgroundColor3 = state and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(38, 44, 60)
            Switch.Text = ""
            Switch.Parent = Frame

            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(1, 0)
            SCorner.Parent = Switch

            Switch.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Switch, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(38, 44, 60)
                }):Play()
                callback(state)
            end)
        end

        -- Slider
        function TabMethods:AddSlider(title, min, max, default, callback)
            local value = default or min
            callback = callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 42)
            Frame.BackgroundColor3 = Color3.fromRGB(20, 25, 36)
            Frame.Parent = Page

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = Frame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 2)
            Label.BackgroundTransparency = 1
            Label.Text = title
            Label.TextColor3 = Color3.fromRGB(230, 230, 235)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0.35, -10, 0, 20)
            ValLabel.Position = UDim2.new(0.65, 0, 0, 2)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(value)
            ValLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 11
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = Frame

            local BarBg = Instance.new("Frame")
            BarBg.Size = UDim2.new(1, -20, 0, 8)
            BarBg.Position = UDim2.new(0, 10, 0, 26)
            BarBg.BackgroundColor3 = Color3.fromRGB(32, 38, 52)
            BarBg.Parent = Frame

            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(1, 0)
            BCorner.Parent = BarBg

            local BarFill = Instance.new("Frame")
            local pct = math.clamp((value - min) / (max - min), 0, 1)
            BarFill.Size = UDim2.new(pct, 0, 1, 0)
            BarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
            BarFill.Parent = BarBg

            local FCorner2 = Instance.new("UICorner")
            FCorner2.CornerRadius = UDim.new(1, 0)
            FCorner2.Parent = BarFill

            local sliding = false
            local function update(input)
                local pos = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                value = math.floor(min + ((max - min) * pos))
                BarFill.Size = UDim2.new(pos, 0, 1, 0)
                ValLabel.Text = tostring(value)
                callback(value)
            end

            BarBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    update(input)
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            sliding = false
                        end
                    end)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
        end

        -- Dropdown
        function TabMethods:AddDropdown(title, options, default, callback)
            options = options or {}
            local open = false
            local selected = default or options[1] or "Nenhum"
            callback = callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 32)
            Frame.BackgroundColor3 = Color3.fromRGB(20, 25, 36)
            Frame.ClipsDescendants = true
            Frame.Parent = Page

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = Frame

            local MainBtn = Instance.new("TextButton")
            MainBtn.Size = UDim2.new(1, 0, 0, 32)
            MainBtn.BackgroundTransparency = 1
            MainBtn.Text = "  " .. title .. ": " .. tostring(selected)
            MainBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
            MainBtn.Font = Enum.Font.Gotham
            MainBtn.TextSize = 11
            MainBtn.TextXAlignment = Enum.TextXAlignment.Left
            MainBtn.Parent = Frame

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 25, 0, 32)
            Arrow.Position = UDim2.new(1, -25, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = Color3.fromRGB(150, 160, 180)
            Arrow.TextSize = 10
            Arrow.Parent = Frame

            local OptHolder = Instance.new("Frame")
            OptHolder.Size = UDim2.new(1, -10, 0, #options * 26)
            OptHolder.Position = UDim2.new(0, 5, 0, 34)
            OptHolder.BackgroundTransparency = 1
            OptHolder.Parent = Frame

            local OptLayout = Instance.new("UIListLayout")
            OptLayout.Padding = UDim.new(0, 2)
            OptLayout.Parent = OptHolder

            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 24)
                OptBtn.BackgroundColor3 = Color3.fromRGB(26, 32, 46)
                OptBtn.Text = tostring(opt)
                OptBtn.TextColor3 = Color3.fromRGB(200, 205, 215)
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 10
                OptBtn.Parent = OptHolder

                local OCorner = Instance.new("UICorner")
                OCorner.CornerRadius = UDim.new(0, 4)
                OCorner.Parent = OptBtn

                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    MainBtn.Text = "  " .. title .. ": " .. tostring(selected)
                    open = false
                    Frame.Size = UDim2.new(1, 0, 0, 32)
                    Arrow.Text = "▼"
                    callback(selected)
                end)
            end

            MainBtn.MouseButton1Click:Connect(function()
                open = not open
                Arrow.Text = open and "▲" or "▼"
                Frame.Size = open and UDim2.new(1, 0, 0, 36 + (#options * 26)) or UDim2.new(1, 0, 0, 32)
            end)
        end

        -- Botão
        function TabMethods:AddButton(text, callback)
            callback = callback or function() end
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 28)
            Btn.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 11
            Btn.Parent = Page

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = Btn

            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Color3.fromRGB(38, 48, 66)
            Stroke.Thickness = 1
            Stroke.Parent = Btn

            Btn.MouseButton1Click:Connect(function()
                callback()
            end)
        end

        return TabMethods
    end

    return WindowObj
end

return TexHub
