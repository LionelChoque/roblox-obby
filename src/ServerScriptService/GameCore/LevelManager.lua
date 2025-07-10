-- LevelManager.lua
-- Sistema de gestión de niveles para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)
local PlayerStats = require(ReplicatedStorage.SharedModules.PlayerStats)

-- Importar otros sistemas
local PlayerDataManager = require(script.Parent.PlayerDataManager)
local CheckpointSystem = require(script.Parent.CheckpointSystem)

local LevelManager = {}

-- Configuración de niveles
local LevelConfigs = {
    [1] = {
        name = "Bosque de los Iniciados",
        description = "Un bosque mágico lleno de plataformas flotantes y obstáculos naturales",
        difficulty = 1,
        estimatedTime = 180, -- 3 minutos
        unlockRequirement = nil, -- Siempre desbloqueado
        rewards = {
            coins = 50,
            gems = 5,
            hammer = GameConstants.HAMMERS.BEGINNER
        },
        spawnPosition = Vector3.new(0, 10, 0),
        finishPosition = Vector3.new(500, 30, 0)
    },
    [2] = {
        name = "Aguas Profundas",
        description = "Un mundo submarino con plataformas que se hunden y corrientes peligrosas",
        difficulty = 2,
        estimatedTime = 300, -- 5 minutos
        unlockRequirement = 1, -- Requiere completar nivel 1
        rewards = {
            coins = 75,
            gems = 8,
            hammer = GameConstants.HAMMERS.NAVIGATOR
        },
        spawnPosition = Vector3.new(0, 5, 0),
        finishPosition = Vector3.new(600, 20, 0)
    },
    [3] = {
        name = "Volcán Ardiente",
        description = "Un volcán activo con lava que sube y plataformas que se derriten",
        difficulty = 3,
        estimatedTime = 420, -- 7 minutos
        unlockRequirement = 2, -- Requiere completar nivel 2
        rewards = {
            coins = 100,
            gems = 12,
            hammer = GameConstants.HAMMERS.WARRIOR
        },
        spawnPosition = Vector3.new(0, 15, 0),
        finishPosition = Vector3.new(700, 40, 0)
    },
    [4] = {
        name = "Ciudad Cyberpunk",
        description = "Una ciudad futurista con plataformas holográficas y obstáculos tecnológicos",
        difficulty = 4,
        estimatedTime = 540, -- 9 minutos
        unlockRequirement = 3, -- Requiere completar nivel 3
        rewards = {
            coins = 125,
            gems = 15,
            hammer = GameConstants.HAMMERS.CODED
        },
        spawnPosition = Vector3.new(0, 20, 0),
        finishPosition = Vector3.new(800, 50, 0)
    },
    [5] = {
        name = "Reino Celestial",
        description = "Un reino en las nubes con plataformas flotantes y vientos traicioneros",
        difficulty = 5,
        estimatedTime = 600, -- 10 minutos
        unlockRequirement = 4, -- Requiere completar nivel 4
        rewards = {
            coins = 150,
            gems = 20,
            hammer = GameConstants.HAMMERS.DIVINE
        },
        spawnPosition = Vector3.new(0, 100, 0),
        finishPosition = Vector3.new(900, 120, 0)
    },
    [6] = {
        name = "Reino del Troll",
        description = "El nivel más difícil con trampas, ilusiones y desafíos imposibles",
        difficulty = 6,
        estimatedTime = 900, -- 15 minutos
        unlockRequirement = 5, -- Requiere completar nivel 5
        rewards = {
            coins = 200,
            gems = 30,
            trollTokens = 1
        },
        spawnPosition = Vector3.new(0, 25, 0),
        finishPosition = Vector3.new(1000, 60, 0)
    }
}

-- Tabla para almacenar el progreso de tiempo por jugador
local PlayerLevelTimes = {}

-- Función para obtener configuración de un nivel
function LevelManager.GetLevelConfig(level)
    return LevelConfigs[level]
end

-- Función para verificar si un jugador puede acceder a un nivel
function LevelManager.CanAccessLevel(player, level)
    local playerData = PlayerDataManager.GetPlayerData(player)
    if not playerData then return false end
    
    local levelConfig = LevelManager.GetLevelConfig(level)
    if not levelConfig then return false end
    
    -- Si no tiene requisito de desbloqueo, siempre está disponible
    if not levelConfig.unlockRequirement then
        return true
    end
    
    -- Verificar si el nivel requerido está completado
    return playerData.Progress.UnlockedLevels[levelConfig.unlockRequirement] == true
end

-- Función para teleportar jugador a un nivel
function LevelManager.TeleportToLevel(player, level)
    if not LevelManager.CanAccessLevel(player, level) then
        warn("Jugador " .. player.Name .. " no puede acceder al nivel " .. level)
        return false
    end
    
    local levelConfig = LevelManager.GetLevelConfig(level)
    if not levelConfig then return false end
    
    local character = player.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    -- Teleportar al jugador
    rootPart.CFrame = CFrame.new(levelConfig.spawnPosition)
    
    -- Iniciar temporizador de nivel
    PlayerLevelTimes[player.UserId] = {
        level = level,
        startTime = tick(),
        checkpoints = {}
    }
    
    print("Jugador " .. player.Name .. " teleportado al nivel " .. level)
    return true
