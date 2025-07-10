-- MultiplayerManager.server.lua
-- Sistema de gestión multijugador para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

-- Eventos remotos
local RankingEvents = ReplicatedStorage:WaitForChild("RankingEvents")

local MultiplayerManager = {}

-- Estado del multijugador
local PlayerStates = {}
local LevelPlayers = {}
local OnlinePlayers = {}
local PlayerConnections = {}

-- Tipos de estado de jugador
local PlayerStateTypes = {
    LOBBY = "lobby",
    PLAYING = "playing",
    SPECTATING = "spectating",
    AFK = "afk",
    OFFLINE = "offline"
}

-- Función para inicializar el sistema multijugador
function MultiplayerManager.Initialize()
    print("Inicializando sistema multijugador...")
    
    -- Configurar eventos de jugadores
    Players.PlayerAdded:Connect(MultiplayerManager.OnPlayerAdded)
    Players.PlayerRemoving:Connect(MultiplayerManager.OnPlayerRemoving)
    
    -- Configurar eventos remotos
    MultiplayerManager.SetupRemoteEvents()
    
    print("Sistema multijugador inicializado correctamente")
end

-- Función para manejar cuando un jugador se une
function MultiplayerManager.OnPlayerAdded(player)
    print("Jugador " .. player.Name .. " se unió al juego")
    
    -- Inicializar estado del jugador
    PlayerStates[player.UserId] = {
        State = PlayerStateTypes.LOBBY,
        CurrentLevel = 0,
        JoinTime = tick(),
        LastActivity = tick(),
        Spectating = nil,
        Friends = {},
        Clan = nil,
        Settings = {
            ShowOtherPlayers = true,
            ShowGhostRunners = true,
            ShowParticles = true,
            ChatEnabled = true
        }
    }
    
    OnlinePlayers[player.UserId] = {
        UserId = player.UserId,
        Username = player.Name,
        DisplayName = player.DisplayName,
        JoinTime = tick(),
        State = PlayerStateTypes.LOBBY
    }
    
    -- Notificar a otros jugadores
    MultiplayerManager.NotifyPlayerJoined(player)
    
    -- Configurar eventos del jugador
    MultiplayerManager.SetupPlayerEvents(player)
    
    -- Enviar información inicial
    MultiplayerManager.SendInitialData(player)
end

-- Función para manejar cuando un jugador se va
function MultiplayerManager.OnPlayerRemoving(player)
    print("Jugador " .. player.Name .. " se fue del juego")
    
    local userId = player.UserId
    
    -- Limpiar estado del jugador
    if PlayerStates[userId] then
        -- Notificar que el jugador dejó el nivel
        if PlayerStates[userId].CurrentLevel > 0 then
            MultiplayerManager.OnPlayerLeftLevel(player, PlayerStates[userId].CurrentLevel)
        end
        
        PlayerStates[userId] = nil
    end
    
    -- Limpiar conexiones
    if PlayerConnections[userId] then
        for _, connection in pairs(PlayerConnections[userId]) do
            connection:Disconnect()
        end
        PlayerConnections[userId] = nil
    end
    
    -- Remover de jugadores online
    OnlinePlayers[userId] = nil
    
    -- Notificar a otros jugadores
    MultiplayerManager.NotifyPlayerLeft(player)
end

