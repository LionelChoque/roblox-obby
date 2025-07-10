-- SoundEffects.client.lua
-- Sistema de efectos de sonido para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

local player = Players.LocalPlayer
local SoundEffects = {}

-- Estado de los efectos de sonido
local ActiveEffects = {}
local EffectQueue = {}
local IsMuted = false

-- Configuración de efectos de sonido
local EffectConfig = {
    -- Efectos de movimiento
    JUMP = {
        soundId = "rbxassetid://131147196",
        volume = 0.5,
        pitch = 1.0,
        maxDistance = 50,
        priority = 1
    },
    
    LAND = {
        soundId = "rbxassetid://131147222",
        volume = 0.4,
        pitch = 1.0,
        maxDistance = 30,
        priority = 1
    },
    
    RUN = {
        soundId = "rbxassetid://131147223",
        volume = 0.3,
        pitch = 1.0,
        maxDistance = 20,
        priority = 2
    },
    
    -- Efectos de interacción
    BUTTON_PRESS = {
        soundId = "rbxassetid://131147203",
        volume = 0.3,
        pitch = 1.0,
        maxDistance = 100,
        priority = 1
    },
    
    SWITCH_TOGGLE = {
        soundId = "rbxassetid://131147224",
        volume = 0.4,
        pitch = 1.0,
        maxDistance = 80,
        priority = 1
    },
    
    DOOR_OPEN = {
        soundId = "rbxassetid://131147225",
        volume = 0.5,
        pitch = 1.0,
        maxDistance = 100,
        priority = 1
    },
    
    DOOR_CLOSE = {
        soundId = "rbxassetid://131147226",
        volume = 0.4,
        pitch = 1.0,
        maxDistance = 100,
        priority = 1
    },
    
    -- Efectos de recolección
    COIN_PICKUP = {
        soundId = "rbxassetid://131147198",
        volume = 0.4,
        pitch = 1.0,
        maxDistance = 50,
        priority = 1
    },
    
    GEM_PICKUP = {
        soundId = "rbxassetid://131147199",
        volume = 0.5,
        pitch = 1.0,
        maxDistance = 50,
        priority = 1
    },
    
    HAMMER_PICKUP = {
        soundId = "rbxassetid://131147201",
        volume = 0.5,
        pitch = 1.0,
        maxDistance = 50,
        priority = 1
    },
    
    CHECKPOINT_ACTIVATE = {
        soundId = "rbxassetid://131147200",
        volume = 0.6,
        pitch = 1.0,
        maxDistance = 100,
        priority = 1
    },
    
    -- Efectos de ambiente
    WATER_SPLASH = {
        soundId = "rbxassetid://131147227",
        volume = 0.4,
        pitch = 1.0,
        maxDistance = 60,
        priority = 2
    },
    
    FIRE_CRACKLE = {
        soundId = "rbxassetid://131147228",
        volume = 0.3,
        pitch = 1.0,
        maxDistance = 40,
        priority = 2
    },
    
    WIND_BLOW = {
        soundId = "rbxassetid://131147229",
        volume = 0.2,
        pitch = 1.0,
        maxDistance = 80,
        priority = 3
    },
    
    ELECTRIC_HUM = {
        soundId = "rbxassetid://131147230",
        volume = 0.3,
        pitch = 1.0,
        maxDistance = 50,
        priority = 2
    },
    
    -- Efectos de UI
    MENU_OPEN = {
        soundId = "rbxassetid://131147231",
        volume = 0.4,
        pitch = 1.0,
        maxDistance = 200,
        priority = 1
    },
    
    MENU_CLOSE = {
        soundId = "rbxassetid://131147232",
        volume = 0.4,
        pitch = 1.0,
        maxDistance = 200,
        priority = 1
    },
    
    NOTIFICATION = {
        soundId = "rbxassetid://131147233",
        volume = 0.3,
        pitch = 1.0,
        maxDistance = 200,
        priority = 1
    },
    
    ACHIEVEMENT = {
        soundId = "rbxassetid://131147234",
        volume = 0.6,
        pitch = 1.0,
        maxDistance = 200,
        priority = 1
    },
    
    -- Efectos de estado
    DAMAGE = {
        soundId = "rbxassetid://131147197",
        volume = 0.6,
        pitch = 1.0,
        maxDistance = 100,
        priority = 1
    },
    
    HEAL = {
        soundId = "rbxassetid://131147235",
        volume = 0.5,
        pitch = 1.0,
        maxDistance = 100,
        priority = 1
    },
    
    POWER_UP = {
        soundId = "rbxassetid://131147236",
        volume = 0.6,
        pitch = 1.0,
        maxDistance = 100,
        priority = 1
    },
    
    SHIELD_BREAK = {
        soundId = "rbxassetid://131147237",
        volume = 0.5,
        pitch = 1.0,
        maxDistance = 100,
        priority = 1
    }
}