end

-- Función para registrar completado de nivel
function LevelManager.RegisterLevelCompletion(player, level)
    local userId = player.UserId
    local levelTime = PlayerLevelTimes[userId]
    
    if not levelTime or levelTime.level ~= level then
        warn("No se encontró tiempo de inicio para el nivel " .. level)
        return false
    end
    
    local completionTime = tick() - levelTime.startTime
    local levelConfig = LevelManager.GetLevelConfig(level)
    
    if not levelConfig then return false end
    
    -- Registrar completado en datos del jugador
    PlayerDataManager.RegisterLevelCompletion(player, level, completionTime)
    
    -- Dar recompensas
    PlayerDataManager.AddCoins(player, levelConfig.rewards.coins)
    PlayerDataManager.AddGems(player, levelConfig.rewards.gems)
    
    if levelConfig.rewards.hammer then
        PlayerDataManager.AddHammerToPlayer(player, levelConfig.rewards.hammer)
    end
    
    if levelConfig.rewards.trollTokens then
        -- TODO: Implementar sistema de troll tokens
        print("Troll tokens otorgados: " .. levelConfig.rewards.trollTokens)
    end
    
    -- Verificar logros
    LevelManager.CheckLevelAchievements(player, level, completionTime)
    
    -- Limpiar tiempo de nivel
    PlayerLevelTimes[userId] = nil
    
    print("Nivel " .. level .. " completado por " .. player.Name .. " en " .. completionTime .. " segundos")
    return true
end

-- Función para verificar logros de nivel
function LevelManager.CheckLevelAchievements(player, level, completionTime)
    local playerData = PlayerDataManager.GetPlayerData(player)
    if not playerData then return end
    
    local levelConfig = LevelManager.GetLevelConfig(level)
    if not levelConfig then return end
    
    -- Logro de velocidad
    if completionTime < (levelConfig.estimatedTime * 0.7) then -- 30% más rápido
        local achievementId = "SpeedDemon_" .. level
        if not playerData.Achievements[achievementId] then
            playerData.Achievements[achievementId] = true
            PlayerDataManager.AddCoins(player, 25)
            PlayerDataManager.AddGems(player, 2)
            print("Logro desbloqueado: SpeedDemon_" .. level .. " para " .. player.Name)
        end
    end
    
    -- Logro sin muerte
    local deathsInLevel = playerData.Statistics.DeathsPerLevel["Level" .. level] or 0
    if deathsInLevel == 0 then
        local achievementId = "NoDeathRun_" .. level
        if not playerData.Achievements[achievementId] then
            playerData.Achievements[achievementId] = true
            PlayerDataManager.AddCoins(player, 50)
            PlayerDataManager.AddGems(player, 5)
            print("Logro desbloqueado: NoDeathRun_" .. level .. " para " .. player.Name)
        end
    end
end

-- Función para obtener el tiempo actual de un jugador en un nivel
function LevelManager.GetPlayerLevelTime(player, level)
    local userId = player.UserId
    local levelTime = PlayerLevelTimes[userId]
    
    if levelTime and levelTime.level == level then
        return tick() - levelTime.startTime
    end
    
    return 0
end

-- Función para obtener el mejor tiempo de un jugador en un nivel
function LevelManager.GetPlayerBestTime(player, level)
    local playerData = PlayerDataManager.GetPlayerData(player)
    if not playerData then return nil end
    
    return playerData.Statistics.BestTimes["Level" .. level]
end

-- Función para obtener todos los niveles desbloqueados de un jugador
function LevelManager.GetUnlockedLevels(player)
    local playerData = PlayerDataManager.GetPlayerData(player)
    if not playerData then return {} end
    
    local unlockedLevels = {}
    for level, isUnlocked in ipairs(playerData.Progress.UnlockedLevels) do
        if isUnlocked then
            table.insert(unlockedLevels, level)
        end
    end
    
    return unlockedLevels
end

-- Función para obtener el nivel actual recomendado para un jugador
function LevelManager.GetRecommendedLevel(player)
    local playerData = PlayerDataManager.GetPlayerData(player)
    if not playerData then return 1 end
    
    return playerData.Progress.CurrentLevel
end

-- Función para reiniciar progreso de un jugador (para testing)
function LevelManager.ResetPlayerProgress(player)
    local userId = player.UserId
    PlayerLevelTimes[userId] = nil
    
    -- TODO: Implementar reset completo de datos del jugador
    print("Progreso reiniciado para " .. player.Name)
end

-- Función para obtener estadísticas de un nivel
function LevelManager.GetLevelStats(player, level)
    local playerData = PlayerDataManager.GetPlayerData(player)
    if not playerData then return nil end
    
    return {
        bestTime = playerData.Statistics.BestTimes["Level" .. level],
        deaths = playerData.Statistics.DeathsPerLevel["Level" .. level] or 0,
        completed = playerData.Statistics.LevelCompletionTimes["Level" .. level] ~= nil,
        checkpoints = playerData.Progress.CheckpointsReached["Level" .. level] or {}
    }
end

-- Limpiar datos cuando el jugador sale
Players.PlayerRemoving:Connect(function(player)
    local userId = player.UserId
    PlayerLevelTimes[userId] = nil
end)

return LevelManager 