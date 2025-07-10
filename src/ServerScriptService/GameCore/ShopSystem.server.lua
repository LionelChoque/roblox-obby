-- ShopSystem.server.lua
-- Sistema de tienda y transacciones para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

-- Eventos remotos
local RankingEvents = ReplicatedStorage:WaitForChild("RankingEvents")

-- DataStores
local ShopDataStore = DataStoreService:GetDataStore("ObbyShop")
local TransactionDataStore = DataStoreService:GetDataStore("ObbyTransactions")

local ShopSystem = {}

-- Estado de la tienda
local ShopInventory = {}
local ActivePromotions = {}
local TransactionLog = {}

-- Tipos de transacción
local TransactionStatus = {
    PENDING = "pending",
    COMPLETED = "completed",
    FAILED = "failed",
    REFUNDED = "refunded"
}

-- Función para inicializar el sistema de tienda
function ShopSystem.Initialize()
    print("Inicializando sistema de tienda...")
    
    -- Cargar inventario de la tienda
    ShopSystem.LoadShopInventory()
    
    -- Cargar promociones activas
    ShopSystem.LoadActivePromotions()
    
    -- Configurar eventos remotos
    ShopSystem.SetupRemoteEvents()
    
    print("Sistema de tienda inicializado correctamente")
end

-- Función para cargar inventario de la tienda
function ShopSystem.LoadShopInventory()
    local success, inventory = pcall(function()
        return ShopDataStore:GetAsync("ShopInventory")
    end)
    
    if success and inventory then
        ShopInventory = inventory
    else
        -- Crear inventario por defecto
        ShopSystem.CreateDefaultInventory()
    end
end

