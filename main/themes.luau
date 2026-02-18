local Env = getgenv and getgenv() or _G

local ThemeManager = {}

local Themes = {
    -- [ ОРИГИНАЛЬНЫЕ ТЕМЫ ] --
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
    },

    -- [ НОВЫЕ ДИЗАЙНЕРСКИЕ ТЕМЫ ОТ VANTALITY ] --

    ["TSB: Saitama"] = { -- Градиент от желтого к красному (костюм/перчатки)
        Main       = ColorSequence.new{
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(220, 20, 60))
        },
        Background = Color3.fromRGB(20, 20, 20),    
        Container  = Color3.fromRGB(30, 30, 30),    
        Element    = Color3.fromRGB(15, 15, 15),    
        Text       = Color3.fromRGB(255, 255, 255),
        TextDark   = Color3.fromRGB(180, 180, 180),
        Stroke     = Color3.fromRGB(50, 50, 50),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },

    ["TSB: Cosmic Garou"] = { -- Космический фиолетовый
        Main       = ColorSequence.new{
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(140, 0, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(80, 0, 180))
        },
        Background = Color3.fromRGB(10, 8, 15),     
        Container  = Color3.fromRGB(18, 15, 25),    
        Element    = Color3.fromRGB(10, 8, 15),     
        Text       = Color3.fromRGB(240, 230, 255),
        TextDark   = Color3.fromRGB(140, 130, 160),
        Stroke     = Color3.fromRGB(40, 30, 60),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },

    ["Cherry Blossom"] = { -- Нежный розовый (Сакура)
        Main       = ColorSequence.new{
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 183, 197)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 105, 180))
        },
        Background = Color3.fromRGB(28, 20, 24),    
        Container  = Color3.fromRGB(40, 28, 34),    
        Element    = Color3.fromRGB(24, 16, 20),    
        Text       = Color3.fromRGB(255, 235, 240),
        TextDark   = Color3.fromRGB(180, 140, 150),
        Stroke     = Color3.fromRGB(60, 40, 50),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },

    ["Cyberpunk 2077"] = { -- Высокий контраст, желтый
        Main       = Color3.fromRGB(252, 238, 10), 
        Background = Color3.fromRGB(8, 10, 12),     
        Container  = Color3.fromRGB(20, 22, 25),    
        Element    = Color3.fromRGB(5, 5, 5),      
        Text       = Color3.fromRGB(10, 240, 255), -- Голубой текст для контраста
        TextDark   = Color3.fromRGB(100, 110, 115),
        Stroke     = Color3.fromRGB(60, 65, 70),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },

    ["Midnight Storm"] = { -- Электрический синий
        Main       = ColorSequence.new{
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(0, 120, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0, 200, 255))
        },
        Background = Color3.fromRGB(10, 12, 18),    
        Container  = Color3.fromRGB(18, 22, 32),    
        Element    = Color3.fromRGB(8, 10, 14),     
        Text       = Color3.fromRGB(230, 240, 255),
        TextDark   = Color3.fromRGB(100, 120, 140),
        Stroke     = Color3.fromRGB(30, 45, 65),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },

    ["Monochrome (Pro)"] = { -- Ч/Б, очень строгая
        Main       = Color3.fromRGB(255, 255, 255), 
        Background = Color3.fromRGB(0, 0, 0),       
        Container  = Color3.fromRGB(20, 20, 20),    
        Element    = Color3.fromRGB(10, 10, 10),    
        Text       = Color3.fromRGB(255, 255, 255),
        TextDark   = Color3.fromRGB(100, 100, 100),
        Stroke     = Color3.fromRGB(40, 40, 40),    
        Outline    = Color3.fromRGB(255, 255, 255), -- Белый контур для стиля
    },

    ["Vaporwave"] = { -- Ретро градиент
        Main       = ColorSequence.new{
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 113, 206)), -- Neon Pink
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(1, 205, 254))    -- Neon Blue
        },
        Background = Color3.fromRGB(24, 18, 38),    
        Container  = Color3.fromRGB(44, 30, 70),    
        Element    = Color3.fromRGB(20, 12, 30),    
        Text       = Color3.fromRGB(255, 255, 255),
        TextDark   = Color3.fromRGB(160, 140, 190),
        Stroke     = Color3.fromRGB(60, 45, 90),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },

    ["Dracula"] = { -- Знаменитая тема для IDE
        Main       = Color3.fromRGB(189, 147, 249), -- Purple
        Background = Color3.fromRGB(40, 42, 54),    
        Container  = Color3.fromRGB(68, 71, 90),    
        Element    = Color3.fromRGB(30, 32, 40),    
        Text       = Color3.fromRGB(248, 248, 242),
        TextDark   = Color3.fromRGB(98, 114, 164),
        Stroke     = Color3.fromRGB(98, 114, 164),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },
    
    ["Acid Green"] = { -- Матрица
        Main       = Color3.fromRGB(57, 255, 20),   
        Background = Color3.fromRGB(5, 15, 5),      
        Container  = Color3.fromRGB(10, 25, 10),    
        Element    = Color3.fromRGB(2, 10, 2),      
        Text       = Color3.fromRGB(200, 255, 200),
        TextDark   = Color3.fromRGB(80, 120, 80),
        Stroke     = Color3.fromRGB(30, 80, 30),    
        Outline    = Color3.fromRGB(0, 0, 0),    
    },

    ["Sunset Gold"] = { -- Премиальный вид
        Main       = ColorSequence.new{
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 165, 0)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 215, 0))
        },
        Background = Color3.fromRGB(25, 20, 15),    
        Container  = Color3.fromRGB(35, 30, 25),    
        Element    = Color3.fromRGB(15, 12, 10),    
        Text       = Color3.fromRGB(255, 240, 220),
        TextDark   = Color3.fromRGB(160, 140, 120),
        Stroke     = Color3.fromRGB(60, 50, 40),    
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
