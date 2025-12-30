if _G.ExecutorChinaHat and typeof(_G.ExecutorChinaHat.Stop) == "function" then
    _G.ExecutorChinaHat:Stop()
    task.wait(0.1)
end

_G.ExecutorChinaHat = {}
local ChinaHatManager = _G.ExecutorChinaHat

local Players = game:GetService("Players")

ChinaHatManager.Settings = {
    Color = Color3.fromRGB(255, 255, 255), 
    Radius = 2.0,                         
    Height = 0.8, 
    Transparency = 0
}

ChinaHatManager.BeamSettings = {
    BeamWidthStart = 0.05,                 
    BeamWidthEnd = 0.02,                   
    NumberOfBeams = 700
}

ChinaHatManager.State = {
    isEnabled = false,
    currentMode = "Beam", 
    activeHatObjects = nil, 
    charAddedConn = nil,
    charRemovingConn = nil
}

function ChinaHatManager:UpdateSetting(settingName, value)
    local isGeometrySetting = (settingName == "Radius" or settingName == "Height")
    
    if self.Settings[settingName] ~= nil then
        self.Settings[settingName] = value
    elseif self.BeamSettings[settingName] ~= nil then
        self.BeamSettings[settingName] = value
        isGeometrySetting = true 
    else
        warn("[ChinaHat] Attempted to update a non-existent setting:", settingName)
        return
    end

    if self.State.isEnabled and self.State.activeHatObjects then
        if isGeometrySetting and Players.LocalPlayer.Character then
            self:CreateHatOnCharacter(Players.LocalPlayer.Character)
        else
            self:_ApplyVisualSettings()
        end
    end
end

function ChinaHatManager:SetHatMode(mode)
    if mode ~= "Beam" and mode ~= "Cone" then
        warn("[ChinaHat] Invalid hat mode:", mode, ". Use 'Beam' or 'Cone'.")
        return
    end

    if self.State.currentMode == mode then return end 

    self.State.currentMode = mode

    if self.State.isEnabled and Players.LocalPlayer and Players.LocalPlayer.Character then
        self:CreateHatOnCharacter(Players.LocalPlayer.Character)
    end
end

function ChinaHatManager:_ApplyVisualSettings()
    if not self.State.activeHatObjects then return end

    if self.State.currentMode == "Beam" then
        for _, beam in ipairs(self.State.activeHatObjects.Beams) do
            beam.Color = ColorSequence.new(self.Settings.Color)
            beam.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, self.Settings.Transparency),
                NumberSequenceKeypoint.new(1, self.Settings.Transparency * 2) 
            })
        end
    elseif self.State.currentMode == "Cone" then
        local adornment = self.State.activeHatObjects.Adornment
        if adornment then
            adornment.Color3 = self.Settings.Color
            adornment.Transparency = self.Settings.Transparency
        end
    end
end


function ChinaHatManager:_CreateBeamHat(head, anchorPart)
    local hatObjects = { AnchorPart = anchorPart, Beams = {}, Attachments = {} }
    
    local peakAttachment = Instance.new("Attachment")
    peakAttachment.Position = Vector3.new(0, self.Settings.Height, 0)
    peakAttachment.Parent = anchorPart
    table.insert(hatObjects.Attachments, peakAttachment)

    for i = 1, self.BeamSettings.NumberOfBeams do
        local angle = (i / self.BeamSettings.NumberOfBeams) * 2 * math.pi
        local x = self.Settings.Radius * math.cos(angle)
        local z = self.Settings.Radius * math.sin(angle)

        local brimAttachment = Instance.new("Attachment")
        brimAttachment.Position = Vector3.new(x, 0, z)
        brimAttachment.Parent = anchorPart
        table.insert(hatObjects.Attachments, brimAttachment)

        local beam = Instance.new("Beam")
        beam.Attachment0 = peakAttachment
        beam.Attachment1 = brimAttachment
        beam.FaceCamera = true
        beam.Width0 = self.BeamSettings.BeamWidthStart
        beam.Width1 = self.BeamSettings.BeamWidthEnd
        beam.Segments = 2
        beam.Parent = anchorPart
        table.insert(hatObjects.Beams, beam)
    end
    
    return hatObjects
end

function ChinaHatManager:_CreateConeHat(head, anchorPart)
    local hatObjects = { AnchorPart = anchorPart }
    
    local coneAdornment = Instance.new("ConeHandleAdornment")
    coneAdornment.Adornee = anchorPart
    coneAdornment.Radius = self.Settings.Radius
    coneAdornment.Height = self.Settings.Height
    coneAdornment.CFrame = CFrame.Angles(math.rad(90), 0, 0)
    coneAdornment.Parent = anchorPart
    hatObjects.Adornment = coneAdornment
    
    return hatObjects
end


function ChinaHatManager:CreateHatOnCharacter(character)
    if not character then return end
    self:DestroyHat()

    local head = character:FindFirstChild("Head")
    if not head then return end
    if not head.Parent then head.AncestryChanged:Wait() end

    local anchorPart = Instance.new("Part")
    anchorPart.Name = "ChinaHatAnchor"
    anchorPart.Size = Vector3.new(0.1, 0.1, 0.1)
    anchorPart.Anchored = false
    anchorPart.CanCollide = false
    anchorPart.Transparency = 1
    anchorPart.Massless = true
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head
    weld.Part1 = anchorPart
    weld.Parent = anchorPart
    
    anchorPart.CFrame = head.CFrame * CFrame.new(0, 0.5, 0)
    anchorPart.Parent = workspace.CurrentCamera
    
    local hatObjects
    if self.State.currentMode == "Beam" then
        hatObjects = self:_CreateBeamHat(head, anchorPart)
    elseif self.State.currentMode == "Cone" then
        hatObjects = self:_CreateConeHat(head, anchorPart)
    end

    if hatObjects then
        hatObjects.Weld = weld 
        self.State.activeHatObjects = hatObjects
        self:_ApplyVisualSettings() 
    end
end

function ChinaHatManager:DestroyHat()
    if self.State.activeHatObjects and self.State.activeHatObjects.AnchorPart then
        if self.State.activeHatObjects.AnchorPart.Parent then
            self.State.activeHatObjects.AnchorPart:Destroy()
        end
    end
    self.State.activeHatObjects = nil
end

function ChinaHatManager:Enable()
    if self.State.isEnabled then return end
    self.State.isEnabled = true

    local player = Players.LocalPlayer
    if not player then return end

    local function onCharacter(character)
        task.wait(0.2)
        if self.State.isEnabled and character and character.Parent then
            self:CreateHatOnCharacter(character)
        end
    end
    
    self.State.charAddedConn = player.CharacterAdded:Connect(onCharacter)
    self.State.charRemovingConn = player.CharacterRemoving:Connect(function(character)
        if self.State.activeHatObjects and self.State.activeHatObjects.Weld and self.State.activeHatObjects.Weld.Part0.Parent == character then
            self:DestroyHat()
        end
    end)
    
    if player.Character then onCharacter(player.Character) end
end

function ChinaHatManager:Disable()
    if not self.State.isEnabled then return end
    self.State.isEnabled = false

    if self.State.charAddedConn then self.State.charAddedConn:Disconnect(); self.State.charAddedConn = nil end
    if self.State.charRemovingConn then self.State.charRemovingConn:Disconnect(); self.State.charRemovingConn = nil end
    
    self:DestroyHat()
end

function ChinaHatManager:Stop()
    self:Disable()
    if _G.ExecutorChinaHat == self then
        _G.ExecutorChinaHat = nil
    end
end

return ChinaHatManager