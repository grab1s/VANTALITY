local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

_G.ExecutorAtmosphere = _G.ExecutorAtmosphere or {}
local ATM = _G.ExecutorAtmosphere

ATM.Settings = ATM.Settings or {
    Density = 0.3,
    Offset = 0.5,
    Haze = 0,
    Glare = 0,
    Color = Color3.fromRGB(255, 255, 255)
}

ATM.State = {
    Enabled = false,
    Connection = nil
}

local function ForceUpdateLoop()
    local targetAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

    if not targetAtmosphere then
        targetAtmosphere = Instance.new("Atmosphere")
        targetAtmosphere.Name = "ExecutorAtmosphere_Created"
        targetAtmosphere.Parent = Lighting
    end

    targetAtmosphere.Density = ATM.Settings.Density
    targetAtmosphere.Offset = ATM.Settings.Offset
    targetAtmosphere.Haze = ATM.Settings.Haze
    targetAtmosphere.Glare = ATM.Settings.Glare
    targetAtmosphere.Color = ATM.Settings.Color
    targetAtmosphere.Decay = ATM.Settings.Color
end

function ATM:Enable()
    ATM.State.Enabled = true
    
    if not ATM.State.Connection then
        ATM.State.Connection = RunService.RenderStepped:Connect(ForceUpdateLoop)
    end
end

function ATM:Disable()
    ATM.State.Enabled = false
    
    if ATM.State.Connection then
        ATM.State.Connection:Disconnect()
        ATM.State.Connection = nil
    end

    local targetAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if targetAtmosphere then
        targetAtmosphere.Density = 0 
    end
end

function ATM:UpdateSetting(settingName, value)
    if ATM.Settings[settingName] ~= nil then
        if settingName == "Color" and typeof(value) ~= "Color3" then return end
        
        ATM.Settings[settingName] = value
    end
end

function ATM:Destroy()
    ATM:Disable()
    _G.ExecutorAtmosphere = nil
end

return true