-- Función para inicializar el sistema de efectos de sonido
function SoundEffects.Initialize()
    print("Inicializando sistema de efectos de sonido...")
    
    -- Configurar eventos
    SoundEffects.SetupEvents()
    
    -- Configurar efectos de movimiento del jugador
    SoundEffects.SetupPlayerEffects()
    
    print("Sistema de efectos de sonido inicializado correctamente")
end

-- Función para configurar eventos
function SoundEffects.SetupEvents()
    -- Eventos de recolección
    local RankingEvents = ReplicatedStorage:WaitForChild("RankingEvents")
    
    RankingEvents.CoinCollected.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("COIN_PICKUP")
    end)
    
    RankingEvents.GemCollected.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("GEM_PICKUP")
    end)
    
    RankingEvents.HammerCollected.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("HAMMER_PICKUP")
    end)
    
    RankingEvents.CheckpointActivated.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("CHECKPOINT_ACTIVATE")
    end)
    
    RankingEvents.PlayerDied.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("DAMAGE")
    end)
    
    RankingEvents.PlayerRespawned.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("HEAL")
    end)
    
    RankingEvents.PowerUpActivated.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("POWER_UP")
    end)
    
    RankingEvents.ShieldBroken.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("SHIELD_BREAK")
    end)
    
    -- Eventos de UI
    RankingEvents.MenuOpened.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("MENU_OPEN")
    end)
    
    RankingEvents.MenuClosed.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("MENU_CLOSE")
    end)
    
    RankingEvents.NotificationReceived.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("NOTIFICATION")
    end)
    
    RankingEvents.AchievementUnlocked.OnClientEvent:Connect(function()
        SoundEffects.PlayEffect("ACHIEVEMENT")
    end)
end

-- Función para configurar efectos del jugador
function SoundEffects.SetupPlayerEffects()
    local character = player.Character or player.CharacterAdded:Wait()
    
    -- Evento para cuando el personaje se mueve
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Jumping then
            SoundEffects.PlayEffect("JUMP")
        elseif new == Enum.HumanoidStateType.Landed then
            SoundEffects.PlayEffect("LAND")
        end
    end)
    
    -- Evento para cuando el personaje cambia
    player.CharacterAdded:Connect(function(newCharacter)
        local newHumanoid = newCharacter:WaitForChild("Humanoid")
        
        newHumanoid.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Jumping then
                SoundEffects.PlayEffect("JUMP")
            elseif new == Enum.HumanoidStateType.Landed then
                SoundEffects.PlayEffect("LAND")
            end
        end)
    end)
end

-- Función para reproducir efecto de sonido
function SoundEffects.PlayEffect(effectName, position, volume, pitch)
    if IsMuted then
        return
    end
    
    if not EffectConfig[effectName] then
        warn("Efecto de sonido no encontrado:", effectName)
        return
    end
    
    local config = EffectConfig[effectName]
    
    -- Crear sonido
    local sound = Instance.new("Sound")
    sound.SoundId = config.soundId
    sound.Volume = (volume or config.volume) * GameConstants.AUDIO.DEFAULT_SFX_VOLUME
    sound.Pitch = pitch or config.pitch
    sound.Parent = workspace
    
    -- Si hay posición, crear parte 3D
    if position then
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 1
        part.Position = position
        part.Parent = workspace
        
        sound.Parent = part
        
        -- Limpiar después de reproducir
        sound.Ended:Connect(function()
            part:Destroy()
        end)
        
        spawn(function()
            wait(sound.TimeLength + 0.1)
            if part then
                part:Destroy()
            end
        end)
    else
        -- Sonido 2D
        sound.Parent = SoundService
        
        -- Limpiar después de reproducir
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
        
        spawn(function()
            wait(sound.TimeLength + 0.1)
            if sound then
                sound:Destroy()
            end
        end)
    end
    
    -- Reproducir sonido
    sound:Play()
    
    -- Agregar a efectos activos si es looped
    if sound.Looped then
        ActiveEffects[effectName] = sound
    end
    
    print("Reproduciendo efecto:", effectName)
end

-- Función para reproducir efecto 3D
function SoundEffects.PlayEffect3D(effectName, position, volume, pitch)
    SoundEffects.PlayEffect(effectName, position, volume, pitch)
end

-- Función para reproducir efecto de salto
function SoundEffects.PlayJumpEffect()
    SoundEffects.PlayEffect("JUMP")
end

-- Función para reproducir efecto de aterrizaje
function SoundEffects.PlayLandEffect()
    SoundEffects.PlayEffect("LAND")
end

