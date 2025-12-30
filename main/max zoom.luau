local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

if not game:IsLoaded() then game.Loaded:Wait() end

if _G.ExecutorZoom_Instance and _G.ExecutorZoom_Instance.Destroy then
    pcall(function() _G.ExecutorZoom_Instance:Destroy() end)
end

_G.ExecutorZoom = _G.ExecutorZoom or {}
local Zoom = _G.ExecutorZoom

Zoom.Settings = Zoom.Settings or {
    Enabled = false,
    MaxDistance = 10000 
}
local Settings = Zoom.Settings

Zoom.State = Zoom.State or {
    connection = nil,
    defaultDist = 128 
}
local State = Zoom.State

local function UpdateZoom()
    if not Settings.Enabled then return end
    
    if LocalPlayer then
        pcall(function()
            LocalPlayer.CameraMaxZoomDistance = Settings.MaxDistance
        end)
    end
end

local function StartLoop()
    if State.connection then return end
    
    if LocalPlayer then
        State.defaultDist = LocalPlayer.CameraMaxZoomDistance
    end

    State.connection = RunService.RenderStepped:Connect(UpdateZoom)
end


function Zoom:Enable()
    Settings.Enabled = true
    StartLoop()
end

function Zoom:Disable()
    Settings.Enabled = false
    
    if State.connection then
        State.connection:Disconnect()
        State.connection = nil
    end

    if LocalPlayer then
        pcall(function()
            LocalPlayer.CameraMaxZoomDistance = State.defaultDist
        end)
    end
end

function Zoom:UpdateSetting(name, value)
    if Settings[name] == nil then return end
    
    if name == "MaxDistance" and type(value) == "number" then
        Settings.MaxDistance = value
    elseif name == "Enabled" and type(value) == "boolean" then
        if value then Zoom:Enable() else Zoom:Disable() end
    end
end

function Zoom:Destroy()
    Zoom:Disable()
    _G.ExecutorZoom = nil
    _G.ExecutorZoom_Instance = nil
end

_G.ExecutorZoom_Instance = Zoom

if Settings.Enabled then
    Zoom:Enable()
end

return true