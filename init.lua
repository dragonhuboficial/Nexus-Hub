--[[
    NEXUS-HUB v7.0 APEX | LOADER
    "Modular Intelligence System"
]]

local baseUrl = "https://raw.githubusercontent.com/dragonhuboficial/Nexus-Hub/main/src/modules/"

local function loadModule(name)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(baseUrl .. name .. ".lua"))()
    end)
    if not success then
        warn("Nexus-Hub: Falha ao carregar módulo " .. name .. " -> " .. tostring(result))
        return nil
    end
    return result
end

-- Carregando Módulos
local Config = loadModule("Config")
local Decryption = loadModule("Decryption")
local UI = loadModule("UI")
local Core = loadModule("Core")

if Config and Decryption and UI and Core then
    UI.init(Config)
    Core.hook(Config, UI, Decryption)
    print("Nexus-Hub v7.0 Apex carregado com sucesso!")
else
    error("Nexus-Hub: Erro crítico ao carregar módulos.")
end
