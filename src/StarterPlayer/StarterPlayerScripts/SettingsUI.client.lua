-- SettingsUI.client.lua
-- Interfaz de configuración para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SettingsUI = {}

-- Configuración actual del jugador
local PlayerSettings = {
    MusicVolume = GameConstants.AUDIO.DEFAULT_MUSIC_VOLUME,
    SFXVolume = GameConstants.AUDIO.DEFAULT_SFX_VOLUME,
    CameraShake = true,
    ShowGhostRunner = true,
    ShowParticles = true,
    ShowNotifications = true,
    Language = "Español"
}

-- Función para crear la UI de configuración
function SettingsUI.CreateSettingsUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SettingsUI"
    screenGui.Parent = playerGui
    
    -- Fondo principal
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.3
    background.Parent = screenGui
    
    -- Panel principal
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(0, 500, 0, 600)
    mainPanel.Position = UDim2.new(0.5, -250, 0.5, -300)
    mainPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainPanel.BorderSizePixel = 0
    mainPanel.Parent = background
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    title.Text = "CONFIGURACIÓN"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainPanel
    
    -- Panel de configuración de audio
    local audioPanel = Instance.new("Frame")
    audioPanel.Name = "AudioPanel"
    audioPanel.Size = UDim2.new(1, -40, 0, 120)
    audioPanel.Position = UDim2.new(0, 20, 0, 80)
    audioPanel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    audioPanel.BorderSizePixel = 0
    audioPanel.Parent = mainPanel
    
    -- Título del panel de audio
    local audioTitle = Instance.new("TextLabel")
    audioTitle.Name = "Title"
    audioTitle.Size = UDim2.new(1, 0, 0, 30)
    audioTitle.Position = UDim2.new(0, 0, 0, 0)
    audioTitle.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    audioTitle.Text = "AUDIO"
    audioTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    audioTitle.TextScaled = true
    audioTitle.Font = Enum.Font.GothamBold
    audioTitle.Parent = audioPanel
    
    -- Configuración de volumen de música
    local musicLabel = Instance.new("TextLabel")
    musicLabel.Name = "MusicLabel"
    musicLabel.Size = UDim2.new(0.3, 0, 0, 25)
    musicLabel.Position = UDim2.new(0, 10, 0, 40)
    musicLabel.BackgroundTransparency = 1
    musicLabel.Text = "Música:"
    musicLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    musicLabel.TextScaled = true
    musicLabel.Font = Enum.Font.Gotham
    musicLabel.Parent = audioPanel
    
    local musicSlider = Instance.new("TextButton")
    musicSlider.Name = "MusicSlider"
    musicSlider.Size = UDim2.new(0.5, 0, 0, 25)
    musicSlider.Position = UDim2.new(0.35, 0, 0, 40)
    musicSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    musicSlider.Text = math.floor(PlayerSettings.MusicVolume * 100) .. "%"
    musicSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    musicSlider.TextScaled = true
    musicSlider.Font = Enum.Font.Gotham
    musicSlider.Parent = audioPanel
    
    -- Configuración de volumen de efectos
    local sfxLabel = Instance.new("TextLabel")
    sfxLabel.Name = "SFXLabel"
    sfxLabel.Size = UDim2.new(0.3, 0, 0, 25)
    sfxLabel.Position = UDim2.new(0, 10, 0, 75)
    sfxLabel.BackgroundTransparency = 1
    sfxLabel.Text = "Efectos:"
    sfxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sfxLabel.TextScaled = true
    sfxLabel.Font = Enum.Font.Gotham
    sfxLabel.Parent = audioPanel
    
    local sfxSlider = Instance.new("TextButton")
    sfxSlider.Name = "SFXSlider"
    sfxSlider.Size = UDim2.new(0.5, 0, 0, 25)
    sfxSlider.Position = UDim2.new(0.35, 0, 0, 75)
    sfxSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    sfxSlider.Text = math.floor(PlayerSettings.SFXVolume * 100) .. "%"
    sfxSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    sfxSlider.TextScaled = true
    sfxSlider.Font = Enum.Font.Gotham
    sfxSlider.Parent = audioPanel
    
    -- Panel de configuración de gráficos
    local graphicsPanel = Instance.new("Frame")
    graphicsPanel.Name = "GraphicsPanel"
    graphicsPanel.Size = UDim2.new(1, -40, 0, 150)
    graphicsPanel.Position = UDim2.new(0, 20, 0, 220)
    graphicsPanel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    graphicsPanel.BorderSizePixel = 0
    graphicsPanel.Parent = mainPanel
    
    -- Título del panel de gráficos
    local graphicsTitle = Instance.new("TextLabel")
    graphicsTitle.Name = "Title"
    graphicsTitle.Size = UDim2.new(1, 0, 0, 30)
    graphicsTitle.Position = UDim2.new(0, 0, 0, 0)
    graphicsTitle.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    graphicsTitle.Text = "GRÁFICOS"
    graphicsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    graphicsTitle.TextScaled = true
    graphicsTitle.Font = Enum.Font.GothamBold
    graphicsTitle.Parent = graphicsPanel
    
    -- Configuración de partículas
    local particlesLabel = Instance.new("TextLabel")
    particlesLabel.Name = "ParticlesLabel"
    particlesLabel.Size = UDim2.new(0.6, 0, 0, 25)
    particlesLabel.Position = UDim2.new(0, 10, 0, 40)
    particlesLabel.BackgroundTransparency = 1
    particlesLabel.Text = "Mostrar partículas:"
    particlesLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    particlesLabel.TextScaled = true
    particlesLabel.Font = Enum.Font.Gotham
    particlesLabel.Parent = graphicsPanel
    
    local particlesToggle = Instance.new("TextButton")
    particlesToggle.Name = "ParticlesToggle"
    particlesToggle.Size = UDim2.new(0, 60, 0, 25)
    particlesToggle.Position = UDim2.new(0.65, 0, 0, 40)
    particlesToggle.BackgroundColor3 = PlayerSettings.ShowParticles and GameConstants.UI.SUCCESS_COLOR or GameConstants.UI.ERROR_COLOR
    particlesToggle.Text = PlayerSettings.ShowParticles and "ON" or "OFF"
    particlesToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    particlesToggle.TextScaled = true
    particlesToggle.Font = Enum.Font.GothamBold
    particlesToggle.Parent = graphicsPanel
    
    -- Configuración de sacudida de cámara
    local cameraShakeLabel = Instance.new("TextLabel")
    cameraShakeLabel.Name = "CameraShakeLabel"
    cameraShakeLabel.Size = UDim2.new(0.6, 0, 0, 25)
    cameraShakeLabel.Position = UDim2.new(0, 10, 0, 75)
    cameraShakeLabel.BackgroundTransparency = 1
    cameraShakeLabel.Text = "Sacudida de cámara:"
    cameraShakeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    cameraShakeLabel.TextScaled = true
    cameraShakeLabel.Font = Enum.Font.Gotham
    cameraShakeLabel.Parent = graphicsPanel
    
    local cameraShakeToggle = Instance.new("TextButton")
    cameraShakeToggle.Name = "CameraShakeToggle"
    cameraShakeToggle.Size = UDim2.new(0, 60, 0, 25)
    cameraShakeToggle.Position = UDim2.new(0.65, 0, 0, 75)
    cameraShakeToggle.BackgroundColor3 = PlayerSettings.CameraShake and GameConstants.UI.SUCCESS_COLOR or GameConstants.UI.ERROR_COLOR
    cameraShakeToggle.Text = PlayerSettings.CameraShake and "ON" or "OFF"
    cameraShakeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    cameraShakeToggle.TextScaled = true
    cameraShakeToggle.Font = Enum.Font.GothamBold
    cameraShakeToggle.Parent = graphicsPanel
    
    -- Configuración de ghost runner
    local ghostRunnerLabel = Instance.new("TextLabel")
    ghostRunnerLabel.Name = "GhostRunnerLabel"
    ghostRunnerLabel.Size = UDim2.new(0.6, 0, 0, 25)
    ghostRunnerLabel.Position = UDim2.new(0, 10, 0, 110)
    ghostRunnerLabel.BackgroundTransparency = 1
    ghostRunnerLabel.Text = "Mostrar ghost runner:"
    ghostRunnerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ghostRunnerLabel.TextScaled = true
    ghostRunnerLabel.Font = Enum.Font.Gotham
    ghostRunnerLabel.Parent = graphicsPanel
    
    local ghostRunnerToggle = Instance.new("TextButton")
    ghostRunnerToggle.Name = "GhostRunnerToggle"
    ghostRunnerToggle.Size = UDim2.new(0, 60, 0, 25)
    ghostRunnerToggle.Position = UDim2.new(0.65, 0, 0, 110)
    ghostRunnerToggle.BackgroundColor3 = PlayerSettings.ShowGhostRunner and GameConstants.UI.SUCCESS_COLOR or GameConstants.UI.ERROR_COLOR
    ghostRunnerToggle.Text = PlayerSettings.ShowGhostRunner and "ON" or "OFF"
    ghostRunnerToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ghostRunnerToggle.TextScaled = true
    ghostRunnerToggle.Font = Enum.Font.GothamBold
    ghostRunnerToggle.Parent = graphicsPanel
    
    -- Panel de configuración de notificaciones
    local notificationsPanel = Instance.new("Frame")
    notificationsPanel.Name = "NotificationsPanel"
    notificationsPanel.Size = UDim2.new(1, -40, 0, 80)
    notificationsPanel.Position = UDim2.new(0, 20, 0, 390)
    notificationsPanel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    notificationsPanel.BorderSizePixel = 0
    notificationsPanel.Parent = mainPanel
    
    -- Título del panel de notificaciones
    local notificationsTitle = Instance.new("TextLabel")
    notificationsTitle.Name = "Title"
    notificationsTitle.Size = UDim2.new(1, 0, 0, 30)
    notificationsTitle.Position = UDim2.new(0, 0, 0, 0)
    notificationsTitle.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    notificationsTitle.Text = "NOTIFICACIONES"
    notificationsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationsTitle.TextScaled = true
    notificationsTitle.Font = Enum.Font.GothamBold
    notificationsTitle.Parent = notificationsPanel
    
    -- Configuración de notificaciones
    local notificationsLabel = Instance.new("TextLabel")
    notificationsLabel.Name = "NotificationsLabel"
    notificationsLabel.Size = UDim2.new(0.6, 0, 0, 25)
    notificationsLabel.Position = UDim2.new(0, 10, 0, 40)
    notificationsLabel.BackgroundTransparency = 1
    notificationsLabel.Text = "Mostrar notificaciones:"
    notificationsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationsLabel.TextScaled = true
    notificationsLabel.Font = Enum.Font.Gotham
    notificationsLabel.Parent = notificationsPanel
    
    local notificationsToggle = Instance.new("TextButton")
    notificationsToggle.Name = "NotificationsToggle"
    notificationsToggle.Size = UDim2.new(0, 60, 0, 25)
    notificationsToggle.Position = UDim2.new(0.65, 0, 0, 40)
    notificationsToggle.BackgroundColor3 = PlayerSettings.ShowNotifications and GameConstants.UI.SUCCESS_COLOR or GameConstants.UI.ERROR_COLOR
    notificationsToggle.Text = PlayerSettings.ShowNotifications and "ON" or "OFF"
    notificationsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationsToggle.TextScaled = true
    notificationsToggle.Font = Enum.Font.GothamBold
    notificationsToggle.Parent = notificationsPanel
    
    -- Botones de acción
    local saveButton = Instance.new("TextButton")
    saveButton.Name = "SaveButton"
    saveButton.Size = UDim2.new(0, 120, 0, 40)
    saveButton.Position = UDim2.new(0.3, 0, 1, -60)
    saveButton.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
    saveButton.Text = "GUARDAR"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextScaled = true
    saveButton.Font = Enum.Font.GothamBold
    saveButton.Parent = mainPanel
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0, 120, 0, 40)
    cancelButton.Position = UDim2.new(0.6, 0, 1, -60)
    cancelButton.BackgroundColor3 = GameConstants.UI.ERROR_COLOR
    cancelButton.Text = "CANCELAR"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextScaled = true
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Parent = mainPanel
    
    -- Configurar eventos de botones
    musicSlider.MouseButton1Click:Connect(function()
        SettingsUI.AdjustVolume(musicSlider, "MusicVolume")
    end)
    
    sfxSlider.MouseButton1Click:Connect(function()
        SettingsUI.AdjustVolume(sfxSlider, "SFXVolume")
    end)
    
    particlesToggle.MouseButton1Click:Connect(function()
        SettingsUI.ToggleSetting(particlesToggle, "ShowParticles")
    end)
    
    cameraShakeToggle.MouseButton1Click:Connect(function()
        SettingsUI.ToggleSetting(cameraShakeToggle, "CameraShake")
    end)
    
    ghostRunnerToggle.MouseButton1Click:Connect(function()
        SettingsUI.ToggleSetting(ghostRunnerToggle, "ShowGhostRunner")
    end)
    
    notificationsToggle.MouseButton1Click:Connect(function()
        SettingsUI.ToggleSetting(notificationsToggle, "ShowNotifications")
    end)
    
    saveButton.MouseButton1Click:Connect(function()
        SettingsUI.SaveSettings()
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        SettingsUI.CancelSettings()
    end)
    
    return screenGui
