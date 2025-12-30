local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

_G.ExecutorVHS_v3 = _G.ExecutorVHS_v3 or {}
local VHS = _G.ExecutorVHS_v3

local VIGNETTE_ASSET_ID = "rbxassetid://4576475446"

VHS.Settings = VHS.Settings or {
    EnableColorCorrection = true,
    EnableVignette = true,
    Brightness = 0,
    Saturation = 0,
    Contrast = 0,
    TintColor = Color3.fromRGB(255, 255, 255),
    VignetteIntensity = 0.5
}
local Settings = VHS.Settings

VHS.State = VHS.State or {
    isEnabled = false,
    originalLighting = nil
}
local State = VHS.State

VHS.ColorCorrectEffect = VHS.ColorCorrectEffect or nil
VHS.VignetteScreenGui = VHS.VignetteScreenGui or nil
VHS.VignetteImage = VHS.VignetteImage or nil

local BASE_NAME = "ExecutorVHS_v3_2_NoBloom"
local CC_NAME = BASE_NAME .. "_ColorCorrect"
local VIGNETTE_GUI_NAME = BASE_NAME .. "_VignetteGui"

local function StoreOriginalSettings()
    if State.originalLighting then return end
    local gameCC = Lighting:FindFirstChild("ColorCorrection")
    State.originalLighting = {
        Brightness = Lighting.Brightness,
        Saturation = (gameCC and gameCC:IsA("ColorCorrectionEffect")) and gameCC.Saturation or 0,
        Contrast = (gameCC and gameCC:IsA("ColorCorrectionEffect")) and gameCC.Contrast or 0,
        TintColor = (gameCC and gameCC:IsA("ColorCorrectionEffect")) and gameCC.TintColor or Color3.fromRGB(255,255,255)
    }
end

local function RestoreOriginalSettings()
    if not State.originalLighting then return end
    local original = State.originalLighting
    pcall(function()
        Lighting.Brightness = original.Brightness
        local ourCC = Lighting:FindFirstChild(CC_NAME)
        if ourCC then ourCC:Destroy() end
        local gameCC = Lighting:FindFirstChild("ColorCorrection")
        if gameCC and gameCC:IsA("ColorCorrectionEffect") then
            gameCC.Saturation = original.Saturation
            gameCC.Contrast = original.Contrast
            gameCC.TintColor = original.TintColor
        elseif not gameCC and (original.Saturation ~= 0 or original.Contrast ~= 0 or original.TintColor ~= Color3.fromRGB(255,255,255)) then
            gameCC = Instance.new("ColorCorrectionEffect")
            gameCC.Name = "ColorCorrection"
            gameCC.Saturation = original.Saturation
            gameCC.Contrast = original.Contrast
            gameCC.TintColor = original.TintColor
            gameCC.Parent = Lighting
        end
    end)
    State.originalLighting = nil
end

local function ApplyVHSEffects()
    if not State.isEnabled then
        if VHS.ColorCorrectEffect then VHS.ColorCorrectEffect.Enabled = false end
        if VHS.VignetteScreenGui then VHS.VignetteScreenGui.Enabled = false end
        return
    end

    if VHS.ColorCorrectEffect then
        VHS.ColorCorrectEffect.Enabled = Settings.EnableColorCorrection
        if Settings.EnableColorCorrection then
            VHS.ColorCorrectEffect.Brightness = Settings.Brightness
            VHS.ColorCorrectEffect.Saturation = Settings.Saturation
            VHS.ColorCorrectEffect.Contrast = Settings.Contrast
            VHS.ColorCorrectEffect.TintColor = Settings.TintColor
        end
    end

    if VHS.VignetteScreenGui and VHS.VignetteImage then
        VHS.VignetteScreenGui.Enabled = Settings.EnableVignette
        if Settings.EnableVignette then
            VHS.VignetteImage.ImageTransparency = 1 - Settings.VignetteIntensity
        end
    end
end

