local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
if not localPlayer then return end

local localUsername = localPlayer.Name
local localUserId = localPlayer.UserId

_G.ExecutorSpoofer = _G.ExecutorSpoofer or {}
local SPOOFER = _G.ExecutorSpoofer

SPOOFER.Settings = SPOOFER.Settings or {
    Leaderboards = {
        SpoofTotalKills = false,
        SpoofTotalKillsReal = false,
        SpoofDonations = false
    },
    Leaderstats = {
        SpoofKills = false,
        TargetKills = 1337,
        SpoofTotalKillsStat = false,
        TargetTotalKills = 9001
    }
}
local Settings = SPOOFER.Settings

SPOOFER.State = SPOOFER.State or {
    isLeaderboardSpoofEnabled = true,
    isLeaderstatsSpoofEnabled = true,
    isWindowFocused = true,
    leaderboardOriginalData = {},
    leaderstatsOriginalValues = {},
    leaderboardObjects = {},
    leaderstatsObjects = {},
    updateConnection = nil,
    focusLostConnection = nil,
    focusGainedConnection = nil
}
local State = SPOOFER.State

local BASE_NAME = "ExecutorSpoofer_v1"

local LEADERBOARD_PATHS = {
    TotalKills = {
        Base = {"Map", "Total Kills Leaderboard", "a", "SurfaceGui", "Holder", "Line", "Main", "KillFrame"},
        TextLabel = {"TextLabel"},
        ImageLabel1 = {"TextLabel", "ImageLabel"},
        ImageLabel2 = {"TextLabel", "ImageLabel", "ImageLabel"}
    },
    TotalKillsReal = {
        Base = {"Map", "Total Kills Leaderboard Real", "a", "SurfaceGui", "Holder", "Line", "Main", "KillFrame"},
        TextLabel = {"TextLabel"},
        ImageLabel1 = {"TextLabel", "ImageLabel"},
        ImageLabel2 = {"TextLabel", "ImageLabel", "ImageLabel"}
    },
    DonationsLine1 = {
        Base = {"Thrown", "Donation Leaderboard", "a", "SurfaceGui", "Holder", "Line", "BigMain", "KillFrame"},
        TextLabel = {"TextLabel"},
        ImageLabel1 = {"TextLabel", "ImageLabel"},
        ImageLabel2 = {"TextLabel", "ImageLabel", "ImageLabel"}
    },
    DonationsLine2 = {
        Base = {"Thrown", "Donation Leaderboard", "a", "SurfaceGui", "Holder", "Line2", "BigMain", "KillFrame"},
        TextLabel = {"TextLabel"},
        ImageLabel1 = {"TextLabel", "ImageLabel"},
        ImageLabel2 = {"TextLabel", "ImageLabel", "ImageLabel"}
    }
}

local function Cleanup_Internal()
    if SPOOFER.updateConnection and SPOOFER.updateConnection.Connected then SPOOFER.updateConnection:Disconnect() end
    if SPOOFER.focusLostConnection and SPOOFER.focusLostConnection.Connected then SPOOFER.focusLostConnection:Disconnect() end
    if SPOOFER.focusGainedConnection and SPOOFER.focusGainedConnection.Connected then SPOOFER.focusGainedConnection:Disconnect() end
    SPOOFER.updateConnection, SPOOFER.focusLostConnection, SPOOFER.focusGainedConnection = nil, nil, nil

    if State.isLeaderboardSpoofEnabled then
        pcall(SPOOFER.DisableLeaderboardSpoof, SPOOFER)
    end
     if State.isLeaderstatsSpoofEnabled then
        pcall(SPOOFER.DisableLeaderstatsSpoof, SPOOFER)
    end
    task.wait(0.1)

    State.leaderboardOriginalData = {}
    State.leaderstatsOriginalValues = {}
    State.leaderboardObjects = {}
    State.leaderstatsObjects = {}
end

local function FindObjectByPath(startNode, path)
    local current = startNode
    for _, name in ipairs(path) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

