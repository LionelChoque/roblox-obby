-- RankingSystem.server.lua
-- Sistema de ranking y leaderboards para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

-- DataStores para ranking
local RankingDataStore = DataStoreService:GetDataStore("ObbyRanking")
local LevelRecordsDataStore = DataStoreService:GetDataStore("ObbyLevelRecords")

local RankingSystem = {}

-- Estructura de datos de ranking
local GlobalRanking = {
    TopPlayers = {},
    LevelRecords = {},
    WeeklyStats = {},
    MonthlyStats = {}
}

-- Tipos de ranking
local RankingTypes = {
    GLOBAL = "global",
    LEVEL = "level",
    WEEKLY = "weekly",
    MONTHLY = "monthly"
}

-- Función para inicializar el sistema de ranking
function RankingSystem.Initialize()
    print("Inicializando sistema de ranking...")
    
    -- Cargar datos de ranking global
    local success, globalData = pcall(function()
        return RankingDataStore:GetAsync("GlobalRanking")
    end)
    
    if success and globalData then
        GlobalRanking.TopPlayers = globalData.TopPlayers or {}
        GlobalRanking.WeeklyStats = globalData.WeeklyStats or {}
        GlobalRanking.MonthlyStats = globalData.MonthlyStats or {}
    end
    
    -- Cargar récords de niveles
    local success2, levelData = pcall(function()
        return LevelRecordsDataStore:GetAsync("LevelRecords")
    end)
    
    if success2 and levelData then
        GlobalRanking.LevelRecords = levelData
    end
    
    print("Sistema de ranking inicializado correctamente")
end

-- Función para actualizar ranking de un jugador
function RankingSystem.UpdatePlayerRanking(player, levelNumber, completionTime, deaths, checkpoints)
    local playerData = {
        UserId = player.UserId,
        Username = player.Name,
        Level = levelNumber,
        Time = completionTime,
        Deaths = deaths,
        Checkpoints = checkpoints,
        Timestamp = os.time(),
        Date = os.date("%Y-%m-%d")
    }
    
    -- Actualizar ranking global
    RankingSystem.UpdateGlobalRanking(playerData)
    
    -- Actualizar récord del nivel
    RankingSystem.UpdateLevelRecord(playerData)
    
    -- Actualizar estadísticas semanales y mensuales
    RankingSystem.UpdateWeeklyStats(playerData)
    RankingSystem.UpdateMonthlyStats(playerData)
    
    -- Guardar datos
    RankingSystem.SaveRankingData()
    
    return RankingSystem.GetPlayerRank(player.UserId)
end

-- Función para actualizar ranking global
function RankingSystem.UpdateGlobalRanking(playerData)
    local playerId = playerData.UserId
    
    -- Buscar si el jugador ya existe en el ranking
    local existingIndex = nil
    for i, entry in ipairs(GlobalRanking.TopPlayers) do
        if entry.UserId == playerId then
            existingIndex = i
            break
        end
    end
    
    -- Calcular puntuación del jugador
    local score = RankingSystem.CalculateScore(playerData)
    
    if existingIndex then
        -- Actualizar entrada existente si la nueva puntuación es mejor
        if score > GlobalRanking.TopPlayers[existingIndex].Score then
            GlobalRanking.TopPlayers[existingIndex] = {
                UserId = playerData.UserId,
                Username = playerData.Username,
                Score = score,
                BestLevel = playerData.Level,
                BestTime = playerData.Time,
                TotalDeaths = playerData.Deaths,
                LastUpdated = playerData.Timestamp
            }
        end
    else
        -- Agregar nueva entrada
        table.insert(GlobalRanking.TopPlayers, {
            UserId = playerData.UserId,
            Username = playerData.Username,
            Score = score,
            BestLevel = playerData.Level,
            BestTime = playerData.Time,
            TotalDeaths = playerData.Deaths,
            LastUpdated = playerData.Timestamp
        })
    end
    
    -- Ordenar ranking por puntuación
    table.sort(GlobalRanking.TopPlayers, function(a, b)
        return a.Score > b.Score
    end)
    
    -- Mantener solo los top 100 jugadores
    if #GlobalRanking.TopPlayers > 100 then
        for i = 101, #GlobalRanking.TopPlayers do
            GlobalRanking.TopPlayers[i] = nil
        end
    end
end

-- Función para actualizar récord de nivel
function RankingSystem.UpdateLevelRecord(playerData)
    local levelKey = "Level" .. playerData.Level
    
    if not GlobalRanking.LevelRecords[levelKey] then
        GlobalRanking.LevelRecords[levelKey] = {}
    end
    
    local levelRecords = GlobalRanking.LevelRecords[levelKey]
    
    -- Buscar si el jugador ya tiene un récord en este nivel
    local existingIndex = nil
    for i, record in ipairs(levelRecords) do
        if record.UserId == playerData.UserId then
            existingIndex = i
            break
        end
    end
    
    if existingIndex then
        -- Actualizar récord si el nuevo tiempo es mejor
        if playerData.Time < levelRecords[existingIndex].Time then
            levelRecords[existingIndex] = {
                UserId = playerData.UserId,
                Username = playerData.Username,
                Time = playerData.Time,
                Deaths = playerData.Deaths,
                Checkpoints = playerData.Checkpoints,
                Date = playerData.Date
            }
        end
    else
        -- Agregar nuevo récord
        table.insert(levelRecords, {
            UserId = playerData.UserId,
            Username = playerData.Username,
            Time = playerData.Time,
            Deaths = playerData.Deaths,
            Checkpoints = playerData.Checkpoints,
            Date = playerData.Date
        })
    end
    
    -- Ordenar récords por tiempo
    table.sort(levelRecords, function(a, b)
        return a.Time < b.Time
    end)
    
    -- Mantener solo los top 50 récords por nivel
    if #levelRecords > 50 then
        for i = 51, #levelRecords do
            levelRecords[i] = nil
        end
    end
