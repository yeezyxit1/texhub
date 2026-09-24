--!strict
-- ========================================================
-- [TEXHUB APEX ENGINE v3.0 - CORE UI LIBRARY]
-- ========================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer indisponível.")

local ParentGui: Instance = CoreGui
pcall(function()
    if not pcall(function() return CoreGui.Name end) then
        ParentGui = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

if ParentGui:FindFirstChild("TexHub_Apex_V3") then
    ParentGui.TexHub_Apex_V3:Destroy()
end

local THEME = {
    Background    = Color3.fromRGB(13, 15, 22),
    Sidebar       = Color3.fromRGB(18, 21, 30),
    CardBg        = Color3.fromRGB(23, 27, 39),
    CardStroke    = Color3.fromRGB(38, 45, 65),
    Accent        = Color3.fromRGB(0, 255, 170),
    AccentGlow    = Color3.fromRGB(0, 200, 255),
    TextPrimary   = Color3.fromRGB(245, 248, 255),
    TextSecondary = Color3.fromRGB(140, 150, 175),
    ToggleOff     = Color3.fromRGB(35, 41, 58),
    PillWhite     = Color3.fromRGB(255, 255, 255),
}

local TexHub = {}
TexHub.__index = TexHub

function TexHub.CreateWindow(hubTitle: string, subtitle: string)
    local self = setmetatable({}, TexHub)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TexHub_Apex_V3"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 9999
    ScreenGui.Parent = ParentGui

    self.ScreenGui = ScreenGui

    local NotifyHolder = Instance.new("Frame")
    NotifyHolder.Name = "NotifyHolder"
    NotifyHolder.Size = UDim2.new(0, 240, 1, -20)
    NotifyHolder.Position = UDim2.new(1, -250, 0, 10)
    NotifyHolder.BackgroundTransparency = 1
    NotifyHolder.Parent = ScreenGui

    local NotifyLayout = Instance.new("UIListLayout")
    NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifyLayout.Padding = UDim.new(0, 8)
    NotifyLayout.Parent = NotifyHolder

    self.NotifyHolder = NotifyHolder

    local FloatBadge = Instance.new("TextButton")
    FloatBadge.Name = "TexFloatBadge"
    FloatBadge.Size = UDim2.new(0, 50, 0, 50)
    FloatBadge.Position = UDim2.new(0.02, 0, 0.28, 0)
    FloatBadge.BackgroundColor3 = THEME.Sidebar
    FloatBadge.Text = "⚡"
    FloatBadge.TextSize = 22
    FloatBadge.TextColor3 = THEME.Accent
    FloatBadge.Parent = ScreenGui

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(1, 0)
    FloatCorner.Parent = FloatBadge

    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Color = THEME.Accent
    FloatStroke.Thickness = 1.8
    FloatStroke.Parent = FloatBadge

    local Main = Instance.new("Frame")
    Main.Name = "ApexMainFrame"
    Main.Size = UDim2.new(0, 420, 0, 275)
    Main.Position = UDim2.new(0.5, -210, 0.5, -137)
    Main.BackgroundColor3 = THEME.Background
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = THEME.CardStroke
    MainStroke.Thickness = 1.2
    MainStroke.Parent = Main

    local TopGlowLine = Instance.new("Frame")
    TopGlowLine.Size = UDim2.new(1, 0, 0, 2)
    TopGlowLine.BackgroundColor3 = THEME.Accent
    TopGlowLine.BorderSizePixel = 0
    TopGlowLine.Parent = Main

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.Position = UDim2.new(0, 0, 0, 2)
    Header.BackgroundColor3 = THEME.Sidebar
    Header.BorderSizePixel = 0
    Header.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.4, 0, 0, 18)
    Title.Position = UDim2.new(0, 14, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBlack
    Title.Text = hubTitle
    Title.TextSize = 12
    Title.TextColor3 = THEME.Accent
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local Sub = Instance.new("TextLabel")
    Sub.Size = UDim2.new(0.4, 0, 0, 14)
    Sub.Position = UDim2.new(0, 14, 0, 22)
    Sub.BackgroundTransparency = 1
    Sub.Font = Enum.Font.GothamMedium
    Sub.Text = subtitle
    Sub.TextSize = 9
    Sub.TextColor3 = THEME.TextSecondary
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Parent = Header

    local TelemetryLabel = Instance.new("TextLabel")
    TelemetryLabel.Size = UDim2.new(0.35, 0, 1, 0)
    TelemetryLabel.Position = UDim2.new(0.45, 0, 0, 0)
    TelemetryLabel.BackgroundTransparency = 1
    TelemetryLabel.Font = Enum.Font.GothamBold
    TelemetryLabel.Text = "FPS: -- | PING: --ms"
    TelemetryLabel.TextSize = 10
    TelemetryLabel.TextColor3 = THEME.TextSecondary
    TelemetryLabel.TextXAlignment = Enum.TextXAlignment.Right
    TelemetryLabel.Parent = Header

    task.spawn(function()
        local lastTime = tick()
        local frameCount = 0
        RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            local now = tick()
            if now - lastTime >= 0.75 then
                local fps = math.floor(frameCount / (now - lastTime))
                local ping = 0
                pcall(function()
                    ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                TelemetryLabel.Text = string.format("FPS: %d  |  %dms", fps, ping)
                frameCount = 0
                lastTime = now
            end
        end)
    end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -34, 0, 8)
    CloseBtn.BackgroundColor3 = THEME.CardBg
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 11
    CloseBtn.TextColor3 = THEME.TextSecondary
    CloseBtn.Parent = Header

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    local SidebarFrame = Instance.new("Frame")
    SidebarFrame.Size = UDim2.new(0, 110, 1, -44)
    SidebarFrame.Position = UDim2.new(0, 0, 0, 44)
    SidebarFrame.BackgroundColor3 = THEME.Sidebar
    SidebarFrame.BorderSizePixel = 0
    SidebarFrame.Parent = Main

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -8, 1, -10)
    TabScroll.Position = UDim2.new(0, 4, 0, 6)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabScroll.Parent = SidebarFrame

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 4)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabScroll

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -118, 1, -52)
    PageContainer.Position = UDim2.new(0, 114, 0, 48)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Main

    self.Main = Main
    self.TabScroll = TabScroll
    self.PageContainer = PageContainer
    self.Tabs = {}
    self.FirstTab = true

    local isOpen = true
    local function ToggleVisibility()
        isOpen = not isOpen
        local targetSize = isOpen and UDim2.new(0, 420, 0, 275) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
        Main.Visible = isOpen
    end

    FloatBadge.MouseButton1Click:Connect(ToggleVisibility)
    CloseBtn.MouseButton1Click:Connect(ToggleVisibility)

    local function MakeDraggable(gui: GuiObject)
        local dragging, dragStart, startPos
        gui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    MakeDraggable(Main)
    MakeDraggable(FloatBadge)

    return self
