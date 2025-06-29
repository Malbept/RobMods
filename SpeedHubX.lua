-- Speed Hub X — переключатель по играм
local Games = {
    [126884695634066] = "https://raw.githubusercontent.com/Malbept/RobMods/main/soft.lua", -- Grow a Garden
    [91867617264223] = "https://raw.githubusercontent.com/Malbept/RobMods/main/soft.lua", -- Grow a Garden 1
    -- добавляй сюда другие игры и свои скрипты
}

for PlaceID, ScriptURL in pairs(Games) do
    if game.PlaceId == PlaceID then
        loadstring(game:HttpGet(ScriptURL))()
        break
    end
end
