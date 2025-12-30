local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera 

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

if _G.ExecutorViewTracersStandalone_Instance and typeof(_G.ExecutorViewTracersStandalone_Instance.Destroy) == "function" then
    pcall(_G.ExecutorViewTracersStandalone_Instance.Destroy)
    task.wait(0.1)
end
_G.ExecutorViewTracersStandalone_Instance = nil

_G.ExecutorViewTracersStandalone = _G.ExecutorViewTracersStandalone or {}
local VT = _G.ExecutorViewTracersStandalone
local BASE_NAME = "ExecutorViewTracersStandalone_v1_1"

VT.Settings = VT.Settings or {
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 1,
    Transparency = 0, 
    AutoThickness = true,
    Length = 15,
    Smoothness = 0.2,
    MaxDistance = 250
}
local Settings = VT.Settings

VT.State = VT.State or {
    isEnabled = false,
    drawingApiWarned = false,
    playerTracerData = {},  
    mainRenderConnection = nil, 
    playerAddedConn = nil,
    playerRemovingConn = nil
}
local State = VT.State

local function CreateDrawingObject(type)
    if typeof(Drawing) ~= "table" or typeof(Drawing.new) ~= "function" then
        if not State.drawingApiWarned then warn(BASE_NAME .. ": Drawing API не найдено!"); State.drawingApiWarned = true end
        return nil
    end
    return Drawing.new(type)
end

local function IsPlayerValidForDrawing(player)
    if not player or player == LocalPlayer or not player.Character or 
       not player.Character:FindFirstChild("Humanoid") or 
       player.Character.Humanoid.Health <= 0 or -- <<< ИЗМЕНЕНО ЗДЕСЬ
       not player.Character:FindFirstChild("HumanoidRootPart") or 
       not player.Character:FindFirstChild("Head") then
        return false
    end
    return true
end

local function UpdateOrRecreateTracerForPlayer(player)
    local playerData = State.playerTracerData[player]

    if not IsPlayerValidForDrawing(player) then
        if playerData and playerData.line then
            playerData.line.Visible = false
        end
        return
    end

    if not Camera or not Camera.Parent then return end 

    local head = player.Character.Head
    local hrp = player.Character.HumanoidRootPart
    local distanceToPlayer = (Camera.CFrame.Position - hrp.Position).Magnitude

    if distanceToPlayer > Settings.MaxDistance then
        if playerData and playerData.line then
            playerData.line.Visible = false
        end
        return
    end

    if not playerData or not playerData.line or not playerData.line.Parent then 
        if playerData and playerData.line then playerData.line:Remove() end 

        local newLine = CreateDrawingObject("Line")
        if not newLine then return end

        newLine.Visible = false
        newLine.From = Vector2.new(0,0)
        newLine.To = Vector2.new(0,0)
        State.playerTracerData[player] = { line = newLine, lastHeadCFrame = head.CFrame }
        playerData = State.playerTracerData[player]
    end

    local line = playerData.line
    local headpos_vec3, onScreen = Camera:WorldToViewportPoint(head.Position)

    if onScreen then
        line.From = Vector2.new(headpos_vec3.X, headpos_vec3.Y)
        line.Color = Settings.Color
        line.Transparency = Settings.Transparency == 1 and 0 or 1

        if Settings.AutoThickness then
            local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distForThickness = localHRP and (localHRP.Position - hrp.Position).Magnitude or distanceToPlayer
            line.Thickness = math.clamp(1 / (distForThickness + 0.001) * 100, 0.1, 3)
        else
            line.Thickness = Settings.Thickness
        end

        local offsetCFrame = CFrame.new(0, 0, -Settings.Length)
        local check = false
        local iterations = 0
        local maxIterations = 30 
        repeat
            iterations = iterations + 1
            local dir_cframe = head.CFrame:ToWorldSpace(offsetCFrame)
            offsetCFrame = offsetCFrame * CFrame.new(0, 0, Settings.Smoothness)
            local dirpos_vec3, vis = Camera:WorldToViewportPoint(dir_cframe.Position)
            if vis then
                check = true
                line.To = Vector2.new(dirpos_vec3.X, dirpos_vec3.Y)
                line.Visible = true
                offsetCFrame = CFrame.new(0, 0, -Settings.Length) 
            end
            if offsetCFrame.Z > 0 or iterations >= maxIterations then 
                if not check then line.Visible = false end
                check = true 
            end
        until check == true
    else 
        line.Visible = false
    end
    playerData.lastHeadCFrame = head.CFrame
end

