if _G.VantalityChristmas then
    if _G.VantalityChristmas.Connection then _G.VantalityChristmas.Connection:Disconnect() end
    if _G.VantalityChristmas.Maid then
        for _, obj in pairs(_G.VantalityChristmas.Maid) do
            if obj and obj.Parent then obj:Destroy() end
        end
    end
    _G.VantalityChristmas = nil
end

_G.VantalityChristmas = {
    Maid = {},
    Settings = {
        SnowEnabled = true,
        SnowmanEnabled = true,
        
        PARTICLE_COUNT = 1000, 
        SNOW_IMAGE = "rbxassetid://10734964600",
        
        SNOWMAN_IMAGE = "rbxassetid://80792277575137",
        SNOWMAN_SIZE = 120,
        SNOWMAN_OFFSET_X = -627, 
        
        SNOWMAN_OFFSET_Y_60  = -18,
        SNOWMAN_OFFSET_Y_65  = -24,
        SNOWMAN_OFFSET_Y_75  = -35, 
        SNOWMAN_OFFSET_Y_100 = -55,
        SNOWMAN_OFFSET_Y_125 = -65, 
        SNOWMAN_OFFSET_Y_150 = -72, 
        
        MIN_SIZE = 8, MAX_SIZE = 18,
        MIN_SPEED = 18, MAX_SPEED = 64,
        SWAY_AMOUNT = 17,
        INTERACTION_RADIUS = 80,
        REPULSION_FORCE = 650,
        FRICTION = 0.99,
        
        FADE_TOP = 60, FADE_BOTTOM = 110,
        LIFETIME = 30, VARIANCE = 5, FADE_OUT = 2
    },
    WasVisible = false 
}

local Module = _G.VantalityChristmas
local Settings = Module.Settings

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local math_random = math.random
local math_sin = math.sin
local math_min = math.min
local math_max = math.max
local math_abs = math.abs
local os_clock = os.clock

local function FindVantalityWindow()
    if _G.ahkgbs_instance and typeof(_G.ahkgbs_instance) == "Instance" then
        return _G.ahkgbs_instance
    end
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and #gui:GetChildren() > 0 then
            for _, desc in ipairs(gui:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text == "Vantality" and desc.TextSize >= 20 then
                    return gui
                end
            end
        end
    end
    return nil
end

local TargetGUI = FindVantalityWindow()
if not TargetGUI then warn("Christmas Module: GUI not found.") return end

local WallpaperGUI = Instance.new("ScreenGui")
WallpaperGUI.Name = "Vantality_Wallpaper"
WallpaperGUI.Parent = CoreGui
WallpaperGUI.IgnoreGuiInset = true
WallpaperGUI.DisplayOrder = TargetGUI.DisplayOrder - 1
table.insert(Module.Maid, WallpaperGUI)

local SnowContainer = Instance.new("Frame")
SnowContainer.Name = "SnowContainer"
SnowContainer.Parent = WallpaperGUI
SnowContainer.BackgroundTransparency = 1
SnowContainer.Size = UDim2.fromScale(1, 1)

local Snowman = Instance.new("ImageLabel")
Snowman.Name = "Christmas_Snowman"
Snowman.Parent = TargetGUI
Snowman.BackgroundTransparency = 1
Snowman.Image = Settings.SNOWMAN_IMAGE
Snowman.Size = UDim2.fromOffset(Settings.SNOWMAN_SIZE, Settings.SNOWMAN_SIZE)
Snowman.ZIndex = 1000 
Snowman.AnchorPoint = Vector2.new(1, 0) 
Snowman.Visible = Settings.SnowmanEnabled
table.insert(Module.Maid, Snowman)

local Particles = {}
local Camera = workspace.CurrentCamera
local ViewportSize = Camera.ViewportSize

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    ViewportSize = Camera.ViewportSize
end)

local function ResetParticle(flake, forceTop)
    local pSize = math_random(Settings.MIN_SIZE, Settings.MAX_SIZE)
    local img = flake and flake.Object or Instance.new("ImageLabel")
    
    if not flake then
        img.Parent = SnowContainer
        img.BackgroundTransparency = 1
        img.Image = Settings.SNOW_IMAGE
        img.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    img.Size = UDim2.fromOffset(pSize, pSize)
    img.ImageTransparency = 1 
    
    local startY = forceTop and (-pSize - 10) or math_random(-ViewportSize.Y, ViewportSize.Y)
    
    return {
        Object = img,
        Position = Vector2.new(math_random(0, ViewportSize.X), startY),
        Velocity = Vector2.new(0,0),
        BaseSpeed = math_random(Settings.MIN_SPEED, Settings.MAX_SPEED),
        SwayOffset = math_random() * 6.28,
        RotationSpeed = math_random(-50, 50) / 100,
        TargetTransparency = math_random(20, 80) / 100,
        Size = pSize,
        SpawnTime = os_clock(),
        TotalLife = Settings.LIFETIME + math_random(-Settings.VARIANCE, Settings.VARIANCE)
    }
end

function Module.RefreshParticles()
    while #Particles > Settings.PARTICLE_COUNT do
        local p = table.remove(Particles)
        if p and p.Object then p.Object:Destroy() end
    end
    while #Particles < Settings.PARTICLE_COUNT do
        table.insert(Particles, ResetParticle(nil, false))
    end
