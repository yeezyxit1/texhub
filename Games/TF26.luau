-- ============================================================================
-- [TEXHUB APEX v8.0 - TF26 TRUE BALL HITBOX & STEALTH REACH]
-- ============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 1. CARREGAMENTO DO MOTOR TEXHUB NATIVO
local TexHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/yeezyxit1/texhub/main/UI.luau?t=" .. tostring(os.time())))()

local Window = TexHub:CreateWindow({
    Title = "TEXHUB APEX <font color='#00FFAA'>[TF26 Elite]</font>"
})

-- 2. CONFIGURAÇÕES E ESTADOS
local Settings = {
    HitboxActive = false,
    HitboxSize = 14,
    ShowHitboxRadius = false,

    AutoTouchMagnet = true, -- Disparo de toque físico garantido
    MagnetRange = 12,

    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,

    OriginalProps = {}
}

-- 3. FILTRO DE JOGADORES (NÃO CONFUNDIR AVATARES COM A BOLA)
local function isPlayerPart(part)
    local model = part:FindFirstAncestorOfClass("Model")
    if model and model:FindFirstChildOfClass("Humanoid") then
        return true
    end
    return false
end

-- 4. LOCALIZADOR DINÂMICO DA BOLA DO TF26 (TAMANHO NATIVO 2.5)
local function getTF26Ball()
    -- 1º: Procura no Workspace direto
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and not obj.Anchored and not isPlayerPart(obj) then
            local isStandardSize = (obj.Size - Vector3.new(2.5, 2.5, 2.5)).Magnitude < 0.15
            local isTracked = Settings.OriginalProps[obj] ~= nil
            if isStandardSize or isTracked then
                return obj
            end
        end
    end

    -- 2º: Procura profunda em subpastas caso a bola tenha sido agrupada
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and not isPlayerPart(obj) then
            local isStandardSize = (obj.Size - Vector3.new(2.5, 2.5, 2.5)).Magnitude < 0.15
            local isTracked = Settings.OriginalProps[obj] ~= nil
            if isStandardSize or isTracked then
                return obj
            end
        end
    end

    return nil
end

-- 5. CLONE VISUAL ESTÉTICO (DISFARCE PARA NINGUÉM VER A BOLA GIGANTE)
local fakeBall = nil

local function cleanupFakeBall()
    if fakeBall and fakeBall.Parent then
        fakeBall:Destroy()
        fakeBall = nil
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
    cleanupFakeBall()
end

-- 6. CICLO PRINCIPAL DA HITBOX INVISÍVEL
RunService.RenderStepped:Connect(function()
    if not Settings.HitboxActive then return end

    local ball = getTF26Ball()
    if not ball then
        cleanupFakeBall()
        return
    end

    -- Guarda os parâmetros originais para restauração
    if not Settings.OriginalProps[ball] then
        Settings.OriginalProps[ball] = {
            Size = Vector3.new(2.5, 2.5, 2.5),
            Transparency = ball.Transparency,
            CanCollide = ball.CanCollide
        }
    end

    -- Cria o clone com a textura e tamanho normal (2.5)
    if not fakeBall or fakeBall.Parent ~= Workspace then
        fakeBall = ball:Clone()
        fakeBall.Name = "TexHub_TF26_Cosmetic"
        fakeBall.CanCollide = false
        fakeBall.Anchored = true
        fakeBall.CastShadow = false
        for _, c in ipairs(fakeBall:GetDescendants()) do
            if c:IsA("LuaSourceContainer") or c:IsA("TouchTransmitter") then
                c:Destroy()
            end
        end
        fakeBall.Parent = Workspace
    end

    -- Sincroniza a posição da bola visual com a bola verdadeira
    fakeBall.Size = Vector3.new(2.5, 2.5, 2.5)
    fakeBall.CFrame = ball.CFrame
    fakeBall.Transparency = 0

    -- Expande a área real de toque da bola
    ball.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
    ball.CanCollide = false

    if Settings.ShowHitboxRadius then
        ball.Transparency = 0.65
        ball.Color = Color3.fromRGB(0, 255, 170)
    else
        ball.Transparency = 1 -- Totalmente invisível
    end
end)

-- 7. REFORÇO: TOQUE FÍSICO MAGNÉTICO (AUTO-TACKLE & REACH)
RunService.Heartbeat:Connect(function()
    if not Settings.AutoTouchMagnet then return end

    local ball = getTF26Ball()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not ball or not hrp then return end

    local dist = (ball.Position - hrp.Position).Magnitude
    if dist <= Settings.MagnetRange then
        local leg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot") or hrp
        pcall(function()
            firetouchinterest(leg, ball, 0)
            task.wait()
            firetouchinterest(leg, ball, 1)
        end)
    end
end)

-- 8. CONSTRUÇÃO DA INTERFACE
local TabHitbox = Window:CreateTab("Hitbox Bola")
local TabPlayer = Window:CreateTab("Jogador")
local TabAjustes = Window:CreateTab("Ajustes")

-- Aba 1: Hitbox da Bola
TabHitbox:AddToggle("Hitbox Invisível da Bola", false, function(active)
    Settings.HitboxActive = active
    if not active then
        local ball = getTF26Ball()
        if ball then restoreBall(ball) end
    end
end)

TabHitbox:AddSlider("Tamanho da Hitbox (Studs)", 4, 30, 14, function(val)
    Settings.HitboxSize = val
end)

TabHitbox:AddToggle("Toque Magnético Automático", true, function(active)
    Settings.AutoTouchMagnet = active
end)

TabHitbox:AddSlider("Distância do Toque", 4, 25, 12, function(val)
    Settings.MagnetRange = val
end)

TabHitbox:AddToggle("Visualizar Esfera (Debug)", false, function(active)
    Settings.ShowHitboxRadius = active
end)

TabHitbox:AddButton("Restaurar Bola ao Normal", function()
    local ball = getTF26Ball()
    if ball then restoreBall(ball) end
end)

-- Aba 2: Jogador
TabPlayer:AddSlider("Velocidade", 16, 70, 16, function(val)
    Settings.WalkSpeed = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

TabPlayer:AddSlider("Força do Salto", 50, 150, 50, function(val)
    Settings.JumpPower = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = val end
end)

TabPlayer:AddToggle("Pulo Infinito (Aéreo)", false, function(active)
    Settings.InfJump = active
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Aba 3: Ajustes
TabAjustes:AddButton("Anti-Lag (Modo Fluido)", function()
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