end

function TexHub:Notify(config: { Title: string, Content: string, Duration: number? })
    local duration = config.Duration or 3.5

    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(1, 0, 0, 52)
    Toast.Position = UDim2.new(1, 40, 0, 0)
    Toast.BackgroundColor3 = THEME.Sidebar
    Toast.Parent = self.NotifyHolder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Toast

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = THEME.Accent
    Stroke.Thickness = 1.2
    Stroke.Parent = Toast

    local TxtTitle = Instance.new("TextLabel")
    TxtTitle.Size = UDim2.new(1, -12, 0, 16)
    TxtTitle.Position = UDim2.new(0, 10, 0, 6)
    TxtTitle.BackgroundTransparency = 1
    TxtTitle.Font = Enum.Font.GothamBold
    TxtTitle.Text = config.Title
    TxtTitle.TextSize = 11
    TxtTitle.TextColor3 = THEME.Accent
    TxtTitle.TextXAlignment = Enum.TextXAlignment.Left
    TxtTitle.Parent = Toast

    local TxtContent = Instance.new("TextLabel")
    TxtContent.Size = UDim2.new(1, -12, 0, 18)
    TxtContent.Position = UDim2.new(0, 10, 0, 22)
    TxtContent.BackgroundTransparency = 1
    TxtContent.Font = Enum.Font.GothamMedium
    TxtContent.Text = config.Content
    TxtContent.TextSize = 9
    TxtContent.TextColor3 = THEME.TextPrimary
    TxtContent.TextXAlignment = Enum.TextXAlignment.Left
    TxtContent.Parent = Toast

    local Progress = Instance.new("Frame")
    Progress.Size = UDim2.new(1, 0, 0, 2)
    Progress.Position = UDim2.new(0, 0, 1, -2)
    Progress.BackgroundColor3 = THEME.Accent
    Progress.BorderSizePixel = 0
    Progress.Parent = Toast

    TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    TweenService:Create(Progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    }):Play()

    task.delay(duration, function()
        local outTween = TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 40, 0, 0)
        })
        outTween:Play()
        outTween.Completed:Connect(function()
            Toast:Destroy()
        end)
    end)