local function MainRenderStepUpdater()
    if not State.isEnabled then return end
    if not Camera or not Camera.Parent then return end

    for player, _ in pairs(State.playerTracerData) do
        if player and player.Parent then 
            UpdateOrRecreateTracerForPlayer(player)
        else
            StopTrackingPlayer(player)
        end
    end
end

local function SetupCharacterConnections(player)
    local playerData = State.playerTracerData[player]
    if not playerData then return end 

    if playerData.characterAddedConn then playerData.characterAddedConn:Disconnect(); playerData.characterAddedConn = nil end
    if playerData.humanoidDiedConn then playerData.humanoidDiedConn:Disconnect(); playerData.humanoidDiedConn = nil end

    playerData.characterAddedConn = player.CharacterAdded:Connect(function(character)
        UpdateOrRecreateTracerForPlayer(player) 
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if playerData.humanoidDiedConn then playerData.humanoidDiedConn:Disconnect() end
            playerData.humanoidDiedConn = humanoid.Died:Connect(function()
                if playerData.line then
                    playerData.line.Visible = false
                end
            end)
        end
    end)

    if player.Character then
        local character = player.Character
        UpdateOrRecreateTracerForPlayer(player)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            playerData.humanoidDiedConn = humanoid.Died:Connect(function()
                if playerData.line then
                    playerData.line.Visible = false
                end
            end)
        end
    end
end


local function StartTrackingPlayer(player)
    if player == LocalPlayer then return end 
    if State.playerTracerData[player] then return end 
    
    State.playerTracerData[player] = {} 
    SetupCharacterConnections(player)
end

local function StopTrackingPlayer(player)
    local playerData = State.playerTracerData[player]
    if playerData then
        if playerData.line then playerData.line:Remove() end
        if playerData.characterAddedConn then playerData.characterAddedConn:Disconnect() end
        if playerData.humanoidDiedConn then playerData.humanoidDiedConn:Disconnect() end
        State.playerTracerData[player] = nil
    end
end

local function StopAllTracers()
    for plr, _ in pairs(State.playerTracerData) do StopTrackingPlayer(plr) end
end

local function OnPlayerAdded(player)
    if State.isEnabled then StartTrackingPlayer(player) end
end

local function OnPlayerRemoving(player)
    StopTrackingPlayer(player)
end

function VT:Enable()
    if State.isEnabled then return end
    if CreateDrawingObject("Line") == nil then return end 
    State.isEnabled = true
    if not Camera then Camera = Workspace.CurrentCamera end
    if not Camera then warn(BASE_NAME..": Камера не найдена!"); State.isEnabled=false; return end

    for _, p in ipairs(Players:GetPlayers()) do StartTrackingPlayer(p) end

    if State.playerAddedConn and State.playerAddedConn.Connected then State.playerAddedConn:Disconnect() end
    State.playerAddedConn = Players.PlayerAdded:Connect(OnPlayerAdded)
    if State.playerRemovingConn and State.playerRemovingConn.Connected then State.playerRemovingConn:Disconnect() end
    State.playerRemovingConn = Players.PlayerRemoving:Connect(OnPlayerRemoving)

    if not (State.mainRenderConnection and State.mainRenderConnection.Connected) then
        State.mainRenderConnection = RunService.RenderStepped:Connect(MainRenderStepUpdater)
    end
end

function VT:Disable()
    if not State.isEnabled then return end
    State.isEnabled = false
    StopAllTracers()
    if State.playerAddedConn and State.playerAddedConn.Connected then State.playerAddedConn:Disconnect(); State.playerAddedConn = nil end
    if State.playerRemovingConn and State.playerRemovingConn.Connected then State.playerRemovingConn:Disconnect(); State.playerRemovingConn = nil end
    if State.mainRenderConnection and State.mainRenderConnection.Connected then
        State.mainRenderConnection:Disconnect(); State.mainRenderConnection = nil
    end
    for _, data in pairs(State.playerTracerData) do
        if data and data.line then data.line.Visible = false; end
    end
end

function VT:UpdateSetting(settingName, value)
    if Settings[settingName] == nil then warn(BASE_NAME .. ": Попытка обновить неизвестную настройку:", settingName); return end
    Settings[settingName] = value
end

function VT:Destroy()
    VT:Disable() 
    _G.ExecutorViewTracersStandalone = nil
    _G.ExecutorViewTracersStandalone_Instance = nil
end

_G.ExecutorViewTracersStandalone_Instance = VT
if not Camera then Camera = workspace.CurrentCamera end