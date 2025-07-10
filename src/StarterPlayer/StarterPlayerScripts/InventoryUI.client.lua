-- InventoryUI.client.lua
-- Interfaz de usuario del inventario para el juego Obby de las Dimensiones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Módulos compartidos
local GameConstants = require(ReplicatedStorage.SharedModules.GameConstants)

-- Eventos remotos
local RankingEvents = ReplicatedStorage:WaitForChild("RankingEvents")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local InventoryUI = {}

-- Referencias de la UI
local InventoryGui = nil
local CurrentCategory = "all"
local PlayerInventory = {}
local EquippedItems = {}

-- Categorías del inventario
local InventoryCategories = {
    { id = "all", name = "TODOS", icon = "📦" },
    { id = "characters", name = "PERSONAJES", icon = "👤" },
    { id = "effects", name = "EFECTOS", icon = "✨" },
    { id = "cosmetics", name = "COSMÉTICOS", icon = "👑" }
}

-- Función para crear la UI del inventario
function InventoryUI.CreateInventoryUI()
    if InventoryGui then
        InventoryGui:Destroy()
    end
    
    InventoryGui = Instance.new("ScreenGui")
    InventoryGui.Name = "InventoryUI"
    InventoryGui.Parent = playerGui
    
    -- Fondo principal
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.3
    background.Parent = InventoryGui
    
    -- Panel principal
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(0, 1200, 0, 800)
    mainPanel.Position = UDim2.new(0.5, -600, 0.5, -400)
    mainPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainPanel.BorderSizePixel = 0
    mainPanel.Parent = background
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
    title.Text = "INVENTARIO"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainPanel
    
    -- Panel izquierdo - Categorías
    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.Size = UDim2.new(0, 200, 1, -80)
    leftPanel.Position = UDim2.new(0, 20, 0, 80)
    leftPanel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = mainPanel
    
    -- Título de categorías
    local categoriesTitle = Instance.new("TextLabel")
    categoriesTitle.Name = "CategoriesTitle"
    categoriesTitle.Size = UDim2.new(1, 0, 0, 40)
    categoriesTitle.Position = UDim2.new(0, 0, 0, 0)
    categoriesTitle.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
    categoriesTitle.Text = "CATEGORÍAS"
    categoriesTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    categoriesTitle.TextScaled = true
    categoriesTitle.Font = Enum.Font.GothamBold
    categoriesTitle.Parent = leftPanel
    
    -- Lista de categorías
    local categoriesList = Instance.new("Frame")
    categoriesList.Name = "CategoriesList"
    categoriesList.Size = UDim2.new(1, 0, 1, -50)
    categoriesList.Position = UDim2.new(0, 0, 0, 50)
    categoriesList.BackgroundTransparency = 1
    categoriesList.Parent = leftPanel
    
    -- Crear botones de categoría
    for i, category in ipairs(InventoryCategories) do
        local categoryButton = Instance.new("TextButton")
        categoryButton.Name = category.id .. "Button"
        categoryButton.Size = UDim2.new(1, -20, 0, 40)
        categoryButton.Position = UDim2.new(0, 10, 0, (i-1) * 50 + 10)
        categoryButton.BackgroundColor3 = i == 1 and GameConstants.UI.PRIMARY_COLOR or GameConstants.UI.SECONDARY_COLOR
        categoryButton.Text = category.icon .. " " .. category.name
        categoryButton.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
        categoryButton.TextScaled = true
        categoryButton.Font = Enum.Font.GothamBold
        categoryButton.Parent = categoriesList
        
        categoryButton.MouseButton1Click:Connect(function()
            InventoryUI.SwitchCategory(category.id)
        end)
    end
    
    -- Panel central - Items del inventario
    local centerPanel = Instance.new("Frame")
    centerPanel.Name = "CenterPanel"
    centerPanel.Size = UDim2.new(0, 400, 1, -80)
    centerPanel.Position = UDim2.new(0, 240, 0, 80)
    centerPanel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    centerPanel.BorderSizePixel = 0
    centerPanel.Parent = mainPanel
    
    -- Título del inventario
    local inventoryTitle = Instance.new("TextLabel")
    inventoryTitle.Name = "InventoryTitle"
    inventoryTitle.Size = UDim2.new(1, 0, 0, 40)
    inventoryTitle.Position = UDim2.new(0, 0, 0, 0)
    inventoryTitle.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
    inventoryTitle.Text = "MI INVENTARIO"
    inventoryTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    inventoryTitle.TextScaled = true
    inventoryTitle.Font = Enum.Font.GothamBold
    inventoryTitle.Parent = centerPanel
    
    -- ScrollFrame para items del inventario
    local inventoryScroll = Instance.new("ScrollingFrame")
    inventoryScroll.Name = "InventoryScroll"
    inventoryScroll.Size = UDim2.new(1, 0, 1, -50)
    inventoryScroll.Position = UDim2.new(0, 0, 0, 50)
    inventoryScroll.BackgroundTransparency = 1
    inventoryScroll.ScrollBarThickness = 6
    inventoryScroll.Parent = centerPanel
    
    -- Grid de items del inventario
    local inventoryGrid = Instance.new("UIGridLayout")
    inventoryGrid.Name = "InventoryGrid"
    inventoryGrid.CellSize = UDim2.new(0, 180, 0, 200)
    inventoryGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    inventoryGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    inventoryGrid.Parent = inventoryScroll
    
    -- Panel derecho - Vista previa y equipamiento
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(0, 520, 1, -80)
    rightPanel.Position = UDim2.new(0, 660, 0, 80)
    rightPanel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = mainPanel
    
    -- Título de vista previa
    local previewTitle = Instance.new("TextLabel")
    previewTitle.Name = "PreviewTitle"
    previewTitle.Size = UDim2.new(1, 0, 0, 40)
    previewTitle.Position = UDim2.new(0, 0, 0, 0)
    previewTitle.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
    previewTitle.Text = "VISTA PREVIA"
    previewTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    previewTitle.TextScaled = true
    previewTitle.Font = Enum.Font.GothamBold
    previewTitle.Parent = rightPanel
    
    -- Panel de vista previa
    local previewPanel = Instance.new("Frame")
    previewPanel.Name = "PreviewPanel"
    previewPanel.Size = UDim2.new(1, -20, 0, 300)
    previewPanel.Position = UDim2.new(0, 10, 0, 50)
    previewPanel.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    previewPanel.BorderSizePixel = 0
    previewPanel.Parent = rightPanel
    
    -- Imagen de vista previa
    local previewImage = Instance.new("ImageLabel")
    previewImage.Name = "PreviewImage"
    previewImage.Size = UDim2.new(1, -20, 1, -20)
    previewImage.Position = UDim2.new(0, 10, 0, 10)
    previewImage.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    previewImage.Image = "rbxassetid://0"
    previewImage.Parent = previewPanel
    
    -- Información del item
    local itemInfoPanel = Instance.new("Frame")
    itemInfoPanel.Name = "ItemInfoPanel"
    itemInfoPanel.Size = UDim2.new(1, -20, 0, 200)
    itemInfoPanel.Position = UDim2.new(0, 10, 0, 370)
    itemInfoPanel.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    itemInfoPanel.BorderSizePixel = 0
    itemInfoPanel.Parent = rightPanel
    
    -- Nombre del item
    local itemName = Instance.new("TextLabel")
    itemName.Name = "ItemName"
    itemName.Size = UDim2.new(1, -20, 0, 30)
    itemName.Position = UDim2.new(0, 10, 0, 10)
    itemName.BackgroundTransparency = 1
    itemName.Text = "Selecciona un item"
    itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
    itemName.TextScaled = true
    itemName.Font = Enum.Font.GothamBold
    itemName.Parent = itemInfoPanel
    
    -- Descripción del item
    local itemDescription = Instance.new("TextLabel")
    itemDescription.Name = "ItemDescription"
    itemDescription.Size = UDim2.new(1, -20, 0, 60)
    itemDescription.Position = UDim2.new(0, 10, 0, 50)
    itemDescription.BackgroundTransparency = 1
    itemDescription.Text = ""
    itemDescription.TextColor3 = Color3.fromRGB(200, 200, 200)
    itemDescription.TextScaled = true
    itemDescription.Font = Enum.Font.Gotham
    itemDescription.Parent = itemInfoPanel
    
    -- Botón de equipar
    local equipButton = Instance.new("TextButton")
    equipButton.Name = "EquipButton"
    equipButton.Size = UDim2.new(0.5, -15, 0, 40)
    equipButton.Position = UDim2.new(0, 10, 0, 130)
    equipButton.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
    equipButton.Text = "EQUIPAR"
    equipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    equipButton.TextScaled = true
    equipButton.Font = Enum.Font.GothamBold
    equipButton.Parent = itemInfoPanel
    
    equipButton.MouseButton1Click:Connect(function()
        InventoryUI.EquipSelectedItem()
    end)
    
    -- Botón de desequipar
    local unequipButton = Instance.new("TextButton")
    unequipButton.Name = "UnequipButton"
    unequipButton.Size = UDim2.new(0.5, -15, 0, 40)
    unequipButton.Position = UDim2.new(0.5, 5, 0, 130)
    unequipButton.BackgroundColor3 = GameConstants.UI.ERROR_COLOR
    unequipButton.Text = "DESEQUIPAR"
    unequipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    unequipButton.TextScaled = true
    unequipButton.Font = Enum.Font.GothamBold
    unequipButton.Parent = itemInfoPanel
    
    unequipButton.MouseButton1Click:Connect(function()
        InventoryUI.UnequipSelectedItem()
    end)
    
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
        InventoryUI.HideInventory()
    end)
    
    -- Cargar inventario del jugador
    InventoryUI.LoadPlayerInventory()
    
    return InventoryGui
