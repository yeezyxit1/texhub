-- ============================================================================
-- [TEXHUB APEX v6.0 - ORCHARD TYCOON ELITE ALL-IN-ONE MASTER]
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 1. IMPORTAÇÃO DO MOTOR GRÁFICO TEXHUB NATIVO
local TexHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/yeezyxit1/texhub/main/UI.luau?t=" .. tostring(os.time())))()

local Window = TexHub:CreateWindow({
    Title = "TEXHUB APEX <font color='#00FFAA'>[Orchard Tycoon]</font>"
})

-- 2. BUSCA ROBUSTA DOS REMOTES DO JOGO
local function findRemote(name)
    local obj = ReplicatedStorage:FindFirstChild(name, true)
    if not obj then
        local parts = string.split(name, ".")
        obj = ReplicatedStorage:FindFirstChild(parts[#parts], true)
    end
    return obj
end

-- Remotes de Colheita e Pomar
local ClickFruit   = findRemote("ClickFruitService.Clicked") or findRemote("Clicked")
local PlantFruit   = findRemote("OrchardPlot.Plant")
local HarvestFruit = findRemote("OrchardPlot.Harvest")
local GetFruit     = findRemote("OrchardPlot.GetFruit")
local SellUpgrade  = findRemote("OrchardPlot.SellUpgrade")
local UseItem      = findRemote("OrchardPlot.UseItem")

-- Remotes de Minijogos e Drops
local RaceStart    = findRemote("MinigameRaceService.Start")
local RaceEnd      = findRemote("MinigameRaceService.End")
local TradeStart   = findRemote("MinigameTradeService.Start")
local TradeEnd     = findRemote("MinigameTradeService.End")
local RedeemDrop   = findRemote("DropService.Redeem")
local LightningHit = findRemote("LightningHit")

-- 3. ESTADOS DE CONTROLO
local States = {
    AutoClickFruit = false,
    ClickDelay = 0.05,
    AutoHarvest = false,
    AutoGetFruit = false,
    AutoPlant = false,
    AutoUpgrades = false,
    AutoRace = false,
    AutoDrops = false,
    AutoLightning = false,
    InfJump = false,
    Noclip = false,
    Fullbright = false,
    AntiAFK = true
}

-- 4. PROTEÇÃO ANTI-AFK
LocalPlayer.Idled:Connect(function()
    if States.AntiAFK then
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- 5. CRIAÇÃO DAS ABAS
local TabFarm      = Window:CreateTab("Auto Pomar")
local TabMinigames = Window:CreateTab("Minijogos")
local TabPlayer    = Window:CreateTab("Jogador")
local TabTeleports = Window:CreateTab("Teleportes")
local TabSettings  = Window:CreateTab("Ajustes & FPS")

-- ============================================================================
-- ABA 1: AUTO POMAR (CLIQUE, COLHEITA E PLANTIO)
-- ============================================================================

TabFarm:AddToggle("Auto Clicar em Frutas", false, function(active)
    States.AutoClickFruit = active
    if active then
        task.spawn(function()
            while States.AutoClickFruit do
                pcall(function()
                    if ClickFruit then
                        ClickFruit:FireServer()
                    end
                end)
                task.wait(States.ClickDelay)
            end
        end)
    end
end)

TabFarm:AddSlider("Velocidade do Clique (ms)", 1, 100, 50, function(val)
    States.ClickDelay = val / 1000
end)

TabFarm:AddToggle("Auto Colher Árvores (Harvest)", false, function(active)
    States.AutoHarvest = active
    if active then
        task.spawn(function()
            while States.AutoHarvest do
                pcall(function()
                    if HarvestFruit then
                        HarvestFruit:InvokeServer()
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

TabFarm:AddToggle("Auto Coletar Frutas Soltas", false, function(active)
    States.AutoGetFruit = active
    if active then
        task.spawn(function()
            while States.AutoGetFruit do
                pcall(function()
                    if GetFruit then
                        GetFruit:InvokeServer()
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

TabFarm:AddToggle("Auto Replantar Árvores", false, function(active)
    States.AutoPlant = active
    if active then
        task.spawn(function()
            while States.AutoPlant do
                pcall(function()
                    if PlantFruit then
                        PlantFruit:InvokeServer()
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

TabFarm:AddToggle("Auto Comprar Upgrades do Lote", false, function(active)
    States.AutoUpgrades = active
    if active then
        task.spawn(function()
            while States.AutoUpgrades do
                pcall(function()
                    if SellUpgrade then
                        SellUpgrade:InvokeServer()
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

TabFarm:AddButton("Colher Tudo Agora", function()
    pcall(function()
        if HarvestFruit then HarvestFruit:InvokeServer() end
        if GetFruit then GetFruit:InvokeServer() end
    end)
end)

-- ============================================================================
-- ABA 2: MINIJOGOS, DROPS & RAIOS
-- ============================================================================

TabMinigames:AddToggle("Auto Completar Corrida (Race)", false, function(active)
    States.AutoRace = active
    if active then
        task.spawn(function()
            while States.AutoRace do
                pcall(function()
                    if RaceStart then RaceStart:InvokeServer() end
                    task.wait(0.2)
                    if RaceEnd then RaceEnd:InvokeServer(true) end
                end)
                task.wait(3)
            end
        end)
    end
end)

TabMinigames:AddToggle("Auto Resgatar Recompensas Drop", false, function(active)
    States.AutoDrops = active
    if active then
        task.spawn(function()
            while States.AutoDrops do
                pcall(function()
                    if RedeemDrop then
                        RedeemDrop:InvokeServer()
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

TabMinigames:AddToggle("Auto Absorver Raios (Lightning)", false, function(active)
    States.AutoLightning = active
    if active then
        task.spawn(function()
            while States.AutoLightning do
                pcall(function()
                    if LightningHit then
                        LightningHit:InvokeServer()
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

TabMinigames:AddButton("Finalizar Minijogo de Troca", function()
    pcall(function()
        if TradeStart then TradeStart:InvokeServer() end
        task.wait(0.1)
        if TradeEnd then TradeEnd:InvokeServer(true) end
    end)
end)

-- ============================================================================
-- ABA 3: JOGADOR (FÍSICA & MOVIMENTO)
-- ============================================================================

TabPlayer:AddSlider("Velocidade", 16, 250, 16, function(val)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

TabPlayer:AddSlider("Força do Salto", 50, 300, 50, function(val)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = val end
end)

TabPlayer:AddSlider("Campo de Visão (FOV)", 70, 120, 70, function(val)
    workspace.CurrentCamera.FieldOfView = val
end)

TabPlayer:AddToggle("Pulo Infinito", false, function(active)
    States.InfJump = active
end)

UserInputService.JumpRequest:Connect(function()
    if States.InfJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

TabPlayer:AddToggle("Atravessar Paredes (Noclip)", false, function(active)
    States.Noclip = active
end)

RunService.Stepped:Connect(function()
    if States.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

TabPlayer:AddToggle("Proteção Anti-AFK", true, function(active)
    States.AntiAFK = active
end)

-- ============================================================================
-- ABA 4: TELEPORTES DO MAPA
-- ============================================================================

TabTeleports:AddButton("Teleportar para Meu Lote/Tycoon", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local plots = workspace:FindFirstChild("OrchardPlots") or workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Tycoons")
    if hrp and plots then
        for _, p in ipairs(plots:GetChildren()) do
            local owner = p:FindFirstChild("Owner")
            if owner and owner.Value == LocalPlayer then
                hrp.CFrame = p:GetPivot() + Vector3.new(0, 5, 0)
                return
            end
        end
        local first = plots:GetChildren()[1]
        if first then hrp.CFrame = first:GetPivot() + Vector3.new(0, 5, 0) end
    end
end)

TabTeleports:AddButton("Teleportar para o Spawn Central", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local spawnObj = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("Spawns")
    if hrp and spawnObj then
        hrp.CFrame = spawnObj:IsA("BasePart") and spawnObj.CFrame + Vector3.new(0, 4, 0) or spawnObj:GetChildren()[1].CFrame + Vector3.new(0, 4, 0)
    end
end)

-- ============================================================================
-- ABA 5: VISUAL, FPS & SISTEMA
-- ============================================================================

TabSettings:AddToggle("Iluminação Total (Fullbright)", false, function(active)
    States.Fullbright = active
    if active then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

TabSettings:AddButton("Otimizar Gráficos (Anti-Lag Mobile)", function()
    pcall(function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            end
        end
    end)
end)

TabSettings:AddButton("Reentrar no Servidor (Rejoin)", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
