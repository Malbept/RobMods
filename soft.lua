-- @description Grow a Garden Helper (Horizontal Red GUI, Price Tooltip, Russian Translation)
-- @author Grok (based on user request)

-- Услуги Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local workspace = game:GetService("Workspace")

-- Конфигурация
local Config = {
    AntiAFK = true,
    RussianTranslation = true,
    ShowPriceTooltip = true, -- Подсчёт цены при наведении
}

-- Таблица мутаций
local Mutations = {
    ["Wet"] = {Name = "Мокрый", Multiplier = 2},
    ["Chilled"] = {Name = "Охлаждённый", Multiplier = 2},
    ["Chocolate"] = {Name = "Шоколадный", Multiplier = 2},
    ["Moonlit"] = {Name = "Лунный", Multiplier = 2},
    ["Bloodlit"] = {Name = "Кровавый", Multiplier = 4},
    ["Plasma"] = {Name = "Плазменный", Multiplier = 5},
    ["Frozen"] = {Name = "Замороженный", Multiplier = 10},
    ["Golden"] = {Name = "Золотой", Multiplier = 20},
    ["Zombified"] = {Name = "Зомбированный", Multiplier = 25},
    ["Twisted"] = {Name = "Искажённый", Multiplier = 30},
    ["Rainbow"] = {Name = "Радужный", Multiplier = 50},
    ["Shocked"] = {Name = "Электрический", Multiplier = 100},
    ["Celestial"] = {Name = "Небесный", Multiplier = 120},
    ["Disco"] = {Name = "Диско", Multiplier = 125},
    ["Solar"] = {Name = "Солнечный", Multiplier = 150},
    ["Eclipse"] = {Name = "Затмение", Multiplier = 80},
    ["Galactic"] = {Name = "Галактический", Multiplier = 4},
    ["Pollinated"] = {Name = "Опылённый", Multiplier = 3},
    ["HoneyGlazed"] = {Name = "Медовая глазурь", Multiplier = 5},
    ["Sundried"] = {Name = "Высушенный солнцем", Multiplier = 1}
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
ScreenGui.Name = "GardenHelperGui"
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
        print("Закрытие GUI")
        Frame.Visible = false
        Icon.Visible = true
    end)

    -- Кнопка скрытия
    local HideButton = Instance.new("TextButton")
    HideButton.Size = UDim2.new(0, 100, 0, 30)
    HideButton.Position = UDim2.new(0, 5, 0, 40)
    HideButton.Text = "Скрыть"
    HideButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    HideButton.TextSize = 14
    HideButton.Parent = Frame
    local HideCorner = Instance.new("UICorner")
    HideCorner.CornerRadius = UDim.new(0, 8)
    HideCorner.Parent = HideButton
    HideButton.MouseButton1Click:Connect(function()
        print("Скрытие GUI")
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Frame, tweenInfo, {Position = UDim2.new(0.5, -300, 1, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            Frame.Visible = false
            Icon.Visible = true
        end)
    end)

    -- Кнопка подсчёта цены
    local PriceTooltipButton = Instance.new("TextButton")
    PriceTooltipButton.Size = UDim2.new(0, 150, 0, 30)
    PriceTooltipButton.Position = UDim2.new(0, 110, 0, 40)
    PriceTooltipButton.Text = "Подсчёт цены: Вкл"
    PriceTooltipButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    PriceTooltipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PriceTooltipButton.TextSize = 14
    PriceTooltipButton.Parent = Frame
    local PriceTooltipCorner = Instance.new("UICorner")
    PriceTooltipCorner.CornerRadius = UDim.new(0, 8)
    PriceTooltipCorner.Parent = PriceTooltipButton
    PriceTooltipButton.MouseButton1Click:Connect(function()
        Config.ShowPriceTooltip = not Config.ShowPriceTooltip
        PriceTooltipButton.Text = "Подсчёт цены: " .. (Config.ShowPriceTooltip and "Вкл" or "Выкл")
        print("Подсчёт цены: " .. tostring(Config.ShowPriceTooltip))
    end)

    -- Вкладки
    local Tabs = {"Статус", "Питомцы", "Мутации"}
    local CurrentTab = "Статус"
    local TabButtons = {}
    for i, tab in ipairs(Tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 100, 0, 30)
        TabButton.Position = UDim2.new(0, 265 + (i-1)*105, 0, 40)
        TabButton.Text = tab
        TabButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 14
        TabButton.Parent = Frame
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        TabButton.MouseButton1Click:Connect(function()
            print("Нажата вкладка: " .. tab)
            CurrentTab = tab
            UpdateInfoLabel()
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
        print("Возврат GUI")
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
            text = GetPlayerData()
        elseif CurrentTab == "Питомцы" then
            text = GetPetsInfo()
        elseif CurrentTab == "Мутации" then
            text = GetMutationsInfo()
        end
        InfoLabel.Text = text
        print("Обновлён текст вкладки: " .. CurrentTab)
    end

    return InfoLabel, Icon, UpdateInfoLabel
end

local InfoLabel, Icon, UpdateInfoLabel = CreateGui()

-- Анти-AFK
if Config.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("Анти-AFK сработал")
    end)
end

-- Логирование структуры игры
local function LogGameStructure()
    local log = "Структура игры:\n"
    pcall(function()
        for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
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
    print(log)
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
        local inventoryFolder = Player.PlayerGui:FindFirstChild("Inventory") or game:GetService("ReplicatedStorage"):FindFirstChild("Inventory")
        if inventoryFolder then
            local items = inventoryFolder:GetChildren()
            inventory = #items > 0 and table.concat(table.map(items, function(item) return item.Name end), ", ") or "Пусто"
        end
    end)
    print("Данные аккаунта: Валюта = " .. currency .. ", Инвентарь = " .. inventory)
    return string.format("Аккаунт: %s\nВалюта: %s Шекелей\nИнвентарь: %s", Player.Name, currency, inventory)
end

-- Информация о питомцах
local function GetPetsInfo()
    local petsInfo = "Питомцы:\n"
    pcall(function()
        local petFolder = game:GetService("ReplicatedStorage"):FindFirstChild("GameEvents") and game:GetService("ReplicatedStorage").GameEvents:FindFirstChild("PetData")
        if petFolder then
            local activePets = petFolder:GetChildren()
            for _, pet in ipairs(activePets) do
                petsInfo = petsInfo .. string.format("- %s\n", pet.Name)
            end
        else
            petsInfo = petsInfo .. "Питомцы не найдены\n"
            print("Ошибка: PetData не найдено")
        end
    end)
    return petsInfo
end

-- Информация о мутациях
local function GetMutationsInfo()
    local mutationsInfo = "Мутации:\n"
    for engName, mutation in pairs(Mutations) do
        mutationsInfo = mutationsInfo .. string.format("- %s (×%d)\n", mutation.Name, mutation.Multiplier)
    end
    return mutationsInfo
end

-- Подсчёт цены растения
local function CalculatePlantPrice(plant)
    local basePrice = PlantPrices[plant.Name] or 10
    local weight = 1
    local growthMutation = 1
    local envMutations = {}
    local envMultiplier = 1

    pcall(function()
        if plant:GetAttribute("Weight") then
            weight = plant:GetAttribute("Weight")
        else
            print("Ошибка: Вес растения не найден")
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
    print("Цена растения " .. plant.Name .. ": " .. totalPrice .. " Шекелей, Мутации: " .. (#envMutations > 0 and table.concat(table.map(envMutations, function(m) return m.Name end), ", ") or "Нет"))
    return math.floor(totalPrice), envMutations
end

-- Подсчёт цены при наведении
local function ShowPriceTooltip()
    if not Config.ShowPriceTooltip then return end
    pcall(function()
        local mouse = Player:GetMouse()
        mouse.Move:Connect(function()
            local target = mouse.Target
            if target and target.Parent and target.Parent:IsA("Model") then
                local plot = target.Parent.Parent
                local possiblePaths = {
                    workspace:FindFirstChild("Plots"),
                    workspace:FindFirstChild("Gardens"),
                    workspace:FindFirstChild("PlayerPlots")
                }
                local isPlayerPlot = false
                for _, path in ipairs(possiblePaths) do
                    if path and path:FindFirstChild(Player.Name) and plot == path[Player.Name] then
                        isPlayerPlot = true
                        break
                    end
                end
                if isPlayerPlot then
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
                        print("Переведён элемент: " .. eng .. " → " .. rus)
                    end
                end
            end
        end
        local possiblePaths = {
            workspace:FindFirstChild("Plots"),
            workspace:FindFirstChild("Gardens"),
            workspace:FindFirstChild("PlayerPlots")
        }
        for _, path in ipairs(possiblePaths) do
            if path and path:FindFirstChild(Player.Name) then
                for _, plant in ipairs(path[Player.Name]:GetChildren()) do
                    if plant:IsA("Model") and translations[plant.Name] then
                        plant.Name = translations[plant.Name]
                        print("Переведено растение: " .. plant.Name)
                    end
                end
            end
        end
    end)
end

-- Основной цикл
spawn(function()
    print("Скрипт запущен")
    LogGameStructure()
    TranslateGame()
    UpdateInfoLabel()
end)

-- Запуск подсчёта цены
spawn(function()
    while Config.ShowPriceTooltip do
        pcall(ShowPriceTooltip)
        wait(0.1)
    end
end)
