-- ============================================================================
-- [TEXHUB APEX - POWER SIMULATOR ELITE AUTOMATION]
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 1. IMPORTAÇÃO DO MOTOR GRÁFICO TEXHUB NATIVO
local TexHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/yeezyxit1/texhub/main/UI.luau?t=" .. tostring(os.time())))()

local Window = TexHub:CreateWindow({
    Title = "TEXHUB APEX <font color='#00FFAA'>[Power Sim]</font>"
})

-- 2. RESOLUÇÃO DOS REMOTES DO JOGO
local PowerFolder   = ReplicatedStorage:WaitForChild("PowerRemotes", 5)
local RewardFolder  = ReplicatedStorage:WaitForChild("RewardRemotes", 5)
local RebirthFolder = ReplicatedStorage:WaitForChild("RebirthRemotes", 5)
local WorldFolder   = ReplicatedStorage:WaitForChild("WorldRemotes", 5)

local ClickPower    = PowerFolder and PowerFolder:WaitForChild("ClickPower", 5)
local DoRebirth     = RebirthFolder and RebirthFolder:WaitForChild("DoRebirth", 5)
local Reincarnate   = WorldFolder and WorldFolder:WaitForChild("Reincarnate", 5)

local ClaimDaily    = RewardFolder and RewardFolder:WaitForChild("ClaimDaily", 5)
local ClaimPlayTime = RewardFolder and RewardFolder:WaitForChild("ClaimPlayTime", 5)
local ClaimFreeGift = RewardFolder and RewardFolder:WaitForChild("ClaimFreeGift", 5)

-- 3. ESTADOS DE CONTROLO
local States = {
    AutoClick = false,
    AutoRebirth = false,
    AutoReincarnate = false,
    AutoRewards = false,
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

TabFarm:AddToggle("Auto Click Power (Poder Rápido)", false, function(active)
    States.AutoClick = active
    if active then
        task.spawn(function()
            while States.AutoClick do
                pcall(function()
                    if ClickPower then
                        ClickPower:FireServer()
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
                    if DoRebirth then
                        DoRebirth:FireServer()
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

TabFarm:AddToggle("Auto Reincarnate (Novo Mundo)", false, function(active)
    States.AutoReincarnate = active
    if active then
        task.spawn(function()
            while States.AutoReincarnate do
                pcall(function()
                    if Reincarnate then
                        Reincarnate:FireServer()
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

-- ============================================================================
-- ABA 2: RECOMPENSAS
-- ============================================================================

local function collectAllRewards()
    pcall(function()
        if ClaimDaily then
            ClaimDaily:FireServer()
        end
        if ClaimFreeGift then
            for i = 1, 12 do
                ClaimFreeGift:FireServer(i)
            end
        end
        if ClaimPlayTime then
            for i = 1, 12 do
                ClaimPlayTime:FireServer(i)
            end
        end
    end)
end

TabRewards:AddButton("Resgatar Todos os Presentes Agora", function()
    collectAllRewards()
end)

TabRewards:AddToggle("Auto Coletar Recompensas & Tempo", false, function(active)
    States.AutoRewards = active
    if active then
        task.spawn(function()
            while States.AutoRewards do
                collectAllRewards()
                task.wait(10)
            end
        end)
    end
end)

-- ============================================================================
-- ABA 3: JOGADOR (VELOCIDADE, PULO, NOCLIP)
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

TabSettings:AddButton("Anti-Lag (Modo Fluido)", function()
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
