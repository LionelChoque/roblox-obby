-- ShopUI.client.lua
-- Interfaz de usuario de la tienda para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

-- Eventos remotos
local RankingEvents = ReplicatedStorage:WaitForChild("RankingEvents")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ShopUI = {}

-- Referencias de la UI
local ShopGui = nil
local CurrentCategory = "all"
local ShopItems = {}
local PlayerInventory = {}
local PlayerCurrency = { coins = 0, gems = 0, tokens = 0 }

-- Categorías de la tienda
local ShopCategories = {
    { id = "all", name = "TODOS", icon = "🛍️" },
    { id = "characters", name = "PERSONAJES", icon = "👤" },
    { id = "effects", name = "EFECTOS", icon = "✨" },
    { id = "boosts", name = "BOOSTS", icon = "⚡" },
    { id = "cosmetics", name = "COSMÉTICOS", icon = "👑" },
    { id = "powerups", name = "POWER-UPS", icon = "💪" }
}

-- Función para crear la UI de la tienda
function ShopUI.CreateShopUI()
    if ShopGui then
        ShopGui:Destroy()
    end
    
    ShopGui = Instance.new("ScreenGui")
    ShopGui.Name = "ShopUI"
    ShopGui.Parent = playerGui
    
    -- Fondo principal
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.3
    background.Parent = ShopGui
    
    -- Panel principal
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(0, 1000, 0, 700)
    mainPanel.Position = UDim2.new(0.5, -500, 0.5, -350)
    mainPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainPanel.BorderSizePixel = 0
    mainPanel.Parent = background
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    title.Text = "TIENDA"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainPanel
    
    -- Panel de monedas del jugador
    local currencyPanel = Instance.new("Frame")
    currencyPanel.Name = "CurrencyPanel"
    currencyPanel.Size = UDim2.new(1, -40, 0, 50)
    currencyPanel.Position = UDim2.new(0, 20, 0, 80)
    currencyPanel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    currencyPanel.BorderSizePixel = 0
    currencyPanel.Parent = mainPanel
    
    -- Monedas
    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Name = "CoinsLabel"
    coinsLabel.Size = UDim2.new(0.33, 0, 1, 0)
    coinsLabel.Position = UDim2.new(0, 10, 0, 0)
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Text = "🪙 " .. PlayerCurrency.coins
    coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinsLabel.TextScaled = true
    coinsLabel.Font = Enum.Font.GothamBold
    coinsLabel.Parent = currencyPanel
    
    -- Gemas
    local gemsLabel = Instance.new("TextLabel")
    gemsLabel.Name = "GemsLabel"
    gemsLabel.Size = UDim2.new(0.33, 0, 1, 0)
    gemsLabel.Position = UDim2.new(0.33, 0, 0, 0)
    gemsLabel.BackgroundTransparency = 1
    gemsLabel.Text = "💎 " .. PlayerCurrency.gems
    gemsLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    gemsLabel.TextScaled = true
    gemsLabel.Font = Enum.Font.GothamBold
    gemsLabel.Parent = currencyPanel
    
    -- Tokens
    local tokensLabel = Instance.new("TextLabel")
    tokensLabel.Name = "TokensLabel"
    tokensLabel.Size = UDim2.new(0.33, 0, 1, 0)
    tokensLabel.Position = UDim2.new(0.66, 0, 0, 0)
    tokensLabel.BackgroundTransparency = 1
    tokensLabel.Text = "🎫 " .. PlayerCurrency.tokens
    tokensLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
    tokensLabel.TextScaled = true
    tokensLabel.Font = Enum.Font.GothamBold
    tokensLabel.Parent = currencyPanel
    
    -- Panel de categorías
    local categoryPanel = Instance.new("Frame")
    categoryPanel.Name = "CategoryPanel"
    categoryPanel.Size = UDim2.new(1, -40, 0, 60)
    categoryPanel.Position = UDim2.new(0, 20, 0, 150)
    categoryPanel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    categoryPanel.BorderSizePixel = 0
    categoryPanel.Parent = mainPanel
    
    -- Crear botones de categoría
    for i, category in ipairs(ShopCategories) do
        local categoryButton = Instance.new("TextButton")
        categoryButton.Name = category.id .. "Button"
        categoryButton.Size = UDim2.new(1 / #ShopCategories, -10, 1, -10)
        categoryButton.Position = UDim2.new((i-1) / #ShopCategories, 5, 0, 5)
        categoryButton.BackgroundColor3 = i == 1 and GameConstants.UI.PRIMARY_COLOR or GameConstants.UI.SECONDARY_COLOR
        categoryButton.Text = category.icon .. " " .. category.name
        categoryButton.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
        categoryButton.TextScaled = true
        categoryButton.Font = Enum.Font.GothamBold
        categoryButton.Parent = categoryPanel
        
        categoryButton.MouseButton1Click:Connect(function()
            ShopUI.SwitchCategory(category.id)
        end)
    end
    
    -- Panel de items
    local itemsPanel = Instance.new("Frame")
    itemsPanel.Name = "ItemsPanel"
    itemsPanel.Size = UDim2.new(1, -40, 1, -250)
    itemsPanel.Position = UDim2.new(0, 20, 0, 230)
    itemsPanel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    itemsPanel.BorderSizePixel = 0
    itemsPanel.Parent = mainPanel
    
    -- ScrollFrame para items
    local itemsScroll = Instance.new("ScrollingFrame")
    itemsScroll.Name = "ItemsScroll"
    itemsScroll.Size = UDim2.new(1, 0, 1, 0)
    itemsScroll.Position = UDim2.new(0, 0, 0, 0)
    itemsScroll.BackgroundTransparency = 1
    itemsScroll.ScrollBarThickness = 6
    itemsScroll.Parent = itemsPanel
    
    -- Grid de items
    local itemsGrid = Instance.new("UIGridLayout")
    itemsGrid.Name = "ItemsGrid"
    itemsGrid.CellSize = UDim2.new(0, 200, 0, 250)
    itemsGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    itemsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    itemsGrid.Parent = itemsScroll
    
    -- Botón de cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 150, 0, 40)
    closeButton.Position = UDim2.new(0.5, -75, 1, -60)
    closeButton.BackgroundColor3 = GameConstants.UI.ERROR_COLOR
    closeButton.Text = "CERRAR"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainPanel
    
    closeButton.MouseButton1Click:Connect(function()
        ShopUI.HideShop()
    end)
    
    -- Cargar items de la tienda
    ShopUI.LoadShopItems()
    
    return ShopGui
end

-- Función para cambiar categoría
function ShopUI.SwitchCategory(categoryId)
    CurrentCategory = categoryId
    
    -- Actualizar colores de botones de categoría
    local categoryPanel = ShopGui.MainPanel.CategoryPanel
    for i, category in ipairs(ShopCategories) do
        local button = categoryPanel:FindFirstChild(category.id .. "Button")
        if button then
            if category.id == categoryId then
                button.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                button.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
                button.TextColor3 = Color3.fromRGB(0, 0, 0)
            end
        end
    end
    
    -- Recargar items
    ShopUI.LoadShopItems()
end

-- Función para cargar items de la tienda
function ShopUI.LoadShopItems()
    spawn(function()
        local success, items = pcall(function()
            return RankingEvents.GetShopItems:InvokeServer(CurrentCategory)
        end)
        
        if success and items then
            ShopItems = items
            ShopUI.DisplayShopItems()
        else
            print("Error al cargar items de la tienda")
        end
    end)
end

-- Función para mostrar items de la tienda
function ShopUI.DisplayShopItems()
    local itemsScroll = ShopGui.MainPanel.ItemsPanel.ItemsScroll
    
    -- Limpiar items existentes
    for _, child in pairs(itemsScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Mostrar items
    for i, item in ipairs(ShopItems) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = "ItemFrame_" .. i
        itemFrame.Size = UDim2.new(0, 200, 0, 250)
        itemFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        itemFrame.BorderSizePixel = 0
        itemFrame.Parent = itemsScroll
        
        -- Imagen del item
        local itemImage = Instance.new("ImageLabel")
        itemImage.Name = "ItemImage"
        itemImage.Size = UDim2.new(1, -20, 0, 120)
        itemImage.Position = UDim2.new(0, 10, 0, 10)
        itemImage.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        itemImage.Image = item.ImageId or "rbxassetid://0"
        itemImage.Parent = itemFrame
        
        -- Nombre del item
        local itemName = Instance.new("TextLabel")
        itemName.Name = "ItemName"
        itemName.Size = UDim2.new(1, -20, 0, 30)
        itemName.Position = UDim2.new(0, 10, 0, 140)
        itemName.BackgroundTransparency = 1
        itemName.Text = item.Name
        itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
        itemName.TextScaled = true
        itemName.Font = Enum.Font.GothamBold
        itemName.Parent = itemFrame
        
        -- Descripción del item
        local itemDescription = Instance.new("TextLabel")
        itemDescription.Name = "ItemDescription"
        itemDescription.Size = UDim2.new(1, -20, 0, 40)
        itemDescription.Position = UDim2.new(0, 10, 0, 170)
        itemDescription.BackgroundTransparency = 1
        itemDescription.Text = item.Description
        itemDescription.TextColor3 = Color3.fromRGB(200, 200, 200)
        itemDescription.TextScaled = true
        itemDescription.Font = Enum.Font.Gotham
        itemDescription.Parent = itemFrame
        
        -- Precio del item
        local priceText = ""
        for currencyType, price in pairs(item.Price) do
            local icon = currencyType == "coins" and "🪙" or currencyType == "gems" and "💎" or "🎫"
            priceText = priceText .. icon .. price .. " "
        end
        
        local itemPrice = Instance.new("TextLabel")
        itemPrice.Name = "ItemPrice"
        itemPrice.Size = UDim2.new(1, -20, 0, 25)
        itemPrice.Position = UDim2.new(0, 10, 0, 210)
        itemPrice.BackgroundTransparency = 1
        itemPrice.Text = priceText
        itemPrice.TextColor3 = Color3.fromRGB(255, 215, 0)
        itemPrice.TextScaled = true
        itemPrice.Font = Enum.Font.GothamBold
        itemPrice.Parent = itemFrame
        
        -- Botón de compra
        local buyButton = Instance.new("TextButton")
        buyButton.Name = "BuyButton"
        buyButton.Size = UDim2.new(1, -20, 0, 30)
        buyButton.Position = UDim2.new(0, 10, 0, 220)
        buyButton.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
        buyButton.Text = "COMPRAR"
        buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyButton.TextScaled = true
        buyButton.Font = Enum.Font.GothamBold
        buyButton.Parent = itemFrame
        
        buyButton.MouseButton1Click:Connect(function()
            ShopUI.PurchaseItem(item.Id)
        end)
        
        -- Verificar si el jugador ya tiene el item
        if PlayerInventory[item.Id] then
            buyButton.Text = "YA TIENES"
            buyButton.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
            buyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        end
    end
    
    -- Ajustar tamaño del ScrollFrame
    itemsScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#ShopItems / 4) * 260)
end

-- Función para comprar item
function ShopUI.PurchaseItem(itemId)
    spawn(function()
        local success, result = pcall(function()
            return RankingEvents.PurchaseItem:InvokeServer(itemId)
        end)
        
        if success and result then
            if result.success then
                ShopUI.ShowPurchaseSuccess(result.item, result.price)
                ShopUI.UpdatePlayerCurrency()
                ShopUI.LoadShopItems() -- Recargar para actualizar botones
            else
                ShopUI.ShowPurchaseError(result.message)
            end
        else
            ShopUI.ShowPurchaseError("Error al procesar la compra")
        end
    end)
end

-- Función para mostrar éxito de compra
function ShopUI.ShowPurchaseSuccess(item, price)
    local notification = Instance.new("ScreenGui")
    notification.Name = "PurchaseSuccess"
    notification.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0.5, -150, 0.3, 0)
    frame.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = "¡Compra exitosa!\n" .. item.Name
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = frame
    
    -- Animación de entrada
    frame.Position = UDim2.new(0.5, -150, 0, -100)
    local enterTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
        Position = UDim2.new(0.5, -150, 0.3, 0)
    })
    enterTween:Play()
    
    -- Animación de salida
    spawn(function()
        wait(3)
        local exitTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
            Position = UDim2.new(0.5, -150, 0, -100)
        })
        exitTween:Play()
        exitTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Función para mostrar error de compra
