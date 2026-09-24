--!strict
-- [TEXHUB - SKATE TO BRAINROTS: APEX GLOBAL ENGINE]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer indisponível.")

-- PRIORIDADE DE RARIDADE (DO MAIOR PRO MENOR)
local RARITY_TIERS: { [string]: number } = {
    ["OG"]        = 7,
    ["Celestial"] = 6,
    ["Divine"]    = 5,
    ["Secret"]    = 4,
    ["God"]       = 3,
    ["Mythic"]    = 2,
    ["Exclusive"] = 1,
}

local SETTINGS = {
    AutoCash = false,
    AutoRebirth = false,
    BrainrotSniper = false,
    GodmodeGuards = false,
    Noclip = false,
    SpeedHack = false,
    WalkSpeedValue = 130,
}

local Events = ReplicatedStorage:WaitForChild("Events")
local RequestSlotCashCollect = Events:WaitForChild("RequestSlotCashCollect") :: RemoteEvent
local RequestRebirth = Events:WaitForChild("RequestRebirth") :: RemoteEvent
local SafeZoneCheckout = Events:FindFirstChild("RequestSafeZoneCheckout") :: RemoteEvent?
local ZoneTeleport_Request = Events:FindFirstChild("ZoneTeleport_Request") :: RemoteEvent?

local ZoneTeleportFolder = Workspace:WaitForChild("ZoneTeleport")
local ZonesFolder = Workspace:FindFirstChild("Zones")
local SkateFolder = Workspace:FindFirstChild("Skate")
local GuardsFolder = Workspace:WaitForChild("Guards")

-- 1. BYPASS ANTI-CHEAT (SILENCIA DENÚNCIAS)
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

-- 2. DESCOBERTA DINÂMICA DA MAIOR ZONA NUMÉRICA
local function GetAbsoluteMaxZone(): (number, BasePart?)
    local maxZoneNum = 0
    local bestPart: BasePart? = nil

    -- Varre Workspace.Zones
    if ZonesFolder then
        for _, child in ipairs(ZonesFolder:GetChildren()) do
            local num = tonumber(string.match(child.Name, "%d+"))
            if num and num > maxZoneNum and child:IsA("BasePart") then
                maxZoneNum = num
                bestPart = child
            end
        end
    end

    -- Varre Workspace.ZoneTeleport
    for _, child in ipairs(ZoneTeleportFolder:GetChildren()) do
        local num = tonumber(string.match(child.Name, "%d+"))
        if num and num > maxZoneNum and child:IsA("BasePart") then
            maxZoneNum = num
            bestPart = child
        end
    end

    return maxZoneNum, bestPart
end

-- 3. TELEPORTE DE ALTA PRECISÃO
local function TeleportToPart(targetPart: BasePart)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return end

    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero
    root.CFrame = targetPart.CFrame + Vector3.new(0, 4, 0)

    if firetouchinterest then
        firetouchinterest(root, targetPart, 0)
        task.wait(0.02)
        firetouchinterest(root, targetPart, 1)
    end
end

-- 4. SNIPER: LOCALIZAÇÃO E CAPTURA DO BRAINROT MAIS RARO
local function GetBrainrotTierScore(modelName: string): number
    local brainrotsFolder = ReplicatedStorage:FindFirstChild("Brainrots")
    if not brainrotsFolder then return 0 end

    for tierName, score in pairs(RARITY_TIERS) do
        for _, category in ipairs({"Normal", "Golden", "Diamond"}) do
            local cat = brainrotsFolder:FindFirstChild(category)
            if cat then
                local tFolder = cat:FindFirstChild(tierName)
                if tFolder and tFolder:FindFirstChild(modelName) then
                    return score
                end
            end
        end
    end
    return 0
end

local function ExecuteBrainrotSnipe()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return end

    local highestScore = 0
    local targetPrompt: ProximityPrompt? = nil
    local targetPart: BasePart? = nil

    -- Procura no mapa por Prompts ativos em Brainrots valiosos
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("ProximityPrompt") and item.Enabled then
            local model = item:FindFirstAncestorOfClass("Model")
            if model then
                local score = GetBrainrotTierScore(model.Name)
                if score > highestScore then
                    highestScore = score
                    targetPrompt = item
                    targetPart = item.Parent :: BasePart?
                end
            end
        end
    end

    -- Se achou um Brainrot raro, teleporta e pega instantaneamente
    if targetPrompt and targetPart then
        root.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.05)
        if fireproximityprompt then
            fireproximityprompt(targetPrompt)
        end
        task.wait(0.1)

        -- Confirma entrega do item na SafeZone
        if SafeZoneCheckout then
            pcall(function() SafeZoneCheckout:FireServer() end)
        end
    end
