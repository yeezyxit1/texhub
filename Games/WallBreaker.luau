--!strict
-- ========================================================
-- [TEXHUB APEX v3.5 - WALL BREAKER & STRENGTH ELITE]
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer indisponível.")

-- Importação segura do Motor de Interface Apex v3.5
local uiSuccess, uiCode = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/yeezyxit1/texhub/main/UI.luau?t=" .. tostring(os.time()))
end)

if not uiSuccess or not uiCode or string.find(uiCode, "404") then
    warn("[TEXHUB] Erro ao obter UI.luau.")
    return
end

local loadFunc = loadstring(uiCode)
if not loadFunc then return end
local TexHub = loadFunc()

local Hub = TexHub.CreateWindow("TEXHUB APEX", "WALL BREAKER ELITE")

Hub:Notify({
    Title = "TEXHUB INJETADO",
    Content = "Módulo de Força e Quebra de Paredes pronto!",
    Duration = 3.5
})

-- REMOTES MAPEADOS DO DUMP
local ClickTrainEvent = ReplicatedStorage:WaitForChild("ClickTrainEvent") :: RemoteEvent
local BuyDumbbellEvent = ReplicatedStorage:WaitForChild("BuyDumbbellEvent") :: RemoteEvent
local StageCompleteEvent = ReplicatedStorage:WaitForChild("StageCompleteEvent") :: RemoteEvent
local SuperCollectorEvt = ReplicatedStorage:WaitForChild("SuperCollectorEvt") :: RemoteEvent
local EruptionHitEvent = ReplicatedStorage:WaitForChild("EruptionHitEvent") :: RemoteEvent
local OpenEggEvent = ReplicatedStorage:WaitForChild("OpenEggEvent") :: RemoteEvent

local PetFunction = ReplicatedStorage:FindFirstChild("PetFunction") :: RemoteFunction?
local DailyRewardFunction = ReplicatedStorage:FindFirstChild("DailyRewardFunction") :: RemoteFunction?
local QuestFunction = ReplicatedStorage:FindFirstChild("QuestFunction") :: RemoteFunction?

-- ESTADOS DE CONTROLO
local SETTINGS = {
    FastTrain = false,
    AutoBuyDumbbell = false,
    AutoStageClear = false,
    SuperCollector = false,
    AutoEruption = false,
    AutoHatch = false,
    SelectedEgg = "Egg1",
    TrainDelay = 0.03,
    Noclip = false,
    SpeedHack = false,
    WalkSpeedValue = 115,
}

-- 1. ABA DE FORÇA E AUTOMAÇÃO
local TrainTab = Hub:CreateTab("Treino & Farm", "⚡")

TrainTab:AddSection("Progressão de Força")

TrainTab:AddToggle("Fast Train (God Speed)", "Treina força continuamente no limite de pacotes", false, function(v)
    SETTINGS.FastTrain = v
end)

TrainTab:AddToggle("Auto Comprar Halteres", "Compra sempre o halter com maior multiplicador", false, function(v)
    SETTINGS.AutoBuyDumbbell = v
end)

TrainTab:AddToggle("Super Coletor (Sugar Itens)", "Absorve todas as gemas e moedas espalhadas", false, function(v)
    SETTINGS.SuperCollector = v
end)

TrainTab:AddSection("Conquista de Estágios")

TrainTab:AddToggle("Auto Quebrar Paredes", "Completa e limpa estágios de paredes automaticamente", false, function(v)
    SETTINGS.AutoStageClear = v
end)

TrainTab:AddButton("Completar Estágio Atual", function()
    pcall(function() StageCompleteEvent:FireServer() end)
    Hub:Notify({ Title = "PAREDE DESTRUÍDA", Content = "Pacote de conclusão enviado!", Duration = 2 })
end)

-- 2. ABA DE EVENTOS & BOSSES
local EventTab = Hub:CreateTab("Erupção & Boss", "🔥")

EventTab:AddSection("Evento da Erupção")

EventTab:AddToggle("Auto Farm Erupção", "Dispara ataques contínuos no evento vulcânico", false, function(v)
    SETTINGS.AutoEruption = v
end)

