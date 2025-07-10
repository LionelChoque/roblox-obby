-- Level1Script.server.lua
-- Script del servidor para el Nivel 1: Bosque de los Iniciados

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Importar sistemas
local PlayerDataManager = require(ReplicatedStorage.SharedModules.PlayerStats)
local CheckpointSystem = require(script.Parent.Parent.Parent.Parent.ServerScriptService.GameCore.CheckpointSystem)
local LevelManager = require(script.Parent.Parent.Parent.Parent.ServerScriptService.GameCore.LevelManager)
local PlatformBehaviors = require(script.Parent.Parent.Parent.Parent.ServerScriptService.Mechanics.PlatformBehaviors)
local HammerSystem = require(script.Parent.Parent.Parent.Parent.ServerScriptService.Mechanics.HammerSystem)
local PhysicsModifiers = require(script.Parent.Parent.Parent.Parent.ServerScriptService.Mechanics.PhysicsModifiers)

local Level1 = {}

-- Configuración del nivel
local LEVEL_ID = 1
local LEVEL_NAME = "Bosque de los Iniciados"

-- Referencias a partes del nivel
local levelFolder = script.Parent
local platformsFolder = levelFolder:WaitForChild("Platforms")
local obstaclesFolder = levelFolder:WaitForChild("Obstacles")
local checkpointsFolder = levelFolder:WaitForChild("Checkpoints")
local portalFolder = levelFolder:WaitForChild("Portal")
local decorationsFolder = levelFolder:WaitForChild("Decorations")

-- Tabla para almacenar jugadores en el nivel
local PlayersInLevel = {}

-- Función para inicializar el nivel
function Level1.InitializeLevel()
    print("Inicializando " .. LEVEL_NAME)
    
    -- Crear plataformas del nivel
    Level1.CreateLevelPlatforms()
    
    -- Crear obstáculos del nivel
    Level1.CreateLevelObstacles()
    
    -- Crear checkpoints del nivel
    Level1.CreateLevelCheckpoints()
    
    -- Crear martillos del nivel
    Level1.CreateLevelHammers()
    
    -- Crear portal de salida
    Level1.CreateLevelPortal()
    
    -- Crear decoraciones
    Level1.CreateLevelDecorations()
    
    print(LEVEL_NAME .. " inicializado correctamente")
end

-- Función para crear plataformas del nivel
function Level1.CreateLevelPlatforms()
    -- Plataforma de inicio
    local startPlatform = PlatformBehaviors.CreateNormalPlatform(
        Vector3.new(0, 10, 0),
        Vector3.new(15, 1, 15)
    )
    startPlatform.Parent = platformsFolder
    
    -- Plataforma que se desmorona
    local fadingPlatform = PlatformBehaviors.CreateFadingPlatform(
        Vector3.new(25, 15, 0),
        Vector3.new(8, 1, 8),
        2.0
    )
    fadingPlatform.Parent = platformsFolder
    
    -- Plataforma móvil
    local movingPlatform = PlatformBehaviors.CreateMovingPlatform(
        Vector3.new(45, 20, 0),
        Vector3.new(6, 1, 6),
        {
            Vector3.new(45, 20, 0),
            Vector3.new(55, 25, 0),
            Vector3.new(45, 20, 0)
        },
        3.0
    )
    movingPlatform.Parent = platformsFolder
    
    -- Plataforma invisible
    local invisiblePlatform = PlatformBehaviors.CreateInvisiblePlatform(
        Vector3.new(65, 18, 0),
        Vector3.new(8, 1, 8)
    )
    invisiblePlatform.Parent = platformsFolder
    
    -- Plataforma rebotadora
    local bouncyPlatform = PlatformBehaviors.CreateBouncyPlatform(
        Vector3.new(85, 22, 0),
        Vector3.new(6, 1, 6),
        60
    )
    bouncyPlatform.Parent = platformsFolder
    
    -- Plataforma de hielo
    local icePlatform = PlatformBehaviors.CreateIcePlatform(
        Vector3.new(105, 25, 0),
        Vector3.new(10, 1, 10)
    )
    icePlatform.Parent = platformsFolder
    
    -- Plataforma magnética
    local magneticPlatform = PlatformBehaviors.CreateMagneticPlatform(
        Vector3.new(125, 28, 0),
        Vector3.new(8, 1, 8),
        25
    )
    magneticPlatform.Parent = platformsFolder
    
    -- Plataforma trampa (cuidado!)
    local trapPlatform = PlatformBehaviors.CreateTrapPlatform(
        Vector3.new(145, 30, 0),
        Vector3.new(6, 1, 6)
    )
    trapPlatform.Parent = platformsFolder
    
    print("Plataformas del nivel 1 creadas")
