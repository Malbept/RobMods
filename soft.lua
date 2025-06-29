-- ========== НАЧАЛО ==========
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local token = "8101289751:AAEk6wpg5UkUBY8S5dSRLcTI0M8TJIZssc4"
local chat_id = "5678878569" -- ЗАМЕНИ ОБЯЗАТЕЛЬНО

local running = false
local interval = 60

local function sendToTelegram(msg)
    pcall(function()
        if syn and syn.request then
            syn.request({
                Url = "https://api.telegram.org/bot" .. token .. "/sendMessage",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode({
                    chat_id = chat_id,
                    text = msg
                })
            })
        elseif http_request then
            http_request({
                Url = "https://api.telegram.org/bot" .. token .. "/sendMessage",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode({
                    chat_id = chat_id,
                    text = msg
                })
            })
        end
    end)
end

local function sendStats()
    local coins = Player:FindFirstChild("leaderstats") and Player.leaderstats:FindFirstChild("Coins") and Player.leaderstats.Coins.Value or 0
    local harvest = Player:FindFirstChild("leaderstats") and Player.leaderstats:FindFirstChild("Harvest") and Player.leaderstats.Harvest.Value or 0
    local pets = Player:FindFirstChild("Pets") and #Player.Pets:GetChildren() or 0

    local msg = "🪴 Grow Log\n👤 " .. Player.Name ..
                "\n💰 Coins: " .. coins ..
                "\n🌽 Harvest: " .. harvest ..
                "\n🐾 Pets: " .. pets ..
                "\n🕒 " .. os.date("%H:%M:%S")
    sendToTelegram(msg)
end

-- ✅ GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GrowLoggerUI"
pcall(function()
    gui.Parent = Player:WaitForChild("PlayerGui")
end)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0, 10, 0, 120)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
title.Text = "🌿 Grow Logger"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local toggle = Instance.new("TextButton", frame)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Text = "▶️ Старт лог"
toggle.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.SourceSans
toggle.TextSize = 16

local sendNow = Instance.new("TextButton", frame)
sendNow.Position = UDim2.new(0, 10, 0, 80)
sendNow.Size = UDim2.new(1, -20, 0, 30)
sendNow.Text = "📤 Отправить сейчас"
sendNow.BackgroundColor3 = Color3.fromRGB(70, 70, 180)
sendNow.TextColor3 = Color3.new(1, 1, 1)
sendNow.Font = Enum.Font.SourceSans
sendNow.TextSize = 16

toggle.MouseButton1Click:Connect(function()
    running = not running
    toggle.Text = running and "⏹ Стоп лог" or "▶️ Старт лог"
    toggle.BackgroundColor3 = running and Color3.fromRGB(180, 70, 70) or Color3.fromRGB(70, 180, 70)
end)

sendNow.MouseButton1Click:Connect(function()
    sendStats()
end)

task.spawn(function()
    while true do
        if running then
            sendStats()
        end
        task.wait(interval)
    end
end)
-- ========== КОНЕЦ ==========
