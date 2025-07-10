-- VisualEffects.client.lua
-- Sistema de efectos visuales y partículas para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local VisualEffects = {}

-- Configuración de efectos
local EffectsConfig = {
    ParticlesEnabled = true,
    CameraShakeEnabled = true,
    ScreenEffectsEnabled = true,
    LightingEffectsEnabled = true
}

-- Función para crear efecto de partículas de checkpoint
function VisualEffects.CreateCheckpointParticles(position)
    if not EffectsConfig.ParticlesEnabled then return end
    
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = workspace
    
    local attachment = Instance.new("Attachment")
    attachment.Parent = part
    
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = attachment
    
    -- Configurar partículas
    particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
    particleEmitter.Lifetime = NumberRange.new(2, 4)
    particleEmitter.Rate = 50
    particleEmitter.Speed = NumberRange.new(5, 10)
    particleEmitter.SpreadAngle = Vector2.new(180, 180)
    particleEmitter.Acceleration = Vector3.new(0, 10, 0)
    particleEmitter.Drag = 5
    particleEmitter.RotSpeed = NumberRange.new(-30, 30)
    particleEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.5, 2),
        NumberSequenceKeypoint.new(1, 0)
    })
    particleEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
    
    -- Activar partículas
    particleEmitter.Enabled = true
    
    -- Remover después de un tiempo
    spawn(function()
        wait(3)
        particleEmitter.Enabled = false
        wait(4)
        part:Destroy()
    end)
end

-- Función para crear efecto de partículas de muerte
function VisualEffects.CreateDeathParticles(position)
    if not EffectsConfig.ParticlesEnabled then return end
    
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = workspace
    
    local attachment = Instance.new("Attachment")
    attachment.Parent = part
    
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = attachment
    
    -- Configurar partículas
    particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particleEmitter.Lifetime = NumberRange.new(1, 2)
    particleEmitter.Rate = 100
    particleEmitter.Speed = NumberRange.new(10, 20)
    particleEmitter.SpreadAngle = Vector2.new(360, 360)
    particleEmitter.Acceleration = Vector3.new(0, -20, 0)
    particleEmitter.Drag = 10
    particleEmitter.RotSpeed = NumberRange.new(-180, 180)
    particleEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    particleEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    
    -- Activar partículas
    particleEmitter.Enabled = true
    
    -- Remover después de un tiempo
    spawn(function()
        wait(2)
        particleEmitter.Enabled = false
        wait(2)
        part:Destroy()
    end)
end

-- Función para crear efecto de partículas de moneda
function VisualEffects.CreateCoinParticles(position)
    if not EffectsConfig.ParticlesEnabled then return end
    
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = workspace
    
    local attachment = Instance.new("Attachment")
    attachment.Parent = part
    
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = attachment
    
    -- Configurar partículas
    particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particleEmitter.Lifetime = NumberRange.new(1, 2)
    particleEmitter.Rate = 30
    particleEmitter.Speed = NumberRange.new(5, 10)
    particleEmitter.SpreadAngle = Vector2.new(90, 90)
    particleEmitter.Acceleration = Vector3.new(0, 15, 0)
    particleEmitter.Drag = 5
    particleEmitter.RotSpeed = NumberRange.new(-90, 90)
    particleEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.8),
        NumberSequenceKeypoint.new(1, 0)
    })
    particleEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
    
    -- Activar partículas
    particleEmitter.Enabled = true
    
    -- Remover después de un tiempo
    spawn(function()
        wait(1.5)
        particleEmitter.Enabled = false
        wait(2)
        part:Destroy()
    end)
end

