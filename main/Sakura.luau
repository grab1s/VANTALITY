_G.ExecutorSakuraEffect = {}
local SakuraManager = _G.ExecutorSakuraEffect

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

SakuraManager.TARGET_LEAF_COLOR = Color3.fromRGB(247, 168, 225)
SakuraManager.TREES_FOLDER_PATH = "Map.Trees"
SakuraManager.TARGET_OBJECT_NAME_LEAF = "MeshPart"
SakuraManager.STUMP_OBJECT_NAME = "TreeRoot"
SakuraManager.LEAF_PARTICLE_TEXTURE_ID = "rbxassetid://110535511819413"

SakuraManager.Settings = SakuraManager.Settings or {
    ENABLE_FALLING_LEAVES = true,
    CHANCE_TO_HAVE_PARTICLES = 0.6,
    PARTICLE_RATE = 0.7,
    MAX_EFFECT_RENDER_DISTANCE = 250,
    PARTICLE_LIFETIME_MIN = 8,
    PARTICLE_LIFETIME_MAX = 10,
    PARTICLE_SPEED_MIN = 0.8,
    PARTICLE_SPEED_MAX = 1,
    PARTICLE_ROTATION_MIN = -180, PARTICLE_ROTATION_MAX = 180,
    PARTICLE_ROT_SPEED_MIN = -45, PARTICLE_ROT_SPEED_MAX = 45,
    PARTICLE_SIZE = NumberSequence.new({NumberSequenceKeypoint.new(0,0.22),NumberSequenceKeypoint.new(0.5,0.32),NumberSequenceKeypoint.new(1,0.20)}),
    PARTICLE_TRANSPARENCY = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.7,0),NumberSequenceKeypoint.new(0.95,0.5),NumberSequenceKeypoint.new(1,1)}),
    PARTICLE_SPREAD_ANGLE = Vector2.new(75, 75),
    PARTICLE_EMISSION_DIRECTION = Enum.NormalId.Bottom,
    PARTICLE_ACCELERATION_NORMAL = Vector3.new(0, -0.6, 0),
    WIND_GUST_INTERVAL_MIN = 10, WIND_GUST_INTERVAL_MAX = 20,
    WIND_GUST_DURATION_MIN = 2.5, WIND_GUST_DURATION_MAX = 4.0,
    WIND_STRENGTH_MIN = 1.4, WIND_STRENGTH_MAX = 3.5,
    CHANCE_LEAF_AFFECTED_BY_WIND = 0.3, COLOR_MONITOR_INTERVAL = 1.0
}
local Settings = SakuraManager.Settings

SakuraManager.State = SakuraManager.State or {
    isEnabled = false, isInitialized = false,
    treeData = {},
    monitoredTreeModels = {},
    currentMonitorTreeIndex = 1, lastColorMonitorTime = 0, mainLoopConnection = nil,
    lastWindGustTime = 0, nextWindGustTime = 0, LocalPlayerInstance = nil
}
local State = SakuraManager.State

local function getObjectByPath(pathString)
    local parts = pathString:split(".")
    local currentObject = Workspace
    for _, partName in ipairs(parts) do
        if currentObject then
            currentObject = currentObject:FindFirstChild(partName)
            if not currentObject then return nil end
        else
            return nil
        end
    end
    return currentObject
end

function SakuraManager:CreateLeafParticleEmitter(parentPart, treeModel)
    if SakuraManager.LEAF_PARTICLE_TEXTURE_ID == "rbxassetid://YOUR_LEAF_TEXTURE_ID_HERE" or string.find(SakuraManager.LEAF_PARTICLE_TEXTURE_ID, "YOUR_LEAF_TEXTURE_ID_HERE") then return nil end
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "SakuraLeafFallEffect"
    emitter.Texture = SakuraManager.LEAF_PARTICLE_TEXTURE_ID;
    emitter.Color = ColorSequence.new(self.TARGET_LEAF_COLOR)
    emitter.LightEmission = 0.05; emitter.LightInfluence = 0.7; emitter.Rate = Settings.PARTICLE_RATE
    emitter.Lifetime = NumberRange.new(Settings.PARTICLE_LIFETIME_MIN, Settings.PARTICLE_LIFETIME_MAX)
    emitter.Speed = NumberRange.new(Settings.PARTICLE_SPEED_MIN, Settings.PARTICLE_SPEED_MAX)
    emitter.Rotation = NumberRange.new(Settings.PARTICLE_ROTATION_MIN, Settings.PARTICLE_ROTATION_MAX)
    emitter.RotSpeed = NumberRange.new(Settings.PARTICLE_ROT_SPEED_MIN, Settings.PARTICLE_ROT_SPEED_MAX)
    emitter.Size = Settings.PARTICLE_SIZE; emitter.Transparency = Settings.PARTICLE_TRANSPARENCY
    emitter.SpreadAngle = Settings.PARTICLE_SPREAD_ANGLE; emitter.EmissionDirection = Settings.PARTICLE_EMISSION_DIRECTION
    emitter.Acceleration = Settings.PARTICLE_ACCELERATION_NORMAL; emitter.Enabled = false;
    emitter.Parent = parentPart
    local emitterData = { emitter = emitter, originalAcceleration = Settings.PARTICLE_ACCELERATION_NORMAL, isInWindGust = false, windEndTime = 0, parentLeafPart = parentPart }
    if not State.treeData[treeModel] then State.treeData[treeModel] = { leafParts = {}, particleEmitters = {} } end
    table.insert(State.treeData[treeModel].particleEmitters, emitterData)
    return emitterData
