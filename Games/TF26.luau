-- ============================================================================
-- [TEXHUB APEX v8.5 - TF26 SAFE HITBOX & HITBOXHANDLER COMPATIBLE]
-- ============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera

-- 1. MOTOR GRÁFICO TEXHUB
local TexHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/yeezyxit1/texhub/main/UI.luau?t=" .. tostring(os.time())))()

local Window = TexHub:CreateWindow({
    Title = "TEXHUB APEX <font color='#00FFAA'>[TF26 Pro v8.5]</font>"
})

-- 2. ESTADOS
local Settings = {
    HitboxActive = false,
    HitboxSize = 12,
    ShowHitboxRadius = false,

    AutoTouchMagnet = true,
    MagnetRange = 10,

    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,

    OriginalProps = {}
}

-- 3. FILTRO DE JOGADORES
local function isPlayerPart(part)
    local model = part:FindFirstAncestorOfClass("Model")
    if model and model:FindFirstChildOfClass("Humanoid") then
        return true
    end
    return false
end

-- 4. LOCALIZADOR DA BOLA REAL (TAMANHO 2.5)
local function getTF26Ball()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and not obj.Anchored and not isPlayerPart(obj) then
            local isStandard = (obj.Size - Vector3.new(2.5, 2.5, 2.5)).Magnitude < 0.2
            local isTracked = Settings.OriginalProps[obj] ~= nil
            if isStandard or isTracked then
                return obj
            end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and not isPlayerPart(obj) then
            local isStandard = (obj.Size - Vector3.new(2.5, 2.5, 2.5)).Magnitude < 0.2
            local isTracked = Settings.OriginalProps[obj] ~= nil
            if isStandard or isTracked then
                return obj
            end
        end
    end
    return nil
end

-- 5. GESTÃO DO CLONE VISUAL (ISOLADO NA CÂMARA LOCAL)
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
        Settings.OriginalProps[ball] = nil
    end
    cleanupFakeBall()
end

-- 6. CICLO SEGURO DA HITBOX INVISÍVEL
RunService.RenderStepped:Connect(function()
    if not Settings.HitboxActive then return end

    local ball = getTF26Ball()
    if not ball then
        cleanupFakeBall()
        return
    end

    -- Guarda os valores de fábrica
    if not Settings.OriginalProps[ball] then
        Settings.OriginalProps[ball] = {
            Size = Vector3.new(2.5, 2.5, 2.5),
            Transparency = ball.Transparency
        }
    end

    -- Cria o clone dentro da Camera para isolá-lo das varreduras do jogo
    if not fakeBall or fakeBall.Parent ~= Camera then
        cleanupFakeBall()
        fakeBall = ball:Clone()
        fakeBall.Name = "TexHub_SafeVisual"
        fakeBall.CanCollide = false
        fakeBall.Anchored = true
        fakeBall.CastShadow = false
        
        -- Remove scripts ou transmissores do clone
        for _, c in ipairs(fakeBall:GetDescendants()) do
            if c:IsA("LuaSourceContainer") or c:IsA("TouchTransmitter") then
                c:Destroy()
            end
        end
        fakeBall.Parent = Camera
    end

    -- Acompanha a posição real da bola
    fakeBall.Size = Vector3.new(2.5, 2.5, 2.5)
    fakeBall.CFrame = ball.CFrame
    fakeBall.Transparency = 0

    -- Expande a área de toque da bola original
    ball.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)

    if Settings.ShowHitboxRadius then
        ball.Transparency = 0.65
        ball.Color = Color3.fromRGB(0, 255, 170)
    else
        ball.Transparency = 1 -- Totalmente invisível
    end
end)

-- 7. DIVIDIDA E TOQUE MAGNÉTICO (AUTO TACKLE)
RunService.Heartbeat:Connect(function()
    if not Settings.AutoTouchMagnet then return end

    local ball = getTF26Ball()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not ball or not hrp then return end

    local dist = (ball.Position - hrp.Position).Magnitude
    if dist <= Settings.MagnetRange then
        local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot") or hrp
        pcall(function()
            firetouchinterest(rightLeg, ball, 0)
            task.wait()
            firetouchinterest(rightLeg, ball, 1)
        end)
    end
end)

-- 8. INTERFACE GRÁFICA
local TabHitbox = Window:CreateTab("Hitbox Bola")
local TabPlayer = Window:CreateTab("Jogador")

TabHitbox:AddToggle("Hitbox Invisível da Bola", false, function(active)
    Settings.HitboxActive = active
    if not active then
        local ball = getTF26Ball()
        if ball then restoreBall(ball) end
    end
end)

TabHitbox:AddSlider("Tamanho da Hitbox (Studs)", 4, 25, 12, function(val)
    Settings.HitboxSize = val
end)

TabHitbox:AddToggle("Auto Dividida Magnética (Tackle)", true, function(active)
    Settings.AutoTouchMagnet = active
end)

TabHitbox:AddSlider("Alcance da Dividida", 4, 20, 10, function(val)
    Settings.MagnetRange = val
end)

TabHitbox:AddToggle("Visualizar Raio (Debug)", false, function(active)
    Settings.ShowHitboxRadius = active
end)

TabHitbox:AddButton("Restaurar Bola ao Normal", function()
    local ball = getTF26Ball()
    if ball then restoreBall(ball) end
end)

TabPlayer:AddSlider("Velocidade", 16, 65, 16, function(val)
    Settings.WalkSpeed = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

TabPlayer:AddSlider("Poder do Salto", 50, 150, 50, function(val)
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
