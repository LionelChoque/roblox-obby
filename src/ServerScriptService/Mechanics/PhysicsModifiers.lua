-- PhysicsModifiers.lua
-- Sistema de modificadores de física para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

local PhysicsModifiers = {}

-- Configuración de modificadores de física
local PhysicsModifierTypes = {
    GRAVITY = "Gravity",
    WIND = "Wind",
    MAGNETIC = "Magnetic",
    SLOW_MOTION = "SlowMotion",
    SPEED_BOOST = "SpeedBoost",
    JUMP_BOOST = "JumpBoost",
    ANTI_GRAVITY = "AntiGravity"
}

-- Tabla para almacenar modificadores activos por jugador
local ActiveModifiers = {}

-- Función para aplicar modificador de gravedad
function PhysicsModifiers.ApplyGravityModifier(player, gravityMultiplier, duration)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local userId = player.UserId
    if not ActiveModifiers[userId] then
        ActiveModifiers[userId] = {}
    end
    
    -- Guardar gravedad original
    local originalGravity = workspace.Gravity
    
    -- Aplicar nueva gravedad
    workspace.Gravity = workspace.Gravity * gravityMultiplier
    
    -- Registrar modificador
    table.insert(ActiveModifiers[userId], {
        type = PhysicsModifierTypes.GRAVITY,
        originalValue = originalGravity,
        modifiedValue = workspace.Gravity,
        startTime = tick(),
        duration = duration
    })
    
    -- Restaurar después del tiempo especificado
    if duration then
        spawn(function()
            wait(duration)
            PhysicsModifiers.RemoveGravityModifier(player)
        end)
    end
    
    print("Modificador de gravedad aplicado a " .. player.Name .. ": " .. gravityMultiplier .. "x")
end

-- Función para remover modificador de gravedad
function PhysicsModifiers.RemoveGravityModifier(player)
    local userId = player.UserId
    if not ActiveModifiers[userId] then return end
    
    for i, modifier in ipairs(ActiveModifiers[userId]) do
        if modifier.type == PhysicsModifierTypes.GRAVITY then
            workspace.Gravity = modifier.originalValue
            table.remove(ActiveModifiers[userId], i)
            print("Modificador de gravedad removido de " .. player.Name)
            break
        end
    end
end

-- Función para aplicar modificador de viento
function PhysicsModifiers.ApplyWindModifier(player, windDirection, windForce, duration)
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local userId = player.UserId
    if not ActiveModifiers[userId] then
        ActiveModifiers[userId] = {}
    end
    
    -- Crear fuerza de viento
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(windForce, 0, windForce)
    bodyVelocity.Velocity = windDirection * windForce
    bodyVelocity.Parent = rootPart
    
    -- Registrar modificador
    table.insert(ActiveModifiers[userId], {
        type = PhysicsModifierTypes.WIND,
        bodyVelocity = bodyVelocity,
        startTime = tick(),
        duration = duration
    })
    
    -- Remover después del tiempo especificado
    if duration then
        spawn(function()
            wait(duration)
            PhysicsModifiers.RemoveWindModifier(player)
        end)
    end
    
    print("Modificador de viento aplicado a " .. player.Name)
end

-- Función para remover modificador de viento
function PhysicsModifiers.RemoveWindModifier(player)
    local userId = player.UserId
    if not ActiveModifiers[userId] then return end
    
    for i, modifier in ipairs(ActiveModifiers[userId]) do
        if modifier.type == PhysicsModifierTypes.WIND then
            if modifier.bodyVelocity and modifier.bodyVelocity.Parent then
                modifier.bodyVelocity:Destroy()
            end
            table.remove(ActiveModifiers[userId], i)
            print("Modificador de viento removido de " .. player.Name)
            break
        end
    end
end

-- Función para aplicar modificador magnético
function PhysicsModifiers.ApplyMagneticModifier(player, targetPosition, magneticForce, duration)
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local userId = player.UserId
    if not ActiveModifiers[userId] then
        ActiveModifiers[userId] = {}
    end
    
    -- Crear fuerza magnética
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(magneticForce, magneticForce, magneticForce)
    bodyPosition.Position = targetPosition
    bodyPosition.Parent = rootPart
    
    -- Registrar modificador
    table.insert(ActiveModifiers[userId], {
        type = PhysicsModifierTypes.MAGNETIC,
        bodyPosition = bodyPosition,
        startTime = tick(),
        duration = duration
    })
    
    -- Remover después del tiempo especificado
    if duration then
        spawn(function()
            wait(duration)
            PhysicsModifiers.RemoveMagneticModifier(player)
        end)
    end
    
    print("Modificador magnético aplicado a " .. player.Name)