end

function SakuraManager:ApplySakuraToTreeModel(treeModel)
    local partsChangedThisTree = 0; local emittersCreatedThisTreeCount = 0
    local isNewTreeForMonitoring = not State.treeData[treeModel]

    if not State.treeData[treeModel] then
        State.treeData[treeModel] = { leafParts = {}, particleEmitters = {} }
        table.insert(State.monitoredTreeModels, treeModel)
    end

    for _, descendant in ipairs(treeModel:GetDescendants()) do
        if descendant.Name == self.TARGET_OBJECT_NAME_LEAF and descendant.Name ~= self.STUMP_OBJECT_NAME then
            if descendant:IsA("BasePart") then
                local found = false; for _,p in ipairs(State.treeData[treeModel].leafParts) do if p==descendant then found=true; break end end
                if not found then table.insert(State.treeData[treeModel].leafParts, descendant) end

                if State.isEnabled and descendant.Color ~= self.TARGET_LEAF_COLOR then
                    descendant.Color = self.TARGET_LEAF_COLOR
                    partsChangedThisTree = partsChangedThisTree + 1
                end

                local existingEmitter = descendant:FindFirstChild("SakuraLeafFallEffect")
                if Settings.ENABLE_FALLING_LEAVES then
                    if not existingEmitter then
                        if math.random() < Settings.CHANCE_TO_HAVE_PARTICLES then
                            local emitterData = self:CreateLeafParticleEmitter(descendant, treeModel)
                            if emitterData then emittersCreatedThisTreeCount = emittersCreatedThisTreeCount + 1 end
                        end
                    elseif existingEmitter and State.isEnabled then
                        existingEmitter.Enabled = ( (descendant.Position - (State.LocalPlayerInstance and State.LocalPlayerInstance.Character and State.LocalPlayerInstance.Character.PrimaryPart.Position or Vector3.zero)).Magnitude <= Settings.MAX_EFFECT_RENDER_DISTANCE )
                    elseif existingEmitter and not State.isEnabled then
                        existingEmitter.Enabled = false
                    end
                elseif existingEmitter then
                    existingEmitter.Enabled = false
                end
            end
        end
    end
    return partsChangedThisTree > 0 or emittersCreatedThisTreeCount > 0 or isNewTreeForMonitoring, emittersCreatedThisTreeCount, partsChangedThisTree
end

function SakuraManager:InitialScanAndApply()
    local treesFolder = getObjectByPath(self.TREES_FOLDER_PATH)
    if not treesFolder then return end

    State.monitoredTreeModels = {}
    local totalTreesProcessed,totalEmittersCreated,totalLeavesColored=0,0,0
    for _,item in ipairs(treesFolder:GetChildren())do
        if item:IsA("Model")then
            local p,e,l=self:ApplySakuraToTreeModel(item);
            if p then totalTreesProcessed=totalTreesProcessed+1 end
            if e>0 then totalEmittersCreated=totalEmittersCreated+e end
            if l>0 then totalLeavesColored=totalLeavesColored+l end
        end
    end
end

