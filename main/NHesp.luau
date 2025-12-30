local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

if _G.ExecutorNameHealthESP_Instance and typeof(_G.ExecutorNameHealthESP_Instance.Destroy) == "function" then
    pcall(_G.ExecutorNameHealthESP_Instance.Destroy)
    task.wait(0.1)
end
_G.ExecutorNameHealthESP_Instance = nil

_G.ExecutorNameHealthESP = _G.ExecutorNameHealthESP or {}
local NH_ESP = _G.ExecutorNameHealthESP
local BASE_NAME = "ExecutorNameHealthESP_v2_4_CustomDisable"

NH_ESP.Settings = NH_ESP.Settings or {
    RenderDistance = 200,        
    ShowNameThroughWalls = true, 
    AlwaysShowHealthBar = true  
}
local Settings = NH_ESP.Settings

NH_ESP.State = NH_ESP.State or {
    isEnabled = false,
    isInitialized = false, 
    playerConnections = {} 
}
local State = NH_ESP.State

local ENUM_VALUES = {
    NameOcclusion_NoOcclusion = 0,
    NameOcclusion_OccludeAll = 1,
    HealthDisplayType_AlwaysOn = 0,
    HealthDisplayType_DisplayWhenDamaged = 2,
    HealthDisplayType_HoverOver = 1,
    HealthDisplayType_AlwaysOff = 3
}

local DISABLED_STATE_CONFIG = {
    NameDisplayDistance = 80, 
    NameOcclusion = ENUM_VALUES.NameOcclusion_OccludeAll, 
    HealthDisplayDistance = 80, 
    HealthDisplayType = ENUM_VALUES.HealthDisplayType_AlwaysOn 
}

local function IsPlayerValid(player)
    if not player or player == LocalPlayer or not player.Character or
       not player.Character:FindFirstChildOfClass("Humanoid") then
        return false
    end
    return true
end

local function ApplyToHumanoid(humanoid, configToApply, isEnabling)
    if not humanoid or not humanoid.Parent then return end
    
    local nameOcc, healthDispType

    if isEnabling then 
        nameOcc = Settings.ShowNameThroughWalls and ENUM_VALUES.NameOcclusion_NoOcclusion or ENUM_VALUES.NameOcclusion_OccludeAll
        healthDispType = Settings.AlwaysShowHealthBar and ENUM_VALUES.HealthDisplayType_AlwaysOn or ENUM_VALUES.HealthDisplayType_DisplayWhenDamaged
        humanoid.NameDisplayDistance = Settings.RenderDistance
        humanoid.HealthDisplayDistance = Settings.RenderDistance
    else 
        nameOcc = configToApply.NameOcclusion
        healthDispType = configToApply.HealthDisplayType
        humanoid.NameDisplayDistance = configToApply.NameDisplayDistance
        humanoid.HealthDisplayDistance = configToApply.HealthDisplayDistance
    end

    local s1,e1 = pcall(function() humanoid.NameOcclusion = nameOcc end)
    if not s1 then warn(BASE_NAME, ": Error setting NameOcclusion:", e1, "Value was:", nameOcc) end
    
    local s2,e2 = pcall(function() humanoid.HealthDisplayType = healthDispType end)
    if not s2 then warn(BASE_NAME, ": Error setting HealthDisplayType:", e2, "Value was:", healthDispType) end
        
    if isEnabling then 
        humanoid.Health = humanoid.Health 
    end
end

local function ProcessPlayerCharacter(player)
    if not IsPlayerValid(player) then return end
    local humanoid = player.Character.Humanoid
    if State.isEnabled then
        ApplyToHumanoid(humanoid, Settings, true)
    else
        ApplyToHumanoid(humanoid, DISABLED_STATE_CONFIG, false)
    end
end

local function OnCharacterAddedForPlayer(player)
    task.wait(0.33) 
    ProcessPlayerCharacter(player)
end

local function SetupPlayerConnections(player)
    if not IsPlayerValid(player) then return end
    if State.playerConnections[player] then return end 

    if player.Character then ProcessPlayerCharacter(player) end
    
    local charAddedConn = player.CharacterAdded:Connect(function() OnCharacterAddedForPlayer(player) end)
    State.playerConnections[player] = { CharacterAdded = charAddedConn }
end

local function CleanupPlayerConnections(player, applyDisabledSettings)
    if applyDisabledSettings and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        ApplyToHumanoid(player.Character.Humanoid, DISABLED_STATE_CONFIG, false)
    end
    local conns = State.playerConnections[player]
    if conns then
        if conns.CharacterAdded then conns.CharacterAdded:Disconnect() end
        State.playerConnections[player] = nil
    end
end

function NH_ESP:Enable()
    if State.isEnabled and State.isInitialized then return end
    State.isEnabled = true
    if not State.isInitialized then
        State.playerAddedGlobalConn = Players.PlayerAdded:Connect(SetupPlayerConnections)
        State.playerRemovingGlobalConn = Players.PlayerRemoving:Connect(function(p) CleanupPlayerConnections(p, false) end)
        State.isInitialized = true
    end
    for _, player in ipairs(Players:GetPlayers()) do SetupPlayerConnections(player) end
end

function NH_ESP:Disable()
    if not State.isEnabled then return end
    State.isEnabled = false
    for _, player in ipairs(Players:GetPlayers()) do
        if IsPlayerValid(player) then
            ApplyToHumanoid(player.Character.Humanoid, DISABLED_STATE_CONFIG, false)
        end
    end
end

function NH_ESP:UpdateSetting(settingName, value)
    if Settings[settingName] == nil then warn(BASE_NAME .. ": Попытка обновить неизвестную настройку:", settingName); return end
    Settings[settingName] = value
    if State.isEnabled then 
        for _, player in ipairs(Players:GetPlayers()) do if IsPlayerValid(player) then ApplyToHumanoid(player.Character.Humanoid, Settings, true) end end
    end
end

function NH_ESP:Destroy()
    local wasEnabled = State.isEnabled
    State.isEnabled = false 

    if State.playerAddedGlobalConn and State.playerAddedGlobalConn.Connected then State.playerAddedGlobalConn:Disconnect(); State.playerAddedGlobalConn = nil end
    if State.playerRemovingGlobalConn and State.playerRemovingGlobalConn.Connected then State.playerRemovingGlobalConn:Disconnect(); State.playerRemovingGlobalConn = nil end
    
    for player, _ in pairs(State.playerConnections) do
        CleanupPlayerConnections(player, wasEnabled) 
    end
    State.playerConnections = {}
    State.isInitialized = false
    
    _G.ExecutorNameHealthESP = nil
    _G.ExecutorNameHealthESP_Instance = nil
end

_G.ExecutorNameHealthESP_Instance = NH_ESP