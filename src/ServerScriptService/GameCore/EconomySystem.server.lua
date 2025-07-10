-- EconomySystem.server.lua
-- Sistema de economía para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

-- DataStores para economía
local EconomyDataStore = DataStoreService:GetDataStore("ObbyEconomy")
local ShopDataStore = DataStoreService:GetDataStore("ObbyShop")

local EconomySystem = {}

-- Estado de la economía
local PlayerEconomy = {}
local ShopItems = {}
local TransactionHistory = {}

-- Tipos de moneda
local CurrencyTypes = {
    COINS = "coins",
    GEMS = "gems",
    TOKENS = "tokens"
}

-- Tipos de transacción
local TransactionTypes = {
    EARNED = "earned",
    SPENT = "spent",
    REFUNDED = "refunded",
    GIFTED = "gifted",
    PURCHASED = "purchased"
}

-- Categorías de items de la tienda
local ShopCategories = {
    CHARACTERS = "characters",
    EFFECTS = "effects",
    BOOSTS = "boosts",
    COSMETICS = "cosmetics",
    POWERUPS = "powerups"
}

-- Función para inicializar el sistema de economía
function EconomySystem.Initialize()
    print("Inicializando sistema de economía...")
    
    -- Cargar items de la tienda
    EconomySystem.LoadShopItems()
    
    -- Configurar eventos de jugadores
    Players.PlayerAdded:Connect(EconomySystem.OnPlayerAdded)
    Players.PlayerRemoving:Connect(EconomySystem.OnPlayerRemoving)
    
    print("Sistema de economía inicializado correctamente")
end

-- Función para cargar items de la tienda
function EconomySystem.LoadShopItems()
    local success, shopData = pcall(function()
        return ShopDataStore:GetAsync("ShopItems")
    end)
    
    if success and shopData then
        ShopItems = shopData
    else
        -- Crear items por defecto
        EconomySystem.CreateDefaultShopItems()
    end
end