-- Función para configurar eventos remotos
function MultiplayerManager.SetupRemoteEvents()
    -- Evento para cuando un jugador se une a un nivel
    RankingEvents.PlayerJoinedLevel.OnServerEvent:Connect(function(player, levelNumber)
        MultiplayerManager.OnPlayerJoinedLevel(player, levelNumber)
    end)
    
    -- Evento para cuando un jugador deja un nivel
    RankingEvents.PlayerLeftLevel.OnServerEvent:Connect(function(player, levelNumber)
        MultiplayerManager.OnPlayerLeftLevel(player, levelNumber)
    end)
    
    -- Evento para completar nivel
    RankingEvents.PlayerCompletedLevel.OnServerEvent:Connect(function(player, levelData)
        MultiplayerManager.OnPlayerCompletedLevel(player, levelData)
    end)
    
    -- Evento para chat
    RankingEvents.SendChatMessage.OnServerEvent:Connect(function(player, message)
        MultiplayerManager.OnChatMessage(player, message)
    end)
    
    -- Evento para espectar jugador
    RankingEvents.SpectatePlayer.OnServerEvent:Connect(function(player, targetUserId)
        MultiplayerManager.OnSpectatePlayer(player, targetUserId)
    end)
    
    -- Evento para desafiar jugador
    RankingEvents.ChallengePlayer.OnServerEvent:Connect(function(player, targetUserId)
        MultiplayerManager.OnChallengePlayer(player, targetUserId)
    end)
    
    -- Evento para aceptar desafío
    RankingEvents.AcceptChallenge.OnServerEvent:Connect(function(player, challengerUserId)
        MultiplayerManager.OnAcceptChallenge(player, challengerUserId)
    end)
    
    -- Evento para rechazar desafío
    RankingEvents.DeclineChallenge.OnServerEvent:Connect(function(player, challengerUserId)
        MultiplayerManager.OnDeclineChallenge(player, challengerUserId)
    end)
    
    -- Evento para actualizar configuración
    RankingEvents.UpdatePlayerSettings.OnServerEvent:Connect(function(player, settings)
        MultiplayerManager.OnUpdatePlayerSettings(player, settings)
    end)
    
    -- Función para obtener jugadores online
    RankingEvents.GetOnlinePlayers.OnServerInvoke = function(player)
        return MultiplayerManager.GetOnlinePlayersList()
    end
    
    -- Función para obtener información de amigos
    RankingEvents.GetFriendsList.OnServerInvoke = function(player)
        return MultiplayerManager.GetPlayerFriends(player.UserId)
    end
    
    -- Función para obtener información de clan
    RankingEvents.GetClanInfo.OnServerInvoke = function(player)
        return MultiplayerManager.GetPlayerClan(player.UserId)
    end
end

-- Función para configurar eventos de un jugador específico
function MultiplayerManager.SetupPlayerEvents(player)
    local userId = player.UserId
    PlayerConnections[userId] = {}
    
    -- Evento para cuando el jugador se mueve
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    local moveConnection = humanoid.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Dead then
            MultiplayerManager.OnPlayerDied(player)
        end
    end)
    
    table.insert(PlayerConnections[userId], moveConnection)
    
    -- Evento para cuando el jugador respawnea
    local respawnConnection = player.CharacterAdded:Connect(function(newCharacter)
        local newHumanoid = newCharacter:WaitForChild("Humanoid")
        
        local newMoveConnection = newHumanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Dead then
                MultiplayerManager.OnPlayerDied(player)
            end
        end)
        
        table.insert(PlayerConnections[userId], newMoveConnection)
    end)
    
    table.insert(PlayerConnections[userId], respawnConnection)
end

-- Función para cuando un jugador se une a un nivel
function MultiplayerManager.OnPlayerJoinedLevel(player, levelNumber)
    local userId = player.UserId
    
    if PlayerStates[userId] then
        PlayerStates[userId].State = PlayerStateTypes.PLAYING
        PlayerStates[userId].CurrentLevel = levelNumber
        PlayerStates[userId].LastActivity = tick()
        
        -- Agregar a la lista de jugadores del nivel
        if not LevelPlayers[levelNumber] then
            LevelPlayers[levelNumber] = {}
        end
        
        LevelPlayers[levelNumber][userId] = {
            UserId = userId,
            Username = player.Name,
            JoinTime = tick(),
            State = PlayerStateTypes.PLAYING
        }
        
        -- Actualizar jugadores online
        if OnlinePlayers[userId] then
            OnlinePlayers[userId].State = PlayerStateTypes.PLAYING
            OnlinePlayers[userId].CurrentLevel = levelNumber
        end
        
        -- Notificar a otros jugadores del nivel
        MultiplayerManager.NotifyLevelPlayers(levelNumber, "PlayerJoinedLevel", {
            UserId = userId,
            Username = player.Name,
            JoinTime = tick()
        })
        
        print("Jugador " .. player.Name .. " se unió al nivel " .. levelNumber)
    end
