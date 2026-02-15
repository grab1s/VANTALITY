local Marketplace = {}
local HttpService = game:GetService("HttpService")

local Paths = {
    Root = "Vantality",
    Scripts = "Vantality/scripts",
    Configs = "Vantality/Config", -- Путь к конфигам чита (Main)
    ScriptConfigs = "Vantality/scripts/configs" -- Путь к конфигам скриптов
}

local Theme = {
    Main = Color3.fromRGB(255, 106, 133),
    Background = Color3.fromRGB(19, 19, 19),
    Container = Color3.fromRGB(24, 24, 24),
    Text = Color3.fromRGB(255, 255, 255),
    Stroke = Color3.fromRGB(29, 29, 29)
}

local MANIFEST_URL = "https://raw.githubusercontent.com/grab1s/VANTALITY/refs/heads/main/MarketPlace/marketplace.json" 

function Marketplace:CreateGUI()
    if _G.VantalityMarketGUI then _G.VantalityMarketGUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VantalityMarketplace"
    ScreenGui.Parent = game:GetService("CoreGui")
    _G.VantalityMarketGUI = ScreenGui

    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Dragging
    local Drag = Instance.new("UIDragDetector", MainFrame)

    -- Stroke & Corner
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = Theme.Stroke
    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 6)

    -- Header
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Theme.Container
    Header.BorderSizePixel = 0
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 6)
    
    -- Title
    local Title = Instance.new("TextLabel", Header)
    Title.Text = "VANTALITY MARKETPLACE"
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Theme.Main
    Title.TextSize = 18
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Close Button
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Size = UDim2.new(0, 40, 1, 0)
    CloseBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Tabs Container
    local TabsFrame = Instance.new("Frame", MainFrame)
    TabsFrame.Position = UDim2.new(0, 10, 0, 50)
    TabsFrame.Size = UDim2.new(0, 120, 1, -60)
    TabsFrame.BackgroundColor3 = Theme.Container
    local TabsCorner = Instance.new("UICorner", TabsFrame)

    -- Content Container (Grid)
    local ContentScroll = Instance.new("ScrollingFrame", MainFrame)
    ContentScroll.Position = UDim2.new(0, 140, 0, 50)
    ContentScroll.Size = UDim2.new(1, -150, 1, -60)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ScrollBarThickness = 4
    
    local Grid = Instance.new("UIGridLayout", ContentScroll)
    Grid.CellSize = UDim2.new(0, 200, 0, 110)
    Grid.CellPadding = UDim2.new(0, 10, 0, 10)

    -- Notification Function
    local function Notify(msg)
        local N = Instance.new("TextLabel", MainFrame)
        N.Size = UDim2.new(1, 0, 0, 30)
        N.Position = UDim2.new(0, 0, 1, -40)
        N.BackgroundColor3 = Theme.Main
        N.TextColor3 = Color3.new(1,1,1)
        N.Text = msg
        N.Font = Enum.Font.GothamBold
        N.ZIndex = 100
        game:GetService("Debris"):AddItem(N, 2)
    end

    -- Function to Draw Cards
    local function DrawItems(category)
        -- Clear old items
        for _, v in pairs(ContentScroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end

        -- Fetch Data
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(MANIFEST_URL))
        end)

        if not success then 
            Notify("Failed to fetch Marketplace data!")
            return 
        end

        local items = result[category] or {}

        for _, item in pairs(items) do
            local Card = Instance.new("Frame", ContentScroll)
            Card.BackgroundColor3 = Theme.Container
            local CardCorner = Instance.new("UICorner", Card)
            local CardStroke = Instance.new("UIStroke", Card)
            CardStroke.Color = Theme.Stroke

            local Name = Instance.new("TextLabel", Card)
            Name.Text = item.name
            Name.Font = Enum.Font.GothamBold
            Name.TextColor3 = Theme.Text
            Name.TextSize = 14
            Name.Size = UDim2.new(1, -10, 0, 20)
            Name.Position = UDim2.new(0, 5, 0, 5)
            Name.BackgroundTransparency = 1
            Name.TextXAlignment = Enum.TextXAlignment.Left

            local Author = Instance.new("TextLabel", Card)
            Author.Text = "by " .. item.author
            Author.Font = Enum.Font.Gotham
            Author.TextColor3 = Color3.fromRGB(150, 150, 150)
            Author.TextSize = 11
            Author.Size = UDim2.new(1, -10, 0, 15)
            Author.Position = UDim2.new(0, 5, 0, 22)
            Author.BackgroundTransparency = 1
            Author.TextXAlignment = Enum.TextXAlignment.Left

            local Desc = Instance.new("TextLabel", Card)
            Desc.Text = item.description or "No description."
            Desc.Font = Enum.Font.Gotham
            Desc.TextColor3 = Color3.fromRGB(200, 200, 200)
            Desc.TextSize = 10
            Desc.Size = UDim2.new(1, -10, 0, 35)
            Desc.Position = UDim2.new(0, 5, 0, 40)
            Desc.BackgroundTransparency = 1
            Desc.TextXAlignment = Enum.TextXAlignment.Left
            Desc.TextWrapped = true
            Desc.TextYAlignment = Enum.TextYAlignment.Top

            local InstallBtn = Instance.new("TextButton", Card)
            InstallBtn.Text = "INSTALL"
            InstallBtn.BackgroundColor3 = Theme.Main
            InstallBtn.TextColor3 = Color3.new(1,1,1)
            InstallBtn.Font = Enum.Font.GothamBold
            InstallBtn.TextSize = 11
            InstallBtn.Size = UDim2.new(1, -10, 0, 20)
            InstallBtn.Position = UDim2.new(0, 5, 1, -25)
            local BtnCorner = Instance.new("UICorner", InstallBtn)
            BtnCorner.CornerRadius = UDim.new(0, 4)

            InstallBtn.MouseButton1Click:Connect(function()
                local content = game:HttpGet(item.url)
                local savePath
                
                if category == "scripts" then
                    savePath = Paths.Scripts .. "/" .. item.name .. ".luau"
                elseif category == "configs" then
                    -- Определяем тип конфига (основной или для скрипта)
                    if item.type == "Main" then
                        savePath = Paths.Configs .. "/" .. item.name .. ".json" -- Или как у тебя конфиги хранятся
                    else
                        savePath = Paths.ScriptConfigs .. "/" .. item.name
                    end
                end

                if savePath then
                    writefile(savePath, content)
                    Notify("Installed: " .. item.name)
                end
            end)
        end
        
        -- Resize Canvas
        ContentScroll.CanvasSize = UDim2.new(0, 0, 0, Grid.AbsoluteContentSize.Y + 20)
    end

    -- Tab System
    local UIList = Instance.new("UIListLayout", TabsFrame)
    UIList.Padding = UDim.new(0, 5)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local function CreateTab(name, category)
        local Btn = Instance.new("TextButton", TabsFrame)
        Btn.Size = UDim2.new(1, -10, 0, 30)
        Btn.BackgroundColor3 = Theme.Background
        Btn.TextColor3 = Theme.Text
        Btn.Text = name
        Btn.Font = Enum.Font.Gotham
        Btn.BorderSizePixel = 0
        local C = Instance.new("UICorner", Btn)
        
        Btn.MouseButton1Click:Connect(function()
            DrawItems(category)
        end)
    end
    
    -- Padding top
    local pad = Instance.new("Frame", TabsFrame)
    pad.BackgroundTransparency = 1
    pad.Size = UDim2.new(1,0,0,5)

    CreateTab("Scripts", "scripts")
    CreateTab("Configs", "configs")
    
    -- Load default
    DrawItems("scripts")
end


return Marketplace