end

-- 5. ANULAÇÃO DE GUARDAS E FÍSICA
local function NeutralizeGuards()
    for _, guard in ipairs(GuardsFolder:GetChildren()) do
        local hitbox = guard:FindFirstChild("Hitbox") :: BasePart?
        if hitbox then
            hitbox.CanTouch = false
            hitbox.CanCollide = false
            hitbox.Size = Vector3.new(0.001, 0.001, 0.001)
        end
    end
end

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

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and SETTINGS.SpeedHack then
        humanoid.WalkSpeed = SETTINGS.WalkSpeedValue
    end
end)

-- 6. INTERFACE TOUCH MOBILE
local ParentGui: Instance = CoreGui
pcall(function()
    if not pcall(function() return CoreGui.Name end) then
        ParentGui = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

if ParentGui:FindFirstChild("TexHubSkateOP") then
    ParentGui.TexHubSkateOP:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TexHubSkateOP"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 48, 0, 48)
FloatBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
FloatBtn.Text = "👑"
FloatBtn.TextSize = 22
FloatBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 430)
MainFrame.Position = UDim2.new(0.5, -145, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundTransparency = 1
Title.Text = "TEXHUB - SKATE APEX"
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

CreateToggle("AUTO CASH (SLOTS)", 40, function(v) SETTINGS.AutoCash = v end)
CreateToggle("AUTO REBIRTH (RANKING)", 74, function(v) SETTINGS.AutoRebirth = v end)
CreateToggle("BRAINROT SNIPER (AUTO FARM)", 108, function(v) SETTINGS.BrainrotSniper = v end)
CreateToggle("GODMODE GUARDAS", 142, function(v) SETTINGS.GodmodeGuards = v end)
CreateToggle("NOCLIP (ATRAVESSAR)", 176, function(v) SETTINGS.Noclip = v end)
CreateToggle("SPEED HACK (130)", 210, function(v) SETTINGS.SpeedHack = v end)

-- BOTÕES DE TELEPORTE AVANÇADO
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

CreateActionBtn("⚡ TP: MAIOR ZONA ENCONTRADA", 248, Color3.fromRGB(0, 130, 220), function()
    local maxNum, targetPart = GetAbsoluteMaxZone()
    if targetPart then
        TeleportToPart(targetPart)
        if ZoneTeleport_Request then
            pcall(function() ZoneTeleport_Request:FireServer(maxNum) end)
        end
    end
end)

CreateActionBtn("🛹 TP: SKATE ZONE OG (ÁREA SECRETA)", 282, Color3.fromRGB(160, 40, 200), function()
    if SkateFolder then
        local ogPart = (SkateFolder:FindFirstChild("SkateZoneOGUpper") or SkateFolder:FindFirstChild("SkateZoneOG")) :: BasePart?
        if ogPart then
            TeleportToPart(ogPart)
        end
    end
end)

CreateActionBtn("🏠 TP: SPAWN / BASE", 316, Color3.fromRGB(180, 40, 40), function()
    local spawnPad = ZoneTeleportFolder:FindFirstChild("SpawnTeleport") :: BasePart?
    if spawnPad then
        TeleportToPart(spawnPad)
    end
end)

-- Sistema Draggable Mobile
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

-- 7. LOOPS ASSÍNCRONOS
task.spawn(function()
    while true do
        if SETTINGS.AutoCash then
            pcall(function() RequestSlotCashCollect:FireServer() end)
        end
        if SETTINGS.AutoRebirth then
            pcall(function() RequestRebirth:FireServer() end)
        end
        task.wait(0.12)
    end
end)

task.spawn(function()
    while true do
        if SETTINGS.GodmodeGuards then
            NeutralizeGuards()
        end
        if SETTINGS.BrainrotSniper then
            ExecuteBrainrotSnipe()
        end
        task.wait(0.35)
    end
end)