-- Función para crear items por defecto de la tienda
function EconomySystem.CreateDefaultShopItems()
    ShopItems = {
        -- Personajes
        {
            Id = "character_speedster",
            Name = "Speedster",
            Description = "Personaje con velocidad aumentada",
            Category = ShopCategories.CHARACTERS,
            Price = { coins = 500, gems = 0 },
            Rarity = "common",
            ImageId = "rbxassetid://123456",
            Available = true
        },
        {
            Id = "character_jumper",
            Name = "Jumper",
            Description = "Personaje con salto mejorado",
            Category = ShopCategories.CHARACTERS,
            Price = { coins = 750, gems = 0 },
            Rarity = "common",
            ImageId = "rbxassetid://123457",
            Available = true
        },
        {
            Id = "character_shield",
            Name = "Shield",
            Description = "Personaje con escudo protector",
            Category = ShopCategories.CHARACTERS,
            Price = { coins = 1000, gems = 5 },
            Rarity = "rare",
            ImageId = "rbxassetid://123458",
            Available = true
        },
        
        -- Efectos
        {
            Id = "effect_trail",
            Name = "Trail Dorado",
            Description = "Deja un rastro dorado al moverse",
            Category = ShopCategories.EFFECTS,
            Price = { coins = 200, gems = 0 },
            Rarity = "common",
            ImageId = "rbxassetid://123459",
            Available = true
        },
        {
            Id = "effect_particles",
            Name = "Partículas Mágicas",
            Description = "Partículas especiales al moverse",
            Category = ShopCategories.EFFECTS,
            Price = { coins = 300, gems = 1 },
            Rarity = "uncommon",
            ImageId = "rbxassetid://123460",
            Available = true
        },
        {
            Id = "effect_rainbow",
            Name = "Efecto Arcoíris",
            Description = "Efecto arcoíris completo",
            Category = ShopCategories.EFFECTS,
            Price = { coins = 500, gems = 3 },
            Rarity = "rare",
            ImageId = "rbxassetid://123461",
            Available = true
        },
        
        -- Boosts
        {
            Id = "boost_speed_1h",
            Name = "Boost de Velocidad (1h)",
            Description = "Aumenta la velocidad por 1 hora",
            Category = ShopCategories.BOOSTS,
            Price = { coins = 100, gems = 0 },
            Rarity = "common",
            ImageId = "rbxassetid://123462",
            Available = true,
            Duration = 3600 -- 1 hora
        },
        {
            Id = "boost_jump_1h",
            Name = "Boost de Salto (1h)",
            Description = "Aumenta el salto por 1 hora",
            Category = ShopCategories.BOOSTS,
            Price = { coins = 100, gems = 0 },
            Rarity = "common",
            ImageId = "rbxassetid://123463",
            Available = true,
            Duration = 3600
        },
        {
            Id = "boost_all_1h",
            Name = "Boost Completo (1h)",
            Description = "Aumenta velocidad y salto por 1 hora",
            Category = ShopCategories.BOOSTS,
            Price = { coins = 200, gems = 1 },
            Rarity = "uncommon",
            ImageId = "rbxassetid://123464",
            Available = true,
            Duration = 3600
        },
        
        -- Cosméticos
        {
            Id = "cosmetic_crown",
            Name = "Corona Real",
            Description = "Corona dorada para el personaje",
            Category = ShopCategories.COSMETICS,
            Price = { coins = 1000, gems = 10 },
            Rarity = "epic",
            ImageId = "rbxassetid://123465",
            Available = true
        },
        {
            Id = "cosmetic_wings",
            Name = "Alas Mágicas",
            Description = "Alas que flotan detrás del personaje",
            Category = ShopCategories.COSMETICS,
            Price = { coins = 1500, gems = 15 },
            Rarity = "epic",
            ImageId = "rbxassetid://123466",
            Available = true
        },
        {
            Id = "cosmetic_halo",
            Name = "Halo Divino",
            Description = "Halo flotante sobre la cabeza",
            Category = ShopCategories.COSMETICS,
            Price = { coins = 2000, gems = 20 },
            Rarity = "legendary",
            ImageId = "rbxassetid://123467",
            Available = true
        },
        
        -- Power-ups
        {
            Id = "powerup_double_jump",
            Name = "Doble Salto",
            Description = "Permite saltar dos veces",
            Category = ShopCategories.POWERUPS,
            Price = { coins = 500, gems = 5 },
            Rarity = "rare",
            ImageId = "rbxassetid://123468",
            Available = true
        },
        {
            Id = "powerup_teleport",
            Name = "Teletransporte",
            Description = "Teletransporte corto",
            Category = ShopCategories.POWERUPS,
            Price = { coins = 750, gems = 8 },
            Rarity = "rare",
            ImageId = "rbxassetid://123469",
            Available = true
        },
        {
            Id = "powerup_shield",
            Name = "Escudo Protector",
            Description = "Escudo que protege de una muerte",
            Category = ShopCategories.POWERUPS,
            Price = { coins = 1000, gems = 10 },
            Rarity = "epic",
            ImageId = "rbxassetid://123470",
            Available = true
        }
    }
    
    -- Guardar items por defecto
    EconomySystem.SaveShopItems()
end

-- Función para guardar items de la tienda
function EconomySystem.SaveShopItems()
    local success, error = pcall(function()
        ShopDataStore:SetAsync("ShopItems", ShopItems)
    end)
    
    if success then
        print("Items de la tienda guardados correctamente")
    else
        warn("Error al guardar items de la tienda:", error)
    end
end

