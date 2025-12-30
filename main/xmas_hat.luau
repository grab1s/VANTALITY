local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if not _G.SantaHatSettings then
    _G.SantaHatSettings = {
        Enabled = false,
        Offset = Vector3.new(-0.25, 0.2, -0.07), 
        Rotation = Vector3.new(-9, 0, 8),
        Scale = Vector3.new(1.1, 1.1, 1.1),
        Transparency = 0,
        AssetID = "rbxassetid://15728716058", 
        HatName = "VantalitySantaHat_R6"
    }
end

local Settings = _G.SantaHatSettings 

local ExecutorSantaHat = {}
ExecutorSantaHat.__index = ExecutorSantaHat

function ExecutorSantaHat.new()
    local self = setmetatable({}, ExecutorSantaHat)
    self.HatInstance = nil
    self.Connection = nil
    
    LocalPlayer.CharacterAdded:Connect(function(char)
        if Settings.Enabled then
            task.wait(1.5)
            self:CreateHat()
        end
    end)
    
    return self
end

function ExecutorSantaHat:RemoveHat()
    if self.HatInstance then
        self.HatInstance:Destroy()
        self.HatInstance = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local old = char:FindFirstChild(Settings.HatName)
        if old then old:Destroy() end
    end
    
    if self.Connection then 
        self.Connection:Disconnect() 
        self.Connection = nil
    end
end

function ExecutorSantaHat:UpdateTransform(weld, mesh, handle)
    if not weld or not handle then return end
    
    weld.C1 = CFrame.new(Settings.Offset) * CFrame.Angles(
        math.rad(Settings.Rotation.X),
        math.rad(Settings.Rotation.Y),
        math.rad(Settings.Rotation.Z)
    )
    
    if mesh then
        mesh.Scale = Settings.Scale
    elseif handle:IsA("MeshPart") then
    end
    
    handle.Transparency = Settings.Transparency
end

function ExecutorSantaHat:CreateHat()
    self:RemoveHat()
    
    if not Settings.Enabled then return end

    local Char = LocalPlayer.Character
    if not Char then return end
    
    local Head = Char:FindFirstChild("Head")
    if not Head then return end

    local success, objects = pcall(function() return game:GetObjects(Settings.AssetID) end)
    
    if not success or not objects or not objects[1] then
        warn("Vantality: Failed to load Santa Hat asset.")
        return
    end

    local loadedItem = objects[1]
    
    local handle = loadedItem:IsA("BasePart") and loadedItem or loadedItem:FindFirstChild("Handle") or loadedItem:FindFirstChildWhichIsA("BasePart", true)

    if not handle then
        loadedItem:Destroy()
        return
    end

    handle.Name = Settings.HatName
    handle.Parent = Char
    handle.Anchored = false
    handle.CanCollide = false
    handle.Massless = true
    
    local mesh = handle:FindFirstChildWhichIsA("SpecialMesh")
    if not mesh and not handle:IsA("MeshPart") then
        mesh = Instance.new("SpecialMesh")
        mesh.Parent = handle
        mesh.MeshType = Enum.MeshType.FileMesh
    end
    
    if loadedItem ~= handle then loadedItem:Destroy() end

    local weld = Instance.new("Weld")
    weld.Name = "SantaHatWeld"
    weld.Part0 = Head
    weld.Part1 = handle
    weld.C0 = CFrame.new(0, 0.5, 0) 
    weld.Parent = handle

    self.HatInstance = handle

    self.Connection = RunService.RenderStepped:Connect(function()
        if not self.HatInstance or not self.HatInstance.Parent then
            self:RemoveHat() 
            return
        end
        self:UpdateTransform(weld, mesh, handle)
    end)
end

local HatController = ExecutorSantaHat.new()

getgenv().UpdateSantaHatState = function()
    if Settings.Enabled then
        HatController:CreateHat()
    else
        HatController:RemoveHat()
    end
end

if Settings.Enabled then
    HatController:CreateHat()
end