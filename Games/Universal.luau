--!strict
-- [MÓDULO UNIVERSAL - TEXHUB]
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer não encontrado.")

-- Anti-AFK nativo contra desconexão de 20 minutos
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.zero)
    print("[TEXHUB] Pulso Anti-AFK enviado.")
end)

-- Notificação na tela confirmando o carregamento
StarterGui:SetCore("SendNotification", {
    Title = "TexHub Conectado!",
    Text = "Executando em modo Universal via GitHub.",
    Duration = 5
})

print("[TEXHUB] Módulo Universal rodando com sucesso.")