-- Función para crear efecto de partículas de gema
function VisualEffects.CreateGemParticles(position)
    if not EffectsConfig.ParticlesEnabled then return end
    
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = workspace
    
    local attachment = Instance.new("Attachment")
    attachment.Parent = part
    
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = attachment
    
    -- Configurar partículas
    particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particleEmitter.Lifetime = NumberRange.new(2, 3)
    particleEmitter.Rate = 40
    particleEmitter.Speed = NumberRange.new(8, 15)
    particleEmitter.SpreadAngle = Vector2.new(120, 120)
    particleEmitter.Acceleration = Vector3.new(0, 20, 0)
    particleEmitter.Drag = 3
    particleEmitter.RotSpeed = NumberRange.new(-120, 120)
    particleEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.5, 1.2),
        NumberSequenceKeypoint.new(1, 0)
    })
    particleEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
    
    -- Activar partículas
    particleEmitter.Enabled = true
    
    -- Remover después de un tiempo
    spawn(function()
        wait(2)
        particleEmitter.Enabled = false
        wait(3)
        part:Destroy()
    end)
end

-- Función para crear efecto de sacudida de cámara
function VisualEffects.CreateCameraShake(intensity, duration)
    if not EffectsConfig.CameraShakeEnabled then return end
    
    local startTime = tick()
    local originalPosition = camera.CFrame
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local progress = elapsed / duration
        
        if progress >= 1 then
            camera.CFrame = originalPosition
            connection:Disconnect()
            return
        end
        
        -- Función de decaimiento
        local decay = 1 - progress
        local shake = math.sin(elapsed * 50) * intensity * decay
        
        camera.CFrame = originalPosition * CFrame.new(shake, shake * 0.5, shake)
    end)
end

-- Función para crear efecto de flash en pantalla
function VisualEffects.CreateScreenFlash(color, duration)
    if not EffectsConfig.ScreenEffectsEnabled then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScreenFlash"
    screenGui.Parent = playerGui
    
    local flashFrame = Instance.new("Frame")
    flashFrame.Size = UDim2.new(1, 0, 1, 0)
    flashFrame.Position = UDim2.new(0, 0, 0, 0)
    flashFrame.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    flashFrame.BackgroundTransparency = 1
    flashFrame.BorderSizePixel = 0
    flashFrame.Parent = screenGui
    
    -- Animación de entrada
    local enterTween = TweenService:Create(flashFrame, TweenInfo.new(0.1), {
        BackgroundTransparency = 0.3
    })
    enterTween:Play()
    
    -- Animación de salida
    spawn(function()
        wait(duration)
        local exitTween = TweenService:Create(flashFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        })
        exitTween:Play()
        exitTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
end

-- Función para crear efecto de distorsión de pantalla
function VisualEffects.CreateScreenDistortion(duration)
    if not EffectsConfig.ScreenEffectsEnabled then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScreenDistortion"
    screenGui.Parent = playerGui
    
    local distortionFrame = Instance.new("Frame")
    distortionFrame.Size = UDim2.new(1, 0, 1, 0)
    distortionFrame.Position = UDim2.new(0, 0, 0, 0)
    distortionFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    distortionFrame.BackgroundTransparency = 0.8
    distortionFrame.BorderSizePixel = 0
    distortionFrame.Parent = screenGui
    
    -- Efecto de ondulación
    local startTime = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local progress = elapsed / duration
        
        if progress >= 1 then
            connection:Disconnect()
            screenGui:Destroy()
            return
        end
        
        local wave = math.sin(elapsed * 20) * 0.1 * (1 - progress)
        distortionFrame.Position = UDim2.new(wave, 0, wave * 0.5, 0)
    end)
end

-- Función para crear efecto de iluminación
function VisualEffects.CreateLightingEffect(effectType, duration)
    if not EffectsConfig.LightingEffectsEnabled then return end
    
    local originalAmbient = Lighting.Ambient
    local originalBrightness = Lighting.Brightness
    local originalColorShift = Lighting.ColorShift_Top
    
    if effectType == "checkpoint" then
        -- Efecto verde para checkpoint
        Lighting.Ambient = Color3.fromRGB(0, 50, 0)
        Lighting.Brightness = 2
        Lighting.ColorShift_Top = Color3.fromRGB(0, 100, 0)
    elseif effectType == "death" then
        -- Efecto rojo para muerte
        Lighting.Ambient = Color3.fromRGB(50, 0, 0)
        Lighting.Brightness = 1.5
        Lighting.ColorShift_Top = Color3.fromRGB(100, 0, 0)
    elseif effectType == "level_complete" then
        -- Efecto dorado para completar nivel
        Lighting.Ambient = Color3.fromRGB(50, 50, 0)
        Lighting.Brightness = 3
        Lighting.ColorShift_Top = Color3.fromRGB(100, 100, 0)
    end
    
    -- Restaurar iluminación original
    spawn(function()
        wait(duration)
        Lighting.Ambient = originalAmbient
        Lighting.Brightness = originalBrightness
        Lighting.ColorShift_Top = originalColorShift
    end)