local function Cleanup_Internal()
    RestoreOriginalSettings()
    local cc = Lighting:FindFirstChild(CC_NAME); if cc then cc:Destroy() end
    local playerGui = Player and Player:FindFirstChild("PlayerGui")
    local vGui = playerGui and playerGui:FindFirstChild(VIGNETTE_GUI_NAME); if vGui then vGui:Destroy() end
    VHS.ColorCorrectEffect, VHS.VignetteScreenGui, VHS.VignetteImage = nil, nil, nil
end

local function InitializeVHS()
    if VHS.ColorCorrectEffect and VHS.VignetteScreenGui then return true end
    Cleanup_Internal()

    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(0.5)
    local playerGui = Player and Player:FindFirstChild("PlayerGui")
    if not playerGui then return false end

    StoreOriginalSettings()
    local allGood = true

    local oldOurCC = Lighting:FindFirstChild(CC_NAME); if oldOurCC then oldOurCC:Destroy() end
    local s_cc, e_cc = pcall(function() VHS.ColorCorrectEffect = Instance.new("ColorCorrectionEffect"); VHS.ColorCorrectEffect.Name = CC_NAME; VHS.ColorCorrectEffect.Parent = Lighting end)
    if not s_cc then warn(BASE_NAME..": Fail ColorCorrection", e_cc); allGood = false end

    VHS.VignetteScreenGui = playerGui:FindFirstChild(VIGNETTE_GUI_NAME)
    if VHS.VignetteScreenGui and not VHS.VignetteScreenGui:IsA("ScreenGui") then VHS.VignetteScreenGui:Destroy(); VHS.VignetteScreenGui = nil end
    if not VHS.VignetteScreenGui then
        VHS.VignetteScreenGui = Instance.new("ScreenGui"); VHS.VignetteScreenGui.Name = VIGNETTE_GUI_NAME; VHS.VignetteScreenGui.ResetOnSpawn = false; VHS.VignetteScreenGui.IgnoreGuiInset = true; VHS.VignetteScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; VHS.VignetteScreenGui.DisplayOrder = 100; VHS.VignetteScreenGui.Parent = playerGui;
        VHS.VignetteImage = Instance.new("ImageLabel"); VHS.VignetteImage.Name = "VignetteOverlay"; VHS.VignetteImage.Size = UDim2.new(1,0,1,0); VHS.VignetteImage.BackgroundTransparency=1; VHS.VignetteImage.Image=VIGNETTE_ASSET_ID; VHS.VignetteImage.ScaleType=Enum.ScaleType.Stretch; VHS.VignetteImage.ZIndex = 1; VHS.VignetteImage.Parent = VHS.VignetteScreenGui;
    else
        VHS.VignetteImage = VHS.VignetteScreenGui:FindFirstChild("VignetteOverlay")
    end
    if not VHS.VignetteImage then warn(BASE_NAME..": Fail Vignette Image"); allGood = false end

    if not allGood then Cleanup_Internal(); return false end
    
    ApplyVHSEffects()

    
    return true
end

function VHS:Enable()
    if not State then return end
    if not VHS.ColorCorrectEffect or not VHS.VignetteScreenGui then if not InitializeVHS() then return end end
    State.isEnabled = true
    ApplyVHSEffects()
end

function VHS:Disable()
    if not State then return end
    State.isEnabled = false
    ApplyVHSEffects()
end

function VHS:UpdateSetting(settingName, value)
    if not Settings or Settings[settingName] == nil then return end
    local expectedType=type(Settings[settingName]); local receivedType=type(value)
    if expectedType~=receivedType and not(expectedType=="number" and receivedType=="number") and expectedType~="Color3" and expectedType~="boolean" then return end
    if expectedType=="Color3" and receivedType~="Color3" then return end
    if expectedType=="boolean" and receivedType~="boolean" then return end
    Settings[settingName] = value
    
    if State.isEnabled then ApplyVHSEffects() end
end

function VHS:Destroy()
    Cleanup_Internal()
    _G.ExecutorVHS_v3 = nil
end

if InitializeVHS() then
else
    warn(BASE_NAME .. ": Инициализация VHS v3.2 не удалась.")
    _G.ExecutorVHS_v3 = nil
end

return true