local function GetLeaderboardObject(key, subPath)
    local fullKey = key .. table.concat(subPath)
    if State.leaderboardObjects[fullKey] and State.leaderboardObjects[fullKey].Parent then
        return State.leaderboardObjects[fullKey]
    end
    local basePath = LEADERBOARD_PATHS[key] and LEADERBOARD_PATHS[key].Base
    if not basePath then return nil end
    local startNode = FindObjectByPath(Workspace, basePath)
    if not startNode then return nil end
    local obj = FindObjectByPath(startNode, subPath)
    if obj then State.leaderboardObjects[fullKey] = obj end
    return obj
end

local function StoreLeaderboardOriginal(obj, key)
    if not obj or State.leaderboardOriginalData[obj] then return end
    State.leaderboardOriginalData[obj] = {
        Text = obj:IsA("TextLabel") and obj.Text or nil,
        Image = obj:IsA("ImageLabel") and obj.Image or nil
    }
end

local function RestoreLeaderboardOriginal(obj, key)
    if not obj or not State.leaderboardOriginalData[obj] then return end
    local original = State.leaderboardOriginalData[obj]
    local changed = false
    if obj:IsA("TextLabel") and original.Text and obj.Text ~= original.Text then
        pcall(function() obj.Text = original.Text end)
        changed = true
    end
    if obj:IsA("ImageLabel") and original.Image and obj.Image ~= original.Image then
        pcall(function() obj.Image = original.Image end)
        changed = true
    end
    State.leaderboardOriginalData[obj] = nil
end

local function ApplyLeaderboardSpoof()
    if not State.isLeaderboardSpoofEnabled or not State.isWindowFocused then return end

    local function processElement(key, subPath, shouldSpoof)
        local obj = GetLeaderboardObject(key, subPath)
        if not obj then return end

        StoreLeaderboardOriginal(obj, key..table.concat(subPath))

        if shouldSpoof then
            if obj:IsA("TextLabel") then
                local originalText = obj.Text
                local newText = originalText:gsub("%s%S+$", " " .. localUsername)
                if newText ~= originalText then pcall(function() obj.Text = newText end) end
            elseif obj:IsA("ImageLabel") then
                local originalImage = obj.Image
                local newImage, r = originalImage:gsub("(id=)%d+(&?)", "%1"..tostring(localUserId).."%2")
                if r > 0 then pcall(function() obj.Image = newImage end) end
            end
        else
            RestoreLeaderboardOriginal(obj, key..table.concat(subPath))
        end
    end

    processElement("TotalKills", LEADERBOARD_PATHS.TotalKills.TextLabel, Settings.Leaderboards.SpoofTotalKills)
    processElement("TotalKills", LEADERBOARD_PATHS.TotalKills.ImageLabel1, Settings.Leaderboards.SpoofTotalKills)
    processElement("TotalKills", LEADERBOARD_PATHS.TotalKills.ImageLabel2, Settings.Leaderboards.SpoofTotalKills)

    processElement("TotalKillsReal", LEADERBOARD_PATHS.TotalKillsReal.TextLabel, Settings.Leaderboards.SpoofTotalKillsReal)
    processElement("TotalKillsReal", LEADERBOARD_PATHS.TotalKillsReal.ImageLabel1, Settings.Leaderboards.SpoofTotalKillsReal)
    processElement("TotalKillsReal", LEADERBOARD_PATHS.TotalKillsReal.ImageLabel2, Settings.Leaderboards.SpoofTotalKillsReal)

    processElement("DonationsLine1", LEADERBOARD_PATHS.DonationsLine1.TextLabel, Settings.Leaderboards.SpoofDonations)
    processElement("DonationsLine1", LEADERBOARD_PATHS.DonationsLine1.ImageLabel1, Settings.Leaderboards.SpoofDonations)
    processElement("DonationsLine1", LEADERBOARD_PATHS.DonationsLine1.ImageLabel2, Settings.Leaderboards.SpoofDonations)

    processElement("DonationsLine2", LEADERBOARD_PATHS.DonationsLine2.TextLabel, Settings.Leaderboards.SpoofDonations)
    processElement("DonationsLine2", LEADERBOARD_PATHS.DonationsLine2.ImageLabel1, Settings.Leaderboards.SpoofDonations)
    processElement("DonationsLine2", LEADERBOARD_PATHS.DonationsLine2.ImageLabel2, Settings.Leaderboards.SpoofDonations)
end

