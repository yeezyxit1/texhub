--!strict
-- [TEXHUB - DRILL BLOCKS FOR DUMPLING SQUISHY: ELITE APEX]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer indisponível.")

-- ========================================================
-- TABELA DE PRIORIDADE DAS ZONAS (SQUISHIES MAIS VALIOSOS)
-- ========================================================
local ZONE_PRIORITIES = {
    "Quantum Zone",
    "Void Zone",
    "Secret Zone",
    "Omega Zone",
    "Candy Zone",
    "Eternal Zone",
    "Divine Zone",
    "Meteor Zone",
    "Toxic Zone",
    "Exclusive Zone",
    "Mythical Zone",
    "Rare Zone",
}

local SETTINGS = {
    AutoFarmSquishies = false,
    AutoSell = false,
    AutoClearObstacles = false,
    Noclip = false,
    SpeedHack = false,
    WalkSpeedValue = 120,
}

local StandsFolder = Workspace:WaitForChild("Stands")
local SellStand = StandsFolder:WaitForChild("Sell")
local SellOpenZone = SellStand:WaitForChild("OpenZone") :: BasePart

local AnimalsFolder = Workspace:WaitForChild("Animals")
local ObstaclesFolder = Workspace:WaitForChild("Obstacles")
local GroupReward = Workspace:FindFirstChild("GroupReward")
local FollowBoard = Workspace:FindFirstChild("FollowEventBoard")

-- 1. VENDA AUTOMÁTICA INSTANTÂNEA
local function ExecuteInstantSell()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root or not SellOpenZone then return end

    if firetouchinterest then
        firetouchinterest(root, SellOpenZone, 0)
        task.wait(0.02)
        firetouchinterest(root, SellOpenZone, 1)
    end
end

-- 2. SNIPER DE DUMPLING SQUISHIES (ZONAS MÁXIMAS PRIMEIRO)
local function CollectBestSquishy()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return end

    for _, zoneName in ipairs(ZONE_PRIORITIES) do
        local zoneFolder = AnimalsFolder:FindFirstChild(zoneName)
        if zoneFolder then
            local targets = zoneFolder:GetChildren()
            if #targets > 0 then
                for _, model in ipairs(targets) do
                    if model:IsA("Model") then
                        local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                        if targetPart then
                            root.Velocity = Vector3.zero
                            root.CFrame = targetPart.CFrame + Vector3.new(0, 1.5, 0)

                            -- Coleta por ProximityPrompt ou Toque
                            for _, desc in ipairs(model:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") and fireproximityprompt then
                                    fireproximityprompt(desc)
                                end
                                if desc:IsA("BasePart") and firetouchinterest then
                                    firetouchinterest(root, desc, 0)
                                    task.wait(0.01)
                                    firetouchinterest(root, desc, 1)
                                end
                            end
                            return
                        end
                    end
                end
            end
        end
    end
end

-- 3. PERCORRER TODOS OS OBSTÁCULOS (1 A 27)
local function ClearAllObstacles()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return end

    for i = 1, 27 do
        local obs = ObstaclesFolder:FindFirstChild("Obstacle_" .. tostring(i))
        if obs then
            local part = obs:FindFirstChild("StartPart") or obs:FindFirstChild("Grass") or obs:FindFirstChild("Dirt")
            if part and part:IsA("BasePart") then
                root.Velocity = Vector3.zero
                root.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                if firetouchinterest then
                    firetouchinterest(root, part, 0)
                    task.wait(0.01)
                    firetouchinterest(root, part, 1)
                end
                task.wait(0.08)
            end
        end
    end
end

-- 4. RECOMPENSAS GRÁTIS
local function ClaimAllFreeRewards()
    if GroupReward and fireproximityprompt then
        local prompt = GroupReward:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then fireproximityprompt(prompt) end
    end
    if FollowBoard and fireproximityprompt then
        local prompt = FollowBoard:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then fireproximityprompt(prompt) end
    end
end

-- 5. NOCLIP E VELOCIDADE
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    if SETTINGS.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and SETTINGS.SpeedHack then
        hum.WalkSpeed = SETTINGS.WalkSpeedValue
    end
end)

-- 6. INTERFACE TOUCH MOBILE
local ParentGui: Instance = CoreGui
pcall(function()
    if not pcall(function() return CoreGui.Name end) then
        ParentGui = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

if ParentGui:FindFirstChild("TexHubDrill") then
    ParentGui.TexHubDrill:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TexHubDrill"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 48, 0, 48)
FloatBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
FloatBtn.Text = "🥟"
FloatBtn.TextSize = 22
FloatBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 410)
MainFrame.Position = UDim2.new(0.5, -145, 0.5, -205)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundTransparency = 1
Title.Text = "TEXHUB - DUMPLING APEX"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 12
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.Parent = MainFrame

local function CreateToggle(name: string, yPos: number, callback: (boolean) -> ())
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
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

CreateToggle("SNIPER SQUISHIES (AUTO FARM)", 40, function(v) SETTINGS.AutoFarmSquishies = v end)
CreateToggle("AUTO SELL (INSTANTÂNEO)", 74, function(v) SETTINGS.AutoSell = v end)
CreateToggle("CLEAR OBSTÁCULOS (1 A 27)", 108, function(v) SETTINGS.AutoClearObstacles = v end)
CreateToggle("NOCLIP (ATRAVESSA TUDO)", 142, function(v) SETTINGS.Noclip = v end)
CreateToggle("SUPER SPEED (120)", 176, function(v) SETTINGS.SpeedHack = v end)

local function CreateActionBtn(text: string, yPos: number, color: Color3, callback: () -> ())
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = MainFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

CreateActionBtn("⚡ TP: QUANTUM ZONE (ÁREA MÁXIMA)", 214, Color3.fromRGB(160, 40, 220), function()
    local qz = AnimalsFolder:FindFirstChild("Quantum Zone")
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if qz and root then
        local first = qz:FindFirstChildWhichIsA("Model")
        local p = first and (first.PrimaryPart or first:FindFirstChildWhichIsA("BasePart"))
        if p then root.CFrame = p.CFrame + Vector3.new(0, 3, 0) end
    end
end)

CreateActionBtn("💰 TP: STAND DE VENDA (SELL)", 248, Color3.fromRGB(0, 140, 220), function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if root and SellOpenZone then
        root.CFrame = SellOpenZone.CFrame + Vector3.new(0, 3, 0)
    end
end)

CreateActionBtn("🎁 RESGATAR RECOMPENSAS GRÁTIS", 282, Color3.fromRGB(220, 120, 0), function()
    ClaimAllFreeRewards()
end)

-- Sistema Draggable
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

-- 7. LOOPS EM PARALELO
task.spawn(function()
    while true do
        if SETTINGS.AutoFarmSquishies then
            CollectBestSquishy()
        end
        task.wait(0.2)
    end
end)

task.spawn(function()
    while true do
        if SETTINGS.AutoSell then
            ExecuteInstantSell()
        end
        task.wait(1.5)
    end
end)

task.spawn(function()
    while true do
        if SETTINGS.AutoClearObstacles then
            ClearAllObstacles()
        end
        task.wait(2.5)
    end
end)