end

-- Función para crear efecto de trail en el jugador
function VisualEffects.CreatePlayerTrail(character, color, duration)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local trail = Instance.new("Trail")
    trail.Attachment0 = Instance.new("Attachment")
    trail.Attachment0.Parent = character.HumanoidRootPart
    trail.Attachment0.Position = Vector3.new(0, 0, 0.5)
    
    trail.Attachment1 = Instance.new("Attachment")
    trail.Attachment1.Parent = character.HumanoidRootPart
    trail.Attachment1.Position = Vector3.new(0, 0, -0.5)
    
    trail.Color = ColorSequence.new(color or Color3.fromRGB(255, 255, 255))
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Lifetime = 0.5
    trail.Parent = character.HumanoidRootPart
    
    -- Remover trail después del tiempo especificado
    spawn(function()
        wait(duration)
        trail:Destroy()
    end)
end

-- Función para crear efecto de explosión
function VisualEffects.CreateExplosion(position, size)
    if not EffectsConfig.ParticlesEnabled then return end
    
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = size or 10
    explosion.BlastPressure = 0 -- Sin daño
    explosion.DestroyJointRadiusPercent = 0
    explosion.Parent = workspace
    
    -- Crear partículas adicionales
    VisualEffects.CreateDeathParticles(position)
end

-- Función para crear efecto de portal
function VisualEffects.CreatePortalEffect(position)
    if not EffectsConfig.ParticlesEnabled then return end
    
    local part = Instance.new("Part")
    part.Size = Vector3.new(2, 2, 2)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = workspace
    
    local attachment = Instance.new("Attachment")
    attachment.Parent = part
    
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = attachment
    
    -- Configurar partículas de portal
    particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
    particleEmitter.Lifetime = NumberRange.new(3, 5)
    particleEmitter.Rate = 100
    particleEmitter.Speed = NumberRange.new(2, 5)
    particleEmitter.SpreadAngle = Vector2.new(360, 360)
    particleEmitter.Acceleration = Vector3.new(0, 5, 0)
    particleEmitter.Drag = 2
    particleEmitter.RotSpeed = NumberRange.new(-60, 60)
    particleEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.5, 3),
        NumberSequenceKeypoint.new(1, 0)
    })
    particleEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    particleEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
    })
    
    -- Activar partículas
    particleEmitter.Enabled = true
    
    -- Remover después de un tiempo
    spawn(function()
        wait(5)
        particleEmitter.Enabled = false
        wait(5)
        part:Destroy()
    end)
end

-- Función para configurar efectos
function VisualEffects.ConfigureEffects(config)
    EffectsConfig = config or EffectsConfig
    print("Configuración de efectos actualizada")
end

-- Función para obtener configuración actual
function VisualEffects.GetEffectsConfig()
    return EffectsConfig
end

-- Función para limpiar todos los efectos
function VisualEffects.ClearAllEffects()
    -- Limpiar efectos de pantalla
    for _, child in pairs(playerGui:GetChildren()) do
        if child.Name:find("Screen") then
            child:Destroy()
        end
    end
    
    -- Limpiar partículas en workspace
    for _, child in pairs(workspace:GetChildren()) do
        if child:IsA("Part") and child.Name:find("Effect") then
            child:Destroy()
        end
    end
    
    print("Todos los efectos visuales han sido limpiados")
end

return VisualEffects 