end

-- Función para cambiar categoría
function InventoryUI.SwitchCategory(categoryId)
    CurrentCategory = categoryId
    
    -- Actualizar colores de botones de categoría
    local categoriesList = InventoryGui.MainPanel.LeftPanel.CategoriesList
    for i, category in ipairs(InventoryCategories) do
        local button = categoriesList:FindFirstChild(category.id .. "Button")
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
    InventoryUI.DisplayInventoryItems()
end

-- Función para cargar inventario del jugador
function InventoryUI.LoadPlayerInventory()
    spawn(function()
        local success, inventory = pcall(function()
            return RankingEvents.GetPlayerInventory:InvokeServer()
        end)
        
        if success and inventory then
            PlayerInventory = inventory
            InventoryUI.DisplayInventoryItems()
        else
            print("Error al cargar inventario del jugador")
        end
    end)
end

-- Función para mostrar items del inventario
function InventoryUI.DisplayInventoryItems()
    local inventoryScroll = InventoryGui.MainPanel.CenterPanel.InventoryScroll
    
    -- Limpiar items existentes
    for _, child in pairs(inventoryScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Mostrar items
    local itemCount = 0
    for itemId, item in pairs(PlayerInventory) do
        -- Filtrar por categoría
        if CurrentCategory == "all" or item.Category == CurrentCategory then
            itemCount = itemCount + 1
            
            local itemFrame = Instance.new("Frame")
            itemFrame.Name = "ItemFrame_" .. itemCount
            itemFrame.Size = UDim2.new(0, 180, 0, 200)
            itemFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            itemFrame.BorderSizePixel = 0
            itemFrame.Parent = inventoryScroll
            
            -- Imagen del item
            local itemImage = Instance.new("ImageLabel")
            itemImage.Name = "ItemImage"
            itemImage.Size = UDim2.new(1, -10, 0, 100)
            itemImage.Position = UDim2.new(0, 5, 0, 5)
            itemImage.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            itemImage.Image = item.ImageId or "rbxassetid://0"
            itemImage.Parent = itemFrame
            
            -- Nombre del item
            local itemName = Instance.new("TextLabel")
            itemName.Name = "ItemName"
            itemName.Size = UDim2.new(1, -10, 0, 25)
            itemName.Position = UDim2.new(0, 5, 0, 110)
            itemName.BackgroundTransparency = 1
            itemName.Text = item.Name
            itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
            itemName.TextScaled = true
            itemName.Font = Enum.Font.GothamBold
            itemName.Parent = itemFrame
            
            -- Botón de seleccionar
            local selectButton = Instance.new("TextButton")
            selectButton.Name = "SelectButton"
            selectButton.Size = UDim2.new(1, -10, 0, 30)
            selectButton.Position = UDim2.new(0, 5, 0, 140)
            selectButton.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
            selectButton.Text = "SELECCIONAR"
            selectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            selectButton.TextScaled = true
            selectButton.Font = Enum.Font.GothamBold
            selectButton.Parent = itemFrame
            
            selectButton.MouseButton1Click:Connect(function()
                InventoryUI.SelectItem(itemId, item)
            end)
            
            -- Verificar si está equipado
            if EquippedItems[item.Category] == itemId then
                selectButton.Text = "EQUIPADO"
                selectButton.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
            end
        end
    end
    
    -- Ajustar tamaño del ScrollFrame
    inventoryScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(itemCount / 2) * 210)
