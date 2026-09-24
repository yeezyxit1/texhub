-- ============================================================================
-- [TEXHUB APEX - +1 SKINNY PER STEP ELITE AUTOMATION]
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 1. IMPORTAÇÃO DO MOTOR GRÁFICO TEXHUB
local TexHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/yeezyxit1/texhub/main/UI.luau?t=" .. tostring(os.time())))()

local Window = TexHub:CreateWindow({
    Title = "TEXHUB APEX <font color='#00FFAA'>[+1 Skinny]</font>"
})

-- 2. RESOLUÇÃO DOS REMOTES DO JOGO
local ThinLevelUp       = ReplicatedStorage:WaitForChild("ThinLevelUp", 5)
local RebirthRequest    = ReplicatedStorage:WaitForChild("RebirthRequest", 5)
local WinAwarded        = ReplicatedStorage:WaitForChild("WinAwarded", 5)
local DailyClaimRequest = ReplicatedStorage:WaitForChild("DailyClaimRequest", 5)
local GiftClaimRequest  = ReplicatedStorage:WaitForChild("GiftClaimRequest", 5)
local SpecialGiftClaim  = ReplicatedStorage:WaitForChild("SpecialGiftClaim", 5)
local GroupRewardClaim  = ReplicatedStorage:WaitForChild("GroupRewardClaim", 5)

local PetsFolder        = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Pets")
local EquipBest         = PetsFolder and PetsFolder:FindFirstChild("EquipBest")

-- 3. ESTADOS DE CONTROLO
local States = {
    AutoSkinny = false,
    AutoRebirth = false,
    AutoWins = false,
    AutoGifts = false,
    InfJump = false,
    Noclip = false
}

-- 4. CONSTRUÇÃO DAS ABAS
local TabFarm     = Window:CreateTab("Auto Farm")
local TabRewards  = Window:CreateTab("Recompensas")
local TabPlayer   = Window:CreateTab("Jogador")
local TabSettings = Window:CreateTab("Ajustes")

-- ============================================================================
-- ABA 1: AUTO FARM
-- ============================================================================

TabFarm:AddToggle("Auto Skinny (+Passos Rápido)", false, function(active)
    States.AutoSkinny = active
    if active then
        task.spawn(function()
            while States.AutoSkinny do
                pcall(function()
                    if ThinLevelUp then
                        ThinLevelUp:FireServer()
                    end
                end)
                task.wait(0.05)
            end
        end)
    end
end)

TabFarm:AddToggle("Auto Rebirth (Renascimento)", false, function(active)
    States.AutoRebirth = active
    if active then
        task.spawn(function()
            while States.AutoRebirth do
                pcall(function()
                    if RebirthRequest then
                        RebirthRequest:FireServer()
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

TabFarm:AddToggle("Auto Vitória (Farm Wins)", false, function(active)
    States.AutoWins = active
    if active then
        task.spawn(function()
            while States.AutoWins do
                pcall(function()
                    if WinAwarded then
                        WinAwarded:FireServer()
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

TabFarm:AddButton("Equipar Melhores Pets", function()
    pcall(function()
        if EquipBest then
            EquipBest:FireServer()
        end
    end)
end)

-- ============================================================================
-- ABA 2: RECOMPENSAS AUTOMÁTICAS
-- ============================================================================

local function claimAllRewards()
    pcall(function()
        if DailyClaimRequest then DailyClaimRequest:FireServer() end
        if GroupRewardClaim then GroupRewardClaim:FireServer() end
        if SpecialGiftClaim then SpecialGiftClaim:FireServer() end
        if GiftClaimRequest then
            for i = 1, 12 do
                GiftClaimRequest:FireServer(i)
            end
        end
    end)
end

TabRewards:AddButton("Resgatar Todos os Presentes Agora", function()
    claimAllRewards()
end)

TabRewards:AddToggle("Auto Coletar Presentes & Diários", false, function(active)
    States.AutoGifts = active
    if active then
        task.spawn(function()
            while States.AutoGifts do
                claimAllRewards()
                task.wait(10)
            end
        end)
    end
end)

-- ============================================================================
-- ABA 3: JOGADOR (VELOCIDADE, SALTO E NOCLIP)
-- ============================================================================

TabPlayer:AddSlider("Velocidade", 16, 250, 16, function(value)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = value
    end
end)

TabPlayer:AddSlider("Força do Salto", 50, 300, 50, function(value)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = value
    end
end)

TabPlayer:AddToggle("Pulo Infinito", false, function(active)
    States.InfJump = active
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

-- ============================================================================
-- ABA 4: AJUSTES & PERFORMANCE
-- ============================================================================

TabSettings:AddButton("Otimizar Gráficos (Anti-Lag Mobile)", function()
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
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