function SakuraManager:DistanceWindAndColorLoop(dt)
    local currentTime = tick()
    if not State.LocalPlayerInstance or not State.LocalPlayerInstance.Character or not State.LocalPlayerInstance.Character:FindFirstChild("HumanoidRootPart") then return end
    local playerPos = State.LocalPlayerInstance.Character.HumanoidRootPart.Position

    if State.isEnabled and #State.monitoredTreeModels > 0 and currentTime >= State.lastColorMonitorTime + Settings.COLOR_MONITOR_INTERVAL then
        State.lastColorMonitorTime = currentTime; local currentProcessingIndex = State.currentMonitorTreeIndex
        if currentProcessingIndex > #State.monitoredTreeModels then currentProcessingIndex = 1; State.currentMonitorTreeIndex = 1 end
        if #State.monitoredTreeModels > 0 then
            local treeToMonitor = State.monitoredTreeModels[currentProcessingIndex]
            if treeToMonitor and treeToMonitor.Parent and State.treeData[treeToMonitor] then
                for _, leafPart in ipairs(State.treeData[treeToMonitor].leafParts) do
                    if leafPart and leafPart.Parent and leafPart:IsA("BasePart") and leafPart.Color ~= self.TARGET_LEAF_COLOR then
                        leafPart.Color = self.TARGET_LEAF_COLOR
                    end
                end
                State.currentMonitorTreeIndex = currentProcessingIndex + 1
            else table.remove(State.monitoredTreeModels, currentProcessingIndex); if State.currentMonitorTreeIndex > #State.monitoredTreeModels and #State.monitoredTreeModels > 0 then State.currentMonitorTreeIndex = 1 elseif #State.monitoredTreeModels == 0 then State.currentMonitorTreeIndex = 1 end end
        end
    end

    local treeModelsToRemoveFromData = {};
    for treeModel, currentTreeData in pairs(State.treeData) do
        if not (treeModel and treeModel.Parent) then table.insert(treeModelsToRemoveFromData, treeModel)
        else
            if Settings.ENABLE_FALLING_LEAVES and currentTreeData.particleEmitters then
                for _, emitterData in ipairs(currentTreeData.particleEmitters) do
                    if emitterData.emitter and emitterData.emitter.Parent and emitterData.parentLeafPart and emitterData.parentLeafPart.Parent then
                        local distanceToLeaf = (emitterData.parentLeafPart.Position - playerPos).Magnitude
                        local shouldBeEnabled = State.isEnabled and distanceToLeaf <= Settings.MAX_EFFECT_RENDER_DISTANCE
                        if emitterData.emitter.Enabled ~= shouldBeEnabled then emitterData.emitter.Enabled = shouldBeEnabled end
                    elseif emitterData.emitter and emitterData.emitter.Enabled then emitterData.emitter.Enabled = false end
                end
            elseif not Settings.ENABLE_FALLING_LEAVES and currentTreeData.particleEmitters then
                 for _, emitterData in ipairs(currentTreeData.particleEmitters) do
                    if emitterData.emitter and emitterData.emitter.Enabled then emitterData.emitter.Enabled = false end
                 end
            end
        end
    end
    for _,modelToRemove in ipairs(treeModelsToRemoveFromData)do local d=State.treeData[modelToRemove];if d and d.particleEmitters then for _,eD in ipairs(d.particleEmitters)do if eD.emitter and eD.emitter.Parent then eD.emitter:Destroy()end end end;State.treeData[modelToRemove]=nil end

    if State.isEnabled and Settings.ENABLE_FALLING_LEAVES then
        if currentTime >= State.nextWindGustTime then
            State.lastWindGustTime=currentTime;State.nextWindGustTime=currentTime+math.random(Settings.WIND_GUST_INTERVAL_MIN,Settings.WIND_GUST_INTERVAL_MAX); local wD=Vector3.new(math.random()-0.5,0,math.random()-0.5).Unit*math.random(Settings.WIND_STRENGTH_MIN,Settings.WIND_STRENGTH_MAX); local gD=math.random()*(Settings.WIND_GUST_DURATION_MAX-Settings.WIND_GUST_DURATION_MIN)+Settings.WIND_GUST_DURATION_MIN; for _,treeEntry in pairs(State.treeData)do if treeEntry.particleEmitters then for _,eD in ipairs(treeEntry.particleEmitters)do if eD.emitter and eD.emitter.Enabled and eD.emitter.Parent and math.random()<Settings.CHANCE_LEAF_AFFECTED_BY_WIND then eD.isInWindGust=true;eD.windEndTime=currentTime+gD;eD.emitter.Acceleration=Settings.PARTICLE_ACCELERATION_NORMAL+wD end end end end
        end
        for _,treeEntry in pairs(State.treeData)do if treeEntry.particleEmitters then for _,eD in ipairs(treeEntry.particleEmitters)do if eD.isInWindGust and currentTime>=eD.windEndTime then eD.isInWindGust=false;if eD.emitter and eD.emitter.Parent then eD.emitter.Acceleration=eD.originalAcceleration end end end end end
    end
end