-- Función para cuando un jugador se une
function EconomySystem.OnPlayerAdded(player)
    local userId = player.UserId
    
    -- Cargar economía del jugador
    local success, playerData = pcall(function()
        return EconomyDataStore:GetAsync("Player_" .. userId)
    end)
    
    if success and playerData then
        PlayerEconomy[userId] = playerData
    else
        -- Crear economía por defecto
        PlayerEconomy[userId] = {
            Coins = GameConstants.ECONOMY.STARTING_COINS,
            Gems = GameConstants.ECONOMY.STARTING_GEMS,
            Tokens = GameConstants.ECONOMY.STARTING_TOKENS,
            Inventory = {},
            PurchasedItems = {},
            TransactionHistory = {},
            LastUpdated = os.time()
        }
    end
    
    print("Economía cargada para " .. player.Name)
end

-- Función para cuando un jugador se va
function EconomySystem.OnPlayerRemoving(player)
    local userId = player.UserId
    
    -- Guardar economía del jugador
    if PlayerEconomy[userId] then
        PlayerEconomy[userId].LastUpdated = os.time()
        
        local success, error = pcall(function()
            EconomyDataStore:SetAsync("Player_" .. userId, PlayerEconomy[userId])
        end)
        
        if success then
            print("Economía guardada para " .. player.Name)
        else
            warn("Error al guardar economía para " .. player.Name .. ":", error)
        end
        
        PlayerEconomy[userId] = nil
    end
end

-- Función para dar monedas a un jugador
function EconomySystem.GiveCurrency(player, currencyType, amount, reason)
    local userId = player.UserId
    
    if not PlayerEconomy[userId] then
        warn("Jugador no encontrado en economía:", player.Name)
        return false
    end
    
    if currencyType == CurrencyTypes.COINS then
        PlayerEconomy[userId].Coins = PlayerEconomy[userId].Coins + amount
    elseif currencyType == CurrencyTypes.GEMS then
        PlayerEconomy[userId].Gems = PlayerEconomy[userId].Gems + amount
    elseif currencyType == CurrencyTypes.TOKENS then
        PlayerEconomy[userId].Tokens = PlayerEconomy[userId].Tokens + amount
    else
        warn("Tipo de moneda no válido:", currencyType)
        return false
    end
    
    -- Registrar transacción
    EconomySystem.RecordTransaction(userId, currencyType, amount, TransactionTypes.EARNED, reason)
    
    print("Dados " .. amount .. " " .. currencyType .. " a " .. player.Name .. " por: " .. reason)
    return true
end

-- Función para quitar monedas a un jugador
function EconomySystem.TakeCurrency(player, currencyType, amount, reason)
    local userId = player.UserId
    
    if not PlayerEconomy[userId] then
        warn("Jugador no encontrado en economía:", player.Name)
        return false
    end
    
    local currentAmount = 0
    if currencyType == CurrencyTypes.COINS then
        currentAmount = PlayerEconomy[userId].Coins
    elseif currencyType == CurrencyTypes.GEMS then
        currentAmount = PlayerEconomy[userId].Gems
    elseif currencyType == CurrencyTypes.TOKENS then
        currentAmount = PlayerEconomy[userId].Tokens
    end
    
    if currentAmount < amount then
        warn("Fondos insuficientes para " .. player.Name .. ":", currentAmount, "<", amount)
        return false
    end
    
    if currencyType == CurrencyTypes.COINS then
        PlayerEconomy[userId].Coins = PlayerEconomy[userId].Coins - amount
    elseif currencyType == CurrencyTypes.GEMS then
        PlayerEconomy[userId].Gems = PlayerEconomy[userId].Gems - amount
    elseif currencyType == CurrencyTypes.TOKENS then
        PlayerEconomy[userId].Tokens = PlayerEconomy[userId].Tokens - amount
    end
    
    -- Registrar transacción
    EconomySystem.RecordTransaction(userId, currencyType, -amount, TransactionTypes.SPENT, reason)
    
    print("Quitados " .. amount .. " " .. currencyType .. " a " .. player.Name .. " por: " .. reason)
    return true
end