end

-- Función para remover modificador magnético
function PhysicsModifiers.RemoveMagneticModifier(player)
    local userId = player.UserId
    if not ActiveModifiers[userId] then return end
    
    for i, modifier in ipairs(ActiveModifiers[userId]) do
        if modifier.type == PhysicsModifierTypes.MAGNETIC then
            if modifier.bodyPosition and modifier.bodyPosition.Parent then
                modifier.bodyPosition:Destroy()
            end
            table.remove(ActiveModifiers[userId], i)
            print("Modificador magnético removido de " .. player.Name)
            break
        end
    end
end

-- Función para aplicar cámara lenta
function PhysicsModifiers.ApplySlowMotionModifier(player, timeScale, duration)
    local userId = player.UserId
    if not ActiveModifiers[userId] then
        ActiveModifiers[userId] = {}
    end
    
    -- Aplicar escala de tiempo
    game:GetService("RunService").Heartbeat:Wait()
    settings().Physics.PhysicsSendThrottle = 1 / timeScale
    
    -- Registrar modificador
    table.insert(ActiveModifiers[userId], {
        type = PhysicsModifierTypes.SLOW_MOTION,
        originalTimeScale = 1,
        modifiedTimeScale = timeScale,
        startTime = tick(),
        duration = duration
    })
    
    -- Restaurar después del tiempo especificado
    if duration then
        spawn(function()
            wait(duration)
            PhysicsModifiers.RemoveSlowMotionModifier(player)
        end)
    end
    
    print("Modificador de cámara lenta aplicado a " .. player.Name)
end

-- Función para remover cámara lenta
function PhysicsModifiers.RemoveSlowMotionModifier(player)
    local userId = player.UserId
    if not ActiveModifiers[userId] then return end
    
    for i, modifier in ipairs(ActiveModifiers[userId]) do
        if modifier.type == PhysicsModifierTypes.SLOW_MOTION then
            settings().Physics.PhysicsSendThrottle = 1 / modifier.originalTimeScale
            table.remove(ActiveModifiers[userId], i)
            print("Modificador de cámara lenta removido de " .. player.Name)
            break
        end
    end
end

-- Función para aplicar boost de velocidad
function PhysicsModifiers.ApplySpeedBoostModifier(player, speedMultiplier, duration)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local userId = player.UserId
    if not ActiveModifiers[userId] then
        ActiveModifiers[userId] = {}
    end
    
    -- Guardar velocidad original
    local originalSpeed = humanoid.WalkSpeed
    
    -- Aplicar nueva velocidad
    humanoid.WalkSpeed = originalSpeed * speedMultiplier
    
    -- Registrar modificador
    table.insert(ActiveModifiers[userId], {
        type = PhysicsModifierTypes.SPEED_BOOST,
        originalValue = originalSpeed,
        modifiedValue = humanoid.WalkSpeed,
        startTime = tick(),
        duration = duration
    })
    
    -- Restaurar después del tiempo especificado
    if duration then
        spawn(function()
            wait(duration)
            PhysicsModifiers.RemoveSpeedBoostModifier(player)
        end)
    end
    
    print("Boost de velocidad aplicado a " .. player.Name .. ": " .. speedMultiplier .. "x")
end

-- Función para remover boost de velocidad
function PhysicsModifiers.RemoveSpeedBoostModifier(player)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local userId = player.UserId
    if not ActiveModifiers[userId] then return end
    
    for i, modifier in ipairs(ActiveModifiers[userId]) do
        if modifier.type == PhysicsModifierTypes.SPEED_BOOST then
            humanoid.WalkSpeed = modifier.originalValue
            table.remove(ActiveModifiers[userId], i)
            print("Boost de velocidad removido de " .. player.Name)
            break
        end
    end
end

