-- AntiCheat.lua
-- Sistema básico de anti-cheat para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

local AntiCheat = {}

-- Tabla para almacenar datos de verificación por jugador
local PlayerVerificationData = {}

-- Configuración de anti-cheat
local AntiCheatConfig = {
    -- Límites de velocidad
    MAX_WALK_SPEED = 50,
    MAX_JUMP_POWER = 100,
    
    -- Límites de posición
    MAX_Y_POSITION = 1000,
    MIN_Y_POSITION = -100,
    
    -- Límites de tiempo
    MAX_LEVEL_TIME = GameConstants.ANTI_CHEAT.MAX_LEVEL_TIME,
    
    -- Configuración de detección
    DETECTION_INTERVAL = 1, -- Verificar cada segundo
    WARNING_THRESHOLD = 3, -- Número de advertencias antes de acción
    MAX_WARNINGS = 5
}

-- Función para inicializar verificación de un jugador
function AntiCheat.InitializePlayer(player)
    local userId = player.UserId
    
    PlayerVerificationData[userId] = {
        warnings = 0,
        lastPosition = Vector3.new(0, 0, 0),
        lastCheckTime = tick(),
        levelStartTime = nil,
        currentLevel = nil,
        suspiciousActions = {}
    }
    
    print("Anti-cheat inicializado para " .. player.Name)
end

-- Función para verificar velocidad del jugador
function AntiCheat.CheckPlayerSpeed(player)
    local character = player.Character
    if not character then return true end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return true end
    
    local userId = player.UserId
    local verificationData = PlayerVerificationData[userId]
    if not verificationData then return true end
    
    -- Verificar velocidad de caminar
    if humanoid.WalkSpeed > AntiCheatConfig.MAX_WALK_SPEED then
        AntiCheat.LogSuspiciousAction(player, "Velocidad de caminar excesiva: " .. humanoid.WalkSpeed)
        return false
    end
    
    -- Verificar poder de salto
    if humanoid.JumpPower > AntiCheatConfig.MAX_JUMP_POWER then
        AntiCheat.LogSuspiciousAction(player, "Poder de salto excesivo: " .. humanoid.JumpPower)
        return false
    end
    
    return true
end

-- Función para verificar posición del jugador
function AntiCheat.CheckPlayerPosition(player)
    local character = player.Character
    if not character then return true end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return true end
    
    local userId = player.UserId
    local verificationData = PlayerVerificationData[userId]
    if not verificationData then return true end
    
    local currentPosition = rootPart.Position
    
    -- Verificar límites de altura
    if currentPosition.Y > AntiCheatConfig.MAX_Y_POSITION then
        AntiCheat.LogSuspiciousAction(player, "Posición Y excesiva: " .. currentPosition.Y)
        return false
    end
    
    if currentPosition.Y < AntiCheatConfig.MIN_Y_POSITION then
        AntiCheat.LogSuspiciousAction(player, "Posición Y muy baja: " .. currentPosition.Y)
        return false
    end
    
    -- Verificar teletransporte sospechoso
    local distance = (currentPosition - verificationData.lastPosition).Magnitude
    if distance > GameConstants.ANTI_CHEAT.MAX_TELEPORT_DISTANCE then
        AntiCheat.LogSuspiciousAction(player, "Teletransporte sospechoso: " .. distance .. " studs")
        return false
    end
    
    verificationData.lastPosition = currentPosition
    return true
end

-- Función para verificar tiempo de nivel
function AntiCheat.CheckLevelTime(player, level)
    local userId = player.UserId
    local verificationData = PlayerVerificationData[userId]
    if not verificationData then return true end
    
    if verificationData.currentLevel == level and verificationData.levelStartTime then
        local currentTime = tick()
        local levelTime = currentTime - verificationData.levelStartTime
        
        if levelTime > AntiCheatConfig.MAX_LEVEL_TIME then
            AntiCheat.LogSuspiciousAction(player, "Tiempo de nivel excesivo: " .. levelTime .. " segundos")
            return false
        end
    end
    
    return true
end

