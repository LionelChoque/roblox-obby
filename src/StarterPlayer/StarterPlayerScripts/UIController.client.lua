-- UIController.client.lua
-- Controlador principal de UI para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local UIController = {}

-- Referencias a las pantallas de UI
local UIScreens = {
    MainMenu = nil,
    LobbyUI = nil,
    LevelUI = nil,
    PauseMenu = nil,
    SettingsUI = nil,
    ShopUI = nil,
    AchievementsUI = nil
}

-- Estado actual de la UI
local CurrentScreen = "MainMenu"
local IsUIVisible = true

-- Función para crear la pantalla principal
function UIController.CreateMainMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MainMenu"
    screenGui.Parent = playerGui
    
    -- Fondo principal
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.3
    background.Parent = screenGui
    
    -- Título del juego
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 400, 0, 80)
    title.Position = UDim2.new(0.5, -200, 0.2, 0)
    title.BackgroundTransparency = 1
    title.Text = "OBBY DE LAS DIMENSIONES"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = background
    
    -- Botón de jugar
    local playButton = Instance.new("TextButton")
    playButton.Name = "PlayButton"
    playButton.Size = UDim2.new(0, 200, 0, 50)
    playButton.Position = UDim2.new(0.5, -100, 0.5, 0)
    playButton.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    playButton.Text = "JUGAR"
    playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    playButton.TextScaled = true
    playButton.Font = Enum.Font.GothamBold
    playButton.Parent = background
    
    -- Botón de configuración
    local settingsButton = Instance.new("TextButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Size = UDim2.new(0, 200, 0, 50)
    settingsButton.Position = UDim2.new(0.5, -100, 0.6, 0)
    settingsButton.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
    settingsButton.Text = "CONFIGURACIÓN"
    settingsButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    settingsButton.TextScaled = true
    settingsButton.Font = Enum.Font.GothamBold
    settingsButton.Parent = background
    
    -- Botón de tienda
    local shopButton = Instance.new("TextButton")
    shopButton.Name = "ShopButton"
    shopButton.Size = UDim2.new(0, 200, 0, 50)
    shopButton.Position = UDim2.new(0.5, -100, 0.7, 0)
    shopButton.BackgroundColor3 = GameConstants.UI.WARNING_COLOR
    shopButton.Text = "TIENDA"
    shopButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    shopButton.TextScaled = true
    shopButton.Font = Enum.Font.GothamBold
    shopButton.Parent = background
    
    -- Configurar eventos de botones
    playButton.MouseButton1Click:Connect(function()
        UIController.SwitchToScreen("LobbyUI")
    end)
    
    settingsButton.MouseButton1Click:Connect(function()
        UIController.SwitchToScreen("SettingsUI")
    end)
    
    shopButton.MouseButton1Click:Connect(function()
        UIController.SwitchToScreen("ShopUI")
    end)
    
    UIScreens.MainMenu = screenGui
    return screenGui
end

-- Función para crear la UI del lobby
function UIController.CreateLobbyUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LobbyUI"
    screenGui.Parent = playerGui
    
    -- Panel principal
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(1, 0, 1, 0)
    mainPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainPanel.BackgroundTransparency = 0.1
    mainPanel.Parent = screenGui
    
    -- Panel de información del jugador
    local playerInfoPanel = Instance.new("Frame")
    playerInfoPanel.Name = "PlayerInfoPanel"
    playerInfoPanel.Size = UDim2.new(0, 300, 0, 200)
    playerInfoPanel.Position = UDim2.new(0, 20, 0, 20)
    playerInfoPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    playerInfoPanel.BorderSizePixel = 0
    playerInfoPanel.Parent = mainPanel
    
    -- Título del panel
    local playerInfoTitle = Instance.new("TextLabel")
    playerInfoTitle.Name = "Title"
    playerInfoTitle.Size = UDim2.new(1, 0, 0, 30)
    playerInfoTitle.Position = UDim2.new(0, 0, 0, 0)
    playerInfoTitle.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    playerInfoTitle.Text = "INFORMACIÓN DEL JUGADOR"
    playerInfoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerInfoTitle.TextScaled = true
    playerInfoTitle.Font = Enum.Font.GothamBold
    playerInfoTitle.Parent = playerInfoPanel
    
    -- Información del jugador
    local playerName = Instance.new("TextLabel")
    playerName.Name = "PlayerName"
    playerName.Size = UDim2.new(1, -20, 0, 25)
    playerName.Position = UDim2.new(0, 10, 0, 40)
    playerName.BackgroundTransparency = 1
    playerName.Text = "Jugador: " .. player.Name
    playerName.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerName.TextScaled = true
    playerName.Font = Enum.Font.Gotham
    playerName.Parent = playerInfoPanel
    
    local playerLevel = Instance.new("TextLabel")
    playerLevel.Name = "PlayerLevel"
    playerLevel.Size = UDim2.new(1, -20, 0, 25)
    playerLevel.Position = UDim2.new(0, 10, 0, 70)
    playerLevel.BackgroundTransparency = 1
    playerLevel.Text = "Nivel actual: 1"
    playerLevel.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerLevel.TextScaled = true
    playerLevel.Font = Enum.Font.Gotham
    playerLevel.Parent = playerInfoPanel
    
    local playerCoins = Instance.new("TextLabel")
    playerCoins.Name = "PlayerCoins"
    playerCoins.Size = UDim2.new(1, -20, 0, 25)
    playerCoins.Position = UDim2.new(0, 10, 0, 100)
    playerCoins.BackgroundTransparency = 1
    playerCoins.Text = "Monedas: 0"
    playerCoins.TextColor3 = Color3.fromRGB(255, 215, 0)
    playerCoins.TextScaled = true
    playerCoins.Font = Enum.Font.Gotham
    playerCoins.Parent = playerInfoPanel
    
    local playerGems = Instance.new("TextLabel")
    playerGems.Name = "PlayerGems"
    playerGems.Size = UDim2.new(1, -20, 0, 25)
    playerGems.Position = UDim2.new(0, 10, 0, 130)
    playerGems.BackgroundTransparency = 1
    playerGems.Text = "Gemas: 0"
    playerGems.TextColor3 = Color3.fromRGB(0, 255, 255)
    playerGems.TextScaled = true
    playerGems.Font = Enum.Font.Gotham
    playerGems.Parent = playerInfoPanel
    
    -- Panel de selección de nivel
    local levelSelectionPanel = Instance.new("Frame")
    levelSelectionPanel.Name = "LevelSelectionPanel"
    levelSelectionPanel.Size = UDim2.new(0, 400, 0, 300)
    levelSelectionPanel.Position = UDim2.new(0.5, -200, 0.5, -150)
    levelSelectionPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    levelSelectionPanel.BorderSizePixel = 0
    levelSelectionPanel.Parent = mainPanel
    
    -- Título del panel de niveles
    local levelTitle = Instance.new("TextLabel")
    levelTitle.Name = "Title"
    levelTitle.Size = UDim2.new(1, 0, 0, 40)
    levelTitle.Position = UDim2.new(0, 0, 0, 0)
    levelTitle.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    levelTitle.Text = "SELECCIONAR NIVEL"
    levelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelTitle.TextScaled = true
    levelTitle.Font = Enum.Font.GothamBold
    levelTitle.Parent = levelSelectionPanel
    
    -- Crear botones de nivel
    for i = 1, 6 do
        local levelButton = Instance.new("TextButton")
        levelButton.Name = "Level" .. i .. "Button"
        levelButton.Size = UDim2.new(0, 80, 0, 80)
        levelButton.Position = UDim2.new(0.2 + (i-1) * 0.15, 0, 0.3, 0)
        levelButton.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
        levelButton.Text = tostring(i)
        levelButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        levelButton.TextScaled = true
        levelButton.Font = Enum.Font.GothamBold
        levelButton.Parent = levelSelectionPanel
        
        -- Configurar evento de clic
        levelButton.MouseButton1Click:Connect(function()
            UIController.StartLevel(i)
        end)
    end
    
    -- Botón de volver al menú principal
    local backButton = Instance.new("TextButton")
    backButton.Name = "BackButton"
    backButton.Size = UDim2.new(0, 150, 0, 40)
    backButton.Position = UDim2.new(0, 20, 1, -60)
    backButton.BackgroundColor3 = GameConstants.UI.ERROR_COLOR
    backButton.Text = "VOLVER AL MENÚ"
    backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButton.TextScaled = true
    backButton.Font = Enum.Font.GothamBold
    backButton.Parent = mainPanel
    
    backButton.MouseButton1Click:Connect(function()
        UIController.SwitchToScreen("MainMenu")
    end)
    
    UIScreens.LobbyUI = screenGui
    return screenGui
end

-- Función para crear la UI del nivel
function UIController.CreateLevelUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LevelUI"
    screenGui.Parent = playerGui
    
    -- Panel de información del nivel
    local levelInfoPanel = Instance.new("Frame")
    levelInfoPanel.Name = "LevelInfoPanel"
    levelInfoPanel.Size = UDim2.new(0, 250, 0, 150)
    levelInfoPanel.Position = UDim2.new(0, 20, 0, 20)
    levelInfoPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    levelInfoPanel.BackgroundTransparency = 0.5
    levelInfoPanel.BorderSizePixel = 0
    levelInfoPanel.Parent = screenGui
    
    -- Título del nivel
    local levelTitle = Instance.new("TextLabel")
    levelTitle.Name = "LevelTitle"
    levelTitle.Size = UDim2.new(1, 0, 0, 30)
    levelTitle.Position = UDim2.new(0, 0, 0, 0)
    levelTitle.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    levelTitle.Text = "NIVEL 1"
    levelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelTitle.TextScaled = true
    levelTitle.Font = Enum.Font.GothamBold
    levelTitle.Parent = levelInfoPanel
    
    -- Tiempo del nivel
    local levelTime = Instance.new("TextLabel")
    levelTime.Name = "LevelTime"
    levelTime.Size = UDim2.new(1, -20, 0, 25)
    levelTime.Position = UDim2.new(0, 10, 0, 40)
    levelTime.BackgroundTransparency = 1
    levelTime.Text = "Tiempo: 00:00"
    levelTime.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelTime.TextScaled = true
    levelTime.Font = Enum.Font.Gotham
    levelTime.Parent = levelInfoPanel
    
    -- Muertes del nivel
    local levelDeaths = Instance.new("TextLabel")
    levelDeaths.Name = "LevelDeaths"
    levelDeaths.Size = UDim2.new(1, -20, 0, 25)
    levelDeaths.Position = UDim2.new(0, 10, 0, 70)
    levelDeaths.BackgroundTransparency = 1
    levelDeaths.Text = "Muertes: 0"
    levelDeaths.TextColor3 = Color3.fromRGB(255, 0, 0)
    levelDeaths.TextScaled = true
    levelDeaths.Font = Enum.Font.Gotham
    levelDeaths.Parent = levelInfoPanel
    
    -- Checkpoints alcanzados
    local levelCheckpoints = Instance.new("TextLabel")
    levelCheckpoints.Name = "LevelCheckpoints"
    levelCheckpoints.Size = UDim2.new(1, -20, 0, 25)
    levelCheckpoints.Position = UDim2.new(0, 10, 0, 100)
    levelCheckpoints.BackgroundTransparency = 1
    levelCheckpoints.Text = "Checkpoints: 0"
    levelCheckpoints.TextColor3 = Color3.fromRGB(0, 255, 0)
    levelCheckpoints.TextScaled = true
    levelCheckpoints.Font = Enum.Font.Gotham
    levelCheckpoints.Parent = levelInfoPanel
    
    -- Botón de pausa
    local pauseButton = Instance.new("TextButton")
    pauseButton.Name = "PauseButton"
    pauseButton.Size = UDim2.new(0, 50, 0, 50)
    pauseButton.Position = UDim2.new(1, -70, 0, 20)
    pauseButton.BackgroundColor3 = GameConstants.UI.WARNING_COLOR
    pauseButton.Text = "⏸"
    pauseButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    pauseButton.TextScaled = true
    pauseButton.Font = Enum.Font.GothamBold
    pauseButton.Parent = screenGui
    
    pauseButton.MouseButton1Click:Connect(function()
        UIController.SwitchToScreen("PauseMenu")
    end)
    
    UIScreens.LevelUI = screenGui
    return screenGui
end

-- Función para crear el menú de pausa
function UIController.CreatePauseMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PauseMenu"
    screenGui.Parent = playerGui
    
    -- Fondo oscuro
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.Parent = screenGui
    
    -- Panel del menú
    local menuPanel = Instance.new("Frame")
    menuPanel.Name = "MenuPanel"
    menuPanel.Size = UDim2.new(0, 300, 0, 400)
    menuPanel.Position = UDim2.new(0.5, -150, 0.5, -200)
    menuPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    menuPanel.BorderSizePixel = 0
    menuPanel.Parent = background
    
    -- Título del menú
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    title.Text = "MENÚ DE PAUSA"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = menuPanel
    
    -- Botón de continuar
    local continueButton = Instance.new("TextButton")
    continueButton.Name = "ContinueButton"
    continueButton.Size = UDim2.new(0.8, 0, 0, 50)
    continueButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    continueButton.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
    continueButton.Text = "CONTINUAR"
    continueButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    continueButton.TextScaled = true
    continueButton.Font = Enum.Font.GothamBold
    continueButton.Parent = menuPanel
    
    -- Botón de reiniciar
    local restartButton = Instance.new("TextButton")
    restartButton.Name = "RestartButton"
    restartButton.Size = UDim2.new(0.8, 0, 0, 50)
    restartButton.Position = UDim2.new(0.1, 0, 0.35, 0)
    restartButton.BackgroundColor3 = GameConstants.UI.WARNING_COLOR
    restartButton.Text = "REINICIAR NIVEL"
    restartButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    restartButton.TextScaled = true
    restartButton.Font = Enum.Font.GothamBold
    restartButton.Parent = menuPanel
    
    -- Botón de configuración
    local settingsButton = Instance.new("TextButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Size = UDim2.new(0.8, 0, 0, 50)
    settingsButton.Position = UDim2.new(0.1, 0, 0.5, 0)
    settingsButton.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
    settingsButton.Text = "CONFIGURACIÓN"
    settingsButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    settingsButton.TextScaled = true
    settingsButton.Font = Enum.Font.GothamBold
    settingsButton.Parent = menuPanel
    
    -- Botón de salir al lobby
    local exitButton = Instance.new("TextButton")
    exitButton.Name = "ExitButton"
    exitButton.Size = UDim2.new(0.8, 0, 0, 50)
    exitButton.Position = UDim2.new(0.1, 0, 0.65, 0)
    exitButton.BackgroundColor3 = GameConstants.UI.ERROR_COLOR
    exitButton.Text = "SALIR AL LOBBY"
    exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    exitButton.TextScaled = true
    exitButton.Font = Enum.Font.GothamBold
    exitButton.Parent = menuPanel
    
    -- Configurar eventos de botones
    continueButton.MouseButton1Click:Connect(function()
        UIController.SwitchToScreen("LevelUI")
    end)
    
    restartButton.MouseButton1Click:Connect(function()
        UIController.RestartLevel()
    end)
    
    settingsButton.MouseButton1Click:Connect(function()
        UIController.SwitchToScreen("SettingsUI")
    end)
    
    exitButton.MouseButton1Click:Connect(function()
        UIController.SwitchToScreen("LobbyUI")
    end)
    
    UIScreens.PauseMenu = screenGui
    return screenGui
end

-- Función para cambiar de pantalla
function UIController.SwitchToScreen(screenName)
    -- Ocultar pantalla actual
    if UIScreens[CurrentScreen] then
        UIScreens[CurrentScreen].Enabled = false
    end
    
    -- Mostrar nueva pantalla
    if UIScreens[screenName] then
        UIScreens[screenName].Enabled = true
    else
        -- Crear pantalla si no existe
        if screenName == "MainMenu" then
            UIController.CreateMainMenu()
        elseif screenName == "LobbyUI" then
            UIController.CreateLobbyUI()
        elseif screenName == "LevelUI" then
            UIController.CreateLevelUI()
        elseif screenName == "PauseMenu" then
            UIController.CreatePauseMenu()
        end
    end
    
    CurrentScreen = screenName
    print("Cambiado a pantalla: " .. screenName)
end

-- Función para iniciar un nivel
function UIController.StartLevel(levelNumber)
    print("Iniciando nivel " .. levelNumber)
    UIController.SwitchToScreen("LevelUI")
    
    -- TODO: Implementar teleportación al nivel
    -- LevelManager.TeleportToLevel(player, levelNumber)
end

-- Función para reiniciar nivel
function UIController.RestartLevel()
    print("Reiniciando nivel actual")
    UIController.SwitchToScreen("LevelUI")
    
    -- TODO: Implementar reinicio del nivel
end

-- Función para mostrar notificación
function UIController.ShowNotification(message, duration, color)
    duration = duration or 3
    color = color or GameConstants.UI.PRIMARY_COLOR
    
    local notification = Instance.new("ScreenGui")
    notification.Name = "Notification"
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

-- Función para actualizar información del jugador
function UIController.UpdatePlayerInfo(playerData)
    if not UIScreens.LobbyUI then return end
    
    local playerInfoPanel = UIScreens.LobbyUI.MainPanel.PlayerInfoPanel
    if not playerInfoPanel then return end
    
    -- Actualizar información
    if playerInfoPanel.PlayerLevel then
        playerInfoPanel.PlayerLevel.Text = "Nivel actual: " .. (playerData.Progress.CurrentLevel or 1)
    end
    
    if playerInfoPanel.PlayerCoins then
        playerInfoPanel.PlayerCoins.Text = "Monedas: " .. (playerData.Currency.Coins or 0)
    end
    
    if playerInfoPanel.PlayerGems then
        playerInfoPanel.PlayerGems.Text = "Gemas: " .. (playerData.Currency.Gems or 0)
    end
end

-- Función para actualizar información del nivel
function UIController.UpdateLevelInfo(levelData)
    if not UIScreens.LevelUI then return end
    
    local levelInfoPanel = UIScreens.LevelUI.LevelInfoPanel
    if not levelInfoPanel then return end
    
    -- Actualizar tiempo
    if levelInfoPanel.LevelTime then
        local minutes = math.floor(levelData.time / 60)
        local seconds = levelData.time % 60
        levelInfoPanel.LevelTime.Text = string.format("Tiempo: %02d:%02d", minutes, seconds)
    end
    
    -- Actualizar muertes
    if levelInfoPanel.LevelDeaths then
        levelInfoPanel.LevelDeaths.Text = "Muertes: " .. (levelData.deaths or 0)
    end
    
    -- Actualizar checkpoints
    if levelInfoPanel.LevelCheckpoints then
        levelInfoPanel.LevelCheckpoints.Text = "Checkpoints: " .. (levelData.checkpoints or 0)
    end
end

-- Configurar tecla de pausa
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Escape then
        if CurrentScreen == "LevelUI" then
            UIController.SwitchToScreen("PauseMenu")
        elseif CurrentScreen == "PauseMenu" then
            UIController.SwitchToScreen("LevelUI")
        end
    end
end)

-- Inicializar UI
UIController.CreateMainMenu()

return UIController 