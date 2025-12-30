local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")

local localPlayer = Players.LocalPlayer
if not localPlayer then return end

if _G.ExecutorFPS and _G.ExecutorFPS.Destroy then _G.ExecutorFPS:Destroy() _G.ExecutorFPS = nil end

local oldInstance = _G.ExecutorOverlay
local savedSettings = nil

if oldInstance then
    if oldInstance.Settings then savedSettings = oldInstance.Settings end
    if oldInstance.Destroy then oldInstance:Destroy() end
    _G.ExecutorOverlay = nil
end

if not game:IsLoaded() then game.Loaded:Wait() end

_G.ExecutorOverlay = {}
local Overlay = _G.ExecutorOverlay

Overlay.Settings = savedSettings or {
    Enabled = false,
    ShowFPS = true,
    ShowPing = false,
    Position = "TopLeft", 
    Scale = 24,
    TextColor = Color3.fromRGB(255, 255, 255)
}
local Settings = Overlay.Settings

Overlay.State = {
    isEnabled = false,
    frameCount = 0,
    lastTime = 0,
    guiObject = nil,
    container = nil,
    fpsLabel = nil,
    pingLabel = nil,
    renderConnection = nil
}
local State = Overlay.State

local GUI_NAME = "Executor_Overlay_Stats"

local POSITION_PRESETS = {
    TopLeft = { 
        AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0, 15, 0, 68), 
        TextAlign = Enum.TextXAlignment.Left, ListAlign = Enum.HorizontalAlignment.Left, VertAlign = Enum.VerticalAlignment.Top 
    },
    TopRight = { 
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -15, 0, 68), 
        TextAlign = Enum.TextXAlignment.Right, ListAlign = Enum.HorizontalAlignment.Right, VertAlign = Enum.VerticalAlignment.Top 
    },
    BottomLeft = { 
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 15, 1, -15), 
        TextAlign = Enum.TextXAlignment.Left, ListAlign = Enum.HorizontalAlignment.Left, VertAlign = Enum.VerticalAlignment.Bottom 
    },
    BottomRight = { 
        AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -15, 1, -15), 
        TextAlign = Enum.TextXAlignment.Right, ListAlign = Enum.HorizontalAlignment.Right, VertAlign = Enum.VerticalAlignment.Bottom 
    }
}

local function GetBestParent()
    local s, r = pcall(function() return gethui() end)
    if s and r then return r end
    local s2, r2 = pcall(function() return game:GetService("CoreGui") end)
    if s2 and r2 then return r2 end
    return localPlayer:WaitForChild("PlayerGui", 5)
end

local function Cleanup_Internal()
    if State.renderConnection then State.renderConnection:Disconnect() end
    State.renderConnection = nil
    
    if State.guiObject then State.guiObject:Destroy() end
    State.guiObject = nil
    State.container = nil
    State.fpsLabel = nil
    State.pingLabel = nil
    
    local parent = GetBestParent()
    if parent then
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name == GUI_NAME then child:Destroy() end
        end
    end
end

local function CreateLabel(name, parent)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Size = UDim2.new(0, 0, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.XY
    label.Font = Enum.Font.GothamBold
    label.Text = "Waiting..."
    label.Active = false
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Parent = parent
    return label
end

local function UpdateVisuals()
    if not State.container then return end
    
    local posData = POSITION_PRESETS[Settings.Position] or POSITION_PRESETS.TopLeft
    
    State.container.AnchorPoint = posData.AnchorPoint
    State.container.Position = posData.Position
    
    local layout = State.container:FindFirstChildOfClass("UIListLayout")
    if layout then
        layout.HorizontalAlignment = posData.ListAlign
        layout.VerticalAlignment = posData.VertAlign
    end

    local function UpdateLabelStyle(lbl)
        if lbl then
            lbl.TextSize = Settings.Scale
            lbl.TextColor3 = Settings.TextColor
            lbl.TextXAlignment = posData.TextAlign
        end
    end
    
    UpdateLabelStyle(State.fpsLabel)
    UpdateLabelStyle(State.pingLabel)
    
    if State.fpsLabel then State.fpsLabel.Visible = Settings.ShowFPS end
    if State.pingLabel then State.pingLabel.Visible = Settings.ShowPing end
end

local function CreateInterface()
    Cleanup_Internal()
    
    local bestParent = GetBestParent()
    if not bestParent then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = GUI_NAME
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 2147483647 
    screenGui.Parent = bestParent
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(0, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.XY
    container.Parent = screenGui
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2) 
    layout.Parent = container

    State.fpsLabel = CreateLabel("FPS_Label", container)
    State.fpsLabel.LayoutOrder = 1
    
    State.pingLabel = CreateLabel("Ping_Label", container)
    State.pingLabel.LayoutOrder = 2
    
    State.guiObject = screenGui
    State.container = container
    
    UpdateVisuals()
end

local function StartCounting()
    if State.renderConnection then return end
    
    State.lastTime = os.clock()
    State.frameCount = 0
    
    State.renderConnection = RunService.Heartbeat:Connect(function()
        State.frameCount = State.frameCount + 1
        local currentTime = os.clock()
        local elapsed = currentTime - State.lastTime
        
        if elapsed >= 1 then
            local fps = State.frameCount / elapsed
            local ping = tonumber(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) or 0
            
            if State.fpsLabel and Settings.ShowFPS then
                State.fpsLabel.Text = string.format("FPS: %.1f", fps)
            end
            
            if State.pingLabel and Settings.ShowPing then
                State.pingLabel.Text = string.format("Ping: %d ms", ping)
            end
            
            State.frameCount = 0
            State.lastTime = currentTime
        end
    end)
end


function Overlay:Enable()
    Settings.Enabled = true
    State.isEnabled = true
    CreateInterface()
    StartCounting()
end

function Overlay:Disable()
    Settings.Enabled = false
    State.isEnabled = false
    if State.guiObject then State.guiObject:Destroy() State.guiObject = nil end
    if State.renderConnection then State.renderConnection:Disconnect() State.renderConnection = nil end
end

function Overlay:UpdateSetting(settingName, value)
    if Settings[settingName] == nil then return end
    
    if settingName == "TextColor" and typeof(value) ~= "Color3" then return end
    
    Settings[settingName] = value
    
    if State.isEnabled then
        UpdateVisuals()
    end
end

function Overlay:Destroy()
    Cleanup_Internal()
    _G.ExecutorOverlay = nil
end

if Settings.Enabled then
    Overlay:Enable()
end

return true