end

-- Función para ajustar volumen
function SettingsUI.AdjustVolume(slider, settingName)
    local currentVolume = PlayerSettings[settingName]
    local newVolume = currentVolume + 0.1
    
    if newVolume > 1 then
        newVolume = 0
    end
    
    PlayerSettings[settingName] = newVolume
    slider.Text = math.floor(newVolume * 100) .. "%"
    
    -- Cambiar color del slider según el volumen
    if newVolume > 0.7 then
        slider.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
    elseif newVolume > 0.3 then
        slider.BackgroundColor3 = GameConstants.UI.WARNING_COLOR
    else
        slider.BackgroundColor3 = GameConstants.UI.ERROR_COLOR
    end
end

-- Función para alternar configuración
function SettingsUI.ToggleSetting(toggle, settingName)
    local currentValue = PlayerSettings[settingName]
    PlayerSettings[settingName] = not currentValue
    
    toggle.Text = PlayerSettings[settingName] and "ON" or "OFF"
    toggle.BackgroundColor3 = PlayerSettings[settingName] and GameConstants.UI.SUCCESS_COLOR or GameConstants.UI.ERROR_COLOR
end

-- Función para guardar configuración
function SettingsUI.SaveSettings()
    -- TODO: Guardar configuración en DataStore
    print("Configuración guardada")
    
    -- Mostrar notificación de éxito
    SettingsUI.ShowNotification("Configuración guardada exitosamente", 2, GameConstants.UI.SUCCESS_COLOR)
    
    -- Volver a la pantalla anterior
    SettingsUI.GoBack()
