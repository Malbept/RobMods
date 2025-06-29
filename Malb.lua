-- Загружаем оригинальный Grow a Garden
local success, err = pcall(function()
    local mainScript = game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Script-Games/refs/heads/main/Grow%20a%20Garden.lua")
    loadstring(mainScript)()
end)

if not success then
    warn("Ошибка загрузки Grow a Garden: " .. tostring(err))
end

-- Загружаем логгер с GUI из твоего репо
local success2, err2 = pcall(function()
    local logScript = game:HttpGet("https://raw.githubusercontent.com/Malbept/RobMods/main/GrowLoggerWithGUI.lua")
    loadstring(logScript)()
end)

if not success2 then
    warn("Ошибка загрузки логгера: " .. tostring(err2))
end
