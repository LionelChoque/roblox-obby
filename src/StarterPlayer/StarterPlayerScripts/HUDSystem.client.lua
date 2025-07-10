-- HUDSystem.client.lua
-- Sistema de HUD (Heads-Up Display) para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local HUDSystem = {}

-- Referencias del HUD
local HUDGui = nil
local HUDElements = {}

-- Estado del HUD
local IsHUDActive = false
local CurrentLevel = 1
local LevelStartTime = 0
local LevelDeaths = 0
local LevelCheckpoints = 0
local PlayerCoins = 0
local PlayerGems = 0

-- Función para crear el HUD principal
function HUDSystem.CreateHUD()
    if HUDGui then
        HUDGui:Destroy()
    end
    
    HUDGui = Instance.new("ScreenGui")
    HUDGui.Name = "GameHUD"
    HUDGui.Parent = playerGui
    
    -- Panel principal del HUD
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(1, 0, 1, 0)
    mainPanel.BackgroundTransparency = 1
    mainPanel.Parent = HUDGui
    
    -- Panel superior (información del nivel)
    local topPanel = Instance.new("Frame")
    topPanel.Name = "TopPanel"
    topPanel.Size = UDim2.new(1, 0, 0, 60)
    topPanel.Position = UDim2.new(0, 0, 0, 0)
    topPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    topPanel.BackgroundTransparency = 0.3
    topPanel.BorderSizePixel = 0
    topPanel.Parent = mainPanel
    
    -- Título del nivel
    local levelTitle = Instance.new("TextLabel")
    levelTitle.Name = "LevelTitle"
    levelTitle.Size = UDim2.new(0, 200, 0, 30)
    levelTitle.Position = UDim2.new(0, 20, 0, 15)
    levelTitle.BackgroundTransparency = 1
    levelTitle.Text = "Nivel " .. CurrentLevel
    levelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelTitle.TextScaled = true
    levelTitle.Font = Enum.Font.GothamBold
    levelTitle.Parent = topPanel
    
    -- Tiempo del nivel
    local levelTime = Instance.new("TextLabel")
    levelTime.Name = "LevelTime"
    levelTime.Size = UDim2.new(0, 150, 0, 30)
    levelTime.Position = UDim2.new(0.5, -75, 0, 15)
    levelTime.BackgroundTransparency = 1
    levelTime.Text = "00:00"
    levelTime.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelTime.TextScaled = true
    levelTime.Font = Enum.Font.Gotham
    levelTime.Parent = topPanel
    
    -- Muertes del nivel
    local levelDeaths = Instance.new("TextLabel")
    levelDeaths.Name = "LevelDeaths"
    levelDeaths.Size = UDim2.new(0, 120, 0, 30)
    levelDeaths.Position = UDim2.new(1, -140, 0, 15)
    levelDeaths.BackgroundTransparency = 1
    levelDeaths.Text = "Muertes: 0"
    levelDeaths.TextColor3 = Color3.fromRGB(255, 0, 0)
    levelDeaths.TextScaled = true
    levelDeaths.Font = Enum.Font.Gotham
    levelDeaths.Parent = topPanel
    
    -- Panel inferior (información del jugador)
    local bottomPanel = Instance.new("Frame")
    bottomPanel.Name = "BottomPanel"
    bottomPanel.Size = UDim2.new(0, 300, 0, 80)
    bottomPanel.Position = UDim2.new(0, 20, 1, -100)
    bottomPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bottomPanel.BackgroundTransparency = 0.3
    bottomPanel.BorderSizePixel = 0
    bottomPanel.Parent = mainPanel
    
    -- Monedas del jugador
    local playerCoins = Instance.new("TextLabel")
    playerCoins.Name = "PlayerCoins"
    playerCoins.Size = UDim2.new(0.5, -10, 0, 30)
    playerCoins.Position = UDim2.new(0, 10, 0, 10)
    playerCoins.BackgroundTransparency = 1
    playerCoins.Text = "🪙 " .. PlayerCoins
    playerCoins.TextColor3 = Color3.fromRGB(255, 215, 0)
    playerCoins.TextScaled = true
    playerCoins.Font = Enum.Font.Gotham
    playerCoins.Parent = bottomPanel
    
    -- Gemas del jugador
    local playerGems = Instance.new("TextLabel")
    playerGems.Name = "PlayerGems"
    playerGems.Size = UDim2.new(0.5, -10, 0, 30)
    playerGems.Position = UDim2.new(0.5, 0, 0, 10)
    playerGems.BackgroundTransparency = 1
    playerGems.Text = "💎 " .. PlayerGems
    playerGems.TextColor3 = Color3.fromRGB(0, 255, 255)
    playerGems.TextScaled = true
    playerGems.Font = Enum.Font.Gotham
    playerGems.Parent = bottomPanel
    
    -- Checkpoints alcanzados
    local levelCheckpoints = Instance.new("TextLabel")
    levelCheckpoints.Name = "LevelCheckpoints"
    levelCheckpoints.Size = UDim2.new(1, -20, 0, 30)
    levelCheckpoints.Position = UDim2.new(0, 10, 0, 50)
    levelCheckpoints.BackgroundTransparency = 1
    levelCheckpoints.Text = "Checkpoints: 0"
    levelCheckpoints.TextColor3 = Color3.fromRGB(0, 255, 0)
    levelCheckpoints.TextScaled = true
    levelCheckpoints.Font = Enum.Font.Gotham
    levelCheckpoints.Parent = bottomPanel
    
    -- Panel lateral (power-ups activos)
    local sidePanel = Instance.new("Frame")
    sidePanel.Name = "SidePanel"
    sidePanel.Size = UDim2.new(0, 200, 0, 200)
    sidePanel.Position = UDim2.new(1, -220, 0.5, -100)
    sidePanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    sidePanel.BackgroundTransparency = 0.3
    sidePanel.BorderSizePixel = 0
    sidePanel.Parent = mainPanel
    
    -- Título del panel lateral
    local sidePanelTitle = Instance.new("TextLabel")
    sidePanelTitle.Name = "Title"
    sidePanelTitle.Size = UDim2.new(1, 0, 0, 30)
    sidePanelTitle.Position = UDim2.new(0, 0, 0, 0)
    sidePanelTitle.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    sidePanelTitle.Text = "POWER-UPS"
    sidePanelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    sidePanelTitle.TextScaled = true
    sidePanelTitle.Font = Enum.Font.GothamBold
    sidePanelTitle.Parent = sidePanel
    
    -- Lista de power-ups activos
    local powerUpsList = Instance.new("Frame")
    powerUpsList.Name = "PowerUpsList"
    powerUpsList.Size = UDim2.new(1, -20, 1, -40)
    powerUpsList.Position = UDim2.new(0, 10, 0, 40)
    powerUpsList.BackgroundTransparency = 1
    powerUpsList.Parent = sidePanel
    
    -- Guardar referencias
    HUDElements = {
        TopPanel = topPanel,
        BottomPanel = bottomPanel,
        SidePanel = sidePanel,
        LevelTitle = levelTitle,
        LevelTime = levelTime,
        LevelDeaths = levelDeaths,
        PlayerCoins = playerCoins,
        PlayerGems = playerGems,
        LevelCheckpoints = levelCheckpoints,
        PowerUpsList = powerUpsList
    }
    
    IsHUDActive = true
    HUDSystem.StartTimeUpdate()
    
    return HUDGui
