--!strict
-- ========================================================
-- [TEXHUB APEX ENGINE v3.5 - INTEGRATED AI SUITE]
-- ========================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer indisponível.")

-- Força o desenho no PlayerGui para funcionar no Delta Mobile
local ParentGui: Instance = LocalPlayer:WaitForChild("PlayerGui")


if ParentGui:FindFirstChild("TexHub_Apex_V3") then
    ParentGui.TexHub_Apex_V3:Destroy()
end

local C = {
    Bg     = Color3.fromRGB(13, 15, 22),
    Side   = Color3.fromRGB(18, 21, 30),
    Card   = Color3.fromRGB(23, 27, 39),
    Stroke = Color3.fromRGB(38, 45, 65),
    Neon   = Color3.fromRGB(0, 255, 170),
    AI_Glow= Color3.fromRGB(0, 200, 255),
    Txt    = Color3.fromRGB(245, 248, 255),
    Muted  = Color3.fromRGB(140, 150, 175),
    Off    = Color3.fromRGB(35, 41, 58),
    UserBubble = Color3.fromRGB(30, 36, 52),
    AIBubble   = Color3.fromRGB(16, 26, 36)
}

local TexHub = {}
TexHub.__index = TexHub

local function AddCorner(p: Instance, r: number)
    local u = Instance.new("UICorner")
    u.CornerRadius = UDim.new(0, r)
    u.Parent = p
end

local function AddStroke(p: Instance, col: Color3, t: number)
    local s = Instance.new("UIStroke")
    s.Color = col
    s.Thickness = t
    s.Parent = p
end

-- Detetor de função HTTP do executor
local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

function TexHub.CreateWindow(hubTitle: string, subtitle: string)
    local self = setmetatable({}, TexHub)

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "TexHub_Apex_V3"
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 9999
    Gui.Parent = ParentGui

    local NotifyHolder = Instance.new("Frame")
    NotifyHolder.Size = UDim2.new(0, 240, 1, -20)
    NotifyHolder.Position = UDim2.new(1, -250, 0, 10)
    NotifyHolder.BackgroundTransparency = 1
    NotifyHolder.Parent = Gui

    local NLayout = Instance.new("UIListLayout")
    NLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NLayout.Padding = UDim.new(0, 8)
    NLayout.Parent = NotifyHolder
    self.NotifyHolder = NotifyHolder

    local Badge = Instance.new("TextButton")
    Badge.Size = UDim2.new(0, 50, 0, 50)
    Badge.Position = UDim2.new(0.02, 0, 0.28, 0)
    Badge.BackgroundColor3 = C.Side
    Badge.Text = "⚡"
    Badge.TextSize = 22
    Badge.TextColor3 = C.Neon
    Badge.Parent = Gui
    AddCorner(Badge, 25)
    AddStroke(Badge, C.Neon, 1.8)

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 420, 0, 275)
    Main.Position = UDim2.new(0.5, -210, 0.5, -137)
    Main.BackgroundColor3 = C.Bg
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = Gui
    AddCorner(Main, 14)
    AddStroke(Main, C.Stroke, 1.2)

    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.BackgroundColor3 = C.Neon
    TopLine.BorderSizePixel = 0
    TopLine.Parent = Main

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.Position = UDim2.new(0, 0, 0, 2)
    Header.BackgroundColor3 = C.Side
    Header.BorderSizePixel = 0
    Header.Parent = Main

    local T = Instance.new("TextLabel")
    T.Size = UDim2.new(0.4, 0, 0, 18)
    T.Position = UDim2.new(0, 14, 0, 5)
    T.BackgroundTransparency = 1
    T.Font = Enum.Font.GothamBlack
    T.Text = hubTitle
    T.TextSize = 12
    T.TextColor3 = C.Neon
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Parent = Header

    local Sub = Instance.new("TextLabel")
    Sub.Size = UDim2.new(0.4, 0, 0, 14)
    Sub.Position = UDim2.new(0, 14, 0, 22)
    Sub.BackgroundTransparency = 1
    Sub.Font = Enum.Font.GothamMedium
    Sub.Text = subtitle
    Sub.TextSize = 9
    Sub.TextColor3 = C.Muted
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Parent = Header

    local Telemetry = Instance.new("TextLabel")
    Telemetry.Size = UDim2.new(0.35, 0, 1, 0)
    Telemetry.Position = UDim2.new(0.45, 0, 0, 0)
    Telemetry.BackgroundTransparency = 1
    Telemetry.Font = Enum.Font.GothamBold
    Telemetry.Text = "FPS: -- | PING: --ms"
    Telemetry.TextSize = 10
    Telemetry.TextColor3 = C.Muted
    Telemetry.TextXAlignment = Enum.TextXAlignment.Right
    Telemetry.Parent = Header

    task.spawn(function()
        local lastTime, count = tick(), 0
        RunService.RenderStepped:Connect(function()
            count = count + 1
            local now = tick()
            if now - lastTime >= 0.75 then
                local fps = math.floor(count / (now - lastTime))
                local ping = 0
                pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                Telemetry.Text = string.format("FPS: %d | %dms", fps, ping)
                count, lastTime = 0, now
            end
        end)
    end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -34, 0, 8)
    CloseBtn.BackgroundColor3 = C.Card
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 11
    CloseBtn.TextColor3 = C.Muted
    CloseBtn.Parent = Header
    AddCorner(CloseBtn, 6)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 110, 1, -44)
    Sidebar.Position = UDim2.new(0, 0, 0, 44)
    Sidebar.BackgroundColor3 = C.Side
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -8, 1, -10)
    TabScroll.Position = UDim2.new(0, 4, 0, 6)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabScroll.Parent = Sidebar

    local TList = Instance.new("UIListLayout")
    TList.Padding = UDim.new(0, 4)
    TList.Parent = TabScroll

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

    local open = true
    local function Toggle()
        open = not open
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = open and UDim2.new(0, 420, 0, 275) or UDim2.new(0, 0, 0, 0)
        }):Play()
        Main.Visible = open
    end

    Badge.MouseButton1Click:Connect(Toggle)
    CloseBtn.MouseButton1Click:Connect(Toggle)

    local function MakeDraggable(obj: GuiObject)
        local drag, dStart, sPos
        obj.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                drag, dStart, sPos = true, inp.Position, obj.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then drag = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local delta = inp.Position - dStart
                obj.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
            end
        end)
    end

    MakeDraggable(Main)
    MakeDraggable(Badge)
    return self