EventTab:AddButton("Disparar Super Golpe Erupção", function()
    pcall(function()
        for _ = 1, 10 do
            EruptionHitEvent:FireServer()
        end
    end)
    Hub:Notify({ Title = "ERUPÇÃO", Content = "Dano massivo aplicado!", Duration = 2 })
end)

-- 3. ABA DE OVOS & PETS
local PetTab = Hub:CreateTab("Pets & Ovos", "🐾")

PetTab:AddSection("Chocar Ovos")

PetTab:AddToggle("Auto Abrir Ovos", "Abre ovos sem animação na velocidade máxima", false, function(v)
    SETTINGS.AutoHatch = v
end)

PetTab:AddButton("Equipar Melhores Pets", function()
    pcall(function()
        if PetFunction then
            PetFunction:InvokeServer("EquipBest")
            PetFunction:InvokeServer("Best")
        end
    end)
    Hub:Notify({ Title = "PETS", Content = "Melhores pets equipados!", Duration = 2 })
end)

-- 4. ABA DE RECOMPENSAS
local RewardsTab = Hub:CreateTab("Recompensas", "🎁")

RewardsTab:AddButton("Resgatar Recompensa Diária", function()
    pcall(function()
        if DailyRewardFunction then DailyRewardFunction:InvokeServer() end
    end)
    Hub:Notify({ Title = "RECOMPENSA", Content = "Prémio diário resgatado!", Duration = 2 })
end)

RewardsTab:AddButton("Reivindicar Quests Concluídas", function()
    pcall(function()
        if QuestFunction then QuestFunction:InvokeServer("ClaimAll") end
    end)
    Hub:Notify({ Title = "MISSÕES", Content = "Recompensas de missões coletadas!", Duration = 2 })
end)

-- 5. ABA JOGADOR
local PlayerTab = Hub:CreateTab("Jogador", "👤")

PlayerTab:AddToggle("Noclip Total", "Atravessa barreiras e portas de estágios", false, function(v)
    SETTINGS.Noclip = v
end)

PlayerTab:AddSlider("Velocidade (WalkSpeed)", 16, 200, 115, function(val)
    SETTINGS.WalkSpeedValue = val
    SETTINGS.SpeedHack = true
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

-- 6. INTEGRAÇÃO TEXAI COPILOT
Hub:CreateAIAssistant("Você é o TexAI no Wall Breaker.", function(prompt)
    local lower = string.lower(prompt)
    if string.find(lower, "treinar") or string.find(lower, "força") then
        SETTINGS.FastTrain = true
        return "Fast Train ativado. O farm contínuo de força foi iniciado!"
    elseif string.find(lower, "parede") or string.find(lower, "estagio") or string.find(lower, "quebrar") then
        SETTINGS.AutoStageClear = true
        return "Auto quebra de paredes ligado. Avançando estágios!"
    elseif string.find(lower, "coletar") or string.find(lower, "moeda") or string.find(lower, "gema") then
        SETTINGS.SuperCollector = true
        return "Super Coletor ativo. Absorvendo recompensas do mapa!"
    elseif string.find(lower, "boss") or string.find(lower, "erupção") then
        SETTINGS.AutoEruption = true
        return "Auto dano na Erupção ativado com sucesso!"
    end
    return nil
end)

-- SISTEMA FÍSICO (NOCLIP & VELOCIDADE)
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

-- LOOPS DE PROCESSAMENTO EM PARALELO
task.spawn(function()
    while true do
        if SETTINGS.FastTrain then
            pcall(function() ClickTrainEvent:FireServer() end)
        end
        if SETTINGS.AutoEruption then
            pcall(function() EruptionHitEvent:FireServer() end)
        end
        task.wait(SETTINGS.TrainDelay)
    end
end)

task.spawn(function()
    while true do
        if SETTINGS.AutoBuyDumbbell then
            pcall(function() BuyDumbbellEvent:FireServer() end)
        end
        if SETTINGS.AutoStageClear then
            pcall(function() StageCompleteEvent:FireServer() end)
        end
        if SETTINGS.SuperCollector then
            pcall(function() SuperCollectorEvt:FireServer() end)
        end
        if SETTINGS.AutoHatch then
            pcall(function() OpenEggEvent:FireServer(SETTINGS.SelectedEgg, 1) end)
        end
        task.wait(0.5)
    end
end)
