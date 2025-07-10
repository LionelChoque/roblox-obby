-- LevelEvents.lua
-- Eventos remotos para el sistema de niveles

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear eventos remotos
local LevelEvents = {}

-- Evento para teleportar a nivel desde el cliente
LevelEvents.TeleportToLevel = Instance.new("RemoteEvent")
LevelEvents.TeleportToLevel.Name = "TeleportToLevel"
LevelEvents.TeleportToLevel.Parent = ReplicatedStorage.RemoteEvents

-- Evento para notificar completado de nivel
LevelEvents.LevelCompleted = Instance.new("RemoteEvent")
LevelEvents.LevelCompleted.Name = "LevelCompleted"
LevelEvents.LevelCompleted.Parent = ReplicatedStorage.RemoteEvents

-- Evento para notificar muerte del jugador
LevelEvents.PlayerDied = Instance.new("RemoteEvent")
LevelEvents.PlayerDied.Name = "PlayerDied"
LevelEvents.PlayerDied.Parent = ReplicatedStorage.RemoteEvents

-- Evento para obtener información de nivel
LevelEvents.GetLevelInfo = Instance.new("RemoteFunction")
LevelEvents.GetLevelInfo.Name = "GetLevelInfo"
LevelEvents.GetLevelInfo.Parent = ReplicatedStorage.RemoteFunctions

-- Evento para obtener progreso del jugador
LevelEvents.GetPlayerProgress = Instance.new("RemoteFunction")
LevelEvents.GetPlayerProgress.Name = "GetPlayerProgress"
LevelEvents.GetPlayerProgress.Parent = ReplicatedStorage.RemoteFunctions

return LevelEvents 