-- Función para aplicar boost de salto
function PhysicsModifiers.ApplyJumpBoostModifier(player, jumpMultiplier, duration)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local userId = player.UserId
    if not ActiveModifiers[userId] then
        ActiveModifiers[userId] = {}
    end
    
    -- Guardar poder de salto original
    local originalJumpPower = humanoid.JumpPower
    
    -- Aplicar nuevo poder de salto
    humanoid.JumpPower = originalJumpPower * jumpMultiplier
    
    -- Registrar modificador
    table.insert(ActiveModifiers[userId], {
        type = PhysicsModifierTypes.JUMP_BOOST,
        originalValue = originalJumpPower,
        modifiedValue = humanoid.JumpPower,
        startTime = tick(),
        duration = duration
    })
    
    -- Restaurar después del tiempo especificado
    if duration then
        spawn(function()
            wait(duration)
            PhysicsModifiers.RemoveJumpBoostModifier(player)
        end)
    end
    
    print("Boost de salto aplicado a " .. player.Name .. ": " .. jumpMultiplier .. "x")
end

-- Función para remover boost de salto
function PhysicsModifiers.RemoveJumpBoostModifier(player)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local userId = player.UserId
    if not ActiveModifiers[userId] then return end
    
    for i, modifier in ipairs(ActiveModifiers[userId]) do
        if modifier.type == PhysicsModifierTypes.JUMP_BOOST then
            humanoid.JumpPower = modifier.originalValue
            table.remove(ActiveModifiers[userId], i)
            print("Boost de salto removido de " .. player.Name)
            break
        end
    end
end

-- Función para aplicar anti-gravedad
function PhysicsModifiers.ApplyAntiGravityModifier(player, duration)
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local userId = player.UserId
    if not ActiveModifiers[userId] then
        ActiveModifiers[userId] = {}
    end
    
    -- Crear fuerza anti-gravedad
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(0, 1000, 0)
    bodyVelocity.Velocity = Vector3.new(0, 10, 0)
    bodyVelocity.Parent = rootPart
    
    -- Registrar modificador
    table.insert(ActiveModifiers[userId], {
        type = PhysicsModifierTypes.ANTI_GRAVITY,
        bodyVelocity = bodyVelocity,
        startTime = tick(),
        duration = duration
    })
    
    -- Remover después del tiempo especificado
    if duration then
        spawn(function()
            wait(duration)
            PhysicsModifiers.RemoveAntiGravityModifier(player)
        end)
    end
    
    print("Modificador anti-gravedad aplicado a " .. player.Name)
end

-- Función para remover anti-gravedad
function PhysicsModifiers.RemoveAntiGravityModifier(player)
    local userId = player.UserId
    if not ActiveModifiers[userId] then return end
    
    for i, modifier in ipairs(ActiveModifiers[userId]) do
        if modifier.type == PhysicsModifierTypes.ANTI_GRAVITY then
            if modifier.bodyVelocity and modifier.bodyVelocity.Parent then
                modifier.bodyVelocity:Destroy()
            end
            table.remove(ActiveModifiers[userId], i)
            print("Modificador anti-gravedad removido de " .. player.Name)
            break
        end
    end
end

-- Función para remover todos los modificadores de un jugador
function PhysicsModifiers.RemoveAllModifiers(player)
    local userId = player.UserId
    if not ActiveModifiers[userId] then return end
    
    PhysicsModifiers.RemoveGravityModifier(player)
    PhysicsModifiers.RemoveWindModifier(player)
    PhysicsModifiers.RemoveMagneticModifier(player)
    PhysicsModifiers.RemoveSlowMotionModifier(player)
    PhysicsModifiers.RemoveSpeedBoostModifier(player)
    PhysicsModifiers.RemoveJumpBoostModifier(player)
    PhysicsModifiers.RemoveAntiGravityModifier(player)
    
    ActiveModifiers[userId] = {}
    print("Todos los modificadores removidos de " .. player.Name)
end

-- Función para obtener modificadores activos de un jugador
function PhysicsModifiers.GetActiveModifiers(player)
    local userId = player.UserId
    return ActiveModifiers[userId] or {}
end

-- Limpiar modificadores cuando el jugador sale
Players.PlayerRemoving:Connect(function(player)
    PhysicsModifiers.RemoveAllModifiers(player)
    local userId = player.UserId
    ActiveModifiers[userId] = nil
end)

return PhysicsModifiers 