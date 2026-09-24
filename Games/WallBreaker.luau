-- ============================================================================
-- [TEXHUB APEX v3.5 - WALL BREAKER ELITE ALL-IN-ONE MOBILE]
-- ============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 1. SELEÇÃO SEGURA DA PASTA DE RENDERIZAÇÃO NO DELTA MOBILE
local ParentGui = nil
pcall(function()
    if gethui then
        ParentGui = gethui()
    elseif syn and syn.protect_gui then
        local f = Instance.new("Folder")
        syn.protect_gui(f)
        f.Parent = CoreGui
        ParentGui = f
    else
        ParentGui = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

if not ParentGui then
    ParentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- Limpa execuções antigas do ecrã
if ParentGui:FindFirstChild("TexHub_WallBreaker") then
    ParentGui.TexHub_WallBreaker:Destroy()
end

-- 2. RESOLUÇÃO SEGURA DOS REMOTES DO JOGO
local function findRemote(name)
    local found = ReplicatedStorage:FindFirstChild(name, true)
    return found
end

local ClickTrainEvent = findRemote("ClickTrainEvent") or findRemote("ClickTrain")
local BuyDumbbellEvent = findRemote("BuyDumbbellEvent") or findRemote("BuyDumbbell")
local StageCompleteEvent = findRemote("StageCompleteEvent") or findRemote("StageComplete")
local SuperCollectorEvt = findRemote("SuperCollectorEvt") or findRemote("SuperCollector")
local EruptionHitEvent = findRemote("EruptionHitEvent") or findRemote("EruptionHit")
local OpenEggEvent = findRemote("OpenEggEvent") or findRemote("OpenEgg")
local DailyRewardFunction = findRemote("DailyRewardFunction") or findRemote("DailyReward")
local QuestFunction = findRemote("QuestFunction") or findRemote("Quest")

-- 3. ESTADOS E CONFIGURAÇÕES
local States = {
    AutoTrain = false,
    AutoDumbbell = false,
    AutoStage = false,
    AutoCollector = false,
    AutoEruption = false,
    InfJump = false,
    Noclip = false,
    Speed = 16
}

-- 4. CONSTRUÇÃO DA INTERFACE GRÁFICA (TEXHUB APEX ENGINE)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TexHub_WallBreaker"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = ParentGui

-- Botão Flutuante Redondo (Abrir/Fechar no Mobile)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 46, 0, 46)
OpenBtn.Position = UDim2.new(0, 15, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
OpenBtn.Text = "TEX"
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
OpenBtn.TextSize = 14
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenBtn

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(0, 255, 170)
OpenStroke.Thickness = 1.6
OpenStroke.Parent = OpenBtn

-- Janela Principal
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 360, 0, 250)
Main.Position = UDim2.new(0.5, -180, 0.5, -125)
Main.BackgroundColor3 = Color3.fromRGB(13, 16, 23)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 42, 58)
MainStroke.Thickness = 1.2
MainStroke.Parent = Main

-- Barra Superior (Header)
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 32)
Topbar.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
Topbar.BorderSizePixel = 0
Topbar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TEXHUB APEX <font color='#00FFAA'>[Wall Breaker]</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Topbar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Barra Lateral (Abas)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 105, 1, -32)
Sidebar.Position = UDim2.new(0, 0, 0, 32)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 4)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 6)
SidePad.Parent = Sidebar

-- Área de Conteúdo
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -111, 1, -38)
ContentArea.Position = UDim2.new(0, 108, 0, 35)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Main

-- Função de Arrastar Janela no Ecrã Tátil (Mobile Friendly)
local function makeDraggable(dragHandle, targetFrame)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(Topbar, Main)
makeDraggable(OpenBtn, OpenBtn)

-- 5. GESTOR DE ABAS E COMPONENTES
local Tabs = {}
local FirstTab = true

local function CreateTab(tabName)
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = tabName .. "_Page"
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.ScrollBarThickness = 2
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
    TabPage.Visible = FirstTab
    TabPage.Parent = ContentArea

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = TabPage

    local PagePad = Instance.new("UIPadding")
    PagePad.PaddingRight = UDim.new(0, 4)
    PagePad.PaddingTop = UDim.new(0, 2)
    PagePad.Parent = TabPage

    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabName .. "_Btn"
    TabBtn.Size = UDim2.new(0, 95, 0, 28)
    TabBtn.BackgroundColor3 = FirstTab and Color3.fromRGB(24, 30, 44) or Color3.fromRGB(18, 22, 32)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = FirstTab and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(150, 160, 180)
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.Parent = Sidebar

    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 6)
    TabBtnCorner.Parent = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
            t.Button.TextColor3 = Color3.fromRGB(150, 160, 180)
        end
        TabPage.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
        TabBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
    end)

    FirstTab = false
    local tabObj = {Page = TabPage, Button = TabBtn}
    table.insert(Tabs, tabObj)
    return TabPage
end