end

-- Función para cuando un jugador deja un nivel
function MultiplayerManager.OnPlayerLeftLevel(player, levelNumber)
    local userId = player.UserId
    
    if PlayerStates[userId] then
        PlayerStates[userId].State = PlayerStateTypes.LOBBY
        PlayerStates[userId].CurrentLevel = 0
        PlayerStates[userId].LastActivity = tick()
        
        -- Remover de la lista de jugadores del nivel
        if LevelPlayers[levelNumber] and LevelPlayers[levelNumber][userId] then
            LevelPlayers[levelNumber][userId] = nil
        end
        
        -- Actualizar jugadores online
        if OnlinePlayers[userId] then
            OnlinePlayers[userId].State = PlayerStateTypes.LOBBY
            OnlinePlayers[userId].CurrentLevel = 0
        end
        
        -- Notificar a otros jugadores del nivel
        MultiplayerManager.NotifyLevelPlayers(levelNumber, "PlayerLeftLevel", {
            UserId = userId,
            Username = player.Name
        })
        
        print("Jugador " .. player.Name .. " dejó el nivel " .. levelNumber)
    end
end

-- Función para cuando un jugador completa un nivel
function MultiplayerManager.OnPlayerCompletedLevel(player, levelData)
    local userId = player.UserId
    
    if PlayerStates[userId] then
        -- Notificar a otros jugadores del nivel
        MultiplayerManager.NotifyLevelPlayers(levelData.Level, "PlayerCompletedLevel", {
            UserId = userId,
            Username = player.Name,
            Level = levelData.Level,
            Time = levelData.Time,
            Deaths = levelData.Deaths
        })
        
        -- Actualizar ranking
        local RankingSystem = require(script.Parent.RankingSystem)
        local playerRank = RankingSystem.UpdatePlayerRanking(player, levelData.Level, levelData.Time, levelData.Deaths, levelData.Checkpoints)
        
        -- Notificar al jugador sobre su ranking
        RankingEvents.RankingNotification:FireClient(player, {
            Type = "LevelCompleted",
            Level = levelData.Level,
            Time = levelData.Time,
            Deaths = levelData.Deaths,
            Rank = playerRank
        })
        
        print("Jugador " .. player.Name .. " completó el nivel " .. levelData.Level)
    end
end

-- Función para cuando un jugador muere
function MultiplayerManager.OnPlayerDied(player)
    local userId = player.UserId
    
    if PlayerStates[userId] and PlayerStates[userId].CurrentLevel > 0 then
        -- Notificar a otros jugadores del nivel
        MultiplayerManager.NotifyLevelPlayers(PlayerStates[userId].CurrentLevel, "PlayerDied", {
            UserId = userId,
            Username = player.Name
        })
        
        print("Jugador " .. player.Name .. " murió en el nivel " .. PlayerStates[userId].CurrentLevel)
    end
end

-- Función para manejar mensajes de chat
function MultiplayerManager.OnChatMessage(player, message)
    local userId = player.UserId
    
    if PlayerStates[userId] and PlayerStates[userId].Settings.ChatEnabled then
        local chatData = {
            UserId = userId,
            Username = player.Name,
            Message = message,
            Timestamp = tick()
        }
        
        -- Enviar mensaje a todos los jugadores del mismo nivel
        if PlayerStates[userId].CurrentLevel > 0 then
            MultiplayerManager.NotifyLevelPlayers(PlayerStates[userId].CurrentLevel, "ChatMessage", chatData)
        else
            -- Enviar a todos los jugadores en lobby
            MultiplayerManager.NotifyLobbyPlayers("ChatMessage", chatData)
        end
    end
