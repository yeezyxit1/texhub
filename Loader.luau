--!strict
-- [LOADER PRINCIPAL - TEXHUB]
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer não inicializado.")

-- CONFIGURAÇÃO VINCULADA AO SEU GITHUB
local REPO_CONFIG = {
    Owner = "yeezyxit1",
    Repository = "texhub",
    Branch = "main"
}

local BASE_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    REPO_CONFIG.Owner,
    REPO_CONFIG.Repository,
    REPO_CONFIG.Branch
)

-- ROTAS DE JOGOS POR ID
local SUPPORTED_GAMES: { [number]: string } = {
    -- Aqui adicionaremos os PlaceIds específicos no futuro
}

-- DOWNLOAD E EXECUÇÃO
local function FetchModule(path: string): ((...any) -> any)?
    local fullUrl = BASE_URL .. path
    local fetchSuccess, sourceCode = pcall(function()
        return game:HttpGet(fullUrl)
    end)

    if not fetchSuccess or not sourceCode or sourceCode == "404: Not Found" then
        warn(string.format("[TEXHUB] Arquivo não encontrado: %s", fullUrl))
        return nil
    end

    local loadSuccess, executable = pcall(loadstring, sourceCode)
    if not loadSuccess or type(executable) ~= "function" then
        warn(string.format("[TEXHUB] Erro de sintaxe: %s", path))
        return nil
    end

    return executable
end

-- INICIALIZAÇÃO
local function Initialize()
    print("[TEXHUB] Conectando ao repositório...")
    
    local currentPlaceId = game.PlaceId
    local gameScriptPath = SUPPORTED_GAMES[currentPlaceId] or "Games/Universal.luau"

    local runScript = FetchModule(gameScriptPath)
    if runScript then
        pcall(runScript)
    else
        warn("[TEXHUB] Falha ao inicializar módulo.")
    end
end

task.spawn(Initialize)