end

-- Función para actualizar estadísticas semanales
function RankingSystem.UpdateWeeklyStats(playerData)
    local weekKey = os.date("%Y-W%V")
    
    if not GlobalRanking.WeeklyStats[weekKey] then
        GlobalRanking.WeeklyStats[weekKey] = {}
    end
    
    local weekStats = GlobalRanking.WeeklyStats[weekKey]
    
    -- Buscar jugador en estadísticas semanales
    local existingIndex = nil
    for i, stat in ipairs(weekStats) do
        if stat.UserId == playerData.UserId then
            existingIndex = i
            break
        end
    end
    
    if existingIndex then
        -- Actualizar estadísticas existentes
        weekStats[existingIndex].LevelsCompleted = weekStats[existingIndex].LevelsCompleted + 1
        weekStats[existingIndex].TotalTime = weekStats[existingIndex].TotalTime + playerData.Time
        weekStats[existingIndex].TotalDeaths = weekStats[existingIndex].TotalDeaths + playerData.Deaths
        if playerData.Level > weekStats[existingIndex].HighestLevel then
            weekStats[existingIndex].HighestLevel = playerData.Level
        end
    else
        -- Agregar nuevas estadísticas
        table.insert(weekStats, {
            UserId = playerData.UserId,
            Username = playerData.Username,
            LevelsCompleted = 1,
            TotalTime = playerData.Time,
            TotalDeaths = playerData.Deaths,
            HighestLevel = playerData.Level
        })
    end
    
    -- Ordenar por niveles completados
    table.sort(weekStats, function(a, b)
        return a.LevelsCompleted > b.LevelsCompleted
    end)
end

-- Función para actualizar estadísticas mensuales
function RankingSystem.UpdateMonthlyStats(playerData)
    local monthKey = os.date("%Y-%m")
    
    if not GlobalRanking.MonthlyStats[monthKey] then
        GlobalRanking.MonthlyStats[monthKey] = {}
    end
    
    local monthStats = GlobalRanking.MonthlyStats[monthKey]
    
    -- Buscar jugador en estadísticas mensuales
    local existingIndex = nil
    for i, stat in ipairs(monthStats) do
        if stat.UserId == playerData.UserId then
            existingIndex = i
            break
        end
    end
    
    if existingIndex then
        -- Actualizar estadísticas existentes
        monthStats[existingIndex].LevelsCompleted = monthStats[existingIndex].LevelsCompleted + 1
        monthStats[existingIndex].TotalTime = monthStats[existingIndex].TotalTime + playerData.Time
        monthStats[existingIndex].TotalDeaths = monthStats[existingIndex].TotalDeaths + playerData.Deaths
        if playerData.Level > monthStats[existingIndex].HighestLevel then
            monthStats[existingIndex].HighestLevel = playerData.Level
        end
    else
        -- Agregar nuevas estadísticas
        table.insert(monthStats, {
            UserId = playerData.UserId,
            Username = playerData.Username,
            LevelsCompleted = 1,
            TotalTime = playerData.Time,
            TotalDeaths = playerData.Deaths,
            HighestLevel = playerData.Level
        })
    end
    
    -- Ordenar por niveles completados
    table.sort(monthStats, function(a, b)
        return a.LevelsCompleted > b.LevelsCompleted
    end)
end

-- Función para calcular puntuación del jugador
function RankingSystem.CalculateScore(playerData)
    local baseScore = playerData.Level * 1000
    local timeBonus = math.max(0, 300 - playerData.Time) * 10 -- Bonus por tiempo rápido
    local deathPenalty = playerData.Deaths * 50 -- Penalización por muertes
    local checkpointBonus = playerData.Checkpoints * 25 -- Bonus por checkpoints
    
    return baseScore + timeBonus - deathPenalty + checkpointBonus
end

-- Función para obtener ranking de un jugador
function RankingSystem.GetPlayerRank(userId)
    for i, player in ipairs(GlobalRanking.TopPlayers) do
        if player.UserId == userId then
            return {
                Rank = i,
                Score = player.Score,
                BestLevel = player.BestLevel,
                BestTime = player.BestTime,
                TotalDeaths = player.TotalDeaths
            }
        end
    end
    
    return nil
end