end

-- Función para cancelar configuración
function SettingsUI.CancelSettings()
    -- Restaurar configuración original
    PlayerSettings = {
        MusicVolume = GameConstants.AUDIO.DEFAULT_MUSIC_VOLUME,
        SFXVolume = GameConstants.AUDIO.DEFAULT_SFX_VOLUME,
        CameraShake = true,
        ShowGhostRunner = true,
        ShowParticles = true,
        ShowNotifications = true,
        Language = "Español"
    }
    
    print("Configuración cancelada")
    SettingsUI.GoBack()
end

-- Función para mostrar notificación
function SettingsUI.ShowNotification(message, duration, color)
    duration = duration or 3
    color = color or GameConstants.UI.PRIMARY_COLOR
    
    local notification = Instance.new("ScreenGui")
    notification.Name = "SettingsNotification"
    notification.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0.2, 0)
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = frame
    
    -- Animación de entrada
    frame.Position = UDim2.new(0.5, -150, 0, -50)
    local tween = TweenService:Create(frame, TweenInfo.new(0.5), {
        Position = UDim2.new(0.5, -150, 0.2, 0)
    })
    tween:Play()
    
    -- Remover después del tiempo especificado
    spawn(function()
        wait(duration)
        local exitTween = TweenService:Create(frame, TweenInfo.new(0.5), {
            Position = UDim2.new(0.5, -150, 0, -50)
        })
        exitTween:Play()
        exitTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Función para volver a la pantalla anterior
function SettingsUI.GoBack()
    -- TODO: Implementar navegación a pantalla anterior
    print("Volviendo a pantalla anterior")
end

-- Función para obtener configuración actual
function SettingsUI.GetSettings()
    return PlayerSettings
end

-- Función para aplicar configuración
function SettingsUI.ApplySettings(settings)
    PlayerSettings = settings or PlayerSettings
    
    -- Aplicar configuración de audio
    -- TODO: Implementar aplicación de configuración de audio
    
    -- Aplicar configuración de gráficos
    -- TODO: Implementar aplicación de configuración de gráficos
    
    print("Configuración aplicada")
end

return SettingsUI 