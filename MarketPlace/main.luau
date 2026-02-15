local Env = getgenv and getgenv() or _G

-- >> PREVENT MULTIPLE INSTANCES
if Env.MarketplaceInstance then
    if Env.MarketplaceInstance.Parent then Env.MarketplaceInstance:Destroy() end
    Env.MarketplaceInstance = nil
end

-- >> CONFIGURATION
local JSON_URL = "https://pastebin.com/raw/cYJpMAK2" -- Твой marketplace.json
local LibUrl = "https://raw.githubusercontent.com/grab1s/VANTALITY/refs/heads/main/ui_library" -- Вставь сюда ссылку на твой uiLIB.txt

-- >> FILE PATHS
local Paths = {
    Scripts = "Vantality/scripts",
    ScriptConfigs = "Vantality/scripts/configs",
    MainConfigs = "Vantality/Config"
}

-- Ensure folders exist
if not isfolder("Vantality") then makefolder("Vantality") end
for _, p in pairs(Paths) do if not isfolder(p) then makefolder(p) end end

-- >> LOAD LIBRARY
local Success, Lib = pcall(function()
    return loadstring(game:HttpGet(LibUrl))()
end)

if not Success or type(Lib) ~= "table" then
    warn("Marketplace: Failed to load UI Library")
    return
end

-- >> CREATE WINDOW
local Window = Lib.new({
    Name = "Marketplace",
    Expire = "Vantality User",
    Keybind = Enum.KeyCode.End -- Отдельная кнопка или можно закрыть мышкой
})
Env.MarketplaceInstance = Window.Main -- Для удаления при перезапуске

local Notifier = Lib:CreateNotifier()

-- >> FETCH DATA
local MarketData = { scripts = {}, script_configs = {}, main_configs = {} }
local DataSuccess, DataResult = pcall(function()
    return game:GetService("HttpService"):JSONDecode(game:HttpGet(JSON_URL))
end)

if DataSuccess then
    MarketData = DataResult
else
    Notifier:Notify({Title = "Error", Content = "Failed to fetch Marketplace data", Icon = "wifi-off"})
end

-- >> UI TABS
local ScriptTab = Window:AddMenu({ Name = "SCRIPTS", Icon = "code" })
local ScriptCfgTab = Window:AddMenu({ Name = "SCRIPT CFGS", Icon = "file-text" })
local MainCfgTab = Window:AddMenu({ Name = "MAIN CFGS", Icon = "settings" })

-- >> HELPER: DOWNLOAD FUNCTION
local function DownloadItem(url, path, name)
    Notifier:Notify({Title = "Downloading...", Content = name, Icon = "download-cloud"})
    
    task.spawn(function()
        local s, content = pcall(game.HttpGet, game, url)
        if s and content then
            local fullPath = path .. "/" .. name
            -- Add extension if missing
            if path == Paths.Scripts and not name:match("%.lua$") then fullPath = fullPath .. ".lua" end
            if path == Paths.ScriptConfigs and not name:match("%.json$") then fullPath = fullPath .. ".json" end
            
            writefile(fullPath, content)
            Notifier:Notify({Title = "Success", Content = "Saved to " .. path, Icon = "check"})
        else
            Notifier:Notify({Title = "Error", Content = "Download failed!", Icon = "x"})
        end
    end)
end

-- >> HELPER: BUILD ITEM LIST
-- Library doesnt support Grid properly, so we balance items between Left, Center, Right columns
local function BuildCategory(Tab, Items, TargetPath)
    if not Items or #Items == 0 then return end
    
    local Columns = {"left", "center", "right"}
    local ColIndex = 1
    
    for _, item in ipairs(Items) do
        local Pos = Columns[ColIndex]
        
        local Section = Tab:AddSection({
            Name = item.name,
            Position = Pos
        })
        
        local desc = string.format("Author: %s\n%s", item.author or "Unknown", item.description or "No description.")
        if item.target_script then
            desc = desc .. "\nFor Script: " .. item.target_script
        end
        
        Section:AddParagraph({
            Title = "Info",
            Content = desc
        })
        
        Section:AddButton({
            Name = "Download / Install",
            Callback = function()
                DownloadItem(item.url, TargetPath, item.name)
            end
        })
        
        -- Cycle columns (1 -> 2 -> 3 -> 1)
        ColIndex = ColIndex + 1
        if ColIndex > 3 then ColIndex = 1 end
    end
end

-- >> POPULATE TABS
BuildCategory(ScriptTab, MarketData.scripts, Paths.Scripts)
BuildCategory(ScriptCfgTab, MarketData.script_configs, Paths.ScriptConfigs)
BuildCategory(MainCfgTab, MarketData.main_configs, Paths.MainConfigs)

-- >> SHOW UI
Window:SetVisible(true)

Notifier:Notify({
    Title = "Marketplace",
    Content = "Welcome to Vantality Market",
    Icon = "shopping-bag"
})