end

-- Función para seleccionar item
function InventoryUI.SelectItem(itemId, item)
    -- Actualizar vista previa
    local previewImage = InventoryGui.MainPanel.RightPanel.PreviewPanel.PreviewImage
    local itemName = InventoryGui.MainPanel.RightPanel.ItemInfoPanel.ItemName
    local itemDescription = InventoryGui.MainPanel.RightPanel.ItemInfoPanel.ItemDescription
    local equipButton = InventoryGui.MainPanel.RightPanel.ItemInfoPanel.EquipButton
    local unequipButton = InventoryGui.MainPanel.RightPanel.ItemInfoPanel.UnequipButton
    
    previewImage.Image = item.ImageId or "rbxassetid://0"
    itemName.Text = item.Name
    itemDescription.Text = item.Description
    
    -- Configurar botones
    if EquippedItems[item.Category] == itemId then
        equipButton.Text = "EQUIPADO"
        equipButton.BackgroundColor3 = GameConstants.UI.SUCCESS_COLOR
        unequipButton.Text = "DESEQUIPAR"
        unequipButton.BackgroundColor3 = GameConstants.UI.ERROR_COLOR
    else
        equipButton.Text = "EQUIPAR"
        equipButton.BackgroundColor3 = GameConstants.UI.PRIMARY_COLOR
        unequipButton.Text = "DESEQUIPAR"
        unequipButton.BackgroundColor3 = GameConstants.UI.SECONDARY_COLOR
    end
    
    -- Guardar item seleccionado
    InventoryUI.SelectedItem = { id = itemId, data = item }
