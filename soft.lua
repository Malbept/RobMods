-- @description Grow a Garden Telegram Notifier (Creative GUI, Price Tooltip & Full Russian Translation)
-- @author Grok (based on user request)

-- Услуги Roblox
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

-- Конфигурация
local Config = {
    TelegramBotToken = "8101289751:AAEk6wpg5UkUBY8S5dSRLcTI0M8TJIZssc4",
    TelegramChatId = "5678878569",
    ReportingEnabled = true,
    ReportInterval = 900, -- Отправка каждые 15 минут
    AntiAFK = true,
    RussianTranslation = true,
    ShowPriceVisuals = true,
    ShowPriceTooltip = true, -- Новая функция: подсчёт цены при наведении
    VisualUpdateInterval = 10, -- Обновление визуалов каждые 10 секунд
}

-- Таблица мутаций
local Mutations = {
    ["Wet"] = {Name = "Мокрый", Multiplier = 2, Description = "Во время дождя или грозы"},
    ["Chilled"] = {Name = "Охлаждённый", Multiplier = 2, Description = "Во время заморозков или с Полярным медведем"},
    ["Chocolate"] = {Name = "Шоколадный", Multiplier = 2, Description = "Через Шоколадный разбрызгиватель (Пасха 2025)"},
    ["Moonlit"] = {Name = "Лунный", Multiplier = 2, Description = "Ночью, во время Лунного сияния"},
    ["Bloodlit"] = {Name = "Кровавый", Multiplier = 4, Description = "Во время Кровавой луны"},
    ["Plasma"] = {Name = "Плазменный", Multiplier = 5, Description = "Через админ-погоду с лазерами"},
    ["Frozen"] = {Name = "Замороженный", Multiplier = 10, Description = "Мокрый + Охлаждённый или Полярный медведь"},
    ["Golden"] = {Name = "Золотой", Multiplier = 20, Description = "1% шанс или через Стрекозу"},
    ["Zombified"] = {Name = "Зомбированный", Multiplier = 25, Description = "Через Зомби-курицу (20% каждые 30 мин)"},
    ["Twisted"] = {Name = "Искажённый", Multiplier = 30, Description = "Во время события Торнадо"},
    ["Rainbow"] = {Name = "Радужный", Multiplier = 50, Description = "0.1% шанс или за Robux"},
    ["Shocked"] = {Name = "Электрический", Multiplier = 100, Description = "Удар молнии или Светлячок (3.07% каждые 1.32 мин)"},
    ["Celestial"] = {Name = "Небесный", Multiplier = 120, Description = "Удар звезды во время Метеоритного дождя"},
    ["Disco"] = {Name = "Диско", Multiplier = 125, Description = "Диско-событие или Диско-пчела"},
    ["Solar"] = {Name = "Солнечный", Multiplier = 150, Description = "Золотое Затмение Обезьяны"},
    ["Eclipse"] = {Name = "Затмение", Multiplier = 80, Description = "Золотое Затмение Обезьяны"},
    ["Galactic"] = {Name = "Галактический", Multiplier = 4, Description = "Событие Космическое путешествие"},
    ["Pollinated"] = {Name = "Опылённый", Multiplier = 3, Description = "Через пчел при активном игроке"},
    ["HoneyGlazed"] = {Name = "Медовая глазурь", Multiplier = 5, Description = "Через Медведя-пчелу"},
    ["Sundried"] = {Name = "Высушенный солнцем", Multiplier = 1, Description = "Неизвестно (предположительно событие)"}
}

-- Таблица растений (базовые цены за кг)
local PlantPrices = {
    ["Carrot"] = 10,
    ["Tomato"] = 20,
    ["Sunflower"] = 50,
    ["Sugar Apple"] = 100,
    ["Blood Orange"] = 200,
    ["Moon Melon"] = 1000,
    ["Candy Blossom"] = 1000,
    ["Bamboo"] = 5000
}

