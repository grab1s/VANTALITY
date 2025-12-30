do
    _G.ExecutorFakeVisuals = {
        Settings = {
            Headless = false,
            Korblox = false
        }
    }

    local KORBLOX_MESH_ID = "rbxassetid://14331410389"
    local KORBLOX_TEXTURE_ID = "rbxassetid://14331410470"
    local KORBLOX_OFFSET = Vector3.new(0, 0.9, 0) 
    local KORBLOX_ROTATION = Vector3.new(0, 180, 0) 

    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local function UpdateVisuals()
        local Character = LocalPlayer.Character
        if not Character then return end

        local Head = Character:FindFirstChild("Head")
        if Head then
            if _G.ExecutorFakeVisuals.Settings.Headless then
                Head.Transparency = 1
                local Face = Head:FindFirstChildOfClass("Decal")
                if Face then Face.Transparency = 1 end
                if Head:IsA("MeshPart") then Head.Transparency = 1 end
            else
                if Head.Transparency == 1 then Head.Transparency = 0 end
                local Face = Head:FindFirstChildOfClass("Decal")
                if Face and Face.Transparency == 1 then Face.Transparency = 0 end
            end
        end

        local RightLeg = Character:FindFirstChild("Right Leg")
        if RightLeg then
            local FakeLeg = RightLeg:FindFirstChild("FakeKorbloxLeg")

            if _G.ExecutorFakeVisuals.Settings.Korblox then
                RightLeg.Transparency = 1
                
                for _, child in pairs(Character:GetChildren()) do
                    if child:IsA("CharacterMesh") and child.BodyPart == Enum.BodyPart.RightLeg then
                        child:Destroy()
                    end
                end

                if not FakeLeg then
                    FakeLeg = Instance.new("Part")
                    FakeLeg.Name = "FakeKorbloxLeg"
                    FakeLeg.Parent = RightLeg
                    FakeLeg.Size = Vector3.new(1, 2, 1)
                    FakeLeg.CanCollide = false
                    FakeLeg.Massless = true
                    FakeLeg.Transparency = 0
                    
                    local Mesh = Instance.new("SpecialMesh")
                    Mesh.Parent = FakeLeg
                    Mesh.MeshId = KORBLOX_MESH_ID
                    Mesh.TextureId = KORBLOX_TEXTURE_ID
                    Mesh.Scale = Vector3.new(1, 1, 1)
                    Mesh.Offset = KORBLOX_OFFSET

                    local Weld = Instance.new("Weld")
                    Weld.Parent = FakeLeg
                    Weld.Part0 = RightLeg
                    Weld.Part1 = FakeLeg
                    Weld.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(
                        math.rad(KORBLOX_ROTATION.X),
                        math.rad(KORBLOX_ROTATION.Y),
                        math.rad(KORBLOX_ROTATION.Z)
                    )
                end
            else
                if RightLeg.Transparency == 1 then RightLeg.Transparency = 0 end
                if FakeLeg then FakeLeg:Destroy() end
            end
        end
    end

    local connectionName = "AhkGbs_FakeVisuals_Loop"
    if _G[connectionName] then _G[connectionName]:Disconnect() end

    _G[connectionName] = RunService.RenderStepped:Connect(UpdateVisuals)

    function _G.ExecutorFakeVisuals:SetHeadless(bool)
        self.Settings.Headless = bool
    end

    function _G.ExecutorFakeVisuals:SetKorblox(bool)
        self.Settings.Korblox = bool
    end
end