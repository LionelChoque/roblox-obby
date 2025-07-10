-- BackgroundMusic.client.lua
-- Sistema de música de fondo para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

local player = Players.LocalPlayer
local BackgroundMusic = {}

-- Estado de la música de fondo
local CurrentMusic = nil
local MusicQueue = {}
local IsPlaying = false
local CurrentLevel = nil
local CurrentArea = "lobby"

-- Configuración de música por área
local MusicConfig = {
    lobby = {
        music = "LOBBY_MUSIC",
        volume = 0.5,
        fadeIn = 2,
        fadeOut = 1
    },
    
    menu = {
        music = "MENU_MUSIC",
        volume = 0.5,
        fadeIn = 2,
        fadeOut = 1
    },
    
    forest = {
        music = "FOREST_MUSIC",
        volume = 0.4,
        fadeIn = 3,
        fadeOut = 2
    },
    
    water = {
        music = "WATER_MUSIC",
        volume = 0.4,
        fadeIn = 3,
        fadeOut = 2
    },
    
    lava = {
        music = "LAVA_MUSIC",
        volume = 0.4,
        fadeIn = 3,
        fadeOut = 2
    },
    
    cyber = {
        music = "CYBER_MUSIC",
        volume = 0.4,
        fadeIn = 3,
        fadeOut = 2
    },
    
    celestial = {
        music = "CELESTIAL_MUSIC",
        volume = 0.4,
        fadeIn = 3,
        fadeOut = 2
    },
    
    troll = {
        music = "TROLL_MUSIC",
        volume = 0.4,
        fadeIn = 3,
        fadeOut = 2
    },
    
    victory = {
        music = "VICTORY_MUSIC",
        volume = 0.6,
        fadeIn = 1,
        fadeOut = 1
    },
    
    defeat = {
        music = "DEFEAT_MUSIC",
        volume = 0.5,
        fadeIn = 1,
        fadeOut = 1
    }
}

-- Función para inicializar el sistema de música de fondo
function BackgroundMusic.Initialize()
    print("Inicializando sistema de música de fondo...")
    
    -- Configurar eventos
    BackgroundMusic.SetupEvents()
    
    -- Iniciar música de lobby
    BackgroundMusic.PlayLobbyMusic()
    
    print("Sistema de música de fondo inicializado correctamente")
end

-- Función para configurar eventos
function BackgroundMusic.SetupEvents()
    -- Evento para cambiar de área
    game.Players.PlayerAdded:Connect(function(newPlayer)
        if newPlayer == player then
            BackgroundMusic.PlayLobbyMusic()
        end
    end)
    
    -- Evento para completar nivel
    local RankingEvents = ReplicatedStorage:WaitForChild("RankingEvents")
    
    RankingEvents.LevelCompleted.OnClientEvent:Connect(function(levelNumber, time, deaths)
        BackgroundMusic.PlayVictoryMusic()
    end)
    
    RankingEvents.PlayerDied.OnClientEvent:Connect(function()
        -- No cambiar música por muerte, mantener la del nivel
    end)
    
    RankingEvents.EnterLevel.OnClientEvent:Connect(function(levelType, levelNumber)
        BackgroundMusic.PlayLevelMusic(levelType)
    end)
    
    RankingEvents.ExitLevel.OnClientEvent:Connect(function()
        BackgroundMusic.PlayLobbyMusic()
    end)
    
    RankingEvents.EnterMenu.OnClientEvent:Connect(function()
        BackgroundMusic.PlayMenuMusic()
    end)
    
    RankingEvents.ExitMenu.OnClientEvent:Connect(function()
        BackgroundMusic.PlayLobbyMusic()
    end)
end

-- Función para reproducir música de lobby
function BackgroundMusic.PlayLobbyMusic()
    BackgroundMusic.PlayMusic("lobby")
end

-- Función para reproducir música de menú
function BackgroundMusic.PlayMenuMusic()
    BackgroundMusic.PlayMusic("menu")
end

-- Función para reproducir música de nivel
function BackgroundMusic.PlayLevelMusic(levelType)
    BackgroundMusic.PlayMusic(levelType)
end

-- Función para reproducir música de victoria
function BackgroundMusic.PlayVictoryMusic()
    BackgroundMusic.PlayMusic("victory")
end

-- Función para reproducir música de derrota
function BackgroundMusic.PlayDefeatMusic()
    BackgroundMusic.PlayMusic("defeat")
end

