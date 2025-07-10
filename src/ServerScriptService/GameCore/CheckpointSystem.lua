-- CheckpointSystem.lua
-- Sistema de checkpoints para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)
local PlayerStats = require(ReplicatedStorage.SharedModules.PlayerStats)

-- Importar PlayerDataManager
local PlayerDataManager = require(script.Parent.PlayerDataManager)

local CheckpointSystem = {}

-- Tabla para almacenar checkpoints activos por jugador
local ActiveCheckpoints = {}

-- Configuración de checkpoints por nivel
local CheckpointConfigs = {
    [1] = { -- Level 1: Forest
        {
            id = 1,
            type = GameConstants.CHECKPOINT_TYPES.STANDARD,
            position = Vector3.new(50, 10, 0),
            cost = 0,
            description = "Checkpoint del Tutorial"
        },
        {
            id = 2,
            type = GameConstants.CHECKPOINT_TYPES.PREMIUM,
            position = Vector3.new(150, 15, 0),
            cost = GameConstants.CURRENCY.PREMIUM_CHECKPOINT_COST,
            description = "Checkpoint Premium - Da buff temporal"
        },
        {
            id = 3,
            type = GameConstants.CHECKPOINT_TYPES.HIDDEN,
            position = Vector3.new(250, 20, 0),
            cost = 0,
            description = "Checkpoint Secreto - Ruta alternativa"
        },
        {
            id = 4,
            type = GameConstants.CHECKPOINT_TYPES.STANDARD,
            position = Vector3.new(400, 25, 0),
            cost = 0,
            description = "Checkpoint Final"
        }
    },
    [2] = { -- Level 2: Water
        {
            id = 1,
            type = GameConstants.CHECKPOINT_TYPES.STANDARD,
            position = Vector3.new(75, 5, 0),
            cost = 0,
            description = "Checkpoint Acuático"
        },
        {
            id = 2,
            type = GameConstants.CHECKPOINT_TYPES.TEMPORAL,
            position = Vector3.new(200, 10, 0),
            cost = 0,
            description = "Checkpoint Temporal - Solo 60 segundos"
        },
        {
            id = 3,
            type = GameConstants.CHECKPOINT_TYPES.PREMIUM,
            position = Vector3.new(350, 15, 0),
            cost = GameConstants.CURRENCY.PREMIUM_CHECKPOINT_COST,
            description = "Checkpoint Premium - Resistencia al agua"
        }
    }
}

-- Función para obtener configuración de checkpoints de un nivel
function CheckpointSystem.GetLevelCheckpoints(level)
    return CheckpointConfigs[level] or {}
end

-- Función para activar un checkpoint
function CheckpointSystem.ActivateCheckpoint(player, level, checkpointId)
    local userId = player.UserId
    local checkpoints = CheckpointSystem.GetLevelCheckpoints(level)
    local checkpoint = nil
    
    -- Buscar el checkpoint por ID
    for _, cp in ipairs(checkpoints) do
        if cp.id == checkpointId then
            checkpoint = cp
            break
        end
    end
    
    if not checkpoint then
        warn("Checkpoint no encontrado: Nivel " .. level .. ", ID " .. checkpointId)
        return false
    end
    
    -- Verificar si el jugador puede activar el checkpoint
    if checkpoint.type == GameConstants.CHECKPOINT_TYPES.PREMIUM then
        local playerData = PlayerDataManager.GetPlayerData(player)
        if playerData.Currency.Coins < checkpoint.cost then
            -- Notificar al cliente que no tiene suficientes monedas
            -- TODO: Implementar RemoteEvent para notificación
            return false
        end
        
        -- Cobrar el costo
        PlayerDataManager.AddCoins(player, -checkpoint.cost)
    end
    
    -- Registrar checkpoint en los datos del jugador
    PlayerDataManager.UpdateCheckpoint(player, level, checkpointId)
    
    -- Guardar checkpoint activo
    if not ActiveCheckpoints[userId] then
        ActiveCheckpoints[userId] = {}
    end
    if not ActiveCheckpoints[userId][level] then
        ActiveCheckpoints[userId][level] = {}
    end
    
    ActiveCheckpoints[userId][level][checkpointId] = {
        checkpoint = checkpoint,
        activatedAt = tick(),
        isTemporal = checkpoint.type == GameConstants.CHECKPOINT_TYPES.TEMPORAL
    }
    
    -- Aplicar efectos especiales según el tipo
    CheckpointSystem.ApplyCheckpointEffects(player, checkpoint)
    
    print("Checkpoint activado: " .. player.Name .. " - Nivel " .. level .. ", ID " .. checkpointId)
    return true
end

