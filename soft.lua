-- 📦 Прототип "Pro Logger"
local Http = game:GetService("HttpService")
local SS = game:GetService("ScreenshotService") or game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local token = "8101289751:AAEk6wpg5UkUBY8S5dSRLcTI0M8TJIZssc4"
local chat_id = "5678878569" -- замени на свой

local running, interval = false, 120

-- 🔁 Отправка HTTP или Synapse
local function sendRequest(url, body)
  if syn and syn.request then
    syn.request({
      Url = url, Method = "POST",
      Headers = {["Content-Type"]="application/json"},
      Body = Http:JSONEncode(body)
    })
  elseif http_request then
    http_request({
      Url = url, Method = "POST",
      Headers = {["Content-Type"]="application/json"},
      Body = Http:JSONEncode(body)
    })
  end
end

-- 🧾 Собираем инфу о растениях и питомцах
local function collectInfo()
  local pets = {}
  for _, p in ipairs(Player:FindFirstChild("Pets") and Player.Pets:GetChildren() or {}) do
    table.insert(pets, p.Name)
  end
  local plants = {}
  for _, obj in pairs(workspace:GetDescendants()) do
    if obj:FindFirstChild("Owner") and obj.Owner.Value == Player then
      local info = {
        name = obj.Name,
        level = obj:FindFirstChild("Level") and obj.Level.Value or "?",
        mutation = obj:FindFirstChild("Mutation") and obj.Mutation.Value or "none",
        price = obj:FindFirstChild("Price") and obj.Price.Value or "?"
      }
      table.insert(plants, info)
    end
  end
  return pets, plants
end

-- 📷 Отправляем скриншот + JSON
local function sendSnapshot()
  local pets, plants = collectInfo()
  local shot = SS:CaptureGame()
  local url = "https://api.telegram.org/bot"..token.."/sendPhoto"
  syn.request({
    Url = url,
    Method = "POST",
    Body = Http:JSONEncode({
      chat_id = chat_id,
      caption = "🪴 Снимок + лог"
    }),
    Headers = {["Content-Type"]="application/json"},
    File = shot
  })
  sendRequest("https://api.telegram.org/bot"..token.."/sendMessage", {
    chat_id = chat_id,
    text = Http:JSONEncode({pets = pets, plants = plants})
  })
end

-- 🎛 GUI
local gui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
local f = Instance.new("Frame", gui)
f.Size = UDim2.new(0, 260, 0, 180); f.Position = UDim2.new(0,20,0,100); f.BackgroundColor3 = Color3.fromRGB(30,30,30)

local t = Instance.new("TextLabel", f)
t.Text = "Grow Logger Pro"; t.Size = UDim2.new(1,0,0,30); t.BackgroundColor3 = Color3.fromRGB(50,50,50); t.TextColor3=Color3.new(1,1,1)

local btn = function(title,y,color,act)
  local b=Instance.new("TextButton",f)
  b.Text=title; b.Size=UDim2.new(1,-20,0,30); b.Position=UDim2.new(0,10,0,y)
  b.BackgroundColor3=color; b.TextColor3=Color3.new(1,1,1)
  b.MouseButton1Click:Connect(act)
end

btn("▶️ Старт",40,Color3.fromRGB(70,180,70),function() running=true end)
btn("⏹ Стоп",80,Color3.fromRGB(180,70,70),function() running=false end)
btn("📤 Снимок",120,Color3.fromRGB(80,80,200),sendSnapshot)

-- 🔄 Цикл логгера
task.spawn(function()
  while true do
    if running then sendSnapshot() end
    wait(interval)
  end
end)