-- Función para crear inventario por defecto
function ShopSystem.CreateDefaultInventory()
    ShopInventory = {
        -- Personajes
        {
            Id = "char_speedster",
            Name = "Speedster",
            Description = "Personaje con velocidad aumentada",
            Category = "characters",
            Price = { coins = 500, gems = 0 },
            Rarity = "common",
            ImageId = "rbxassetid://123456",
            Available = true,
            Stock = -1, -- -1 = ilimitado
            Discount = 0
        },
        {
            Id = "char_jumper",
            Name = "Jumper",
            Description = "Personaje con salto mejorado",
            Category = "characters",
            Price = { coins = 750, gems = 0 },
            Rarity = "common",
            ImageId = "rbxassetid://123457",
            Available = true,
            Stock = -1,
            Discount = 0
        },
        {
            Id = "char_shield",
            Name = "Shield",
            Description = "Personaje con escudo protector",
            Category = "characters",
            Price = { coins = 1000, gems = 5 },
            Rarity = "rare",
            ImageId = "rbxassetid://123458",
            Available = true,
            Stock = -1,
            Discount = 0
        },
        
        -- Efectos
        {
            Id = "effect_trail_gold",
            Name = "Trail Dorado",
            Description = "Deja un rastro dorado al moverse",
            Category = "effects",
            Price = { coins = 200, gems = 0 },
            Rarity = "common",
            ImageId = "rbxassetid://123459",
            Available = true,
            Stock = -1,
            Discount = 0
        },
        {
            Id = "effect_particles_magic",
            Name = "Partículas Mágicas",
            Description = "Partículas especiales al moverse",
            Category = "effects",
            Price = { coins = 300, gems = 1 },
            Rarity = "uncommon",
            ImageId = "rbxassetid://123460",
            Available = true,
            Stock = -1,
            Discount = 0
        },
        {
            Id = "effect_rainbow",
            Name = "Efecto Arcoíris",
            Description = "Efecto arcoíris completo",
            Category = "effects",
            Price = { coins = 500, gems = 3 },
            Rarity = "rare",
            ImageId = "rbxassetid://123461",
            Available = true,
            Stock = -1,
            Discount = 0
        },
        
        -- Boosts
        {
            Id = "boost_speed_1h",
            Name = "Boost de Velocidad (1h)",
            Description = "Aumenta la velocidad por 1 hora",
            Category = "boosts",
            Price = { coins = 100, gems = 0 },
            Rarity = "common",
            ImageId = "rbxassetid://123462",
            Available = true,
            Stock = -1,
            Discount = 0,
            Duration = 3600
        },
        {
            Id = "boost_jump_1h",
            Name = "Boost de Salto (1h)",
            Description = "Aumenta el salto por 1 hora",
            Category = "boosts",
            Price = { coins = 100, gems = 0 },
            Rarity = "common",
            ImageId = "rbxassetid://123463",
            Available = true,
            Stock = -1,
            Discount = 0,
            Duration = 3600
        },
        {
            Id = "boost_all_1h",
            Name = "Boost Completo (1h)",
            Description = "Aumenta velocidad y salto por 1 hora",
            Category = "boosts",
            Price = { coins = 200, gems = 1 },
            Rarity = "uncommon",
            ImageId = "rbxassetid://123464",
            Available = true,
            Stock = -1,
            Discount = 0,
            Duration = 3600
        },
        
        -- Cosméticos
        {
            Id = "cosmetic_crown",
            Name = "Corona Real",
            Description = "Corona dorada para el personaje",
            Category = "cosmetics",
            Price = { coins = 1000, gems = 10 },
            Rarity = "epic",
            ImageId = "rbxassetid://123465",
            Available = true,
            Stock = -1,
            Discount = 0
        },
        {
            Id = "cosmetic_wings",
            Name = "Alas Mágicas",
            Description = "Alas que flotan detrás del personaje",
            Category = "cosmetics",
            Price = { coins = 1500, gems = 15 },
            Rarity = "epic",
            ImageId = "rbxassetid://123466",
            Available = true,
            Stock = -1,
            Discount = 0
        },
        {
            Id = "cosmetic_halo",
            Name = "Halo Divino",
            Description = "Halo flotante sobre la cabeza",
            Category = "cosmetics",
            Price = { coins = 2000, gems = 20 },
            Rarity = "legendary",
            ImageId = "rbxassetid://123467",
            Available = true,
            Stock = -1,
            Discount = 0
        },
        
        -- Power-ups
        {
            Id = "powerup_double_jump",
            Name = "Doble Salto",
            Description = "Permite saltar dos veces",
            Category = "powerups",
            Price = { coins = 500, gems = 5 },
            Rarity = "rare",
            ImageId = "rbxassetid://123468",
            Available = true,
            Stock = -1,
            Discount = 0
        },
        {
            Id = "powerup_teleport",
            Name = "Teletransporte",
            Description = "Teletransporte corto",
            Category = "powerups",
            Price = { coins = 750, gems = 8 },
            Rarity = "rare",
            ImageId = "rbxassetid://123469",
            Available = true,
            Stock = -1,
            Discount = 0
        },
        {
            Id = "powerup_shield",
            Name = "Escudo Protector",
            Description = "Escudo que protege de una muerte",
            Category = "powerups",
            Price = { coins = 1000, gems = 10 },
            Rarity = "epic",
            ImageId = "rbxassetid://123470",
            Available = true,
            Stock = -1,
            Discount = 0
        }
    }
    
    ShopSystem.SaveShopInventory()
end

-- Función para guardar inventario de la tienda
function ShopSystem.SaveShopInventory()
    local success, error = pcall(function()
        ShopDataStore:SetAsync("ShopInventory", ShopInventory)
    end)
    
    if success then
        print("Inventario de la tienda guardado correctamente")
    else
        warn("Error al guardar inventario de la tienda:", error)
    end
end