end

Module.RefreshParticles()

local MainFrame = nil
for _, child in pairs(TargetGUI:GetChildren()) do
    if child:IsA("Frame") and child.Size.X.Offset > 100 and child.Visible then
        MainFrame = child
        break
    end
end

Module.Connection = RunService.RenderStepped:Connect(function(deltaTime)
    if not TargetGUI.Parent then 
        if Module.Connection then Module.Connection:Disconnect() end
        return 
    end
    
    local isVisible = TargetGUI.Enabled
    
    if isVisible and not Module.WasVisible then
        local now = os_clock()
        for _, p in ipairs(Particles) do
            p.Position = Vector2.new(math_random(0, ViewportSize.X), math_random(0, ViewportSize.Y))
            p.Velocity = Vector2.new(0,0)
            p.SpawnTime = now
        end
    end
    Module.WasVisible = isVisible

    WallpaperGUI.Enabled = isVisible and Settings.SnowEnabled
    Snowman.Visible = isVisible and Settings.SnowmanEnabled
    
    if not isVisible then return end

    if not MainFrame or not MainFrame.Visible then
        for _, child in pairs(TargetGUI:GetChildren()) do
            if child:IsA("Frame") and child.Size.X.Offset > 100 and child.Visible then MainFrame = child break end
        end
    end

    local dt = math_min(deltaTime, 0.1)
    local MousePos = UserInputService:GetMouseLocation()
    local currentTime = os_clock()
    local bottomLimit = ViewportSize.Y
    
    if MainFrame and Settings.SnowmanEnabled then
        local uiScaleObj = MainFrame:FindFirstChildOfClass("UIScale")
        local currentScale = uiScaleObj and uiScaleObj.Scale or 1
        
        local selectedOffsetY = Settings.SNOWMAN_OFFSET_Y_100
        
        if math_abs(currentScale - 0.60) < 0.05 then
            selectedOffsetY = Settings.SNOWMAN_OFFSET_Y_60
        elseif math_abs(currentScale - 0.65) < 0.05 then
            selectedOffsetY = Settings.SNOWMAN_OFFSET_Y_65
        elseif math_abs(currentScale - 0.75) < 0.05 then
            selectedOffsetY = Settings.SNOWMAN_OFFSET_Y_75
        elseif math_abs(currentScale - 1.25) < 0.05 then
            selectedOffsetY = Settings.SNOWMAN_OFFSET_Y_125
        elseif math_abs(currentScale - 1.50) < 0.05 then
            selectedOffsetY = Settings.SNOWMAN_OFFSET_Y_150
        end
        
        local scaledOffsetY = selectedOffsetY * currentScale
        local scaledOffsetX = Settings.SNOWMAN_OFFSET_X * currentScale
        local scaledSize = Settings.SNOWMAN_SIZE * currentScale
        
        local targetX = MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X + scaledOffsetX
        local targetY = MainFrame.AbsolutePosition.Y + scaledOffsetY
        
        Snowman.Position = UDim2.fromOffset(targetX, targetY)
        Snowman.Size = UDim2.fromOffset(scaledSize, scaledSize)
    end

    if Settings.SnowEnabled then
        for i, flake in ipairs(Particles) do
            local age = currentTime - flake.SpawnTime
            local remainingLife = flake.TotalLife - age
            
            if remainingLife <= 0 then
                Particles[i] = ResetParticle(flake, true)
            else
                local sway = math_sin((currentTime * 2) + flake.SwayOffset) * Settings.SWAY_AMOUNT
                local dirVector = flake.Position - MousePos
                local dist = dirVector.Magnitude
                
                if dist < Settings.INTERACTION_RADIUS then
                    local force = (1 - (dist / Settings.INTERACTION_RADIUS)) * Settings.REPULSION_FORCE
                    flake.Velocity = flake.Velocity + (dirVector.Unit * force * dt)
                end
                
                flake.Position = flake.Position + (Vector2.new(sway, flake.BaseSpeed) * dt) + (flake.Velocity * dt)
                flake.Velocity = flake.Velocity * Settings.FRICTION
                flake.Object.Rotation = flake.Object.Rotation + (flake.RotationSpeed + (flake.Velocity.X * 0.1))

                local currentY = flake.Position.Y
                local alphaPos = 1
                local alphaLife = 1 

                if currentY < Settings.FADE_TOP then
                    alphaPos = math_max(0, currentY / Settings.FADE_TOP)
                elseif currentY > (bottomLimit - Settings.FADE_BOTTOM) then
                    alphaPos = math_max(0, (bottomLimit - currentY) / Settings.FADE_BOTTOM)
                end
                
                if remainingLife < Settings.FADE_OUT then
                    alphaLife = remainingLife / Settings.FADE_OUT
                end
                
                flake.Object.ImageTransparency = 1 + (flake.TargetTransparency - 1) * math_min(alphaPos, alphaLife)

                if currentY > bottomLimit + flake.Size then
                    Particles[i] = ResetParticle(flake, true)
                else
                    flake.Object.Position = UDim2.fromOffset(flake.Position.X, flake.Position.Y)
                end
            end
        end
    end
end)