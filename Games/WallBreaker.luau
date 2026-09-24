--!strict
-- ========================================================
-- [TEXHUB APEX v3.5 - WALL BREAKER ELITE FAST-LOAD]
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer indisponível.")

-- Importação da UI sem cache
local uiSuccess, uiLib = pcall(function()
    local url = "https://raw.githubusercontent.com/yeezyxit1/texhub/main/UI.luau?t=" .. tostring(os.time())
    return loadstring(game:HttpGet(url))()
end)

if not uiSuccess or not uiLib then
    warn("Falha ao carregar TexHub UI: " .. tostring(uiLib))
    return
end

local TexHub = uiLib

-- Criação da Janela
local Window = TexHub:CreateWindow({
    Title = "TexHub | Wall Breaker",
    SubTitle = "Mobile Edition",
    Size = UDim2.new(0, 320, 0, 240)
})

local Tab = Window:CreateTab("Principal")


if not uiSuccess or not uiCode or string.find(uiCode, "404") then return end
local loadFunc = loadstring(uiCode)
if not loadFunc then return end
local TexHub = loadFunc()

local Hub = TexHub.CreateWindow("TEXHUB APEX", "WALL BREAKER ELITE")

Hub:Notify({
    Title = "TEXHUB INJETADO",
    Content = "Menu carregado com sucesso!",
    Duration = 3.5
})

-- REMOTES COM TIMEOUT SEGURO (NÃO TRAVA NO TUTORIAL)
local ClickTrainEvent = ReplicatedStorage:WaitForChild("ClickTrainEvent", 5) :: RemoteEvent?
local BuyDumbbellEvent = ReplicatedStorage:WaitForChild("BuyDumbbellEvent", 5) :: RemoteEvent?
local StageCompleteEvent = ReplicatedStorage:WaitForChild("StageCompleteEvent", 5) :: RemoteEvent?
local SuperCollectorEvt = ReplicatedStorage:WaitForChild("SuperCollectorEvt", 5) :: RemoteEvent?
local EruptionHitEvent = ReplicatedStorage:WaitForChild("EruptionHitEvent", 5) :: RemoteEvent?
local OpenEggEvent = ReplicatedStorage:WaitForChild("OpenEggEvent", 5) :: RemoteEvent?

local PetFunction = ReplicatedStorage:FindFirstChild("PetFunction") :: RemoteFunction?
local DailyRewardFunction = ReplicatedStorage:FindFirstChild("DailyRewardFunction") :: RemoteFunction?
local QuestFunction = ReplicatedStorage:FindFirstChild("QuestFunction") :: RemoteFunction?

-- ESTADOS
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

-- ABA 1: TREINO
local TrainTab = Hub:CreateTab("Treino & Farm", "⚡")

TrainTab:AddSection("Progressão de Força")

TrainTab:AddToggle("Fast Train (God Speed)", "Treina força na velocidade máxima", false, function(v)
    SETTINGS.FastTrain = v
end)

TrainTab:AddToggle("Auto Comprar Halteres", "Compra novos halteres automaticamente", false, function(v)
    SETTINGS.AutoBuyDumbbell = v
end)

TrainTab:AddToggle("Super Coletor", "Puxa moedas e gemas do mapa", false, function(v)
    SETTINGS.SuperCollector = v
end)

TrainTab:AddSection("Paredes")

TrainTab:AddToggle("Auto Quebrar Paredes", "Conclui os estágios automaticamente", false, function(v)
    SETTINGS.AutoStageClear = v
end)

TrainTab:AddButton("Quebrar Parede Atual", function()
    pcall(function()
        if StageCompleteEvent then StageCompleteEvent:FireServer() end
    end)
    Hub:Notify({ Title = "PAREDE", Content = "Comando enviado!", Duration = 2 })
end)

-- ABA 2: EVENTOS
local EventTab = Hub:CreateTab("Erupção", "🔥")

EventTab:AddToggle("Auto Farm Erupção", "Dano contínuo no boss da erupção", false, function(v)
    SETTINGS.AutoEruption = v
end)

-- ABA 3: PETS & RECOMPENSAS
local MiscTab = Hub:CreateTab("Pets & Bônus", "🎁")

MiscTab:AddButton("Equipar Melhores Pets", function()
    pcall(function()
        if PetFunction then PetFunction:InvokeServer("EquipBest") end
    end)
    Hub:Notify({ Title = "PETS", Content = "Melhores pets equipados!", Duration = 2 })
end)

MiscTab:AddButton("Resgatar Recompensas Diárias", function()
    pcall(function()
        if DailyRewardFunction then DailyRewardFunction:InvokeServer() end
        if QuestFunction then QuestFunction:InvokeServer("ClaimAll") end
    end)
    Hub:Notify({ Title = "RECOMPENSAS", Content = "Bônus coletados!", Duration = 2 })
end)

-- ABA 4: JOGADOR
local PlayerTab = Hub:CreateTab("Jogador", "👤")

PlayerTab:AddToggle("Noclip Total", "Atravessa barreiras e fases", false, function(v)
    SETTINGS.Noclip = v
end)

PlayerTab:AddSlider("Velocidade (WalkSpeed)", 16, 200, 115, function(val)
    SETTINGS.WalkSpeedValue = val
    SETTINGS.SpeedHack = true
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

-- ABA 5: TEXAI
Hub:CreateAIAssistant("Você é o assistente do TexHub no Wall Breaker.", function(prompt)
    local lower = string.lower(prompt)
    if string.find(lower, "treinar") or string.find(lower, "força") then
        SETTINGS.FastTrain = true
        return "Fast Train ativado! Acumulando força máxima."
    elseif string.find(lower, "parede") or string.find(lower, "quebrar") then
        SETTINGS.AutoStageClear = true
        return "Auto Quebra ativado! Avançando fases."
    elseif string.find(lower, "coletar") or string.find(lower, "moeda") then
        SETTINGS.SuperCollector = true
        return "Super Coletor ativo! Absorvendo drops."
    end
    return nil
end)

-- LOOPS
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    if SETTINGS.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and SETTINGS.SpeedHack then hum.WalkSpeed = SETTINGS.WalkSpeedValue end
end)

task.spawn(function()
    while true do
        if SETTINGS.FastTrain and ClickTrainEvent then
            pcall(function() ClickTrainEvent:FireServer() end)
        end
        if SETTINGS.AutoEruption and EruptionHitEvent then
            pcall(function() EruptionHitEvent:FireServer() end)
        end
        task.wait(SETTINGS.TrainDelay)
    end
end)

task.spawn(function()
    while true do
        if SETTINGS.AutoBuyDumbbell and BuyDumbbellEvent then
            pcall(function() BuyDumbbellEvent:FireServer() end)
        end
        if SETTINGS.AutoStageClear and StageCompleteEvent then
            pcall(function() StageCompleteEvent:FireServer() end)
        end
        if SETTINGS.SuperCollector and SuperCollectorEvt then
            pcall(function() SuperCollectorEvt:FireServer() end)
        end
        task.wait(0.6)
    end
end)