local function FindLeaderstatsObjects()
    if State.leaderstatsObjects["Kills"] and State.leaderstatsObjects["Total Kills"] then return true end

    local leaderstatsFolder = localPlayer:FindFirstChild("leaderstats")
    if not leaderstatsFolder then return false end

    local killsStat = leaderstatsFolder:FindFirstChild("Kills")
    local totalKillsStat = leaderstatsFolder:FindFirstChild("Total Kills")

    if killsStat and killsStat:IsA("IntValue") then State.leaderstatsObjects["Kills"] = killsStat end
    if totalKillsStat and totalKillsStat:IsA("IntValue") then State.leaderstatsObjects["Total Kills"] = totalKillsStat end

    return State.leaderstatsObjects["Kills"] and State.leaderstatsObjects["Total Kills"]
end

local function StoreLeaderstatsOriginals()
    if not FindLeaderstatsObjects() then return end
    if State.leaderstatsObjects["Kills"] and State.leaderstatsOriginalValues["Kills"] == nil then
        State.leaderstatsOriginalValues["Kills"] = State.leaderstatsObjects["Kills"].Value
    end
    if State.leaderstatsObjects["Total Kills"] and State.leaderstatsOriginalValues["Total Kills"] == nil then
        State.leaderstatsOriginalValues["Total Kills"] = State.leaderstatsObjects["Total Kills"].Value
    end
end

local function RestoreLeaderstatsOriginals()
    if not FindLeaderstatsObjects() then return end
    if State.leaderstatsObjects["Kills"] and State.leaderstatsOriginalValues["Kills"] ~= nil then
        pcall(function() State.leaderstatsObjects["Kills"].Value = State.leaderstatsOriginalValues["Kills"] end)
        State.leaderstatsOriginalValues["Kills"] = nil
    end
    if State.leaderstatsObjects["Total Kills"] and State.leaderstatsOriginalValues["Total Kills"] ~= nil then
        pcall(function() State.leaderstatsObjects["Total Kills"].Value = State.leaderstatsOriginalValues["Total Kills"] end)
        State.leaderstatsOriginalValues["Total Kills"] = nil
    end
end

local function ApplyLeaderstatsSpoof()
    if not State.isLeaderstatsSpoofEnabled or not State.isWindowFocused then return end
    if not FindLeaderstatsObjects() then return end

    StoreLeaderstatsOriginals()

    if State.leaderstatsObjects["Kills"] then
        if Settings.Leaderstats.SpoofKills then
            pcall(function() State.leaderstatsObjects["Kills"].Value = Settings.Leaderstats.TargetKills end)
        elseif State.leaderstatsOriginalValues["Kills"] ~= nil then
            pcall(function() State.leaderstatsObjects["Kills"].Value = State.leaderstatsOriginalValues["Kills"] end)
        end
    end

    if State.leaderstatsObjects["Total Kills"] then
        if Settings.Leaderstats.SpoofTotalKillsStat then
            pcall(function() State.leaderstatsObjects["Total Kills"].Value = Settings.Leaderstats.TargetTotalKills end)
        elseif State.leaderstatsOriginalValues["Total Kills"] ~= nil then
            pcall(function() State.leaderstatsObjects["Total Kills"].Value = State.leaderstatsOriginalValues["Total Kills"] end)
        end
    end
end

local function OnHeartbeat(deltaTime)
    if not SPOOFER or not State or not Settings then return end
    if not State.isWindowFocused then return end

    pcall(ApplyLeaderboardSpoof)
    pcall(ApplyLeaderstatsSpoof)
end

local function OnFocusLost() if SPOOFER and State then State.isWindowFocused = false end end
local function OnFocusGained() if SPOOFER and State then State.isWindowFocused = true end end

function SPOOFER:EnableLeaderboardSpoof()
    if not State then return end
    if not State.isLeaderboardSpoofEnabled then
        State.isLeaderboardSpoofEnabled = true
        ApplyLeaderboardSpoof()
    end
end

