-- NotificationSystem.client.lua
-- Sistema de notificaciones y feedback visual para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NotificationSystem = {}

-- Cola de notificaciones
local NotificationQueue = {}
local IsShowingNotification = false

-- Tipos de notificaciones
local NotificationTypes = {
    SUCCESS = {
        Color = GameConstants.UI.SUCCESS_COLOR,
        Icon = "✓"
    },
    ERROR = {
        Color = GameConstants.UI.ERROR_COLOR,
        Icon = "✗"
    },
    WARNING = {
        Color = GameConstants.UI.WARNING_COLOR,
        Icon = "⚠"
    },
    INFO = {
        Color = GameConstants.UI.PRIMARY_COLOR,
        Icon = "ℹ"
    },
    ACHIEVEMENT = {
        Color = Color3.fromRGB(255, 215, 0),
        Icon = "🏆"
    },
    CHECKPOINT = {
        Color = Color3.fromRGB(0, 255, 0),
        Icon = "📍"
    },
    LEVEL_COMPLETE = {
        Color = Color3.fromRGB(0, 255, 255),
        Icon = "🎉"
    }
}

-- Función para mostrar notificación
function NotificationSystem.ShowNotification(message, notificationType, duration)
    notificationType = notificationType or "INFO"
    duration = duration or 3
    
    local notificationData = {
        message = message,
        type = notificationType,
        duration = duration,
        timestamp = tick()
    }
    
    table.insert(NotificationQueue, notificationData)
    
    if not IsShowingNotification then
        NotificationSystem.ProcessNotificationQueue()
    end
end

-- Función para procesar la cola de notificaciones
function NotificationSystem.ProcessNotificationQueue()
    if #NotificationQueue == 0 then
        IsShowingNotification = false
        return
    end
    
    IsShowingNotification = true
    local notificationData = table.remove(NotificationQueue, 1)
    
    NotificationSystem.DisplayNotification(notificationData)
end

-- Función para mostrar una notificación individual
function NotificationSystem.DisplayNotification(notificationData)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Notification_" .. notificationData.timestamp
    screenGui.Parent = playerGui
    
    local notificationType = NotificationTypes[notificationData.type] or NotificationTypes.INFO
    
    -- Panel principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 60)
    mainFrame.Position = UDim2.new(0.5, -175, 0, -60)
    mainFrame.BackgroundColor3 = notificationType.Color
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Icono
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 40, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = notificationType.Icon
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextScaled = true
    icon.Font = Enum.Font.GothamBold
    icon.Parent = mainFrame
    
    -- Mensaje
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -60, 1, 0)
    messageLabel.Position = UDim2.new(0, 50, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = notificationData.message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = mainFrame
    
    -- Animación de entrada
    local enterTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
        Position = UDim2.new(0.5, -175, 0.1, 0)
    })
    enterTween:Play()
    
    -- Animación de salida después del tiempo especificado
    spawn(function()
        wait(notificationData.duration)
        local exitTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
            Position = UDim2.new(0.5, -175, 0, -60)
        })
        exitTween:Play()
        exitTween.Completed:Connect(function()
            screenGui:Destroy()
            NotificationSystem.ProcessNotificationQueue()
        end)
    end)
end

-- Función para mostrar feedback de checkpoint
function NotificationSystem.ShowCheckpointFeedback(checkpointNumber)
    NotificationSystem.ShowNotification(
        "Checkpoint " .. checkpointNumber .. " alcanzado!",
        "CHECKPOINT",
        2
    )
end

-- Función para mostrar feedback de nivel completado
function NotificationSystem.ShowLevelCompleteFeedback(levelNumber, time, deaths)
    local message = string.format(
        "¡Nivel %d completado!\nTiempo: %02d:%02d | Muertes: %d",
        levelNumber,
        math.floor(time / 60),
        time % 60,
        deaths
    )
    
    NotificationSystem.ShowNotification(message, "LEVEL_COMPLETE", 4)
end

-- Función para mostrar feedback de logro
function NotificationSystem.ShowAchievementFeedback(achievementName, description)
    local message = "¡Logro desbloqueado!\n" .. achievementName .. "\n" .. description
    NotificationSystem.ShowNotification(message, "ACHIEVEMENT", 4)
