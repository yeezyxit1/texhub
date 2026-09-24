--!strict
-- [TEXHUB - SKATE TO BRAINROTS: ELITE LEADERBOARD & SMART ESP]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer indisponível.")

-- ========================================================
-- TABELA DE RARIDADES RELEVANTES (FILTRO OP)
-- ========================================================
local HIGH_TIER_RARITIES: { [string]: Color3 } = {
    ["Secret"]    = Color3.fromRGB(255, 0, 85),    -- Magenta Escuro
    ["God"]       = Color3.fromRGB(255, 215, 0),   -- Dourado Brilhante
    ["Divine"]    = Color3.fromRGB(0, 255, 230),   -- Ciano Radiante
    ["Celestial"] = Color3.fromRGB(140, 0, 255),   -- Roxo Cósmico
    ["OG"]        = Color3.fromRGB(255, 70, 0),    -- Laranja Fogo
    ["Mythic"]    = Color3.fromRGB(255, 0, 170),   -- Rosa Choque
    ["Exclusive"] = Color3.fromRGB(0, 255, 120),   -- Verde Esmeralda
}

local SETTINGS = {
    AutoCash = false,
    AutoRebirth = false,
    SmartESP = false,
    GodmodeGuards = false,
    AutoZone10 = false,
}

local Events = ReplicatedStorage:WaitForChild("Events")
local RequestSlotCashCollect = Events:WaitForChild("RequestSlotCashCollect") :: RemoteEvent
local RequestRebirth = Events:WaitForChild("RequestRebirth") :: RemoteEvent
local ZoneTeleportFolder = Workspace:WaitForChild("ZoneTeleport")
local GuardsFolder = Workspace:WaitForChild("Guards")

-- 1. BYPASS ANTI-CHEAT (SILENCIA REPORTES AO SERVIDOR)
pcall(function()
    local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local oldNamecall = gmt.__namecall

    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and self.Name == "ReportAntiCheatDevice" then
            return nil
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(gmt, true)
end)

-- 2. SISTEMA DE ESP SELETIVO
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "TexHub_ESP"
ESPFolder.Parent = CoreGui

local function GetTargetRarity(modelName: string): (string?, Color3?)
    local brainrotsFolder = ReplicatedStorage:FindFirstChild("Brainrots")
    if not brainrotsFolder then return nil, nil end

    for tierName, color in pairs(HIGH_TIER_RARITIES) do
        for _, category in ipairs({"Normal", "Golden", "Diamond"}) do
            local catFolder = brainrotsFolder:FindFirstChild(category)
            if catFolder then
                local tierFolder = catFolder:FindFirstChild(tierName)
                if tierFolder and tierFolder:FindFirstChild(modelName) then
                    return tierName, color
                end
            end
        end
    end
    return nil, nil
end

local function ApplySmartESP(target: Model)
    if target:FindFirstChild("TexESP_Marker") then return end

    local rarity, color = GetTargetRarity(target.Name)
    if not rarity or not color then return end

    local root = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    -- Caixa de Contorno (Highlight)
    local highlight = Instance.new("Highlight")
    highlight.Name = "TexESP_Marker"
    highlight.Adornee = target
    highlight.FillColor = color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Parent = ESPFolder

    -- Painel Informativo Flutuante
    local bb = Instance.new("BillboardGui")
    bb.Name = "TexESP_Text"
    bb.Adornee = root
    bb.Size = UDim2.new(0, 160, 0, 45)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 11
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.2
    label.Text = string.format("[%s]\n%s", string.upper(rarity), target.Name)
    label.Parent = bb
end

local function ClearESP()
    ESPFolder:ClearAllChildren()
end

-- 3. BYPASS DE GUARDAS (GODMODE)
local function NeutralizeGuards()
    for _, guard in ipairs(GuardsFolder:GetChildren()) do
        local hitbox = guard:FindFirstChild("Hitbox") :: BasePart?
        if hitbox then
            hitbox.CanTouch = false
            hitbox.CanCollide = false
            hitbox.Size = Vector3.new(0.01, 0.01, 0.01)
        end
    end
end

-- 4. TELEPORTE DE ZONA MÁXIMA
local function TriggerMaxZone()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root or not firetouchinterest then return end

    local zone10 = ZoneTeleportFolder:FindFirstChild("Zone10Teleport") :: BasePart?
    if zone10 then
        firetouchinterest(root, zone10, 0)
        task.wait(0.02)
        firetouchinterest(root, zone10, 1)
    end
end

-- 5. INTERFACE MOBILE DE ALTA PERFORMANCE
local ParentGui: Instance = CoreGui
pcall(function()
    if not pcall(function() return CoreGui.Name end) then
        ParentGui = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

if ParentGui:FindFirstChild("TexHubSkatePro") then
    ParentGui.TexHubSkatePro:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TexHubSkatePro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 48, 0, 48)
FloatBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
FloatBtn.Text = "👑"
FloatBtn.TextSize = 22
FloatBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundTransparency = 1
Title.Text = "TEXHUB - GLOBAL LEADERBOARD"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 11
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.Parent = MainFrame

local function CreateToggle(name: string, yPos: number, callback: (boolean) -> ())
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
    btn.Text = name .. ": [OFF]"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = MainFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. (state and ": [ATIVO]" or ": [OFF]")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(28, 33, 46)
        callback(state)
    end)
    return btn
end

CreateToggle("AUTO CASH SLOTS (INSTANT)", 42, function(val) SETTINGS.AutoCash = val end)
CreateToggle("AUTO REBIRTH (RANKING)", 78, function(val) SETTINGS.AutoRebirth = val end)
CreateToggle("SMART ESP (RAROS & DEUSES)", 114, function(val) 
    SETTINGS.SmartESP = val 
    if not val then ClearESP() end
end)
CreateToggle("GODMODE GUARDAS (SEM MORTE)", 150, function(val) SETTINGS.GodmodeGuards = val end)
CreateToggle("AUTO FARM ZONA 10", 186, function(val) SETTINGS.AutoZone10 = val end)

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(1, -20, 0, 32)
ClearBtn.Position = UDim2.new(0, 10, 0, 226)
ClearBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
ClearBtn.Text = "⚡ TELEPORTAR PRA ZONA FINAL"
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 10
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Parent = MainFrame

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearBtn

ClearBtn.MouseButton1Click:Connect(TriggerMaxZone)

-- Movimentação da Interface
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

MakeDraggable(MainFrame)
MakeDraggable(FloatBtn)

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 6. ROTINAS EM PARALELO DE ULTRA VELOCIDADE
task.spawn(function()
    while true do
        if SETTINGS.AutoCash then
            pcall(function() RequestSlotCashCollect:FireServer() end)
        end
        if SETTINGS.AutoRebirth then
            pcall(function() RequestRebirth:FireServer() end)
        end
        task.wait(0.15)
    end
end)

task.spawn(function()
    while true do
        if SETTINGS.GodmodeGuards then
            NeutralizeGuards()
        end
        if SETTINGS.AutoZone10 then
            TriggerMaxZone()
        end
        task.wait(0.4)
    end
end)

-- Varredura do ESP
task.spawn(function()
    while true do
        if SETTINGS.SmartESP then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and not obj:FindFirstChildOfClass("Humanoid") then
                    ApplySmartESP(obj)
                end
            end
        end
        task.wait(1.5)
    end
end)
