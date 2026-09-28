-- ============================================================================
-- [TEXHUB APEX v7.0 - TF26 TACTICAL FOOTBALL ULTIMATE HITBOX & TACKLE]
-- ============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 1. IMPORTAÇÃO DO MOTOR VISUAL TEXHUB
local TexHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/yeezyxit1/texhub/main/UI.luau?t=" .. tostring(os.time())))()

local Window = TexHub:CreateWindow({
    Title = "TEXHUB APEX <font color='#00FFAA'>[TF26 Pro]</font>"
})

-- 2. CONFIGURAÇÕES E ESTADOS
local Settings = {
    HitboxActive = false,
    HitboxSize = 12,
    ShowHitboxRadius = false,

    AutoTackle = false,
    TackleRange = 10,

    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,

    OriginalProps = {},
    OriginalLimbs = {}
}

-- 3. LOCALIZADOR AVANÇADO DA BOLA NO TF26
local function findBall()
    local names = {"Ball", "Football", "SoccerBall", "TPSBall", "TouchBall", "RealBall", "Soccer_Ball"}
    for _, name in ipairs(names) do
        local obj = Workspace:FindFirstChild(name, true)
        if obj then
            if obj:IsA("BasePart") then
                return obj
            elseif obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) then
                return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            end
        end
    end
    -- Varredura por geometria de esfera com física
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("foot")) and not obj.Anchored and obj.Size.X < 8 then
            return obj
        end
    end
    return nil
end

-- 4. CONTROLO DO CLONE VISUAL DA BOLA
local visualBall = nil

local function cleanupVisualBall()
    if visualBall and visualBall.Parent then
        visualBall:Destroy()
        visualBall = nil
    end
end

local function restoreBall(ball)
    if ball and Settings.OriginalProps[ball] then
        local p = Settings.OriginalProps[ball]
        ball.Size = p.Size
        ball.Transparency = p.Transparency
        ball.CanCollide = p.CanCollide
        Settings.OriginalProps[ball] = nil
    end
    cleanupVisualBall()
end

-- 5. CICLO DA HITBOX INVISÍVEL
RunService.RenderStepped:Connect(function()
    if not Settings.HitboxActive then return end

    local ball = findBall()
    if not ball then
        cleanupVisualBall()
        return
    end

    if not Settings.OriginalProps[ball] then
        Settings.OriginalProps[ball] = {
            Size = ball.Size,
            Transparency = ball.Transparency,
            CanCollide = ball.CanCollide
        }
    end

    -- Criação da bola decorativa (tamanho original)
    if not visualBall or visualBall.Parent ~= Workspace then
        visualBall = ball:Clone()
        visualBall.Name = "TexHub_TF26_VisualClone"
        visualBall.CanCollide = false
        visualBall.Anchored = true
        visualBall.CastShadow = false
        for _, child in ipairs(visualBall:GetDescendants()) do
            if child:IsA("LuaSourceContainer") or child:IsA("TouchTransmitter") then
                child:Destroy()
            end
        end
        visualBall.Parent = Workspace
    end

    -- Sincronização de posição da bola decorativa
    visualBall.Size = Settings.OriginalProps[ball].Size
    visualBall.CFrame = ball.CFrame
    visualBall.Transparency = 0

    -- Expansão da hitbox real de toque
    ball.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
    ball.CanCollide = false

    if Settings.ShowHitboxRadius then
        ball.Transparency = 0.7
        ball.Color = Color3.fromRGB(0, 255, 170)
    else
        ball.Transparency = 1 -- Totalmente invisível
    end
end)

-- 6. CICLO DE DIVIDIDA MAGNÉTICA (AUTO TACKLE / TOUCH)
RunService.Heartbeat:Connect(function()
    if not Settings.AutoTackle then return end

    local ball = findBall()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not ball or not hrp then return end

    local distance = (ball.Position - hrp.Position).Magnitude
    if distance <= Settings.TackleRange then
        local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot") or hrp
        pcall(function()
            firetouchinterest(rightLeg, ball, 0)
            task.wait()
            firetouchinterest(rightLeg, ball, 1)
        end)
    end
end)

-- 7. CONSTRUÇÃO DA INTERFACE
local TabBall   = Window:CreateTab("Hitbox Bola")
local TabTackle = Window:CreateTab("Dividida/Pés")
local TabPlayer = Window:CreateTab("Jogador")
local TabVisual = Window:CreateTab("Ajustes")

-- Aba Hitbox Bola
TabBall:AddToggle("Hitbox Invisível Ativa", false, function(active)
    Settings.HitboxActive = active
    if not active then
        local ball = findBall()
        if ball then restoreBall(ball) end
    end
end)

TabBall:AddSlider("Alcance da Bola (Studs)", 4, 30, 12, function(val)
    Settings.HitboxSize = val
end)

TabBall:AddToggle("Mostrar Raio (Visualizador Debug)", false, function(active)
    Settings.ShowHitboxRadius = active
end)

TabBall:AddButton("Restaurar Bola ao Padrão", function()
    local ball = findBall()
    if ball then restoreBall(ball) end
end)

-- Aba Dividida / Pés
TabTackle:AddToggle("Auto Dividida Magnética (Tackle)", false, function(active)
    Settings.AutoTackle = active
end)

TabTackle:AddSlider("Distância da Dividida", 4, 25, 10, function(val)
    Settings.TackleRange = val
end)

-- Aba Jogador
TabPlayer:AddSlider("Velocidade de Corrida", 16, 75, 16, function(val)
    Settings.WalkSpeed = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

TabPlayer:AddSlider("Força do Salto", 50, 160, 50, function(val)
    Settings.JumpPower = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = val end
end)

TabPlayer:AddToggle("Pulo Infinito (Cabeceio)", false, function(active)
    Settings.InfJump = active
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Aba Ajustes
TabVisual:AddButton("Otimizar Campo (Anti-Lag)", function()
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Name:lower():find("ball") then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            end
        end
    end)
end)
