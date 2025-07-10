-- PlatformBehaviors.lua
-- Sistema de comportamientos de plataformas para el juego Obby de las Dimensiones

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

local PlatformBehaviors = {}

-- Configuración de tipos de plataformas
local PlatformTypes = {
    NORMAL = "Normal",
    FADING = "Fading",           -- Se desmorona después de pisarla
    MOVING = "Moving",           -- Se mueve en patrón
    INVISIBLE = "Invisible",     -- Invisible hasta tocarla
    BOUNCY = "Bouncy",           -- Rebota al jugador
    ICE = "Ice",                 -- Resbaladiza
    MAGNETIC = "Magnetic",       -- Atrae al jugador
    TRAP = "Trap"                -- Trampa que mata
}

-- Tabla para almacenar plataformas activas
local ActivePlatforms = {}

-- Función para crear plataforma normal
function PlatformBehaviors.CreateNormalPlatform(position, size)
    local platform = Instance.new("Part")
    platform.Name = "NormalPlatform"
    platform.Position = position
    platform.Size = size
    platform.Anchored = true
    platform.Material = Enum.Material.Wood
    platform.BrickColor = BrickColor.new("Brown")
    
    return platform
end

-- Función para crear plataforma que se desmorona
function PlatformBehaviors.CreateFadingPlatform(position, size, fadeTime)
    local platform = Instance.new("Part")
    platform.Name = "FadingPlatform"
    platform.Position = position
    platform.Size = size
    platform.Anchored = true
    platform.Material = Enum.Material.Wood
    platform.BrickColor = BrickColor.new("Reddish brown")
    
    -- Configurar comportamiento de desmoronamiento
    local fadeTime = fadeTime or GameConstants.PHYSICS.PLATFORM_FADE_TIME
    
    local function onTouched(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            -- Iniciar desmoronamiento
            spawn(function()
                wait(0.5) -- Pequeña demora para que el jugador se estabilice
                
                -- Efecto visual de desmoronamiento
                local tween = TweenService:Create(platform, TweenInfo.new(fadeTime), {
                    Transparency = 1,
                    Size = platform.Size * 0.5
                })
                tween:Play()
                
                -- Destruir después del efecto
                tween.Completed:Connect(function()
                    platform:Destroy()
                end)
            end)
        end
    end
    
    platform.Touched:Connect(onTouched)
    
    return platform
end

-- Función para crear plataforma móvil
function PlatformBehaviors.CreateMovingPlatform(position, size, path, speed)
    local platform = Instance.new("Part")
    platform.Name = "MovingPlatform"
    platform.Position = position
    platform.Size = size
    platform.Anchored = true
    platform.Material = Enum.Material.Metal
    platform.BrickColor = BrickColor.new("Really blue")
    
    local speed = speed or GameConstants.PHYSICS.MOVING_PLATFORM_SPEED
    local path = path or {position, position + Vector3.new(0, 10, 0)}
    
    -- Crear movimiento cíclico
    local currentIndex = 1
    local function moveToNextPosition()
        local targetPosition = path[currentIndex]
        local tween = TweenService:Create(platform, TweenInfo.new(speed), {
            Position = targetPosition
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            currentIndex = currentIndex + 1
            if currentIndex > #path then
                currentIndex = 1
            end
            moveToNextPosition()
        end)
    end
    
    -- Iniciar movimiento
    moveToNextPosition()
    
    return platform
end

-- Función para crear plataforma invisible
function PlatformBehaviors.CreateInvisiblePlatform(position, size)
    local platform = Instance.new("Part")
    platform.Name = "InvisiblePlatform"
    platform.Position = position
    platform.Size = size
    platform.Anchored = true
    platform.Material = Enum.Material.Glass
    platform.Transparency = 1
    platform.CanCollide = false
    
    -- Hacer visible cuando el jugador la toca
    local function onTouched(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            platform.Transparency = 0.3
            platform.CanCollide = true
            platform.BrickColor = BrickColor.new("Cyan")
            
            -- Volver invisible después de un tiempo
            spawn(function()
                wait(5)
                platform.Transparency = 1
                platform.CanCollide = false
            end)
        end
    end
    
    platform.Touched:Connect(onTouched)
    
    return platform
end

-- Función para crear plataforma rebotadora
function PlatformBehaviors.CreateBouncyPlatform(position, size, bouncePower)
    local platform = Instance.new("Part")
    platform.Name = "BouncyPlatform"
    platform.Position = position
    platform.Size = size
    platform.Anchored = true
    platform.Material = Enum.Material.Neon
    platform.BrickColor = BrickColor.new("Bright yellow")
    
    local bouncePower = bouncePower or 50
    
    local function onTouched(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = bouncePower
            
            -- Restaurar después de un tiempo
            spawn(function()
                wait(1)
                humanoid.JumpPower = GameConstants.PHYSICS.JUMP_POWER
            end)
        end
    end
    
    platform.Touched:Connect(onTouched)
    
    return platform
end

-- Función para crear plataforma de hielo
function PlatformBehaviors.CreateIcePlatform(position, size)
    local platform = Instance.new("Part")
    platform.Name = "IcePlatform"
    platform.Position = position
    platform.Size = size
    platform.Anchored = true
    platform.Material = Enum.Material.Ice
    platform.BrickColor = BrickColor.new("Light blue")
    
    local function onTouched(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            -- Reducir fricción para efecto resbaladizo
            humanoid.WalkSpeed = humanoid.WalkSpeed * 1.5
        end
    end
    
    local function onTouchEnded(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = GameConstants.PHYSICS.WALK_SPEED
        end
    end
    
    platform.Touched:Connect(onTouched)
    platform.TouchEnded:Connect(onTouchEnded)
    
    return platform
end

-- Función para crear plataforma magnética
function PlatformBehaviors.CreateMagneticPlatform(position, size, attractionForce)
    local platform = Instance.new("Part")
    platform.Name = "MagneticPlatform"
    platform.Position = position
    platform.Size = size
    platform.Anchored = true
    platform.Material = Enum.Material.Neon
    platform.BrickColor = BrickColor.new("Really red")
    
    local attractionForce = attractionForce or 20
    
    local function onTouched(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        local rootPart = hit.Parent:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            -- Aplicar fuerza de atracción
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(attractionForce, attractionForce, attractionForce)
            bodyVelocity.Velocity = (platform.Position - rootPart.Position).Unit * 10
            bodyVelocity.Parent = rootPart
            
            -- Remover después de un tiempo
            spawn(function()
                wait(2)
                if bodyVelocity and bodyVelocity.Parent then
                    bodyVelocity:Destroy()
                end
            end)
        end
    end
    
    platform.Touched:Connect(onTouched)
    
    return platform
end

-- Función para crear plataforma trampa
function PlatformBehaviors.CreateTrapPlatform(position, size)
    local platform = Instance.new("Part")
    platform.Name = "TrapPlatform"
    platform.Position = position
    platform.Size = size
    platform.Anchored = true
    platform.Material = Enum.Material.Neon
    platform.BrickColor = BrickColor.new("Really red")
    
    local function onTouched(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            -- Matar al jugador
            humanoid.Health = 0
            
            -- Efecto visual
            local explosion = Instance.new("Explosion")
            explosion.Position = platform.Position
            explosion.BlastRadius = 5
            explosion.BlastPressure = 0
            explosion.Parent = workspace
        end
    end
    
    platform.Touched:Connect(onTouched)
    
    return platform
end

-- Función para crear plataforma según tipo
function PlatformBehaviors.CreatePlatform(platformType, position, size, config)
    config = config or {}
    
    if platformType == PlatformTypes.NORMAL then
        return PlatformBehaviors.CreateNormalPlatform(position, size)
    elseif platformType == PlatformTypes.FADING then
        return PlatformBehaviors.CreateFadingPlatform(position, size, config.fadeTime)
    elseif platformType == PlatformTypes.MOVING then
        return PlatformBehaviors.CreateMovingPlatform(position, size, config.path, config.speed)
    elseif platformType == PlatformTypes.INVISIBLE then
        return PlatformBehaviors.CreateInvisiblePlatform(position, size)
    elseif platformType == PlatformTypes.BOUNCY then
        return PlatformBehaviors.CreateBouncyPlatform(position, size, config.bouncePower)
    elseif platformType == PlatformTypes.ICE then
        return PlatformBehaviors.CreateIcePlatform(position, size)
    elseif platformType == PlatformTypes.MAGNETIC then
        return PlatformBehaviors.CreateMagneticPlatform(position, size, config.attractionForce)
    elseif platformType == PlatformTypes.TRAP then
        return PlatformBehaviors.CreateTrapPlatform(position, size)
    else
        warn("Tipo de plataforma no reconocido: " .. tostring(platformType))
        return PlatformBehaviors.CreateNormalPlatform(position, size)
    end
end

-- Función para registrar plataforma activa
function PlatformBehaviors.RegisterPlatform(platform, level)
    if not ActivePlatforms[level] then
        ActivePlatforms[level] = {}
    end
    
    table.insert(ActivePlatforms[level], platform)
end

-- Función para limpiar plataformas de un nivel
function PlatformBehaviors.CleanupLevelPlatforms(level)
    if ActivePlatforms[level] then
        for _, platform in ipairs(ActivePlatforms[level]) do
            if platform and platform.Parent then
                platform:Destroy()
            end
        end
        ActivePlatforms[level] = {}
    end
end

-- Función para obtener configuración de plataformas por nivel
function PlatformBehaviors.GetLevelPlatformConfig(level)
    local configs = {
        [1] = { -- Level 1: Forest
            {
                type = PlatformTypes.NORMAL,
                position = Vector3.new(0, 10, 0),
                size = Vector3.new(10, 1, 10)
            },
            {
                type = PlatformTypes.FADING,
                position = Vector3.new(20, 15, 0),
                size = Vector3.new(8, 1, 8),
                config = {fadeTime = 2}
            },
            {
                type = PlatformTypes.MOVING,
                position = Vector3.new(40, 20, 0),
                size = Vector3.new(6, 1, 6),
                config = {
                    path = {
                        Vector3.new(40, 20, 0),
                        Vector3.new(50, 25, 0),
                        Vector3.new(40, 20, 0)
                    },
                    speed = 3
                }
            }
        },
        [2] = { -- Level 2: Water
            {
                type = PlatformTypes.ICE,
                position = Vector3.new(0, 5, 0),
                size = Vector3.new(12, 1, 12)
            },
            {
                type = PlatformTypes.INVISIBLE,
                position = Vector3.new(30, 10, 0),
                size = Vector3.new(8, 1, 8)
            },
            {
                type = PlatformTypes.TRAP,
                position = Vector3.new(60, 8, 0),
                size = Vector3.new(6, 1, 6)
            }
        }
    }
    
    return configs[level] or {}
end

return PlatformBehaviors 