-- Таблица питомцев
local Pets = {
    ["Bunny"] = {Rarity = "Обычный", Ability = "Ест морковь, увеличивая её стоимость в ×1.53"},
    ["Dog"] = {Rarity = "Обычный", Ability = "5.14% шанс выкопать семя каждую минуту"},
    ["Golden Lab"] = {Rarity = "Обычный", Ability = "10.31% шанс выкопать семя каждую минуту"},
    ["Black Bunny"] = {Rarity = "Необычный", Ability = "Увеличивает стоимость моркови в ×1.53 (быстрее)"},
    ["Cat"] = {Rarity = "Необычный", Ability = "Спит 10.12 сек/80 сек, увеличивает размер фруктов на ×1.25"},
    ["Chicken"] = {Rarity = "Необычный", Ability = "Ускоряет вылупление яиц на 10.36%"},
    ["Deer"] = {Rarity = "Необычный", Ability = "2.53% шанс оставить ягоды после сбора"},
    ["Hedgehog"] = {Rarity = "Редкий", Ability = "Увеличивает размер колючих фруктов на ×1.52"},
    ["Kiwi"] = {Rarity = "Редкий", Ability = "Сокращает время вылупления яиц на 20.24%"},
    ["Monkey"] = {Rarity = "Редкий", Ability = "2.55% шанс вернуть проданные фрукты"},
    ["Orange Tabby"] = {Rarity = "Редкий", Ability = "Спит 1.5 мин, увеличивает размер фруктов на ×1.51"},
    ["Pig"] = {Rarity = "Редкий", Ability = "2.02% шанс мутировать фрукты (15.35 сек/2 мин)"},
    ["Rooster"] = {Rarity = "Редкий", Ability = "Ускоряет вылупление яиц на 20.93%"},
    ["Spotted Deer"] = {Rarity = "Редкий", Ability = "5.10% шанс оставить ягоды после сбора"},
    ["Blood Hedgehog"] = {Rarity = "Легендарный", Ability = "Колючие фрукты на ×2.02, мутированные на ×1.16"},
    ["Blood Kiwi"] = {Rarity = "Легендарный", Ability = "Ускоряет вылупление яиц на 45.56% и инкубацию на 20.25%"},
    ["Cow"] = {Rarity = "Легендарный", Ability = "Ускоряет рост растений на ×1.12 (8.18 юнитов)"},
    ["Frog"] = {Rarity = "Легендарный", Ability = "Ускоряет рост растения на 24 часа каждые 19.48 мин"},
    ["Mole"] = {Rarity = "Легендарный", Ability = "Выкапывает снаряжение/шекели каждые 1.2 мин"},
    ["Moon Cat"] = {Rarity = "Легендарный", Ability = "Спит 20.18 сек/мин, увеличивает размер фруктов на ×1.51, сохраняет лунные плоды"},
    ["Panda"] = {Rarity = "Легендарный", Ability = "Ест бамбук, увеличивая его стоимость в ×1.57"},
    ["Polar Bear"] = {Rarity = "Легендарный", Ability = "10.14% шанс мутации Охлаждённый/Замороженный каждые 1.29 мин"},
    ["Sea Otter"] = {Rarity = "Легендарный", Ability = "Поливает растения каждые 15 сек"},
    ["Silver Monkey"] = {Rarity = "Легендарный", Ability = "7.76% шанс вернуть проданные фрукты"},
    ["Turtle"] = {Rarity = "Легендарный", Ability = "Увеличивает срок службы разбрызгивателей на 20.47%"},
    ["Brown Mouse"] = {Rarity = "Мифический", Ability = "+803.74 опыта каждые 8 мин, увеличивает высоту прыжков"},
    ["Caterpillar"] = {Rarity = "Мифический", Ability = "Ускоряет рост листовых растений"},
    ["Echo Frog"] = {Rarity = "Мифический", Ability = "Ускоряет рост растения на 24 часа каждые 15 мин"},
    ["Giant Ant"] = {Rarity = "Мифический", Ability = "10.38% шанс удвоить урожай"},
    ["Grey Mouse"] = {Rarity = "Мифический", Ability = "+521.75 опыта каждые 10 мин, увеличивает скорость ходьбы"},
    ["Owl"] = {Rarity = "Мифический", Ability = "0.23 опыта/сек всем питомцам"},
    ["Praying Mantis"] = {Rarity = "Мифический", Ability = "Увеличивает шанс мутаций на 10.30 сек каждые 1.32 мин"},
    ["Red Fox"] = {Rarity = "Мифический", Ability = "Похищает семя из соседского сада каждые 8.57 мин"},
    ["Red Giant Ant"] = {Rarity = "Мифический", Ability = "5.16% шанс дать доп. фрукт (особенно ягоды)"},
    ["Snail"] = {Rarity = "Мифический", Ability = "5.08% шанс вернуть семя после сбора"},
    ["Squirrel"] = {Rarity = "Мифический", Ability = "Возвращает семя после посадки"},
    ["Zombie Chicken"] = {Rarity = "Мифический", Ability = "20.30% шанс мутации Зомбированный каждые 30 мин, +10.15% к вылуплению яиц"},
    ["Firefly"] = {Rarity = "Мифический", Ability = "3.07% шанс мутации Электрический каждые 1.32 мин"},
    ["Blood Owl"] = {Rarity = "Божественный", Ability = "0.53 опыта/сек всем питомцам"},
    ["Dragonfly"] = {Rarity = "Божественный", Ability = "Каждые 4.5 мин превращает фрукт в Золотой"},
    ["Night Owl"] = {Rarity = "Божественный", Ability = "0.23 опыта/сек всем питомцам"},
    ["Raccoon"] = {Rarity = "Божественный", Ability = "Копирует фрукт из соседского сада каждые 15 мин"}
}

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GardenNotifierGui"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local function CreateGui()
    -- Основной фрейм
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 350, 0, 450)
    Frame.Position = UDim2.new(0.5, -175, 0.5, -225)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BackgroundTransparency = 0.1
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    -- Градиентный фон
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 220, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 170, 220))
    }
    Gradient.Rotation = 45
    Gradient.Parent = Frame

    -- Закруглённые углы
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = Frame

    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 0, 40)
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "Садовый Помощник"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextStrokeTransparency = 0.5
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Frame

    -- Кнопка закрытия
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.Text = "X"
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Parent = Frame
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    CloseButton.MouseButton1Click:Connect(function()
        Frame.Visible = false
        Icon.Visible = true
    end)

    -- Кнопка скрытия
    local HideButton = Instance.new("TextButton")
    HideButton.Size = UDim2.new(0, 100, 0, 30)
    HideButton.Position = UDim2.new(0, 5, 0, 45)
    HideButton.Text = "Скрыть"
    HideButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    HideButton.TextSize = 14
    HideButton.Parent = Frame
    local HideCorner = Instance.new("UICorner")
    HideCorner.CornerRadius = UDim.new(0, 8)
    HideCorner.Parent = HideButton
    HideButton.MouseButton1Click:Connect(function()
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Frame, tweenInfo, {Position = UDim2.new(0.5, -175, 1, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            Frame.Visible = false
            Icon.Visible = true
        end)
    end)

    -- Кнопка визуалов
    local VisualsButton = Instance.new("TextButton")
    VisualsButton.Size = UDim2.new(0, 100, 0, 30)
    VisualsButton.Position = UDim2.new(0, 110, 0, 45)
    VisualsButton.Text = "Визуалы: Вкл"
    VisualsButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
    VisualsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    VisualsButton.TextSize = 14
    VisualsButton.Parent = Frame
    local VisualsCorner = Instance.new("UICorner")
    VisualsCorner.CornerRadius = UDim.new(0, 8)
    VisualsCorner.Parent = VisualsButton
    VisualsButton.MouseButton1Click:Connect(function()
        Config.ShowPriceVisuals = not Config.ShowPriceVisuals
        VisualsButton.Text = "Визуалы: " .. (Config.ShowPriceVisuals and "Вкл" or "Выкл")
    end)

    -- Кнопка подсчёта цены
    local PriceTooltipButton = Instance.new("TextButton")
    PriceTooltipButton.Size = UDim2.new(0, 100, 0, 30)
    PriceTooltipButton.Position = UDim2.new(0, 215, 0, 45)
    PriceTooltipButton.Text = "Подсчёт цены: Вкл"
    PriceTooltipButton.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
    PriceTooltipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PriceTooltipButton.TextSize = 14
    PriceTooltipButton.Parent = Frame
    local PriceTooltipCorner = Instance.new("UICorner")
    PriceTooltipCorner.CornerRadius = UDim.new(0, 8)
    PriceTooltipCorner.Parent = PriceTooltipButton
    PriceTooltipButton.MouseButton1Click:Connect(function()
        Config.ShowPriceTooltip = not Config.ShowPriceTooltip
        PriceTooltipButton.Text = "Подсчёт цены: " .. (Config.ShowPriceTooltip and "Вкл" or "Выкл")
    end)

    -- Вкладки
    local Tabs = {"Статус", "Питомцы", "Предметы", "Мутации"}
    local CurrentTab = "Статус"
    local TabButtons = {}
    for i, tab in ipairs(Tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0.25, -5, 0, 30)
        TabButton.Position = UDim2.new((i-1)*0.25, 5, 0, 80)
        TabButton.Text = tab
        TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 14
        TabButton.Parent = Frame
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        TabButton.MouseButton1Click:Connect(function()
            CurrentTab = tab
            UpdateInfoLabel()
        end)
        TabButtons[tab] = TabButton
    end

    -- Информационный текст
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -10, 1, -120)
    InfoLabel.Position = UDim2.new(0, 5, 0, 115)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfoLabel.TextStrokeTransparency = 0.5
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    InfoLabel.TextWrapped = true
    InfoLabel.TextSize = 14
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Text = "Ожидание данных..."
    InfoLabel.Parent = Frame

    -- Иконка возврата
    local Icon = Instance.new("ImageButton")
    Icon.Size = UDim2.new(0, 50, 0, 50)
    Icon.Position = UDim2.new(0, 10, 0, 10)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://1234567890" -- Замени на ID цветка
    Icon.Visible = false
    Icon.Parent = ScreenGui
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 25)
    IconCorner.Parent = Icon
    Icon.MouseButton1Click:Connect(function()
        Frame.Visible = true
        Icon.Visible = false
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Frame, tweenInfo, {Position = UDim2.new(0.5, -175, 0.5, -225)})
        tween:Play()
    end)

    -- Перемещение GUI
    local dragging, dragStart, startPos
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

    -- Функция обновления текста во вкладках
    local function UpdateInfoLabel()
        local text = ""
        if CurrentTab == "Статус" then
            text = GetPlayerData() .. "\n" .. GetServerData()
        elseif CurrentTab == "Питомцы" then
            text = GetPetsInfo()
        elseif CurrentTab == "Предметы" then
            text = GetItemsInfo()
        elseif CurrentTab == "Мутации" then
            text = GetMutationsInfo()
        end
        InfoLabel.Text = text:gsub("*", "")
    end

    return InfoLabel, Icon, UpdateInfoLabel
