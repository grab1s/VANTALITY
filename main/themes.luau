local Env = getgenv and getgenv() or _G

local ThemeManager = {}

local Themes = {
    ["Fatality"] = {
        Main       = Color3.fromRGB(255, 106, 133), 
        Background = Color3.fromRGB(19, 19, 19),    
        Container  = Color3.fromRGB(24, 24, 24),    
        Element    = Color3.fromRGB(16, 16, 16),
        Text       = Color3.fromRGB(255, 255, 255),
        TextDark   = Color3.fromRGB(150, 150, 150),
        Stroke     = Color3.fromRGB(29, 29, 29),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },
    ["Christmas"] = {
        Main       = ColorSequence.new{
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 45, 85)), 
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0, 255, 120))
        }, 
        Background = Color3.fromRGB(13, 15, 20),    
        Container  = Color3.fromRGB(20, 24, 30),    
        Element    = Color3.fromRGB(10, 12, 16),    
        Text       = Color3.fromRGB(240, 245, 255),
        TextDark   = Color3.fromRGB(100, 110, 130),
        Stroke     = Color3.fromRGB(40, 50, 60),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },

    ["Discord (Dark)"] = {
        Main       = Color3.fromRGB(88, 101, 242), 
        Background = Color3.fromRGB(49, 51, 56),   
        Container  = Color3.fromRGB(43, 45, 49),   
        Element    = Color3.fromRGB(30, 31, 34),   
        Text       = Color3.fromRGB(220, 221, 222),
        TextDark   = Color3.fromRGB(148, 155, 164),
        Stroke     = Color3.fromRGB(30, 31, 34),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },
    ["Twitch (Dark)"] = {
        Main       = Color3.fromRGB(145, 70, 255), 
        Background = Color3.fromRGB(24, 24, 27),   
        Container  = Color3.fromRGB(31, 31, 35),   
        Element    = Color3.fromRGB(14, 14, 16),   
        Text       = Color3.fromRGB(239, 239, 241),
        TextDark   = Color3.fromRGB(173, 173, 184),
        Stroke     = Color3.fromRGB(50, 50, 55),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },
    ["Steam"] = {
        Main       = ColorSequence.new{
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(6, 182, 212)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(59, 130, 246))
        },
        Background = Color3.fromRGB(23, 26, 33),  
        Container  = Color3.fromRGB(34, 43, 53),   
        Element    = Color3.fromRGB(16, 21, 25),   
        Text       = Color3.fromRGB(197, 195, 192),
        TextDark   = Color3.fromRGB(118, 128, 137),
        Stroke     = Color3.fromRGB(60, 70, 80),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },
    ["Spotify"] = {
        Main       = Color3.fromRGB(29, 185, 84),
        Background = Color3.fromRGB(18, 18, 18),    
        Container  = Color3.fromRGB(33, 33, 33),    
        Element    = Color3.fromRGB(10, 10, 10),    
        Text       = Color3.fromRGB(255, 255, 255),
        TextDark   = Color3.fromRGB(179, 179, 179),
        Stroke     = Color3.fromRGB(45, 45, 45),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },

    ["Neverlose"] = {
        Main       = Color3.fromRGB(0, 200, 255), 
        Background = Color3.fromRGB(10, 15, 25),    
        Container  = Color3.fromRGB(15, 20, 35),    
        Element    = Color3.fromRGB(5, 10, 20),    
        Text       = Color3.fromRGB(255, 255, 255),
        TextDark   = Color3.fromRGB(100, 130, 150),
        Stroke     = Color3.fromRGB(25, 40, 60),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },
    ["Skeet"] = {
        Main       = Color3.fromRGB(168, 255, 0), 
        Background = Color3.fromRGB(18, 18, 18),    
        Container  = Color3.fromRGB(28, 28, 28),    
        Element    = Color3.fromRGB(12, 12, 12),    
        Text       = Color3.fromRGB(220, 220, 220),
        TextDark   = Color3.fromRGB(120, 120, 120),
        Stroke     = Color3.fromRGB(45, 45, 45),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },
    ["Onetap V4"] = {
        Main       = Color3.fromRGB(219, 166, 73), 
        Background = Color3.fromRGB(26, 26, 26),    
        Container  = Color3.fromRGB(45, 45, 45), 
        Element    = Color3.fromRGB(35, 35, 35),    
        Text       = Color3.fromRGB(230, 230, 230),
        TextDark   = Color3.fromRGB(150, 150, 150),
        Stroke     = Color3.fromRGB(60, 60, 60),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    }
}

function ThemeManager:GetThemeNames()
    local names = {}
    for name, _ in pairs(Themes) do
        table.insert(names, name)
    end
    table.sort(names) 
    return names
end

function ThemeManager:Apply(Library, ThemeName)
    local data = Themes[ThemeName]
    if data and Library.SetTheme then
        Library:SetTheme(data)
    end
end

return ThemeManager