-- Función para cargar promociones activas
function ShopSystem.LoadActivePromotions()
    local success, promotions = pcall(function()
        return ShopDataStore:GetAsync("ActivePromotions")
    end)
    
    if success and promotions then
        ActivePromotions = promotions
    else
        -- Crear promociones por defecto
        ActivePromotions = {
            {
                Id = "welcome_discount",
                Name = "Descuento de Bienvenida",
                Description = "20% de descuento en todos los items",
                Discount = 0.2,
                StartDate = os.time(),
                EndDate = os.time() + (7 * 24 * 60 * 60), -- 7 días
                Active = true
            }
        }
    end
end

-- Función para configurar eventos remotos
function ShopSystem.SetupRemoteEvents()
    -- Función para obtener items de la tienda
    RankingEvents.GetShopItems.OnServerInvoke = function(player)
        return ShopSystem.GetShopItems()
    end
    
    -- Función para comprar item
    RankingEvents.PurchaseItem.OnServerInvoke = function(player, itemId)
        return ShopSystem.ProcessPurchase(player, itemId)
    end
    
    -- Función para obtener inventario del jugador
    RankingEvents.GetPlayerInventory.OnServerInvoke = function(player)
        return ShopSystem.GetPlayerInventory(player.UserId)
    end
    
    -- Función para obtener transacciones del jugador
    RankingEvents.GetPlayerTransactions.OnServerInvoke = function(player)
        return ShopSystem.GetPlayerTransactions(player.UserId)
    end
    
    -- Función para reclamar recompensa diaria
    RankingEvents.ClaimDailyReward.OnServerInvoke = function(player)
        return ShopSystem.ClaimDailyReward(player)
    end
    
    -- Función para obtener promociones activas
    RankingEvents.GetActivePromotions.OnServerInvoke = function(player)
        return ShopSystem.GetActivePromotions()
    end
end

-- Función para obtener items de la tienda
function ShopSystem.GetShopItems(category)
    if category then
        local filteredItems = {}
        for _, item in ipairs(ShopInventory) do
            if item.Category == category and item.Available then
                table.insert(filteredItems, item)
            end
        end
        return filteredItems
    end
    
    local availableItems = {}
    for _, item in ipairs(ShopInventory) do
        if item.Available then
            table.insert(availableItems, item)
        end
    end
    
    return availableItems
end

-- Función para procesar compra
function ShopSystem.ProcessPurchase(player, itemId)
    local userId = player.UserId
    
    -- Buscar item en la tienda
    local item = nil
    for _, shopItem in ipairs(ShopInventory) do
        if shopItem.Id == itemId then
            item = shopItem
            break
        end
    end
    
    if not item then
        return { success = false, message = "Item no encontrado" }
    end
    
    if not item.Available then
        return { success = false, message = "Item no disponible" }
    end
    
    if item.Stock == 0 then
        return { success = false, message = "Item agotado" }
    end
    
    -- Verificar si el jugador ya tiene el item (para items únicos)
    local EconomySystem = require(script.Parent.EconomySystem)
    local playerEconomy = EconomySystem.GetPlayerEconomy(userId)
    
    if playerEconomy and playerEconomy.PurchasedItems and playerEconomy.PurchasedItems[itemId] then
        return { success = false, message = "Ya tienes este item" }
    end
    
    -- Calcular precio con descuentos
    local finalPrice = {}
    for currencyType, price in pairs(item.Price) do
        local discountedPrice = price * (1 - (item.Discount or 0))
        finalPrice[currencyType] = math.floor(discountedPrice)
    end
    
    -- Verificar fondos del jugador
    local canAfford = true
    local missingCurrency = {}
    
    for currencyType, price in pairs(finalPrice) do
        local currentAmount = 0
        if currencyType == "coins" then
            currentAmount = playerEconomy.Coins
        elseif currencyType == "gems" then
            currentAmount = playerEconomy.Gems
        elseif currencyType == "tokens" then
            currentAmount = playerEconomy.Tokens
        end
        
        if currentAmount < price then
            canAfford = false
            table.insert(missingCurrency, { type = currencyType, needed = price, has = currentAmount })
        end
    end
    
    if not canAfford then
        return { success = false, message = "Fondos insuficientes", missing = missingCurrency }
    end
    
    -- Crear transacción
    local transactionId = ShopSystem.CreateTransaction(userId, itemId, finalPrice)
    
    -- Procesar pago
    for currencyType, price in pairs(finalPrice) do
        EconomySystem.TakeCurrency(player, currencyType, price, "Compra: " .. item.Name)
    end
    
    -- Agregar item al inventario del jugador
    if not playerEconomy.PurchasedItems then
        playerEconomy.PurchasedItems = {}
    end
    
    playerEconomy.PurchasedItems[itemId] = {
        PurchaseDate = os.time(),
        TransactionId = transactionId,
        ItemData = item
    }
    
    -- Agregar al inventario si es un item de inventario
    if item.Category == "characters" or item.Category == "effects" or item.Category == "cosmetics" then
        if not playerEconomy.Inventory then
            playerEconomy.Inventory = {}
        end
        playerEconomy.Inventory[itemId] = item
    end
    
    -- Actualizar stock si no es ilimitado
    if item.Stock > 0 then
        item.Stock = item.Stock - 1
    end
    
    -- Completar transacción
    ShopSystem.CompleteTransaction(transactionId)
    
    -- Notificar al jugador
    RankingEvents.PurchaseSuccess:FireClient(player, {
        item = item,
        price = finalPrice,
        transactionId = transactionId
    })
    
    print("Compra exitosa: " .. player.Name .. " compró " .. item.Name)
    return { success = true, message = "Compra exitosa", item = item, transactionId = transactionId }
