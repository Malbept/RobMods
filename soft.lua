local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local token = "8101289751:AAEk6wpg5UkUBY8S5dSRLcTI0M8TJIZssc4"
local chat_id = "5678878569" -- Замени на свой

local running = false
local interval = 60

local function sendToTelegram(msg)
    pcall(function()
        http_request({
            Url = "https://api.telegram.org/bot" .. token .. "/sendMessage",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                chat_id = chat_id,
                text = msg
            })
        })
    end)
end

local function sendStats()
    local coins = Player.leaderstats and Player.leaderstats.Coins.Value or 0
    local harvest = Player.leaderstats and Player.leaderstats.Harvest.Value or 0
    local pets = Player.Pets and #Player.Pets:GetChildren() or 0
    local msg = "🪴 Grow Log\\n👤 " .. Player.Name ..
                "\\n💰 Coins: " .. coins ..
                "\\n🌽 Harvest: " .. harvest ..
                "\\n🐾 Pets: " .. pets ..
                "\\n🕒 " .. os.date("%H:%M:%S")
    sendToTelegram(msg)
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 240, 0, 160)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Frame)
Title.Text = "🌿 Grow Logger"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1, -20, 0, 30)
Toggle.Position = UDim2.new(0, 10, 0, 40)
Toggle.Text = "▶️ Запустить"
Toggle.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Font = Enum.Font.SourceSans
Toggle.TextSize = 16

local SendNow = Instance.new("TextButton", Frame)
SendNow.Size = UDim2.new(1, -20, 0, 30)
SendNow.Position = UDim2.new(0, 10, 0, 80)
SendNow.Text = "📤 Отправить сейчас"
SendNow.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
SendNow.TextColor3 = Color3.new(1,1,1)
SendNow.Font = Enum.Font.SourceSans
SendNow.TextSize = 16

local IntervalLabel = Instance.new("TextLabel", Frame)
IntervalLabel.Size = UDim2.new(1, -20, 0, 20)
IntervalLabel.Position = UDim2.new(0, 10, 0, 120)
IntervalLabel.Text = "⏱ Интервал: " .. interval .. " сек"
IntervalLabel.BackgroundTransparency = 1
IntervalLabel.TextColor3 = Color3.new(1,1,1)
IntervalLabel.Font = Enum.Font.SourceSans
IntervalLabel.TextSize = 14

Toggle.MouseButton1Click:Connect(function()
    running = not running
    Toggle.Text = running and "⏹ Остановить" or "▶️ Запустить"
    Toggle.BackgroundColor3 = running and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 180, 80)
end)

SendNow.MouseButton1Click:Connect(function()
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
