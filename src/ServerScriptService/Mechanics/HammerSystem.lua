-- HammerSystem.lua
-- Sistema de martillos para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

-- Importar otros sistemas
local PlayerDataManager = require(script.Parent.Parent.GameCore.PlayerDataManager)

local HammerSystem = {}

-- Configuración de martillos
local HammerConfigs = {
    [GameConstants.HAMMERS.BEGINNER] = {
        name = "Martillo del Principiante",
        description = "El primer martillo que obtienes en tu viaje",
        rarity = "Common",
        effect = "none",
        color = BrickColor.new("Brown"),
        size = Vector3.new(2, 4, 1),
        position = Vector3.new(250, 15, 0),
        level = 1
    },
    [GameConstants.HAMMERS.NAVIGATOR] = {
        name = "Martillo del Navegante",
        description = "Te ayuda a encontrar el camino correcto",
        rarity = "Uncommon",
        effect = "guidance",
        color = BrickColor.new("Cyan"),
        size = Vector3.new(2, 4, 1),
        position = Vector3.new(350, 20, 0),
        level = 2
    },
    [GameConstants.HAMMERS.WARRIOR] = {
        name = "Martillo del Guerrero",
        description = "Otorga resistencia temporal a daño",
        rarity = "Rare",
        effect = "protection",
        color = BrickColor.new("Really red"),
        size = Vector3.new(2, 4, 1),
        position = Vector3.new(450, 25, 0),
        level = 3
    },
    [GameConstants.HAMMERS.CODED] = {
        name = "Martillo Codificado",
        description = "Revela plataformas invisibles temporalmente",
        rarity = "Epic",
        effect = "reveal",
        color = BrickColor.new("Purple"),
        size = Vector3.new(2, 4, 1),
        position = Vector3.new(550, 30, 0),
        level = 4
    },
    [GameConstants.HAMMERS.DIVINE] = {
        name = "Martillo Divino",
        description = "El martillo más poderoso, otorga múltiples efectos",
        rarity = "Legendary",
        effect = "divine",
        color = BrickColor.new("Gold"),
        size = Vector3.new(2, 4, 1),
        position = Vector3.new(650, 35, 0),
        level = 5
    }
}

-- Tabla para almacenar martillos activos
local ActiveHammers = {}