end

-- Función para actualizar el tiempo del nivel
function HUDSystem.StartTimeUpdate()
    if not IsHUDActive or not HUDElements.LevelTime then return end
    
    spawn(function()
        while IsHUDActive do
            local currentTime = tick()
            local elapsedTime = currentTime - LevelStartTime
            
            local minutes = math.floor(elapsedTime / 60)
            local seconds = math.floor(elapsedTime % 60)
            
            HUDElements.LevelTime.Text = string.format("%02d:%02d", minutes, seconds)
            
            wait(1)
        end
    end)
end

-- Función para actualizar información del nivel
function HUDSystem.UpdateLevelInfo(levelNumber, deaths, checkpoints)
    CurrentLevel = levelNumber or CurrentLevel
    LevelDeaths = deaths or LevelDeaths
    LevelCheckpoints = checkpoints or LevelCheckpoints
    
    if HUDElements.LevelTitle then
        HUDElements.LevelTitle.Text = "Nivel " .. CurrentLevel
    end
    
    if HUDElements.LevelDeaths then
        HUDElements.LevelDeaths.Text = "Muertes: " .. LevelDeaths
    end
    
    if HUDElements.LevelCheckpoints then
        HUDElements.LevelCheckpoints.Text = "Checkpoints: " .. LevelCheckpoints
    end
end

-- Función para actualizar información del jugador
function HUDSystem.UpdatePlayerInfo(coins, gems)
    PlayerCoins = coins or PlayerCoins
    PlayerGems = gems or PlayerGems
    
    if HUDElements.PlayerCoins then
        HUDElements.PlayerCoins.Text = "🪙 " .. PlayerCoins
    end
    
    if HUDElements.PlayerGems then
        HUDElements.PlayerGems.Text = "💎 " .. PlayerGems
    end