end

-- Función para crear transacción
function ShopSystem.CreateTransaction(userId, itemId, price)
    local transactionId = userId .. "_" .. os.time() .. "_" .. math.random(1000, 9999)
    
    local transaction = {
        Id = transactionId,
        UserId = userId,
        ItemId = itemId,
        Price = price,
        Status = TransactionStatus.PENDING,
        Timestamp = os.time(),
        CompletedAt = nil
    }
    
    TransactionLog[transactionId] = transaction
    
    return transactionId
end

-- Función para completar transacción
function ShopSystem.CompleteTransaction(transactionId)
    if TransactionLog[transactionId] then
        TransactionLog[transactionId].Status = TransactionStatus.COMPLETED
        TransactionLog[transactionId].CompletedAt = os.time()
    end
end

-- Función para obtener inventario del jugador
function ShopSystem.GetPlayerInventory(userId)
    local EconomySystem = require(script.Parent.EconomySystem)
    local playerEconomy = EconomySystem.GetPlayerEconomy(userId)
    
    if playerEconomy and playerEconomy.Inventory then
        return playerEconomy.Inventory
    end
    
    return {}
end

-- Función para obtener transacciones del jugador
function ShopSystem.GetPlayerTransactions(userId, limit)
    limit = limit or 20
    
    local transactions = {}
    for transactionId, transaction in pairs(TransactionLog) do
        if transaction.UserId == userId then
            table.insert(transactions, transaction)
        end
    end
    
    -- Ordenar por fecha (más reciente primero)
    table.sort(transactions, function(a, b)
        return a.Timestamp > b.Timestamp
    end)
    
    -- Limitar resultados
    local limitedTransactions = {}
    for i = 1, math.min(limit, #transactions) do
        table.insert(limitedTransactions, transactions[i])
    end
    
    return limitedTransactions
end

-- Función para reclamar recompensa diaria
function ShopSystem.ClaimDailyReward(player)
    local EconomySystem = require(script.Parent.EconomySystem)
    return EconomySystem.GiveDailyReward(player)
end

-- Función para obtener promociones activas
function ShopSystem.GetActivePromotions()
    local currentTime = os.time()
    local activePromotions = {}
    
    for _, promotion in ipairs(ActivePromotions) do
        if promotion.Active and currentTime >= promotion.StartDate and currentTime <= promotion.EndDate then
            table.insert(activePromotions, promotion)
        end
    end
    
    return activePromotions
end

-- Función para aplicar promoción a un item
function ShopSystem.ApplyPromotionToItem(item, promotion)
    if promotion and promotion.Discount > 0 then
        local discountedItem = table.clone(item)
        discountedItem.Discount = promotion.Discount
        
        -- Aplicar descuento a todos los precios
        for currencyType, price in pairs(discountedItem.Price) do
            discountedItem.Price[currencyType] = math.floor(price * (1 - promotion.Discount))
        end
        
        return discountedItem
    end
    
    return item
end

-- Función para obtener items con promociones aplicadas
function ShopSystem.GetShopItemsWithPromotions(category)
    local items = ShopSystem.GetShopItems(category)
    local promotions = ShopSystem.GetActivePromotions()
    
    for i, item in ipairs(items) do
        -- Aplicar promociones globales
        for _, promotion in ipairs(promotions) do
            if promotion.Active then
                items[i] = ShopSystem.ApplyPromotionToItem(item, promotion)
            end
        end
    end
    
    return items
end

-- Función para agregar promoción
function ShopSystem.AddPromotion(promotion)
    table.insert(ActivePromotions, promotion)
    ShopSystem.SavePromotions()
end

-- Función para remover promoción
function ShopSystem.RemovePromotion(promotionId)
    for i, promotion in ipairs(ActivePromotions) do
        if promotion.Id == promotionId then
            table.remove(ActivePromotions, i)
            break
        end
    end
    ShopSystem.SavePromotions()
end

-- Función para guardar promociones
function ShopSystem.SavePromotions()
    local success, error = pcall(function()
        ShopDataStore:SetAsync("ActivePromotions", ActivePromotions)
    end)
    
    if success then
        print("Promociones guardadas correctamente")
    else
        warn("Error al guardar promociones:", error)
    end
end

-- Función para obtener estadísticas de la tienda
function ShopSystem.GetShopStats()
    local stats = {
        TotalItems = #ShopInventory,
        AvailableItems = 0,
        TotalTransactions = 0,
        TotalRevenue = { coins = 0, gems = 0, tokens = 0 },
        PopularItems = {},
        Categories = {}
    }
    
    -- Contar items disponibles
    for _, item in ipairs(ShopInventory) do
        if item.Available then
            stats.AvailableItems = stats.AvailableItems + 1
        end
        
        -- Contar por categoría
        if not stats.Categories[item.Category] then
            stats.Categories[item.Category] = 0
        end
        stats.Categories[item.Category] = stats.Categories[item.Category] + 1
    end
    
    -- Analizar transacciones
    local itemSales = {}
    for transactionId, transaction in pairs(TransactionLog) do
        if transaction.Status == TransactionStatus.COMPLETED then
            stats.TotalTransactions = stats.TotalTransactions + 1
            
            -- Sumar ingresos
            for currencyType, amount in pairs(transaction.Price) do
                if not stats.TotalRevenue[currencyType] then
                    stats.TotalRevenue[currencyType] = 0
                end
                stats.TotalRevenue[currencyType] = stats.TotalRevenue[currencyType] + amount
            end
            
            -- Contar ventas por item
            if not itemSales[transaction.ItemId] then
                itemSales[transaction.ItemId] = 0
            end
            itemSales[transaction.ItemId] = itemSales[transaction.ItemId] + 1
        end
    end
    
    -- Obtener items más populares
    for itemId, sales in pairs(itemSales) do
        table.insert(stats.PopularItems, { itemId = itemId, sales = sales })
    end
    
    table.sort(stats.PopularItems, function(a, b)
        return a.sales > b.sales
    end)
    
    return stats
end

-- Inicializar sistema
ShopSystem.Initialize()

return ShopSystem 