-- Función para crear un martillo
function HammerSystem.CreateHammer(hammerType, position)
    local config = HammerConfigs[hammerType]
    if not config then
        warn("Configuración de martillo no encontrada: " .. tostring(hammerType))
        return nil
    end
    
    local hammer = Instance.new("Part")
    hammer.Name = "Hammer_" .. hammerType
    hammer.Position = position or config.position
    hammer.Size = config.size
    hammer.Anchored = true
    hammer.Material = Enum.Material.Metal
    hammer.BrickColor = config.color
    hammer.CanCollide = true
    
    -- Agregar efecto de brillo
    local pointLight = Instance.new("PointLight")
    pointLight.Color = config.color.Color
    pointLight.Range = 10
    pointLight.Brightness = 2
    pointLight.Parent = hammer
    
    -- Agregar efecto de rotación
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(0, 1000, 0)
    bodyGyro.D = 100
    bodyGyro.P = 1000
    bodyGyro.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
    bodyGyro.Parent = hammer
    
    -- Agregar efecto de flotación
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(0, 1000, 0)
    bodyPosition.Position = hammer.Position + Vector3.new(0, 2, 0)
    bodyPosition.Parent = hammer
    
    -- Configurar comportamiento de recolección
    local function onTouched(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if player then
                HammerSystem.CollectHammer(player, hammerType, hammer)
            end
        end
    end
    
    hammer.Touched:Connect(onTouched)
    
    -- Registrar martillo activo
    if not ActiveHammers[hammerType] then
        ActiveHammers[hammerType] = {}
    end
    table.insert(ActiveHammers[hammerType], hammer)
    
    return hammer
end

-- Función para recolectar martillo
function HammerSystem.CollectHammer(player, hammerType, hammer)
    -- Verificar si el jugador ya tiene este martillo
    local playerData = PlayerDataManager.GetPlayerData(player)
    if not playerData then return end
    
    if playerData.Progress.Hammers[hammerType] then
        -- El jugador ya tiene este martillo
        return
    end
    
    -- Agregar martillo al jugador
    PlayerDataManager.AddHammerToPlayer(player, hammerType)
    
    -- Aplicar efectos del martillo
    HammerSystem.ApplyHammerEffects(player, hammerType)
    
    -- Efecto visual de recolección
    HammerSystem.CreateCollectionEffect(hammer)
    
    -- Destruir el martillo
    hammer:Destroy()
    
    print("Martillo " .. hammerType .. " recolectado por " .. player.Name)
end

-- Función para aplicar efectos del martillo
function HammerSystem.ApplyHammerEffects(player, hammerType)
    local config = HammerConfigs[hammerType]
    if not config then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if config.effect == "guidance" then
        -- Efecto de guía: mostrar camino correcto
        HammerSystem.ApplyGuidanceEffect(player)
        
    elseif config.effect == "protection" then
        -- Efecto de protección: resistencia temporal
        HammerSystem.ApplyProtectionEffect(player)
        
    elseif config.effect == "reveal" then
        -- Efecto de revelación: mostrar plataformas invisibles
        HammerSystem.ApplyRevealEffect(player)
        
    elseif config.effect == "divine" then
        -- Efecto divino: múltiples efectos
        HammerSystem.ApplyDivineEffect(player)
    end
end

-- Función para aplicar efecto de guía
function HammerSystem.ApplyGuidanceEffect(player)
    -- Crear partículas de guía
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local attachment = Instance.new("Attachment")
    attachment.Parent = rootPart
    
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = attachment
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
    particleEmitter.Size = NumberSequence.new(0.5)
    particleEmitter.Lifetime = NumberRange.new(2, 3)
    particleEmitter.Rate = 20
    particleEmitter.Speed = NumberRange.new(5, 10)
    
    -- Detener después de 30 segundos
    spawn(function()
        wait(30)
        if particleEmitter and particleEmitter.Parent then
            particleEmitter:Destroy()
        end
        if attachment and attachment.Parent then
            attachment:Destroy()
        end
    end)
end

-- Función para aplicar efecto de protección
function HammerSystem.ApplyProtectionEffect(player)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Crear escudo visual
    local shield = Instance.new("Part")
    shield.Name = "ProtectionShield"
    shield.Shape = Enum.PartType.Ball
    shield.Size = Vector3.new(8, 8, 8)
    shield.Transparency = 0.7
    shield.Material = Enum.Material.Neon
    shield.BrickColor = BrickColor.new("Really red")
    shield.CanCollide = false
    shield.Anchored = true
    shield.Parent = character
    
    -- Hacer el escudo seguir al jugador
    local weld = Instance.new("Weld")
    weld.Part0 = character.HumanoidRootPart
    weld.Part1 = shield
    weld.C0 = CFrame.new(0, 0, 0)
    weld.Parent = shield
    
    -- Remover escudo después de 60 segundos
    spawn(function()
        wait(60)
        if shield and shield.Parent then
            shield:Destroy()
        end
    end)
end

-- Función para aplicar efecto de revelación
function HammerSystem.ApplyRevealEffect(player)
    -- Buscar plataformas invisibles en el área
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local radius = 50
    local parts = workspace:GetPartsInPart(rootPart)
    
    for _, part in ipairs(parts) do
        if part.Name == "InvisiblePlatform" and part.Transparency > 0.5 then
            -- Hacer visible temporalmente
            part.Transparency = 0.3
            part.BrickColor = BrickColor.new("Cyan")
            
            -- Volver invisible después de 30 segundos
            spawn(function()
                wait(30)
                if part and part.Parent then
                    part.Transparency = 1
                end
            end)
        end
    end
end

-- Función para aplicar efecto divino
function HammerSystem.ApplyDivineEffect(player)
    -- Aplicar múltiples efectos
    HammerSystem.ApplyGuidanceEffect(player)
    HammerSystem.ApplyProtectionEffect(player)
    HammerSystem.ApplyRevealEffect(player)
    
    -- Efecto adicional: velocidad aumentada
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            local originalSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = originalSpeed * 1.5
            
            -- Restaurar después de 45 segundos
            spawn(function()
                wait(45)
                if humanoid and humanoid.Parent then
                    humanoid.WalkSpeed = originalSpeed
                end
            end)
        end
    end
end

-- Función para crear efecto de recolección
function HammerSystem.CreateCollectionEffect(hammer)
    -- Efecto de partículas
    local attachment = Instance.new("Attachment")
    attachment.Parent = hammer
    
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = attachment
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
    particleEmitter.Size = NumberSequence.new(1)
    particleEmitter.Lifetime = NumberRange.new(1, 2)
    particleEmitter.Rate = 100
    particleEmitter.Speed = NumberRange.new(10, 20)
    
    -- Efecto de sonido (se configurará en Roblox Studio)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" -- ID del sonido de recolección
    sound.Volume = 0.5
    sound.Parent = hammer
    sound:Play()
    
    -- Detener partículas después de 2 segundos
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

-- Función para obtener configuración de martillos por nivel
function HammerSystem.GetLevelHammers(level)
    local hammers = {}
    
    for hammerType, config in pairs(HammerConfigs) do
        if config.level == level then
            table.insert(hammers, {
                type = hammerType,
                config = config
            })
        end
    end
    
    return hammers
end

-- Función para crear todos los martillos de un nivel
function HammerSystem.CreateLevelHammers(level)
    local hammers = HammerSystem.GetLevelHammers(level)
    
    for _, hammerData in ipairs(hammers) do
        HammerSystem.CreateHammer(hammerData.type, hammerData.config.position)
    end
    
    print("Martillos creados para el nivel " .. level)
end

-- Función para limpiar martillos de un nivel
function HammerSystem.CleanupLevelHammers(level)
    local hammers = HammerSystem.GetLevelHammers(level)
    
    for _, hammerData in ipairs(hammers) do
        if ActiveHammers[hammerData.type] then
            for _, hammer in ipairs(ActiveHammers[hammerData.type]) do
                if hammer and hammer.Parent then
                    hammer:Destroy()
                end
            end
            ActiveHammers[hammerData.type] = {}
        end
    end
end

return HammerSystem 