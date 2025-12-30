local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

if _G.ExecutorScreenStretch_Instance and typeof(_G.ExecutorScreenStretch_Instance.Destroy) == "function" then
    pcall(_G.ExecutorScreenStretch_Instance.Destroy)
    task.wait(0.1)
end
_G.ExecutorScreenStretch_Instance = nil

_G.ExecutorScreenStretch = _G.ExecutorScreenStretch or {}
local SS = _G.ExecutorScreenStretch
local BASE_NAME = "ExecutorScreenStretch"
local BIND_NAME = "Fix_ScreenStretch_Update" 

SS.Settings = SS.Settings or {
    StretchFactor = 0.75,
    AutoDisableInCutscenes = true 
}
local Settings = SS.Settings

SS.State = SS.State or {
    isEnabled = false,
    isBound = false
}
local State = SS.State


local function UpdateCamera()
    if not Camera or Camera.Parent == nil then
        Camera = workspace.CurrentCamera
        return
    end

    if Settings.StretchFactor == 1 then return end

    if Settings.AutoDisableInCutscenes and Camera.CameraType == Enum.CameraType.Scriptable then
        return
    end

    
    local cf = Camera.CFrame
    
    Camera.CFrame = cf * CFrame.new(0, 0, 0, 1, 0, 0, 0, Settings.StretchFactor, 0, 0, 0, 1)
end

function SS:Enable()
    Settings.StretchFactor = math.clamp(Settings.StretchFactor, 0.1, 1.0) 
    State.isEnabled = true
    
    if not State.isBound then
        RunService:BindToRenderStep(
            BIND_NAME,
            Enum.RenderPriority.Camera.Value + 1, 
            UpdateCamera
        )
        State.isBound = true
    end
end

function SS:Disable()
    State.isEnabled = false
    if State.isBound then
        RunService:UnbindFromRenderStep(BIND_NAME)
        State.isBound = false
    end
end

function SS:UpdateSetting(settingName, value)
    if Settings[settingName] == nil then return end

    if settingName == "StretchFactor" then
        if type(value) == "number" then
            Settings.StretchFactor = math.clamp(value, 0.1, 1.5) 
        end
    elseif settingName == "AutoDisableInCutscenes" then
        if type(value) == "boolean" then
            Settings.AutoDisableInCutscenes = value
        end
    end
end

function SS:Destroy()
    SS:Disable()
    _G.ExecutorScreenStretch = nil
    _G.ExecutorScreenStretch_Instance = nil
end

_G.ExecutorScreenStretch_Instance = SS

if State.isEnabled then
    SS:Enable()
end

return true