end

-- Función para equipar item seleccionado
function InventoryUI.EquipSelectedItem()
    if not InventoryUI.SelectedItem then
        return
    end
    
    local itemId = InventoryUI.SelectedItem.id
    local item = InventoryUI.SelectedItem.data
    
    -- Equipar item
    EquippedItems[item.Category] = itemId
    
    -- Notificar al servidor
    spawn(function()
        local success = pcall(function()
            return RankingEvents.EquipItem:InvokeServer(itemId)
        end)
        
        if success then
            InventoryUI.ShowEquipSuccess(item.Name)
            InventoryUI.DisplayInventoryItems() -- Actualizar botones
        else
            InventoryUI.ShowEquipError("Error al equipar el item")
        end
    end)
end

-- Función para desequipar item seleccionado
function InventoryUI.UnequipSelectedItem()
    if not InventoryUI.SelectedItem then
        return
    end
    
    local itemId = InventoryUI.SelectedItem.id
    local item = InventoryUI.SelectedItem.data
    
    -- Desequipar item
    EquippedItems[item.Category] = nil
    
    -- Notificar al servidor
    spawn(function()
        local success = pcall(function()
            return RankingEvents.UnequipItem:InvokeServer(itemId)
        end)
        
        if success then
            InventoryUI.ShowUnequipSuccess(item.Name)
            InventoryUI.DisplayInventoryItems() -- Actualizar botones
        else
            InventoryUI.ShowUnequipError("Error al desequipar el item")
        end
    end)
end

-- Función para mostrar éxito de equipamiento
function InventoryUI.ShowEquipSuccess(itemName)
    local notification = Instance.new("ScreenGui")
    notification.Name = "EquipSuccess"
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
    text.Text = "¡Item equipado!\n" .. itemName
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

-- Función para mostrar error de equipamiento
function InventoryUI.ShowEquipError(message)
    local notification = Instance.new("ScreenGui")
    notification.Name = "EquipError"
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

-- Función para mostrar éxito de desequipamiento
function InventoryUI.ShowUnequipSuccess(itemName)
    local notification = Instance.new("ScreenGui")
    notification.Name = "UnequipSuccess"
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
    text.Text = "¡Item desequipado!\n" .. itemName
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

-- Función para mostrar error de desequipamiento
function InventoryUI.ShowUnequipError(message)
    local notification = Instance.new("ScreenGui")
    notification.Name = "UnequipError"
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

-- Función para mostrar inventario
function InventoryUI.ShowInventory()
    if not InventoryGui then
        InventoryUI.CreateInventoryUI()
    else
        InventoryGui.Enabled = true
    end
    
    -- Cargar inventario del jugador
    InventoryUI.LoadPlayerInventory()
end

-- Función para ocultar inventario
function InventoryUI.HideInventory()
    if InventoryGui then
        InventoryGui.Enabled = false
    end
end

return InventoryUI 