end

function TexHub:Notify(cfg: { Title: string, Content: string, Duration: number? })
    local d = cfg.Duration or 3
    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(1, 0, 0, 50)
    Toast.Position = UDim2.new(1, 40, 0, 0)
    Toast.BackgroundColor3 = C.Side
    Toast.Parent = self.NotifyHolder
    AddCorner(Toast, 8)
    AddStroke(Toast, C.Neon, 1.2)

    local Tit = Instance.new("TextLabel")
    Tit.Size = UDim2.new(1, -12, 0, 16)
    Tit.Position = UDim2.new(0, 10, 0, 6)
    Tit.BackgroundTransparency = 1
    Tit.Font = Enum.Font.GothamBold
    Tit.Text = cfg.Title
    Tit.TextSize = 11
    Tit.TextColor3 = C.Neon
    Tit.TextXAlignment = Enum.TextXAlignment.Left
    Tit.Parent = Toast

    local Msg = Instance.new("TextLabel")
    Msg.Size = UDim2.new(1, -12, 0, 18)
    Msg.Position = UDim2.new(0, 10, 0, 22)
    Msg.BackgroundTransparency = 1
    Msg.Font = Enum.Font.GothamMedium
    Msg.Text = cfg.Content
    Msg.TextSize = 9
    Msg.TextColor3 = C.Txt
    Msg.TextXAlignment = Enum.TextXAlignment.Left
    Msg.Parent = Toast

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 2)
    Bar.Position = UDim2.new(0, 0, 1, -2)
    Bar.BackgroundColor3 = C.Neon
    Bar.BorderSizePixel = 0
    Bar.Parent = Toast

    TweenService:Create(Toast, TweenInfo.new(0.25, Enum.EasingStyle.Quart), { Position = UDim2.new(0, 0, 0, 0) }):Play()
    TweenService:Create(Bar, TweenInfo.new(d, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()

    task.delay(d, function()
        local tw = TweenService:Create(Toast, TweenInfo.new(0.25), { Position = UDim2.new(1, 40, 0, 0) })
        tw:Play()
        tw.Completed:Connect(function() Toast:Destroy() end)
    end)
end

function TexHub:CreateTab(name: string, icon: string?)
    local tabSelf = {}
    local isFirst = self.FirstTab
    self.FirstTab = false

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = C.Card
    TabBtn.BackgroundTransparency = isFirst and 0 or 1
    TabBtn.Text = (icon and (icon .. "  ") or "") .. name
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 10
    TabBtn.TextColor3 = isFirst and C.Neon or C.Muted
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = self.TabScroll
    AddCorner(TabBtn, 6)

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft = UDim.new(0, 8)
    Pad.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = C.Neon
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = isFirst
    Page.Parent = self.PageContainer

    local PList = Instance.new("UIListLayout")
    PList.Padding = UDim.new(0, 6)
    PList.Parent = Page

    local PPad = Instance.new("UIPadding")
    PPad.PaddingRight = UDim.new(0, 4)
    PPad.PaddingBottom = UDim.new(0, 6)
    PPad.Parent = Page

    table.insert(self.Tabs, { Button = TabBtn, Page = Page })

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Page.Visible = false
            TweenService:Create(t.Button, TweenInfo.new(0.15), { BackgroundTransparency = 1, TextColor3 = C.Muted }):Play()
        end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0, TextColor3 = C.Neon }):Play()
    end)

    tabSelf.Page = Page

    function tabSelf:AddSection(title: string)
        local SecFrame = Instance.new("Frame")
        SecFrame.Size = UDim2.new(1, 0, 0, 20)
        SecFrame.BackgroundTransparency = 1
        SecFrame.Parent = Page

        local SecLabel = Instance.new("TextLabel")
        SecLabel.Size = UDim2.new(1, 0, 1, 0)
        SecLabel.BackgroundTransparency = 1
        SecLabel.Font = Enum.Font.GothamBlack
        SecLabel.Text = string.upper(title)
        SecLabel.TextSize = 9
        SecLabel.TextColor3 = C.Neon
        SecLabel.TextXAlignment = Enum.TextXAlignment.Left
        SecLabel.Parent = SecFrame
    end

    function tabSelf:AddToggle(title: string, desc: string, default: boolean, callback: (boolean) -> ())
        local state = default or false
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 44)
        Card.BackgroundColor3 = C.Card
        Card.Parent = Page
        AddCorner(Card, 8)
        AddStroke(Card, C.Stroke, 1)

        local T = Instance.new("TextLabel")
        T.Size = UDim2.new(0.75, 0, 0, 16)
        T.Position = UDim2.new(0, 10, 0, 6)
        T.BackgroundTransparency = 1
        T.Font = Enum.Font.GothamBold
        T.Text = title
        T.TextSize = 11
        T.TextColor3 = C.Txt
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = Card

        local D = Instance.new("TextLabel")
        D.Size = UDim2.new(0.75, 0, 0, 14)
        D.Position = UDim2.new(0, 10, 0, 23)
        D.BackgroundTransparency = 1
        D.Font = Enum.Font.GothamMedium
        D.Text = desc
        D.TextSize = 8
        D.TextColor3 = C.Muted
        D.TextXAlignment = Enum.TextXAlignment.Left
        D.Parent = Card

        local Sw = Instance.new("TextButton")
        Sw.Size = UDim2.new(0, 38, 0, 20)
        Sw.Position = UDim2.new(1, -48, 0.5, -10)
        Sw.BackgroundColor3 = state and C.Neon or C.Off
        Sw.Text = ""
        Sw.Parent = Card
        AddCorner(Sw, 10)

        local Pill = Instance.new("Frame")
        Pill.Size = UDim2.new(0, 14, 0, 14)
        Pill.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        Pill.BackgroundColor3 = Color3.new(1, 1, 1)
        Pill.Parent = Sw
        AddCorner(Pill, 7)

        Sw.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(Pill, TweenInfo.new(0.2), { Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }):Play()
            TweenService:Create(Sw, TweenInfo.new(0.2), { BackgroundColor3 = state and C.Neon or C.Off }):Play()
            callback(state)
        end)
    end

    function tabSelf:AddSlider(title: string, min: number, max: number, default: number, callback: (number) -> ())
        local val = math.clamp(default or min, min, max)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 48)
        Card.BackgroundColor3 = C.Card
        Card.Parent = Page
        AddCorner(Card, 8)
        AddStroke(Card, C.Stroke, 1)

        local T = Instance.new("TextLabel")
        T.Size = UDim2.new(0.7, 0, 0, 16)
        T.Position = UDim2.new(0, 10, 0, 5)
        T.BackgroundTransparency = 1
        T.Font = Enum.Font.GothamBold
        T.Text = title
        T.TextSize = 10
        T.TextColor3 = C.Txt
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = Card

        local VL = Instance.new("TextLabel")
        VL.Size = UDim2.new(0.25, 0, 0, 16)
        VL.Position = UDim2.new(0.72, 0, 0, 5)
        VL.BackgroundTransparency = 1
        VL.Font = Enum.Font.GothamBlack
        VL.Text = tostring(val)
        VL.TextSize = 10
        VL.TextColor3 = C.Neon
        VL.TextXAlignment = Enum.TextXAlignment.Right
        VL.Parent = Card

        local Rail = Instance.new("TextButton")
        Rail.Size = UDim2.new(1, -20, 0, 8)
        Rail.Position = UDim2.new(0, 10, 0, 28)
        Rail.BackgroundColor3 = C.Off
        Rail.Text = ""
        Rail.Parent = Card
        AddCorner(Rail, 4)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = C.Neon
        Fill.Parent = Rail
        AddCorner(Fill, 4)

        local dragging = false
        local function Upd(inp)
            local rel = math.clamp((inp.Position.X - Rail.AbsolutePosition.X) / Rail.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            local res = math.floor(min + ((max - min) * rel))
            VL.Text = tostring(res)
            callback(res)
        end

        Rail.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                Upd(inp)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                Upd(inp)
            end
        end)
    end

    function tabSelf:AddButton(title: string, callback: () -> ())
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 34)
        Btn.BackgroundColor3 = C.Card
        Btn.Text = title
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 10
        Btn.TextColor3 = C.Txt
        Btn.Parent = Page
        AddCorner(Btn, 8)
        AddStroke(Btn, C.Stroke, 1)

        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.08), { BackgroundColor3 = C.Neon, TextColor3 = Color3.fromRGB(10, 15, 20) }):Play()
            task.wait(0.1)
            TweenService:Create(Btn, TweenInfo.new(0.12), { BackgroundColor3 = C.Card, TextColor3 = C.Txt }):Play()
            callback()
        end)
    end

    return tabSelf