end

function TexHub:CreateTab(name: string, icon: string?)
    local tabSelf = {}
    local isFirst = self.FirstTab
    self.FirstTab = false

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = isFirst and THEME.CardBg or Color3.fromRGB(0, 0, 0)
    TabBtn.BackgroundTransparency = isFirst and 0 or 1
    TabBtn.Text = (icon and (icon .. "  ") or "") .. name
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 10
    TabBtn.TextColor3 = isFirst and THEME.Accent or THEME.TextSecondary
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = self.TabScroll

    local BtnPad = Instance.new("UIPadding")
    BtnPad.PaddingLeft = UDim.new(0, 8)
    BtnPad.Parent = TabBtn

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = THEME.Accent
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = isFirst
    Page.Parent = self.PageContainer

    local PageList = Instance.new("UIListLayout")
    PageList.Padding = UDim.new(0, 6)
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Parent = Page

    local PagePad = Instance.new("UIPadding")
    PagePad.PaddingRight = UDim.new(0, 4)
    PagePad.PaddingBottom = UDim.new(0, 6)
    PagePad.Parent = Page

    table.insert(self.Tabs, { Button = TabBtn, Page = Page })

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Page.Visible = false
            TweenService:Create(t.Button, TweenInfo.new(0.18), {
                BackgroundTransparency = 1,
                TextColor3 = THEME.TextSecondary
            }):Play()
        end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.18), {
            BackgroundTransparency = 0,
            BackgroundColor3 = THEME.CardBg,
            TextColor3 = THEME.Accent
        }):Play()
    end)

    tabSelf.Page = Page

    function tabSelf:AddToggle(title: string, desc: string, default: boolean, callback: (boolean) -> ())
        local state = default or false

        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 44)
        Card.BackgroundColor3 = THEME.CardBg
        Card.Parent = Page

        local CC = Instance.new("UICorner")
        CC.CornerRadius = UDim.new(0, 8)
        CC.Parent = Card

        local CS = Instance.new("UIStroke")
        CS.Color = THEME.CardStroke
        CS.Thickness = 1
        CS.Parent = Card

        local T = Instance.new("TextLabel")
        T.Size = UDim2.new(0.75, 0, 0, 16)
        T.Position = UDim2.new(0, 10, 0, 6)
        T.BackgroundTransparency = 1
        T.Font = Enum.Font.GothamBold
        T.Text = title
        T.TextSize = 11
        T.TextColor3 = THEME.TextPrimary
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = Card

        local D = Instance.new("TextLabel")
        D.Size = UDim2.new(0.75, 0, 0, 14)
        D.Position = UDim2.new(0, 10, 0, 23)
        D.BackgroundTransparency = 1
        D.Font = Enum.Font.GothamMedium
        D.Text = desc
        D.TextSize = 8
        D.TextColor3 = THEME.TextSecondary
        D.TextXAlignment = Enum.TextXAlignment.Left
        D.Parent = Card

        local Switch = Instance.new("TextButton")
        Switch.Size = UDim2.new(0, 38, 0, 20)
        Switch.Position = UDim2.new(1, -48, 0.5, -10)
        Switch.BackgroundColor3 = state and THEME.Accent or THEME.ToggleOff
        Switch.Text = ""
        Switch.Parent = Card

        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(1, 0)
        SwitchCorner.Parent = Switch

        local Pill = Instance.new("Frame")
        Pill.Size = UDim2.new(0, 14, 0, 14)
        Pill.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        Pill.BackgroundColor3 = THEME.PillWhite
        Pill.Parent = Switch

        local PillCorner = Instance.new("UICorner")
        PillCorner.CornerRadius = UDim.new(1, 0)
        PillCorner.Parent = Pill

        Switch.MouseButton1Click:Connect(function()
            state = not state
            local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            local targetBg = state and THEME.Accent or THEME.ToggleOff

            TweenService:Create(Pill, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { Position = targetPos }):Play()
            TweenService:Create(Switch, TweenInfo.new(0.2), { BackgroundColor3 = targetBg }):Play()

            callback(state)
        end)
    end

    function tabSelf:AddSlider(title: string, min: number, max: number, default: number, callback: (number) -> ())
        local val = math.clamp(default or min, min, max)

        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 48)
        Card.BackgroundColor3 = THEME.CardBg
        Card.Parent = Page

        local CC = Instance.new("UICorner")
        CC.CornerRadius = UDim.new(0, 8)
        CC.Parent = Card

        local CS = Instance.new("UIStroke")
        CS.Color = THEME.CardStroke
        CS.Thickness = 1
        CS.Parent = Card

        local T = Instance.new("TextLabel")
        T.Size = UDim2.new(0.7, 0, 0, 16)
        T.Position = UDim2.new(0, 10, 0, 5)
        T.BackgroundTransparency = 1
        T.Font = Enum.Font.GothamBold
        T.Text = title
        T.TextSize = 10
        T.TextColor3 = THEME.TextPrimary
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = Card

        local ValLabel = Instance.new("TextLabel")
        ValLabel.Size = UDim2.new(0.25, 0, 0, 16)
        ValLabel.Position = UDim2.new(0.72, 0, 0, 5)
        ValLabel.BackgroundTransparency = 1
        ValLabel.Font = Enum.Font.GothamBlack
        ValLabel.Text = tostring(val)
        ValLabel.TextSize = 10
        ValLabel.TextColor3 = THEME.Accent
        ValLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValLabel.Parent = Card

        local Rail = Instance.new("TextButton")
        Rail.Size = UDim2.new(1, -20, 0, 8)
        Rail.Position = UDim2.new(0, 10, 0, 28)
        Rail.BackgroundColor3 = THEME.ToggleOff
        Rail.Text = ""
        Rail.Parent = Card

        local RailCorner = Instance.new("UICorner")
        RailCorner.CornerRadius = UDim.new(1, 0)
        RailCorner.Parent = Rail

        local Fill = Instance.new("Frame")
        local startScale = (val - min) / (max - min)
        Fill.Size = UDim2.new(startScale, 0, 1, 0)
        Fill.BackgroundColor3 = THEME.Accent
        Fill.Parent = Rail

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill

        local isDragging = false
        local function Update(input)
            local rel = math.clamp((input.Position.X - Rail.AbsolutePosition.X) / Rail.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            local currentVal = math.floor(min + ((max - min) * rel))
            ValLabel.Text = tostring(currentVal)
            callback(currentVal)
        end

        Rail.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                Update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                Update(input)
            end
        end)
    end

    function tabSelf:AddDropdown(title: string, options: { string }, default: string?, callback: (string) -> ())
        local selected = default or options[1] or "Nenhum"
        local isExpanded = false

        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 38)
        Card.BackgroundColor3 = THEME.CardBg
        Card.ClipsDescendants = true
        Card.Parent = Page

        local CC = Instance.new("UICorner")
        CC.CornerRadius = UDim.new(0, 8)
        CC.Parent = Card

        local CS = Instance.new("UIStroke")
        CS.Color = THEME.CardStrok
