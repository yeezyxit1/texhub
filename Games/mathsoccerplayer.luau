--!strict
-- [TEXHUB - MATH SOCCER MODULE]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer não encontrado.")

local SETTINGS = {
    AutoFarm = false,
    ReturnMode = "Remote",
    CollectDelay = 0.4,
    StepDistance = 2.5,
}

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local TeleportHomeRemote = EventsFolder:WaitForChild("TeleportHome") :: RemoteFunction
local ActiveCardsFolder = Workspace:WaitForChild("ActiveCards") :: Folder
local PlayerPlotName = "Plot_" .. LocalPlayer.Name

local function GetSafePlotPosition(): Vector3?
    local plot = Workspace:FindFirstChild(PlayerPlotName)
    if not plot then return nil end

    local floor1 = plot:FindFirstChild("Floor1")
    if floor1 and floor1:IsA("Model") then
        local cf, size = floor1:GetBoundingBox()
        return cf.Position + Vector3.new(0, (size.Y / 2) + 3.5, 0)
    end

    if plot:IsA("Model") then
        local cf, size = plot:GetBoundingBox()
        return cf.Position + Vector3.new(0, 4, 0)
    end
    return nil
end

local function InteractWithCard(card: Model)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    for _, item in ipairs(card:GetDescendants()) do
        if item:IsA("ProximityPrompt") and fireproximityprompt then
            fireproximityprompt(item)
        end
    end

    for _, item in ipairs(card:GetDescendants()) do
        if item:IsA("BasePart") and firetouchinterest then
            firetouchinterest(root, item, 0)
            task.wait(0.02)
            firetouchinterest(root, item, 1)
        end
    end

    local forwardPos = root.Position + (root.CFrame.LookVector * SETTINGS.StepDistance)
    humanoid:MoveTo(forwardPos)
end

local function ExecuteReturn(statusLabel: TextLabel)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return end

    if SETTINGS.ReturnMode == "Remote" then
        statusLabel.Text = "Voltando: Via Remote..."
        pcall(function()
            TeleportHomeRemote:InvokeServer()
        end)
    else
        statusLabel.Text = "Voltando: Via CFrame..."
        local safePos = GetSafePlotPosition()
        if safePos then
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
            root.CFrame = CFrame.new(safePos)
        else
            statusLabel.Text = "Erro: Base não localizada!"
        end
    end
end

-- Interface
local ParentGui: Instance = CoreGui
pcall(function()
    if not pcall(function() return CoreGui.Name end) then
        ParentGui = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

if ParentGui:FindFirstChild("SoccerHubV3") then
    ParentGui.SoccerHubV3:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SoccerHubV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 48, 0, 48)
FloatBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
FloatBtn.Text = "⚽"
FloatBtn.TextSize = 22
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 370)
MainFrame.Position = UDim2.new(0.5, -145, 0.5, -185)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "TEXHUB - MATH SOCCER"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 36)
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.BackgroundColor3 = Color3.fromRGB(26, 30, 40)
StatusLabel.Text = "Status: Pronto"
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.TextColor3 = Color3.fromRGB(200, 205, 220)
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

local function CreateButton(name: string, yPos: number, callback: () -> ())
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(32, 38, 52)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = MainFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local FarmBtn = CreateButton("AUTO-FARM: DESLIGADO", 90, function()
    SETTINGS.AutoFarm = not SETTINGS.AutoFarm
    FarmBtn.Text = SETTINGS.AutoFarm and "AUTO-FARM: LIGADO" or "AUTO-FARM: DESLIGADO"
    FarmBtn.BackgroundColor3 = SETTINGS.AutoFarm and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(32, 38, 52)
end)

local ModeBtn = CreateButton("RETORNO: VIA REMOTE", 134, function()
    if SETTINGS.ReturnMode == "Remote" then
        SETTINGS.ReturnMode = "CFrame"
        ModeBtn.Text = "RETORNO: VIA CFRAME"
    else
        SETTINGS.ReturnMode = "Remote"
        ModeBtn.Text = "RETORNO: VIA REMOTE"
    end
end)

CreateButton("TESTAR VOLTA PRA BASE", 178, function()
    ExecuteReturn(StatusLabel)
end)

CreateButton("🔍 INSPECIONAR CARTA", 222, function()
    local firstCard = ActiveCardsFolder:FindFirstChildWhichIsA("Model")
    if firstCard then
        local details = {}
        for _, child in ipairs(firstCard:GetChildren()) do
            table.insert(details, string.format("%s [%s]", child.Name, child.ClassName))
        end
        local msg = string.format("Carta: %s | Filhos: %s", firstCard.Name, table.concat(details, ", "))
        StatusLabel.Text = "Copiado para a área de transferência!"
        local clipFunc = (setclipboard or toclipboard or (Clipboard and Clipboard.set))
        if clipFunc then clipFunc(msg) end
    else
        StatusLabel.Text = "Nenhuma carta ativa!"
    end
end)

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

task.spawn(function()
    while true do
        if SETTINGS.AutoFarm then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
            
            if root then
                local targetCard: Model? = nil
                for _, card in ipairs(ActiveCardsFolder:GetChildren()) do
                    if card:IsA("Model") and (card.PrimaryPart or card:FindFirstChildWhichIsA("BasePart")) then
                        targetCard = card
                        break
                    end
                end

                if targetCard then
                    local targetPart = targetCard.PrimaryPart or targetCard:FindFirstChildWhichIsA("BasePart")
                    if targetPart then
                        StatusLabel.Text = "Apanhando: " .. targetCard.Name
                        root.Velocity = Vector3.zero
                        root.CFrame = targetPart.CFrame + Vector3.new(0, 2.5, 0)
                        
                        InteractWithCard(targetCard)
                        task.wait(SETTINGS.CollectDelay)

                        ExecuteReturn(StatusLabel)
                        task.wait(0.6)
                    end
                else
                    StatusLabel.Text = "Sem cartas ativas..."
                end
            end
        end
        task.wait(0.3)
    end
end)
