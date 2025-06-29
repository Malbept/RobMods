-- @description Grow a Garden Telegram Notifier with Visuals and Russian Translation
-- @author Grok (based on user request)

-- Услуги Roblox
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- Конфигурация
local Config = {
    TelegramBotToken = "8101289751:AAEk6wpg5UkUBY8S5dSRLcTI0M8TJIZssc4",
    TelegramChatId = "5678878569",
    ReportingEnabled = true,
    ReportInterval = 300, -- Отправка каждые 5 минут
    AntiAFK = true,
    RenderingEnabled = false, -- Отключение рендеринга для оптимизации
    RussianTranslation = true, -- Перевод меню на русский
    ShowPriceVisuals = true, -- Показ цен над растениями
    ShowSkins = true, -- Показ скинов (SpongeBob и др.)
}

-- Услуги для GUI
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GardenNotifierGui"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Создание GUI
local function CreateGui()
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 400)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Frame.BackgroundTransparency = 0.3
    Frame.Parent = ScreenGui

    -- Кнопка закрытия
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.Text = "X"
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.Parent = Frame
    CloseButton.MouseButton1Click:Connect(function()
        Frame.Visible = false
    end)

    -- Кнопка скрытия/показа
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 100, 0, 30)
    ToggleButton.Position = UDim2.new(0, 5, 0, 5)
    ToggleButton.Text = "Скрыть/Показать"
    ToggleButton.Parent = Frame
    ToggleButton.MouseButton1Click:Connect(function()
        Frame.Visible = not Frame.Visible
    end)

    -- Перемещение GUI
    local dragging, dragInput, dragStart, startPos
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Информационные разделы
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -10, 1, -40)
    InfoLabel.Position = UDim2.new(0, 5, 0, 40)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    InfoLabel.TextWrapped = true
    InfoLabel.Text = "Загрузка данных..."
    InfoLabel.Parent = Frame

    return InfoLabel
end

local InfoLabel = _

