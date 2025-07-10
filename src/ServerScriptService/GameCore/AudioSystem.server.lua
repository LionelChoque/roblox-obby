-- AudioSystem.server.lua
-- Sistema de audio del servidor para el juego Obby de las Dimensiones

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

-- Eventos remotos
local RankingEvents = ReplicatedStorage:WaitForChild("RankingEvents")

local AudioSystem = {}

-- Estado del sistema de audio
local AudioSettings = {
    MasterVolume = 1.0,
    MusicVolume = 0.7,
    SFXVolume = 0.8,
    VoiceVolume = 0.6,
    AmbientVolume = 0.5
}

-- Configuración de sonidos
local SoundConfig = {
    -- Efectos de sonido básicos
    JUMP = {
        SoundId = "rbxassetid://131147196",
        Volume = 0.5,
        Pitch = 1.0,
        Looped = false
    },
    
    DEATH = {
        SoundId = "rbxassetid://131147197",
        Volume = 0.6,
        Pitch = 1.0,
        Looped = false
    },
    
    COIN_COLLECT = {
        SoundId = "rbxassetid://131147198",
        Volume = 0.4,
        Pitch = 1.0,
        Looped = false
    },
    
    GEM_COLLECT = {
        SoundId = "rbxassetid://131147199",
        Volume = 0.5,
        Pitch = 1.0,
        Looped = false
    },
    
    CHECKPOINT = {
        SoundId = "rbxassetid://131147200",
        Volume = 0.6,
        Pitch = 1.0,
        Looped = false
    },
    
    HAMMER_COLLECT = {
        SoundId = "rbxassetid://131147201",
        Volume = 0.5,
        Pitch = 1.0,
        Looped = false
    },
    
    LEVEL_COMPLETE = {
        SoundId = "rbxassetid://131147202",
        Volume = 0.8,
        Pitch = 1.0,
        Looped = false
    },
    
    BUTTON_CLICK = {
        SoundId = "rbxassetid://131147203",
        Volume = 0.3,
        Pitch = 1.0,
        Looped = false
    },
    
    ERROR_SOUND = {
        SoundId = "rbxassetid://131147204",
        Volume = 0.4,
        Pitch = 1.0,
        Looped = false
    },
    
    SUCCESS_SOUND = {
        SoundId = "rbxassetid://131147205",
        Volume = 0.5,
        Pitch = 1.0,
        Looped = false
    },
    
    -- Sonidos de ambiente
    AMBIENT_FOREST = {
        SoundId = "rbxassetid://131147206",
        Volume = 0.3,
        Pitch = 1.0,
        Looped = true
    },
    
    AMBIENT_WATER = {
        SoundId = "rbxassetid://131147207",
        Volume = 0.3,
        Pitch = 1.0,
        Looped = true
    },
    
    AMBIENT_LAVA = {
        SoundId = "rbxassetid://131147208",
        Volume = 0.3,
        Pitch = 1.0,
        Looped = true
    },
    
    AMBIENT_CYBER = {
        SoundId = "rbxassetid://131147209",
        Volume = 0.3,
        Pitch = 1.0,
        Looped = true
    },
    
    AMBIENT_CELESTIAL = {
        SoundId = "rbxassetid://131147210",
        Volume = 0.3,
        Pitch = 1.0,
        Looped = true
    },
    
    AMBIENT_TROLL = {
        SoundId = "rbxassetid://131147211",
        Volume = 0.3,
        Pitch = 1.0,
        Looped = true
    }
}

-- Configuración de música
local MusicConfig = {
    -- Música de fondo por nivel
    FOREST_MUSIC = {
        SoundId = "rbxassetid://131147212",
        Volume = 0.4,
        Pitch = 1.0,
        Looped = true
    },
    
    WATER_MUSIC = {
        SoundId = "rbxassetid://131147213",
        Volume = 0.4,
        Pitch = 1.0,
        Looped = true
    },
    
    LAVA_MUSIC = {
        SoundId = "rbxassetid://131147214",
        Volume = 0.4,
        Pitch = 1.0,
        Looped = true
    },
    
    CYBER_MUSIC = {
        SoundId = "rbxassetid://131147215",
        Volume = 0.4,
        Pitch = 1.0,
        Looped = true
    },
    
    CELESTIAL_MUSIC = {
        SoundId = "rbxassetid://131147216",
        Volume = 0.4,
        Pitch = 1.0,
        Looped = true
    },
    
    TROLL_MUSIC = {
        SoundId = "rbxassetid://131147217",
        Volume = 0.4,
        Pitch = 1.0,
        Looped = true
    },
    
    -- Música de menú
    MENU_MUSIC = {
        SoundId = "rbxassetid://131147218",
        Volume = 0.5,
        Pitch = 1.0,
        Looped = true
    },
    
    LOBBY_MUSIC = {
        SoundId = "rbxassetid://131147219",
        Volume = 0.5,
        Pitch = 1.0,
        Looped = true
    },
    
    VICTORY_MUSIC = {
        SoundId = "rbxassetid://131147220",
        Volume = 0.6,
        Pitch = 1.0,
        Looped = false
    },
    
    DEFEAT_MUSIC = {
        SoundId = "rbxassetid://131147221",
        Volume = 0.5,
        Pitch = 1.0,
        Looped = false
    }
}