-- Función para reproducir efecto de moneda
function SoundEffects.PlayCoinEffect()
    SoundEffects.PlayEffect("COIN_PICKUP")
end

-- Función para reproducir efecto de gema
function SoundEffects.PlayGemEffect()
    SoundEffects.PlayEffect("GEM_PICKUP")
end

-- Función para reproducir efecto de martillo
function SoundEffects.PlayHammerEffect()
    SoundEffects.PlayEffect("HAMMER_PICKUP")
end

-- Función para reproducir efecto de checkpoint
function SoundEffects.PlayCheckpointEffect()
    SoundEffects.PlayEffect("CHECKPOINT_ACTIVATE")
end

-- Función para reproducir efecto de daño
function SoundEffects.PlayDamageEffect()
    SoundEffects.PlayEffect("DAMAGE")
end

-- Función para reproducir efecto de curación
function SoundEffects.PlayHealEffect()
    SoundEffects.PlayEffect("HEAL")
end

-- Función para reproducir efecto de power-up
function SoundEffects.PlayPowerUpEffect()
    SoundEffects.PlayEffect("POWER_UP")
end

-- Función para reproducir efecto de botón
function SoundEffects.PlayButtonEffect()
    SoundEffects.PlayEffect("BUTTON_PRESS")
end

-- Función para reproducir efecto de menú
function SoundEffects.PlayMenuEffect()
    SoundEffects.PlayEffect("MENU_OPEN")
end

-- Función para reproducir efecto de notificación
function SoundEffects.PlayNotificationEffect()
    SoundEffects.PlayEffect("NOTIFICATION")
end

-- Función para reproducir efecto de logro
function SoundEffects.PlayAchievementEffect()
    SoundEffects.PlayEffect("ACHIEVEMENT")
end

-- Función para reproducir efecto de ambiente
function SoundEffects.PlayAmbientEffect(effectName, position)
    if EffectConfig[effectName] then
        SoundEffects.PlayEffect(effectName, position)
    end
end

-- Función para detener efecto
function SoundEffects.StopEffect(effectName)
    if ActiveEffects[effectName] then
        ActiveEffects[effectName]:Stop()
        ActiveEffects[effectName]:Destroy()
        ActiveEffects[effectName] = nil
    end
end

-- Función para detener todos los efectos
function SoundEffects.StopAllEffects()
    for effectName, sound in pairs(ActiveEffects) do
        sound:Stop()
        sound:Destroy()
    end
    
    ActiveEffects = {}
end

-- Función para silenciar efectos
function SoundEffects.MuteEffects()
    IsMuted = true
    SoundEffects.StopAllEffects()
end

-- Función para activar efectos
function SoundEffects.UnmuteEffects()
    IsMuted = false
end

-- Función para cambiar volumen de efectos
function SoundEffects.SetEffectsVolume(volume)
    for _, sound in pairs(ActiveEffects) do
        sound.Volume = volume
    end
end

-- Función para agregar efecto a la cola
function SoundEffects.QueueEffect(effectName, position, volume, pitch)
    table.insert(EffectQueue, {
        name = effectName,
        position = position,
        volume = volume,
        pitch = pitch
    })
    
    -- Reproducir siguiente efecto en la cola
    SoundEffects.PlayNextInQueue()
end

-- Función para reproducir siguiente efecto en la cola
function SoundEffects.PlayNextInQueue()
    if #EffectQueue > 0 then
        local effect = table.remove(EffectQueue, 1)
        SoundEffects.PlayEffect(effect.name, effect.position, effect.volume, effect.pitch)
    end
end

-- Función para limpiar cola de efectos
function SoundEffects.ClearQueue()
    EffectQueue = {}
end

-- Función para crear efecto personalizado
function SoundEffects.CreateCustomEffect(effectName, soundId, volume, pitch, maxDistance, priority)
    EffectConfig[effectName] = {
        soundId = soundId,
        volume = volume or 0.5,
        pitch = pitch or 1.0,
        maxDistance = maxDistance or 50,
        priority = priority or 1
    }
    
    print("Efecto personalizado creado:", effectName)
end

-- Función para obtener configuración de efectos
function SoundEffects.GetEffectConfig()
    return EffectConfig
end

-- Función para obtener estadísticas de efectos
function SoundEffects.GetEffectsStats()
    return {
        ActiveEffects = #ActiveEffects,
        QueueLength = #EffectQueue,
        IsMuted = IsMuted,
        TotalEffects = #EffectConfig
    }
end

-- Función para limpiar recursos
function SoundEffects.Cleanup()
    SoundEffects.StopAllEffects()
    SoundEffects.ClearQueue()
    IsMuted = false
end

-- Inicializar sistema
SoundEffects.Initialize()

return SoundEffects 