end

-- Función para manejar espectar jugador
function MultiplayerManager.OnSpectatePlayer(player, targetUserId)
    local userId = player.UserId
    
    if PlayerStates[userId] and PlayerStates[targetUserId] then
        PlayerStates[userId].State = PlayerStateTypes.SPECTATING
        PlayerStates[userId].Spectating = targetUserId
        
        -- Notificar al jugador objetivo
        local targetPlayer = Players:GetPlayerByUserId(targetUserId)
        if targetPlayer then
            RankingEvents.SpectatePlayer:FireClient(targetPlayer, {
                SpectatorId = userId,
                SpectatorName = player.Name
            })
        end
        
        print("Jugador " .. player.Name .. " está espectando a " .. (PlayerStates[targetUserId].Username or "jugador"))
    end
end

-- Función para manejar desafíos entre jugadores
function MultiplayerManager.OnChallengePlayer(player, targetUserId)
    local userId = player.UserId
    local targetPlayer = Players:GetPlayerByUserId(targetUserId)
    
    if targetPlayer and PlayerStates[userId] and PlayerStates[targetUserId] then
        -- Enviar desafío al jugador objetivo
        RankingEvents.ChallengePlayer:FireClient(targetPlayer, {
            ChallengerId = userId,
            ChallengerName = player.Name,
            Level = PlayerStates[userId].CurrentLevel
        })
        
        print("Jugador " .. player.Name .. " desafió a " .. targetPlayer.Name)
    end
end

-- Función para manejar aceptar desafío
function MultiplayerManager.OnAcceptChallenge(player, challengerUserId)
    local userId = player.UserId
    local challengerPlayer = Players:GetPlayerByUserId(challengerUserId)
    
    if challengerPlayer and PlayerStates[userId] and PlayerStates[challengerUserId] then
        -- Notificar al retador
        RankingEvents.AcceptChallenge:FireClient(challengerPlayer, {
            ChallengedId = userId,
            ChallengedName = player.Name
        })
        
        print("Jugador " .. player.Name .. " aceptó el desafío de " .. challengerPlayer.Name)
    end
end

-- Función para manejar rechazar desafío
function MultiplayerManager.OnDeclineChallenge(player, challengerUserId)
    local userId = player.UserId
    local challengerPlayer = Players:GetPlayerByUserId(challengerUserId)
    
    if challengerPlayer and PlayerStates[userId] and PlayerStates[challengerUserId] then
        -- Notificar al retador
        RankingEvents.DeclineChallenge:FireClient(challengerPlayer, {
            ChallengedId = userId,
            ChallengedName = player.Name
        })
        
        print("Jugador " .. player.Name .. " rechazó el desafío de " .. challengerPlayer.Name)
    end
end

-- Función para manejar actualización de configuración
function MultiplayerManager.OnUpdatePlayerSettings(player, settings)
    local userId = player.UserId
    
    if PlayerStates[userId] then
        PlayerStates[userId].Settings = settings
        print("Configuración actualizada para " .. player.Name)
    end
end

-- Función para notificar jugadores de un nivel
function MultiplayerManager.NotifyLevelPlayers(levelNumber, eventType, data)
    if LevelPlayers[levelNumber] then
        for playerUserId, playerData in pairs(LevelPlayers[levelNumber]) do
            local player = Players:GetPlayerByUserId(playerUserId)
            if player then
                RankingEvents.UpdateLevelPlayers:FireClient(player, {
                    EventType = eventType,
                    Data = data
                })
            end
        end
    end
end

-- Función para notificar jugadores en lobby
function MultiplayerManager.NotifyLobbyPlayers(eventType, data)
    for userId, playerState in pairs(PlayerStates) do
        if playerState.State == PlayerStateTypes.LOBBY then
            local player = Players:GetPlayerByUserId(userId)
            if player then
                RankingEvents.UpdateLevelPlayers:FireClient(player, {
                    EventType = eventType,
                    Data = data
                })
            end
        end
    end