end

-- Función para agregar power-up activo
function HUDSystem.AddActivePowerUp(powerUpName, duration)
    if not HUDElements.PowerUpsList then return end
    
    local powerUpFrame = Instance.new("Frame")
    powerUpFrame.Name = powerUpName .. "PowerUp"
    powerUpFrame.Size = UDim2.new(1, 0, 0, 25)
    powerUpFrame.Position = UDim2.new(0, 0, 0, #HUDElements.PowerUpsList:GetChildren() * 30)
    powerUpFrame.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
    powerUpFrame.BorderSizePixel = 0
    powerUpFrame.Parent = HUDElements.PowerUpsList
    
    local powerUpLabel = Instance.new("TextLabel")
    powerUpLabel.Name = "Label"
    powerUpLabel.Size = UDim2.new(0.7, 0, 1, 0)
    powerUpLabel.Position = UDim2.new(0, 5, 0, 0)
    powerUpLabel.BackgroundTransparency = 1
    powerUpLabel.Text = powerUpName
    powerUpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    powerUpLabel.TextScaled = true
    powerUpLabel.Font = Enum.Font.Gotham
    powerUpLabel.Parent = powerUpFrame
    
    local powerUpTimer = Instance.new("TextLabel")
    powerUpTimer.Name = "Timer"
    powerUpTimer.Size = UDim2.new(0.3, 0, 1, 0)
    powerUpTimer.Position = UDim2.new(0.7, 0, 0, 0)
    powerUpTimer.BackgroundTransparency = 1
    powerUpTimer.Text = string.format("%.1fs", duration)
    powerUpTimer.TextColor3 = Color3.fromRGB(255, 255, 255)
    powerUpTimer.TextScaled = true
    powerUpTimer.Font = Enum.Font.Gotham
    powerUpTimer.Parent = powerUpFrame
    
    -- Actualizar timer
    spawn(function()
        local remainingTime = duration
        while remainingTime > 0 and powerUpFrame.Parent do
            powerUpTimer.Text = string.format("%.1fs", remainingTime)
            remainingTime = remainingTime - 0.1
            wait(0.1)
        end
        
        if powerUpFrame.Parent then
            powerUpFrame:Destroy()
            HUDSystem.RearrangePowerUps()
        end
    end)
end

-- Función para reorganizar power-ups después de remover uno
function HUDSystem.RearrangePowerUps()
    if not HUDElements.PowerUpsList then return end
    
    local powerUps = {}
    for _, child in pairs(HUDElements.PowerUpsList:GetChildren()) do
        if child:IsA("Frame") and child.Name:find("PowerUp") then
            table.insert(powerUps, child)
        end
    end
    
    for i, powerUp in ipairs(powerUps) do
        powerUp.Position = UDim2.new(0, 0, 0, (i-1) * 30)
    end
end

-- Función para mostrar indicador de checkpoint
function HUDSystem.ShowCheckpointIndicator(checkpointNumber)
    if not IsHUDActive then return end
    
    local indicator = Instance.new("ScreenGui")
    indicator.Name = "CheckpointIndicator"
    indicator.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(0.5, -100, 0.3, 0)
    frame.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
    frame.BorderSizePixel = 0
    frame.Parent = indicator
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = "Checkpoint " .. checkpointNumber .. " alcanzado!"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = frame
    
    -- Animación de entrada
    frame.Position = UDim2.new(0.5, -100, 0, -50)
    local enterTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
        Position = UDim2.new(0.5, -100, 0.3, 0)
    })
    enterTween:Play()
    
    -- Animación de salida
    spawn(function()
        wait(2)
        local exitTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
            Position = UDim2.new(0.5, -100, 0, -50)
        })
        exitTween:Play()
        exitTween.Completed:Connect(function()
            indicator:Destroy()
        end)
    end)
end

-- Función para mostrar indicador de muerte
function HUDSystem.ShowDeathIndicator()
    if not IsHUDActive then return end
    
    local indicator = Instance.new("ScreenGui")
    indicator.Name = "DeathIndicator"
    indicator.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(0.5, -100, 0.3, 0)
    frame.BackgroundColor3 = GameConstants.UI.ERROR_COLOR
    frame.BorderSizePixel = 0
    frame.Parent = indicator
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = "¡Has muerto!"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = frame
    
    -- Animación de entrada
    frame.Position = UDim2.new(0.5, -100, 0, -50)
    local enterTween = TweenService:Create(frame, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -100, 0.3, 0)
    })
    enterTween:Play()
    
    -- Animación de salida
    spawn(function()
        wait(1.5)
        local exitTween = TweenService:Create(frame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -100, 0, -50)
        })
        exitTween:Play()
        exitTween.Completed:Connect(function()
            indicator:Destroy()
        end)
    end)