-- Función para inicializar el sistema de audio
function AudioSystem.Initialize()
    print("Inicializando sistema de audio...")
    
    -- Configurar eventos remotos
    AudioSystem.SetupRemoteEvents()
    
    -- Crear sonidos globales
    AudioSystem.CreateGlobalSounds()
    
    print("Sistema de audio inicializado correctamente")
end

-- Función para configurar eventos remotos
function AudioSystem.SetupRemoteEvents()
    -- Función para reproducir sonido
    RankingEvents.PlaySound.OnServerEvent:Connect(function(player, soundName, volume, pitch)
        AudioSystem.PlaySound(player, soundName, volume, pitch)
    end)
    
    -- Función para reproducir música
    RankingEvents.PlayMusic.OnServerEvent:Connect(function(player, musicName, volume, pitch)
        AudioSystem.PlayMusic(player, musicName, volume, pitch)
    end)
    
    -- Función para detener música
    RankingEvents.StopMusic.OnServerEvent:Connect(function(player)
        AudioSystem.StopMusic(player)
    end)
    
    -- Función para actualizar configuración de audio
    RankingEvents.UpdateAudioSettings.OnServerEvent:Connect(function(player, settings)
        AudioSystem.UpdatePlayerAudioSettings(player, settings)
    end)
    
    -- Función para obtener configuración de audio
    RankingEvents.GetAudioSettings.OnServerInvoke = function(player)
        return AudioSystem.GetPlayerAudioSettings(player)
    end
end

-- Función para crear sonidos globales
function AudioSystem.CreateGlobalSounds()
    -- Crear carpeta para sonidos globales
    local globalSounds = Instance.new("Folder")
    globalSounds.Name = "GlobalSounds"
    globalSounds.Parent = ReplicatedStorage
    
    -- Crear sonidos básicos
    for soundName, config in pairs(SoundConfig) do
        local sound = Instance.new("Sound")
        sound.Name = soundName
        sound.SoundId = config.SoundId
        sound.Volume = config.Volume * AudioSettings.SFXVolume
        sound.Pitch = config.Pitch
        sound.Looped = config.Looped
        sound.Parent = globalSounds
    end
    
    -- Crear carpeta para música
    local globalMusic = Instance.new("Folder")
    globalMusic.Name = "GlobalMusic"
    globalMusic.Parent = ReplicatedStorage
    
    -- Crear música
    for musicName, config in pairs(MusicConfig) do
        local music = Instance.new("Sound")
        music.Name = musicName
        music.SoundId = config.SoundId
        music.Volume = config.Volume * AudioSettings.MusicVolume
        music.Pitch = config.Pitch
        music.Looped = config.Looped
        music.Parent = globalMusic
    end
end

-- Función para reproducir sonido
function AudioSystem.PlaySound(player, soundName, volume, pitch)
    if not SoundConfig[soundName] then
        warn("Sonido no encontrado:", soundName)
        return
    end
    
    local sound = ReplicatedStorage.GlobalSounds:FindFirstChild(soundName)
    if not sound then
        warn("Sonido no encontrado en GlobalSounds:", soundName)
        return
    end
    
    -- Aplicar configuración personalizada
    if volume then
        sound.Volume = volume * AudioSettings.SFXVolume
    end
    
    if pitch then
        sound.Pitch = pitch
    end
    
    -- Reproducir sonido para el jugador
    RankingEvents.PlaySoundClient:FireClient(player, soundName, sound.Volume, sound.Pitch)
end

-- Función para reproducir música
function AudioSystem.PlayMusic(player, musicName, volume, pitch)
    if not MusicConfig[musicName] then
        warn("Música no encontrada:", musicName)
        return
    end
    
    local music = ReplicatedStorage.GlobalMusic:FindFirstChild(musicName)
    if not music then
        warn("Música no encontrada en GlobalMusic:", musicName)
        return
    end
    
    -- Aplicar configuración personalizada
    if volume then
        music.Volume = volume * AudioSettings.MusicVolume
    end
    
    if pitch then
        music.Pitch = pitch
    end
    
    -- Reproducir música para el jugador
    RankingEvents.PlayMusicClient:FireClient(player, musicName, music.Volume, music.Pitch)
