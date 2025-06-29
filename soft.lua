-- @description Grow a Garden Telegram Notifier (Horizontal Red GUI, Price Tooltip, Russian Translation)
-- @author Grok (based on user request)

-- Услуги Roblox
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

-- Конфигурация
local Config = {
    TelegramBotToken = "8101289751:AAEk6wpg5UkUBY8S5dSRLcTI0M8TJIZssc4",
    TelegramChatId = "5678878569",
    ReportingEnabled = true,
    ReportInterval = 300, -- Отправка каждые 5 минут для отладки
    AntiAFK = true,
    RussianTranslation = true,
    ShowPriceTooltip = true, -- Подсчёт цены при наведении
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

-- Таблица растений
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

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GardenNotifierGui"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local function CreateGui()
    -- Основной фрейм (горизонтальный, красный)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 600, 0, 200)
    Frame.Position = UDim2.new(0.5, -300, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    -- Закруглённые углы
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = Frame

    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 0, 30)
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "Садовый Помощник"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextStrokeTransparency = 0.5
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Frame

    -- Кнопка закрытия
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.Text = "X"
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
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

    -- Кнопка подсчёта цены
    local PriceTooltipButton = Instance.new("TextButton")
    PriceTooltipButton.Size = UDim2.new(0, 150, 0, 30)
    PriceTooltipButton.Position = UDim2.new(0, 5, 0, 40)
    PriceTooltipButton.Text = "Подсчёт цены: Вкл"
    PriceTooltipButton.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
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
    local Tabs = {"Статус", "Питомцы", "Мутации"}
    local CurrentTab = "Статус"
    local TabButtons = {}
    for i, tab in ipairs(Tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 120, 0, 30)
        TabButton.Position = UDim2.new(0, 160 + (i-1)*125, 0, 40)
        TabButton.Text = tab
        TabButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 14
        TabButton.Parent = Frame
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        TabButton.MouseButton1Click:Connect(function()
            CurrentTab = tab
            UpdateInfoLabel()
            -- Анимация нажатия
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(TabButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)})
            tween:Play()
            wait(0.2)
            tween = TweenService:Create(TabButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(150, 50, 50)})
            tween:Play()
        end)
        TabButtons[tab] = TabButton
    end

    -- Информационный текст
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -10, 0, 120)
    InfoLabel.Position = UDim2.new(0, 5, 0, 75)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfoLabel.TextStrokeTransparency = 0.5
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    InfoLabel.TextWrapped = true
    InfoLabel.TextSize = 12
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
        local tween = TweenService:Create(Frame, tweenInfo, {Position = UDim2.new(0.5, -300, 0.5, -100)})
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
    pcall(function()
        local gameEvents = ReplicatedStorage:FindFirstChild("GameEvents")
        if gameEvents and gameEvents:FindFirstChild("Weather") then
            weather = gameEvents.Weather.Value
        elseif gameEvents and gameEvents:FindFirstChild("WeatherEventStarted") then
            weather = gameEvents.WeatherEventStarted.Value
        end
    end)
    return string.format("*Сервер*:\n*Погода*: %s", weather)
end

-- Информация о питомцах
local function GetPetsInfo()
    local petsInfo = "*Питомцы*:\n"
    pcall(function()
        local petFolder = ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("PetData")
        if petFolder then
            local activePets = petFolder:GetChildren()
            for _, pet in ipairs(activePets) do
                petsInfo = petsInfo .. string.format("- %s\n", pet.Name)
            end
        else
            petsInfo = petsInfo .. "Питомцы не найдены\n"
        end
    end)
    return petsInfo
end

-- Информация о мутациях
local function GetMutationsInfo()
    local mutationsInfo = "*Мутации*:\n"
    for engName, mutation in pairs(Mutations) do
        mutationsInfo = mutationsInfo .. string.format("- %s (×%d): %s\n", mutation.Name, mutation.Multiplier, mutation.Description)
    end
    return mutationsInfo
end

-- Подсчёт цены растения
local function CalculatePlantPrice(plant)
    local basePrice = PlantPrices[plant.Name] or 10
    local weight = 1 -- Нужно получить реальный вес
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
                tooltipLabel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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
        local translations = {
            ["Plant"] = "Посадить",
            ["Water"] = "Полить",
            ["Harvest"] = "Собрать",
            ["Inventory"] = "Инвентарь",
            ["Shop"] = "Магазин",
            ["Sheckles"] = "Шекли",
            ["Carrot"] = "Морковь",
            ["Tomato"] = "Помидор",
            ["Sunflower"] = "Подсолнух",
            ["Sugar Apple"] = "Сахарное яблоко",
            ["Blood Orange"] = "Кровавый апельсин",
            ["Moon Melon"] = "Лунный арбуз",
            ["Candy Blossom"] = "Конфетный цветок",
            ["Bamboo"] = "Бамбук"
        }
        for _, element in ipairs(PlayerGui:GetDescendants()) do
            if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                for eng, rus in pairs(translations) do
                    if element.Text:find(eng) then
                        element.Text = element.Text:gsub(eng, rus)
                    end
                end
            end
        end
        local plots = workspace:FindFirstChild("Plots")
        if plots and plots:FindFirstChild(Player.Name) then
            for _, plant in ipairs(plots[Player.Name]:GetChildren()) do
                if plant:IsA("Model") and translations[plant.Name] then
                    plant.Name = translations[plant.Name]
                end
            end
        end
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
        message = message .. GetMutationsInfo() .. "\n"
        pcall(function()
            SendTelegramMessage(message)
            UpdateInfoLabel()
            TranslateGame()
        end)
        wait(Config.ReportInterval)
    end
end)

-- Запуск подсчёта цены
spawn(function()
    while Config.ShowPriceTooltip do
        pcall(ShowPriceTooltip)
        wait(0.1)
    end
end)

-- Сообщение о запуске
SendTelegramMessage("Скрипт Садового Помощника запущен для " .. Player.Name)