function SPOOFER:DisableLeaderboardSpoof()
    if not State then return end
    if State.isLeaderboardSpoofEnabled then
        State.isLeaderboardSpoofEnabled = false
        local function restoreElement(key, subPath)
            local obj = GetLeaderboardObject(key, subPath)
            RestoreLeaderboardOriginal(obj, key..table.concat(subPath))
        end
        restoreElement("TotalKills", LEADERBOARD_PATHS.TotalKills.TextLabel)
        restoreElement("TotalKills", LEADERBOARD_PATHS.TotalKills.ImageLabel1)
        restoreElement("TotalKills", LEADERBOARD_PATHS.TotalKills.ImageLabel2)
        restoreElement("TotalKillsReal", LEADERBOARD_PATHS.TotalKillsReal.TextLabel)
        restoreElement("TotalKillsReal", LEADERBOARD_PATHS.TotalKillsReal.ImageLabel1)
        restoreElement("TotalKillsReal", LEADERBOARD_PATHS.TotalKillsReal.ImageLabel2)
        restoreElement("DonationsLine1", LEADERBOARD_PATHS.DonationsLine1.TextLabel)
        restoreElement("DonationsLine1", LEADERBOARD_PATHS.DonationsLine1.ImageLabel1)
        restoreElement("DonationsLine1", LEADERBOARD_PATHS.DonationsLine1.ImageLabel2)
        restoreElement("DonationsLine2", LEADERBOARD_PATHS.DonationsLine2.TextLabel)
        restoreElement("DonationsLine2", LEADERBOARD_PATHS.DonationsLine2.ImageLabel1)
        restoreElement("DonationsLine2", LEADERBOARD_PATHS.DonationsLine2.ImageLabel2)
    end
end

function SPOOFER:EnableLeaderstatsSpoof()
    if not State then return end
    if not State.isLeaderstatsSpoofEnabled then
        State.isLeaderstatsSpoofEnabled = true
        StoreLeaderstatsOriginals()
        ApplyLeaderstatsSpoof()
    end
end

function SPOOFER:DisableLeaderstatsSpoof()
    if not State then return end
    if State.isLeaderstatsSpoofEnabled then
        State.isLeaderstatsSpoofEnabled = false
        RestoreLeaderstatsOriginals()
    end
end

function SPOOFER:UpdateSetting(pathString, value)
    if not Settings then return end
    local keys = {}
    for key in pathString:gmatch("[^%.]+") do table.insert(keys, key) end

    local currentTable = Settings
    local settingKey = keys[#keys]

    for i = 1, #keys - 1 do
        local key = keys[i]
        if not currentTable[key] or type(currentTable[key]) ~= "table" then
            return
        end
        currentTable = currentTable[key]
    end

    if currentTable[settingKey] == nil then return end

    local expectedType = type(currentTable[settingKey])
    local receivedType = type(value)

    if expectedType ~= receivedType and not(expectedType=="number" and receivedType=="number") and expectedType~="boolean" then return end
    if expectedType=="boolean" and receivedType~="boolean" then return end

    currentTable[settingKey] = value

    if State.isLeaderboardSpoofEnabled and keys[1] == "Leaderboards" then
        ApplyLeaderboardSpoof()
    elseif State.isLeaderstatsSpoofEnabled and keys[1] == "Leaderstats" then
        ApplyLeaderstatsSpoof()
    end
end

function SPOOFER:Destroy()
    Cleanup_Internal()
    _G.ExecutorSpoofer = nil
end

local function Initialize()
    if State.isInitialized then return true end

    pcall(FindLeaderstatsObjects)

    if SPOOFER.updateConnection and SPOOFER.updateConnection.Connected then SPOOFER.updateConnection:Disconnect() end
    if SPOOFER.focusLostConnection and SPOOFER.focusLostConnection.Connected then SPOOFER.focusLostConnection:Disconnect() end
    if SPOOFER.focusGainedConnection and SPOOFER.focusGainedConnection.Connected then SPOOFER.focusGainedConnection:Disconnect() end

    local sfc, rfc = pcall(function()
        SPOOFER.focusLostConnection = UserInputService.WindowFocusReleased:Connect(OnFocusLost)
        SPOOFER.focusGainedConnection = UserInputService.WindowFocused:Connect(OnFocusGained)
        SPOOFER.updateConnection = RunService.Heartbeat:Connect(OnHeartbeat)
    end)
    if not sfc then Cleanup_Internal(); return false; end

    State.isInitialized = true
    
    if State.isLeaderstatsSpoofEnabled then
        StoreLeaderstatsOriginals()
    end

    return true
end

Initialize()

return true