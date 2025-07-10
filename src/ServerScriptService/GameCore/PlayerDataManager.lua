-- PlayerDataManager.lua
-- Script del servidor para gestionar los datos del jugador

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- Módulos compartidos
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerStats = require(ReplicatedStorage.SharedModules.PlayerStats)
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

-- DataStore para guardar datos del jugador
local PlayerDataStore = DataStoreService:GetDataStore("ObbyPlayerData")

-- Tabla para almacenar datos de jugadores en memoria
local PlayerDataCache = {}

local PlayerDataManager = {}

-- Función para cargar datos del jugador
function PlayerDataManager.LoadPlayerData(player)
    local userId = player.UserId
    local username = player.Name
    
    -- Intentar cargar datos guardados
    local success, savedData = pcall(function()
        return PlayerDataStore:GetAsync(tostring(userId))
    end)
    
    if success and savedData then
        -- Verificar que los datos tienen la estructura correcta
        if savedData.Progress and savedData.Statistics then
            PlayerDataCache[userId] = savedData
            print("Datos cargados para " .. username)
        else
            -- Datos corruptos, crear nuevos
            PlayerDataCache[userId] = PlayerStats.CreateNewPlayerData(userId, username)
            print("Datos corruptos detectados, creados nuevos para " .. username)
        end
    else
        -- Crear datos nuevos para jugador
        PlayerDataCache[userId] = PlayerStats.CreateNewPlayerData(userId, username)
        print("Nuevos datos creados para " .. username)
    end
    
    return PlayerDataCache[userId]
end

-- Función para guardar datos del jugador
function PlayerDataManager.SavePlayerData(player)
    local userId = player.UserId
    local playerData = PlayerDataCache[userId]
    
    if not playerData then
        warn("No se encontraron datos para guardar: " .. player.Name)
        return false
    end
    
    local success, errorMessage = pcall(function()
        PlayerDataStore:SetAsync(tostring(userId), playerData)
    end)
    
    if success then
        print("Datos guardados exitosamente para " .. player.Name)
        return true
    else
        warn("Error al guardar datos para " .. player.Name .. ": " .. tostring(errorMessage))
        return false
    end
end

-- Función para obtener datos del jugador
function PlayerDataManager.GetPlayerData(player)
    local userId = player.UserId
    return PlayerDataCache[userId]
end

-- Función para actualizar datos del jugador
function PlayerDataManager.UpdatePlayerData(player, updateFunction)
    local userId = player.UserId
    local playerData = PlayerDataCache[userId]
    
    if playerData then
        updateFunction(playerData)
        -- Guardar automáticamente después de actualizar
        PlayerDataManager.SavePlayerData(player)
    end
end

-- Función para registrar muerte del jugador
function PlayerDataManager.RegisterPlayerDeath(player, level)
    PlayerDataManager.UpdatePlayerData(player, function(playerData)
        PlayerStats.RegisterDeath(playerData, level)
    end)
end

-- Función para registrar completado de nivel
function PlayerDataManager.RegisterLevelCompletion(player, level, time)
    PlayerDataManager.UpdatePlayerData(player, function(playerData)
        PlayerStats.RegisterLevelCompletion(playerData, level, time)
        
        -- Desbloquear siguiente nivel
        if playerData.Progress.UnlockedLevels[level + 1] ~= true then
            playerData.Progress.UnlockedLevels[level + 1] = true
        end
        
        -- Dar recompensas
        PlayerStats.AddCoins(playerData, GameConstants.CURRENCY.LEVEL_COMPLETION_COINS)
        PlayerStats.AddGems(playerData, GameConstants.CURRENCY.LEVEL_COMPLETION_GEMS)
    end)
end

-- Función para agregar martillo al jugador
function PlayerDataManager.AddHammerToPlayer(player, hammerName)
    PlayerDataManager.UpdatePlayerData(player, function(playerData)
        if PlayerStats.AddHammer(playerData, hammerName) then
            -- Dar recompensas por martillo
            PlayerStats.AddCoins(playerData, GameConstants.CURRENCY.HAMMER_COINS)
            PlayerStats.AddGems(playerData, GameConstants.CURRENCY.HAMMER_GEMS)
        end
    end)
end

-- Función para actualizar checkpoint
function PlayerDataManager.UpdateCheckpoint(player, level, checkpoint)
    PlayerDataManager.UpdatePlayerData(player, function(playerData)
        PlayerStats.UpdateProgress(playerData, level, checkpoint)
    end)
end

-- Función para agregar monedas
function PlayerDataManager.AddCoins(player, amount)
    PlayerDataManager.UpdatePlayerData(player, function(playerData)
        PlayerStats.AddCoins(playerData, amount)
    end)
end

-- Función para agregar gemas
function PlayerDataManager.AddGems(player, amount)
    PlayerDataManager.UpdatePlayerData(player, function(playerData)
        PlayerStats.AddGems(playerData, amount)
    end)
end

-- Eventos del jugador
Players.PlayerAdded:Connect(function(player)
    -- Cargar datos cuando el jugador entra
    PlayerDataManager.LoadPlayerData(player)
    
    -- Configurar guardado automático
    spawn(function()
        while player.Parent do
            wait(GameConstants.SAVE.AUTO_SAVE_INTERVAL)
            PlayerDataManager.SavePlayerData(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    -- Guardar datos cuando el jugador sale
    PlayerDataManager.SavePlayerData(player)
    
    -- Limpiar cache
    local userId = player.UserId
    PlayerDataCache[userId] = nil
end)

return PlayerDataManager 