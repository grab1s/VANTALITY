if _G.FOV_SCRIPT_INSTANCE and typeof(_G.FOV_SCRIPT_INSTANCE.Cleanup) == "function" then
    _G.FOV_SCRIPT_INSTANCE:Cleanup()
    task.wait(0.1)
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not Camera then return end

local isEnabled = false
local baseFov = 75
local originalFov = Camera.FieldOfView
local isOriginalFovCaptured = false
local updateConnection = nil
local SPEED_THRESHOLD_START = 18
local SPEED_THRESHOLD_MAX = 60

local dynamicSettings = {
    SpeedFovBoost = 18,
    TransitionSpeed = 6,
    isDynamicSpeedEnabled = false
}

local currentFovOffset = 0
local currentAppliedFov = baseFov

local FovController = {}

local function lerp(a, b, t) return a + (b - a) * t end

local function updateFov(deltaTime)
    if not Camera then return end
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local targetFovOffset = 0

    if isEnabled and dynamicSettings.isDynamicSpeedEnabled and hrp then
        local speed = hrp.Velocity.Magnitude
        local speedRange = SPEED_THRESHOLD_MAX - SPEED_THRESHOLD_START
        local speedRatio = 0
        if speedRange > 0 then speedRatio = math.clamp((speed - SPEED_THRESHOLD_START) / speedRange, 0, 1)
        elseif speed > SPEED_THRESHOLD_START then speedRatio = 1 end
        targetFovOffset = speedRatio * dynamicSettings.SpeedFovBoost
    end

    currentFovOffset = lerp(currentFovOffset, targetFovOffset, math.min(deltaTime * dynamicSettings.TransitionSpeed, 1))
    local finalFov = baseFov + currentFovOffset

    if isEnabled and math.abs(Camera.FieldOfView - finalFov) > 0.1 then
         currentAppliedFov = lerp(Camera.FieldOfView, finalFov, math.min(deltaTime * dynamicSettings.TransitionSpeed * 2, 1))
         pcall(function() Camera.FieldOfView = currentAppliedFov end)
    elseif not isEnabled and isOriginalFovCaptured and math.abs(Camera.FieldOfView - originalFov) > 0.1 then
         currentAppliedFov = lerp(Camera.FieldOfView, originalFov, math.min(deltaTime * dynamicSettings.TransitionSpeed, 1))
         pcall(function() Camera.FieldOfView = currentAppliedFov end)
    end
end

function FovController:enable()
    if isEnabled then return end;
    if not isOriginalFovCaptured then originalFov = Camera.FieldOfView; isOriginalFovCaptured = true; end
    isEnabled = true; currentAppliedFov = Camera.FieldOfView
    if not updateConnection then updateConnection = RunService.RenderStepped:Connect(updateFov); end
end

function FovController:disable()
    if not isEnabled then return end;
    isEnabled = false;
end

function FovController:setBase(value)
    local numValue = tonumber(value)
    if not numValue then return end
    numValue = math.max(60, numValue)
    if baseFov ~= numValue then
        baseFov = numValue
    end
end

function FovController:setDynamicSpeedEnabled(enabled)
    if typeof(enabled) ~= "boolean" then return end
    if dynamicSettings.isDynamicSpeedEnabled ~= enabled then
        dynamicSettings.isDynamicSpeedEnabled = enabled
        if not enabled then currentFovOffset = 0 end
    end
end

function FovController:updateSetting(settingName, value)
    if dynamicSettings[settingName] == nil then return end
    if settingName ~= "SpeedFovBoost" and settingName ~= "TransitionSpeed" then return end
    local numValue = tonumber(value)
    if not numValue then return end
    if settingName == "TransitionSpeed" then numValue = math.max(1, numValue) end
    if settingName == "SpeedFovBoost" then numValue = math.max(0, numValue) end
    dynamicSettings[settingName] = numValue
end

local cleanupFunction = function()
    isEnabled = false
    if updateConnection then updateConnection:Disconnect(); updateConnection = nil; end
    if isOriginalFovCaptured and Camera then pcall(function() Camera.FieldOfView = originalFov end); end
    if _G.FOV == FovController then _G.FOV = nil end
    _G.FOV_SCRIPT_INSTANCE = nil
end

_G.FOV = FovController
_G.FOV_SCRIPT_INSTANCE = { Cleanup = cleanupFunction }

if not updateConnection then updateConnection = RunService.RenderStepped:Connect(updateFov) end