    --!strict
-- [TEXHUB - MATH SOCCER ELITE MODULE]
-- Alvo calibrado: Hitbox 'Bottom' + Leitura de 'InfoGUI'

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer não encontrado.")

local SETTINGS = {
    AutoFarm = false,
    ReturnMode = "Remote",         -- "Remote" ou "CFrame"
    CollectDelay = 0.08,           -- Coleta ultrarrápida
    ReturnDelay = 0.15,            -- Intervalo mínimo entre voltas
    PrioritizeVIP = true,
}

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local TeleportHomeRemote = EventsFolder:WaitForChild("TeleportHome") :: RemoteFunction
local ActiveCardsFolder = Workspace:WaitForChild("ActiveCards") :: Folder
local PlayerPlotName = "Plot_" .. LocalPlayer.Name

-- 1. LOCALIZAÇÃO DA HITBOX REAL E DADOS DA CARTA
local function ExtractCardInfo(card: Model): (BasePart?, string)
    -- Hitbox prioritária descoberta no diagnóstico
    local hitbox = card:FindFirstChild("Bottom") :: BasePart?
    if not hitbox then
        hitbox = card:FindFirstChildWhichIsA("BasePart")
    end

    -- Leitura dos rótulos de texto dentro do InfoGUI
    local cardName = card.Name
    local infoGui = card:FindFirstChild("InfoGUI")
    if infoGui then
        for _, obj in ipairs(infoGui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Text ~= "" and obj.Text ~= "Label" then
                cardName = obj.Text
                break
            end
        end
    end

    return hitbox, cardName
end

-- 2. CALCULO DE POSIÇÃO NA BASE
local function GetSafePlotCFrame(): CFrame?
    local plot = Workspace:FindFirstChild(PlayerPlotName)
    if not plot then return nil end

    local floor1 = plot:FindFirstChild("Floor1")
    if floor1 and floor1:IsA("Model") then
        local cf, size = floor1:GetBoundingBox()
        return cf + Vector3.new(0, (size.Y / 2) + 3, 0)
    end

    if plot:IsA("Model") then
        local cf, size = plot:GetBoundingBox()
        return cf + Vector3.new(0, 4, 0)
    end
    return nil
end

-- 3. INTERAÇÃO INSTANTÂNEA COM A HITBOX 'BOTTOM'
local function CollectHitbox(hitbox: BasePart)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return end

    -- Teleporta exatamente sobre o Bottom
    root.Velocity = Vector3.zero
    root.CFrame = hitbox.CFrame + Vector3.new(0, 2, 0)

    -- Gatilho de toque nativo na placa de piso
    if firetouchinterest then
        firetouchinterest(root, hitbox, 0)
        task.wait(0.02)
        firetouchinterest(root, hitbox, 1)
    end
end

-- 4. RETORNO OTIMIZADO
local function ExecuteReturn()
    if SETTINGS.ReturnMode == "Remote" then
        task.spawn(function()
            pcall(function()
                TeleportHomeRemote:InvokeServer()
            end)
        end)
    else
        local baseCF = GetSafePlotCFrame()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if root and baseCF then
            root.Velocity = Vector3.zero
            root.CFrame = baseCF
        end
    end
end

-- 5. INTERFACE DO USUÁRIO
local ParentGui: Instance = CoreGui
pcall(function()
    if not pcall(function() return CoreGui.Name end) then
        ParentGui = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

if ParentGui:FindFirstChild("TexHubSoccer") then
    ParentGui.TexHubSoccer:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TexHubSoccer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 46, 0, 46)
FloatBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
FloatBtn.Text = "⚡"
FloatBtn.TextSize = 20
FloatBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 310)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundTransparency = 1
Title.Text = "TEXHUB - AUTO FARM OP"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 32)
StatusLabel.Position = UDim2.new(0, 10, 0, 42)
StatusLabel.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
StatusLabel.Text = "Status: Pronto (Hitbox: Bottom)"
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 10
StatusLabel.TextColor3 = Color3.fromRGB(200, 210, 230)
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

local function AddBtn(text: string, yPos: number, callback: () -> ())
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = MainFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local FarmBtn = AddBtn("AUTO-FARM: DESLIGADO", 84, function()
    SETTINGS.AutoFarm = not SETTINGS.AutoFarm
    FarmBtn.Text = SETTINGS.AutoFarm and "AUTO-FARM: ATIVO [RODANDO]" or "AUTO-FARM: DESLIGADO"
    FarmBtn.BackgroundColor3 = SETTINGS.AutoFarm and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(28, 33, 46)
end)

local ModeBtn = AddBtn("RETORNO: VIA REMOTE", 128, function()
    if SETTINGS.ReturnMode == "Remote" then
        SETTINGS.ReturnMode = "CFrame"
        ModeBtn.Text = "RETORNO: VIA CFRAME"
    else
        SETTINGS.ReturnMode = "Remote"
        ModeBtn.Text = "RETORNO: VIA REMOTE"
    end
end)

AddBtn("FORÇAR VOLTA PRA BASE", 172, function()
    ExecuteReturn()
    StatusLabel.Text = "Retorno executado."
end)

-- Sistema de Arrastar no Mobile
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

-- 6. LOOP DE FARM CALIBRADO
task.spawn(function()
    while true do
        if SETTINGS.AutoFarm then
            local cards = ActiveCardsFolder:GetChildren()
            local targetCard: Model? = nil
            local targetHitbox: BasePart? = nil
            local labelFound = ""

            for _, item in ipairs(cards) do
                if item:IsA("Model") then
                    local hitbox, nameText = ExtractCardInfo(item)
                    if hitbox then
                        targetCard = item
                        targetHitbox = hitbox
                        labelFound = nameText
                        break
                    end
                end
            end

            if targetHitbox and targetCard and targetCard:IsDescendantOf(Workspace) then
                StatusLabel.Text = "Coletando: " .. labelFound
                
                -- Teleporte e toque na peça 'Bottom'
                CollectHitbox(targetHitbox)
                task.wait(SETTINGS.CollectDelay)

                -- Retorno à base
                StatusLabel.Text = "Voltando à base..."
                ExecuteReturn()
                task.wait(SETTINGS.ReturnDelay)
            else
                StatusLabel.Text = "Varrendo cartas..."
            end
        end
        task.wait(0.1)
    end
end)