-- Función para aplicar efectos de checkpoint
function CheckpointSystem.ApplyCheckpointEffects(player, checkpoint)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if checkpoint.type == GameConstants.CHECKPOINT_TYPES.PREMIUM then
        -- Aplicar buff temporal
        local originalWalkSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = originalWalkSpeed * 1.5
        
        -- Restaurar después de 30 segundos
        spawn(function()
            wait(30)
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = originalWalkSpeed
            end
        end)
        
        -- Efecto visual
        CheckpointSystem.CreateActivationEffect(character.HumanoidRootPart)
        
    elseif checkpoint.type == GameConstants.CHECKPOINT_TYPES.HIDDEN then
        -- Logro especial
        local playerData = PlayerDataManager.GetPlayerData(player)
        if playerData and not playerData.Achievements["HiddenCheckpointFound"] then
            playerData.Achievements["HiddenCheckpointFound"] = true
            PlayerDataManager.AddCoins(player, 50) -- Bonus por encontrar checkpoint oculto
        end
        
        -- Efecto visual especial
        CheckpointSystem.CreateHiddenActivationEffect(character.HumanoidRootPart)
    end
end

-- Función para crear efecto de activación
function CheckpointSystem.CreateActivationEffect(rootPart)
    if not rootPart then return end
    
    -- Crear partículas de activación
    local attachment = Instance.new("Attachment")
    attachment.Parent = rootPart
    
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = attachment
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
    particleEmitter.Size = NumberSequence.new(0.5)
    particleEmitter.Lifetime = NumberRange.new(1, 2)
    particleEmitter.Rate = 50
    particleEmitter.Speed = NumberRange.new(5, 10)
    
    -- Detener después de 2 segundos
    spawn(function()
        wait(2)
        if particleEmitter and particleEmitter.Parent then
            particleEmitter:Destroy()
        end
        if attachment and attachment.Parent then
            attachment:Destroy()
        end
    end)
end

-- Función para crear efecto de activación de checkpoint oculto
function CheckpointSystem.CreateHiddenActivationEffect(rootPart)
    if not rootPart then return end
    
    -- Efecto especial para checkpoint oculto
    local attachment = Instance.new("Attachment")
    attachment.Parent = rootPart
    
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = attachment
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)) -- Dorado
    particleEmitter.Size = NumberSequence.new(1)
    particleEmitter.Lifetime = NumberRange.new(2, 3)
    particleEmitter.Rate = 100
    particleEmitter.Speed = NumberRange.new(10, 15)
    
    -- Detener después de 3 segundos
    spawn(function()
        wait(3)
        if particleEmitter and particleEmitter.Parent then
            particleEmitter:Destroy()
        end
        if attachment and attachment.Parent then
            attachment:Destroy()
        end
    end)
end

-- Función para respawnear al jugador en el último checkpoint
function CheckpointSystem.RespawnAtCheckpoint(player, level)
    local userId = player.UserId
    local character = player.Character
    
    if not character or not ActiveCheckpoints[userId] or not ActiveCheckpoints[userId][level] then
        return false
    end
    
    -- Encontrar el checkpoint más reciente
    local latestCheckpoint = nil
    local latestTime = 0
    
    for checkpointId, checkpointData in pairs(ActiveCheckpoints[userId][level]) do
        if checkpointData.activatedAt > latestTime then
            latestTime = checkpointData.activatedAt
            latestCheckpoint = checkpointData.checkpoint
        end
    end
    
    if latestCheckpoint then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(latestCheckpoint.position)
            return true
        end
    end
    
    return false
end

-- Función para limpiar checkpoints temporales expirados
function CheckpointSystem.CleanupTemporalCheckpoints()
    local currentTime = tick()
    
    for userId, levelData in pairs(ActiveCheckpoints) do
        for level, checkpointData in pairs(levelData) do
            for checkpointId, data in pairs(checkpointData) do
                if data.isTemporal and (currentTime - data.activatedAt) > 60 then
                    -- Checkpoint temporal expirado
                    checkpointData[checkpointId] = nil
                    print("Checkpoint temporal expirado para jugador " .. userId .. ", nivel " .. level)
                end
            end
        end
    end
end

-- Función para obtener información de checkpoint
function CheckpointSystem.GetCheckpointInfo(level, checkpointId)
    local checkpoints = CheckpointSystem.GetLevelCheckpoints(level)
    
    for _, checkpoint in ipairs(checkpoints) do
        if checkpoint.id == checkpointId then
            return checkpoint
        end
    end
    
    return nil
end

-- Función para verificar si un jugador tiene un checkpoint activo
function CheckpointSystem.HasActiveCheckpoint(player, level, checkpointId)
    local userId = player.UserId
    return ActiveCheckpoints[userId] and 
           ActiveCheckpoints[userId][level] and 
           ActiveCheckpoints[userId][level][checkpointId] ~= nil
end

-- Limpiar checkpoints temporales cada 30 segundos
spawn(function()
    while true do
        wait(30)
        CheckpointSystem.CleanupTemporalCheckpoints()
    end
end)

-- Limpiar datos cuando el jugador sale
Players.PlayerRemoving:Connect(function(player)
    local userId = player.UserId
    ActiveCheckpoints[userId] = nil
end)

return CheckpointSystem 