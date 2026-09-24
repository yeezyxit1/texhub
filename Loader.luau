--!strict
-- [LOADER PRINCIPAL - TEXHUB APEX V3]
local Players = game:GetService("Players")
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

-- REGISTO DOS JOGOS
local SUPPORTED_GAMES: { [number]: string } = {
    [124721731495884] = "Games/mathsoccerplayer.luau",
    [110730550789828] = "Games/ChopTrees.luau",
}

local function FetchModule(path: string): ((...any) -> any)?
    -- Anti-Cache: Impede que o GitHub entregue páginas antigas ou 404
    local cacheBuster = "?t=" .. tostring(os.time())
    local fullUrl = BASE_URL .. path .. cacheBuster

    local fetchSuccess, sourceCode = pcall(function()
        return game:HttpGet(fullUrl)
    end)

    if not fetchSuccess or not sourceCode or string.find(sourceCode, "404: Not Found") then
        warn(string.format("[TEXHUB] Falha ao baixar módulo: %s", path))
        return nil
    end

    local loadSuccess, executable = pcall(loadstring, sourceCode)
    if not loadSuccess or type(executable) ~= "function" then
        warn(string.format("[TEXHUB] Erro de sintaxe no arquivo %s: %s", path, tostring(executable)))
        return nil
    end

    return executable
end

local function Initialize()
    local currentPlaceId = game.PlaceId
    local gameScriptPath = SUPPORTED_GAMES[currentPlaceId] or "Games/Universal.luau"

    print(string.format("[TEXHUB] PlaceId: %d | Rota: %s", currentPlaceId, gameScriptPath))

    local runScript = FetchModule(gameScriptPath)
    if runScript then
        local success, err = pcall(runScript)
        if not success then
            warn(string.format("[TEXHUB ERRO DE EXECUÇÃO]: %s", tostring(err)))
        end
    else
        warn("[TEXHUB] Módulo indisponível no momento.")
    end
end

task.spawn(Initialize)