-- Función para registrar transacción
function EconomySystem.RecordTransaction(userId, currencyType, amount, transactionType, reason)
    local transaction = {
        Timestamp = os.time(),
        CurrencyType = currencyType,
        Amount = amount,
        Type = transactionType,
        Reason = reason
    }
    
    if not PlayerEconomy[userId].TransactionHistory then
        PlayerEconomy[userId].TransactionHistory = {}
    end
    
    table.insert(PlayerEconomy[userId].TransactionHistory, transaction)
    
    -- Mantener solo las últimas 100 transacciones
    if #PlayerEconomy[userId].TransactionHistory > 100 then
        table.remove(PlayerEconomy[userId].TransactionHistory, 1)
    end
end

-- Función para comprar item
function EconomySystem.PurchaseItem(player, itemId)
    local userId = player.UserId
    
    if not PlayerEconomy[userId] then
        return { success = false, message = "Jugador no encontrado" }
    end
    
    -- Buscar item en la tienda
    local item = nil
    for _, shopItem in ipairs(ShopItems) do
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
    
    -- Verificar si el jugador ya tiene el item
    if PlayerEconomy[userId].PurchasedItems[itemId] then
        return { success = false, message = "Ya tienes este item" }
    end
    
    -- Verificar fondos
    local canAfford = true
    local missingCurrency = {}
    
    for currencyType, price in pairs(item.Price) do
        local currentAmount = 0
        if currencyType == CurrencyTypes.COINS then
            currentAmount = PlayerEconomy[userId].Coins
        elseif currencyType == CurrencyTypes.GEMS then
            currentAmount = PlayerEconomy[userId].Gems
        elseif currencyType == CurrencyTypes.TOKENS then
            currentAmount = PlayerEconomy[userId].Tokens
        end
        
        if currentAmount < price then
            canAfford = false
            table.insert(missingCurrency, { type = currencyType, needed = price, has = currentAmount })
        end
    end
    
    if not canAfford then
        return { success = false, message = "Fondos insuficientes", missing = missingCurrency }
    end
    
    -- Realizar compra
    for currencyType, price in pairs(item.Price) do
        EconomySystem.TakeCurrency(player, currencyType, price, "Compra: " .. item.Name)
    end
    
    -- Agregar item al inventario
    PlayerEconomy[userId].PurchasedItems[itemId] = {
        PurchaseDate = os.time(),
        ItemData = item
    }
    
    -- Agregar al inventario si es un item de inventario
    if item.Category == ShopCategories.CHARACTERS or 
       item.Category == ShopCategories.EFFECTS or 
       item.Category == ShopCategories.COSMETICS then
        if not PlayerEconomy[userId].Inventory then
            PlayerEconomy[userId].Inventory = {}
        end
        PlayerEconomy[userId].Inventory[itemId] = item
    end
    
    print("Item comprado por " .. player.Name .. ": " .. item.Name)
    return { success = true, message = "Compra exitosa", item = item }
end

-- Función para obtener economía de un jugador
function EconomySystem.GetPlayerEconomy(userId)
    return PlayerEconomy[userId]
end

-- Función para obtener items de la tienda
function EconomySystem.GetShopItems(category)
    if category then
        local filteredItems = {}
        for _, item in ipairs(ShopItems) do
            if item.Category == category then
                table.insert(filteredItems, item)
            end
        end
        return filteredItems
    end
    return ShopItems
end

-- Función para obtener inventario de un jugador
function EconomySystem.GetPlayerInventory(userId)
    if PlayerEconomy[userId] then
        return PlayerEconomy[userId].Inventory or {}
    end
    return {}
end

-- Función para obtener historial de transacciones
function EconomySystem.GetTransactionHistory(userId, limit)
    limit = limit or 20
    
    if PlayerEconomy[userId] and PlayerEconomy[userId].TransactionHistory then
        local history = PlayerEconomy[userId].TransactionHistory
        local recentHistory = {}
        
        for i = #history, math.max(1, #history - limit + 1), -1 do
            table.insert(recentHistory, history[i])
        end
        
        return recentHistory
    end
    
    return {}
end

