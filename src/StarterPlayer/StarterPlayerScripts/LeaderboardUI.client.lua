-- LeaderboardUI.client.lua
-- Interfaz de usuario para leaderboards y rankings del juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

-- Eventos remotos
local RankingEvents = ReplicatedStorage:WaitForChild("RankingEvents")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local LeaderboardUI = {}

-- Referencias de la UI
local LeaderboardGui = nil
local CurrentLeaderboard = nil
local LeaderboardData = {}

-- Tipos de leaderboard
local LeaderboardTypes = {
    GLOBAL = "global",
    LEVEL = "level",
    WEEKLY = "weekly",
    MONTHLY = "monthly"
}

-- Función para crear la UI del leaderboard
function LeaderboardUI.CreateLeaderboardUI()
    if LeaderboardGui then
        LeaderboardGui:Destroy()
    end
    
    LeaderboardGui = Instance.new("ScreenGui")
    LeaderboardGui.Name = "LeaderboardUI"
    LeaderboardGui.Parent = playerGui
    
    -- Fondo principal
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.3
    background.Parent = LeaderboardGui
    
    -- Panel principal
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(0, 800, 0, 600)
    mainPanel.Position = UDim2.new(0.5, -400, 0.5, -300)
    mainPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainPanel.BorderSizePixel = 0
    mainPanel.Parent = background
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    title.Text = "LEADERBOARD"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainPanel
    
    -- Panel de botones de tipo de leaderboard
    local buttonPanel = Instance.new("Frame")
    buttonPanel.Name = "ButtonPanel"
    buttonPanel.Size = UDim2.new(1, -40, 0, 50)
    buttonPanel.Position = UDim2.new(0, 20, 0, 80)
    buttonPanel.BackgroundTransparency = 1
    buttonPanel.Parent = mainPanel
    
    -- Botón Global
    local globalButton = Instance.new("TextButton")
    globalButton.Name = "GlobalButton"
    globalButton.Size = UDim2.new(0.25, -10, 1, 0)
    globalButton.Position = UDim2.new(0, 0, 0, 0)
    globalButton.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    globalButton.Text = "GLOBAL"
    globalButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    globalButton.TextScaled = true
    globalButton.Font = Enum.Font.GothamBold
    globalButton.Parent = buttonPanel
    
    -- Botón por Nivel
    local levelButton = Instance.new("TextButton")
    levelButton.Name = "LevelButton"
    levelButton.Size = UDim2.new(0.25, -10, 1, 0)
    levelButton.Position = UDim2.new(0.25, 0, 0, 0)
    levelButton.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
    levelButton.Text = "POR NIVEL"
    levelButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    levelButton.TextScaled = true
    levelButton.Font = Enum.Font.GothamBold
    levelButton.Parent = buttonPanel
    
    -- Botón Semanal
    local weeklyButton = Instance.new("TextButton")
    weeklyButton.Name = "WeeklyButton"
    weeklyButton.Size = UDim2.new(0.25, -10, 1, 0)
    weeklyButton.Position = UDim2.new(0.5, 0, 0, 0)
    weeklyButton.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
    weeklyButton.Text = "SEMANAL"
    weeklyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    weeklyButton.TextScaled = true
    weeklyButton.Font = Enum.Font.GothamBold
    weeklyButton.Parent = buttonPanel
    
    -- Botón Mensual
    local monthlyButton = Instance.new("TextButton")
    monthlyButton.Name = "MonthlyButton"
    monthlyButton.Size = UDim2.new(0.25, -10, 1, 0)
    monthlyButton.Position = UDim2.new(0.75, 0, 0, 0)
    monthlyButton.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
    monthlyButton.Text = "MENSUAL"
    monthlyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    monthlyButton.TextScaled = true
    monthlyButton.Font = Enum.Font.GothamBold
    monthlyButton.Parent = buttonPanel
    
    -- Panel de selección de nivel (para leaderboard por nivel)
    local levelSelectionPanel = Instance.new("Frame")
    levelSelectionPanel.Name = "LevelSelectionPanel"
    levelSelectionPanel.Size = UDim2.new(1, -40, 0, 40)
    levelSelectionPanel.Position = UDim2.new(0, 20, 0, 150)
    levelSelectionPanel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    levelSelectionPanel.BorderSizePixel = 0
    levelSelectionPanel.Visible = false
    levelSelectionPanel.Parent = mainPanel
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Size = UDim2.new(0.2, 0, 1, 0)
    levelLabel.Position = UDim2.new(0, 10, 0, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Nivel:"
    levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelLabel.TextScaled = true
    levelLabel.Font = Enum.Font.Gotham
    levelLabel.Parent = levelSelectionPanel
    
    local levelDropdown = Instance.new("TextButton")
    levelDropdown.Name = "LevelDropdown"
    levelDropdown.Size = UDim2.new(0.3, 0, 0.8, 0)
    levelDropdown.Position = UDim2.new(0.25, 0, 0.1, 0)
    levelDropdown.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    levelDropdown.Text = "1"
    levelDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelDropdown.TextScaled = true
    levelDropdown.Font = Enum.Font.GothamBold
    levelDropdown.Parent = levelSelectionPanel
    
    -- Panel de lista de jugadores
    local playerListPanel = Instance.new("Frame")
    playerListPanel.Name = "PlayerListPanel"
    playerListPanel.Size = UDim2.new(1, -40, 1, -200)
    playerListPanel.Position = UDim2.new(0, 20, 0, 200)
    playerListPanel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    playerListPanel.BorderSizePixel = 0
    playerListPanel.Parent = mainPanel
    
    -- Encabezados de la tabla
    local headersPanel = Instance.new("Frame")
    headersPanel.Name = "HeadersPanel"
    headersPanel.Size = UDim2.new(1, 0, 0, 40)
    headersPanel.Position = UDim2.new(0, 0, 0, 0)
    headersPanel.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    headersPanel.BorderSizePixel = 0
    headersPanel.Parent = playerListPanel
    
    -- Encabezado de posición
    local rankHeader = Instance.new("TextLabel")
    rankHeader.Name = "RankHeader"
    rankHeader.Size = UDim2.new(0.1, 0, 1, 0)
    rankHeader.Position = UDim2.new(0, 0, 0, 0)
    rankHeader.BackgroundTransparency = 1
    rankHeader.Text = "#"
    rankHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    rankHeader.TextScaled = true
    rankHeader.Font = Enum.Font.GothamBold
    rankHeader.Parent = headersPanel
    
    -- Encabezado de jugador
    local playerHeader = Instance.new("TextLabel")
    playerHeader.Name = "PlayerHeader"
    playerHeader.Size = UDim2.new(0.4, 0, 1, 0)
    playerHeader.Position = UDim2.new(0.1, 0, 0, 0)
    playerHeader.BackgroundTransparency = 1
    playerHeader.Text = "JUGADOR"
    playerHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerHeader.TextScaled = true
    playerHeader.Font = Enum.Font.GothamBold
    playerHeader.Parent = headersPanel
    
    -- Encabezado de puntuación
    local scoreHeader = Instance.new("TextLabel")
    scoreHeader.Name = "ScoreHeader"
    scoreHeader.Size = UDim2.new(0.2, 0, 1, 0)
    scoreHeader.Position = UDim2.new(0.5, 0, 0, 0)
    scoreHeader.BackgroundTransparency = 1
    scoreHeader.Text = "PUNTUACIÓN"
    scoreHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    scoreHeader.TextScaled = true
    scoreHeader.Font = Enum.Font.GothamBold
    scoreHeader.Parent = headersPanel
    
    -- Encabezado de nivel
    local levelHeader = Instance.new("TextLabel")
    levelHeader.Name = "LevelHeader"
    levelHeader.Size = UDim2.new(0.15, 0, 1, 0)
    levelHeader.Position = UDim2.new(0.7, 0, 0, 0)
    levelHeader.BackgroundTransparency = 1
    levelHeader.Text = "NIVEL"
    levelHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelHeader.TextScaled = true
    levelHeader.Font = Enum.Font.GothamBold
    levelHeader.Parent = headersPanel
    
    -- Encabezado de tiempo
    local timeHeader = Instance.new("TextLabel")
    timeHeader.Name = "TimeHeader"
    timeHeader.Size = UDim2.new(0.15, 0, 1, 0)
    timeHeader.Position = UDim2.new(0.85, 0, 0, 0)
    timeHeader.BackgroundTransparency = 1
    timeHeader.Text = "TIEMPO"
    timeHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeHeader.TextScaled = true
    timeHeader.Font = Enum.Font.GothamBold
    timeHeader.Parent = headersPanel
    
    -- Lista de jugadores (ScrollFrame)
    local playerList = Instance.new("ScrollingFrame")
    playerList.Name = "PlayerList"
    playerList.Size = UDim2.new(1, 0, 1, -40)
    playerList.Position = UDim2.new(0, 0, 0, 40)
    playerList.BackgroundTransparency = 1
    playerList.ScrollBarThickness = 6
    playerList.Parent = playerListPanel
    
    -- Botón de cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 150, 0, 40)
    closeButton.Position = UDim2.new(0.5, -75, 1, -60)
    closeButton.BackgroundColor3 = GameConstants.UI.ERROR_COLOR
    closeButton.Text = "CERRAR"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainPanel
    
    -- Configurar eventos de botones
    globalButton.MouseButton1Click:Connect(function()
        LeaderboardUI.SwitchLeaderboardType("global")
    end)
    
    levelButton.MouseButton1Click:Connect(function()
        LeaderboardUI.SwitchLeaderboardType("level")
    end)
    
    weeklyButton.MouseButton1Click:Connect(function()
        LeaderboardUI.SwitchLeaderboardType("weekly")
    end)
    
    monthlyButton.MouseButton1Click:Connect(function()
        LeaderboardUI.SwitchLeaderboardType("monthly")
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        LeaderboardUI.HideLeaderboard()
    end)
    
    -- Configurar dropdown de nivel
    levelDropdown.MouseButton1Click:Connect(function()
        LeaderboardUI.ShowLevelDropdown()
    end)
    
    -- Cargar leaderboard global por defecto
    LeaderboardUI.SwitchLeaderboardType("global")
    
    return LeaderboardGui