end

local InfoLabel, Icon, UpdateInfoLabel = CreateGui()

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
        warn("Ошибка отправки в Telegram: " .. tostring(response))
        InfoLabel.Text = InfoLabel.Text .. "\nОшибка Telegram: " .. tostring(response)
        UpdateInfoLabel()
    end
end

-- Анти-AFK
if Config.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- Логирование структуры игры
local function LogGameStructure()
    local log = "*Структура игры*:\n"
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
            log = log .. "- ReplicatedStorage." .. obj.Name .. "\n"
        end
        for _, obj in ipairs(workspace:GetChildren()) do
            log = log .. "- workspace." .. obj.Name .. "\n"
        end
        if Player.leaderstats then
            for _, stat in ipairs(Player.leaderstats:GetChildren()) do
                log = log .. "- leaderstats." .. stat.Name .. "\n"
            end
        end
        if Player.PlayerGui then
            for _, gui in ipairs(Player.PlayerGui:GetChildren()) do
                log = log .. "- PlayerGui." .. gui.Name .. "\n"
            end
        end
    end)
    SendTelegramMessage(log)
    return log
end

-- Получение данных аккаунта
local function GetPlayerData()
    local currency = "Неизвестно"
    local inventory = "Неизвестно"
    pcall(function()
        if Player.leaderstats and Player.leaderstats.Sheckles then
            currency = Player.leaderstats.Sheckles.Value
        elseif Player.leaderstats and Player.leaderstats.Coins then
            currency = Player.leaderstats.Coins.Value
        end
        local inventoryFolder = Player.PlayerGui:FindFirstChild("Inventory") or ReplicatedStorage:FindFirstChild("Inventory")
        if inventoryFolder then
            local items = inventoryFolder:GetChildren()
            inventory = #items > 0 and table.concat(table.map(items, function(item) return item.Name end), ", ") or "Пусто"
        end
    end)
    return string.format("*Аккаунт*: %s\n*Валюта*: %s Шекелей\n*Инвентарь*: %s", Player.Name, currency, inventory)