end

-- Función para iniciar nivel
function HUDSystem.StartLevel(levelNumber)
    CurrentLevel = levelNumber
    LevelStartTime = tick()
    LevelDeaths = 0
    LevelCheckpoints = 0
    
    HUDSystem.UpdateLevelInfo(CurrentLevel, LevelDeaths, LevelCheckpoints)
end

-- Función para reiniciar nivel
function HUDSystem.RestartLevel()
    LevelStartTime = tick()
    LevelDeaths = LevelDeaths + 1
    
    HUDSystem.UpdateLevelInfo(CurrentLevel, LevelDeaths, LevelCheckpoints)
end

-- Función para completar nivel
function HUDSystem.CompleteLevel()
    local completionTime = tick() - LevelStartTime
    local minutes = math.floor(completionTime / 60)
    local seconds = math.floor(completionTime % 60)
    
    -- Mostrar estadísticas de completado
    HUDSystem.ShowLevelCompleteStats(CurrentLevel, completionTime, LevelDeaths)
end

-- Función para mostrar estadísticas de nivel completado
function HUDSystem.ShowLevelCompleteStats(levelNumber, time, deaths)
    local statsGui = Instance.new("ScreenGui")
    statsGui.Name = "LevelCompleteStats"
    statsGui.Parent = playerGui
    
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.Parent = statsGui
    
    local statsPanel = Instance.new("Frame")
    statsPanel.Size = UDim2.new(0, 400, 0, 300)
    statsPanel.Position = UDim2.new(0.5, -200, 0.5, -150)
    statsPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    statsPanel.BorderSizePixel = 0
    statsPanel.Parent = background
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
    title.Text = "¡Nivel " .. levelNumber .. " Completado!"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = statsPanel
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, -20, 0, 30)
    timeLabel.Position = UDim2.new(0, 10, 0, 70)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "Tiempo: " .. string.format("%02d:%02d", math.floor(time / 60), math.floor(time % 60))
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.Parent = statsPanel
    
    local deathsLabel = Instance.new("TextLabel")
    deathsLabel.Size = UDim2.new(1, -20, 0, 30)
    deathsLabel.Position = UDim2.new(0, 10, 0, 110)
    deathsLabel.BackgroundTransparency = 1
    deathsLabel.Text = "Muertes: " .. deaths
    deathsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    deathsLabel.TextScaled = true
    deathsLabel.Font = Enum.Font.Gotham
    deathsLabel.Parent = statsPanel
    
    local checkpointsLabel = Instance.new("TextLabel")
    checkpointsLabel.Size = UDim2.new(1, -20, 0, 30)
    checkpointsLabel.Position = UDim2.new(0, 10, 0, 150)
    checkpointsLabel.BackgroundTransparency = 1
    checkpointsLabel.Text = "Checkpoints: " .. LevelCheckpoints
    checkpointsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    checkpointsLabel.TextScaled = true
    checkpointsLabel.Font = Enum.Font.Gotham
    checkpointsLabel.Parent = statsPanel
    
    local continueButton = Instance.new("TextButton")
    continueButton.Size = UDim2.new(0, 150, 0, 40)
    continueButton.Position = UDim2.new(0.5, -75, 1, -60)
    continueButton.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
    continueButton.Text = "CONTINUAR"
    continueButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    continueButton.TextScaled = true
    continueButton.Font = Enum.Font.GothamBold
    continueButton.Parent = statsPanel
    
    continueButton.MouseButton1Click:Connect(function()
        statsGui:Destroy()
    end)
end

-- Función para ocultar HUD
function HUDSystem.HideHUD()
    if HUDGui then
        HUDGui.Enabled = false
        IsHUDActive = false
    end
end

-- Función para mostrar HUD
function HUDSystem.ShowHUD()
    if HUDGui then
        HUDGui.Enabled = true
        IsHUDActive = true
        HUDSystem.StartTimeUpdate()
    end
end

-- Función para limpiar HUD
function HUDSystem.CleanupHUD()
    if HUDGui then
        HUDGui:Destroy()
        HUDGui = nil
    end
    
    HUDElements = {}
    IsHUDActive = false
end

return HUDSystem 