--!strict
-- ========================================================
-- [TEXHUB APEX ENGINE - CORE INDUSTRIAL LOADER]
-- ========================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ScriptContext = game:GetService("ScriptContext")
local LocalPlayer = Players.LocalPlayer

assert(LocalPlayer, "LocalPlayer não inicializado.")

-- 1. CAMADA DE PROTEÇÃO SILENCIOSA (ANTI-DETECTION & ANTI-CRASH)
pcall(function()
    -- Bloqueia envio de relatórios de erro do cliente para os desenvolvedores do jogo
    ScriptContext.Error:Connect(function() end)

    local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local oldNamecall = gmt.__namecall

    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local name = tostring(self)

        -- Filtra e anula remotes comuns de checagem/anti-cheat de desenvolvedores
        if method == "FireServer" or method == "InvokeServer" then
            if string.find(string.lower(name), "anticheat") 
            or string.find(string.lower(name), "report") 
            or string.find(string.lower(name), "telemetry") 
            or string.find(string.lower(name), "detection") then
                return nil
            end
        end

        return oldNamecall(self, ...)
    end)
    setreadonly(gmt, true)
end)

-- 2. SISTEMA DE PERSISTÊNCIA (CONFIG MANAGER GLOBAL)
getgenv().TexHubConfig = {
    Save = function(gameId: number, data: any)
        if writefile then
            pcall(function()
                if not isfolder("TexHub") then makefolder("TexHub") end
                writefile(string.format("TexHub/%d.json", gameId), HttpService:JSONEncode(data))
            end)
        end
    end,
    Load = function(gameId: number)
        if readfile and isfile and isfile(string.format("TexHub/%d.json", gameId)) then
            local success, content = pcall(readfile, string.format("TexHub/%d.json", gameId))
            if success then
                local decodeSuccess, data = pcall(HttpService.JSONDecode, HttpService, content)
                if decodeSuccess then return data end
            end
        end
        return {}
    end
}

-- 3. CONFIGURAÇÃO DE REPOSITÓRIO E ROTAS
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

local SUPPORTED_GAMES: { [number]: string } = {
    [124721731495884] = "Games/mathsoccerplayer.luau",
    [110730550789828] = "Games/ChopTrees.luau",
    [74889851913797]  = "Games/WallBreaker.luau",
    [128448883585036] = "Games/SkinnyPerStep.luau",

}

local function FetchModule(path: string): ((...any) -> any)?
    local cacheBuster = "?t=" .. tostring(os.time())
    local fullUrl = BASE_URL .. path .. cacheBuster

    local fetchSuccess, sourceCode = pcall(function()
        return game:HttpGet(fullUrl)
    end)

    if not fetchSuccess or not sourceCode or string.find(sourceCode, "404: Not Found") then
        warn(string.format("[TEXHUB] Módulo indisponível: %s", path))
        return nil
    end

    local loadSuccess, executable = pcall(loadstring, sourceCode)
    if not loadSuccess or type(executable) ~= "function" then
        warn(string.format("[TEXHUB] Erro de compilação em %s: %s", path, tostring(executable)))
        return nil
    end

    return executable
end

-- 4. INICIALIZAÇÃO CONTROLADA
local function Initialize()
    local currentPlaceId = game.PlaceId
    local gameScriptPath = SUPPORTED_GAMES[currentPlaceId] or "Games/Universal.luau"

    print(string.format("[TEXHUB APEX] Jogo: %d | Rota: %s", currentPlaceId, gameScriptPath))

    local runScript = FetchModule(gameScriptPath)
    if runScript then
        local success, err = pcall(runScript)
        if not success then
            warn(string.format("[TEXHUB RUNTIME ERROR]: %s", tostring(err)))
        end
    else
        warn("[TEXHUB] Inicialização abortada: módulo não carregado.")
    end
end

task.spawn(Initialize)
