--!strict
-- [UNIVERSAL HUB LOADER - DELTA MOBILE]
-- Objetivo: Identificar PlaceId, carregar dependências da nuvem e despachar execução.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "LocalPlayer não inicializado.")

-- CONFIGURAÇÃO DO REPOSITÓRIO GITHUB
local REPO_CONFIG = {
    Owner = "SEU_USUARIO_GITHUB",      -- Substitua pelo seu usuário
    Repository = "NOME_DO_REPOSITORIO", -- Substitua pelo nome do repo
    Branch = "main"
}

local BASE_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    REPO_CONFIG.Owner,
    REPO_CONFIG.Repository,
    REPO_CONFIG.Branch
)

-- ROTEAMENTO DE JOGOS POR PLACEID
local SUPPORTED_GAMES: { [number]: string } = {
    -- [PlaceId] = "Caminho do Arquivo no Repositório"
    [123456789] = "Games/SoccerMath.luau", -- Substitua pelo PlaceId real do jogo analisado
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
        warn(string.format("[LOADER] Erro de sintaxe/compilação em: %s | %s", path, tostring(executable)))
        return nil
    end

    return executable
end

-- INICIALIZAÇÃO
local function Initialize()
    print("[HUB] Conectando ao repositório central...")
    
    local currentPlaceId = game.PlaceId
    local gameScriptPath = SUPPORTED_GAMES[currentPlaceId] or "Games/Universal.luau"
    
    print(string.format("[HUB] PlaceId: %d | Rota selecionada: %s", currentPlaceId, gameScriptPath))

    local runScript = FetchModule(gameScriptPath)
    if runScript then
        -- Executa o módulo passando utilitários compartilhados
        local execSuccess, runtimeErr = pcall(runScript, {
            BaseUrl = BASE_URL,
            Fetch = FetchModule
        })
        
        if not execSuccess then
            warn(string.format("[HUB] Erro em tempo de execução: %s", tostring(runtimeErr)))
        else
            print("[HUB] Módulo carregado com sucesso!")
        end
    else
        warn("[HUB] Falha crítica: Nenhum módulo pôde ser executado.")
    end
end

task.spawn(Initialize)