-- Componente: Toggle
local function AddToggle(parentPage, labelText, defaultVal, callback)
    local active = defaultVal or false

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 36)
    ToggleFrame.Parent = parentPage

    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 6)
    TCorner.Parent = ToggleFrame

    local TLabel = Instance.new("TextLabel")
    TLabel.Size = UDim2.new(1, -50, 1, 0)
    TLabel.Position = UDim2.new(0, 10, 0, 0)
    TLabel.BackgroundTransparency = 1
    TLabel.Text = labelText
    TLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
    TLabel.Font = Enum.Font.Gotham
    TLabel.TextSize = 11
    TLabel.TextXAlignment = Enum.TextXAlignment.Left
    TLabel.Parent = ToggleFrame

    local Indicator = Instance.new("TextButton")
    Indicator.Size = UDim2.new(0, 34, 0, 18)
    Indicator.Position = UDim2.new(1, -40, 0.5, -9)
    Indicator.BackgroundColor3 = active and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(36, 42, 58)
    Indicator.Text = ""
    Indicator.Parent = ToggleFrame

    local ICorner = Instance.new("UICorner")
    ICorner.CornerRadius = UDim.new(1, 0)
    ICorner.Parent = Indicator

    Indicator.MouseButton1Click:Connect(function()
        active = not active
        Indicator.BackgroundColor3 = active and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(36, 42, 58)
        callback(active)
    end)
end

-- Componente: Botão Simples
local function AddButton(parentPage, labelText, callback)
    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(1, 0, 0, 30)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
    ActionBtn.Text = labelText
    ActionBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
    ActionBtn.Font = Enum.Font.GothamMedium
    ActionBtn.TextSize = 11
    ActionBtn.Parent = parentPage

    local ACorner = Instance.new("UICorner")
    ACorner.CornerRadius = UDim.new(0, 6)
    ACorner.Parent = ActionBtn

    local AStroke = Instance.new("UIStroke")
    AStroke.Color = Color3.fromRGB(35, 42, 58)
    AStroke.Thickness = 1
    AStroke.Parent = ActionBtn

    ActionBtn.MouseButton1Click:Connect(function()
        callback()
    end)
end

-- 6. MONTAGEM DAS ABAS E FUNÇÕES DO WALL BREAKER
local TabFarm = CreateTab("Auto Farm")
local TabExtra = CreateTab("Eventos")
local TabPlayer = CreateTab("Jogador")

-- ABA 1: AUTO FARM
AddToggle(TabFarm, "Auto Treino / Click", false, function(state)
    States.AutoTrain = state
    if state then
        task.spawn(function()
            while States.AutoTrain do
                pcall(function()
                    if ClickTrainEvent then
                        ClickTrainEvent:FireServer()
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end)

AddToggle(TabFarm, "Auto Comprar Halteres", false, function(state)
    States.AutoDumbbell = state
    if state then
        task.spawn(function()
            while States.AutoDumbbell do
                pcall(function()
                    if BuyDumbbellEvent then
                        BuyDumbbellEvent:FireServer()
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

AddToggle(TabFarm, "Auto Quebrar Parede", false, function(state)
    States.AutoStage = state
    if state then
        task.spawn(function()
            while States.AutoStage do
                pcall(function()
                    if StageCompleteEvent then
                        StageCompleteEvent:FireServer()
                    end
                end)
                task.wait(0.2)
            end
        end)
    end
end)

-- ABA 2: EVENTOS & RECOMPENSAS
AddToggle(TabExtra, "Auto Super Collector", false, function(state)
    States.AutoCollector = state
    if state then
        task.spawn(function()
            while States.AutoCollector do
                pcall(function()
                    if SuperCollectorEvt then
                        SuperCollectorEvt:FireServer()
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

AddToggle(TabExtra, "Auto Erupção", false, function(state)
    States.AutoEruption = state
    if state then
        task.spawn(function()
            while States.AutoEruption do
                pcall(function()
                    if EruptionHitEvent then
                        EruptionHitEvent:FireServer()
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

AddButton(TabExtra, "Resgatar Recompensas & Missões", function()
    pcall(function()
        if DailyRewardFunction then
            DailyRewardFunction:InvokeServer()
        end
        if QuestFunction then
            QuestFunction:InvokeServer()
        end
    end)
end)

-- ABA 3: JOGADOR (SPEED, NOCLIP, PULO)
AddToggle(TabPlayer, "Velocidade +50", false, function(state)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = state and 50 or 16
    end
end)

AddToggle(TabPlayer, "Pulo Infinito", false, function(state)
    States.InfJump = state
end)

UserInputService.JumpRequest:Connect(function()
    if States.InfJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

AddToggle(TabPlayer, "Atravessar Paredes (Noclip)", false, function(state)
    States.Noclip = state
end)

RunService.Stepped:Connect(function()
    if States.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- 7. NOTIFICAÇÃO INICIAL DE SUCESSO
local Notif = Instance.new("Frame")
Notif.Size = UDim2.new(0, 180, 0, 30)
Notif.Position = UDim2.new(1, -195, 0, 15)
Notif.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
Notif.Parent = ScreenGui

local NCorner = Instance.new("UICorner")
NCorner.CornerRadius = UDim.new(0, 6)
NCorner.Parent = Notif

local NStroke = Instance.new("UIStroke")
NStroke.Color = Color3.fromRGB(0, 255, 170)
NStroke.Thickness = 1.2
NStroke.Parent = Notif

local NText = Instance.new("TextLabel")
NText.Size = UDim2.new(1, 0, 1, 0)
NText.BackgroundTransparency = 1
NText.Text = "✓ TexHub Injetado!"
NText.TextColor3 = Color3.fromRGB(0, 255, 170)
NText.Font = Enum.Font.GothamBold
NText.TextSize = 11
NText.Parent = Notif

task.delay(4, function()
    TweenService:Create(Notif, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(NText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(NStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    task.wait(0.5)
    Notif:Destroy()
end)
