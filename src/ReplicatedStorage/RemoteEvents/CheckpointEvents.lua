-- CheckpointEvents.lua
-- Eventos remotos para el sistema de checkpoints

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear eventos remotos
local CheckpointEvents = {}

-- Evento para activar checkpoint desde el cliente
CheckpointEvents.ActivateCheckpoint = Instance.new("RemoteEvent")
CheckpointEvents.ActivateCheckpoint.Name = "ActivateCheckpoint"
CheckpointEvents.ActivateCheckpoint.Parent = ReplicatedStorage.RemoteEvents

-- Evento para notificar activación de checkpoint al cliente
CheckpointEvents.CheckpointActivated = Instance.new("RemoteEvent")
CheckpointEvents.CheckpointActivated.Name = "CheckpointActivated"
CheckpointEvents.CheckpointActivated.Parent = ReplicatedStorage.RemoteEvents

-- Evento para notificar error de checkpoint al cliente
CheckpointEvents.CheckpointError = Instance.new("RemoteEvent")
CheckpointEvents.CheckpointError.Name = "CheckpointError"
CheckpointEvents.CheckpointError.Parent = ReplicatedStorage.RemoteEvents

-- Evento para respawnear en checkpoint
CheckpointEvents.RespawnAtCheckpoint = Instance.new("RemoteEvent")
CheckpointEvents.RespawnAtCheckpoint.Name = "RespawnAtCheckpoint"
CheckpointEvents.RespawnAtCheckpoint.Parent = ReplicatedStorage.RemoteEvents

return CheckpointEvents 