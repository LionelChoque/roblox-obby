-- AudioSystem.client.lua
-- Sistema de audio del cliente para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

-- Eventos remotos
local RankingEvents = ReplicatedStorage:WaitForChild("RankingEvents")

local player = Players.LocalPlayer
local AudioSystem = {}

-- Estado del sistema de audio
local AudioSettings = {
    MasterVolume = 1.0,
    MusicVolume = 0.7,
    SFXVolume = 0.8,
    VoiceVolume = 0.6,
    AmbientVolume = 0.5
}

-- Sonidos activos
local ActiveSounds = {}
local ActiveMusic = {}
local CurrentMusic = nil

-- Función para inicializar el sistema de audio
function AudioSystem.Initialize()
    print("Inicializando sistema de audio del cliente...")
    
    -- Configurar eventos remotos
    AudioSystem.SetupRemoteEvents()
    
    -- Cargar configuración de audio
    AudioSystem.LoadAudioSettings()
    
    -- Crear interfaz de audio
    AudioSystem.CreateAudioUI()
    
    print("Sistema de audio del cliente inicializado correctamente")
end

-- Función para configurar eventos remotos
function AudioSystem.SetupRemoteEvents()
    -- Evento para reproducir sonido
    RankingEvents.PlaySoundClient.OnClientEvent:Connect(function(soundName, volume, pitch)
        AudioSystem.PlaySound(soundName, volume, pitch)
    end)
    
    -- Evento para reproducir música
    RankingEvents.PlayMusicClient.OnClientEvent:Connect(function(musicName, volume, pitch)
        AudioSystem.PlayMusic(musicName, volume, pitch)
    end)
    
    -- Evento para detener música
    RankingEvents.StopMusicClient.OnClientEvent:Connect(function()
        AudioSystem.StopMusic()
    end)
    
    -- Evento para reproducir sonido 3D
    RankingEvents.PlaySound3DClient.OnClientEvent:Connect(function(soundName, position, volume, pitch)
        AudioSystem.PlaySound3D(soundName, position, volume, pitch)
    end)
end

-- Función para cargar configuración de audio
function AudioSystem.LoadAudioSettings()
    -- Cargar desde configuración guardada
    local success, settings = pcall(function()
        return RankingEvents.GetAudioSettings:InvokeServer()
    end)
    
    if success and settings then
        AudioSettings = settings
    end
end

