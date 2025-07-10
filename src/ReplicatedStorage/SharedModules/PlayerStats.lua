-- PlayerStats.lua
-- Módulo para manejar las estadísticas del jugador

local PlayerStats = {}

-- Estructura de datos del jugador
PlayerStats.DefaultData = {
    UserId = 0,
    Username = "",
    
    Progress = {
        CurrentLevel = 1,
        UnlockedLevels = {true, false, false, false, false, false},
        Hammers = {
            ["Hammer_Beginner"] = false,
            ["Hammer_Navigator"] = false,
            ["Hammer_Warrior"] = false,
            ["Hammer_Coded"] = false,
            ["Hammer_Divine"] = false
        },
        CheckpointsReached = {
            Level1 = {},
            Level2 = {},
            Level3 = {},
            Level4 = {},
            Level5 = {},
            Level6 = {}
        }
    },
    
    Statistics = {
        TotalPlayTime = 0,
        TotalDeaths = 0,
        LevelCompletionTimes = {},
        BestTimes = {},
        DeathsPerLevel = {}
    },
    
    Currency = {
        Coins = 0,
        Gems = 0,
        TrollTokens = 0
    },
    
    Inventory = {
        Skins = {"Default"},
        Trails = {"Basic_Blue"},
        Emotes = {"Wave"}
    },
    
    Achievements = {
        ["FirstBlood"] = false,
        ["SpeedDemon_1"] = false,
        ["NoDeathRun_1"] = false,
        ["HammerCollector"] = false
    },
    
    Settings = {
        MusicVolume = 0.7,
        SFXVolume = 0.8,
        CameraShake = true,
        ShowGhostRunner = true
    }
}

-- Función para crear datos iniciales del jugador
function PlayerStats.CreateNewPlayerData(userId, username)
    local newData = table.clone(PlayerStats.DefaultData)
    newData.UserId = userId
    newData.Username = username
    return newData
end

-- Función para actualizar progreso del jugador
function PlayerStats.UpdateProgress(playerData, level, checkpoint)
    if not playerData.Progress.CheckpointsReached["Level" .. level] then
        playerData.Progress.CheckpointsReached["Level" .. level] = {}
    end
    
    table.insert(playerData.Progress.CheckpointsReached["Level" .. level], checkpoint)
    
    -- Actualizar nivel actual si es mayor
    if level > playerData.Progress.CurrentLevel then
        playerData.Progress.CurrentLevel = level
    end
end

-- Función para agregar martillo
function PlayerStats.AddHammer(playerData, hammerName)
    if playerData.Progress.Hammers[hammerName] then
        playerData.Progress.Hammers[hammerName] = true
        return true
    end
    return false
end

-- Función para agregar monedas
function PlayerStats.AddCoins(playerData, amount)
    playerData.Currency.Coins = playerData.Currency.Coins + amount
end

-- Función para agregar gemas
function PlayerStats.AddGems(playerData, amount)
    playerData.Currency.Gems = playerData.Currency.Gems + amount
end

-- Función para registrar muerte
function PlayerStats.RegisterDeath(playerData, level)
    playerData.Statistics.TotalDeaths = playerData.Statistics.TotalDeaths + 1
    
    if not playerData.Statistics.DeathsPerLevel["Level" .. level] then
        playerData.Statistics.DeathsPerLevel["Level" .. level] = 0
    end
    
    playerData.Statistics.DeathsPerLevel["Level" .. level] = playerData.Statistics.DeathsPerLevel["Level" .. level] + 1
end

-- Función para registrar tiempo de completado
function PlayerStats.RegisterLevelCompletion(playerData, level, time)
    playerData.Statistics.LevelCompletionTimes["Level" .. level] = time
    
    if not playerData.Statistics.BestTimes["Level" .. level] or time < playerData.Statistics.BestTimes["Level" .. level] then
        playerData.Statistics.BestTimes["Level" .. level] = time
    end
end

return PlayerStats 