end

-- ========================================================
-- [MÓDULO NATIVO TEXAI COPILOT]
-- ========================================================
function TexHub:CreateAIAssistant(systemPrompt: string?, commandCallback: ((string) -> string?)?)
    local tab = self:CreateTab("TexAI", "🤖")
    local Page = tab.Page

    local StatusCard = Instance.new("Frame")
    StatusCard.Size = UDim2.new(1, 0, 0, 24)
    StatusCard.BackgroundColor3 = C.AIBubble
    StatusCard.Parent = Page
    AddCorner(StatusCard, 6)
    AddStroke(StatusCard, C.AI_Glow, 1)

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -16, 1, 0)
    StatusText.Position = UDim2.new(0, 8, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.GothamBold
    StatusText.Text = "● TEXAI COPILOT ONLINE [ASSISTENTE ATIVO]"
    StatusText.TextSize = 9
    StatusText.TextColor3 = C.AI_Glow
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = StatusCard

    local ChatBox = Instance.new("ScrollingFrame")
    ChatBox.Size = UDim2.new(1, 0, 0, 140)
    ChatBox.BackgroundColor3 = C.Side
    ChatBox.BorderSizePixel = 0
    ChatBox.ScrollBarThickness = 2
    ChatBox.ScrollBarImageColor3 = C.AI_Glow
    ChatBox.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ChatBox.Parent = Page
    AddCorner(ChatBox, 8)

    local CList = Instance.new("UIListLayout")
    CList.Padding = UDim.new(0, 6)
    CList.Parent = ChatBox

    local CPadding = Instance.new("UIPadding")
    CPadding.PaddingTop = UDim.new(0, 6)
    CPadding.PaddingBottom = UDim.new(0, 6)
    CPadding.PaddingLeft = UDim.new(0, 6)
    CPadding.PaddingRight = UDim.new(0, 6)
    CPadding.Parent = ChatBox

    local function AppendMessage(sender: string, text: string)
        local isAI = sender == "TexAI"
        local Bubble = Instance.new("Frame")
        Bubble.Size = UDim2.new(1, 0, 0, 0)
        Bubble.BackgroundColor3 = isAI and C.AIBubble or C.UserBubble
        Bubble.AutomaticSize = Enum.AutomaticSize.Y
        Bubble.Parent = ChatBox
        AddCorner(Bubble, 6)
        AddStroke(Bubble, isAI and C.AI_Glow or C.Stroke, 1)

        local Label = Instance.new("TextLabel"
