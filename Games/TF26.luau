-- ============================================================================
-- [TEXHUB APEX v9.0 - TF26 TRUE REACH & MAGNET TACKLE]
-- ============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 1. MOTOR TEXHUB
local TexHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/yeezyxit1/texhub/main/UI.luau?t=" .. tostring(os.time())))()

local Window = TexHub:CreateWindow({
    Title = "TEXHUB APEX <font color='#00FFAA'>[TF26 Reach]</font>"
})

-- 2. CONFIGURAÇÕES
local Settings = {
    ReachActive = false,
    ReachRange = 14,
    ShowVisualizer = false,

    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false
}

-- 3. FILTRO DE JOGADORES
local function isPlayerPart(part)
    local model = part:FindFirstAncestorOfClass("Model")
    if model and model:FindFirstChildOfClass("Humanoid") then
        return true
    end
    return false
end

-- 4. LOCALIZADOR DA BOLA REAL DO TF26
local function getBall()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and not obj.Anchored and not isPlayerPart(obj) then
            if (obj.Size - Vector3.new(2.5, 2.5, 2.5)).Magnitude < 0.35 then
                return obj
            end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and not isPlayerPart(obj) then
            if (obj.Size - Vector3.new(2.5, 2.5, 2.5)).Magnitude < 0.35 then
                return obj
            end
        end
    end
    return nil
end

-- 5. ESFERA DE VISUALIZAÇÃO (DEBUG)
local visualizerPart = nil

local function updateVisualizer(originCFrame)
    if not Settings.ShowVisualizer or not Settings.ReachActive then
        if visualizerPart then
            visualizerPart:Destroy()
            visualizerPart = nil
        end
        return
    end

    if not visualizerPart or visualizerPart.Parent ~= Workspace then
        visualizerPart = Instance.new("Part")
        visualizerPart.Name = "TexHub_ReachVisual"
        visualizerPart.Shape = Enum.PartType.Ball
        visualizerPart.Material = Enum.Material.ForceField
        visualizerPart.Color = Color3.fromRGB(0, 255, 170)
        visualizerPart.Transparency = 0.75
        visualizerPart.CanCollide = false
        visualizerPart.CanTouch = false
        visualizerPart.CanQuery = false
        visualizerPart.Anchored = true
        visualizerPart.Parent = Workspace
    end

    local d = Settings.ReachRange * 2
    visualizerPart.Size = Vector3.new(d, d, d)
    visualizerPart.CFrame = originCFrame
end

-- 6. MOTOR PRINCIPAL DE REACH E DIVIDIDA MAGNÉTICA
RunService.Heartbeat:Connect(function()
    if not Settings.ReachActive then
        if visualizerPart then
            visualizerPart:Destroy()
            visualizerPart = nil
        end
        return
    end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    updateVisualizer(hrp.CFrame)

    local ball = getBall()
    if not ball then return end

    -- Garante que a bola nunca tem o tamanho modificado para não criar barreiras
    if (ball.Size - Vector3.new(2.5, 2.5, 2.5)).Magnitude > 0.5 then
        ball.Size = Vector3.new(2.5, 2.5, 2.5)
        ball.CanCollide = true
    end

    local dist = (ball.Position - hrp.Position).Magnitude

    -- Se a bola estiver dentro do raio de Reach, simula o toque contínuo nos pés
    if dist <= Settings.ReachRange then
        local foot = char:FindFirstChild("Right Leg")
            or char:FindFirstChild("RightFoot")
            or char:FindFirstChild("Left Leg")
            or char:FindFirstChild("LeftFoot")
            or hrp

        pcall(function()
            firetouchinterest(foot, ball, 0)
            firetouchinterest(foot, ball, 1)
        end)
    end
end)

-- 7. CONSTRUÇÃO DA INTERFACE
local TabReach  = Window:CreateTab("Reach & Toque")
local TabPlayer = Window:CreateTab("Jogador")

-- Aba Reach
TabReach:AddToggle("Reach Invisível Ativo", false, function(active)
    Settings.ReachActive = active
    if not active and visualizerPart then
        visualizerPart:Destroy()
        visualizerPart = nil
    end
end)

TabReach:AddSlider("Alcance do Reach (Studs)", 4, 30, 14, function(val)
    Settings.ReachRange = val
end)

TabReach:AddToggle("Visualizar Raio do Reach", false, function(active)
    Settings.ShowVisualizer = active
    if not active and visualizerPart then
        visualizerPart:Destroy()
        visualizerPart = nil
    end
end)

-- Aba Jogador
TabPlayer:AddSlider("Velocidade", 16, 60, 16, function(val)
    Settings.WalkSpeed = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

TabPlayer:AddSlider("Força do Salto", 50, 140, 50, function(val)
    Settings.JumpPower = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = val end
end)

TabPlayer:AddToggle("Pulo Infinito", false, function(active)
    Settings.InfJump = active
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