-- Función para reproducir música
function BackgroundMusic.PlayMusic(area)
    if not MusicConfig[area] then
        warn("Configuración de música no encontrada para área:", area)
        return
    end
    
    local config = MusicConfig[area]
    
    -- Si ya estamos reproduciendo la misma música, no hacer nada
    if CurrentArea == area and IsPlaying then
        return
    end
    
    -- Detener música actual
    BackgroundMusic.StopMusic()
    
    -- Obtener música del servidor
    spawn(function()
        local RankingEvents = ReplicatedStorage:WaitForChild("RankingEvents")
        local success = pcall(function()
            return RankingEvents.PlayMusic:InvokeServer(config.music, config.volume)
        end)
        
        if success then
            CurrentArea = area
            IsPlaying = true
            print("Reproduciendo música de área:", area)
        else
            warn("Error al reproducir música de área:", area)
        end
    end)
end

-- Función para detener música
function BackgroundMusic.StopMusic()
    if IsPlaying then
        spawn(function()
            local RankingEvents = ReplicatedStorage:WaitForChild("RankingEvents")
            local success = pcall(function()
                return RankingEvents.StopMusic:InvokeServer()
            end)
            
            if success then
                IsPlaying = false
                print("Música detenida")
            else
                warn("Error al detener música")
            end
        end)
    end
end

-- Función para pausar música
function BackgroundMusic.PauseMusic()
    if CurrentMusic then
        CurrentMusic:Pause()
        IsPlaying = false
    end
end

-- Función para reanudar música
function BackgroundMusic.ResumeMusic()
    if CurrentMusic and not IsPlaying then
        CurrentMusic:Resume()
        IsPlaying = true
    end
end

-- Función para cambiar volumen
function BackgroundMusic.SetVolume(volume)
    if CurrentMusic then
        local tween = TweenService:Create(CurrentMusic, TweenInfo.new(1), {
            Volume = volume
        })
        tween:Play()
    end
end

-- Función para fade in
function BackgroundMusic.FadeIn(duration)
    if CurrentMusic then
        CurrentMusic.Volume = 0
        local tween = TweenService:Create(CurrentMusic, TweenInfo.new(duration), {
            Volume = MusicConfig[CurrentArea].volume
        })
        tween:Play()
    end
end

-- Función para fade out
function BackgroundMusic.FadeOut(duration)
    if CurrentMusic then
        local tween = TweenService:Create(CurrentMusic, TweenInfo.new(duration), {
            Volume = 0
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            BackgroundMusic.StopMusic()
        end)
    end
end

-- Función para agregar música a la cola
function BackgroundMusic.QueueMusic(area)
    table.insert(MusicQueue, area)
    
    -- Si no hay música reproduciéndose, reproducir la primera de la cola
    if not IsPlaying then
        BackgroundMusic.PlayNextInQueue()
    end
end

-- Función para reproducir siguiente música en la cola
function BackgroundMusic.PlayNextInQueue()
    if #MusicQueue > 0 then
        local nextArea = table.remove(MusicQueue, 1)
        BackgroundMusic.PlayMusic(nextArea)
    end
end

-- Función para limpiar cola de música
function BackgroundMusic.ClearQueue()
    MusicQueue = {}
end

-- Función para obtener información de la música actual
function BackgroundMusic.GetCurrentMusicInfo()
    return {
        Area = CurrentArea,
        IsPlaying = IsPlaying,
        QueueLength = #MusicQueue,
        Config = MusicConfig[CurrentArea]
    }
end

-- Función para obtener configuración de música
function BackgroundMusic.GetMusicConfig()
    return MusicConfig
end

-- Función para establecer configuración de música
function BackgroundMusic.SetMusicConfig(area, config)
    if MusicConfig[area] then
        for key, value in pairs(config) do
            MusicConfig[area][key] = value
        end
    else
        MusicConfig[area] = config
    end
end

-- Función para reproducir música personalizada
function BackgroundMusic.PlayCustomMusic(musicName, volume, fadeIn, fadeOut)
    local customConfig = {
        music = musicName,
        volume = volume or 0.5,
        fadeIn = fadeIn or 2,
        fadeOut = fadeOut or 1
    }
    
    -- Guardar configuración temporal
    local tempArea = "custom"
    MusicConfig[tempArea] = customConfig
    
    -- Reproducir música
    BackgroundMusic.PlayMusic(tempArea)
    
    -- Limpiar configuración temporal después de un tiempo
    spawn(function()
        wait(10)
        MusicConfig[tempArea] = nil
    end)
end

-- Función para obtener estadísticas de música
function BackgroundMusic.GetMusicStats()
    return {
        CurrentArea = CurrentArea,
        IsPlaying = IsPlaying,
        QueueLength = #MusicQueue,
        TotalAreas = #MusicConfig,
        CurrentVolume = CurrentMusic and CurrentMusic.Volume or 0
    }
end

-- Función para limpiar recursos
function BackgroundMusic.Cleanup()
    BackgroundMusic.StopMusic()
    BackgroundMusic.ClearQueue()
    CurrentArea = nil
    IsPlaying = false
end

-- Inicializar sistema
BackgroundMusic.Initialize()

return BackgroundMusic 