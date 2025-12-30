if _G.ExecutorPlayerArrows_Instance and typeof(_G.ExecutorPlayerArrows_Instance.Destroy) == "function" then
    pcall(_G.ExecutorPlayerArrows_Instance.Destroy)
    task.wait(0.1)
end
_G.ExecutorPlayerArrows_Instance = nil

_G.ExecutorPlayerArrows = _G.ExecutorPlayerArrows or {}
local Arrows = _G.ExecutorPlayerArrows
local BASE_NAME = "ExecutorPlayerArrows_vFinal"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

Arrows.Settings = Arrows.Settings or {
    ARROW_IMAGE_ID = "rbxassetid://4862800922",
    RenderDistance = 300,
    RingRadius = 120,
    ArrowBaseSizeXY = 32,
    ArrowTransparency = 0.1,
    MaxVisibleArrows = 0,

    EnableDynamicSize = true,
    MinArrowScale = 0.5,
    MaxArrowScale = 1.5,
    NearDistanceForScaling = 30,
    FarDistanceForScaling = 150,

    EnableDynamicColor = true,
    ArrowColorFar = Color3.fromRGB(80, 200, 80),  
    ArrowColorNear = Color3.fromRGB(255, 80, 80), 
    INTERNAL_NEAR_COLOR_DIST = 5,
    INTERNAL_FAR_COLOR_DIST = 100
}
local Settings = Arrows.Settings

Arrows.State = Arrows.State or {
    isEnabled = false,
    isInitialized = false,
    screenGui = nil,
    activePlayerArrows = {},
    runConnection = nil,
    playerAddedConn = nil,
    playerRemovingConn = nil
}
local State = Arrows.State

local function IsValidTarget(player)
    if not player or player == LocalPlayer or not player.Character or
       not player.Character:FindFirstChild("HumanoidRootPart") or
       not player.Character:FindFirstChildOfClass("Humanoid") or
       player.Character.Humanoid.Health <= 0 then
        return false
    end
    return true
end

local function Lerp(a, b, t) return a + (b - a) * t end
local function InverseLerp(a, b, v) if b - a == 0 then return 0 end; return (v - a) / (b - a) end

function Arrows:CreateScreenGui_Internal()
    if State.screenGui and State.screenGui.Parent then return State.screenGui end
    local sg = Instance.new("ScreenGui")
    sg.Name = BASE_NAME .. "_ScreenGui"
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
    sg.ResetOnSpawn = false
    State.screenGui = sg
    local parentGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")
    if parentGui then sg.Parent = parentGui else warn(BASE_NAME .. ": Не удалось найти PlayerGui/CoreGui."); return nil end
    return sg
end

function Arrows:CreateArrowImage_Internal()
    if not State.screenGui or not State.screenGui.Parent then self:CreateScreenGui_Internal() end
    if not State.screenGui then return nil end

    local arrowImage = Instance.new("ImageLabel")
    arrowImage.Name = "DirectionArrow"
    arrowImage.Image = Settings.ARROW_IMAGE_ID
    arrowImage.Size = UDim2.fromOffset(Settings.ArrowBaseSizeXY, Settings.ArrowBaseSizeXY)
    arrowImage.AnchorPoint = Vector2.new(0.5,0.5) 
    arrowImage.BackgroundTransparency = 1
    arrowImage.ImageTransparency = Settings.ArrowTransparency
    arrowImage.Visible = false 
    arrowImage.Parent = State.screenGui
    return arrowImage
end