end

-- Función para detener música
function AudioSystem.StopMusic(player)
    RankingEvents.StopMusicClient:FireClient(player)
end

-- Función para reproducir sonido de ambiente
function AudioSystem.PlayAmbientSound(player, levelType)
    local ambientSoundName = "AMBIENT_" .. string.upper(levelType)
    
    if SoundConfig[ambientSoundName] then
        AudioSystem.PlaySound(player, ambientSoundName, nil, nil)
    end
end

-- Función para reproducir música de nivel
function AudioSystem.PlayLevelMusic(player, levelType)
    local musicName = levelType .. "_MUSIC"
    
    if MusicConfig[musicName] then
        AudioSystem.PlayMusic(player, musicName, nil, nil)
    end
end

-- Función para reproducir sonido de muerte
function AudioSystem.PlayDeathSound(player)
    AudioSystem.PlaySound(player, "DEATH")
end

-- Función para reproducir sonido de salto
function AudioSystem.PlayJumpSound(player)
    AudioSystem.PlaySound(player, "JUMP")
end

-- Función para reproducir sonido de recolección de moneda
function AudioSystem.PlayCoinSound(player)
    AudioSystem.PlaySound(player, "COIN_COLLECT")
end

-- Función para reproducir sonido de recolección de gema
function AudioSystem.PlayGemSound(player)
    AudioSystem.PlaySound(player, "GEM_COLLECT")
end

-- Función para reproducir sonido de checkpoint
function AudioSystem.PlayCheckpointSound(player)
    AudioSystem.PlaySound(player, "CHECKPOINT")
end

-- Función para reproducir sonido de martillo
function AudioSystem.PlayHammerSound(player)
    AudioSystem.PlaySound(player, "HAMMER_COLLECT")
end

-- Función para reproducir sonido de completar nivel
function AudioSystem.PlayLevelCompleteSound(player)
    AudioSystem.PlaySound(player, "LEVEL_COMPLETE")
end

-- Función para reproducir sonido de botón
function AudioSystem.PlayButtonSound(player)
    AudioSystem.PlaySound(player, "BUTTON_CLICK")
end

-- Función para reproducir sonido de error
function AudioSystem.PlayErrorSound(player)
    AudioSystem.PlaySound(player, "ERROR_SOUND")
end

-- Función para reproducir sonido de éxito
function AudioSystem.PlaySuccessSound(player)
    AudioSystem.PlaySound(player, "SUCCESS_SOUND")
end

-- Función para reproducir música de menú
function AudioSystem.PlayMenuMusic(player)
    AudioSystem.PlayMusic(player, "MENU_MUSIC")
end

-- Función para reproducir música de lobby
function AudioSystem.PlayLobbyMusic(player)
    AudioSystem.PlayMusic(player, "LOBBY_MUSIC")
end

-- Función para reproducir música de victoria
function AudioSystem.PlayVictoryMusic(player)
    AudioSystem.PlayMusic(player, "VICTORY_MUSIC")
end

-- Función para reproducir música de derrota
function AudioSystem.PlayDefeatMusic(player)
    AudioSystem.PlayMusic(player, "DEFEAT_MUSIC")
end

-- Función para actualizar configuración de audio del jugador
function AudioSystem.UpdatePlayerAudioSettings(player, settings)
    if settings.MasterVolume then
        AudioSettings.MasterVolume = math.clamp(settings.MasterVolume, 0, 1)
    end
    
    if settings.MusicVolume then
        AudioSettings.MusicVolume = math.clamp(settings.MusicVolume, 0, 1)
    end
    
    if settings.SFXVolume then
        AudioSettings.SFXVolume = math.clamp(settings.SFXVolume, 0, 1)
    end
    
    if settings.VoiceVolume then
        AudioSettings.VoiceVolume = math.clamp(settings.VoiceVolume, 0, 1)
    end
    
    if settings.AmbientVolume then
        AudioSettings.AmbientVolume = math.clamp(settings.AmbientVolume, 0, 1)
    end
    
    -- Actualizar volúmenes de sonidos globales
    AudioSystem.UpdateGlobalSoundVolumes()
    
    print("Configuración de audio actualizada para", player.Name)
end

-- Función para obtener configuración de audio del jugador
function AudioSystem.GetPlayerAudioSettings(player)
    return {
        MasterVolume = AudioSettings.MasterVolume,
        MusicVolume = AudioSettings.MusicVolume,
        SFXVolume = AudioSettings.SFXVolume,
        VoiceVolume = AudioSettings.VoiceVolume,
        AmbientVolume = AudioSettings.AmbientVolume
    }
end