function SakuraManager:Initialize()
    if State.isInitialized then return true end
    State.LocalPlayerInstance = Players.LocalPlayer
    if not State.LocalPlayerInstance then local s,p=pcall(function()return Players.LocalPlayerAdded:Wait()end);if not s or not p then return false end;State.LocalPlayerInstance=p; else end
    if not State.LocalPlayerInstance then return false end
    if not self then return false end

    local scanSuccess, scanError = pcall(self.InitialScanAndApply, self);
    if not scanSuccess then return false end

    State.lastWindGustTime = tick(); State.nextWindGustTime = State.lastWindGustTime + math.random(Settings.WIND_GUST_INTERVAL_MIN, Settings.WIND_GUST_INTERVAL_MAX); State.lastColorMonitorTime = tick(); State.currentMonitorTreeIndex = 1;
    if State.mainLoopConnection then State.mainLoopConnection:Disconnect() end
    State.mainLoopConnection = RunService.Heartbeat:Connect(function(dt) if not self then if State.mainLoopConnection then State.mainLoopConnection:Disconnect(); State.mainLoopConnection = nil; end return end; pcall(self.DistanceWindAndColorLoop, self, dt) end)
    State.isInitialized = true;
    return true
end

function SakuraManager:Enable()
    if not self or not State then return end
    if not State.isInitialized then if not self:Initialize() then return end end
    if not State.isEnabled then
        State.isEnabled = true
        for _, treeModel in ipairs(State.monitoredTreeModels) do
            if treeModel and treeModel.Parent then
                self:ApplySakuraToTreeModel(treeModel)
            end
        end
    end
end

function SakuraManager:Disable()
    if not self or not State then return end
    if State.isEnabled then
        State.isEnabled = false
        for _,treeEntry in pairs(State.treeData) do
            if treeEntry.particleEmitters then
                for _,emitterData in ipairs(treeEntry.particleEmitters) do
                    if emitterData.emitter and emitterData.emitter.Enabled then
                        emitterData.emitter.Enabled = false
                    end
                end
            end
        end
    end
end

function SakuraManager:UpdateSetting(settingName, value)
    if not self or not Settings or Settings[settingName] == nil then return end
    local expectedType = typeof(Settings[settingName]); local receivedType = typeof(value)
    if expectedType ~= receivedType and not (expectedType == "number" and receivedType == "number") and expectedType ~= "boolean" then return end
    if expectedType == "boolean" and receivedType ~= "boolean" then return end
    Settings[settingName] = value

    if State.isEnabled and State.isInitialized then
        if settingName == "PARTICLE_RATE" or settingName == "PARTICLE_LIFETIME_MIN" or settingName == "PARTICLE_LIFETIME_MAX" or settingName == "PARTICLE_SPEED_MIN" or settingName == "PARTICLE_SPEED_MAX" then
            for _,treeEntry in pairs(State.treeData) do if treeEntry.particleEmitters then for _,emitterData in ipairs(treeEntry.particleEmitters) do if emitterData.emitter and emitterData.emitter.Parent then if settingName == "PARTICLE_RATE" then emitterData.emitter.Rate = Settings.PARTICLE_RATE end; if settingName == "PARTICLE_LIFETIME_MIN" or settingName == "PARTICLE_LIFETIME_MAX" then emitterData.emitter.Lifetime = NumberRange.new(Settings.PARTICLE_LIFETIME_MIN, Settings.PARTICLE_LIFETIME_MAX) end; if settingName == "PARTICLE_SPEED_MIN" or settingName == "PARTICLE_SPEED_MAX" then emitterData.emitter.Speed = NumberRange.new(Settings.PARTICLE_SPEED_MIN, Settings.PARTICLE_SPEED_MAX) end end end end end
        elseif settingName == "ENABLE_FALLING_LEAVES" then
            for _, treeModel in ipairs(State.monitoredTreeModels) do
                if treeModel and treeModel.Parent then
                    self:ApplySakuraToTreeModel(treeModel)
                end
            end
        end
    end
end

function SakuraManager:Destroy()
    State.isEnabled = false
    if State.mainLoopConnection then State.mainLoopConnection:Disconnect(); State.mainLoopConnection = nil end
    for treeModel, treeDataEntry in pairs(State.treeData) do if treeDataEntry.particleEmitters then for _, emitterData in ipairs(treeDataEntry.particleEmitters) do if emitterData.emitter and emitterData.emitter.Parent then emitterData.emitter:Destroy() end end end end
    State.treeData = {}; State.monitoredTreeModels = {}; State.isInitialized = false
    if _G.ExecutorSakuraEffect == SakuraManager then _G.ExecutorSakuraEffect = nil end
end

return SakuraManager