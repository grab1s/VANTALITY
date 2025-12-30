local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

_G.ExecutorSimulatedMB_CamOnly = _G.ExecutorSimulatedMB_CamOnly or {}
local MB = _G.ExecutorSimulatedMB_CamOnly

MB.Settings = MB.Settings or {
    MaxBlurSize = 18,
    CamRotationThresholdStart = 0.006,
    CamRotationThresholdMax = 0.18,
    TransitionSpeed = 16
}
local Settings = MB.Settings

MB.State = MB.State or {
    isEnabled = false,
    isWindowFocused = true,
    currentBlurSize = 0,
    lastCameraCFrame = Camera.CFrame
}
local State = MB.State

local SIM_MB_EFFECT_NAME = "ExecutorSimulatedMB_CamOnly_Blur_v3"

if MB.BlurEffect and not MB.BlurEffect.Parent then MB.BlurEffect = nil end

if not MB.BlurEffect then
    MB.BlurEffect = Lighting:FindFirstChild(SIM_MB_EFFECT_NAME)
    if MB.BlurEffect and not MB.BlurEffect:IsA("BlurEffect") then
        MB.BlurEffect:Destroy(); MB.BlurEffect = nil
    end
    if not MB.BlurEffect then
        local success, effect = pcall(function() return Instance.new("BlurEffect") end)
        if success and effect then
            MB.BlurEffect = effect
            MB.BlurEffect.Name = SIM_MB_EFFECT_NAME
            MB.BlurEffect.Size = 0
            MB.BlurEffect.Enabled = false
            MB.BlurEffect.Parent = Lighting
        else
            if MB.Destroy then MB.Destroy() else _G.ExecutorSimulatedMB_CamOnly = nil end
            return
        end
    else
        MB.BlurEffect.Size = 0
        MB.BlurEffect.Enabled = State.isEnabled
    end
else
     MB.BlurEffect.Size = State.currentBlurSize
     MB.BlurEffect.Enabled = State.isEnabled
end

local function lerp(a, b, t) return a + (b - a) * t end

local function UpdateSimulatedMB(deltaTime)
    if not MB.BlurEffect or not MB.BlurEffect.Parent or not Player then
        if MB.Destroy then pcall(MB.Destroy) end
        return
    end

    local targetBlurSize = 0

    if State.isEnabled and State.isWindowFocused then
        local camAngularVelocity = 0

        local currentCameraCFrame = Camera.CFrame
        if currentCameraCFrame ~= State.lastCameraCFrame then
             local success, rotationDelta = pcall(function() return State.lastCameraCFrame:ToObjectSpace(currentCameraCFrame) end)
             if success and rotationDelta then
                  local axis, angle = rotationDelta:ToAxisAngle()
                  camAngularVelocity = math.abs(angle)
             end
             State.lastCameraCFrame = currentCameraCFrame
        else
             camAngularVelocity = 0
        end

        local camBlurRatio = 0
        local camRotRange = Settings.CamRotationThresholdMax - Settings.CamRotationThresholdStart
        if camRotRange <= 0.0001 then camRotRange = 0.0001 end
        camBlurRatio = math.clamp((camAngularVelocity - Settings.CamRotationThresholdStart) / camRotRange, 0, 1)

        targetBlurSize = camBlurRatio * (Settings.MaxBlurSize or 0)

    else
        targetBlurSize = 0
    end

    local speed = Settings.TransitionSpeed or 8
    local alpha = math.min(deltaTime * speed, 1)
    State.currentBlurSize = lerp(State.currentBlurSize, targetBlurSize, alpha)

    MB.BlurEffect.Size = math.clamp(State.currentBlurSize, 0, Settings.MaxBlurSize or 24)
    MB.BlurEffect.Enabled = State.isEnabled and State.isWindowFocused and State.currentBlurSize > 0.1

end

local function OnFocusLost() State.isWindowFocused = false end
local function OnFocusGained() State.isWindowFocused = true end

local function ConnectEvents()
    if MB.RenderStepConnection and MB.RenderStepConnection.Connected then MB.RenderStepConnection:Disconnect() end
    if MB.FocusLostConnection and MB.FocusLostConnection.Connected then MB.FocusLostConnection:Disconnect() end
    if MB.FocusGainedConnection and MB.FocusGainedConnection.Connected then MB.FocusGainedConnection:Disconnect() end

    MB.RenderStepConnection = RunService.RenderStepped:Connect(UpdateSimulatedMB)
    MB.FocusLostConnection = UserInputService.WindowFocusReleased:Connect(OnFocusLost)
    MB.FocusGainedConnection = UserInputService.WindowFocused:Connect(OnFocusGained)
end

function MB:Enable()
    if not State.isEnabled then
        State.isEnabled = true
    end
end

function MB:Disable()
    if State.isEnabled then
        State.isEnabled = false
        if MB.BlurEffect and MB.BlurEffect.Parent then
            MB.BlurEffect.Enabled = false
            MB.BlurEffect.Size = 0
            State.currentBlurSize = 0
        end
    end
end

function MB:UpdateSetting(settingName, value)
    if Settings[settingName] ~= nil then
        if type(value) == "number" then
             Settings[settingName] = value
             if settingName == "CamRotationThresholdStart" and Settings.CamRotationThresholdMax and value >= Settings.CamRotationThresholdMax then
                 -- Removed warn
             elseif settingName == "CamRotationThresholdMax" and Settings.CamRotationThresholdStart and value <= Settings.CamRotationThresholdStart then
                  -- Removed warn
             end
        else
            -- Removed warn
        end
    else
         -- Removed warn
    end
end

function MB:Destroy()
    if MB.RenderStepConnection and MB.RenderStepConnection.Connected then MB.RenderStepConnection:Disconnect() end
    if MB.FocusLostConnection and MB.FocusLostConnection.Connected then MB.FocusLostConnection:Disconnect() end
    if MB.FocusGainedConnection and MB.FocusGainedConnection.Connected then MB.FocusGainedConnection:Disconnect() end
    MB.RenderStepConnection, MB.FocusLostConnection, MB.FocusGainedConnection = nil, nil, nil
    if MB.BlurEffect and MB.BlurEffect.Parent then MB.BlurEffect:Destroy() end
    MB.BlurEffect = nil
    _G.ExecutorSimulatedMB_CamOnly = nil
end

if MB.BlurEffect then
    if MB.RenderStepConnection == nil or not MB.RenderStepConnection.Connected then
        ConnectEvents()
        UpdateSimulatedMB(1/60)
    else
        -- Removed print
    end
else
    _G.ExecutorSimulatedMB_CamOnly = nil
end