-- Función para obtener top jugadores
function RankingSystem.GetTopPlayers(limit)
    limit = limit or 10
    local topPlayers = {}
    
    for i = 1, math.min(limit, #GlobalRanking.TopPlayers) do
        table.insert(topPlayers, {
            Rank = i,
            UserId = GlobalRanking.TopPlayers[i].UserId,
            Username = GlobalRanking.TopPlayers[i].Username,
            Score = GlobalRanking.TopPlayers[i].Score,
            BestLevel = GlobalRanking.TopPlayers[i].BestLevel,
            BestTime = GlobalRanking.TopPlayers[i].BestTime
        })
    end
    
    return topPlayers
end

-- Función para obtener récords de un nivel
function RankingSystem.GetLevelRecords(levelNumber, limit)
    limit = limit or 10
    local levelKey = "Level" .. levelNumber
    local records = GlobalRanking.LevelRecords[levelKey] or {}
    local topRecords = {}
    
    for i = 1, math.min(limit, #records) do
        table.insert(topRecords, {
            Rank = i,
            UserId = records[i].UserId,
            Username = records[i].Username,
            Time = records[i].Time,
            Deaths = records[i].Deaths,
            Checkpoints = records[i].Checkpoints,
            Date = records[i].Date
        })
    end
    
    return topRecords
end

-- Función para obtener estadísticas semanales
function RankingSystem.GetWeeklyStats(limit)
    limit = limit or 10
    local currentWeek = os.date("%Y-W%V")
    local weekStats = GlobalRanking.WeeklyStats[currentWeek] or {}
    local topStats = {}
    
    for i = 1, math.min(limit, #weekStats) do
        table.insert(topStats, {
            Rank = i,
            UserId = weekStats[i].UserId,
            Username = weekStats[i].Username,
            LevelsCompleted = weekStats[i].LevelsCompleted,
            TotalTime = weekStats[i].TotalTime,
            TotalDeaths = weekStats[i].TotalDeaths,
            HighestLevel = weekStats[i].HighestLevel
        })
    end
    
    return topStats
end

-- Función para obtener estadísticas mensuales
function RankingSystem.GetMonthlyStats(limit)
    limit = limit or 10
    local currentMonth = os.date("%Y-%m")
    local monthStats = GlobalRanking.MonthlyStats[currentMonth] or {}
    local topStats = {}
    
    for i = 1, math.min(limit, #monthStats) do
        table.insert(topStats, {
            Rank = i,
            UserId = monthStats[i].UserId,
            Username = monthStats[i].Username,
            LevelsCompleted = monthStats[i].LevelsCompleted,
            TotalTime = monthStats[i].TotalTime,
            TotalDeaths = monthStats[i].TotalDeaths,
            HighestLevel = monthStats[i].HighestLevel
        })
    end
    
    return topStats
end

-- Función para guardar datos de ranking
function RankingSystem.SaveRankingData()
    local success, error = pcall(function()
        RankingDataStore:SetAsync("GlobalRanking", {
            TopPlayers = GlobalRanking.TopPlayers,
            WeeklyStats = GlobalRanking.WeeklyStats,
            MonthlyStats = GlobalRanking.MonthlyStats
        })
        
        LevelRecordsDataStore:SetAsync("LevelRecords", GlobalRanking.LevelRecords)
    end)
    
    if success then
        print("Datos de ranking guardados correctamente")
    else
        warn("Error al guardar datos de ranking:", error)
    end
end

-- Función para limpiar datos antiguos
function RankingSystem.CleanupOldData()
    local currentTime = os.time()
    local weekAgo = currentTime - (7 * 24 * 60 * 60)
    local monthAgo = currentTime - (30 * 24 * 60 * 60)
    
    -- Limpiar estadísticas semanales antiguas
    for weekKey, weekStats in pairs(GlobalRanking.WeeklyStats) do
        local weekTime = os.time(weekKey:gsub("W", ""))
        if weekTime < weekAgo then
            GlobalRanking.WeeklyStats[weekKey] = nil
        end
    end
    
    -- Limpiar estadísticas mensuales antiguas
    for monthKey, monthStats in pairs(GlobalRanking.MonthlyStats) do
        local monthTime = os.time(monthKey .. "-01")
        if monthTime < monthAgo then
            GlobalRanking.MonthlyStats[monthKey] = nil
        end
    end
    
    print("Datos antiguos de ranking limpiados")
end

-- Función para obtener estadísticas completas de un jugador
function RankingSystem.GetPlayerStats(userId)
    local globalRank = RankingSystem.GetPlayerRank(userId)
    local levelRecords = {}
    
    -- Obtener récords de todos los niveles
    for level = 1, GameConstants.LEVELS.TOTAL_LEVELS do
        local records = RankingSystem.GetLevelRecords(level, 50)
        for _, record in ipairs(records) do
            if record.UserId == userId then
                levelRecords[level] = record
                break
            end
        end
    end
    
    return {
        GlobalRank = globalRank,
        LevelRecords = levelRecords
    }
end

-- Inicializar sistema
RankingSystem.Initialize()

-- Limpiar datos antiguos cada hora
spawn(function()
    while true do
        wait(3600) -- 1 hora
        RankingSystem.CleanupOldData()
    end
end)

return RankingSystem 