function ShopUI.ShowPurchaseError(message)
    local notification = Instance.new("ScreenGui")
    notification.Name = "PurchaseError"
    notification.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0.5, -150, 0.3, 0)
    frame.BackgroundColor3 = GameConstants.UI.ERROR_COLOR
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = "Error: " .. message
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = frame
    
    -- Animación de entrada
    frame.Position = UDim2.new(0.5, -150, 0, -100)
    local enterTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
        Position = UDim2.new(0.5, -150, 0.3, 0)
    })
    enterTween:Play()
    
    -- Animación de salida
    spawn(function()
        wait(3)
        local exitTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
            Position = UDim2.new(0.5, -150, 0, -100)
        })
        exitTween:Play()
        exitTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Función para actualizar monedas del jugador
function ShopUI.UpdatePlayerCurrency()
    spawn(function()
        local success, playerData = pcall(function()
            return RankingEvents.GetPlayerEconomy:InvokeServer()
        end)
        
        if success and playerData then
            PlayerCurrency.coins = playerData.Coins or 0
            PlayerCurrency.gems = playerData.Gems or 0
            PlayerCurrency.tokens = playerData.Tokens or 0
            
            -- Actualizar labels
            local currencyPanel = ShopGui.MainPanel.CurrencyPanel
            if currencyPanel then
                local coinsLabel = currencyPanel.CoinsLabel
                local gemsLabel = currencyPanel.GemsLabel
                local tokensLabel = currencyPanel.TokensLabel
                
                if coinsLabel then coinsLabel.Text = "🪙 " .. PlayerCurrency.coins end
                if gemsLabel then gemsLabel.Text = "💎 " .. PlayerCurrency.gems end
                if tokensLabel then tokensLabel.Text = "🎫 " .. PlayerCurrency.tokens end
            end
        end
    end)
end

-- Función para cargar inventario del jugador
function ShopUI.LoadPlayerInventory()
    spawn(function()
        local success, inventory = pcall(function()
            return RankingEvents.GetPlayerInventory:InvokeServer()
        end)
        
        if success and inventory then
            PlayerInventory = inventory
        end
    end)
end

-- Función para mostrar tienda
function ShopUI.ShowShop()
    if not ShopGui then
        ShopUI.CreateShopUI()
    else
        ShopGui.Enabled = true
    end
    
    -- Actualizar datos del jugador
    ShopUI.UpdatePlayerCurrency()
    ShopUI.LoadPlayerInventory()
end

-- Función para ocultar tienda
function ShopUI.HideShop()
    if ShopGui then
        ShopGui.Enabled = false
    end
end

return ShopUI 