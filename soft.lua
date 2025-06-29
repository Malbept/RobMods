local Http = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local TOKEN = "8101289751:AAEk6wpg5UkUBY8S5dSRLcTI0M8TJIZssc4"
local CHAT_ID = "5678878569" -- ⚠️ ЗАМЕНИ

local INTERVAL = 60
local running = false

-- 📤 Отправка текста
local function sendText(text)
    local url = "https://api.telegram.org/bot"..TOKEN.."/sendMessage"
    local data = {
        chat_id = CHAT_ID,
        text = text
    }
    local body = Http:JSONEncode(data)

    if syn and syn.request then
        syn.request({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = body
        })
    elseif http_request then
        http_request({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = body
        })
    end
end

-- 📸 Отправка скрина
local function sendScreenshot()
    if getscreenshot then
        local imageData = getscreenshot()
        local boundary = "----WebKitFormBoundary"..tostring(math.random(100000, 999999))
        local body = "--"..boundary.."\r\n"..
            'Content-Disposition: form-data; name="chat_id"\r\n\r\n'..CHAT_ID.."\r\n"..
            "--"..boundary.."\r\n"..
            'Content-Disposition: form-data; name="photo"; filename="screenshot.png"\r\n'..
            "Content-Type: image/png\r\n\r\n"..
            imageData.."\r\n"..
            "--"..boundary.."--"

        local headers = {
            ["Content-Type"] = "multipart/form-data; boundary="..boundary,
            ["Content-Length"] = tostring(#body)
        }

        local url = "https://api.telegram.org/bot"..TOKEN.."/sendPhoto"

        if syn and syn.request then
            syn.request({
                Url = url,
                Method = "POST",
                Headers = headers,
                Body = body
            })
        elseif http_request then
            http_request({
                Url = url,
                Method = "POST",
                Headers = headers,
                Body = body
            })
        end
    else
        sendText("⚠️ getscreenshot не поддерживается в этом эксплойте")
    end
end

-- 🧠 Сбор инфы
local function collectInfo()
    local coins = Player:FindFirstChild("leaderstats") and Player.leaderstats:FindFirstChild("Coins") and Player.leaderstats.Coins.Value or 0
    local harvest = Player:FindFirstChild("leaderstats") and Player.leaderstats:FindFirstChild("Harvest") and Player.leaderstats.Harvest.Value or 0
    local pets = Player:FindFirstChild("Pets") and #Player.Pets:GetChildren() or 0

    local msg = "🌿 Grow a Garden Log\n👤 "..Player.Name..
        "\n💰 Coins: "..coins..
        "\n🌽 Harvest: "..harvest..
        "\n🐾 Pets: "..pets..
        "\n🕒 "..os.date("%H:%M:%S")

    return msg
end

-- 📦 Отправка всей инфы + фото
local function sendFullLog()
    sendText(collectInfo())
    task.wait(1.2)
    sendScreenshot()
end

-- 🔁 Авто-цикл
task.spawn(function()
    while true do
        if running then
            sendFullLog()
        end
        wait(INTERVAL)
    end
end)

-- 🖼 GUI
local gui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0, 10, 0, 120)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local function makeBtn(text, y, color, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.MouseButton1Click:Connect(callback)
end

makeBtn("▶️ Старт авто", 10, Color3.fromRGB(70, 180, 70), function()
    running = true
    sendText("✅ Авто логгер включен.")
end)

makeBtn("⏹ Стоп авто", 50, Color3.fromRGB(180, 70, 70), function()
    running = false
    sendText("⛔ Авто логгер выключен.")
end)

makeBtn("📤 Отправить сейчас", 90, Color3.fromRGB(70, 70, 180), function()
    sendFullLog()
end)
