--!strict
-- [UNIVERSAL HUB LOADER - DELTA MOBILE]
-- Objetivo: Identificar PlaceId, carregar dependências da nuvem e despachar execução.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer não inicializado.")

-- ========================================================
-- MODIFIQUE APENAS ESTAS DUAS LINHAS ABAIXO:
-- ========================================================
local REPO_CONFIG = {
    Owner = "SEU_USUARIO_GITHUB",      -- Coloque seu nick do GitHub entre as aspas
    Repository = "NOME_DO_REPOSITORIO", -- Coloque o nome exato do repo entre as aspas
    Branch = "main"
}
-- ========================================================

local BASE_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    REPO_CONFIG.Owner,
    REPO_CONFIG.Repository,
    REPO_CONFIG.Branch
)

-- ROTEAMENTO DE JOGOS POR PLACEID
local SUPPORTED_GAMES: { [number]: string } = {
    -- [PlaceId] = "Caminho do Arquivo no Repositório"
    -- Exemplo: [123456789] = "Games/SoccerMath.luau"
}

-- FUNÇÃO ROBUSTA DE REQUISIÇÃO E EXECUÇÃO
local function FetchModule(path: string): ((...any) -> any)?
    local fullUrl = BASE_URL .. path
    local fetchSuccess, sourceCode = pcall(function()
        return game:HttpGet(fullUrl)
    end)

    if not fetchSuccess or not sourceCode or sourceCode == "404: Not Found" then
        warn(string.format("[LOADER] Falha ao baixar módulo: %s", fullUrl))
        return nil
    end

    local loadSuccess, executable = pcall(loadstring, sourceCode)
    if not loadSuccess or type(executable) ~= "function" then
        warn(string.format("[LOADER] Erro de sintaxe em: %s | %s", path, tostring(executable)))
        return nil
    end

    return executable
end

-- INICIALIZAÇÃO
local function Initialize()
    print("[HUB] Conectando ao repositório central...")
    
    local currentPlaceId = game.PlaceId
    local gameScriptPath = SUPPORTED_GAMES[currentPlaceId] or "Games/Universal.luau"
    
    print(string.format("[HUB] PlaceId: %d | Rota: %s", currentPlaceId, gameScriptPath))

    local runScript = FetchModule(gameScriptPath)
    if runScript then
        local execSuccess, runtimeErr = pcall(runScript, {
            BaseUrl = BASE_URL,
            Fetch = FetchModule
        })
        
        if not execSuccess then
            warn(string.format("[HUB] Erro de execução: %s", tostring(runtimeErr)))
        else
            print("[HUB] Módulo executado com sucesso!")
        end
    else
        warn("[HUB] Falha crítica: Módulo inacessível.")
    end
end

task.spawn(Initialize)