end

-- Получение данных сервера
local function GetServerData()
    local weather = "Неизвестно"
    local shopData = "Неизвестно"
    pcall(function()
        local gameEvents = ReplicatedStorage:FindFirstChild("GameEvents")
        if gameEvents and gameEvents:FindFirstChild("Weather") then
            weather = gameEvents.Weather.Value
        elseif gameEvents and gameEvents:FindFirstChild("WeatherEventStarted") then
            weather = gameEvents.WeatherEventStarted.Value
        end
        local shopFolder = gameEvents and gameEvents:FindFirstChild("DataStream") and gameEvents.DataStream:FindFirstChild("ShopData")
        if shopFolder then
            local shops = shopFolder:GetChildren()
            shopData = #shops > 0 and table.concat(table.map(shops, function(shop) return shop.Name .. ": " .. (shop.Value or "N/A") end), "\n") or "Пусто"
        end
    end)
    return string.format("*Сервер*:\n*Погода*: %s\n*Магазины*:\n%s", weather, shopData)
end

-- Информация о питомцах
local function GetPetsInfo()
    local petsInfo = "*Питомцы*:\n"
    for engName, pet in pairs(Pets) do
        petsInfo = petsInfo .. string.format("- %s (%s): %s\n", pet.Name or engName, pet.Rarity, pet.Ability)
    end
    pcall(function()
        local petFolder = ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("PetData")
        if petFolder then
            local activePets = petFolder:GetChildren()
            petsInfo = petsInfo .. "\n*Активные питомцы*:\n"
            for _, pet in ipairs(activePets) do
                local petInfo = Pets[pet.Name] or {Name = pet.Name, Ability = "Неизвестно"}
                petsInfo = petsInfo .. string.format("- %s: %s\n", petInfo.Name, petInfo.Ability)
            end
        end
    end)
    return petsInfo