end

-- Función para crear obstáculos del nivel
function Level1.CreateLevelObstacles()
    -- Obstáculo giratorio
    local spinningObstacle = Instance.new("Part")
    spinningObstacle.Name = "SpinningObstacle"
    spinningObstacle.Position = Vector3.new(35, 18, 0)
    spinningObstacle.Size = Vector3.new(2, 8, 2)
    spinningObstacle.Anchored = true
    spinningObstacle.Material = Enum.Material.Metal
    spinningObstacle.BrickColor = BrickColor.new("Really red")
    spinningObstacle.Parent = obstaclesFolder
    
    -- Hacer girar el obstáculo
    spawn(function()
        while spinningObstacle and spinningObstacle.Parent do
            spinningObstacle.CFrame = spinningObstacle.CFrame * CFrame.Angles(0, math.rad(2), 0)
            wait()
        end
    end)
    
    -- Obstáculo que se mueve arriba y abajo
    local movingObstacle = Instance.new("Part")
    movingObstacle.Name = "MovingObstacle"
    movingObstacle.Position = Vector3.new(75, 25, 0)
    movingObstacle.Size = Vector3.new(4, 4, 4)
    movingObstacle.Anchored = true
    movingObstacle.Material = Enum.Material.Neon
    movingObstacle.BrickColor = BrickColor.new("Bright orange")
    movingObstacle.Parent = obstaclesFolder
    
    -- Mover el obstáculo
    spawn(function()
        local startPos = movingObstacle.Position
        local upPos = startPos + Vector3.new(0, 10, 0)
        local downPos = startPos - Vector3.new(0, 5, 0)
        
        while movingObstacle and movingObstacle.Parent do
            -- Mover arriba
            for i = 0, 1, 0.02 do
                if movingObstacle and movingObstacle.Parent then
                    movingObstacle.Position = startPos:Lerp(upPos, i)
                    wait(0.05)
                else
                    break
                end
            end
            
            -- Mover abajo
            for i = 0, 1, 0.02 do
                if movingObstacle and movingObstacle.Parent then
                    movingObstacle.Position = upPos:Lerp(downPos, i)
                    wait(0.05)
                else
                    break
                end
            end
            
            -- Volver al inicio
            for i = 0, 1, 0.02 do
                if movingObstacle and movingObstacle.Parent then
                    movingObstacle.Position = downPos:Lerp(startPos, i)
                    wait(0.05)
                else
                    break
                end
            end
        end
    end)
    
    print("Obstáculos del nivel 1 creados")
end

-- Función para crear checkpoints del nivel
function Level1.CreateLevelCheckpoints()
    -- Checkpoint estándar
    local checkpoint1 = Instance.new("Part")
    checkpoint1.Name = "Checkpoint_1"
    checkpoint1.Position = Vector3.new(50, 12, 0)
    checkpoint1.Size = Vector3.new(4, 8, 4)
    checkpoint1.Anchored = true
    checkpoint1.Material = Enum.Material.Neon
    checkpoint1.BrickColor = BrickColor.new("Bright green")
    checkpoint1.Parent = checkpointsFolder
    
    -- Efecto de brillo para checkpoint
    local pointLight = Instance.new("PointLight")
    pointLight.Color = Color3.fromRGB(0, 255, 0)
    pointLight.Range = 15
    pointLight.Brightness = 3
    pointLight.Parent = checkpoint1
    
    -- Configurar activación de checkpoint
    checkpoint1.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if player then
                CheckpointSystem.ActivateCheckpoint(player, LEVEL_ID, 1)
            end
        end
    end)
    
    print("Checkpoints del nivel 1 creados")
