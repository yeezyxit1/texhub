--!strict
-- ========================================================
-- [TEXHUB APEX v3 - CHOP TREES FOR TREASURE ELITE MODULE]
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer indisponível.")

-- Importação da Engine Visual TexHub Apex v3
local TexHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/yeezyxit1/texhub/main/UI.luau?t=" .. tostring(os.time())))()
local Hub = TexHub.CreateWindow("TEXHUB APEX", "+1 CHOP TREES")

Hub:Notify({
    Title = "TEXHUB INJETADO",
    Content = "Módulo Chop Trees v3 carregado com sucesso!",
    Duration = 3.5
})

-- REMOTES MAPEADOS NO DUMP
local ChopTreeHit = ReplicatedStorage:WaitForChild("ChopTreeHit") :: RemoteEvent
local LootTreasure = ReplicatedStorage:WaitForChild("LootTreasure") :: RemoteFunction
local SellTreasure = ReplicatedStorage:WaitForChild("SellTreasure") :: RemoteEvent
local TreasureDrop = ReplicatedStorage:FindFirstChild("TreasureDrop") :: RemoteEvent?

local RebirthFunc = ReplicatedStorage:FindFirstChild("RebirthFunc") :: RemoteFunction?
local DailyClaimFunc = ReplicatedStorage:FindFirstChild("DailyClaimFunc") :: RemoteFunction?
local GroupRewardClaim = ReplicatedStorage:FindFirstChild("GroupRewardClaim") :: RemoteFunction?
local SpinWheelFunc = ReplicatedStorage:FindFirstChild("SpinWheelFunc") :: RemoteFunction?

-- ESTADOS DE CONTROLO
local SETTINGS = {
    FastChop = false,
    AutoLoot = false,
    AutoSell = false,
    AutoRebirth = false,
    Noclip = false,
    SpeedHack = false,
    WalkSpeedValue = 110,
    ChopDelay = 0.05,
}

-- 1. LOCALIZADOR DA ÁRVORE MAIS PRÓXIMA
local function GetNearestTree(): Model?
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return nil end

    local closestTree: Model? = nil
    local minDistance = math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (string.find(string.lower(obj.Name), "tree") or obj:FindFirstChild("Wood") or obj:FindFirstChild("Trunk")) then
            local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if p then
                local dist = (root.Position - p.Position).Magnitude
                if dist < minDistance and dist < 45 then
                    minDistance = dist
                    closestTree = obj
                end
            end
        end
    end
    return closestTree
end

-- 2. ESCUTA EM TEMPO REAL DE DROPS DE TESOURO
if TreasureDrop then
    TreasureDrop.OnClientEvent:Connect(function(dropData: any, ...)
        if SETTINGS.AutoLoot then
            pcall(function()
                if typeof(dropData) == "Instance" then
                    LootTreasure:InvokeServer(dropData)
                elseif typeof(dropData) == "string" or typeof(dropData) == "number" then
                    LootTreasure:InvokeServer(dropData)
                else
                    LootTreasure:InvokeServer()
                end
            end)
        end
    end)
end

-- 3. INTERFACE APEX V3

-- ABA 1: AUTOMAÇÃO PRINCIPAL
local FarmTab = Hub:CreateTab("Automação", "⚡")

FarmTab:AddToggle("Fast Chop (Sem Animação)", "Dispara corte contínuo na velocidade máxima", false, function(active)
    SETTINGS.FastChop = active
    Hub:Notify({
        Title = "FAST CHOP",
        Content = active and "Corte acelerado ativo!" or "Corte desligado.",
        Duration = 2
    })
end)

FarmTab:AddToggle("Auto Loot (Coleta Tesouros)", "Puxa anéis, baús e relíquias do chão na hora", false, function(active)
    SETTINGS.AutoLoot = active
end)

FarmTab:AddToggle("Auto Sell (Venda Instantânea)", "Converte tesouros em moedas sem ir à loja", false, function(active)
    SETTINGS.AutoSell = active
end)

FarmTab:AddToggle("Auto Rebirth", "Renascimento automático ao atingir o requisito", false, function(active)
    SETTINGS.AutoRebirth = active
end)

FarmTab:AddButton("Vender Tesouros Agora", function()
    pcall(function() SellTreasure:FireServer() end)
    Hub:Notify({
        Title = "VENDA CONCLUÍDA",
        Content = "Todos os tesouros do inventário foram vendidos!",
        Duration = 2
    })
end)

-- ABA 2: RECOMPENSAS
local RewardsTab = Hub:CreateTab("Recompensas", "🎁")

RewardsTab:AddButton("Resgatar Recompensa Diária", function()
    pcall(function()
        if DailyClaimFunc then DailyClaimFunc:InvokeServer() end
    end)
    Hub:Notify({ Title = "RECOMPENSAS", Content = "Diário resgatado!", Duration = 2.5 })
end)

RewardsTab:AddButton("Resgatar Baú do Grupo", function()
    pcall(function()
        if GroupRewardClaim then GroupRewardClaim:InvokeServer() end
    end)
    Hub:Notify({ Title = "RECOMPENSAS", Content = "Prémio de grupo solicitado!", Duration = 2.5 })
end)

RewardsTab:AddButton("Girar Roleta Grátis", function()
    pcall(function()
        if SpinWheelFunc then SpinWheelFunc:InvokeServer() end
    end)
    Hub:Notify({ Title = "ROLETA", Content = "Giro requisitado!", Duration = 2.5 })
end)

-- ABA 3: JOGADOR
local PlayerTab = Hub:CreateTab("Jogador", "👤")

PlayerTab:AddToggle("Noclip Total", "Atravessa barreiras e árvores no caminho", false, function(active)
    SETTINGS.Noclip = active
end)

PlayerTab:AddSlider("Velocidade (WalkSpeed)", 16, 200, 110, function(val)
    SETTINGS.WalkSpeedValue = val
    SETTINGS.SpeedHack = true
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

-- 4. FÍSICA E MOVIMENTO (NOCLIP & VELOCIDADE)
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

-- 5. LOOPS DE EXECUÇÃO EM PARALELO
task.spawn(function()
    while true do
        if SETTINGS.FastChop then
            local targetTree = GetNearestTree()
            pcall(function()
                if targetTree then
                    ChopTreeHit:FireServer(targetTree)
                end
                ChopTreeHit:FireServer()
            end)
        end
        task.wait(SETTINGS.ChopDelay)
    end
end)

task.spawn(function()
    while true do
        if SETTINGS.AutoLoot then
            for _, item in ipairs(Workspace:GetChildren()) do
                if item:IsA("Model") and (string.find(string.lower(item.Name), "treasure") or string.find(string.lower(item.Name), "drop") or string.find(string.lower(item.Name), "ring")) then
                    pcall(function() LootTreasure:InvokeServer(item) end)
                end
            end
        end
        if SETTINGS.AutoSell then
            pcall(function() SellTreasure:FireServer() end)
        end
        if SETTINGS.AutoRebirth and RebirthFunc then
            pcall(function() RebirthFunc:InvokeServer() end)
        end
        task.wait(1.2)
    end
end)