end

-- Función para notificar que un jugador se unió
function MultiplayerManager.NotifyPlayerJoined(player)
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            RankingEvents.PlayerJoinedLevel:FireClient(otherPlayer, {
                UserId = player.UserId,
                Username = player.Name,
                JoinTime = tick()
            })
        end
    end
end

-- Función para notificar que un jugador se fue
function MultiplayerManager.NotifyPlayerLeft(player)
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        RankingEvents.PlayerLeftLevel:FireClient(otherPlayer, {
            UserId = player.UserId,
            Username = player.Name
        })
    end
end

-- Función para obtener lista de jugadores online
function MultiplayerManager.GetOnlinePlayersList()
    local onlineList = {}
    
    for userId, playerData in pairs(OnlinePlayers) do
        table.insert(onlineList, {
            UserId = playerData.UserId,
            Username = playerData.Username,
            DisplayName = playerData.DisplayName,
            State = playerData.State,
            CurrentLevel = playerData.CurrentLevel,
            JoinTime = playerData.JoinTime
        })
    end
    
    return onlineList
end

-- Función para obtener amigos de un jugador
function MultiplayerManager.GetPlayerFriends(userId)
    if PlayerStates[userId] then
        return PlayerStates[userId].Friends
    end
    return {}
end

-- Función para obtener clan de un jugador
function MultiplayerManager.GetPlayerClan(userId)
    if PlayerStates[userId] then
        return PlayerStates[userId].Clan
    end
    return nil
end

-- Función para enviar datos iniciales a un jugador
function MultiplayerManager.SendInitialData(player)
    local userId = player.UserId
    
    -- Enviar información de jugadores online
    local onlinePlayers = MultiplayerManager.GetOnlinePlayersList()
    RankingEvents.UpdateLevelPlayers:FireClient(player, {
        EventType = "InitialData",
        Data = {
            OnlinePlayers = onlinePlayers,
            PlayerStates = PlayerStates,
            LevelPlayers = LevelPlayers
        }
    })
    
    -- Enviar configuración del jugador
    if PlayerStates[userId] then
        RankingEvents.UpdatePlayerSettings:FireClient(player, PlayerStates[userId].Settings)
    end
end

-- Función para obtener estadísticas de multijugador
function MultiplayerManager.GetMultiplayerStats()
    local stats = {
        TotalPlayers = #Players:GetPlayers(),
        PlayersInLobby = 0,
        PlayersPlaying = 0,
        PlayersSpectating = 0,
        LevelDistribution = {}
    }
    
    for userId, playerState in pairs(PlayerStates) do
        if playerState.State == PlayerStateTypes.LOBBY then
            stats.PlayersInLobby = stats.PlayersInLobby + 1
        elseif playerState.State == PlayerStateTypes.PLAYING then
            stats.PlayersPlaying = stats.PlayersPlaying + 1
        elseif playerState.State == PlayerStateTypes.SPECTATING then
            stats.PlayersSpectating = stats.PlayersSpectating + 1
        end
    end
    
    for levelNumber, players in pairs(LevelPlayers) do
        stats.LevelDistribution[levelNumber] = #players
    end
    
    return stats
end

-- Función para limpiar datos antiguos
function MultiplayerManager.CleanupOldData()
    local currentTime = tick()
    local timeout = 300 -- 5 minutos
    
    for userId, playerState in pairs(PlayerStates) do
        if currentTime - playerState.LastActivity > timeout then
            playerState.State = PlayerStateTypes.AFK
        end
    end
end

-- Inicializar sistema
MultiplayerManager.Initialize()

-- Limpiar datos antiguos cada minuto
spawn(function()
    while true do
        wait(60)
        MultiplayerManager.CleanupOldData()
    end
end)

return MultiplayerManager 