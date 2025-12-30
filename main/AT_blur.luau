local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

_G.ExecutorAltTabBlur = _G.ExecutorAltTabBlur or {}
local ATB = _G.ExecutorAltTabBlur

ATB.Settings = ATB.Settings or {
    EnableAltTabBlur = false,
    AltTabBlurAmount = 16,
    AltTabTransitionSpeed = 8
}
local Settings = ATB.Settings

ATB.State = ATB.State or {
    isWindowFocused = true,
    currentAltTabBlurSize = 0
}
local State = ATB.State

ATB.AltTabBlurEffect = ATB.AltTabBlurEffect or nil
ATB.RenderStepConnection = ATB.RenderStepConnection or nil
ATB.FocusLostConnection = ATB.FocusLostConnection or nil
ATB.FocusGainedConnection = ATB.FocusGainedConnection or nil

local BASE_NAME = "ExecutorAltTabBlur_v1"
local ALTTAB_BLUR_NAME = BASE_NAME .. "_Effect"

local function Cleanup_Internal()
    if ATB.RenderStepConnection and ATB.RenderStepConnection.Connected then ATB.RenderStepConnection:Disconnect() end
    if ATB.FocusLostConnection and ATB.FocusLostConnection.Connected then ATB.FocusLostConnection:Disconnect() end
    if ATB.FocusGainedConnection and ATB.FocusGainedConnection.Connected then ATB.FocusGainedConnection:Disconnect() end
    ATB.RenderStepConnection, ATB.FocusLostConnection, ATB.FocusGainedConnection = nil, nil, nil
    local blurEff = Lighting:FindFirstChild(ALTTAB_BLUR_NAME); if blurEff then blurEff:Destroy() end
    ATB.AltTabBlurEffect = nil
end

local function lerp(a, b, t) return a + (b - a) * t end

local function UpdateEffects(deltaTime)
    if not ATB or not ATB.State or not ATB.Settings then return end
    local useAltTabBlur = Settings.EnableAltTabBlur and not State.isWindowFocused

    if ATB.AltTabBlurEffect then
        local targetAltTabSize = useAltTabBlur and Settings.AltTabBlurAmount or 0
        local speed = Settings.AltTabTransitionSpeed or 6; local alpha = math.min(deltaTime * speed, 1)
        State.currentAltTabBlurSize = lerp(State.currentAltTabBlurSize, targetAltTabSize, alpha)
        ATB.AltTabBlurEffect.Size = math.clamp(State.currentAltTabBlurSize, 0, Settings.AltTabBlurAmount or 24)
        ATB.AltTabBlurEffect.Enabled = State.currentAltTabBlurSize > 0.1
    end
end

local function OnFocusLost() if ATB and ATB.State then State.isWindowFocused = false end end
local function OnFocusGained() if ATB and ATB.State then State.isWindowFocused = true end end

local function InitializeAltTabBlur()
    if ATB.AltTabBlurEffect and ATB.AltTabBlurEffect.Parent then return true end
    Cleanup_Internal()

    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(0.5)

    local success, effect = pcall(function()
        local blur = Instance.new("BlurEffect")
        blur.Name = ALTTAB_BLUR_NAME
        blur.Size = 0
        blur.Enabled = false
        blur.Parent = Lighting
        return blur
    end)

    if not success or not effect then
        Cleanup_Internal(); return false
    end

    ATB.AltTabBlurEffect = effect

    if ATB.RenderStepConnection and ATB.RenderStepConnection.Connected then ATB.RenderStepConnection:Disconnect() end
    if ATB.FocusLostConnection and ATB.FocusLostConnection.Connected then ATB.FocusLostConnection:Disconnect() end
    if ATB.FocusGainedConnection and ATB.FocusGainedConnection.Connected then ATB.FocusGainedConnection:Disconnect() end

    local sfc, rfc = pcall(function()
        ATB.FocusLostConnection = UserInputService.WindowFocusReleased:Connect(OnFocusLost)
        ATB.FocusGainedConnection = UserInputService.WindowFocused:Connect(OnFocusGained)
        ATB.RenderStepConnection = RunService.RenderStepped:Connect(UpdateEffects)
    end)
    if not sfc then Cleanup_Internal(); return false; end

    return true
end

function ATB:UpdateSetting(settingName, value)
    if not ATB or not Settings or Settings[settingName] == nil then return end
    local expectedType=type(Settings[settingName]); local receivedType=type(value)
    if expectedType~=receivedType and not(expectedType=="number" and receivedType=="number") and expectedType~="boolean" then return end
    if expectedType=="boolean" and receivedType~="boolean" then return end

    Settings[settingName] = value
end

function ATB:Destroy()
    Cleanup_Internal()
    _G.ExecutorAltTabBlur = nil
end

if InitializeAltTabBlur() then

else
    _G.ExecutorAltTabBlur = nil
end

return true