-- Función para registrar inicio de nivel
function AntiCheat.RegisterLevelStart(player, level)
    local userId = player.UserId
    local verificationData = PlayerVerificationData[userId]
    if not verificationData then return end
    
    verificationData.currentLevel = level
    verificationData.levelStartTime = tick()
    
    print("Nivel iniciado para " .. player.Name .. ": Nivel " .. level)
end

-- Función para registrar fin de nivel
function AntiCheat.RegisterLevelEnd(player, level)
    local userId = player.UserId
    local verificationData = PlayerVerificationData[userId]
    if not verificationData then return end
    
    if verificationData.currentLevel == level then
        verificationData.currentLevel = nil
        verificationData.levelStartTime = nil
    end
    
    print("Nivel terminado para " .. player.Name .. ": Nivel " .. level)
end

-- Función para registrar acción sospechosa
function AntiCheat.LogSuspiciousAction(player, reason)
    local userId = player.UserId
    local verificationData = PlayerVerificationData[userId]
    if not verificationData then return end
    
    verificationData.warnings = verificationData.warnings + 1
    table.insert(verificationData.suspiciousActions, {
        time = tick(),
        reason = reason
    })
    
    warn("Anti-cheat: " .. player.Name .. " - " .. reason .. " (Advertencia " .. verificationData.warnings .. "/" .. AntiCheatConfig.MAX_WARNINGS .. ")")
    
    -- Tomar acción si se excede el límite de advertencias
    if verificationData.warnings >= AntiCheatConfig.MAX_WARNINGS then
        AntiCheat.TakeAction(player, "Demasiadas acciones sospechosas")
    end
end

-- Función para tomar acción contra un jugador
function AntiCheat.TakeAction(player, reason)
    warn("Anti-cheat: Tomando acción contra " .. player.Name .. " - Razón: " .. reason)
    
    -- Resetear velocidad y posición del jugador
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = GameConstants.PHYSICS.WALK_SPEED
            humanoid.JumpPower = GameConstants.PHYSICS.JUMP_POWER
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            -- Teleportar al spawn del lobby
            rootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end
    
    -- Resetear advertencias
    local userId = player.UserId
    local verificationData = PlayerVerificationData[userId]
    if verificationData then
        verificationData.warnings = 0
        verificationData.suspiciousActions = {}
    end
    
    -- TODO: Implementar sistema de reporte y moderación
    print("Jugador " .. player.Name .. " ha sido reseteado por anti-cheat")
end

-- Función para obtener estadísticas de anti-cheat de un jugador
function AntiCheat.GetPlayerStats(player)
    local userId = player.UserId
    local verificationData = PlayerVerificationData[userId]
    
    if not verificationData then
        return {
            warnings = 0,
            suspiciousActions = {},
            isClean = true
        }
    end
    
    return {
        warnings = verificationData.warnings,
        suspiciousActions = verificationData.suspiciousActions,
        isClean = verificationData.warnings < AntiCheatConfig.WARNING_THRESHOLD
    }
end

-- Función para limpiar datos de un jugador
function AntiCheat.CleanupPlayer(player)
    local userId = player.UserId
    PlayerVerificationData[userId] = nil
end

-- Función principal de verificación
function AntiCheat.RunVerification(player)
    if not AntiCheat.CheckPlayerSpeed(player) then
        return false
    end
    
    if not AntiCheat.CheckPlayerPosition(player) then
        return false
    end
    
    -- Verificar tiempo de nivel si está en uno
    local userId = player.UserId
    local verificationData = PlayerVerificationData[userId]
    if verificationData and verificationData.currentLevel then
        if not AntiCheat.CheckLevelTime(player, verificationData.currentLevel) then
            return false
        end
    end
    
    return true
end

-- Inicializar verificación para nuevos jugadores
Players.PlayerAdded:Connect(function(player)
    AntiCheat.InitializePlayer(player)
    
    -- Ejecutar verificación periódica
    spawn(function()
        while player.Parent do
            AntiCheat.RunVerification(player)
            wait(AntiCheatConfig.DETECTION_INTERVAL)
        end
    end)
end)

-- Limpiar datos cuando el jugador sale
Players.PlayerRemoving:Connect(function(player)
    AntiCheat.CleanupPlayer(player)
end)

return AntiCheat 