end

-- Информация о предметах
local function GetItemsInfo()
    local itemsInfo = "*Предметы*:\n"
    local items = {
        {Name = "Семя моркови", Effect = "Базовое растение, ~10 Шекелей"},
        {Name = "Семя помидора", Effect = "Базовое растение, ~20 Шекелей"},
        {Name = "Семя подсолнуха", Effect = "Базовое растение, ~50 Шекелей"},
        {Name = "Золотая лейка", Effect = "+10% к шансу мутаций"},
        {Name = "Лунная посыпка", Effect = "Дает мутацию Теневая"},
        {Name = "Скин Губки Боба", Effect = "Косметический скин"}
    }
    pcall(function()
        local cosmeticStock = ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("CosmeticStock")
        if cosmeticStock then
            items = table.map(cosmeticStock:GetChildren(), function(item) return {Name = item.Name, Effect = "Косметика"} end)
        end
    end)
    for _, item in ipairs(items) do
        itemsInfo = itemsInfo .. string.format("- %s: %s\n", item.Name, item.Effect)
    end
    return itemsInfo
end

-- Информация о мутациях
local function GetMutationsInfo()
    local mutationsInfo = "*Мутации*:\n"
    for engName, mutation in pairs(Mutations) do
        mutationsInfo = mutationsInfo .. string.format("- %s (×%d): %s\n", mutation.Name, mutation.Multiplier, mutation.Description)
    end
    return mutationsInfo