end

-- Función para crear martillos del nivel
function Level1.CreateLevelHammers()
    -- Crear martillo del principiante
    local hammer = HammerSystem.CreateHammer("Hammer_Beginner", Vector3.new(250, 15, 0))
    if hammer then
        hammer.Parent = levelFolder
    end
    
    print("Martillos del nivel 1 creados")
end

-- Función para crear portal de salida
function Level1.CreateLevelPortal()
    local portal = Instance.new("Part")
    portal.Name = "LevelPortal"
    portal.Position = Vector3.new(500, 30, 0)
    portal.Size = Vector3.new(8, 12, 2)
    portal.Anchored = true
    portal.Material = Enum.Material.Neon
    portal.BrickColor = BrickColor.new("Bright blue")
    portal.Parent = portalFolder
    
    -- Efecto de portal
    local pointLight = Instance.new("PointLight")
    pointLight.Color = Color3.fromRGB(0, 150, 255)
    pointLight.Range = 20
    pointLight.Brightness = 5
    pointLight.Parent = portal
    
    -- Configurar activación de portal
    portal.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if player then
                Level1.CompleteLevel(player)
            end
        end
    end)
    
    print("Portal del nivel 1 creado")
end

-- Función para crear decoraciones
function Level1.CreateLevelDecorations()
    -- Árboles decorativos
    for i = 1, 5 do
        local tree = Instance.new("Part")
        tree.Name = "Tree_" .. i
        tree.Position = Vector3.new(i * 20, 5, 10)
        tree.Size = Vector3.new(3, 10, 3)
        tree.Anchored = true
        tree.Material = Enum.Material.Wood
        tree.BrickColor = BrickColor.new("Brown")
        tree.Parent = decorationsFolder
    end
    
    print("Decoraciones del nivel 1 creadas")
end

-- Función para completar el nivel
function Level1.CompleteLevel(player)
    if not PlayersInLevel[player.UserId] then
        return
    end
    
    -- Registrar completado
    LevelManager.RegisterLevelCompletion(player, LEVEL_ID)
    
    -- Efecto de completado
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            -- Efecto de partículas
            local attachment = Instance.new("Attachment")
            attachment.Parent = rootPart
            
            local particleEmitter = Instance.new("ParticleEmitter")
            particleEmitter.Parent = attachment
            particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
            particleEmitter.Size = NumberSequence.new(1)
            particleEmitter.Lifetime = NumberRange.new(2, 3)
            particleEmitter.Rate = 100
            particleEmitter.Speed = NumberRange.new(10, 20)
            
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
    end
    
    -- Teleportar al lobby
    spawn(function()
        wait(2)
        LevelManager.TeleportToLevel(player, 1) -- Volver al lobby
    end)
    
    print("Nivel 1 completado por " .. player.Name)
end

-- Función para registrar jugador en el nivel
function Level1.RegisterPlayer(player)
    PlayersInLevel[player.UserId] = {
        player = player,
        startTime = tick(),
        checkpoints = {}
    }
    
    print("Jugador " .. player.Name .. " registrado en nivel 1")
end

-- Función para remover jugador del nivel
function Level1.RemovePlayer(player)
    PlayersInLevel[player.UserId] = nil
    
    print("Jugador " .. player.Name .. " removido del nivel 1")
end

-- Eventos del jugador
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Verificar si el jugador está en el nivel 1
        local rootPart = character:WaitForChild("HumanoidRootPart")
        if rootPart.Position.X > 0 and rootPart.Position.X < 600 then
            Level1.RegisterPlayer(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    Level1.RemovePlayer(player)
end)

-- Inicializar el nivel
Level1.InitializeLevel()

return Level1 