-- Función para actualizar volúmenes de sonidos globales
function AudioSystem.UpdateGlobalSoundVolumes()
    local globalSounds = ReplicatedStorage:FindFirstChild("GlobalSounds")
    if globalSounds then
        for _, sound in pairs(globalSounds:GetChildren()) do
            if sound:IsA("Sound") then
                local config = SoundConfig[sound.Name]
                if config then
                    sound.Volume = config.Volume * AudioSettings.SFXVolume * AudioSettings.MasterVolume
                end
            end
        end
    end
    
    local globalMusic = ReplicatedStorage:FindFirstChild("GlobalMusic")
    if globalMusic then
        for _, music in pairs(globalMusic:GetChildren()) do
            if music:IsA("Sound") then
                local config = MusicConfig[music.Name]
                if config then
                    music.Volume = config.Volume * AudioSettings.MusicVolume * AudioSettings.MasterVolume
                end
            end
        end
    end
end

-- Función para reproducir sonido 3D
function AudioSystem.PlaySound3D(player, soundName, position, volume, pitch)
    if not SoundConfig[soundName] then
        warn("Sonido 3D no encontrado:", soundName)
        return
    end
    
    local sound = ReplicatedStorage.GlobalSounds:FindFirstChild(soundName)
    if not sound then
        warn("Sonido 3D no encontrado en GlobalSounds:", soundName)
        return
    end
    
    -- Aplicar configuración personalizada
    local finalVolume = (volume or sound.Volume) * AudioSettings.SFXVolume
    local finalPitch = pitch or sound.Pitch
    
    -- Reproducir sonido 3D para el jugador
    RankingEvents.PlaySound3DClient:FireClient(player, soundName, position, finalVolume, finalPitch)
end

-- Función para crear sonido personalizado
function AudioSystem.CreateCustomSound(soundName, soundId, volume, pitch, looped)
    local customSound = {
        SoundId = soundId,
        Volume = volume or 0.5,
        Pitch = pitch or 1.0,
        Looped = looped or false
    }
    
    SoundConfig[soundName] = customSound
    
    -- Crear el sonido en GlobalSounds
    local globalSounds = ReplicatedStorage:FindFirstChild("GlobalSounds")
    if globalSounds then
        local sound = Instance.new("Sound")
        sound.Name = soundName
        sound.SoundId = soundId
        sound.Volume = customSound.Volume * AudioSettings.SFXVolume
        sound.Pitch = customSound.Pitch
        sound.Looped = customSound.Looped
        sound.Parent = globalSounds
    end
    
    print("Sonido personalizado creado:", soundName)
end

-- Función para crear música personalizada
function AudioSystem.CreateCustomMusic(musicName, musicId, volume, pitch, looped)
    local customMusic = {
        SoundId = musicId,
        Volume = volume or 0.5,
        Pitch = pitch or 1.0,
        Looped = looped or true
    }
    
    MusicConfig[musicName] = customMusic
    
    -- Crear la música en GlobalMusic
    local globalMusic = ReplicatedStorage:FindFirstChild("GlobalMusic")
    if globalMusic then
        local music = Instance.new("Sound")
        music.Name = musicName
        music.SoundId = musicId
        music.Volume = customMusic.Volume * AudioSettings.MusicVolume
        music.Pitch = customMusic.Pitch
        music.Looped = customMusic.Looped
        music.Parent = globalMusic
    end
    
    print("Música personalizada creada:", musicName)
end

-- Función para obtener lista de sonidos disponibles
function AudioSystem.GetAvailableSounds()
    local sounds = {}
    for soundName, _ in pairs(SoundConfig) do
        table.insert(sounds, soundName)
    end
    return sounds
end

-- Función para obtener lista de música disponible
function AudioSystem.GetAvailableMusic()
    local music = {}
    for musicName, _ in pairs(MusicConfig) do
        table.insert(music, musicName)
    end
    return music
end

-- Función para obtener estadísticas de audio
function AudioSystem.GetAudioStats()
    local globalSounds = ReplicatedStorage:FindFirstChild("GlobalSounds")
    local globalMusic = ReplicatedStorage:FindFirstChild("GlobalMusic")
    
    return {
        TotalSounds = globalSounds and #globalSounds:GetChildren() or 0,
        TotalMusic = globalMusic and #globalMusic:GetChildren() or 0,
        MasterVolume = AudioSettings.MasterVolume,
        MusicVolume = AudioSettings.MusicVolume,
        SFXVolume = AudioSettings.SFXVolume,
        VoiceVolume = AudioSettings.VoiceVolume,
        AmbientVolume = AudioSettings.AmbientVolume
    }
end

-- Inicializar sistema
AudioSystem.Initialize()

return AudioSystem 