-- Función para dar recompensa por completar nivel
function EconomySystem.GiveLevelReward(player, levelNumber, time, deaths)
    local baseCoins = GameConstants.ECONOMY.BASE_LEVEL_REWARD
    local timeBonus = math.max(0, 300 - time) * 2 -- Bonus por tiempo rápido
    local deathPenalty = deaths * 5 -- Penalización por muertes
    
    local totalCoins = baseCoins + timeBonus - deathPenalty
    totalCoins = math.max(totalCoins, GameConstants.ECONOMY.MIN_LEVEL_REWARD)
    
    -- Dar monedas
    EconomySystem.GiveCurrency(player, CurrencyTypes.COINS, totalCoins, "Completar nivel " .. levelNumber)
    
    -- Dar gemas si es un nivel especial
    if levelNumber % 5 == 0 then
        EconomySystem.GiveCurrency(player, CurrencyTypes.GEMS, 1, "Nivel especial " .. levelNumber)
    end
    
    return {
        coins = totalCoins,
        gems = levelNumber % 5 == 0 and 1 or 0,
        timeBonus = timeBonus,
        deathPenalty = deathPenalty
    }
end

-- Función para dar recompensa diaria
function EconomySystem.GiveDailyReward(player)
    local userId = player.UserId
    
    if not PlayerEconomy[userId] then
        return { success = false, message = "Jugador no encontrado" }
    end
    
    local today = os.date("%Y-%m-%d")
    local lastReward = PlayerEconomy[userId].LastDailyReward
    
    if lastReward == today then
        return { success = false, message = "Ya reclamaste la recompensa de hoy" }
    end
    
    -- Dar recompensa
    local coins = math.random(50, 150)
    local gems = math.random(1, 3)
    
    EconomySystem.GiveCurrency(player, CurrencyTypes.COINS, coins, "Recompensa diaria")
    EconomySystem.GiveCurrency(player, CurrencyTypes.GEMS, gems, "Recompensa diaria")
    
    PlayerEconomy[userId].LastDailyReward = today
    
    return {
        success = true,
        coins = coins,
        gems = gems
    }
end

-- Función para verificar si un jugador puede comprar un item
function EconomySystem.CanPlayerAfford(userId, itemId)
    if not PlayerEconomy[userId] then
        return false
    end
    
    local item = nil
    for _, shopItem in ipairs(ShopItems) do
        if shopItem.Id == itemId then
            item = shopItem
            break
        end
    end
    
    if not item then
        return false
    end
    
    for currencyType, price in pairs(item.Price) do
        local currentAmount = 0
        if currencyType == CurrencyTypes.COINS then
            currentAmount = PlayerEconomy[userId].Coins
        elseif currencyType == CurrencyTypes.GEMS then
            currentAmount = PlayerEconomy[userId].Gems
        elseif currencyType == CurrencyTypes.TOKENS then
            currentAmount = PlayerEconomy[userId].Tokens
        end
        
        if currentAmount < price then
            return false
        end
    end
    
    return true
end

-- Función para obtener estadísticas de economía
function EconomySystem.GetEconomyStats()
    local stats = {
        TotalPlayers = 0,
        TotalCoins = 0,
        TotalGems = 0,
        TotalTokens = 0,
        AverageCoins = 0,
        AverageGems = 0,
        AverageTokens = 0
    }
    
    for userId, economy in pairs(PlayerEconomy) do
        stats.TotalPlayers = stats.TotalPlayers + 1
        stats.TotalCoins = stats.TotalCoins + economy.Coins
        stats.TotalGems = stats.TotalGems + economy.Gems
        stats.TotalTokens = stats.TotalTokens + economy.Tokens
    end
    
    if stats.TotalPlayers > 0 then
        stats.AverageCoins = stats.TotalCoins / stats.TotalPlayers
        stats.AverageGems = stats.TotalGems / stats.TotalPlayers
        stats.AverageTokens = stats.TotalTokens / stats.TotalPlayers
    end
    
    return stats
end

-- Inicializar sistema
EconomySystem.Initialize()

return EconomySystem 