-- Функция отправки в Telegram
local function SendTelegramMessage(message)
    if not Config.ReportingEnabled then return end
    local url = "https://api.telegram.org/bot" .. Config.TelegramBotToken .. "/sendMessage"
    local payload = {
        chat_id = Config.TelegramChatId,
        text = message,
        parse_mode = "Markdown"
    }
    local success, response = pcall(function()
        return HttpService:PostAsync(url, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("Ошибка Telegram: " .. tostring(response))
    end
end

-- Анти-AFK
if Config.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- Отключение рендеринга
RunService:Set3dRenderingEnabled(Config.RenderingEnabled)

-- Получение данных аккаунта
local function GetPlayerData()
    local player = Players.LocalPlayer
    local currency = player.leaderstats and player.leaderstats.Coins and player.leaderstats.Coins.Value or "Неизвестно"
    local inventory = "Неизвестно"
    -- Пример: получение инвентаря (нужно уточнить путь)
    -- local inventoryItems = player.PlayerGui.Inventory.Seeds:GetChildren()
    -- for _, item in ipairs(inventoryItems) do
    --     inventory = inventory .. item.Name .. ", "
    -- end
    return string.format("*Аккаунт*: %s\n*Валюта*: %s Sheckles\n*Инвентарь*: %s", player.Name, currency, inventory)
end

-- Получение данных сервера
local function GetServerData()
    local weather = ReplicatedStorage.GameEvents.WeatherEventStarted and ReplicatedStorage.GameEvents.WeatherEventStarted.Value or "Неизвестно"
    local shopData = "Неизвестно"
    -- Пример: получение данных магазинов
    -- local shops = ReplicatedStorage.GameEvents.DataStream.ShopData:GetChildren()
    -- for _, shop in ipairs(shops) do
    --     shopData = shopData .. shop.Name .. ": " .. shop.Value .. "\n"
    -- end
    return string.format("*Сервер*:\n*Погода*: %s\n*Магазины*:\n%s", weather, shopData)
end

-- Информация о питомцах
local function GetPetsInfo()
    local petsInfo = "*Питомцы*:\n"
    local pets = {
        {Name = "Raccoon", Effect = "+10% к скорости роста"},
        {Name = "Dragonfly", Effect = "+5% к шансу мутаций"},
        {Name = "Bee", Effect = "+15% к доходу"},
        {Name = "Ladybug", Effect = "-20% к времени полива"},
        {Name = "Lunar Bunny", Effect = "Уникальная мутация Dawnbound"},
        {Name = "Phoenix", Effect = "+25% к доходу и редкие мутации"}
    }
    for _, pet in ipairs(pets) do
        petsInfo = petsInfo .. string.format("- %s: %s\n", pet.Name, pet.Effect)
    end
    return petsInfo
end

-- Информация о предметах
local function GetItemsInfo()
    local itemsInfo = "*Предметы*:\n"
    local items = {
        {Name = "Carrot Seed", Effect = "Базовое растение, 10 Sheckles"},
        {Name = "Golden Watering Can", Effect = "+10% к шансу мутаций"},
        {Name = "Lunar Sprinkler", Effect = "Дает мутацию Voidtouched"},
        {Name = "SpongeBob Skin", Effect = "Косметический скин"}
    }
    for _, item in ipairs(items) do
        itemsInfo = itemsInfo .. string.format("- %s: %s\n", item.Name, item.Effect)
    end
    return itemsInfo
end

-- Информация о мутациях
local function GetMutationsInfo()
    local mutationsInfo = "*Мутации*:\n"
    local mutations = {
        {Name = "Disco", Effect = "+50% к стоимости, через Disco Sprinkler"},
        {Name = "Frozen", Effect = "+75% к стоимости, во время снега"},
        {Name = "Waterlogged", Effect = "+100% к стоимости, во время дождя"},
        {Name = "Starbound", Effect = "+150% к стоимости, через Star Sprinkler"},
        {Name = "Dawnbound", Effect = "+500% к стоимости, только Sunflower"},
        {Name = "Voidtouched", Effect = "+300% к стоимости, редкое событие"},
        {Name = "Ripe", Effect = "+200% к стоимости, только Sugar Apple"}
    }
    for _, mutation in ipairs(mutations) do
        mutationsInfo = mutationsInfo .. string.format("- %s: %s\n", mutation.Name, mutation.Effect)
    end
    return mutationsInfo
end

-- Визуалы: цены над растениями
local function UpdatePlantPriceVisuals()
    if not Config.ShowPriceVisuals then return end
    -- Пример: получение растений на участке игрока
    local plants = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild(Player.Name) and workspace.Plots[Player.Name]:GetChildren() or {}
    for _, plant in ipairs(plants) do
        if plant:IsA("Model") and plant:FindFirstChild("BasePart") then
            local price = 20 -- Базовая цена (например, для помидора)
            local mutations = {} -- Нужно получить мутации растения
            -- Пример: проверка мутаций
            -- if plant.Mutations:FindFirstChild("Disco") then price = price * 1.5 end
            -- if plant.Mutations:FindFirstChild("Frozen") then price = price * 1.75 end
            local billboard = plant.BasePart:FindFirstChild("PriceBillboard") or Instance.new("BillboardGui")
            billboard.Name = "PriceBillboard"
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.Parent = plant.BasePart

            local priceLabel = billboard:FindFirstChild("PriceLabel") or Instance.new("TextLabel")
            priceLabel.Name = "PriceLabel"
            priceLabel.Size = UDim2.new(1, 0, 1, 0)
            priceLabel.BackgroundTransparency = 1
            priceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            priceLabel.Text = plant.Name .. "\nЦена: " .. price .. " Sheckles"
            priceLabel.Parent = billboard
        end
    end
end

-- Визуалы: отображение скинов
local function ShowSkins()
    if not Config.ShowSkins then return end
    local skins = {
        "SpongeBob Skin",
        "Patrick Skin",
        "Squidward Skin"
    }
    local skinsInfo = "*Скины*:\n"
    for _, skin in ipairs(skins) do
        skinsInfo = skinsInfo .. string.format("- %s\n", skin)
    end
    SendTelegramMessage(skinsInfo)
    -- Пример: отображение скинов в GUI
    InfoLabel.Text = InfoLabel.Text .. "\n" .. skinsInfo
end

-- Перевод меню на русский
local function TranslateMenus()
    if not Config.RussianTranslation then return end
    local guiElements = PlayerGui:GetDescendants()
    local translations = {
        ["Plant"] = "Посадить",
        ["Water"] = "Полить",
        ["Harvest"] = "Собрать",
        ["Inventory"] = "Инвентарь",
        ["Shop"] = "Магазин",
        ["Coins"] = "Шекли",
        ["Seeds"] = "Семена",
        ["Tools"] = "Инструменты"
    }
    for _, element in ipairs(guiElements) do
        if element:IsA("TextLabel") or element:IsA("TextButton") then
            for eng, rus in pairs(translations) do
                if element.Text:find(eng) then
                    element.Text = element.Text:gsub(eng, rus)
                end
            end
        end
    end
end

-- Основной цикл
spawn(function()
    while Config.ReportingEnabled do
        local message = "=== Уведомление Grow a Garden ===\n"
        message = message .. GetPlayerData() .. "\n"
        message = message .. GetServerData() .. "\n"
        message = message .. GetPetsInfo() .. "\n"
        message = message .. GetItemsInfo() .. "\n"
        message = message .. GetMutationsInfo() .. "\n"
        SendTelegramMessage(message)
        UpdatePlantPriceVisuals()
        ShowSkins()
        TranslateMenus()
        InfoLabel.Text = message:gsub("*", "") -- Обновление GUI
        wait(Config.ReportInterval)
    end
end)

-- Инициализация GUI
InfoLabel = CreateGui()