function Arrows:UpdateArrows_Internal()
    if not State.isEnabled then
        for _, data in pairs(State.activePlayerArrows) do if data.ArrowImageLabel then data.ArrowImageLabel.Visible = false end end
        return
    end
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, data in pairs(State.activePlayerArrows) do if data.ArrowImageLabel then data.ArrowImageLabel.Visible = false end end
        return
    end
    if not Camera then Camera = workspace.CurrentCamera; if not Camera then return end end

    local localHRP_Pos = LocalPlayer.Character.HumanoidRootPart.Position
    local cameraCF = Camera.CFrame
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

    local potentialTargets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local targetHRP = player.Character.HumanoidRootPart
            local distance = (localHRP_Pos - targetHRP.Position).Magnitude
            if distance <= Settings.RenderDistance then
                table.insert(potentialTargets, { Player = player, HRP_Pos = targetHRP.Position, Distance = distance })
            end
        end
    end

    if Settings.MaxVisibleArrows > 0 and #potentialTargets > Settings.MaxVisibleArrows then
        table.sort(potentialTargets, function(a, b) return a.Distance < b.Distance end)
    end
    
    local activePlayersThisFrame = {}
    local targetsToProcessCount = Settings.MaxVisibleArrows > 0 and math.min(#potentialTargets, Settings.MaxVisibleArrows) or #potentialTargets
    
    for i = 1, targetsToProcessCount do activePlayersThisFrame[potentialTargets[i].Player] = true end

    for player, arrowData in pairs(State.activePlayerArrows) do
        if not activePlayersThisFrame[player] or not player.Parent then
            if arrowData.ArrowImageLabel then arrowData.ArrowImageLabel.Visible = false end
        end
    end
    
    for i = 1, targetsToProcessCount do
        local targetData = potentialTargets[i]
        local targetPlayer = targetData.Player
        local targetHRP_Pos = targetData.HRP_Pos
        local distanceToTarget = targetData.Distance
        
        local arrowData = State.activePlayerArrows[targetPlayer]
        if not arrowData or not arrowData.ArrowImageLabel or not arrowData.ArrowImageLabel.Parent then
            local newArrowImage = self:CreateArrowImage_Internal(); if not newArrowImage then continue end
            arrowData = { ArrowImageLabel = newArrowImage }; State.activePlayerArrows[targetPlayer] = arrowData
        end
        local arrowImage = arrowData.ArrowImageLabel
        
        arrowImage.Image = Settings.ARROW_IMAGE_ID
        arrowImage.ImageTransparency = Settings.ArrowTransparency

        local worldDirectionToTarget = (targetHRP_Pos - cameraCF.Position) -- Вектор от КАМЕРЫ к цели
        if worldDirectionToTarget.Magnitude < 0.1 then arrowImage.Visible = false; continue end
        worldDirectionToTarget = worldDirectionToTarget.Unit

        local camLookVector = cameraCF.LookVector
        local camRightVector = cameraCF.RightVector
        
        local targetRelativeX = worldDirectionToTarget:Dot(camRightVector)
        local targetRelativeZ = worldDirectionToTarget:Dot(camLookVector) 
        local angleRad = math.atan2(targetRelativeX, targetRelativeZ) 
        
        local hudX = screenCenter.X + math.sin(angleRad) * Settings.RingRadius
        local hudY = screenCenter.Y - math.cos(angleRad) * Settings.RingRadius
        arrowImage.Position = UDim2.fromOffset(hudX, hudY)
        arrowImage.Rotation = math.deg(angleRad)
        
        if Settings.EnableDynamicColor then
            local colorT = math.clamp(InverseLerp(Settings.INTERNAL_FAR_COLOR_DIST, Settings.INTERNAL_NEAR_COLOR_DIST, distanceToTarget), 0, 1)
            arrowImage.ImageColor3 = Settings.ArrowColorFar:Lerp(Settings.ArrowColorNear, colorT)
        else
            arrowImage.ImageColor3 = Settings.ArrowColorFar
        end
        
        if Settings.EnableDynamicSize then
            local sizeT = math.clamp(InverseLerp(Settings.FarDistanceForScaling, Settings.NearDistanceForScaling, distanceToTarget), 0, 1)
            local currentScale = Lerp(Settings.MinArrowScale, Settings.MaxArrowScale, sizeT)
            arrowImage.Size = UDim2.fromOffset(Settings.ArrowBaseSizeXY * currentScale, Settings.ArrowBaseSizeXY * currentScale)
        else
            arrowImage.Size = UDim2.fromOffset(Settings.ArrowBaseSizeXY, Settings.ArrowBaseSizeXY)
        end
        
        arrowImage.Visible = true
    end
end

function Arrows:ManagePlayer_Internal(player, add)
    if add then
        if State.activePlayerArrows[player] and (not State.activePlayerArrows[player].ArrowImageLabel or not State.activePlayerArrows[player].ArrowImageLabel.Parent) then
            State.activePlayerArrows[player] = nil
        end
    else 
        local arrowData = State.activePlayerArrows[player]
        if arrowData and arrowData.ArrowImageLabel then arrowData.ArrowImageLabel:Destroy() end
        State.activePlayerArrows[player] = nil
    end
end

function Arrows:Enable()
    if State.isInitialized and State.isEnabled then return end
    State.isEnabled = true
    if not State.isInitialized then
        if not Camera then Camera = workspace.CurrentCamera end
        if not Camera then warn(BASE_NAME .. ": Камера не найдена!"); State.isEnabled=false; return end
        if not LocalPlayer then warn(BASE_NAME .. ": Локальный игрок не найден!"); State.isEnabled=false; return end

        self:CreateScreenGui_Internal()
        if not State.screenGui then State.isEnabled=false; return end

        for _,p in ipairs(Players:GetPlayers()) do self:ManagePlayer_Internal(p, true) end
        if State.playerAddedConn and State.playerAddedConn.Connected then State.playerAddedConn:Disconnect() end
        State.playerAddedConn=Players.PlayerAdded:Connect(function(p) self:ManagePlayer_Internal(p,true) end)
        if State.playerRemovingConn and State.playerRemovingConn.Connected then State.playerRemovingConn:Disconnect() end
        State.playerRemovingConn=Players.PlayerRemoving:Connect(function(p) self:ManagePlayer_Internal(p,false) end)
        State.isInitialized = true
    end
    if not (State.runConnection and State.runConnection.Connected) then
        State.runConnection = RunService.RenderStepped:Connect(function() self:UpdateArrows_Internal() end)
    end
    if State.screenGui then State.screenGui.Enabled = true end
end

function Arrows:Disable()
    if not State.isEnabled then return end
    State.isEnabled = false
    if State.screenGui then State.screenGui.Enabled = false end 
end

function Arrows:UpdateSetting(settingName, value)
    if Settings[settingName] == nil then warn(BASE_NAME .. ": Неизвестная настройка:", settingName); return end
    Settings[settingName] = value
    if State.isEnabled and (settingName == "ArrowBaseSizeXY" or settingName == "ArrowTransparency" or settingName == "ARROW_IMAGE_ID") then
        for _, data in pairs(State.activePlayerArrows) do
            if data.ArrowImageLabel and data.ArrowImageLabel.Visible then
                if settingName == "ArrowTransparency" then data.ArrowImageLabel.ImageTransparency = Settings.ArrowTransparency end
                if settingName == "ARROW_IMAGE_ID" then data.ArrowImageLabel.Image = Settings.ARROW_IMAGE_ID end
            end
        end
    end
end

function Arrows:Destroy()
    if not State.isInitialized and not State.isEnabled then return end 
    if State.runConnection then State.runConnection:Disconnect(); State.runConnection = nil end
    if State.playerAddedConn then State.playerAddedConn:Disconnect(); State.playerAddedConn = nil end
    if State.playerRemovingConn then State.playerRemovingConn:Disconnect(); State.playerRemovingConn = nil end
    for _, data in pairs(State.activePlayerArrows) do if data.ArrowImageLabel then data.ArrowImageLabel:Destroy() end end
    State.activePlayerArrows = {}
    if State.screenGui then State.screenGui:Destroy(); State.screenGui = nil end
    State.isInitialized = false
    State.isEnabled = false
    _G.ExecutorPlayerArrows = nil 
    _G.ExecutorPlayerArrows_Instance = nil
end

_G.ExecutorPlayerArrows_Instance = Arrows
if not Camera then Camera = workspace.CurrentCamera end