-- Función para crear interfaz de audio
function AudioSystem.CreateAudioUI()
    -- Crear carpeta para UI de audio
    local audioUI = Instance.new("ScreenGui")
    audioUI.Name = "AudioUI"
    audioUI.Parent = player.PlayerGui
    
    -- Panel de configuración de audio
    local audioPanel = Instance.new("Frame")
    audioPanel.Name = "AudioPanel"
    audioPanel.Size = UDim2.new(0, 300, 0, 400)
    audioPanel.Position = UDim2.new(1, -320, 0.5, -200)
    audioPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    audioPanel.BorderSizePixel = 0
    audioPanel.Visible = false
    audioPanel.Parent = audioUI
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    title.Text = "CONFIGURACIÓN DE AUDIO"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = audioPanel
    
    -- Controles de volumen
    local volumeControls = {
        { name = "MasterVolume", label = "Volumen General", icon = "🔊" },
        { name = "MusicVolume", label = "Volumen de Música", icon = "🎵" },
        { name = "SFXVolume", label = "Volumen de Efectos", icon = "🔊" },
        { name = "VoiceVolume", label = "Volumen de Voz", icon = "🎤" },
        { name = "AmbientVolume", label = "Volumen Ambiental", icon = "🌿" }
    }
    
    for i, control in ipairs(volumeControls) do
        local controlFrame = Instance.new("Frame")
        controlFrame.Name = control.name .. "Control"
        controlFrame.Size = UDim2.new(1, -20, 0, 60)
        controlFrame.Position = UDim2.new(0, 10, 0, 50 + (i-1) * 70)
        controlFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        controlFrame.BorderSizePixel = 0
        controlFrame.Parent = audioPanel
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 0, 25)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = control.icon .. " " .. control.label
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.Parent = controlFrame
        
        -- Slider
        local slider = Instance.new("TextButton")
        slider.Name = "Slider"
        slider.Size = UDim2.new(1, -20, 0, 20)
        slider.Position = UDim2.new(0, 10, 0, 30)
        slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        slider.Text = ""
        slider.Parent = controlFrame
        
        -- Slider fill
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "SliderFill"
        sliderFill.Size = UDim2.new(AudioSettings[control.name], 0, 1, 0)
        sliderFill.Position = UDim2.new(0, 0, 0, 0)
        sliderFill.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = slider
        
        -- Valor
        local value = Instance.new("TextLabel")
        value.Name = "Value"
        value.Size = UDim2.new(0, 50, 0, 20)
        value.Position = UDim2.new(1, -60, 0, 30)
        value.BackgroundTransparency = 1
        value.Text = math.floor(AudioSettings[control.name] * 100) .. "%"
        value.TextColor3 = Color3.fromRGB(255, 255, 255)
        value.TextScaled = true
        value.Font = Enum.Font.GothamBold
        value.Parent = controlFrame
        
        -- Evento del slider
        slider.MouseButton1Down:Connect(function()
            local mouse = Players.LocalPlayer:GetMouse()
            local relativeX = (mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
            local newVolume = math.clamp(relativeX, 0, 1)
            
            AudioSettings[control.name] = newVolume
            sliderFill.Size = UDim2.new(newVolume, 0, 1, 0)
            value.Text = math.floor(newVolume * 100) .. "%"
            
            -- Actualizar configuración en el servidor
            AudioSystem.UpdateAudioSettings()
        end)
    end
    
    -- Botón de cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(0.5, -50, 1, -40)
    closeButton.BackgroundColor3 = GameConstants.UI.ERROR_COLOR
    closeButton.Text = "CERRAR"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = audioPanel
    
    closeButton.MouseButton1Click:Connect(function()
        audioPanel.Visible = false
    end)
    
    -- Botón para mostrar/ocultar panel
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(1, -60, 0, 10)
    toggleButton.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    toggleButton.Text = "🔊"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = audioUI
    
    toggleButton.MouseButton1Click:Connect(function()
        audioPanel.Visible = not audioPanel.Visible
    end)
end

-- Función para reproducir sonido
function AudioSystem.PlaySound(soundName, volume, pitch)
    local sound = ReplicatedStorage.GlobalSounds:FindFirstChild(soundName)
    if not sound then
        warn("Sonido no encontrado:", soundName)
        return
    end
    
    -- Crear copia del sonido para reproducir
    local soundCopy = sound:Clone()
    soundCopy.Parent = SoundService
    
    -- Aplicar configuración
    if volume then
        soundCopy.Volume = volume * AudioSettings.SFXVolume * AudioSettings.MasterVolume
    else
        soundCopy.Volume = soundCopy.Volume * AudioSettings.SFXVolume * AudioSettings.MasterVolume
    end
    
    if pitch then
        soundCopy.Pitch = pitch
    end
    
    -- Reproducir sonido
    soundCopy:Play()
    
    -- Limpiar después de reproducir
    soundCopy.Ended:Connect(function()
        soundCopy:Destroy()
    end)
    
    -- Si no es looped, destruir después de un tiempo
    if not soundCopy.Looped then
        spawn(function()
            wait(soundCopy.TimeLength + 0.1)
            if soundCopy then
                soundCopy:Destroy()
            end
        end)
    else
        -- Agregar a sonidos activos
        ActiveSounds[soundName] = soundCopy
    end
end

-- Función para reproducir música
function AudioSystem.PlayMusic(musicName, volume, pitch)
    -- Detener música actual si existe
    if CurrentMusic then
        AudioSystem.StopMusic()
    end
    
    local music = ReplicatedStorage.GlobalMusic:FindFirstChild(musicName)
    if not music then
        warn("Música no encontrada:", musicName)
        return
    end
    
    -- Crear copia de la música
    local musicCopy = music:Clone()
    musicCopy.Parent = SoundService
    
    -- Aplicar configuración
    if volume then
        musicCopy.Volume = volume * AudioSettings.MusicVolume * AudioSettings.MasterVolume
    else
        musicCopy.Volume = musicCopy.Volume * AudioSettings.MusicVolume * AudioSettings.MasterVolume
    end
    
    if pitch then
        musicCopy.Pitch = pitch
    end
    
    -- Reproducir música
    musicCopy:Play()
    
    -- Guardar referencia
    CurrentMusic = musicCopy
    ActiveMusic[musicName] = musicCopy
    
    print("Reproduciendo música:", musicName)
end

-- Función para detener música
function AudioSystem.StopMusic()
    if CurrentMusic then
        -- Fade out
        local fadeTween = TweenService:Create(CurrentMusic, TweenInfo.new(1), {
            Volume = 0
        })
        fadeTween:Play()
        
        fadeTween.Completed:Connect(function()
            if CurrentMusic then
                CurrentMusic:Stop()
                CurrentMusic:Destroy()
                CurrentMusic = nil
            end
        end)
    end
    
    -- Detener todas las músicas activas
    for musicName, music in pairs(ActiveMusic) do
        if music then
            music:Stop()
            music:Destroy()
        end
    end
    
    ActiveMusic = {}
end

-- Función para reproducir sonido 3D
function AudioSystem.PlaySound3D(soundName, position, volume, pitch)
    local sound = ReplicatedStorage.GlobalSounds:FindFirstChild(soundName)
    if not sound then
        warn("Sonido 3D no encontrado:", soundName)
        return
    end
    
    -- Crear sonido 3D
    local sound3D = Instance.new("Sound")
    sound3D.SoundId = sound.SoundId
    sound3D.Volume = (volume or sound.Volume) * AudioSettings.SFXVolume * AudioSettings.MasterVolume
    sound3D.Pitch = pitch or sound.Pitch
    sound3D.Looped = sound.Looped
    
    -- Crear parte para el sonido 3D
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Position = position
    part.Parent = workspace
    
    sound3D.Parent = part
    sound3D:Play()
    
    -- Limpiar después de reproducir
    if not sound3D.Looped then
        sound3D.Ended:Connect(function()
            part:Destroy()
        end)
        
        spawn(function()
            wait(sound3D.TimeLength + 0.1)
            if part then
                part:Destroy()
            end
        end)
    end
end

-- Función para actualizar configuración de audio
function AudioSystem.UpdateAudioSettings()
    spawn(function()
        local success = pcall(function()
            return RankingEvents.UpdateAudioSettings:FireServer(AudioSettings)
        end)
        
        if success then
            print("Configuración de audio actualizada")
        else
            warn("Error al actualizar configuración de audio")
        end
    end)
end

-- Función para reproducir sonido de salto
function AudioSystem.PlayJumpSound()
    AudioSystem.PlaySound("JUMP")
end

-- Función para reproducir sonido de muerte
function AudioSystem.PlayDeathSound()
    AudioSystem.PlaySound("DEATH")
end

-- Función para reproducir sonido de moneda
function AudioSystem.PlayCoinSound()
    AudioSystem.PlaySound("COIN_COLLECT")
end

-- Función para reproducir sonido de gema
function AudioSystem.PlayGemSound()
    AudioSystem.PlaySound("GEM_COLLECT")
end

-- Función para reproducir sonido de checkpoint
function AudioSystem.PlayCheckpointSound()
    AudioSystem.PlaySound("CHECKPOINT")
end

-- Función para reproducir sonido de martillo
function AudioSystem.PlayHammerSound()
    AudioSystem.PlaySound("HAMMER_COLLECT")
end

-- Función para reproducir sonido de completar nivel
function AudioSystem.PlayLevelCompleteSound()
    AudioSystem.PlaySound("LEVEL_COMPLETE")
end

-- Función para reproducir sonido de botón
function AudioSystem.PlayButtonSound()
    AudioSystem.PlaySound("BUTTON_CLICK")
end

-- Función para reproducir sonido de error
function AudioSystem.PlayErrorSound()
    AudioSystem.PlaySound("ERROR_SOUND")
end

-- Función para reproducir sonido de éxito
function AudioSystem.PlaySuccessSound()
    AudioSystem.PlaySound("SUCCESS_SOUND")
end

-- Función para reproducir música de menú
function AudioSystem.PlayMenuMusic()
    AudioSystem.PlayMusic("MENU_MUSIC")
end

-- Función para reproducir música de lobby
function AudioSystem.PlayLobbyMusic()
    AudioSystem.PlayMusic("LOBBY_MUSIC")
end

-- Función para reproducir música de victoria
function AudioSystem.PlayVictoryMusic()
    AudioSystem.PlayMusic("VICTORY_MUSIC")
end

-- Función para reproducir música de derrota
function AudioSystem.PlayDefeatMusic()
    AudioSystem.PlayMusic("DEFEAT_MUSIC")
end

-- Función para reproducir música de nivel
function AudioSystem.PlayLevelMusic(levelType)
    local musicName = levelType .. "_MUSIC"
    AudioSystem.PlayMusic(musicName)
end

-- Función para reproducir sonido de ambiente
function AudioSystem.PlayAmbientSound(levelType)
    local ambientName = "AMBIENT_" .. string.upper(levelType)
    AudioSystem.PlaySound(ambientName)
end

-- Función para obtener configuración de audio
function AudioSystem.GetAudioSettings()
    return AudioSettings
end

-- Función para establecer configuración de audio
function AudioSystem.SetAudioSettings(settings)
    for key, value in pairs(settings) do
        if AudioSettings[key] ~= nil then
            AudioSettings[key] = math.clamp(value, 0, 1)
        end
    end
    
    AudioSystem.UpdateAudioSettings()
end

-- Función para obtener estadísticas de audio
function AudioSystem.GetAudioStats()
    return {
        ActiveSounds = #ActiveSounds,
        ActiveMusic = #ActiveMusic,
        CurrentMusic = CurrentMusic and CurrentMusic.Name or "Ninguna",
        MasterVolume = AudioSettings.MasterVolume,
        MusicVolume = AudioSettings.MusicVolume,
        SFXVolume = AudioSettings.SFXVolume,
        VoiceVolume = AudioSettings.VoiceVolume,
        AmbientVolume = AudioSettings.AmbientVolume
    }
end

-- Función para limpiar todos los sonidos
function AudioSystem.CleanupSounds()
    for soundName, sound in pairs(ActiveSounds) do
        if sound then
            sound:Stop()
            sound:Destroy()
        end
    end
    
    ActiveSounds = {}
    
    AudioSystem.StopMusic()
end

-- Inicializar sistema
AudioSystem.Initialize()

return AudioSystem 