end

-- Функция подсчёта цены растения
local function CalculatePlantPrice(plant)
    local basePrice = PlantPrices[plant.Name] or 10
    local weight = 1 -- Нужно получить реальный вес из атрибутов растения
    local growthMutation = 1
    local envMutations = {}
    local envMultiplier = 1

    pcall(function()
        if plant:GetAttribute("Weight") then
            weight = plant:GetAttribute("Weight")
        end
        local mutationFolder = plant:FindFirstChild("Mutations") or plant:GetAttributes()
        for engName, mutation in pairs(Mutations) do
            if mutationFolder[engName] or (mutationFolder.GetAttribute and mutationFolder:GetAttribute(engName)) then
                if engName == "Golden" or engName == "Rainbow" then
                    growthMutation = mutation.Multiplier
                else
                    table.insert(envMutations, mutation)
                    envMultiplier = envMultiplier + mutation.Multiplier - 1
                end
            end
        end
    end)

    local totalPrice = basePrice * (weight ^ 2) * growthMutation * envMultiplier
    return math.floor(totalPrice), envMutations
end

-- Визуалы: цены над растениями
local function UpdatePlantPriceVisuals()
    if not Config.ShowPriceVisuals then return end
    pcall(function()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        local playerPlot = plots:FindFirstChild(Player.Name)
        if not playerPlot then return end
        local plants = playerPlot:GetChildren()
        for _, plant in ipairs(plants) do
            if plant:IsA("Model") and plant:FindFirstChild("BasePart") then
                local price, mutations = CalculatePlantPrice(plant)
                local billboard = plant.BasePart:FindFirstChild("PriceBillboard") or Instance.new("BillboardGui")
                billboard.Name = "PriceBillboard"
                billboard.Size = UDim2.new(0, 80, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 1.5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = plant.BasePart

                local priceLabel = billboard:FindFirstChild("PriceLabel") or Instance.new("TextLabel")
                priceLabel.Name = "PriceLabel"
                priceLabel.Size = UDim2.new(1, 0, 1, 0)
                priceLabel.BackgroundTransparency = 1
                priceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                priceLabel.TextStrokeTransparency = 0.5
                priceLabel.TextSize = 12
                priceLabel.Font = Enum.Font.Gotham
                priceLabel.Text = (Mutations[plant.Name] and Mutations[plant.Name].Name or plant.Name) .. "\nЦена: " .. price .. " Шекелей"
                priceLabel.Parent = billboard
            end
        end
    end)
end

-- Подсчёт цены при наведении
local function ShowPriceTooltip()
    if not Config.ShowPriceTooltip then return end
    pcall(function()
        local mouse = Player:GetMouse()
        mouse.Move:Connect(function()
            local target = mouse.Target
            if target and target.Parent and target.Parent:IsA("Model") and target.Parent.Parent == workspace:FindFirstChild("Plots"):FindFirstChild(Player.Name) then
                local price, mutations = CalculatePlantPrice(target.Parent)
                local mutationText = #mutations > 0 and table.concat(table.map(mutations, function(m) return m.Name end), ", ") or "Нет мутаций"
                local billboard = target.Parent:FindFirstChild("TooltipBillboard") or Instance.new("BillboardGui")
                billboard.Name = "TooltipBillboard"
                billboard.Size = UDim2.new(0, 120, 0, 80)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = target.Parent

                local tooltipLabel = billboard:FindFirstChild("TooltipLabel") or Instance.new("TextLabel")
                tooltipLabel.Name = "TooltipLabel"
                tooltipLabel.Size = UDim2.new(1, 0, 1, 0)
                tooltipLabel.BackgroundTransparency = 0.5
                tooltipLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                tooltipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                tooltipLabel.TextStrokeTransparency = 0.5
                tooltipLabel.TextSize = 10
                tooltipLabel.Font = Enum.Font.Gotham
                tooltipLabel.Text = string.format("%s\nЦена: %d Шекелей\nМутации: %s", Mutations[target.Parent.Name] and Mutations[target.Parent.Name].Name or target.Parent.Name, price, mutationText)
                tooltipLabel.Parent = billboard

                spawn(function()
                    wait(2)
                    if billboard.Parent == target.Parent then
                        billboard:Destroy()
                    end
                end)
            end
        end)
    end)
end

-- Перевод игры на русский
local function TranslateGame()
    if not Config.RussianTranslation then return end
    pcall(function()
        local guiElements = PlayerGui:GetDescendants()
        local translations = {
            -- Интерфейс
            ["Plant"] = "Посадить",
            ["Water"] = "Полить",
            ["Harvest"] = "Собрать",
            ["Inventory"] = "Инвентарь",
            ["Shop"] = "Магазин",
            ["Sheckles"] = "Шекли",
            ["Coins"] = "Шекли",
            ["Seeds"] = "Семена",
            ["Tools"] = "Инструменты",
            ["Pets"] = "Питомцы",
            ["Weather"] = "Погода",
            ["Settings"] = "Настройки",
            ["Buy"] = "Купить",
            ["Sell"] = "Продать",
            -- Растения
            ["Carrot"] = "Морковь",
            ["Tomato"] = "Помидор",
            ["Sunflower"] = "Подсолнух",
            ["Sugar Apple"] = "Сахарное яблоко",
            ["Blood Orange"] = "Кровавый апельсин",
            ["Moon Melon"] = "Лунный арбуз",
            ["Candy Blossom"] = "Конфетный цветок",
            ["Bamboo"] = "Бамбук",
            -- Питомцы
            ["Bunny"] = "Кролик",
            ["Dog"] = "Собака",
            ["Golden Lab"] = "Золотистый лабрадор",
            ["Black Bunny"] = "Чёрный кролик",
            ["Cat"] = "Кошка",
            ["Chicken"] = "Курица",
            ["Deer"] = "Олень",
            ["Hedgehog"] = "Ёжик",
            ["Kiwi"] = "Киви",
            ["Monkey"] = "Обезьяна",
            ["Orange Tabby"] = "Рыжий кот",
            ["Pig"] = "Свинья",
            ["Rooster"] = "Петух",
            ["Spotted Deer"] = "Пятнистый олень",
            ["Blood Hedgehog"] = "Кровавый ёжик",
            ["Blood Kiwi"] = "Кровавый киви",
            ["Cow"] = "Корова",
            ["Frog"] = "Лягушка",
            ["Mole"] = "Крот",
            ["Moon Cat"] = "Лунный кот",
            ["Panda"] = "Панда",
            ["Polar Bear"] = "Белый медведь",
            ["Sea Otter"] = "Морская выдра",
            ["Silver Monkey"] = "Серебряная обезьяна",
            ["Turtle"] = "Черепаха",
            ["Brown Mouse"] = "Коричневая мышь",
            ["Caterpillar"] = "Гусеница",
            ["Echo Frog"] = "Эхо-лягушка",
            ["Giant Ant"] = "Гигантский муравей",
            ["Grey Mouse"] = "Серая мышь",
            ["Owl"] = "Сова",
            ["Praying Mantis"] = "Богомол",
            ["Red Fox"] = "Рыжая лиса",
            ["Red Giant Ant"] = "Красный гигантский муравей",
            ["Snail"] = "Улитка",
            ["Squirrel"] = "Белка",
            ["Zombie Chicken"] = "Зомби-курица",
            ["Firefly"] = "Светлячок",
            ["Blood Owl"] = "Кровавая сова",
            ["Dragonfly"] = "Стрекоза",
            ["Night Owl"] = "Ночная сова",
            ["Raccoon"] = "Енот",
            -- Мутации
            ["Wet"] = "Мокрый",
            ["Chilled"] = "Охлаждённый",
            ["Chocolate"] = "Шоколадный",
            ["Moonlit"] = "Лунный",
            ["Bloodlit"] = "Кровавый",
            ["Plasma"] = "Плазменный",
            ["Frozen"] = "Замороженный",
            ["Golden"] = "Золотой",
            ["Zombified"] = "Зомбированный",
            ["Twisted"] = "Искажённый",
            ["Rainbow"] = "Радужный",
            ["Shocked"] = "Электрический",
            ["Celestial"] = "Небесный",
            ["Disco"] = "Диско",
            ["Solar"] = "Солнечный",
            ["Eclipse"] = "Затмение",
            ["Galactic"] = "Галактический",
            ["Pollinated"] = "Опылённый",
            ["HoneyGlazed"] = "Медовая глазурь",
            ["Sundried"] = "Высушенный солнцем"
        }
        for _, element in ipairs(guiElements) do
            if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                for eng, rus in pairs(translations) do
                    if element.Text:find(eng) then
                        element.Text = element.Text:gsub(eng, rus)
                    end
                end
            end
        end
        pcall(function()
            local plots = workspace:FindFirstChild("Plots")
            if plots and plots:FindFirstChild(Player.Name) then
                for _, plant in ipairs(plots[Player.Name]:GetChildren()) do
                    if plant:IsA("Model") and translations[plant.Name] then
                        plant.Name = translations[plant.Name]
                    end
                end
            end
        end)
    end)
end

-- Основной цикл
spawn(function()
    InfoLabel.Text = "Логирование структуры игры..."
    SendTelegramMessage(LogGameStructure())
    
    while Config.ReportingEnabled do
        local message = "=== Уведомление Садового Помощника ===\n"
        message = message .. GetPlayerData() .. "\n"
        message = message .. GetServerData() .. "\n"
        message = message .. GetPetsInfo() .. "\n"
        message = message .. GetItemsInfo() .. "\n"
        message = message .. GetMutationsInfo() .. "\n"
        pcall(function()
            SendTelegramMessage(message)
            UpdateInfoLabel()
            TranslateGame()
        end)
        pcall(UpdatePlantPriceVisuals)
        wait(Config.ReportInterval)
    end
end)

-- Обновление визуалов
spawn(function()
    while Config.ShowPriceVisuals do
        pcall(UpdatePlantPriceVisuals)
        wait(Config.VisualUpdateInterval)
    end
end)

-- Запуск подсчёта цены при наведении
spawn(function()
    while Config.ShowPriceTooltip do
        pcall(ShowPriceTooltip)
        wait(0.1)
    end
end)

-- Сообщение о запуске
InfoLabel.Text = "Скрипт запущен! Логирование структуры..."
SendTelegramMessage("Скрипт Садового Помощника запущен для " .. Player.Name)