end

-- Función para cambiar tipo de leaderboard
function LeaderboardUI.SwitchLeaderboardType(leaderboardType)
    CurrentLeaderboard = leaderboardType
    
    -- Actualizar colores de botones
    local buttonPanel = LeaderboardGui.MainPanel.ButtonPanel
    local buttons = {
        global = buttonPanel.GlobalButton,
        level = buttonPanel.LevelButton,
        weekly = buttonPanel.WeeklyButton,
        monthly = buttonPanel.MonthlyButton
    }
    
    for type, button in pairs(buttons) do
        if type == leaderboardType then
            button.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
            button.TextColor3 = Color3.fromRGB(0, 0, 0)
        end
    end
    
    -- Mostrar/ocultar panel de selección de nivel
    local levelSelectionPanel = LeaderboardGui.MainPanel.LevelSelectionPanel
    levelSelectionPanel.Visible = (leaderboardType == "level")
    
    -- Cargar datos del leaderboard
    LeaderboardUI.LoadLeaderboardData(leaderboardType)
end

-- Función para cargar datos del leaderboard
function LeaderboardUI.LoadLeaderboardData(leaderboardType)
    local playerList = LeaderboardGui.MainPanel.PlayerListPanel.PlayerList
    
    -- Limpiar lista actual
    for _, child in pairs(playerList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Mostrar indicador de carga
    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Name = "LoadingLabel"
    loadingLabel.Size = UDim2.new(1, 0, 0, 50)
    loadingLabel.Position = UDim2.new(0, 0, 0, 0)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Text = "Cargando datos..."
    loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingLabel.TextScaled = true
    loadingLabel.Font = Enum.Font.Gotham
    loadingLabel.Parent = playerList
    
    -- Cargar datos según el tipo
    if leaderboardType == "global" then
        LeaderboardUI.LoadGlobalLeaderboard(playerList)
    elseif leaderboardType == "level" then
        local selectedLevel = tonumber(LeaderboardGui.MainPanel.LevelSelectionPanel.LevelDropdown.Text) or 1
        LeaderboardUI.LoadLevelLeaderboard(playerList, selectedLevel)
    elseif leaderboardType == "weekly" then
        LeaderboardUI.LoadWeeklyLeaderboard(playerList)
    elseif leaderboardType == "monthly" then
        LeaderboardUI.LoadMonthlyLeaderboard(playerList)
    end
end

-- Función para cargar leaderboard global
function LeaderboardUI.LoadGlobalLeaderboard(playerList)
    spawn(function()
        local success, topPlayers = pcall(function()
            return RankingEvents.GetTopPlayers:InvokeServer(20)
        end)
        
        if success and topPlayers then
            LeaderboardUI.DisplayLeaderboardData(playerList, topPlayers, "global")
        else
            LeaderboardUI.ShowError(playerList, "Error al cargar leaderboard global")
        end
    end)
end

-- Función para cargar leaderboard por nivel
function LeaderboardUI.LoadLevelLeaderboard(playerList, levelNumber)
    spawn(function()
        local success, levelRecords = pcall(function()
            return RankingEvents.GetLevelRecords:InvokeServer(levelNumber, 20)
        end)
        
        if success and levelRecords then
            LeaderboardUI.DisplayLeaderboardData(playerList, levelRecords, "level")
        else
            LeaderboardUI.ShowError(playerList, "Error al cargar leaderboard del nivel " .. levelNumber)
        end
    end)
end

-- Función para cargar leaderboard semanal
function LeaderboardUI.LoadWeeklyLeaderboard(playerList)
    spawn(function()
        local success, weeklyStats = pcall(function()
            return RankingEvents.GetWeeklyStats:InvokeServer(20)
        end)
        
        if success and weeklyStats then
            LeaderboardUI.DisplayLeaderboardData(playerList, weeklyStats, "weekly")
        else
            LeaderboardUI.ShowError(playerList, "Error al cargar leaderboard semanal")
        end
    end)
end

-- Función para cargar leaderboard mensual
function LeaderboardUI.LoadMonthlyLeaderboard(playerList)
    spawn(function()
        local success, monthlyStats = pcall(function()
            return RankingEvents.GetMonthlyStats:InvokeServer(20)
        end)
        
        if success and monthlyStats then
            LeaderboardUI.DisplayLeaderboardData(playerList, monthlyStats, "monthly")
        else
            LeaderboardUI.ShowError(playerList, "Error al cargar leaderboard mensual")
        end
    end)
end

-- Función para mostrar datos del leaderboard
function LeaderboardUI.DisplayLeaderboardData(playerList, data, leaderboardType)
    -- Remover indicador de carga
    local loadingLabel = playerList:FindFirstChild("LoadingLabel")
    if loadingLabel then
        loadingLabel:Destroy()
    end
    
    -- Mostrar datos
    for i, playerData in ipairs(data) do
        local playerRow = Instance.new("Frame")
        playerRow.Name = "PlayerRow" .. i
        playerRow.Size = UDim2.new(1, 0, 0, 40)
        playerRow.Position = UDim2.new(0, 0, 0, (i-1) * 45)
        playerRow.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(60, 60, 60)
        playerRow.BorderSizePixel = 0
        playerRow.Parent = playerList
        
        -- Posición
        local rankLabel = Instance.new("TextLabel")
        rankLabel.Name = "Rank"
        rankLabel.Size = UDim2.new(0.1, 0, 1, 0)
        rankLabel.Position = UDim2.new(0, 0, 0, 0)
        rankLabel.BackgroundTransparency = 1
        rankLabel.Text = "#" .. playerData.Rank
        rankLabel.TextColor3 = i <= 3 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255)
        rankLabel.TextScaled = true
        rankLabel.Font = Enum.Font.GothamBold
        rankLabel.Parent = playerRow
        
        -- Nombre del jugador
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
        nameLabel.Position = UDim2.new(0.1, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = playerData.Username
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = playerRow
        
        -- Puntuación/Tiempo
        local scoreLabel = Instance.new("TextLabel")
        scoreLabel.Name = "Score"
        scoreLabel.Size = UDim2.new(0.2, 0, 1, 0)
        scoreLabel.Position = UDim2.new(0.5, 0, 0, 0)
        scoreLabel.BackgroundTransparency = 1
        
        if leaderboardType == "global" then
            scoreLabel.Text = tostring(playerData.Score)
        elseif leaderboardType == "level" then
            local minutes = math.floor(playerData.Time / 60)
            local seconds = math.floor(playerData.Time % 60)
            scoreLabel.Text = string.format("%02d:%02d", minutes, seconds)
        elseif leaderboardType == "weekly" or leaderboardType == "monthly" then
            scoreLabel.Text = tostring(playerData.LevelsCompleted)
        end
        
        scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        scoreLabel.TextScaled = true
        scoreLabel.Font = Enum.Font.Gotham
        scoreLabel.Parent = playerRow
        
        -- Nivel
        local levelLabel = Instance.new("TextLabel")
        levelLabel.Name = "Level"
        levelLabel.Size = UDim2.new(0.15, 0, 1, 0)
        levelLabel.Position = UDim2.new(0.7, 0, 0, 0)
        levelLabel.BackgroundTransparency = 1
        
        if leaderboardType == "global" then
            levelLabel.Text = tostring(playerData.BestLevel)
        elseif leaderboardType == "level" then
            levelLabel.Text = tostring(playerData.Deaths)
        elseif leaderboardType == "weekly" or leaderboardType == "monthly" then
            levelLabel.Text = tostring(playerData.HighestLevel)
        end
        
        levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        levelLabel.TextScaled = true
        levelLabel.Font = Enum.Font.Gotham
        levelLabel.Parent = playerRow
        
        -- Tiempo/Información adicional
        local timeLabel = Instance.new("TextLabel")
        timeLabel.Name = "Time"
        timeLabel.Size = UDim2.new(0.15, 0, 1, 0)
        timeLabel.Position = UDim2.new(0.85, 0, 0, 0)
        timeLabel.BackgroundTransparency = 1
        
        if leaderboardType == "global" then
            local minutes = math.floor(playerData.BestTime / 60)
            local seconds = math.floor(playerData.BestTime % 60)
            timeLabel.Text = string.format("%02d:%02d", minutes, seconds)
        elseif leaderboardType == "level" then
            timeLabel.Text = tostring(playerData.Checkpoints)
        elseif leaderboardType == "weekly" or leaderboardType == "monthly" then
            local totalMinutes = math.floor(playerData.TotalTime / 60)
            local totalSeconds = math.floor(playerData.TotalTime % 60)
            timeLabel.Text = string.format("%02d:%02d", totalMinutes, totalSeconds)
        end
        
        timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timeLabel.TextScaled = true
        timeLabel.Font = Enum.Font.Gotham
        timeLabel.Parent = playerRow
    end
    
    -- Ajustar tamaño del ScrollFrame
    playerList.CanvasSize = UDim2.new(0, 0, 0, #data * 45)
end

-- Función para mostrar error
function LeaderboardUI.ShowError(playerList, message)
    local loadingLabel = playerList:FindFirstChild("LoadingLabel")
    if loadingLabel then
        loadingLabel:Destroy()
    end
    
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Name = "ErrorLabel"
    errorLabel.Size = UDim2.new(1, 0, 0, 50)
    errorLabel.Position = UDim2.new(0, 0, 0, 0)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = message
    errorLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    errorLabel.TextScaled = true
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.Parent = playerList
end

-- Función para mostrar dropdown de nivel
function LeaderboardUI.ShowLevelDropdown()
    local dropdown = LeaderboardGui.MainPanel.LevelSelectionPanel.LevelDropdown
    
    -- Crear panel de opciones
    local optionsPanel = Instance.new("Frame")
    optionsPanel.Name = "OptionsPanel"
    optionsPanel.Size = UDim2.new(0.3, 0, 0, 200)
    optionsPanel.Position = UDim2.new(0.25, 0, 1, 0)
    optionsPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    optionsPanel.BorderSizePixel = 0
    optionsPanel.Parent = dropdown.Parent
    
    -- Crear opciones para cada nivel
    for i = 1, GameConstants.LEVELS.TOTAL_LEVELS do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Level" .. i .. "Option"
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 35)
        optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        optionButton.Text = "Nivel " .. i
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.TextScaled = true
        optionButton.Font = Enum.Font.Gotham
        optionButton.Parent = optionsPanel
        
        optionButton.MouseButton1Click:Connect(function()
            dropdown.Text = tostring(i)
            optionsPanel:Destroy()
            LeaderboardUI.LoadLeaderboardData("level")
        end)
    end
    
    -- Remover panel después de un tiempo
    spawn(function()
        wait(5)
        if optionsPanel.Parent then
            optionsPanel:Destroy()
        end
    end)
end

-- Función para mostrar leaderboard
function LeaderboardUI.ShowLeaderboard()
    if not LeaderboardGui then
        LeaderboardUI.CreateLeaderboardUI()
    else
        LeaderboardGui.Enabled = true
    end
end

-- Función para ocultar leaderboard
function LeaderboardUI.HideLeaderboard()
    if LeaderboardGui then
        LeaderboardGui.Enabled = false
    end
end

-- Función para actualizar datos del leaderboard
function LeaderboardUI.UpdateLeaderboard()
    if CurrentLeaderboard then
        LeaderboardUI.LoadLeaderboardData(CurrentLeaderboard)
    end
end

return LeaderboardUI 