end

-- Función para mostrar feedback de muerte
function NotificationSystem.ShowDeathFeedback()
    NotificationSystem.ShowNotification("¡Has muerto! Reintentando...", "ERROR", 1.5)
end

-- Función para mostrar feedback de trampa detectada
function NotificationSystem.ShowAntiCheatFeedback()
    NotificationSystem.ShowNotification("Trampa detectada. Nivel reiniciado.", "WARNING", 3)
end

-- Función para mostrar feedback de monedas recolectadas
function NotificationSystem.ShowCoinCollectedFeedback(amount)
    NotificationSystem.ShowNotification(
        "+" .. amount .. " monedas recolectadas!",
        "SUCCESS",
        2
    )
end

-- Función para mostrar feedback de gemas recolectadas
function NotificationSystem.ShowGemCollectedFeedback(amount)
    NotificationSystem.ShowNotification(
        "+" .. amount .. " gemas recolectadas!",
        "SUCCESS",
        2
    )
end

-- Función para mostrar feedback de power-up
function NotificationSystem.ShowPowerUpFeedback(powerUpName)
    NotificationSystem.ShowNotification(
        "¡Power-up activado: " .. powerUpName .. "!",
        "INFO",
        2
    )
end

-- Función para mostrar feedback de error de conexión
function NotificationSystem.ShowConnectionErrorFeedback()
    NotificationSystem.ShowNotification(
        "Error de conexión. Intentando reconectar...",
        "ERROR",
        3
    )
end

-- Función para mostrar feedback de guardado
function NotificationSystem.ShowSaveFeedback()
    NotificationSystem.ShowNotification(
        "Progreso guardado exitosamente",
        "SUCCESS",
        2
    )
end

-- Función para mostrar feedback de carga
function NotificationSystem.ShowLoadFeedback()
    NotificationSystem.ShowNotification(
        "Progreso cargado exitosamente",
        "INFO",
        2
    )
end

-- Función para mostrar feedback de error de guardado
function NotificationSystem.ShowSaveErrorFeedback()
    NotificationSystem.ShowNotification(
        "Error al guardar progreso",
        "ERROR",
        3
    )
end

-- Función para mostrar feedback de ranking
function NotificationSystem.ShowRankingFeedback(rank, totalPlayers)
    local message = string.format(
        "Posición en ranking: %d/%d",
        rank,
        totalPlayers
    )
    NotificationSystem.ShowNotification(message, "INFO", 3)
end

-- Función para mostrar feedback de nuevo récord
function NotificationSystem.ShowNewRecordFeedback(levelNumber, time)
    local message = string.format(
        "¡Nuevo récord en nivel %d!\nTiempo: %02d:%02d",
        levelNumber,
        math.floor(time / 60),
        time % 60
    )
    NotificationSystem.ShowNotification(message, "ACHIEVEMENT", 4)
end

-- Función para mostrar feedback de compra exitosa
function NotificationSystem.ShowPurchaseSuccessFeedback(itemName)
    NotificationSystem.ShowNotification(
        "¡" .. itemName .. " comprado exitosamente!",
        "SUCCESS",
        2
    )
end

-- Función para mostrar feedback de fondos insuficientes
function NotificationSystem.ShowInsufficientFundsFeedback()
    NotificationSystem.ShowNotification(
        "Fondos insuficientes para esta compra",
        "WARNING",
        3
    )
end

-- Función para limpiar todas las notificaciones
function NotificationSystem.ClearAllNotifications()
    for _, child in pairs(playerGui:GetChildren()) do
        if child.Name:find("Notification_") then
            child:Destroy()
        end
    end
    
    NotificationQueue = {}
    IsShowingNotification = false
end

-- Función para obtener estadísticas de notificaciones
function NotificationSystem.GetNotificationStats()
    return {
        QueueLength = #NotificationQueue,
        IsShowing = IsShowingNotification,
        TotalShown = 0 -- TODO: Implementar contador
    }
end

-- Función para configurar notificaciones
function NotificationSystem.ConfigureNotifications(enabled, types)
    -- TODO: Implementar configuración de notificaciones
    print("Configuración de notificaciones actualizada")
end

return NotificationSystem 