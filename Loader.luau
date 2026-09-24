--!strict
-- [LOADER PRINCIPAL - TEXHUB]
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer não inicializado.")

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

-- REGISTO DE JOGOS SUPORTADOS
local SUPPORTED_GAMES: { [number]: string } = {
    [124721731495884] = "Games/mathsoccerplayer.luau",
    [110730550789828] = "Games/ChopTrees.luau",

    
}


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

local function Initialize()
    print("[TEXHUB] Conectando ao repositório...")
    
    local currentPlaceId = game.PlaceId
    local gameScriptPath = SUPPORTED_GAMES[currentPlaceId] or "Games/Universal.luau"

    print(string.format("[TEXHUB] PlaceId: %d | Rota: %s", currentPlaceId, gameScriptPath))

    local runScript = FetchModule(gameScriptPath)
    if runScript then
        pcall(runScript)
    else
        warn("[TEXHUB] Falha ao inicializar módulo.")
    end
end

task.spawn(Initialize)
