local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local math_rad = math.rad
local math_lerp = function(a, b, t) return a + (b - a) * t end

local LocalTiltData = {
    Settings = {
        Enabled = false,
        TiltAngle = 3, 
        Smoothness = 6 
    },
    CurrentTilt = 0,
    Connection = nil
}

_G.CameraTiltTest = LocalTiltData

local function UpdateTilt(deltaTime)
    local Data = LocalTiltData 
    
    if not Data or not Data.Settings then return end

    local Settings = Data.Settings
    
    if not Settings.Enabled then return end
    
    local PressingLeft = UserInputService:IsKeyDown(Enum.KeyCode.A)
    local PressingRight = UserInputService:IsKeyDown(Enum.KeyCode.D)
    
    local TargetAngle = 0
    
    if PressingLeft and not PressingRight then
        TargetAngle = Settings.TiltAngle
    elseif PressingRight and not PressingLeft then
        TargetAngle = -Settings.TiltAngle
    else
        TargetAngle = 0
    end
    
    local Step = math.min(deltaTime * Settings.Smoothness, 1)
    Data.CurrentTilt = math_lerp(Data.CurrentTilt, TargetAngle, Step)
    
    if math.abs(Data.CurrentTilt) > 0.01 then
        Camera.CFrame = Camera.CFrame * CFrame.Angles(0, 0, math_rad(Data.CurrentTilt))
    end
end

RunService:BindToRenderStep("CameraTiltEffect", Enum.RenderPriority.Camera.Value + 1, UpdateTilt)

LocalTiltData.Connection = {
    Disconnect = function() 
        pcall(function() RunService:UnbindFromRenderStep("CameraTiltEffect") end)
    end
}