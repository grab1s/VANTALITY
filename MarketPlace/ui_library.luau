
--[[
    Fatality: Marketplace UI
	Modded by: grab1s
    Author: 4lpaca
    Github: https://github.com/4lpaca-pin/Fatality
--]]

export type Window = {
	Name: string,
	Keybind: string | Enum.KeyCode,
	Scale: UDim2,
	Expire: string
}

export type Loader = {
	Name: string,
	Duration: number,
	Scale: number
}

export type Menu = {
	Name: string,
	Icon: string,
	AutoFill: boolean
}

export type Section = {
	Name: string,
	Position: string,
	Height: number,
}

export type Listbox = {
	Name: string,
	Option: boolean,
	Multi: boolean,
	Position: string,
	Flag: string | nil,
	Height: number,
	Default: ValueBase,
	Values: {ValueBase},
	Callback: (values: {ValueBase}) -> any
}

export type Elements = {
	AddToggle: (self,Config: Toggle) -> { Option: Elements },
	AddSlider: (self,Config: Slider) -> { Option: Elements },
	AddButton: (self,Config: Button) -> {},
	AddColorPicker: (self,Config: ColorPicker) -> { Option: Elements },
	AddDropdown: (self,Config: Dropdown) -> { Option: Elements },
	AddKeybind: (self,Config: Keybind) -> { Option: Elements },
}

export type Preview = {
	Position: string,
	Height: number
}

export type Toggle = {
	Name: string,
	Default: boolean,
	Callback: (boolean) -> any,
	Risky: boolean,
	Option: boolean,
	Flag: string | nil,
}

export type Slider = {
    Name: string,
    Default: number,
    Range: {number}, 
    Precise: boolean, 
    Step: number,    
    Type: string,
    Callback: (number) -> any,
    Risky: boolean,
    Flag: string | nil,
    Option: boolean
}

export type Button = {
	Name: string,
	Callback: (number) -> any,
	Risky: boolean,
}

export type ColorPicker = {
	Name: string,
	Default: Color3,
	Transparency: number,
	Callback: (number) -> any,
	Flag: string | nil,
	Option: boolean
}

export type Dropdown = {
	Name: string,
	Default: string | {string},
	Values: {string},
	Callback: (string | {string}) -> any,
	Option: boolean,
	Multi: boolean,
	Flag: string | nil,
	AutoUpdate: boolean
}

export type Keybind = {
	Name: string,
	Default: string | Enum.KeyCode,
	Callback: (string) -> any,
	Flag: string | nil,
	Option: boolean,
}

export type Notify = {
	Title: string,
	Content: string,
	Duration: number,
	Flag: string | nil,
	Icon: string
}

export type Notifier = {
	Notify: (self, Config: Notify) -> nil
}

cloneref = cloneref or function(i) return i; end;
clonefunction = clonefunction or function(...) return ...; end;
hookfunction = hookfunction or function(a,b) return a; end;
getgenv = getgenv or getfenv;
protect_gui = protect_gui or protectgui or (syn and syn.protect_gui) or function() end;
getgenv().LPH_NO_VIRTUALIZE = LPH_NO_VIRTUALIZE or function(f) return f end;

if game:GetService('RunService'):IsStudio() then
	local BaseWorkspace = Instance.new('Folder',game:GetService("ReplicatedFirst"));
	BaseWorkspace.Name = "WORKSPACE";

	local __get_path_c = function(path)
		return (string.find(path,'/',1,true) and string.split(path,'/')) or (string.find(path,'\\',1,true) and string.split(path,'\\')) or {path};
	end
	local __get_path = function(path)
		local main = __get_path_c(path);
		local block = BaseWorkspace;
		for i,v in next , main do
			block = block[v];
		end;
		return block;
	end;

	getgenv().readfile = function(path) return __get_path(path).Value; end;
	getgenv().isfile = function(path)
		local success , message = pcall(function() return __get_path(path); end);
		if success and not message:IsA("Folder") then return true; end;
		return false;
	end;
	getgenv().isfolder = function(path)
		local success , message = pcall(function() return __get_path(path); end);
		if success and message:IsA("Folder") then return true; end;
		return false;
	end;
	getgenv().writefile = function(path,content)
		local main = __get_path_c(path);
		local block = BaseWorkspace;
		for i,v in next , main do
			local item = block:FindFirstChild(v);
			if not item then
				local c = Instance.new('StringValue',block);
				c.Name = tostring(v);
				c.Value = content;
			else
				if item:IsA('StringValue') and tostring(item) == v then
					item.Name = tostring(v);
					item.Value = content;
				end;
				block = item;
			end;
		end;
	end;
	getgenv().listfiles = function(path)
		local fold = __get_path(path);
		local pa = {};
		for i,v in next , fold:GetChildren() do
			if v:IsA('StringValue') then table.insert(pa,path..'/'..tostring(v)); end;
		end;
		return pa;
	end;
	getgenv().makefolder = function(path)
		local main = __get_path_c(path);
		local block = BaseWorkspace;
		for i,v in next , main do
			local item = block:FindFirstChild(v);
			if not item then
				local c = Instance.new('Folder',block);
				c.Name = tostring(v);
			else
				block = item;
			end;
		end;
	end;
	getgenv().delfile = function(path)
		local main = __get_path_c(path);
		local block = BaseWorkspace;
		for i,v in next , main do
			local item = block:FindFirstChild(v);
			if item and item:IsA('StringValue') then
				item:Destroy();
			else
				block = item;
			end;
		end;
	end;
end;

local TextService = cloneref(game:GetService('TextService'));
local TweenService = cloneref(game:GetService('TweenService'));
local RunService = cloneref(game:GetService('RunService'));
local Players = cloneref(game:GetService('Players'));
local UserInputService = cloneref(game:GetService('UserInputService'));
local Client = Players.LocalPlayer;
local Mouse = Client:GetMouse();
local CurrentCamera = workspace.CurrentCamera;
local _,CoreGui = xpcall(function() return (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui"); end,function() return Client.PlayerGui; end);

-- Fatality --
local Fatality = {};
Fatality.Scale = 1
Fatality.Ascii = "qwertyuiopasdfghjklzxcvbnmQWRTYUIOPASDFGHJKLZXCVBNM";
Fatality.GLOBAL_ENVIRONMENT = {};
Fatality.Windows = {};
Fatality.Fonts = {
	Regular = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	Medium = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
	SemiBold = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
	Bold = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal),
	Black = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
}
Fatality.FontSemiBold = Fatality.Fonts.SemiBold; 
Fatality.DragBlacklist = {};
Fatality.Version = '1.7 - Theme Engine';
Fatality.ScalesRegistry = {}; 

-- THEME SYSTEM --
Fatality.CurrentTheme = {
	Main       = Color3.fromRGB(255, 106, 133), 
	Background = Color3.fromRGB(19, 19, 19),    
	Container  = Color3.fromRGB(24, 24, 24),    
	Element    = Color3.fromRGB(16, 16, 16),
	Hover      = Color3.fromRGB(25, 25, 25), 
	TabActive  = Color3.fromRGB(44, 44, 44), 
	Black      = Color3.fromRGB(16, 16, 16), 
	Text       = Color3.fromRGB(255, 255, 255),
	TextDark   = Color3.fromRGB(150, 150, 150),
	Stroke     = Color3.fromRGB(29, 29, 29),    
	Outline    = Color3.fromRGB(0, 0, 0),      
};

Fatality.Colors = Fatality.CurrentTheme; 
Fatality.ThemeRegistry = {}; 
Fatality.ThemeEvent = Instance.new("BindableEvent") 

function Fatality:GetColor(Category)
	local val = self.CurrentTheme[Category] or Color3.fromRGB(255, 255, 255)
	if typeof(val) == "ColorSequence" then return val.Keypoints[1].Value end
	return val
end

local function LightenColor(color, amount)
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(v + amount, 0, 1))
end

function Fatality:Register(Object, Category, Property)
	if not Object then return end
	Property = Property or "BackgroundColor3"
	
	table.insert(Fatality.ThemeRegistry, { Object = Object, Category = Category, Property = Property })
	
	local val = Fatality.CurrentTheme[Category]
	if val then
		if typeof(val) == "ColorSequence" then
			local grad = Object:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", Object)
			grad.Color = val
			Object[Property] = Color3.fromRGB(255,255,255)
		else
			Object[Property] = val
			local grad = Object:FindFirstChildOfClass("UIGradient")
			if grad then grad.Enabled = false end
		end
	end
	
	if Object:IsA("UIStroke") and Category == "Stroke" then
		Object.Transparency = 0.65
	end
end

function Fatality:SetTheme(NewTheme) 
	for i = #Fatality.ThemeRegistry, 1, -1 do
		local item = Fatality.ThemeRegistry[i]
		if not item.Object or not item.Object.Parent then
			table.remove(Fatality.ThemeRegistry, i)
		end
	end

	for key, val in pairs(NewTheme) do
		Fatality.CurrentTheme[key] = val
	end

	if not NewTheme.Hover then Fatality.CurrentTheme.Hover = LightenColor(Fatality:GetColor("Element"), 0.05) end
	if not NewTheme.TabActive then Fatality.CurrentTheme.TabActive = LightenColor(Fatality:GetColor("Container"), 0.08) end

	Fatality.Colors = Fatality.CurrentTheme
	
	local Sequence = { "Background", "Container", "Element", "Stroke", "Outline", "Text", "TextDark", "Main", "Hover", "TabActive" }
	local TS = game:GetService("TweenService")
	
	task.spawn(function()
		for i, phaseCategory in ipairs(Sequence) do
			for _, item in pairs(Fatality.ThemeRegistry) do
				if item.Object and item.Object.Parent and (item.Category == phaseCategory or (phaseCategory == "Container" and (item.Category == "Element" or item.Category == "Stroke"))) then
					local newVal = Fatality.CurrentTheme[item.Category]
					if typeof(newVal) == "Color3" then
						TS:Create(item.Object, TweenInfo.new(0.3), {[item.Property] = newVal}):Play()
						local grad = item.Object:FindFirstChildOfClass("UIGradient")
						if grad then grad.Enabled = false end
					elseif typeof(newVal) == "ColorSequence" then
						local grad = item.Object:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", item.Object)
						grad.Enabled = true
						grad.Color = newVal
						item.Object[item.Property] = Color3.fromRGB(255,255,255)
					end
				end
			end
			task.wait(0.05)
		end
	end)

	Fatality.ThemeEvent:Fire()
end

Fatality.Lucide = {
	["lucide-accessibility"] = "rbxassetid://114029945302017",
};

Fatality.IsPC = not UserInputService.TouchEnabled;

Fatality.Dummy = {}
local function GetDummy() return Fatality.Dummy end

setmetatable(Fatality.Dummy, {
	__index = function(self, key) return function() return self end end,
    __newindex = function() end
})
Fatality.Dummy.Option = Fatality.Dummy 
Fatality.Dummy.Set = function() end
Fatality.Dummy.Refresh = function() end
Fatality.Dummy.SetValue = function() end
Fatality.Dummy.GetValue = function() return nil end

function Fatality:CanShow(Config)
    if Config and Config.OnlyPC and not Fatality.IsPC then return false end
    return true
end

Fatality.WindowFlags = {};

function Fatality:IsMobile() : boolean return UserInputService.TouchEnabled; end;

function Fatality:RandomString() : string
	return string.char(math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102),math.random(64,102));	
end;

function Fatality:GetTextSize(Text : TextLabel,CustomFont: Enum.Font) : Vector2
	return TextService:GetTextSize(Text.Text,Text.TextSize,(Text.Font ~= Enum.Font.Unknown and Text.Font) or (CustomFont or Enum.Font.GothamMedium),Vector2.new(math.huge,math.huge));
end;

function Fatality:IsMouseOverFrame(Frame : Frame) : boolean
	local AbsPos: Vector2, AbsSize: Vector2 = Frame.AbsolutePosition, Frame.AbsoluteSize;
	if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
		return true;
	end;
end;

function Fatality:GetCalculatePosition(planePos: number, planeNormal: Vector3, rayOrigin: number, rayDirection: Vector3) : number
	local n: Vector3 = planeNormal;
	local d: Vector3 = rayDirection;
	local v: Vector3 = rayOrigin - planePos;

	local num: number = (n.x * v.x) + (n.y * v.y) + (n.z * v.z);
	local den: number = (n.x * d.x) + (n.y * d.y) + (n.z * d.z);
	local a: number = -num / den;

	return rayOrigin + (a * rayDirection);
end;

function Fatality:CreateHover(Element : Frame,Callback : (boolean) -> any)
	Element.MouseEnter:Connect(function() Callback(true); end);
	Element.MouseLeave:Connect(function() Callback(false); end);
end;

function Fatality:GetIcon(name : string) : string
	return Fatality.Lucide['lucide-'..tostring(name)] or Fatality.Lucide[name] or Fatality.Lucide[tostring(name)] or "";
end;

function Fatality:SetIcon(name : string, value : string)
	Fatality.Lucide[name] = value;
end;

function Fatality:Rounding(num: number, numDecimalPlaces: number) : number
	local mult: number = 10 ^ (numDecimalPlaces or 0);
	return math.floor(num * mult + 0.5) / mult;
end;

function Fatality:CreateAnimation(Instance: Instance , Time: number , Style : Enum.EasingStyle , Property : {[string] : any}) : Tween
	if not Property then
		if typeof(Style) == 'table' then Property = Style; Style = nil; end;
	end;

	if Instance:IsA("UIStroke") and Property.Transparency ~= nil then
		if Property.Transparency < 0.65 then Property.Transparency = 0.65 end
	end

	for key, value in pairs(Property) do
		if typeof(value) == "ColorSequence" then
			if value.Keypoints and value.Keypoints[1] then
				Property[key] = value.Keypoints[1].Value
			end
		end
	end

	local Tween: Tween = TweenService:Create(Instance,TweenInfo.new(Time or 1 , Style or Enum.EasingStyle.Quint),Property);
	Tween:Play();
	return Tween;
end;

function Fatality:NewInput(Frame : Frame , Callback : () -> ()) : TextButton
	local Button = Instance.new('TextButton',Frame);
	Button.ZIndex = Frame.ZIndex + 10;
	Button.Size = UDim2.fromScale(1,1);
	Button.BackgroundTransparency = 1;
	Button.TextTransparency = 1;
	if Callback then Button.MouseButton1Click:Connect(Callback); end;
	return Button;
end;

function Fatality:Drag(InputFrame: Frame, MoveFrame: Frame, Speed : number)
	local dragToggle: boolean = false;
	local dragStart: Vector3 = nil;
	local startPos: UDim2 = nil;

	local function updateInput(input)
		local delta = input.Position - dragStart;
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y);
		Fatality:CreateAnimation(MoveFrame,Speed,nil,{ Position = position });
	end;

	InputFrame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and #Fatality.DragBlacklist <= 0 then 
			dragToggle = true
			dragStart = input.Position
			startPos = MoveFrame.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch and #Fatality.DragBlacklist <= 0 then
			if dragToggle then updateInput(input) end
		else
			if #Fatality.DragBlacklist > 0 then dragToggle = false end
		end
	end);
end;

function Fatality:ScrollSignal(Scroll: ScrollingFrame,UIListLayout: UIListLayout,Type:string)
	Scroll.ScrollBarThickness = 0
	Scroll.ScrollBarImageTransparency = 1
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.None

	if Type == 'X' then
		UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			Scroll.CanvasSize = UDim2.fromOffset(math.round(UIListLayout.AbsoluteContentSize.X / Fatality.Scale), 0)
		end)
	else
		UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			Scroll.CanvasSize = UDim2.fromOffset(0, math.round(UIListLayout.AbsoluteContentSize.Y / Fatality.Scale))
		end)
	end;
end;

function Fatality:CreateResponse(args: {[string] : (any) -> any})
	local main = {};
	for i,v in next , args do
		if typeof(v) == 'function' then main[i] = function(self , ...) return v(...); end;
		else main[i] = v; end;
	end;
	return main;
end;

function Fatality:GetWindowFromElement(Element: GuiObject)
	for i,v in next , Fatality.Windows do
		if Element:IsDescendantOf(v) then return v; end;
	end;
end;

function Fatality:CreateOption(OptionButton: ImageButton): Elements
	Fatality:CreateHover(OptionButton,function(bool)
		if bool then Fatality:CreateAnimation(OptionButton,0.5,{ ImageTransparency = 0.3 })
		else Fatality:CreateAnimation(OptionButton,0.5,{ ImageTransparency = 0.600 }) end;
	end);

	local Bindable = Instance.new('BindableEvent');
	local OwnWindow = Fatality:GetWindowFromElement(OptionButton);
	local ExtElementFrame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIStroke = Instance.new("UIStroke")
	local DropShadow = Instance.new("ImageLabel")
	local ScrollingFrame = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local SpaceBox = Instance.new("Frame")

	Fatality:ScrollSignal(ScrollingFrame,UIListLayout,'Y');

	ExtElementFrame.Active = true;
	ExtElementFrame.Name = Fatality:RandomString()
	ExtElementFrame.Parent = OwnWindow
	ExtElementFrame.AnchorPoint = Vector2.new(0.5, 0)
	Fatality:Register(ExtElementFrame, "Container") 
	ExtElementFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ExtElementFrame.BorderSizePixel = 0
	ExtElementFrame.ClipsDescendants = true
	ExtElementFrame.Position = UDim2.new(2, 0, 2, 0)
	ExtElementFrame.Size = UDim2.new(0, 200, 0, 0)
	ExtElementFrame.ZIndex = 100
	local OptScale = Instance.new("UIScale", ExtElementFrame) 
	OptScale.Scale = Fatality.Scale
	table.insert(Fatality.ScalesRegistry, OptScale)

	UICorner.CornerRadius = UDim.new(0, 2)
	UICorner.Parent = ExtElementFrame

	UIStroke.Color = Color3.fromRGB(29, 29, 29)
	Fatality:Register(UIStroke, "Stroke", "Color")
	UIStroke.Parent = ExtElementFrame

	DropShadow.Name = Fatality:RandomString()
	DropShadow.Parent = ExtElementFrame
	DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow.BackgroundTransparency = 1.000
	DropShadow.BorderSizePixel = 0
	DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow.Rotation = 0.001
	DropShadow.Size = UDim2.new(1, 47, 1, 47)
	DropShadow.ZIndex = 99
	DropShadow.Image = "rbxassetid://6014261993"
	Fatality:Register(DropShadow, "Outline", "ImageColor3") 
	DropShadow.ImageTransparency = 0.750
	DropShadow.ScaleType = Enum.ScaleType.Slice
	DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

	ScrollingFrame.Parent = ExtElementFrame
	ScrollingFrame.Active = true
	ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame.BackgroundTransparency = 1.000
	ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.ClipsDescendants = false
	ScrollingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	ScrollingFrame.Size = UDim2.new(1, 0, 1, -5)
	ScrollingFrame.ZIndex = 109
	ScrollingFrame.ScrollBarThickness = 0

	UIListLayout.Parent = ScrollingFrame
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)

	SpaceBox.Name = Fatality:RandomString()
	SpaceBox.Parent = ScrollingFrame
	SpaceBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SpaceBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
	SpaceBox.BorderSizePixel = 0
	SpaceBox.Size = UDim2.new(0, 0, 0, 3)

	local SPAWN_THREAD;
	local isOpen = false; 

	local ToggleExt = function(bool)
		isOpen = bool; 
		if bool then
			Bindable:SetAttribute('V',true); Bindable:Fire(true);

			local size = math.clamp(UIListLayout.AbsoluteContentSize.Y + 15,0,200)
			ExtElementFrame.Position = UDim2.fromOffset(OptionButton.AbsolutePosition.X + 100, OptionButton.AbsolutePosition.Y + (size / 2))

			Fatality:CreateAnimation(ExtElementFrame,0.45,{ Size = UDim2.new(0, 200, 0, size) })
			Fatality:CreateAnimation(DropShadow,0.45,{ ImageTransparency = 0.750 })
			Fatality:CreateAnimation(UIStroke,0.45,{ Transparency = 0 })

			if SPAWN_THREAD then task.cancel(SPAWN_THREAD); SPAWN_THREAD = nil; end;

			SPAWN_THREAD = task.spawn(function()
				while true do task.wait(0.1)
					local size = math.clamp(UIListLayout.AbsoluteContentSize.Y + 15,0,200)
					local ud = UDim2.fromOffset(OptionButton.AbsolutePosition.X + 100, OptionButton.AbsolutePosition.Y + (size / 2));
					Fatality:CreateAnimation(ExtElementFrame,0.35,{ Position = ud });
				end;
			end)
		else
			if SPAWN_THREAD then task.cancel(SPAWN_THREAD); SPAWN_THREAD = nil; end;

			Bindable:SetAttribute('V',false); Bindable:Fire(false);

			Fatality:CreateAnimation(ExtElementFrame,0.45,{ Size = UDim2.new(0, 200, 0, 0) })
			Fatality:CreateAnimation(DropShadow,0.45,{ ImageTransparency = 1 })
			Fatality:CreateAnimation(UIStroke,0.45,{ Transparency = 1 })
		end;
	end;

	Bindable:SetAttribute('V',false);
	ToggleExt(false);

	OptionButton.MouseButton1Click:Connect(function() ToggleExt(true); end);

	UserInputService.InputBegan:Connect(function(input) 
		if isOpen and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
			if not Fatality:IsMouseOverFrame(ExtElementFrame) and not Fatality.GLOBAL_ENVIRONMENT.IS_HOLD_COLOR_PICKER then ToggleExt(false); end;
		end;
	end);

	local UIElements: Elements = Fatality:CreateElements(ScrollingFrame,ScrollingFrame.ZIndex,Bindable);
	return UIElements;
end;

function Fatality:CreateColorPicker(ColorBox: Frame,Transparency, Callback)
	Transparency = Transparency or 0;
	Callback = Callback or function() end;

	local OwnWindow = Fatality:GetWindowFromElement(ColorBox);
	local ColorPickerFrame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIStroke = Instance.new("UIStroke")
	local DropShadow = Instance.new("ImageLabel")
	local ColorPickBox = Instance.new("ImageLabel")
	local MouseMovement = Instance.new("ImageLabel")
	local UICorner_2 = Instance.new("UICorner")
	local UIStroke_2 = Instance.new("UIStroke")
	local ColorRedGreenBlue = Instance.new("Frame")
	local UIGradient = Instance.new("UIGradient")
	local UICorner_3 = Instance.new("UICorner")
	local ColorRGBSlide = Instance.new("Frame")
	local UIStroke_3 = Instance.new("UIStroke")
	local ColorOpc = Instance.new("Frame")
	local UICorner_4 = Instance.new("UICorner")
	local ColorOptSlide = Instance.new("Frame")
	local UIStroke_4 = Instance.new("UIStroke")
	local UIGradient_2 = Instance.new("UIGradient")
	local UIStroke_5 = Instance.new("UIStroke")
	local ColorOpt = Instance.new("Frame")
	local UICorner_5 = Instance.new("UICorner")
	local PasteButton = Instance.new("ImageButton")
	local CopyButton = Instance.new("ImageButton")
	local hexCode = Instance.new("Frame")
	local UICorner_6 = Instance.new("UICorner")
	local HexCodeText = Instance.new("TextLabel")

	local OldCode = 0;
	local CodeH,CodeV = 1, 1;
	local IsPressM1 = false;
	local UI_SPAWN_THREAD;
	local isOpen = false; 

	local updateColor = function()
		local H , S , V = ColorBox.BackgroundColor3:ToHSV();
		OldCode = H; CodeH = S; CodeV = V;
	end;

	local VisibleToggle = function(value)
		isOpen = value; 
		if value then
			ColorPickBox.BackgroundColor3 = Color3.fromHSV(OldCode,1,1);
			ColorOpc.BackgroundColor3 = ColorBox.BackgroundColor3;
			HexCodeText.Text = "#" .. tostring(ColorPickBox.BackgroundColor3:ToHex())

			ColorPickerFrame.Position = UDim2.fromOffset(ColorBox.AbsolutePosition.X + (ColorPickerFrame.AbsoluteSize.X / 1.5),ColorBox.AbsolutePosition.Y);
			updateColor();

			if UI_SPAWN_THREAD then task.cancel(UI_SPAWN_THREAD); UI_SPAWN_THREAD = nil; end;

			UI_SPAWN_THREAD = task.spawn(function()
				while true do task.wait()
					Fatality:CreateAnimation(ColorPickerFrame,0.35,{
						Position = UDim2.fromOffset(ColorBox.AbsolutePosition.X + (ColorPickerFrame.AbsoluteSize.X / 1.5),ColorBox.AbsolutePosition.Y);
					});
				end;
			end);

			Fatality:CreateAnimation(ColorRGBSlide,0.35,{ Position = UDim2.new(0.5, 0, OldCode, 0) });
			Fatality:CreateAnimation(MouseMovement,0.35,{ Position = UDim2.new(CodeH, 0, 1 - CodeV, 0) })
			Fatality:CreateAnimation(ColorOptSlide,0.35,{ Position = UDim2.new(1- Transparency, 0, 0.5, 0) })
			Fatality:CreateAnimation(ColorPickerFrame,0.45,{ Size = UDim2.new(0, 175, 0, 195) });
			Fatality:CreateAnimation(UIStroke,0.45,{ Transparency = 0 });
			Fatality:CreateAnimation(DropShadow,0.45,{ ImageTransparency = 0.75 });
			Fatality:CreateAnimation(ColorPickBox,0.45,{ ImageTransparency = 0, BackgroundTransparency = 0 });
			Fatality:CreateAnimation(MouseMovement,0.45,{ ImageTransparency = 0 });
			Fatality:CreateAnimation(UIStroke_2,0.45,{ Transparency = 0 });
			Fatality:CreateAnimation(ColorRedGreenBlue,0.45,{ BackgroundTransparency = 0 });
			Fatality:CreateAnimation(ColorRGBSlide,0.45,{ BackgroundTransparency = 0 });
			Fatality:CreateAnimation(UIStroke_3,0.45,{ Transparency = 0.75 });
			Fatality:CreateAnimation(ColorOpc,0.45,{ BackgroundTransparency = 0 });
			Fatality:CreateAnimation(ColorOptSlide,0.45,{ BackgroundTransparency = 0 });
			Fatality:CreateAnimation(UIStroke_4,0.45,{ Transparency = 0.75 });
			Fatality:CreateAnimation(UIStroke_5,0.45,{ Transparency = 0 });
			Fatality:CreateAnimation(PasteButton,0.45,{ ImageTransparency = 0.45 });
			Fatality:CreateAnimation(CopyButton,0.45,{ ImageTransparency = 0.45 });
			Fatality:CreateAnimation(hexCode,0.45,{ BackgroundTransparency = 0.4 });
			Fatality:CreateAnimation(HexCodeText,0.45,{ TextTransparency = 0.45 });
		else
			if UI_SPAWN_THREAD then task.cancel(UI_SPAWN_THREAD); UI_SPAWN_THREAD = nil; end;

			Fatality:CreateAnimation(ColorPickerFrame,0.45,{ Size = UDim2.new(0, 175, 0, 0) });
			Fatality:CreateAnimation(UIStroke,0.45,{ Transparency = 1 });
			Fatality:CreateAnimation(DropShadow,0.45,{ ImageTransparency = 1 });
			Fatality:CreateAnimation(ColorPickBox,0.45,{ ImageTransparency = 1, BackgroundTransparency = 1 });
			Fatality:CreateAnimation(MouseMovement,0.45,{ ImageTransparency = 1 });
			Fatality:CreateAnimation(UIStroke_2,0.45,{ Transparency = 1 });
			Fatality:CreateAnimation(ColorRedGreenBlue,0.45,{ BackgroundTransparency = 1 });
			Fatality:CreateAnimation(ColorRGBSlide,0.45,{ BackgroundTransparency = 1 });
			Fatality:CreateAnimation(UIStroke_3,0.45,{ Transparency = 1 });
			Fatality:CreateAnimation(ColorOpc,0.45,{ BackgroundTransparency = 1 });
			Fatality:CreateAnimation(ColorOptSlide,0.45,{ BackgroundTransparency = 1 });
			Fatality:CreateAnimation(UIStroke_4,0.45,{ Transparency = 1 });
			Fatality:CreateAnimation(UIStroke_5,0.45,{ Transparency = 1 });
			Fatality:CreateAnimation(PasteButton,0.45,{ ImageTransparency = 1 });
			Fatality:CreateAnimation(CopyButton,0.45,{ ImageTransparency = 1 });
			Fatality:CreateAnimation(hexCode,0.45,{ BackgroundTransparency = 1 });
			Fatality:CreateAnimation(HexCodeText,0.45,{ TextTransparency = 1 });
		end;
	end;

	ColorPickerFrame.Active = true;
	ColorPickerFrame.Name = Fatality:RandomString()
	ColorPickerFrame.Parent = OwnWindow
	ColorPickerFrame.AnchorPoint = Vector2.new(0.5, 0)
	Fatality:Register(ColorPickerFrame, "Background") 
	ColorPickerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ColorPickerFrame.BorderSizePixel = 0
	ColorPickerFrame.ClipsDescendants = true
	ColorPickerFrame.Position = UDim2.new(4,0,4,0)
	ColorPickerFrame.Size = UDim2.new(0, 175, 0, 195)
	ColorPickerFrame.ZIndex = 200
	local CPScale = Instance.new("UIScale", ColorPickerFrame) 
	CPScale.Scale = Fatality.Scale
	table.insert(Fatality.ScalesRegistry, CPScale)
	Fatality:AddDragBlacklist(ColorPickerFrame);

	UICorner.CornerRadius = UDim.new(0, 2)
	UICorner.Parent = ColorPickerFrame

	UIStroke.Color = Color3.fromRGB(29, 29, 29)
	Fatality:Register(UIStroke, "Stroke", "Color")
	UIStroke.Parent = ColorPickerFrame

	DropShadow.Name = Fatality:RandomString()
	DropShadow.Parent = ColorPickerFrame
	DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow.BackgroundTransparency = 1.000
	DropShadow.BorderSizePixel = 0
	DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow.Rotation = 0.001
	DropShadow.Size = UDim2.new(1, 47, 1, 47)
	DropShadow.ZIndex = 199
	DropShadow.Image = "rbxassetid://6014261993"
	Fatality:Register(DropShadow, "Outline", "ImageColor3") 
	DropShadow.ImageTransparency = 0.750
	DropShadow.ScaleType = Enum.ScaleType.Slice
	DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

	ColorPickBox.Name = Fatality:RandomString()
	ColorPickBox.Parent = ColorPickerFrame
	ColorPickBox.BackgroundColor3 = Color3.fromRGB(39, 255, 35)
	ColorPickBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ColorPickBox.BorderSizePixel = 0
	ColorPickBox.Position = UDim2.new(0, 7, 0, 7)
	ColorPickBox.Size = UDim2.new(0, 135, 0, 135)
	ColorPickBox.ZIndex = 201
	ColorPickBox.Image = "http://www.roblox.com/asset/?id=112554223509763"

	MouseMovement.Name = Fatality:RandomString()
	MouseMovement.Parent = ColorPickBox
	MouseMovement.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MouseMovement.BackgroundTransparency = 1.000
	MouseMovement.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MouseMovement.BorderSizePixel = 0
	MouseMovement.Position = UDim2.new(0.822222233, 0, 0.0592592582, 0)
	MouseMovement.Size = UDim2.new(0, 12, 0, 12)
	MouseMovement.ZIndex = 205
	MouseMovement.Image = "rbxassetid://4805639000"
	MouseMovement.AnchorPoint = Vector2.new(0.5,0.5)

	UICorner_2.CornerRadius = UDim.new(0, 2)
	UICorner_2.Parent = ColorPickBox

	UIStroke_2.Color = Color3.fromRGB(29, 29, 29)
	Fatality:Register(UIStroke_2, "Stroke", "Color") 
	UIStroke_2.Parent = ColorPickBox

	ColorRedGreenBlue.Name = Fatality:RandomString()
	ColorRedGreenBlue.Parent = ColorPickerFrame
	ColorRedGreenBlue.AnchorPoint = Vector2.new(1, 0)
	ColorRedGreenBlue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ColorRedGreenBlue.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ColorRedGreenBlue.BorderSizePixel = 0
	ColorRedGreenBlue.Position = UDim2.new(1, -7, 0, 7)
	ColorRedGreenBlue.Size = UDim2.new(0, 20, 0, 135)
	ColorRedGreenBlue.ZIndex = 206

	UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.10, Color3.fromRGB(255, 153, 0)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(203, 255, 0)), ColorSequenceKeypoint.new(0.30, Color3.fromRGB(50, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 102)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 101, 255)), ColorSequenceKeypoint.new(0.70, Color3.fromRGB(50, 0, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(204, 0, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 153)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))}
	UIGradient.Rotation = 90
	UIGradient.Parent = ColorRedGreenBlue

	UICorner_3.CornerRadius = UDim.new(0, 3)
	UICorner_3.Parent = ColorRedGreenBlue

	ColorRGBSlide.Name = Fatality:RandomString()
	ColorRGBSlide.Parent = ColorRedGreenBlue
	ColorRGBSlide.AnchorPoint = Vector2.new(0.5, 0)
	ColorRGBSlide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ColorRGBSlide.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ColorRGBSlide.BorderSizePixel = 0
	ColorRGBSlide.Position = UDim2.new(0.5, 0, 0.5, 0)
	ColorRGBSlide.Size = UDim2.new(1, 5, 0, 2)
	ColorRGBSlide.ZIndex = 207

	UIStroke_3.Transparency = 0.750
	UIStroke_3.Color = Color3.fromRGB(29, 29, 29)
	Fatality:Register(UIStroke_3, "Stroke", "Color")
	UIStroke_3.Parent = ColorRGBSlide

	ColorOpc.Name = Fatality:RandomString()
	ColorOpc.Parent = ColorPickerFrame
	ColorOpc.AnchorPoint = Vector2.new(0.5, 0)
	ColorOpc.BackgroundColor3 = Color3.fromRGB(102, 255, 0)
	ColorOpc.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ColorOpc.BorderSizePixel = 0
	ColorOpc.Position = UDim2.new(0.5, 0, 0, 149)
	ColorOpc.Size = UDim2.new(1, -15, 0, 12)
	ColorOpc.ZIndex = 206

	UICorner_4.CornerRadius = UDim.new(0, 2)
	UICorner_4.Parent = ColorOpc

	ColorOptSlide.Name = Fatality:RandomString()
	ColorOptSlide.Parent = ColorOpc
	ColorOptSlide.AnchorPoint = Vector2.new(0, 0.5)
	ColorOptSlide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ColorOptSlide.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ColorOptSlide.BorderSizePixel = 0
	ColorOptSlide.Position = UDim2.new(0.5, 0, 0.5, 0)
	ColorOptSlide.Size = UDim2.new(0, 2, 1, 5)
	ColorOptSlide.ZIndex = 207

	UIStroke_4.Transparency = 0.750
	UIStroke_4.Color = Color3.fromRGB(29, 29, 29)
	Fatality:Register(UIStroke_4, "Stroke", "Color") 
	UIStroke_4.Parent = ColorOptSlide

	UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(1.00, 0.00)}
	UIGradient_2.Parent = ColorOpc

	UIStroke_5.Color = Color3.fromRGB(29, 29, 29)
	Fatality:Register(UIStroke_5, "Stroke", "Color")
	UIStroke_5.Parent = ColorOpc

	ColorOpt.Name = Fatality:RandomString()
	ColorOpt.Parent = ColorPickerFrame
	ColorOpt.AnchorPoint = Vector2.new(0.5, 0)
	ColorOpt.BackgroundColor3 = Color3.fromRGB(102, 255, 0)
	ColorOpt.BackgroundTransparency = 1.000
	ColorOpt.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ColorOpt.BorderSizePixel = 0
	ColorOpt.Position = UDim2.new(0.5, 0, 0, 169)
	ColorOpt.Size = UDim2.new(1, -15, 0, 18)
	ColorOpt.ZIndex = 206

	UICorner_5.CornerRadius = UDim.new(0, 2)
	UICorner_5.Parent = ColorOpt

	PasteButton.Name = Fatality:RandomString()
	PasteButton.Parent = ColorOpt
	PasteButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	PasteButton.BackgroundTransparency = 1.000
	PasteButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	PasteButton.BorderSizePixel = 0
	PasteButton.Size = UDim2.new(1, 0, 1, 0)
	PasteButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
	PasteButton.ZIndex = 209
	PasteButton.Image = "rbxassetid://10709799288"
	PasteButton.ImageTransparency = 0.450
	Fatality:Register(PasteButton, "Text", "ImageColor3") 

	CopyButton.Name = Fatality:RandomString()
	CopyButton.Parent = ColorOpt
	CopyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CopyButton.BackgroundTransparency = 1.000
	CopyButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	CopyButton.BorderSizePixel = 0
	CopyButton.Position = UDim2.new(0, 20, 0, 0)
	CopyButton.Size = UDim2.new(1, 0, 1, 0)
	CopyButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
	CopyButton.ZIndex = 209
	CopyButton.Image = "rbxassetid://10709798682"
	CopyButton.ImageTransparency = 0.450
	Fatality:Register(CopyButton, "Text", "ImageColor3") 

	hexCode.Name = Fatality:RandomString()
	hexCode.Parent = ColorOpt
	Fatality:Register(hexCode, "Element") 
	hexCode.BackgroundTransparency = 0.400
	hexCode.BorderColor3 = Color3.fromRGB(0, 0, 0)
	hexCode.BorderSizePixel = 0
	hexCode.Position = UDim2.new(0, 43, 0, 0)
	hexCode.Size = UDim2.new(1, -43, 1, 0)
	hexCode.ZIndex = 209

	UICorner_6.CornerRadius = UDim.new(0, 4)
	UICorner_6.Parent = hexCode

	HexCodeText.Name = Fatality:RandomString()
	HexCodeText.Parent = hexCode
	HexCodeText.AnchorPoint = Vector2.new(0, 0.5)
	HexCodeText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HexCodeText.BackgroundTransparency = 1.000
	HexCodeText.BorderColor3 = Color3.fromRGB(0, 0, 0)
	HexCodeText.BorderSizePixel = 0
	HexCodeText.Position = UDim2.new(0, 3, 0.5, 0)
	HexCodeText.Size = UDim2.new(1, 0, 0.800000012, 0)
	HexCodeText.ZIndex = 209
	HexCodeText.FontFace = Fatality.FontSemiBold
	HexCodeText.Text = "#fff"
	Fatality:Register(HexCodeText, "Text", "TextColor3") 
	HexCodeText.TextSize = 13.000
	HexCodeText.TextTransparency = 0.450
	HexCodeText.TextXAlignment = Enum.TextXAlignment.Left;

	Fatality:CreateHover(CopyButton,function(bool)
		if bool then Fatality:CreateAnimation(CopyButton,0.45,{ ImageTransparency = 0.1 })
		else Fatality:CreateAnimation(CopyButton,0.45,{ ImageTransparency = 0.45 }) end
	end)	

	Fatality:CreateHover(PasteButton,function(bool)
		if bool then Fatality:CreateAnimation(PasteButton,0.45,{ ImageTransparency = 0.1 })
		else Fatality:CreateAnimation(PasteButton,0.45,{ ImageTransparency = 0.45 }) end
	end)

	PasteButton.MouseButton1Click:Connect(function()
		if Fatality.GLOBAL_ENVIRONMENT.COLOR_COPY then
			local h,s,v = Fatality.GLOBAL_ENVIRONMENT.COLOR_COPY.RGB:ToHSV();
			Transparency = Fatality.GLOBAL_ENVIRONMENT.COLOR_COPY.OPC;
			OldCode = h; CodeH = s; CodeV = v;
			HexCodeText.Text = "#" .. tostring(Fatality.GLOBAL_ENVIRONMENT.COLOR_COPY.RGB:ToHex());
			Fatality:CreateAnimation(ColorRGBSlide,0.35,{ Position = UDim2.new(0.5, 0, OldCode, 0) });
			Fatality:CreateAnimation(MouseMovement,0.35,{ Position = UDim2.new(CodeH, 0, 1 - CodeV, 0) })
			Fatality:CreateAnimation(ColorOptSlide,0.35,{ Position = UDim2.new(1- Transparency, 0, 0.5, 0) })
			Fatality:CreateAnimation(ColorPickerFrame,0.45,{ Size = UDim2.new(0, 175, 0, 195), });
			ColorPickBox.BackgroundColor3 = Color3.fromHSV(h,1,1);
			ColorOpc.BackgroundColor3 = Fatality.GLOBAL_ENVIRONMENT.COLOR_COPY.RGB;
			Callback(Color3.fromHSV(OldCode,CodeH,CodeV),Transparency);
		end;
	end);

	CopyButton.MouseButton1Click:Connect(function()
		Fatality.GLOBAL_ENVIRONMENT.COLOR_COPY = {
			RGB = Color3.fromHSV(OldCode,CodeH,CodeV),
			OPC = Transparency,
		};
	end)

	VisibleToggle(false);

	Fatality:NewInput(ColorBox,function() VisibleToggle(true); end);

	do
		local SPAWN_THREAD;
		ColorPickerFrame.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				IsPressM1 = true;
				Fatality.GLOBAL_ENVIRONMENT.IS_HOLD_COLOR_PICKER = true;
				if SPAWN_THREAD then task.cancel(SPAWN_THREAD); SPAWN_THREAD = nil; end;
				SPAWN_THREAD = task.spawn(function()
					while IsPressM1 do task.wait(0) Callback(Color3.fromHSV(OldCode,CodeH,CodeV),Transparency); end;
				end);
			end;
		end)

		ColorPickerFrame.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				IsPressM1 = false;
				Fatality.GLOBAL_ENVIRONMENT.IS_HOLD_COLOR_PICKER = false;
				if SPAWN_THREAD then task.cancel(SPAWN_THREAD); SPAWN_THREAD = nil; end;
			end;
		end)

	UserInputService.InputBegan:Connect(function(Input) 
			if isOpen and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
				if not Fatality:IsMouseOverFrame(ColorPickerFrame) then VisibleToggle(false); end;
			end;
		end)

		ColorRedGreenBlue.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				IsPressM1 = true;
				while (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or IsPressM1) do task.wait()
					local ColorY = ColorRedGreenBlue.AbsolutePosition.Y
					local ColorYM = ColorY + ColorRedGreenBlue.AbsoluteSize.Y;
					local Value = math.clamp(Mouse.Y, ColorY, ColorYM)
					local Code = ((Value - ColorY) / (ColorYM - ColorY));
					local Color = Color3.fromHSV(Code, CodeH, CodeV);

					Fatality:CreateAnimation(ColorRGBSlide,0.35,{ Position = UDim2.new(0.5, 0, Code, 0) });
					Fatality:CreateAnimation(ColorBox,0.5,{ BackgroundColor3 = Color });
					Fatality:CreateAnimation(ColorOpc,0.35,{ BackgroundColor3 = Color });
					Fatality:CreateAnimation(ColorPickBox,0.5,{ BackgroundColor3 = Color3.fromHSV(Code, 1, 1) });

					HexCodeText.Text = "#" .. tostring(Color:ToHex())
					OldCode = Code;
				end;
			end;
		end);

		ColorOpc.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				IsPressM1 = true;
				while (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or IsPressM1) do task.wait()
					local transparency = math.clamp((((Mouse.X) - ColorOpc.AbsolutePosition.X) / ColorOpc.AbsoluteSize.X), 0, 1);
					Fatality:CreateAnimation(ColorOptSlide,0.35,{ Position = UDim2.new(transparency, 0, 0.5, 0) });
					HexCodeText.Text = "#" .. tostring(ColorBox.BackgroundColor3:ToHex())
					Transparency = (1 - transparency);
				end;
			end;
		end);

		ColorPickBox.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				IsPressM1 = true;
				while (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or IsPressM1) do task.wait();
					local PosX = ColorPickBox.AbsolutePosition.X
					local ScaleX = PosX + ColorPickBox.AbsoluteSize.X
					local Value, PosY = math.clamp(Mouse.X, PosX, ScaleX), ColorPickBox.AbsolutePosition.Y
					local ScaleY = PosY + ColorPickBox.AbsoluteSize.Y
					local Vals = math.clamp(Mouse.Y, PosY, ScaleY)

					CodeH = (Value - PosX) / (ScaleX - PosX);
					CodeV = (1 - ((Vals - PosY) / (ScaleY - PosY)));

					Fatality:CreateAnimation(ColorBox,0.5,{ BackgroundColor3 = Color3.fromHSV(OldCode, CodeH, CodeV) });
					Fatality:CreateAnimation(ColorOpc,0.35,{ BackgroundColor3 = Color3.fromHSV(OldCode, CodeH, CodeV) });
					HexCodeText.Text = "#" .. tostring(Color3.fromHSV(OldCode, CodeH, CodeV):ToHex())
					Fatality:CreateAnimation(MouseMovement,0.2,nil,{ Position = UDim2.new(CodeH, 0, 1 - CodeV, 0) })
				end
			end
		end)
	end;

	return { set_opc = function(v) Transparency = v; end, }
end;

function Fatality:RandomStr(len: number): string
	local main = "";
	for i = 1 , len do
		local max = #Fatality.Ascii;
		local rand = math.random(1,max);
		main = main .. Fatality.Ascii:sub(rand,rand);
	end;
	return main;
end;

function Fatality:AddDragBlacklist(Frame: Frame) 
	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			local finder = table.find(Fatality.DragBlacklist , Frame);
			if not finder then table.insert(Fatality.DragBlacklist , Frame); end;
		end;
	end);
	Frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			local finder = table.find(Fatality.DragBlacklist , Frame);
			if finder then table.remove(Fatality.DragBlacklist , finder); end;
		end;
	end);
end;

function Fatality:ProtectText(Label: TextLabel,Text: string)
	Label.RichText = true;
	local MainText = string.gsub(Text,'.',function(t)
		if not string.find(t,"[<>()\"']") then return string.format('<font %s="%s">%s</font>',Fatality:RandomStr(5),Fatality:RandomStr(5),t) end;
		return t;
	end);
	Label.Text = MainText;
end;

function Fatality:CreateDropdown(Parent: Frame, Default: string | {[string]: boolean}, Multiplier: boolean, AutoUpdate: boolean,Callback: (data: any) -> any)
	local ScreenGui = Parent:FindFirstAncestorWhichIsA("ScreenGui")
	local Window = Fatality:GetWindowFromElement(Parent)
	local Data = {};
	local Selected = (Multiplier and {}) or nil;
	local isOpen = false;
    local GuiService = game:GetService("GuiService") 

	local function GetSafeColor(val)
		if typeof(val) == "ColorSequence" then return val.Keypoints[1].Value end
		return val
	end

	local DropdownItemFrame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIStroke = Instance.new("UIStroke")
	local DropShadow = Instance.new("ImageLabel")
	local ScrollingFrame = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local SPAWN_THREAD;

	Fatality:AddDragBlacklist(DropdownItemFrame);

	local Toggle = function(value)
		isOpen = value;
		Fatality.GLOBAL_ENVIRONMENT.IS_HOLD_COLOR_PICKER = value;

		if value then
			DropdownItemFrame.Visible = true
			if SPAWN_THREAD then SPAWN_THREAD:Disconnect() end

			SPAWN_THREAD = game:GetService("RunService").RenderStepped:Connect(function()
				if not Parent or not Parent.Parent or not Parent.Visible or not isOpen then 
					if SPAWN_THREAD then SPAWN_THREAD:Disconnect() end
					DropdownItemFrame.Visible = false
					return 
				end
				
				local unscaledHeight = UIListLayout.AbsoluteContentSize.Y / Fatality.Scale
				local baseSize = unscaledHeight + 10;
				
				local btnPos = Parent.AbsolutePosition
				local btnSize = Parent.AbsoluteSize
                local topBarOffset = GuiService:GetGuiInset().Y
				
				local targetY = btnPos.Y + btnSize.Y + 3 + topBarOffset
				local targetX = (btnPos.X + btnSize.X) - 175

				DropdownItemFrame.Position = UDim2.fromOffset(targetX, targetY)

				Fatality:CreateAnimation(DropdownItemFrame,0.35,{ Size = UDim2.new(0, 175, 0, math.clamp(baseSize,0,200)) })
			end)

			Fatality:CreateAnimation(UIStroke,0.35,{ Transparency = 0 })
			Fatality:CreateAnimation(DropShadow,0.35,{ ImageTransparency = 0.75 })
		else
			if SPAWN_THREAD then SPAWN_THREAD:Disconnect(); SPAWN_THREAD = nil; end;

			Fatality:CreateAnimation(DropdownItemFrame,0.35,{ Size = UDim2.new(0, 175, 0, 0) })
			Fatality:CreateAnimation(UIStroke,0.35,{ Transparency = 1 })
			Fatality:CreateAnimation(DropShadow,0.35,{ ImageTransparency = 1 })
			
			task.delay(0.35, function() if not isOpen then DropdownItemFrame.Visible = false end end)
		end;
	end;

	DropdownItemFrame.Name = Fatality:RandomString()
	DropdownItemFrame.Parent = ScreenGui 
	
	DropdownItemFrame.AnchorPoint = Vector2.new(0, 0) 
	Fatality:Register(DropdownItemFrame, "Container") 
	DropdownItemFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	DropdownItemFrame.BorderSizePixel = 0
	DropdownItemFrame.ClipsDescendants = true
	DropdownItemFrame.Position = UDim2.fromOffset(0, 0)
	DropdownItemFrame.Size = UDim2.new(0, 175, 0, 0)
	DropdownItemFrame.Visible = false
	DropdownItemFrame.ZIndex = 10000 
	DropdownItemFrame.Active = true
	local DDScale = Instance.new("UIScale", DropdownItemFrame)
	DDScale.Scale = Fatality.Scale
	table.insert(Fatality.ScalesRegistry, DDScale)

	UICorner.CornerRadius = UDim.new(0, 2)
	UICorner.Parent = DropdownItemFrame

	UIStroke.Color = Color3.fromRGB(29, 29, 29)
	Fatality:Register(UIStroke, "Stroke", "Color") 
	UIStroke.Parent = DropdownItemFrame

	DropShadow.Name = Fatality:RandomString()
	DropShadow.Parent = DropdownItemFrame
	DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow.BackgroundTransparency = 1.000
	DropShadow.BorderSizePixel = 0
	DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow.Rotation = 0.001
	DropShadow.Size = UDim2.new(1, 47, 1, 47)
	DropShadow.ZIndex = 9999
	DropShadow.Image = "rbxassetid://6014261993"
	Fatality:Register(DropShadow, "Outline", "ImageColor3")
	DropShadow.ImageTransparency = 0.750
	DropShadow.ScaleType = Enum.ScaleType.Slice
	DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

	ScrollingFrame.Parent = DropdownItemFrame
	ScrollingFrame.Active = true
	ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame.BackgroundTransparency = 1.000
	ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.ClipsDescendants = false
	ScrollingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	ScrollingFrame.Size = UDim2.new(1, -5, 1, -5)
	ScrollingFrame.ZIndex = 10005
	ScrollingFrame.ScrollBarThickness = 0
	ScrollingFrame.ScrollBarImageTransparency = 1
	ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None

	UIListLayout.Parent = ScrollingFrame
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)

	UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		ScrollingFrame.CanvasSize = UDim2.fromOffset(0, math.round(UIListLayout.AbsoluteContentSize.Y / Fatality.Scale) + 4)
	end)

local new_button = function()
		local db_selected = Instance.new("TextButton")
		db_selected.Name = Fatality:RandomString()
		db_selected.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		db_selected.BackgroundTransparency = 1.000
		db_selected.BorderSizePixel = 0
		db_selected.Size = UDim2.new(1, 0, 0, 10)
		db_selected.ZIndex = 10010
		db_selected.FontFace = Fatality.FontSemiBold
		db_selected.TextColor3 = Fatality:GetColor("Main") 
		db_selected.TextSize = 12.000
		db_selected.TextXAlignment = Enum.TextXAlignment.Left
		return db_selected;
	end;

	local func;
	local DropdownButtons = {}; 

	local res = Fatality:CreateResponse({
		set_data = function(v) Data = v; end,
		on_toggle = function(cb) func = cb; end,
		change_default = function(v) Default = v; end,
		refresh = function()
			for i,v in next , ScrollingFrame:GetChildren() do if v:IsA('TextButton') then v:Destroy(); end; end;
			table.clear(DropdownButtons);

			local selectedmem;

			for i,v in next , Data do
				local bth = new_button();
				bth.Text = tostring(v);
				bth.Parent = ScrollingFrame;
				table.insert(DropdownButtons, {Btn = bth, Value = v})

				if Multiplier then
					if (typeof(Default) == 'table' and (Default[v] or table.find(Default,v))) or Default == v then
						Selected[v] = true
						bth.TextColor3 = Fatality:GetColor("Main");
					else
						bth.TextColor3 = Fatality:GetColor("Text");
						Selected[v] = false
					end

					bth.MouseButton1Click:Connect(function()
						Selected[v] = not Selected[v];
						bth.TextColor3 = Selected[v] and Fatality:GetColor("Main") or Fatality:GetColor("Text");
						Callback(Selected);
					end)
				else
					if v == Default then
						selectedmem = bth; Selected = v;
						bth.TextColor3 = Fatality:GetColor("Main");
					else
						bth.TextColor3 = Fatality:GetColor("Text");
					end

					bth.MouseButton1Click:Connect(function()
						if selectedmem then selectedmem.TextColor3 = Fatality:GetColor("Text"); end;
						bth.TextColor3 = Fatality:GetColor("Main");
						selectedmem = bth; Selected = v;
						Callback(v);
						if not Multiplier then isOpen = false; func(false); Toggle(false); end
					end)
				end;
			end;
			Callback(Selected);
		end,
	});

	Fatality.ThemeEvent.Event:Connect(function()
		for _, data in pairs(DropdownButtons) do
			if data.Btn and data.Btn.Parent then
				local isSelected = false
				if Multiplier then isSelected = Selected[data.Value] == true else isSelected = (Selected == data.Value) end
				game:GetService("TweenService"):Create(data.Btn, TweenInfo.new(0.3), {TextColor3 = isSelected and Fatality:GetColor("Main") or Fatality:GetColor("Text")}):Play()
			end
		end
	end)

	Fatality:NewInput(Parent,function()
		if isOpen then isOpen = false; func(false); Toggle(false);
		else if AutoUpdate then res:refresh(); end; isOpen = true; func(true); Toggle(true); end
	end);

	UserInputService.InputBegan:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and isOpen then
			if not Fatality:IsMouseOverFrame(DropdownItemFrame) and not Fatality:IsMouseOverFrame(Parent) then
				isOpen = false; func(false); Toggle(false);
			end;
		end;
	end);

	return res;
end;

function Fatality:CreateElements(Parent : Frame , ZIndex : number , Event : BindableEvent,SearchAPI: {Path: string,Memory : (name:string) -> any}) : Elements
	local elements = {};
	local FatalWindow = Fatality:GetWindowFromElement(Parent);

	local function GetDummyElement()
		return { Option = Fatality.Dummy, SetValue = function() end, GetValue = function() return nil end, Set = function() end, Refresh = function() end, Rename = function() end, Signal = { Disconnect = function() end }, Fire = function() end }
	end

	function elements:AddToggle(Config: Toggle)
		Config = Config or {};
		if not Fatality:CanShow(Config) then return GetDummyElement() end

		Config.Name = Config.Name or "Toggle"; Config.Default = Config.Default or false; Config.Risky = Config.Risky or false; Config.Option = Config.Option or false; Config.Callback = Config.Callback or function(bool) end; Config.Flag = Config.Flag or nil;

		local Toggle = Instance.new("Frame")
		local Toggle_Name = Instance.new("TextLabel")
		local ValueFrame = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local ValueIcon = Instance.new("ImageLabel")
		local OptionButton = Instance.new("ImageButton")

		if SearchAPI then SearchAPI.Memory(Config.Name); end;

		Toggle.Name = Fatality:RandomString()
		Toggle.Parent = Parent
		Fatality:Register(Toggle, "Element")
		Toggle.BackgroundTransparency = 1.000
		Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Toggle.BorderSizePixel = 0
		Toggle.Size = UDim2.new(1, -25, 0, 17)
		Toggle.ZIndex = ZIndex + 1
		Fatality:AddDragBlacklist(Toggle);

		Toggle_Name.Name = Fatality:RandomString()
		Toggle_Name.Parent = Toggle
		Toggle_Name.AnchorPoint = Vector2.new(0, 0.5)
		Toggle_Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Toggle_Name.BackgroundTransparency = 1.000
		Toggle_Name.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Toggle_Name.BorderSizePixel = 0
		Toggle_Name.Position = UDim2.new(0, 0, 0.5, 0)
		Toggle_Name.Size = UDim2.new(1, 0, 0.800000012, 0)
		Toggle_Name.ZIndex = ZIndex + 2
		Toggle_Name.FontFace = Fatality.FontSemiBold;
		
		if Config.Risky then Toggle_Name.TextColor3 = Color3.fromRGB(255, 160, 92) else Fatality:Register(Toggle_Name, "Text", "TextColor3") end
		
		Toggle_Name.TextSize = 13.000
		Toggle_Name.TextTransparency = 1
		Toggle_Name.TextXAlignment = Enum.TextXAlignment.Left;
		Fatality:ProtectText(Toggle_Name,Config.Name);

		ValueFrame.Name = Fatality:RandomString()
		ValueFrame.Parent = Toggle
		ValueFrame.AnchorPoint = Vector2.new(1, 0.5)
		Fatality:Register(ValueFrame, "Element")
		ValueFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ValueFrame.BorderSizePixel = 0
		ValueFrame.Position = UDim2.new(1, -3, 0.5, 0)
		ValueFrame.Size = UDim2.new(0.899999976, 0, 0.899999976, 0)
		ValueFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
		ValueFrame.ZIndex = ZIndex + 2
		ValueFrame.BackgroundTransparency = 1;

		UICorner.CornerRadius = UDim.new(0, 2)
		UICorner.Parent = ValueFrame

		ValueIcon.Name = Fatality:RandomString()
		ValueIcon.Parent = ValueFrame
		ValueIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		ValueIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ValueIcon.BackgroundTransparency = 1.000
		ValueIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ValueIcon.BorderSizePixel = 0
		ValueIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
		ValueIcon.Size = UDim2.new(0.699999988, 0, 0.699999988, 0)
		ValueIcon.ZIndex = ZIndex + 2
		ValueIcon.Image = "rbxassetid://10709790644"
		ValueIcon.ImageTransparency = 1;
		Fatality:Register(ValueIcon, "Main", "ImageColor3")

		OptionButton.Name = Fatality:RandomString()
		OptionButton.Parent = Toggle
		OptionButton.AnchorPoint = Vector2.new(1, 0.5)
		OptionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		OptionButton.BackgroundTransparency = 1.000
		OptionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		OptionButton.BorderSizePixel = 0
		OptionButton.Position = UDim2.new(1, -25, 0.5, 0)
		OptionButton.Size = UDim2.new(0.899999976, 0, 0.899999976, 0)
		OptionButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
		OptionButton.Image = "http://www.roblox.com/asset/?id=14007344336"
		OptionButton.ImageTransparency = 1
		OptionButton.ZIndex = ZIndex + 4
		OptionButton.Visible = Config.Option;
		Fatality:Register(OptionButton, "Text", "ImageColor3")

		local toggleImg = function(value)
			if value then
				Fatality:CreateAnimation(ValueIcon,0.45,{ ImageTransparency = 0, ImageColor3 = Fatality.CurrentTheme.Main, Size = UDim2.new(0.8, 0, 0.8, 0), Rotation = 0, })
			else
				Fatality:CreateAnimation(ValueIcon,0.45,{ ImageTransparency = 1, ImageColor3 = Fatality.CurrentTheme.Text, Size = UDim2.new(0.699999988, 0, 0.699999988, 0), Rotation = 15 })
			end;
		end;

		local OpcToggle = function(value)
			if value then
				Fatality:CreateAnimation(ValueIcon,0.45,{ ImageTransparency = 1, })
				Fatality:CreateAnimation(OptionButton,0.45,{ ImageTransparency = (Config.Option and 0.600) or 1 })
				toggleImg(Config.Default)
				Fatality:CreateAnimation(ValueFrame,0.45,{ BackgroundTransparency = 0, })
				Fatality:CreateAnimation(Toggle_Name,0.45,{ TextTransparency = 0.200 })
			else
				Fatality:CreateAnimation(Toggle_Name,0.45,{ TextTransparency = 1 })
				Fatality:CreateAnimation(ValueFrame,0.45,{ BackgroundTransparency = 1, })
				Fatality:CreateAnimation(ValueIcon,0.45,{ ImageTransparency = 1, })
				Fatality:CreateAnimation(ValueIcon,0.45,{ ImageTransparency = 1, })
				Fatality:CreateAnimation(OptionButton,0.45,{ ImageTransparency = 1 })
			end;
		end;

		OpcToggle(Event:GetAttribute('V'))
		toggleImg(Config.Default);

		Fatality:CreateHover(ValueFrame,function(b)
			if not Config.Default then
				if b then Fatality:CreateAnimation(ValueIcon,0.45,{ ImageTransparency = 0.5, ImageColor3 = Fatality.CurrentTheme.Text, Size = UDim2.new(0.7, 0, 0.7, 0), Rotation = 0 })
				else Fatality:CreateAnimation(ValueIcon,0.45,{ ImageTransparency = 1, ImageColor3 = Fatality.CurrentTheme.Text, Size = UDim2.new(0.699999988, 0, 0.699999988, 0), Rotation = 15 }) end;
			end;
		end)

		Fatality:NewInput(ValueFrame,function() Config.Default = not Config.Default; toggleImg(Config.Default); Config.Callback(Config.Default) end);

		local Respons = Fatality:CreateResponse({
			Rename = function(new_name) Toggle_Name.Text = new_name; Fatality:ProtectText(Toggle_Name,new_name); end,
			GetValue = function() return Config.Default; end,
			Signal = Event.Event:Connect(OpcToggle),
			SetValue = function(v, force)
				local IsSame = v == Config.Default; Config.Default = v; toggleImg(Config.Default);
				if not IsSame or force then Config.Callback(Config.Default); end;
			end,
			Flag = Config.Flag and (Config.Flag.."Toggle"),
			Option = (Config.Option and Fatality:CreateOption(OptionButton)) or nil;
		});

		if Config.Flag then Fatality.WindowFlags[FatalWindow][Config.Flag.."Toggle"] = Respons; end;
		if Config.Default then Config.Callback(Config.Default) end

		return Respons;
	end;

	function elements:AddSlider(Config)
		Config = Config or {};
		if not Fatality:CanShow(Config) then return GetDummyElement() end

		Config.Name = Config.Name or "Slider"; Config.Type = Config.Type or ""; Config.Range = Config.Range or {0, 100}; Config.Default = Config.Default or Config.Range[1]; Config.Precise = Config.Precise or false; Config.Step = Config.Step or nil; Config.Risky = Config.Risky or false; Config.Option = Config.Option or false; Config.Callback = Config.Callback or function(number) end; Config.Flag = Config.Flag or nil;

		local min, max = Config.Range[1], Config.Range[2];
		local Slider = Instance.new("Frame")
		local Slider_Name = Instance.new("TextLabel")
		local ValueFrame = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local OptionButton = Instance.new("ImageButton")
		local boxli = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local ValueText = Instance.new("TextLabel")

		if SearchAPI then SearchAPI.Memory(Config.Name); end;

		Slider.Name = Fatality:RandomString()
		Slider.Parent = Parent
		Fatality:Register(Slider, "Element")
		Slider.BackgroundTransparency = 1.000
		Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Slider.BorderSizePixel = 0
		Slider.Size = UDim2.new(1, -25, 0, 17)
		Slider.ZIndex = ZIndex + 1

		Fatality:AddDragBlacklist(Slider);

		Slider_Name.Name = Fatality:RandomString()
		Slider_Name.Parent = Slider
		Slider_Name.AnchorPoint = Vector2.new(0, 0.5)
		Slider_Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Slider_Name.BackgroundTransparency = 1.000
		Slider_Name.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Slider_Name.BorderSizePixel = 0
		Slider_Name.Position = UDim2.new(0, 0, 0.5, 0)
		Slider_Name.Size = UDim2.new(1, 0, 0.800000012, 0)
		Slider_Name.ZIndex = ZIndex + 2
		Slider_Name.FontFace = Fatality.FontSemiBold
		Slider_Name.Text = Config.Name
		
		if Config.Risky then Slider_Name.TextColor3 = Color3.fromRGB(255, 160, 92) else Fatality:Register(Slider_Name, "Text", "TextColor3") end
		
		Slider_Name.TextSize = 13.000
		Slider_Name.TextTransparency = 0.200
		Slider_Name.TextXAlignment = Enum.TextXAlignment.Left

		ValueFrame.Name = Fatality:RandomString()
		ValueFrame.Parent = Slider
		ValueFrame.AnchorPoint = Vector2.new(1, 0.5)
		Fatality:Register(ValueFrame, "Element")
		ValueFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ValueFrame.BorderSizePixel = 0
		ValueFrame.Position = UDim2.new(1, -3, 0.5, 0)
		ValueFrame.Size = UDim2.new(0, 85, 0.600000024, 0)
		ValueFrame.ZIndex = ZIndex + 2

		UICorner.CornerRadius = UDim.new(0, 2)
		UICorner.Parent = ValueFrame

		OptionButton.Name = Fatality:RandomString()
		OptionButton.Parent = ValueFrame
		OptionButton.AnchorPoint = Vector2.new(0, 0.5)
		OptionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		OptionButton.BackgroundTransparency = 1.000
		OptionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		OptionButton.BorderSizePixel = 0
		OptionButton.Position = UDim2.new(0, -20, 0.5, 0)
		OptionButton.Size = UDim2.new(0, 13, 0, 13)
		OptionButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
		OptionButton.Image = "http://www.roblox.com/asset/?id=14007344336"
		OptionButton.ImageTransparency = 0.600
		OptionButton.Visible = Config.Option;
		OptionButton.ZIndex = ZIndex + 1;
		Fatality:Register(OptionButton, "Text", "ImageColor3")

		local initialAlpha = (Config.Default - min) / (max - min)
		boxli.Name = Fatality:RandomString()
		boxli.Parent = ValueFrame
		Fatality:Register(boxli, "Main")
		boxli.BorderColor3 = Color3.fromRGB(0, 0, 0)
		boxli.BorderSizePixel = 0
		boxli.Size = UDim2.new(initialAlpha, 0, 1, 0)
		boxli.ZIndex = ZIndex + 3

		UICorner_2.CornerRadius = UDim.new(0, 2)
		UICorner_2.Parent = boxli

		ValueText.Name = "Information"
		ValueText.Parent = ValueFrame
		ValueText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ValueText.BackgroundTransparency = 1.000
		ValueText.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ValueText.BorderSizePixel = 0
		ValueText.Size = UDim2.new(1, 0, 1, 0)
		ValueText.ZIndex = ZIndex + 4
		ValueText.FontFace = Fatality.FontSemiBold
		ValueText.Text = string.format('%s%s',tostring(Config.Default),tostring(Config.Type));
		ValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
		ValueText.TextSize = 9.000
		ValueText.TextStrokeTransparency = 0.850;
		ValueText.TextTransparency = 0;

		local OpcToggle = function(value)
			if value then
				Fatality:CreateAnimation(boxli,0.45,{ BackgroundTransparency = 0, })
				Fatality:CreateAnimation(OptionButton,0.45,{ ImageTransparency = (Config.Option and 0.600) or 1 })
				Fatality:CreateAnimation(ValueFrame,0.45,{ BackgroundTransparency = 0, })
				Fatality:CreateAnimation(Slider_Name,0.45,{ TextTransparency = 0.200 })
				Fatality:CreateAnimation(ValueText,0.45,{ TextStrokeTransparency = 0.850, TextTransparency = 0; })
			else
				Fatality:CreateAnimation(ValueText,0.45,{ TextStrokeTransparency = 1, TextTransparency = 1; })
				Fatality:CreateAnimation(Slider_Name,0.45,{ TextTransparency = 1 })
				Fatality:CreateAnimation(ValueFrame,0.45,{ BackgroundTransparency = 1, })
				Fatality:CreateAnimation(boxli,0.45,{ BackgroundTransparency = 1, })
				Fatality:CreateAnimation(OptionButton,0.45,{ ImageTransparency = 1 })
			end;
		end;

		OpcToggle(Event:GetAttribute('V'))

		local IsHold = false;
		local function update(Input)
			local alpha = math.clamp((Input.Position.X - ValueFrame.AbsolutePosition.X) / ValueFrame.AbsoluteSize.X, 0, 1)
			local Value = min + alpha * (max - min)

			if Config.Step then Value = math.floor(Value / Config.Step + 0.5) * Config.Step
			elseif typeof(Config.Precise) == "number" and Config.Precise > 0 then Value = Fatality:Rounding(Value, Config.Precise) 
			elseif not Config.Precise or Config.Precise == 0 then Value = math.round(Value) end
			
			Value = math.clamp(Value, min, max)
			local normalizedAlpha = (Value - min) / (max - min)

			TweenService:Create(boxli, TweenInfo.new(0.2), { Size = UDim2.new(normalizedAlpha, 0, 1, 0) }):Play()
			Config.Default = Value
			ValueText.Text = string.format('%s%s', tostring(Value), tostring(Config.Type))
			Config.Callback(Value)
		end;

		do
			ValueFrame.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then IsHold = true; update(Input) end
			end)
			ValueFrame.InputEnded:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then IsHold = false end
			end)
			UserInputService.InputChanged:Connect(function(Input)
				if IsHold and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then update(Input) end
			end);
		end;

		local Respons = Fatality:CreateResponse({
			Rename = function(new_name) Slider_Name.Text = new_name end,
			GetValue = function() return Config.Default; end,
			Signal = Event.Event:Connect(OpcToggle),
			SetValue = function(v, force)
				local IsSame = v == Config.Default;
				v = math.clamp(v, min, max)
				Config.Default = v;
				local normalizedAlpha = (v - min) / (max - min)
				TweenService:Create(boxli, TweenInfo.new(0.2), { Size = UDim2.new(normalizedAlpha, 0, 1, 0) }):Play()
				ValueText.Text = string.format('%s%s', tostring(v), tostring(Config.Type))
				if not IsSame or force then Config.Callback(v); end;
			end,
			Flag = Config.Flag and Config.Flag.."Slider",
			Option = (Config.Option and Fatality:CreateOption(OptionButton)) or nil;
		});

		if Config.Flag then Fatality.WindowFlags[FatalWindow][Config.Flag.."Slider"] = Respons; end;
		Config.Callback(Config.Default)

		return Respons;
	end;

	function elements:AddButton(Config: Button)
		Config = Config or {};
		if not Fatality:CanShow(Config) then return GetDummyElement() end

		Config.Name = Config.Name or "Slider"; Config.Risky = Config.Risky or false; Config.Callback = Config.Callback or function() end;

		local Button = Instance.new("Frame")
		local Button_Name = Instance.new("TextLabel")
		local UICorner = Instance.new("UICorner")

		if SearchAPI then SearchAPI.Memory(Config.Name); end;

		Button.Name = Fatality:RandomString()
		Button.Parent = Parent
		Fatality:Register(Button, "Element")
		Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Button.BorderSizePixel = 0
		Button.Size = UDim2.new(1, -25, 0, 25)
		Button.ZIndex = ZIndex + 1
		Fatality:AddDragBlacklist(Button);

		Button_Name.Name = Fatality:RandomString()
		Button_Name.Parent = Button
		Button_Name.AnchorPoint = Vector2.new(0, 0.5)
		Button_Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Button_Name.BackgroundTransparency = 1.000
		Button_Name.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Button_Name.BorderSizePixel = 0
		Button_Name.Position = UDim2.new(0, 0, 0.5, 0)
		Button_Name.Size = UDim2.new(1, 0, 0.800000012, 0)
		Button_Name.ZIndex = ZIndex + 2
		Button_Name.FontFace = Fatality.FontSemiBold
		Button_Name.Text = Config.Name
		
		if Config.Risky then Button_Name.TextColor3 = Color3.fromRGB(255, 160, 92) else Fatality:Register(Button_Name, "Text", "TextColor3") end
		
		Button_Name.TextSize = 12.000
		Button_Name.TextTransparency = 0.400
		Fatality:ProtectText(Button_Name,Config.Name);

		UICorner.CornerRadius = UDim.new(0, 2)
		UICorner.Parent = Button;

		local OpcToggle = function(value)
			if value then
				Fatality:CreateAnimation(Button_Name,0.45,{ TextTransparency = 0.4, })
				Fatality:CreateAnimation(Button,0.45,{ BackgroundTransparency = 0, })
			else
				Fatality:CreateAnimation(Button_Name,0.45,{ TextTransparency = 1, })
				Fatality:CreateAnimation(Button,0.45,{ BackgroundTransparency = 1, })
			end;
		end;

		OpcToggle(Event:GetAttribute('V'));

		Fatality:CreateHover(Button,function(value)
			if value then Fatality:CreateAnimation(Button,0.25,{ BackgroundColor3 = Fatality:GetColor("Hover") })
			else Fatality:CreateAnimation(Button,0.45,{ BackgroundColor3 = Fatality:GetColor("Element") }) end;
		end)

		Fatality:NewInput(Button,function() Config.Callback(); end)

		return Fatality:CreateResponse({
			Rename = function(new_name) Button_Name.Text = new_name; Fatality:ProtectText(Button_Name,new_name); end,
			GetValue = function() return Config.Default; end,
			Signal = Event.Event:Connect(OpcToggle),
			Fire = Config.Callback,
		})
	end;

	function elements:AddColorPicker(Config: ColorPicker)
		Config = Config or {};
		if not Fatality:CanShow(Config) then return GetDummyElement() end

		Config.Name = Config.Name or "Color Picker"; Config.Option = Config.Option or false; Config.Default = Config.Default or Color3.fromRGB(255, 255, 255); Config.Callback = Config.Callback or function(number) end; Config.Transparency = Config.Transparency or 0; Config.Flag = Config.Flag or nil;

		local ColorPicker = Instance.new("Frame")
		local ColorPicker_Name = Instance.new("TextLabel")
		local ValueFrame = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local OptionButton = Instance.new("ImageButton")

		if SearchAPI then SearchAPI.Memory(Config.Name); end;

		ColorPicker.Name = Fatality:RandomString()
		ColorPicker.Parent = Parent
		Fatality:Register(ColorPicker, "Element")
		ColorPicker.BackgroundTransparency = 1.000
		ColorPicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ColorPicker.BorderSizePixel = 0
		ColorPicker.Size = UDim2.new(1, -25, 0, 17)
		ColorPicker.ZIndex = ZIndex + 1
		Fatality:AddDragBlacklist(ColorPicker);

		ColorPicker_Name.Name = Fatality:RandomString()
		ColorPicker_Name.Parent = ColorPicker
		ColorPicker_Name.AnchorPoint = Vector2.new(0, 0.5)
		ColorPicker_Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ColorPicker_Name.BackgroundTransparency = 1.000
		ColorPicker_Name.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ColorPicker_Name.BorderSizePixel = 0
		ColorPicker_Name.Position = UDim2.new(0, 0, 0.5, 0)
		ColorPicker_Name.Size = UDim2.new(1, 0, 0.800000012, 0)
		ColorPicker_Name.ZIndex = ZIndex + 2
		ColorPicker_Name.FontFace = Fatality.FontSemiBold
		ColorPicker_Name.Text = Config.Name
		Fatality:Register(ColorPicker_Name, "Text", "TextColor3")
		ColorPicker_Name.TextSize = 13.000
		ColorPicker_Name.TextTransparency = 0.200
		ColorPicker_Name.TextXAlignment = Enum.TextXAlignment.Left
		ColorPicker_Name.ZIndex = ZIndex + 2

		ValueFrame.Name = Fatality:RandomString()
		ValueFrame.Parent = ColorPicker
		ValueFrame.AnchorPoint = Vector2.new(1, 0.5)
		ValueFrame.BackgroundColor3 = Config.Default
		ValueFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ValueFrame.BorderSizePixel = 0
		ValueFrame.Position = UDim2.new(1, -3, 0.5, 0)
		ValueFrame.Size = UDim2.new(0, 35, 0.699999988, 0)
		ValueFrame.ZIndex = ZIndex + 3

		UICorner.CornerRadius = UDim.new(0, 2)
		UICorner.Parent = ValueFrame

		OptionButton.Name = Fatality:RandomString()
		OptionButton.Parent = ValueFrame
		OptionButton.AnchorPoint = Vector2.new(0, 0.5)
		OptionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		OptionButton.BackgroundTransparency = 1.000
		OptionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		OptionButton.BorderSizePixel = 0
		OptionButton.Position = UDim2.new(0, -20, 0.5, 0)
		OptionButton.Size = UDim2.new(0, 13, 0, 13)
		OptionButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
		OptionButton.Image = "http://www.roblox.com/asset/?id=14007344336"
		OptionButton.ImageTransparency = 0.600
		OptionButton.ZIndex = 7;
		Fatality:Register(OptionButton, "Text", "ImageColor3")

		local res = Fatality:CreateColorPicker(ValueFrame,Config.Transparency,function(rgb,opc)
			ValueFrame.BackgroundColor3 = rgb;
			ValueFrame.BackgroundTransparency = opc;
			task.spawn(Config.Callback,rgb,opc)
		end);

		local OpcToggle = function(value)
			if value then
				Fatality:CreateAnimation(ColorPicker_Name,0.45,{ TextTransparency = 0.2, })
				Fatality:CreateAnimation(ValueFrame,0.45,{ Size = UDim2.new(0, 35, 0.7, 0) })
				Fatality:CreateAnimation(OptionButton,0.45,{ ImageTransparency = (Config.Option and 0.6) or 1, })
			else
				Fatality:CreateAnimation(ColorPicker_Name,0.45,{ TextTransparency = 1, })
				Fatality:CreateAnimation(ValueFrame,0.45,{ Size = UDim2.new(0, 35, 0, 0) })
				Fatality:CreateAnimation(OptionButton,0.45,{ ImageTransparency = 1, })
			end;
		end;

		OpcToggle(Event:GetAttribute('V'));

		local Respons = Fatality:CreateResponse({
			Rename = function(new_name) ColorPicker.Text = new_name end,
			Signal = Event.Event:Connect(OpcToggle),
			SetValue = function(rgb,opc,force)
				local IsSame = ValueFrame.BackgroundColor3 == rgb or ValueFrame.BackgroundTransparency == opc;
				ValueFrame.BackgroundColor3 = rgb; 
				ValueFrame.BackgroundTransparency = opc;
				res.set_opc(opc);
				if not IsSame or force then task.spawn(Config.Callback,rgb,opc) end;
			end,
			GetValue = function() return { Color = ValueFrame.BackgroundColor3, Transparency = ValueFrame.BackgroundTransparency }; end,
			Flag = Config.Flag and Config.Flag.."ColorPicker",
			Option = (Config.Option and Fatality:CreateOption(OptionButton)) or nil;
		});

		if Config.Flag then Fatality.WindowFlags[FatalWindow][Config.Flag.."ColorPicker"] = Respons; end;
		if Config.Default then task.spawn(Config.Callback, Config.Default, Config.Transparency) end

		return Respons;
	end;

	function elements:AddParagraph(settings)
		settings = settings or {}
		if not Fatality:CanShow(settings) then return GetDummyElement() end

		settings.Title = settings.Title or "Paragraph"
		settings.Content = settings.Content or "This is some default content."

		local Paragraph = Instance.new("Frame")
		Paragraph.Name = Fatality:RandomString()
		Paragraph.Parent = Parent
		Fatality:Register(Paragraph, "Element")
		Paragraph.BackgroundTransparency = 1.000
		Paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Paragraph.BorderSizePixel = 0
		Paragraph.Size = UDim2.new(1, -25, 0, 0) 
		Paragraph.ZIndex = ZIndex + 1
		Paragraph.ClipsDescendants = true
		Paragraph.AutomaticSize = Enum.AutomaticSize.Y

		local listLayout = Instance.new("UIListLayout")
		listLayout.Parent = Paragraph
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 3)

		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Name = "Title"
		TitleLabel.Parent = Paragraph
		TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TitleLabel.BackgroundTransparency = 1.000
		TitleLabel.Size = UDim2.new(1, 0, 0, 15)
		TitleLabel.ZIndex = ZIndex + 2
		TitleLabel.FontFace = Fatality.FontSemiBold
		TitleLabel.Text = settings.Title
		Fatality:Register(TitleLabel, "Text", "TextColor3")
		TitleLabel.TextSize = 13.000
		TitleLabel.TextTransparency = 1
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

		local ContentLabel = Instance.new("TextLabel")
		ContentLabel.Name = "Content"
		ContentLabel.Parent = Paragraph
		ContentLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ContentLabel.BackgroundTransparency = 1.000
		ContentLabel.Size = UDim2.new(1, 0, 0, 0)
		ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
		ContentLabel.ZIndex = ZIndex + 2
		ContentLabel.FontFace = Fatality.FontSemiBold
		ContentLabel.Text = settings.Content
		Fatality:Register(ContentLabel, "TextDark", "TextColor3")
		ContentLabel.TextSize = 12.000
		ContentLabel.TextTransparency = 1
		ContentLabel.TextWrapped = true
		ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
		ContentLabel.TextYAlignment = Enum.TextYAlignment.Top

		local OpcToggle = function(value)
			if value then
				Fatality:CreateAnimation(TitleLabel, 0.45, { TextTransparency = 0.200 })
				Fatality:CreateAnimation(ContentLabel, 0.45, { TextTransparency = 0.400 })
			else
				Fatality:CreateAnimation(TitleLabel, 0.45, { TextTransparency = 1 })
				Fatality:CreateAnimation(ContentLabel, 0.45, { TextTransparency = 1 })
			end
		end

		OpcToggle(Event:GetAttribute('V'))
		Event.Event:Connect(OpcToggle)
		return {}
	end;

	function elements:AddInput(settings)
		settings = settings or {}
		if not Fatality:CanShow(settings) then return GetDummyElement() end

		settings.Name = settings.Name or "Input"
		settings.PlaceholderText = settings.PlaceholderText or "..."
		settings.Default = settings.Default or ""
		settings.Callback = settings.Callback or function(text) end

		local InputFrame = Instance.new("Frame")
		local NameLabel = Instance.new("TextLabel")
		local TextBoxFrame = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local TextBox = Instance.new("TextBox")

		InputFrame.Name = Fatality:RandomString()
		InputFrame.Parent = Parent
		Fatality:Register(InputFrame, "Element")
		InputFrame.BackgroundTransparency = 1.000
		InputFrame.Size = UDim2.new(1, -25, 0, 17)
		InputFrame.ZIndex = ZIndex + 1

		NameLabel.Name = "NameLabel"
		NameLabel.Parent = InputFrame
		NameLabel.AnchorPoint = Vector2.new(0, 0.5)
		NameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		NameLabel.BackgroundTransparency = 1.000
		NameLabel.Position = UDim2.new(0, 0, 0.5, 0)
		NameLabel.Size = UDim2.new(0.5, 0, 0.8, 0)
		NameLabel.ZIndex = ZIndex + 2
		NameLabel.FontFace = Fatality.FontSemiBold
		NameLabel.Text = settings.Name
		Fatality:Register(NameLabel, "Text", "TextColor3")
		NameLabel.TextSize = 13.000
		NameLabel.TextTransparency = 1
		NameLabel.TextXAlignment = Enum.TextXAlignment.Left

		TextBoxFrame.Name = "TextBoxFrame"
		TextBoxFrame.Parent = InputFrame
		TextBoxFrame.AnchorPoint = Vector2.new(1, 0.5)
		Fatality:Register(TextBoxFrame, "Element")
		TextBoxFrame.Position = UDim2.new(1, -3, 0.5, 0)
		TextBoxFrame.Size = UDim2.new(0, 85, 0.85, 0)
		TextBoxFrame.ZIndex = ZIndex + 2

		UICorner.CornerRadius = UDim.new(0, 2)
		UICorner.Parent = TextBoxFrame

		TextBox.Name = "InputTextBox"
		TextBox.Parent = TextBoxFrame
		TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextBox.BackgroundTransparency = 1.000
		TextBox.Size = UDim2.new(1, -10, 1, 0)
		TextBox.Position = UDim2.new(0.5, 0, 0.5, 0)
		TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
		TextBox.ZIndex = ZIndex + 3
		TextBox.FontFace = Fatality.FontSemiBold
		TextBox.Text = settings.Default
		TextBox.PlaceholderText = settings.PlaceholderText
		Fatality:Register(TextBox, "Text", "TextColor3")
		TextBox.PlaceholderColor3 = Color3.fromRGB(128, 128, 128)
		TextBox.TextSize = 11.000
		TextBox.TextXAlignment = Enum.TextXAlignment.Left
		TextBox.ClearTextOnFocus = false
		TextBox.TextTransparency = 1

		TextBox.FocusLost:Connect(function(enterPressed) settings.Callback(TextBox.Text) end)

		local OpcToggle = function(value)
			if value then
				Fatality:CreateAnimation(NameLabel, 0.45, { TextTransparency = 0.200 })
				Fatality:CreateAnimation(TextBoxFrame, 0.45, { BackgroundTransparency = 0 })
				Fatality:CreateAnimation(TextBox, 0.45, { TextTransparency = 0.400 })
			else
				Fatality:CreateAnimation(NameLabel, 0.45, { TextTransparency = 1 })
				Fatality:CreateAnimation(TextBoxFrame, 0.45, { BackgroundTransparency = 1 })
				Fatality:CreateAnimation(TextBox, 0.45, { TextTransparency = 1 })
			end
		end

		OpcToggle(Event:GetAttribute('V'))
		Event.Event:Connect(OpcToggle)

		local Response = { Set = function(text) TextBox.Text = tostring(text) end }
		if settings.Default ~= "" then settings.Callback(settings.Default) end
		
		return Response
	end;

	function elements:AddMetric(Config)
		Config = Config or {}
		if not Fatality:CanShow(Config) then return GetDummyElement() end

		Config.Name = Config.Name or "Metric"
		Config.Default = Config.Default or "..."
		Config.ButtonIcon = Config.ButtonIcon or nil
		Config.Callback = Config.Callback or nil

		local MetricFrame = Instance.new("Frame")
		local NameLabel = Instance.new("TextLabel")
		local ValueLabel = Instance.new("TextLabel")
		local ActionButton = nil
		local UICornerBtn = nil

		MetricFrame.Name = Fatality:RandomString()
		MetricFrame.Parent = Parent
		Fatality:Register(MetricFrame, "Element")
		MetricFrame.BackgroundTransparency = 1.000
		MetricFrame.BorderSizePixel = 0
		MetricFrame.Size = UDim2.new(1, -25, 0, 17)
		MetricFrame.ZIndex = ZIndex + 1

		NameLabel.Name = "MetricName"
		NameLabel.Parent = MetricFrame
		NameLabel.AnchorPoint = Vector2.new(0, 0.5)
		NameLabel.BackgroundTransparency = 1.000
		NameLabel.Position = UDim2.new(0, 0, 0.5, 0)
		NameLabel.Size = UDim2.new(0.5, 0, 0.8, 0)
		NameLabel.ZIndex = ZIndex + 2
		NameLabel.FontFace = Fatality.FontSemiBold
		NameLabel.Text = Config.Name
		Fatality:Register(NameLabel, "TextDark", "TextColor3") 
		NameLabel.TextSize = 12.000
		NameLabel.TextXAlignment = Enum.TextXAlignment.Left

		local valueOffset = Config.ButtonIcon and -22 or 0 
		
		ValueLabel.Name = "MetricValue"
		ValueLabel.Parent = MetricFrame
		ValueLabel.AnchorPoint = Vector2.new(1, 0.5)
		ValueLabel.BackgroundTransparency = 1.000
		ValueLabel.Position = UDim2.new(1, valueOffset, 0.5, 0)
		ValueLabel.Size = UDim2.new(0.5, 0, 0.8, 0)
		ValueLabel.ZIndex = ZIndex + 2
		ValueLabel.FontFace = Fatality.FontSemiBold
		ValueLabel.Text = tostring(Config.Default)
		Fatality:Register(ValueLabel, "Text", "TextColor3") 
		ValueLabel.TextSize = 12.000
		ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

		if Config.ButtonIcon and Config.Callback then
			ActionButton = Instance.new("ImageButton")
			ActionButton.Name = "MetricAction"
			ActionButton.Parent = MetricFrame
			ActionButton.AnchorPoint = Vector2.new(1, 0.5)
			ActionButton.BackgroundTransparency = 1.000
			ActionButton.Position = UDim2.new(1, 0, 0.5, 0)
			ActionButton.Size = UDim2.new(0, 14, 0, 14)
			ActionButton.ZIndex = ZIndex + 3
			ActionButton.Image = Fatality:GetIcon(Config.ButtonIcon)
			ActionButton.ImageTransparency = 0.4
			Fatality:Register(ActionButton, "Text", "ImageColor3")

			Fatality:CreateHover(ActionButton, function(bool)
				if bool then Fatality:CreateAnimation(ActionButton, 0.2, { ImageTransparency = 0 })
				else Fatality:CreateAnimation(ActionButton, 0.2, { ImageTransparency = 0.4 }) end
			end)

			ActionButton.MouseButton1Click:Connect(function()
				Fatality:CreateAnimation(ActionButton, 0.1, { Size = UDim2.new(0, 11, 0, 11) })
				task.delay(0.1, function() Fatality:CreateAnimation(ActionButton, 0.1, { Size = UDim2.new(0, 14, 0, 14) }) end)
				Config.Callback(ValueLabel.Text)
			end)
		end

		local OpcToggle = function(value)
			if value then
				Fatality:CreateAnimation(NameLabel, 0.45, { TextTransparency = 0 })
				Fatality:CreateAnimation(ValueLabel, 0.45, { TextTransparency = 0 })
				if ActionButton then Fatality:CreateAnimation(ActionButton, 0.45, { ImageTransparency = 0.4 }) end
			else
				Fatality:CreateAnimation(NameLabel, 0.45, { TextTransparency = 1 })
				Fatality:CreateAnimation(ValueLabel, 0.45, { TextTransparency = 1 })
				if ActionButton then Fatality:CreateAnimation(ActionButton, 0.45, { ImageTransparency = 1 }) end
			end
		end

		OpcToggle(Event:GetAttribute('V'))
		Event.Event:Connect(OpcToggle)

		local Response = {
			Set = function(self, newText)
				local strText = tostring(newText)
				if ValueLabel.Text == strText then return end
				ValueLabel.Text = strText
			end,
			SetName = function(self, newName) NameLabel.Text = tostring(newName) end,
			Get = function(self) return ValueLabel.Text end
		}
		
		return Response
	end; 

	return elements;
end;

function Fatality.new(Window: Window)
	Window = Window or {};
	Window.Name = Window.Name or "FATALITY";
	Window.Scale = Window.Scale or UDim2.new(0, 750, 0, 500);
	Window.Keybind = Window.Keybind or "Insert";
	Window.Expire = Window.Expire or "never";

	local OriginalSize = Window.Scale
	local CurrentKeybind = Window.Keybind

	local Fatal = {
		Menus = {},
		ElementContents = {},
		MenuSelected = nil,
		Toggle = true,
		Signal = Instance.new('BindableEvent');
	};

	Fatal.Notifier = Fatality.__NOTIFIER_CACHE or Fatality:CreateNotifier();

	local function GetSafeColor(val)
		if typeof(val) == "ColorSequence" then return val.Keypoints[1].Value end
		return val
	end

	local Fatalitywin = Instance.new("ScreenGui")
	Fatalitywin.Enabled = false 
	Fatal.Main = Fatalitywin 
	
	local FatalFrame = Instance.new("Frame")
	local MainScale = Instance.new("UIScale")
	MainScale.Parent = FatalFrame
	MainScale.Scale = 1 

	local UICorner = Instance.new("UICorner")
	local DropShadow = Instance.new("ImageLabel")
	local Header = Instance.new("Frame")
	local HeaderLine = Instance.new("Frame")
	local UICorner_2 = Instance.new("UICorner")
	local HeaderText = Instance.new("TextLabel")
	local MenuButtonCont = Instance.new("Frame")
	local tbc = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local UserProfle = Instance.new("Frame")
	local UserIcon = Instance.new("ImageLabel")
	local UICorner_3 = Instance.new("UICorner")
	local UIStroke = Instance.new("UIStroke")
	local User_name = Instance.new("TextLabel")
	local expire_days = Instance.new("TextLabel")
	local HeaderLineShadow = Instance.new("Frame")
	local UIGradient = Instance.new("UIGradient")
	local UICorner_4 = Instance.new("UICorner")
	local MenuFrame = Instance.new("Frame")
	local Bottom = Instance.new("Frame")
	local HeaderLine_2 = Instance.new("Frame")
	local UICorner_5 = Instance.new("UICorner")
	local HeaderLineShadow_2 = Instance.new("Frame")
	local UIGradient_2 = Instance.new("UIGradient")
	local UICorner_6 = Instance.new("UICorner")
	local InfoButton = Instance.new("ImageButton")
	local SearchButton = Instance.new("ImageButton")
	local SaveButton = Instance.new("ImageButton")

	Fatality.WindowFlags[Fatalitywin] = {};
	Fatality:ScrollSignal(tbc,UIListLayout,'X');

	FatalFrame:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
		if FatalFrame.BackgroundTransparency >= 0.99 then Fatalitywin.Enabled = false;
		else Fatalitywin.Enabled = true; end;
	end);

	local ToggleUI = function(bool)
		Fatal.Signal:Fire(bool);

		if bool then
			for i,v in next , Fatal.Menus do v.ValueSelect(false); end;
			if Fatal.MenuSelected then Fatal.MenuSelected.ValueSelect(true) end

			Fatality:CreateAnimation(FatalFrame,0.15,{ Size = Window.Scale, BackgroundTransparency = 0 })
			Fatality:CreateAnimation(Header,0.5,{ BackgroundTransparency = 0 })
			Fatality:CreateAnimation(HeaderLine,0.5,{ BackgroundTransparency = 0 })
			Fatality:CreateAnimation(Bottom,0.5,{ BackgroundTransparency = 0 })
			Fatality:CreateAnimation(HeaderLine_2,0.5,{ BackgroundTransparency = 0 })
			Fatality:CreateAnimation(HeaderLineShadow,0.5,{ BackgroundTransparency = 0.5 })
			Fatality:CreateAnimation(HeaderLineShadow_2,0.5,{ BackgroundTransparency = 0.5 })
			Fatality:CreateAnimation(InfoButton,0.25,{ ImageTransparency = 0.5 })
			Fatality:CreateAnimation(SearchButton,0.25,{ ImageTransparency = 0.5 })
			Fatality:CreateAnimation(SaveButton,0.25,{ ImageTransparency = 0.5 })
			Fatality:CreateAnimation(HeaderText,0.35,{ TextStrokeTransparency = 0.640, TextTransparency = 0 })
			Fatality:CreateAnimation(UserIcon,0.45,{ ImageTransparency = 0, Position = UDim2.new(1, -10,0.5, 0) })
			Fatality:CreateAnimation(User_name,0.35,{ TextTransparency = 0, Position = UDim2.new(1, -40,0, 3) })
			Fatality:CreateAnimation(expire_days,0.5,{ TextTransparency = 0, Position = UDim2.new(1, -40,0, 16) })
			Fatality:CreateAnimation(UIStroke,0.35,{ Thickness = 2.500, Transparency = 0.900 })
			Fatality:CreateAnimation(InfoButton,0.1,Enum.EasingStyle.Back,{ Position = UDim2.new(1, -5,0.5, 0) })
			Fatality:CreateAnimation(SearchButton,0.1,Enum.EasingStyle.Back,{ Position = UDim2.new(0,10,0.5, 0) })
			Fatality:CreateAnimation(SaveButton,0.1,Enum.EasingStyle.Back,{ Position = UDim2.new(0,35,0.5, 0) })
			Fatality:CreateAnimation(DropShadow,0.35,{ ImageTransparency = 0.75 })
		else
			table.clear(Fatality.DragBlacklist);
			for i,v in next , Fatal.Menus do v.ValueSelect(false); end;

			SaveButton.Position = UDim2.new(0,35,1, 20)
			SearchButton.Position = UDim2.new(0,10,1, 20)
			InfoButton.Position = UDim2.new(1, -5,1, 20)
			UIStroke.Thickness = 0
			UIStroke.Transparency = 1
			UserIcon.ImageTransparency = 1
			UserIcon.Position = UDim2.new(1, -10,0.5, 0)
			User_name.TextTransparency = 1
			User_name.Position = UDim2.new(1, -40,0, 3)
			expire_days.TextTransparency = 1
			expire_days.Position = UDim2.new(1, -40,0, 16)
			HeaderText.TextStrokeTransparency = 1
			HeaderText.TextTransparency = 1
			HeaderLineShadow_2.BackgroundTransparency = 1
			InfoButton.ImageTransparency = 1
			SearchButton.ImageTransparency = 1
			SaveButton.ImageTransparency = 1
			HeaderLineShadow.BackgroundTransparency = 1
			FatalFrame.BackgroundTransparency = 1
			Header.BackgroundTransparency = 1
			HeaderLine.BackgroundTransparency = 1
			Bottom.BackgroundTransparency = 1
			HeaderLine_2.BackgroundTransparency = 1
			DropShadow.ImageTransparency = 1
		end
	end

	Fatalitywin.Name = Fatality:RandomString();
	Fatalitywin.Parent = CoreGui;
	Fatalitywin.ResetOnSpawn = false;
	Fatalitywin.IgnoreGuiInset = true;
	Fatalitywin.ZIndexBehavior = Enum.ZIndexBehavior.Global;
	table.insert(Fatality.Windows,Fatalitywin)
	protect_gui(Fatalitywin);

	FatalFrame.Active = true;
	FatalFrame.Name = Fatality:RandomString()
	FatalFrame.Parent = Fatalitywin
	FatalFrame.AnchorPoint = Vector2.new(0.5, 0)
	Fatality:Register(FatalFrame, "Background")
	FatalFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	FatalFrame.BorderSizePixel = 0
	FatalFrame.Position = UDim2.new(0.5, 0, 0.2);
	FatalFrame.Size = Window.Scale;
	FatalFrame.ClipsDescendants = true
	UICorner.CornerRadius = UDim.new(0, 5)
	UICorner.Parent = FatalFrame

	DropShadow.Name = Fatality:RandomString()
	DropShadow.Parent = FatalFrame
	DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow.BackgroundTransparency = 1.000
	DropShadow.BorderSizePixel = 0
	DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow.Size = UDim2.new(1, 47, 1, 47)
	DropShadow.ZIndex = -1
	DropShadow.Image = "rbxassetid://6014261993"
	Fatality:Register(DropShadow, "Outline", "ImageColor3")
	DropShadow.ImageTransparency = 1
	DropShadow.ScaleType = Enum.ScaleType.Slice
	DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
	DropShadow.Rotation = 0.001

	Header.Name = Fatality:RandomString()
	Header.Parent = FatalFrame
	Header.Active = true
	Fatality:Register(Header, "Container")
	Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Header.BorderSizePixel = 0
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.ZIndex = 2
	HeaderLine.Name = Fatality:RandomString()
	HeaderLine.Parent = Header
	HeaderLine.AnchorPoint = Vector2.new(0, 1)
	Fatality:Register(HeaderLine, "Stroke")
	HeaderLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
	HeaderLine.BorderSizePixel = 0
	HeaderLine.Position = UDim2.new(0, 0, 1, 0)
	HeaderLine.Size = UDim2.new(1, 0, 0, 1)
	HeaderLine.ZIndex = 3
	UICorner_2.CornerRadius = UDim.new(0, 5)
	UICorner_2.Parent = Header

	HeaderText.Name = Fatality:RandomString()
	HeaderText.Parent = Header
	HeaderText.AnchorPoint = Vector2.new(0, 0.5)
	HeaderText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HeaderText.BackgroundTransparency = 1.000
	HeaderText.BorderColor3 = Color3.fromRGB(0, 0, 0)
	HeaderText.BorderSizePixel = 0
	HeaderText.Position = UDim2.new(0, 5, 0.5, 0)
	HeaderText.Size = UDim2.new(0, 100, 0.699999988, 0)
	HeaderText.ZIndex = 4
	HeaderText.FontFace = Fatality.Fonts.Bold
	HeaderText.Text = Window.Name
	Fatality:Register(HeaderText, "Text", "TextColor3")
	HeaderText.TextSize = 21.000
	HeaderText.TextStrokeColor3 = Color3.fromRGB(205, 67, 218)
	HeaderText.TextStrokeTransparency = 0.640

	MenuButtonCont.Name = Fatality:RandomString()
	MenuButtonCont.Parent = Header
	MenuButtonCont.AnchorPoint = Vector2.new(0, 0.5)
	MenuButtonCont.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MenuButtonCont.BackgroundTransparency = 1.000
	MenuButtonCont.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MenuButtonCont.BorderSizePixel = 0
	MenuButtonCont.ClipsDescendants = true
	MenuButtonCont.Position = UDim2.new(0, 115, 0.5, 0)
	MenuButtonCont.Size = UDim2.new(1, -275, 0.75, 0)
	MenuButtonCont.ZIndex = 4
	tbc.Name = Fatality:RandomString()
	tbc.Parent = MenuButtonCont
	tbc.Active = true
	tbc.AnchorPoint = Vector2.new(0.5, 0.5)
	tbc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	tbc.BackgroundTransparency = 1.000
	tbc.BorderColor3 = Color3.fromRGB(0, 0, 0)
	tbc.BorderSizePixel = 0
	tbc.ClipsDescendants = false
	tbc.Position = UDim2.new(0.5, 0, 0.5, 0)
	tbc.Size = UDim2.new(1, -2, 1, 0)
	tbc.ZIndex = 4
	tbc.CanvasSize = UDim2.new(2, 0, 0, 0)
	tbc.ScrollBarThickness = 0
	UIListLayout.Parent = tbc
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIListLayout.Padding = UDim.new(0, 4)

	UserProfle.Name = Fatality:RandomString()
	UserProfle.Parent = Header
	UserProfle.AnchorPoint = Vector2.new(1, 0.5)
	UserProfle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	UserProfle.BackgroundTransparency = 1.000
	UserProfle.BorderColor3 = Color3.fromRGB(0, 0, 0)
	UserProfle.BorderSizePixel = 0
	UserProfle.Position = UDim2.new(1, -5, 0.5, 0)
	UserProfle.Size = UDim2.new(0, 150, 0.75, 0)
	UserProfle.ZIndex = 4
	UserIcon.Name = Fatality:RandomString()
	UserIcon.Parent = UserProfle
	UserIcon.AnchorPoint = Vector2.new(1, 0.5)
	UserIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	UserIcon.BackgroundTransparency = 1.000
	UserIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	UserIcon.BorderSizePixel = 0
	UserIcon.Position = UDim2.new(1, -10, 0.5, 0)
	UserIcon.Size = UDim2.new(0.800000012, 0, 0.800000012, 0)
	UserIcon.SizeConstraint = Enum.SizeConstraint.RelativeYY
	UserIcon.ZIndex = 5
	UserIcon.Image = Players:GetUserThumbnailAsync(Client.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size180x180);
	UICorner_3.CornerRadius = UDim.new(1, 0)
	UICorner_3.Parent = UserIcon
	UIStroke.Thickness = 2.500
	UIStroke.Transparency = 0.900
	UIStroke.Parent = UserIcon
	User_name.Name = Fatality:RandomString()
	User_name.Parent = UserProfle
	User_name.AnchorPoint = Vector2.new(1, 0)
	User_name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	User_name.BackgroundTransparency = 1.000
	User_name.BorderColor3 = Color3.fromRGB(0, 0, 0)
	User_name.BorderSizePixel = 0
	User_name.Position = UDim2.new(1, -40, 0, 3)
	User_name.Size = UDim2.new(0, 200, 0, 15)
	User_name.ZIndex = 4
	User_name.FontFace = Fatality.Fonts.Medium	
	User_name.Text = Client.DisplayName;
	Fatality:Register(User_name, "Text", "TextColor3")
	User_name.TextSize = 13.000
	User_name.TextStrokeTransparency = 0.700
	User_name.TextXAlignment = Enum.TextXAlignment.Right
	expire_days.Name = Fatality:RandomString()
	expire_days.Parent = UserProfle
	expire_days.AnchorPoint = Vector2.new(1, 0)
	expire_days.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	expire_days.BackgroundTransparency = 1.000
	expire_days.BorderColor3 = Color3.fromRGB(0, 0, 0)
	expire_days.BorderSizePixel = 0
	expire_days.Position = UDim2.new(1, -40, 0, 16)
	expire_days.Size = UDim2.new(0, 200, 0, 15)
	expire_days.ZIndex = 4
	expire_days.FontFace = Fatality.Fonts.Medium
	Fatality:Register(expire_days, "Text", "TextColor3")
	expire_days.Text = string.format("<font transparency=\"0.5\">expires:</font> <font color=\"#f53174\">%s</font>",Window.Expire)
	expire_days.TextSize = 12.000
	expire_days.TextStrokeTransparency = 0.700
	expire_days.TextXAlignment = Enum.TextXAlignment.Right
	expire_days.RichText = true;

	HeaderLineShadow.Name = Fatality:RandomString()
	HeaderLineShadow.Parent = Header
	HeaderLineShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	HeaderLineShadow.BorderColor3 = Color3.fromRGB(0, 0, 0)
	HeaderLineShadow.BorderSizePixel = 0
	HeaderLineShadow.Size = UDim2.new(1, 0, 1, 10)
	UIGradient.Rotation = 90
	UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
	UIGradient.Parent = HeaderLineShadow
	UICorner_4.CornerRadius = UDim.new(0, 5)
	UICorner_4.Parent = HeaderLineShadow

	MenuFrame.Name = Fatality:RandomString()
	MenuFrame.Parent = FatalFrame
	MenuFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MenuFrame.BackgroundTransparency = 1.000
	MenuFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MenuFrame.BorderSizePixel = 0
	MenuFrame.Position = UDim2.new(0, 0, 0, 50)
	MenuFrame.Size = UDim2.new(1, 0, 1, -82)

	Bottom.Name = Fatality:RandomString()
	Bottom.Parent = FatalFrame
	Bottom.Active = true
	Bottom.AnchorPoint = Vector2.new(0, 1)
	Fatality:Register(Bottom, "Container")
	Bottom.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Bottom.BorderSizePixel = 0
	Bottom.Position = UDim2.new(0, 0, 1, 0)
	Bottom.Size = UDim2.new(1, 0, 0, 25)
	Bottom.ZIndex = 2
	HeaderLine_2.Name = Fatality:RandomString()
	HeaderLine_2.Parent = Bottom
	Fatality:Register(HeaderLine_2, "Stroke")
	HeaderLine_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	HeaderLine_2.BorderSizePixel = 0
	HeaderLine_2.Size = UDim2.new(1, 0, 0, 1)
	HeaderLine_2.ZIndex = 3
	UICorner_5.CornerRadius = UDim.new(0, 4)
	UICorner_5.Parent = Bottom
	HeaderLineShadow_2.Name = Fatality:RandomString()
	HeaderLineShadow_2.Parent = Bottom
	HeaderLineShadow_2.AnchorPoint = Vector2.new(0, 1)
	HeaderLineShadow_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	HeaderLineShadow_2.BackgroundTransparency = 0.500
	HeaderLineShadow_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	HeaderLineShadow_2.BorderSizePixel = 0
	HeaderLineShadow_2.Position = UDim2.new(0, 0, 1, 0)
	HeaderLineShadow_2.Size = UDim2.new(1, 0, 1, 5)
	UIGradient_2.Rotation = -90
	UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
	UIGradient_2.Parent = HeaderLineShadow_2
	UICorner_6.CornerRadius = UDim.new(0, 5)
	UICorner_6.Parent = HeaderLineShadow_2

	
	InfoButton.Name = Fatality:RandomString()
	InfoButton.Parent = Bottom
	InfoButton.AnchorPoint = Vector2.new(1, 0.5)
	InfoButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	InfoButton.BackgroundTransparency = 1.000
	InfoButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	InfoButton.BorderSizePixel = 0
	InfoButton.Position = UDim2.new(1, -5, 0.5, 0)
	InfoButton.Size = UDim2.new(0, 16, 0, 16)
	InfoButton.ZIndex = 4
	InfoButton.Image = "rbxassetid://10723415903"
	InfoButton.ImageTransparency = 0.500
	Fatality:Register(InfoButton, "Text", "ImageColor3")

	SearchButton.Name = Fatality:RandomString()
	SearchButton.Parent = Bottom
	SearchButton.AnchorPoint = Vector2.new(0, 0.5)
	SearchButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SearchButton.BackgroundTransparency = 1.000
	SearchButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	SearchButton.BorderSizePixel = 0
	SearchButton.Position = UDim2.new(0, 10, 0.5, 0)
	SearchButton.Size = UDim2.new(0, 16, 0, 16)
	SearchButton.ZIndex = 4
	SearchButton.Image = "rbxassetid://10734943674"
	SearchButton.ImageTransparency = 0.500
	Fatality:Register(SearchButton, "Text", "ImageColor3")

	Fatality:CreateHover(SaveButton,function(bool) if bool then Fatality:CreateAnimation(SaveButton,0.5,{ ImageTransparency = 0.1 }) else Fatality:CreateAnimation(SaveButton,0.5,{ ImageTransparency = 0.5 }) end	end);
	Fatality:CreateHover(InfoButton,function(bool) if bool then Fatality:CreateAnimation(InfoButton,0.5,{ ImageTransparency = 0.1 }) else Fatality:CreateAnimation(InfoButton,0.5,{ ImageTransparency = 0.5 }) end	end);
	Fatality:CreateHover(SearchButton,function(bool) if bool then Fatality:CreateAnimation(SearchButton,0.5,{ ImageTransparency = 0.1 }) else Fatality:CreateAnimation(SearchButton,0.5,{ ImageTransparency = 0.5 }) end	end);

	function Fatal:AddSave(callback) SaveButton.MouseButton1Click:Connect(callback); end;

	Fatality:Drag(FatalFrame,FatalFrame,0.1);
	Fatality:Drag(Header, FatalFrame, 0.1)
	Fatality:Drag(Bottom, FatalFrame, 0.1)
	Fatality:Drag(MenuFrame, FatalFrame, 0.1)

	UserInputService.InputBegan:Connect(function(input,istyping)
		if not istyping then
			local keyPressed = input.KeyCode
			local isMatch = false
			if typeof(CurrentKeybind) == "string" then
				if keyPressed.Name == CurrentKeybind or tostring(keyPressed) == CurrentKeybind then isMatch = true end
			elseif typeof(CurrentKeybind) == "EnumItem" then
				if keyPressed == CurrentKeybind then isMatch = true end
			end
			if isMatch then
				Fatal.Toggle = not Fatal.Toggle;
				ToggleUI(Fatal.Toggle);
			end;
		end
	end)

	function Fatal:SetUsername(name: string) User_name.Text = name or Client.DisplayName; end;
	function Fatal:SetProfile(icon: string) UserIcon.Image = icon or Players:GetUserThumbnailAsync(Client.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size180x180); end;
	function Fatal:SetExpire(str: string) expire_days.Text = string.format("<font transparency=\"0.5\">expires:</font> <font color=\"#f53174\">%s</font>",str) end;
	
	function Fatal:SetScale(percent: number) 
		Fatality.Scale = percent / 100 
		MainScale.Scale = Fatality.Scale 
		for _, scaleObj in pairs(Fatality.ScalesRegistry) do
			if scaleObj and scaleObj.Parent then
				scaleObj.Scale = Fatality.Scale
			end
		end
	end
	
	function Fatal:SetKeybind(key) CurrentKeybind = key end
	function Fatal:GetFlags() return Fatality.WindowFlags[Fatalitywin]; end;

	function Fatal:AddMenu(Menu : Menu) 
		Menu = Menu or {};
        if not Fatality:CanShow(Menu) then return { AddSection = function() return Fatality.Dummy end, AddPreview = function() return Fatality.Dummy end, AddProduct = function() return {SetButton=function()end, SetStatus=function()end, SetVisible=function()end, GetButton=function() return Instance.new("TextButton") end} end, AddColumnTitle = function() end } end
		Menu.Name = Menu.Name or "EXAMPLE";
		Menu.Icon = Menu.Icon or "eye";
		Menu.AutoFill = false; 

		local MenuLib = {};
		local MenuButton = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local UIStroke = Instance.new("UIStroke")
		local Icon = Instance.new("ImageLabel")
		local UICorner_2 = Instance.new("UICorner")
		local menu_name = Instance.new("TextLabel")

		MenuButton.Name = Fatality:RandomString()
		MenuButton.Parent = tbc;
		Fatality:Register(MenuButton, "TabActive") 
		MenuButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		MenuButton.BorderSizePixel = 0
		MenuButton.Size = UDim2.new(0, 90, 0.85, 0)
		MenuButton.ZIndex = 5
		UICorner.CornerRadius = UDim.new(0, 3)
		UICorner.Parent = MenuButton
		UIStroke.Transparency = 0.950
		UIStroke.Parent = MenuButton
		Icon.Name = Fatality:RandomString()
		Icon.Parent = MenuButton
		Icon.AnchorPoint = Vector2.new(0, 0.5)
		Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Icon.BackgroundTransparency = 1.000
		Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Icon.BorderSizePixel = 0
		Icon.Position = UDim2.new(0, 5, 0.5, 0)
		Icon.Size = UDim2.new(0.800000012, 0, 0.800000012, 0)
		Icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
		Icon.ZIndex = 5
		Icon.Image = Fatality:GetIcon(Menu.Icon);
		Fatality:Register(Icon, "Text", "ImageColor3")
		Icon.ScaleType = Enum.ScaleType.Crop
		UICorner_2.CornerRadius = UDim.new(1, 0)
		UICorner_2.Parent = Icon
		menu_name.Name = Fatality:RandomString()
		menu_name.Parent = MenuButton
		menu_name.AnchorPoint = Vector2.new(0, 0.5)
		menu_name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		menu_name.BackgroundTransparency = 1.000
		menu_name.BorderColor3 = Color3.fromRGB(0, 0, 0)
		menu_name.BorderSizePixel = 0
		menu_name.Position = UDim2.new(0, 28, 0.5, 0)
		menu_name.Size = UDim2.new(1, 0, 1, 0)
		menu_name.ZIndex = 5
		menu_name.FontFace = Fatality.Fonts.Bold
		menu_name.Text = Menu.Name
		Fatality:Register(menu_name, "Text", "TextColor3") 
		menu_name.TextSize = 13.000
		menu_name.TextStrokeTransparency = 0.900
		menu_name.TextTransparency = 0.150
		menu_name.TextXAlignment = Enum.TextXAlignment.Left
		local text_size = Fatality:GetTextSize(menu_name);
		MenuButton.Size = UDim2.new(0, text_size.X + 33, 0.85, 0)

		local MenuLiber = Instance.new("Frame")
		local Left = Instance.new("ScrollingFrame")
		local UIListLayout = Instance.new("UIListLayout")
		local Center = Instance.new("ScrollingFrame")
		local UIListLayout_2 = Instance.new("UIListLayout")
		local Right = Instance.new("ScrollingFrame")
		local UIListLayout_3 = Instance.new("UIListLayout")

		MenuLiber.Name = Fatality:RandomString()
		MenuLiber.Parent = MenuFrame
		MenuLiber.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		MenuLiber.BackgroundTransparency = 1.000
		MenuLiber.BorderColor3 = Color3.fromRGB(0, 0, 0)
		MenuLiber.BorderSizePixel = 0
		MenuLiber.ClipsDescendants = true
		MenuLiber.Size = UDim2.new(1, 0, 1, 0)
		MenuLiber.ZIndex = 7
		
		Left.Name = "Left" 
		Left.Parent = MenuLiber
		Left.Active = true
		Left.AnchorPoint = Vector2.new(0.5, 0.5)
		Left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Left.BackgroundTransparency = 1.000
		Left.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Left.BorderSizePixel = 0
		Left.ClipsDescendants = false
		Left.Position = UDim2.new(0.175, 0, 0.5, 0)
		Left.Size = UDim2.new(0.32, 0, 1, -5)
		Left.ScrollBarThickness = 0
		UIListLayout.Parent = Left
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Padding = UDim.new(0, 5)
		UIListLayout.VerticalFlex = Enum.UIFlexAlignment.None; 

		Center.Name = "Center"
		Center.Parent = MenuLiber
		Center.Active = true
		Center.AnchorPoint = Vector2.new(0.5, 0.5)
		Center.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Center.BackgroundTransparency = 1.000
		Center.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Center.BorderSizePixel = 0
		Center.ClipsDescendants = false
		Center.Position = UDim2.new(0.5, 0, 0.5, 0)
		Center.Size = UDim2.new(0.32, 0, 1, -5)
		Center.ScrollBarThickness = 0
		UIListLayout_2.Parent = Center
		UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_2.Padding = UDim.new(0, 5)
		UIListLayout_2.VerticalFlex = Enum.UIFlexAlignment.None;

		Right.Name = "Right"
		Right.Parent = MenuLiber
		Right.Active = true
		Right.AnchorPoint = Vector2.new(0.5, 0.5)
		Right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Right.BackgroundTransparency = 1.000
		Right.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Right.BorderSizePixel = 0
		Right.ClipsDescendants = false
		Right.Position = UDim2.new(0.825, 0, 0.5, 0)
		Right.Size = UDim2.new(0.32, 0, 1, -5)
		Right.ScrollBarThickness = 0
		UIListLayout_3.Parent = Right
		UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_3.Padding = UDim.new(0, 5)
		UIListLayout_3.VerticalFlex = Enum.UIFlexAlignment.None;

		local BindEvent = Instance.new('BindableEvent',MenuLiber);
		BindEvent.Name = Fatality:RandomString();
		
        Fatality:ScrollSignal(Right,UIListLayout_3,'Y'); 
        Fatality:ScrollSignal(Center,UIListLayout_2,'Y'); 
        Fatality:ScrollSignal(Left,UIListLayout,'Y'); 

		Fatal.Signal.Event:Connect(function(Bool)
			if Bool then
				Fatality:CreateAnimation(MenuButton,0.5,{ BackgroundTransparency = (MenuLiber.Visible and 0) or 1 })
				Fatality:CreateAnimation(UIStroke,0.5,{ Transparency = 0.950 })
				Fatality:CreateAnimation(Left,0.3,{ Position = UDim2.new(0.175, 0, 0.5, 0) })
				Fatality:CreateAnimation(Center,0.4,{ Position = UDim2.new(0.5, 0, 0.5, 0) })
				Fatality:CreateAnimation(Right,0.5,{ Position = UDim2.new(0.825, 0, 0.5, 0) })
				Fatality:CreateAnimation(Icon,0.5,{ ImageTransparency = (MenuLiber.Visible and 0.15) or 0.5 })
				Fatality:CreateAnimation(menu_name,0.5,{ TextStrokeTransparency = 0.900, TextTransparency = (MenuLiber.Visible and 0.15) or 0.5 })
			else
				Fatality:CreateAnimation(Left,0.5,{ Position = UDim2.new(0.175, 0, 0.5, 1) })
				Fatality:CreateAnimation(Center,0.5,{ Position = UDim2.new(0.5, 0, 0.5, 2) })
				Fatality:CreateAnimation(Right,0.5,{ Position = UDim2.new(0.825, 0, 0.5, 3) })
				Fatality:CreateAnimation(MenuButton,0.5,{ BackgroundTransparency = 1 })
				Fatality:CreateAnimation(UIStroke,0.5,{ Transparency = 1 })
				Fatality:CreateAnimation(Icon,0.5,{ ImageTransparency = 1 })
				Fatality:CreateAnimation(menu_name,0.5,{ TextStrokeTransparency = 1, TextTransparency = 1 })
			end;
		end)

		local ValueSelect = function(val)
			if val then
				MenuLiber.Visible = true;
				Fatality:CreateAnimation(Icon,0.5,{ ImageTransparency = 0.15, ImageColor3 = Fatality:GetColor("Main") });
				Fatality:CreateAnimation(menu_name,0.5,{ TextTransparency = 0.15 });
				Fatality:CreateAnimation(MenuButton,0.5,{ BackgroundTransparency = 0 })
				BindEvent:SetAttribute('V',true); BindEvent:Fire(true);
			else
				BindEvent:SetAttribute('V',false); BindEvent:Fire(false);
				MenuLiber.Visible = false;
				Fatality:CreateAnimation(Icon,0.5,{ ImageTransparency = 0.5, ImageColor3 = Fatality:GetColor("Text") });
				Fatality:CreateAnimation(MenuButton,0.5,{ BackgroundTransparency = 1 })
				Fatality:CreateAnimation(menu_name,0.5,{ TextTransparency = 0.5 });
			end;
		end;

		local _B = { Root = MenuLiber, ValueSelect = ValueSelect, Bindable = BindEvent, };
		if not Fatal.MenuSelected then Fatal.MenuSelected = _B; ValueSelect(true); else ValueSelect(false); end;
		table.insert(Fatal.Menus,_B)
		Fatality:CreateHover(MenuButton,function(bool)
			if Fatal.MenuSelected.Root ~= MenuLiber then
				if bool then Fatality:CreateAnimation(Icon,0.5,{ ImageTransparency = 0.2, ImageColor3 = Fatality:GetColor("Text") }); Fatality:CreateAnimation(MenuButton,0.5,{ BackgroundTransparency = 1 }) Fatality:CreateAnimation(menu_name,0.5,{ TextTransparency = 0.2 });
				else Fatality:CreateAnimation(Icon,0.5,{ ImageTransparency = 0.5, ImageColor3 = Fatality:GetColor("Text") }); Fatality:CreateAnimation(MenuButton,0.5,{ BackgroundTransparency = 1 }) Fatality:CreateAnimation(menu_name,0.5,{ TextTransparency = 0.5 }); end
			end;
		end)
		Fatality:NewInput(MenuButton, function() 
			if Fatal.MenuSelected and Fatal.MenuSelected.Root == MenuLiber then return end 
			
			for i, v in next, Fatal.Menus do 
				if v.Root == MenuLiber then 
					Fatal.MenuSelected = v; 
					v.ValueSelect(true) 
				else 
					v.ValueSelect(false) 
				end; 
			end; 
		end);

		function MenuLib:AddPreview(Config: Preview)
			Config = Config or {}; Config.Name = Config.Name or "PREVIEW"; Config.Position = Config.Position or "left"; Config.Height = Config.Height or 0;
			local Preview = Instance.new("Frame")
			local PreviewName = Instance.new("TextLabel")
			local Main = Instance.new("Frame")
			local UIStroke = Instance.new("UIStroke")
			local UICorner = Instance.new("UICorner")
			local MainBlock = Instance.new("Frame")
			Preview.Name = "Preview"
			Preview.Parent = (string.lower(Config.Position) == 'left' and Left) or (string.lower(Config.Position) == 'center' and Center) or Right;
			Fatality:Register(Preview, "Background")
			Preview.BackgroundTransparency = 1
			Preview.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Preview.BorderSizePixel = 0
			Preview.ClipsDescendants = true
			Preview.ZIndex = 15;
			Preview.Size = UDim2.new(1, 0, 0, 25 + Config.Height)
			PreviewName.Name = "PreviewName"
			PreviewName.Parent = Preview
			PreviewName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			PreviewName.BackgroundTransparency = 1.000
			PreviewName.BorderColor3 = Color3.fromRGB(0, 0, 0)
			PreviewName.BorderSizePixel = 0
			PreviewName.Position = UDim2.new(0, 10, 0, 0)
			PreviewName.Size = UDim2.new(1, 0, 0, 15)
			PreviewName.ZIndex = 19
			PreviewName.FontFace = Fatality.FontSemiBold
			PreviewName.Text = Config.Name
			Fatality:Register(PreviewName, "Text", "TextColor3")
			PreviewName.TextSize = 15.000
			PreviewName.TextStrokeTransparency = 0.750
			PreviewName.TextXAlignment = Enum.TextXAlignment.Left
			Main.Name = "Main"
			Main.Parent = Preview
			Main.AnchorPoint = Vector2.new(0.5, 1)
			Fatality:Register(Main, "Container")
			Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Main.BorderSizePixel = 0
			Main.Position = UDim2.new(0.5, 0, 1, -1)
			Main.Size = UDim2.new(1, -5, 1, -10)
			Main.ZIndex = 17
			UIStroke.Color = Color3.fromRGB(29, 29, 29)
			Fatality:Register(UIStroke, "Stroke", "Color")
			UIStroke.Parent = Main
			UICorner.CornerRadius = UDim.new(0, 2)
			UICorner.Parent = Main
			MainBlock.Name = "MainBlock"
			MainBlock.Parent = Main
			MainBlock.AnchorPoint = Vector2.new(0.5, 0.5)
			MainBlock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			MainBlock.BackgroundTransparency = 1.000
			MainBlock.BorderColor3 = Color3.fromRGB(0, 0, 0)
			MainBlock.BorderSizePixel = 0
			MainBlock.Position = UDim2.new(0.5, 0, 0.5, 0)
			MainBlock.Size = UDim2.new(1, -5, 1, -5)
			MainBlock.ZIndex = 18
			local Toggle = function(v)
				if v then Fatality:CreateAnimation(Preview,0.5,{ BackgroundTransparency = 0 }) Fatality:CreateAnimation(PreviewName,0.5,{ TextStrokeTransparency = 0.750, TextTransparency = 0 }) Fatality:CreateAnimation(Main,0.5,{ BackgroundTransparency = 0 }) Fatality:CreateAnimation(UIStroke,0.5,{ Transparency = 0 }) Fatality:CreateAnimation(MainBlock,0.5,{ Size = UDim2.new(1, -5, 1, -5) })
				else Fatality:CreateAnimation(Preview,0.5,{ BackgroundTransparency = 1 }) Fatality:CreateAnimation(PreviewName,0.5,{ TextStrokeTransparency = 1, TextTransparency = 1 }) Fatality:CreateAnimation(Main,0.5,{ BackgroundTransparency = 1 }) Fatality:CreateAnimation(UIStroke,0.5,{ Transparency = 1 }) Fatality:CreateAnimation(MainBlock,0.5,{ Size = UDim2.new(0,0,0,0) }) end
			end;
			Toggle(BindEvent:GetAttribute('V'));
			BindEvent.Event:Connect(Toggle);
			return MainBlock;
		end;

		function MenuLib:AddListBox(Config : Listbox)
			Config = Config or {}; Config.Name = Config.Name or "LIST BOX"; Config.Position = Config.Position or "left"; Config.Height = Config.Height or 0; Config.Values = Config.Values or {}; Config.Multi = Config.Multi or false; Config.Default = Config.Default or ((Config.Multi and nil) or {}); Config.Callback = Config.Callback or function() end;
			table.insert(Fatal.ElementContents,{ Name = Config.Name, Path = Menu.Name .. " > ".. Config.Name, _TAB = _B });
			local ListBox = Instance.new("Frame")
			local Elements = Instance.new("Frame")
			local UIStroke = Instance.new("UIStroke")
			local UICorner = Instance.new("UICorner")
			local SearchBox = Instance.new("Frame")
			local TextBox = Instance.new("TextBox")
			local UICorner_2 = Instance.new("UICorner")
			local UIStroke_2 = Instance.new("UIStroke")
			local OptionButton = Instance.new("ImageButton")
			local ScrollingFrame = Instance.new("ScrollingFrame")
			local UICorner_3 = Instance.new("UICorner")
			local UIStroke_3 = Instance.new("UIStroke")
			local UIListLayout = Instance.new("UIListLayout")
			local SpaceBox = Instance.new("Frame")
			local ListName = Instance.new("TextLabel")
			ListBox.Name = Fatality:RandomString()
			ListBox.Parent = (string.lower(Config.Position) == 'left' and Left) or (string.lower(Config.Position) == 'center' and Center) or Right;
			Fatality:Register(ListBox, "Background")
			ListBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ListBox.BorderSizePixel = 0
			ListBox.ClipsDescendants = true
			ListBox.Size = UDim2.new(1, 0, 0, 350)
			ListBox.ZIndex = 10
			Fatality:AddDragBlacklist(ScrollingFrame);
			Elements.Name = Fatality:RandomString()
			Elements.Parent = ListBox
			Elements.AnchorPoint = Vector2.new(0.5, 1)
			Fatality:Register(Elements, "Container")
			Elements.BackgroundTransparency = 0
			Elements.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Elements.BorderSizePixel = 0
			Elements.Position = UDim2.new(0.5, 0, 1, -1)
			Elements.Size = UDim2.new(1, -5, 1, -10)
			Elements.ZIndex = 10
			UIStroke.Color = Color3.fromRGB(29, 29, 29)
			Fatality:Register(UIStroke, "Stroke", "Color")
			UIStroke.Parent = Elements
			UICorner.CornerRadius = UDim.new(0, 2)
			UICorner.Parent = Elements
			SearchBox.Name = Fatality:RandomString()
			SearchBox.Parent = Elements
			Fatality:Register(SearchBox, "Element")
			SearchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SearchBox.BorderSizePixel = 0
			SearchBox.ClipsDescendants = true
			SearchBox.Position = UDim2.new(0, 10, 0, 15)
			SearchBox.Size = UDim2.new(0, 195, 0, 16)
			SearchBox.ZIndex = 10
			TextBox.Parent = SearchBox
			Fatality:Register(TextBox, "Element")
			TextBox.BackgroundTransparency = 1.000
			TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextBox.BorderSizePixel = 0
			TextBox.Position = UDim2.new(0, 5, 0, 0)
			TextBox.Size = UDim2.new(1, -10, 0, 16)
			TextBox.ZIndex = 11
			TextBox.ClearTextOnFocus = false
			TextBox.FontFace = Fatality.FontSemiBold
			TextBox.PlaceholderText = "Start typing..."
			TextBox.Text = ""
			Fatality:Register(TextBox, "Text", "TextColor3")
			TextBox.TextSize = 11.000
			TextBox.TextXAlignment = Enum.TextXAlignment.Left
			UICorner_2.CornerRadius = UDim.new(0, 3)
			UICorner_2.Parent = SearchBox
			UIStroke_2.Transparency = 0.750
			UIStroke_2.Color = Color3.fromRGB(29, 29, 29)
			Fatality:Register(UIStroke_2, "Stroke", "Color")
			UIStroke_2.Parent = SearchBox
			OptionButton.Name = Fatality:RandomString()
			OptionButton.Parent = Elements
			OptionButton.AnchorPoint = Vector2.new(1, 0)
			OptionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			OptionButton.BackgroundTransparency = 1.000
			OptionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
			OptionButton.BorderSizePixel = 0
			OptionButton.Position = UDim2.new(1, -10, 0, 16)
			OptionButton.Size = UDim2.new(0, 13, 0, 13)
			OptionButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
			OptionButton.ZIndex = 11
			OptionButton.Image = "http://www.roblox.com/asset/?id=14007344336"
			OptionButton.ImageTransparency = 0.600
			OptionButton.Visible = Config.Option or false;
			ScrollingFrame.Parent = Elements
			ScrollingFrame.Active = true
			ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0)
			Fatality:Register(ScrollingFrame, "Element")
			ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ScrollingFrame.BorderSizePixel = 0
			ScrollingFrame.Position = UDim2.new(0.5, 0, 0, 40)
			ScrollingFrame.Size = UDim2.new(1, -20, 1, -50)
			ScrollingFrame.ZIndex = 11
			ScrollingFrame.ScrollBarThickness = 0
			ScrollingFrame.ScrollBarImageTransparency = 1
			ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
			UICorner_3.CornerRadius = UDim.new(0, 3)
			UICorner_3.Parent = ScrollingFrame
			UIStroke_3.Transparency = 0.750
			UIStroke_3.Color = Color3.fromRGB(29, 29, 29)
			Fatality:Register(UIStroke_3, "Stroke", "Color")
			UIStroke_3.Parent = ScrollingFrame
			UIListLayout.Parent = ScrollingFrame
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Padding = UDim.new(0, 5)
			UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				local all = (#ScrollingFrame:GetChildren() - 1);
				local unscaledSize = math.clamp((all * (10 + UIListLayout.Padding.Offset)) + (Config.Height + UIListLayout.Padding.Offset), 25, 400);
				
				if Menu.AutoFill then 
					ListBox.Size = UDim2.new(1, 0, 0, unscaledSize / 2.5); 
				else 
					ListBox.Size = UDim2.new(1, 0, 0, unscaledSize); 
				end;
				
				ScrollingFrame.CanvasSize = UDim2.fromOffset(0, math.round(UIListLayout.AbsoluteContentSize.Y / Fatality.Scale));
			end)
			SpaceBox.Name = Fatality:RandomString()
			SpaceBox.Parent = ScrollingFrame
			SpaceBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SpaceBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SpaceBox.BorderSizePixel = 0
			SpaceBox.Size = UDim2.new(0, 0, 0, 1)
			ListName.Name = Fatality:RandomString()
			ListName.Parent = ListBox
			ListName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ListName.BackgroundTransparency = 1.000
			ListName.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ListName.BorderSizePixel = 0
			ListName.Position = UDim2.new(0, 10, 0, 0)
			ListName.Size = UDim2.new(1, 0, 0, 15)
			ListName.ZIndex = 10
			ListName.FontFace = Fatality.FontSemiBold
			ListName.Text = Config.Name
			Fatality:Register(ListName, "Text", "TextColor3")
			ListName.TextSize = 15.000
			ListName.TextStrokeTransparency = 0.750
			ListName.TextXAlignment = Enum.TextXAlignment.Left
			
			local new_button = function()
				local db_selected = Instance.new("TextButton")
				db_selected.Name = Fatality:RandomString()
				db_selected.BackgroundTransparency = 1.000
				db_selected.Size = UDim2.new(1, 0, 0, 10)
				db_selected.ZIndex = 15
				db_selected.FontFace = Fatality.FontSemiBold
				db_selected.TextColor3 = Fatality:GetColor("Main")
				db_selected.TextSize = 12.000
				db_selected.TextTransparency = 0.5;
				db_selected.TextXAlignment = Enum.TextXAlignment.Left
				return db_selected;
			end;

			local Toggle = function(v)
				if v then
					Fatality:CreateAnimation(ListBox,0.5,{ BackgroundTransparency = 0 }) Fatality:CreateAnimation(UIStroke,0.5,{ Transparency = 0 }) Fatality:CreateAnimation(UIStroke_2,0.5,{ Transparency = 0.75 }) Fatality:CreateAnimation(UIStroke_3,0.5,{ Transparency = 0.75 }) Fatality:CreateAnimation(SearchBox,0.5,{ BackgroundTransparency = 0 }) Fatality:CreateAnimation(TextBox,0.5,{ TextTransparency = 0 }) Fatality:CreateAnimation(OptionButton,0.45,{ ImageTransparency = (Config.Option and 0.6) or 1, }) Fatality:CreateAnimation(ScrollingFrame,0.45,{ BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0, 40) }) table.foreach(ScrollingFrame:GetChildren(),function(i,v) if v:IsA('TextButton') then Fatality:CreateAnimation(v,0.45,{ TextTransparency = 0.5 }); end; end); Fatality:CreateAnimation(ListName,0.5,{ TextStrokeTransparency = 0.75, TextTransparency = 0 })
				else
					table.foreach(ScrollingFrame:GetChildren(),function(i,v) if v:IsA('TextButton') then Fatality:CreateAnimation(v,0.45,{ TextTransparency = 1 }); end; end); Fatality:CreateAnimation(ListBox,0.5,{ BackgroundTransparency = 1 }) Fatality:CreateAnimation(UIStroke,0.5,{ Transparency = 1 }) Fatality:CreateAnimation(UIStroke_2,0.5,{ Transparency = 1 }) Fatality:CreateAnimation(UIStroke_3,0.5,{ Transparency = 1 }) Fatality:CreateAnimation(SearchBox,0.5,{ BackgroundTransparency = 1 }) Fatality:CreateAnimation(TextBox,0.5,{ TextTransparency = 1 }) Fatality:CreateAnimation(OptionButton,0.45,{ ImageTransparency = 1 }) Fatality:CreateAnimation(ScrollingFrame,0.45,{ BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 40) }) Fatality:CreateAnimation(ListName,0.5,{ TextStrokeTransparency = 1, TextTransparency = 1 })
				end
			end;
			Toggle(BindEvent:GetAttribute('V'));
			BindEvent.Event:Connect(Toggle);
			
			local DearchDelay = tick();
			TextBox:GetPropertyChangedSignal('Text'):Connect(function()
				DearchDelay = tick();
				if not TextBox.Text:byte() then for i,v in next , ScrollingFrame:GetChildren() do if v:IsA('TextButton') then v.Visible = true; end; end; return; end;
				task.delay(0.25,function() if (tick() - DearchDelay) > 0.25 then for i,v in next , ScrollingFrame:GetChildren() do if v:IsA('TextButton') then if string.find(string.lower(v.Text),string.lower(TextBox.Text),1,true) then v.Visible = true; else v.Visible = false; end; end; end; end; end)
			end);
			
			local res;
			local ListBoxButtons = {};

			res = Fatality:CreateResponse({
				Refresh = function()
					for i,v in next , ScrollingFrame:GetChildren() do if v:IsA('TextButton') then v:Destroy(); end; end;
					table.clear(ListBoxButtons)
					local selectedmem;
					for i,v in next , Config.Values do
						local bth = new_button();
						bth.Text = string.rep(" ",2)..tostring(v);
						bth.Parent = ScrollingFrame;
						table.insert(ListBoxButtons, {Btn = bth, Value = v})

						if Config.Multi then
							if (typeof(Config.Default) == 'table' and (Config.Default[v] or table.find(Config.Default,v))) or Config.Default == v then Config.Default[v] = true; bth.TextColor3 = Fatality:GetColor("Main"); bth.TextTransparency = 0; else bth.TextColor3 = Fatality:GetColor("Text"); bth.TextTransparency = 0.5; Config.Default[v] = false end;
							Fatality:CreateHover(bth,function(bool) if not Config.Default[v] then if bool then Fatality:CreateAnimation(bth,0.25,{ TextTransparency = 0; }) else Fatality:CreateAnimation(bth,0.25,{ TextTransparency = 0.5; }) end; end; end)
							bth.MouseButton1Click:Connect(function() Config.Default[v] = not Config.Default[v]; if Config.Default[v] then bth.TextColor3 = Fatality:GetColor("Main"); bth.TextTransparency = 0; else bth.TextColor3 = Fatality:GetColor("Text"); bth.TextTransparency = 0.5; end; Config.Callback(Config.Default); end)
						else
							if v == Config.Default then selectedmem = bth; Config.Default = v; bth.TextColor3 = Fatality:GetColor("Main"); bth.TextTransparency = 0; else bth.TextColor3 = Fatality:GetColor("Text"); bth.TextTransparency = 0.5; end;
							Fatality:CreateHover(bth,function(bool) if Config.Default ~= v then if bool then Fatality:CreateAnimation(bth,0.25,{ TextTransparency = 0; }) else Fatality:CreateAnimation(bth,0.25,{ TextTransparency = 0.5; }) end; end; end)
							bth.MouseButton1Click:Connect(function() if selectedmem then selectedmem.TextColor3 = Fatality:GetColor("Text"); selectedmem.TextTransparency = 0.5; end; bth.TextTransparency = 0; bth.TextColor3 = Fatality:GetColor("Main"); selectedmem = bth; Config.Default = v; Config.Callback(v); end)
						end;
					end;
					Config.Callback(Config.Default);
				end,
				SetValues = function(value) Config.Values = value; end,
				SetDefault = function(value) Config.Default = value; end,
				GetValue = function() return Config.Default; end,
				Flag = Config.Flag and Config.Flag.."ListBox",
				SetValue = function(a) Config.Default = a; res:Refresh(); Config.Callback(Config.Default); end,
				Option = (Config.Option and Fatality:CreateOption(OptionButton)) or nil;
			});

			Fatality.ThemeEvent.Event:Connect(function()
				for _, data in pairs(ListBoxButtons) do
					if data.Btn and data.Btn.Parent then
						local isSelected = false
						if Config.Multi then isSelected = Config.Default[data.Value] == true else isSelected = (Config.Default == data.Value) end
						game:GetService("TweenService"):Create(data.Btn, TweenInfo.new(0.3), {TextColor3 = isSelected and Fatality:GetColor("Main") or Fatality:GetColor("Text")}):Play()
					end
				end
			end)

			res:Refresh();
			if Config.Flag then Fatality.WindowFlags[Fatalitywin][Config.Flag.."ListBox"] = res; end;
			return res;
		end;

		function MenuLib:AddSection(Config : Section)
			Config = Config or {};
			if not Fatality:CanShow(Config) then return Fatality.Dummy end
			Config.Name = Config.Name or "SECTION"; Config.Position = Config.Position or "center"; Config.Height = Config.Height or 0;
			table.insert(Fatal.ElementContents,{ Name = Config.Name, Path = Menu.Name .. " > ".. Config.Name, _TAB = _B });
			local Section = Instance.new("Frame")
			local Elements = Instance.new("Frame")
			local UIStroke = Instance.new("UIStroke")
			local UICorner = Instance.new("UICorner")
			local UIListLayout = Instance.new("UIListLayout")
			local SpaceBox = Instance.new("Frame")
			local SectionName = Instance.new("TextLabel")
			local Toggle = function(v)
				if v then Fatality:CreateAnimation(Section,0.5,{ BackgroundTransparency = 0 }) Fatality:CreateAnimation(UIStroke,0.5,{ Transparency = 0 }) Fatality:CreateAnimation(SectionName,0.5,{ TextStrokeTransparency = 0.750, TextTransparency = 0 })
				else Fatality:CreateAnimation(Section,0.5,{ BackgroundTransparency = 1 }) Fatality:CreateAnimation(UIStroke,0.5,{ Transparency = 1 }) Fatality:CreateAnimation(SectionName,0.5,{ TextStrokeTransparency = 1, TextTransparency = 1 }) end
			end;
			Section.Name = Fatality:RandomString()
			Section.Parent = (string.lower(Config.Position) == 'left' and Left) or (string.lower(Config.Position) == 'center' and Center) or Right;
			Fatality:Register(Section, "Background")
			Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Section.BorderSizePixel = 0
			Section.ClipsDescendants = true
			Section.Size = UDim2.new(1, 0, 0, 0)
			Elements.Name = Fatality:RandomString()
			Elements.Parent = Section
			Elements.AnchorPoint = Vector2.new(0.5, 1)
			Fatality:Register(Elements, "Container")
			Elements.BackgroundTransparency = 0
			Elements.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Elements.BorderSizePixel = 0
			Elements.Position = UDim2.new(0.5, 0, 1, -1)
			Elements.Size = UDim2.new(1, -5, 1, -10)
			UIStroke.Color = Color3.fromRGB(29, 29, 29)
			Fatality:Register(UIStroke, "Stroke", "Color")
			UIStroke.Parent = Elements
			UICorner.CornerRadius = UDim.new(0, 2)
			UICorner.Parent = Elements
			UIListLayout.Parent = Elements
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Padding = UDim.new(0, 5)
			SpaceBox.Name = Fatality:RandomString()
			SpaceBox.Parent = Elements
			SpaceBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SpaceBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SpaceBox.BorderSizePixel = 0
			SpaceBox.Size = UDim2.new(0, 0, 0, 10)
			SectionName.Name = Fatality:RandomString()
			SectionName.Parent = Section
			SectionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionName.BackgroundTransparency = 1.000
			SectionName.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionName.BorderSizePixel = 0
			SectionName.Position = UDim2.new(0, 10, 0, 0)
			SectionName.Size = UDim2.new(1, 0, 0, 15)
			SectionName.FontFace = Fatality.FontSemiBold;
			SectionName.Text = Config.Name
			Fatality:Register(SectionName, "Text", "TextColor3")
			SectionName.TextSize = 15.000
			SectionName.TextStrokeTransparency = 0.750
			SectionName.TextXAlignment = Enum.TextXAlignment.Left
			UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() 
				local unscaledHeight = UIListLayout.AbsoluteContentSize.Y / Fatality.Scale
				local targetHeight = unscaledHeight + 20 + Config.Height
				
				if not Menu.AutoFill then 
					Fatality:CreateAnimation(Section, 0.25, { Size = UDim2.new(1, 0, 0, targetHeight) }) 
				else 
					Section.Size = UDim2.new(1, 0, 0, targetHeight / 2.5); 
				end;
			end);
			Toggle(BindEvent:GetAttribute('V'));
			BindEvent.Event:Connect(Toggle);
			return Fatality:CreateElements(Elements,Elements.ZIndex,BindEvent,{
				Path = Menu.Name .. " > ".. Config.Name,
				Memory = function(Name) table.insert(Fatal.ElementContents,{ Name = Name, Path = Menu.Name .. " > ".. Config.Name .. " > " .. Name, _TAB = _B }); end,
			});
		end;

		function MenuLib:AddColumnTitle(Config)
			Config = Config or {}
			Config.Text = Config.Text or "TITLE"
			Config.Position = Config.Position or "center"

			local Parent = (Config.Position == 'left' and Left) or (Config.Position == 'center' and Center) or Right

			local Container = Instance.new("Frame")
			Container.Name = "ColTitle_" .. Config.Text
			Container.Parent = Parent
			Container.BackgroundTransparency = 1
			Container.Size = UDim2.new(1, 0, 0, 25) 
			Container.LayoutOrder = -999 
			Container.ZIndex = 10

			local Label = Instance.new("TextLabel")
			Label.Parent = Container
			Label.BackgroundTransparency = 1
			Label.Size = UDim2.new(1, 0, 1, -2) 
			Label.Position = UDim2.new(0, 0, 0, 2)
			Label.FontFace = Fatality.Fonts.Bold
			Label.TextColor3 = Color3.fromRGB(90, 90, 90) 
			Label.TextSize = 15
			Label.Text = string.upper(Config.Text)
			Label.TextXAlignment = Enum.TextXAlignment.Center
			Label.ZIndex = 11

			local Toggle = function(v)
				if v then Fatality:CreateAnimation(Label, 0.5, {TextTransparency = 0})
				else Fatality:CreateAnimation(Label, 0.5, {TextTransparency = 1}) end
			end
			Toggle(BindEvent:GetAttribute('V'))
			BindEvent.Event:Connect(Toggle)

			return Container
		end
		
		function MenuLib:AddProduct(Config)
			Config = Config or {};
			if not Fatality:CanShow(Config) then return Fatality.Dummy end
			
			Config.Name = Config.Name or "SCRIPT";
			Config.Version = Config.Version or "1.0";
			Config.Author = Config.Author or "Unknown";
			Config.Status = Config.Status or "Working";
			Config.Description = Config.Description or "No desc";
			Config.Tags = Config.Tags or {};
			Config.DateCreate = Config.DateCreate or "-";
			Config.DateUpdate = Config.DateUpdate or "-";
			
			Config.Likes = Config.Likes or 0
			Config.Dislikes = Config.Dislikes or 0
			Config.Downloads = Config.Downloads or 0
			Config.UserVote = Config.UserVote or 0
			Config.IsFavorite = Config.IsFavorite or false
			Config.IsOfficial = Config.IsOfficial or false
			
			Config.ButtonText = Config.ButtonText or "Install";
			Config.Callback = Config.Callback or function() end;
			Config.FavCallback = Config.FavCallback or function(v) end;
			Config.VoteCallback = Config.VoteCallback or function(v) end;
			Config.Position = Config.Position or "center";

			table.insert(Fatal.ElementContents, {
				Name = Config.Name, Path = Menu.Name.." > "..Config.Name, _TAB = _B,
				MenuName = Menu.Name, Author = Config.Author, Description = Config.Description, Tags = table.concat(Config.Tags," "), IsProduct = true
			});

			local function GetTimeAgo(d)
				if not d or d=="-" or d=="N/A" then return d end
				local D,M,Y,H,Min = d:match("(%d+)%.(%d+)%.(%d+)%s+(%d+):(%d+)")
				if not D then D,M,Y = d:match("(%d+)%.(%d+)%.(%d+)") H,Min=0,0 end
				if not D then return d end
				local diff = os.time() - os.time({year=Y,month=M,day=D,hour=H,min=Min})
				if diff<60 then return "now" end
				if diff<3600 then return math.floor(diff/60).."m ago" end
				if diff<86400 then return math.floor(diff/3600).."h ago" end
				if diff<604800 then return math.floor(diff/86400).."d ago" end
				return math.floor(diff/604800).."w ago"
			end

			local StatusColors = { Working=Color3.fromRGB(100,255,100), Updating=Color3.fromRGB(255,220,80), Patched=Color3.fromRGB(255,80,80) }

			local Product = Instance.new("Frame")
			local P_Corner = Instance.new("UICorner")
			local P_Stroke = Instance.new("UIStroke")
			local P_Pad = Instance.new("UIPadding")
			local P_List = Instance.new("UIListLayout")

			Product.Name = Fatality:RandomString()
			Product.Parent = (Config.Position=='left' and Left) or (Config.Position=='center' and Center) or Right
			Fatality:Register(Product, "Container")
			Product.BorderColor3 = Color3.new(0,0,0)
			Product.BorderSizePixel = 0
			Product.Size = UDim2.new(1,0,0,0)
			Product.AutomaticSize = Enum.AutomaticSize.Y
			Product.ZIndex = 15

			P_Corner.CornerRadius = UDim.new(0,4); P_Corner.Parent = Product
			P_Stroke.Color = Color3.fromRGB(29,29,29); Fatality:Register(P_Stroke, "Stroke", "Color"); P_Stroke.Parent = Product
			P_Pad.PaddingTop = UDim.new(0,8); P_Pad.PaddingBottom = UDim.new(0,8); P_Pad.PaddingLeft = UDim.new(0,8); P_Pad.PaddingRight = UDim.new(0,8); P_Pad.Parent = Product
			P_List.SortOrder = Enum.SortOrder.LayoutOrder; P_List.Padding = UDim.new(0,4); P_List.Parent = Product

			local Head = Instance.new("Frame", Product); Head.BackgroundTransparency=1; Head.Size=UDim2.new(1,0,0,16); Head.LayoutOrder=1; Head.ZIndex=20
			local Title = Instance.new("TextLabel", Head); Title.BackgroundTransparency=1; Title.Size=UDim2.new(0.7,0,1,0); Title.Font=Enum.Font.GothamBold; Title.Text=Config.Name; Title.TextColor3=Fatality:GetColor("Text"); Title.TextSize=13; Title.TextXAlignment=Enum.TextXAlignment.Left; Title.TextTruncate=Enum.TextTruncate.AtEnd; Title.ZIndex=20; Fatality:Register(Title,"Text","TextColor3")
			local Ver = Instance.new("TextLabel", Head); Ver.BackgroundTransparency=1; Ver.Size=UDim2.new(0.3,0,1,0); Ver.Position=UDim2.new(0.7,0,0,0); Ver.Font=Enum.Font.Gotham; Ver.Text=Config.Version; Ver.TextColor3=Fatality:GetColor("TextDark"); Ver.TextSize=11; Ver.TextXAlignment=Enum.TextXAlignment.Right; Ver.ZIndex=20; Fatality:Register(Ver,"TextDark","TextColor3")
			
			local StatDot = Instance.new("Frame", Head); 
			StatDot.BackgroundTransparency=0; 
			StatDot.Size=UDim2.new(0,6,0,6); 
			StatDot.AnchorPoint = Vector2.new(1, 0)
			StatDot.Position=UDim2.new(1, 0, 1, 2); 
			StatDot.BackgroundColor3=StatusColors[Config.Status] or StatusColors.Working; 
			StatDot.ZIndex=21
			Instance.new("UICorner", StatDot).CornerRadius = UDim.new(1,0)

			local Sub = Instance.new("Frame", Product); Sub.BackgroundTransparency=1; Sub.Size=UDim2.new(1,0,0,14); Sub.LayoutOrder=2; Sub.ZIndex=20
			local SL = Instance.new("UIListLayout", Sub); SL.SortOrder=Enum.SortOrder.LayoutOrder; SL.FillDirection=Enum.FillDirection.Horizontal; SL.Padding=UDim.new(0,4); SL.VerticalAlignment=Enum.VerticalAlignment.Center
			
			local By = Instance.new("TextLabel", Sub); By.LayoutOrder=1; By.BackgroundTransparency=1; By.AutomaticSize=Enum.AutomaticSize.X; By.Size=UDim2.new(0,0,1,0); By.Font=Enum.Font.Gotham; By.Text="by"; By.TextColor3=Fatality:GetColor("TextDark"); By.TextSize=10; By.ZIndex=20; Fatality:Register(By,"TextDark","TextColor3")
			
			local Auth = Instance.new("TextLabel", Sub); Auth.LayoutOrder=2; Auth.BackgroundTransparency=1; Auth.AutomaticSize=Enum.AutomaticSize.X; Auth.Size=UDim2.new(0,0,1,0); Auth.Font=Enum.Font.Gotham; Auth.Text=Config.Author; Auth.TextSize=10; Auth.ZIndex=20
			
			Auth.TextColor3 = Fatality:GetColor("Main")
			Fatality:Register(Auth,"Main","TextColor3")
			
			if Config.IsOfficial then
				local Crown = Instance.new("ImageLabel", Sub); Crown.LayoutOrder=3; Crown.BackgroundTransparency=1; Crown.Size=UDim2.new(0,10,0,10); Crown.Image=Fatality:GetIcon("crown"); Crown.ImageColor3=Color3.fromRGB(255,215,0); Crown.ZIndex=20
			end

			local Desc = Instance.new("TextLabel", Product); Desc.BackgroundTransparency=1; Desc.Size=UDim2.new(1,0,0,0); Desc.AutomaticSize=Enum.AutomaticSize.Y; Desc.Font=Enum.Font.GothamMedium; Desc.Text=Config.Description; Desc.TextColor3=Color3.fromRGB(200,200,200); Desc.TextSize=11; Desc.TextWrapped=true; Desc.TextXAlignment=Enum.TextXAlignment.Left; Desc.LayoutOrder=3; Desc.ZIndex=20

			local TagBox = Instance.new("Frame", Product); TagBox.BackgroundTransparency=1; TagBox.Size=UDim2.new(1,0,0,16); TagBox.AutomaticSize=Enum.AutomaticSize.Y; TagBox.LayoutOrder=4; TagBox.ZIndex=20
			local TL = Instance.new("UIListLayout", TagBox); TL.FillDirection=Enum.FillDirection.Horizontal; TL.Padding=UDim.new(0,4); TL.Wraps=true
			for _, t in ipairs(Config.Tags) do
				local Ch = Instance.new("Frame", TagBox); Ch.BackgroundColor3=Color3.fromRGB(35,35,35); Ch.Size=UDim2.new(0,0,0,14); Ch.AutomaticSize=Enum.AutomaticSize.X; Ch.ZIndex=21; Instance.new("UICorner", Ch).CornerRadius=UDim.new(0,3); local S=Instance.new("UIStroke", Ch); S.Color=Color3.fromRGB(50,50,50); local P=Instance.new("UIPadding", Ch); P.PaddingLeft=UDim.new(0,4); P.PaddingRight=UDim.new(0,4)
				local L = Instance.new("TextLabel", Ch); L.BackgroundTransparency=1; L.Size=UDim2.new(1,0,1,0); L.Font=Enum.Font.Gotham; L.TextSize=9; L.TextColor3=Color3.fromRGB(180,180,180); L.Text=string.lower(t); L.ZIndex=22
			end
			if #Config.Tags == 0 then TagBox.Visible=false end

			local StatRow = Instance.new("Frame", Product); StatRow.BackgroundTransparency=1; StatRow.Size=UDim2.new(1,0,0,16); StatRow.LayoutOrder=5; StatRow.ZIndex=20
			
			local LkBtn = Instance.new("ImageButton", StatRow); LkBtn.BackgroundTransparency=1; LkBtn.Size=UDim2.new(0,14,0,14); LkBtn.Position=UDim2.new(0,0,0.5,-7); LkBtn.Image=Fatality:GetIcon("chevron-up"); LkBtn.ImageColor3=(Config.UserVote==1 and Color3.fromRGB(100,255,100) or Color3.fromRGB(150,150,150)); LkBtn.ZIndex=21
			local LkCnt = Instance.new("TextLabel", StatRow); LkCnt.BackgroundTransparency=1; LkCnt.Position=UDim2.new(0,16,0,0); LkCnt.Size=UDim2.new(0,20,1,0); LkCnt.Font=Enum.Font.GothamBold; LkCnt.TextSize=10; LkCnt.TextColor3=Color3.fromRGB(100,255,100); LkCnt.TextXAlignment=Enum.TextXAlignment.Left; LkCnt.Text=tostring(Config.Likes); LkCnt.ZIndex=21
			
			local DkBtn = Instance.new("ImageButton", StatRow); DkBtn.BackgroundTransparency=1; DkBtn.Size=UDim2.new(0,14,0,14); DkBtn.Position=UDim2.new(0,35,0.5,-7); DkBtn.Image=Fatality:GetIcon("chevron-down"); DkBtn.ImageColor3=(Config.UserVote==-1 and Color3.fromRGB(255,100,100) or Color3.fromRGB(150,150,150)); DkBtn.ZIndex=21
			local DkCnt = Instance.new("TextLabel", StatRow); DkCnt.BackgroundTransparency=1; DkCnt.Position=UDim2.new(0,51,0,0); DkCnt.Size=UDim2.new(0,20,1,0); DkCnt.Font=Enum.Font.GothamBold; DkCnt.TextSize=10; DkCnt.TextColor3=Color3.fromRGB(255,100,100); DkCnt.TextXAlignment=Enum.TextXAlignment.Left; DkCnt.Text=tostring(Config.Dislikes); DkCnt.ZIndex=21

			local FavBtn = Instance.new("ImageButton", StatRow); FavBtn.BackgroundTransparency=1; FavBtn.Size=UDim2.new(0,16,0,16); FavBtn.AnchorPoint=Vector2.new(1,0.5); FavBtn.Position=UDim2.new(1,0,0.5,0); FavBtn.Image=Fatality:GetIcon("star"); FavBtn.ImageColor3=(Config.IsFavorite and Color3.fromRGB(255,220,80) or Color3.fromRGB(80,80,80)); FavBtn.ZIndex=21

			local BtnCont = Instance.new("Frame", Product); BtnCont.BackgroundTransparency=1; BtnCont.Size=UDim2.new(1,0,0,22); BtnCont.LayoutOrder=6; BtnCont.ZIndex=20
			
			local InstBtn = Instance.new("TextButton", BtnCont); InstBtn.BackgroundColor3=Fatality:GetColor("Element"); InstBtn.Size=UDim2.new(1,-35,1,0); InstBtn.Font=Enum.Font.GothamBold; InstBtn.Text=Config.ButtonText; InstBtn.TextColor3=Fatality:GetColor("Text"); InstBtn.TextSize=11; InstBtn.AutoButtonColor=false; InstBtn.ZIndex=25; Fatality:Register(InstBtn,"Element"); Fatality:Register(InstBtn,"Text","TextColor3"); Instance.new("UICorner", InstBtn).CornerRadius=UDim.new(0,4); local IBS=Instance.new("UIStroke", InstBtn); IBS.Color=Fatality:GetColor("Stroke"); Fatality:Register(IBS,"Stroke","Color")
			
			local DLCont = Instance.new("Frame", BtnCont); DLCont.BackgroundTransparency=1; DLCont.Size=UDim2.new(0,30,1,0); DLCont.Position=UDim2.new(1,-30,0,0); DLCont.ZIndex=21
			local DLL = Instance.new("UIListLayout", DLCont); DLL.FillDirection=Enum.FillDirection.Horizontal; DLL.HorizontalAlignment=Enum.HorizontalAlignment.Right; DLL.VerticalAlignment=Enum.VerticalAlignment.Center; DLL.Padding=UDim.new(0,3)
			
			local DLCnt = Instance.new("TextLabel", DLCont); DLCnt.BackgroundTransparency=1; DLCnt.AutomaticSize=Enum.AutomaticSize.X; DLCnt.Size=UDim2.new(0,0,1,0); DLCnt.Font=Enum.Font.Gotham; DLCnt.TextSize=10; DLCnt.TextColor3=Fatality:GetColor("TextDark"); DLCnt.LayoutOrder=2; DLCnt.Text=tostring(Config.Downloads); DLCnt.ZIndex=21; Fatality:Register(DLCnt,"TextDark","TextColor3")
			local DLIcon = Instance.new("ImageLabel", DLCont); DLIcon.BackgroundTransparency=1; DLIcon.Size=UDim2.new(0,12,0,12); DLIcon.Image=Fatality:GetIcon("download"); DLIcon.ImageColor3=Fatality:GetColor("TextDark"); DLIcon.LayoutOrder=1; DLIcon.ZIndex=21; Fatality:Register(DLIcon,"TextDark","ImageColor3")

			local DateRow = Instance.new("Frame", Product); DateRow.BackgroundTransparency=1; DateRow.Size=UDim2.new(1,0,0,12); DateRow.LayoutOrder=7; DateRow.ZIndex=20
			local D1 = Instance.new("TextLabel", DateRow); D1.BackgroundTransparency=1; D1.Size=UDim2.new(0.5,0,1,0); D1.Font=Enum.Font.Gotham; D1.TextColor3=Color3.fromRGB(80,80,80); D1.TextSize=9; D1.TextXAlignment=Enum.TextXAlignment.Left; D1.Text="added: "..GetTimeAgo(Config.DateCreate); D1.ZIndex=20
			local D2 = Instance.new("TextLabel", DateRow); D2.BackgroundTransparency=1; D2.Size=UDim2.new(0.5,0,1,0); D2.Position=UDim2.new(0.5,0,0,0); D2.Font=Enum.Font.Gotham; D2.TextColor3=Color3.fromRGB(80,80,80); D2.TextSize=9; D2.TextXAlignment=Enum.TextXAlignment.Right; D2.Text="updated: "..GetTimeAgo(Config.DateUpdate); D2.ZIndex=20

			local Sp = Instance.new("Frame", Product); Sp.BackgroundTransparency=1; Sp.Size=UDim2.new(1,0,0,2); Sp.LayoutOrder=8

			Fatality:CreateHover(InstBtn, function(h)
				if h then 
					local c = InstBtn.BackgroundColor3
					local h_color, s, v = c:ToHSV()
					Fatality:CreateAnimation(InstBtn, 0.2, {BackgroundColor3 = Color3.fromHSV(h_color, s, math.clamp(v + 0.15, 0, 1))})
				else
					Fatality:CreateAnimation(InstBtn, 0.2, {BackgroundColor3 = Fatality:GetColor("Element")})
				end
			end)
			
			Fatality:CreateHover(FavBtn, function(h) Fatality:CreateAnimation(FavBtn, 0.2, {ImageTransparency = h and 0 or 0.3}) end)

			InstBtn.MouseButton1Click:Connect(Config.Callback)
			FavBtn.MouseButton1Click:Connect(function()
				Config.IsFavorite = not Config.IsFavorite
				FavBtn.ImageColor3 = Config.IsFavorite and Color3.fromRGB(255,220,80) or Color3.fromRGB(80,80,80)
				Config.FavCallback(Config.IsFavorite)
			end)
			
			local function Vote(v)
				local nv = (Config.UserVote == v) and 0 or v
				Config.VoteCallback(nv)
			end
			LkBtn.MouseButton1Click:Connect(function() Vote(1) end)
			DkBtn.MouseButton1Click:Connect(function() Vote(-1) end)

			local Toggle = function(v)
				local t = v and 0 or 1
				Fatality:CreateAnimation(Product, 0.5, {BackgroundTransparency=t})
				Fatality:CreateAnimation(P_Stroke, 0.5, {Transparency=t})
				Fatality:CreateAnimation(InstBtn, 0.5, {BackgroundTransparency=t})
				Fatality:CreateAnimation(IBS, 0.5, {Transparency=t})
				Fatality:CreateAnimation(StatDot, 0.5, {BackgroundTransparency=t})
				
				for _, obj in pairs(Product:GetDescendants()) do
					if obj:IsA("TextLabel") or obj:IsA("TextButton") then
						Fatality:CreateAnimation(obj, 0.5, {TextTransparency=t})
					elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
						if obj == FavBtn then Fatality:CreateAnimation(obj, 0.5, {ImageTransparency = v and 0.3 or 1})
						else Fatality:CreateAnimation(obj, 0.5, {ImageTransparency=t}) end
					elseif obj:IsA("UIStroke") and obj.Parent ~= Product and obj.Parent ~= InstBtn then
						Fatality:CreateAnimation(obj, 0.5, {Transparency=t})
					elseif obj:IsA("Frame") and obj.Parent.Name == "TagsContainer" then 
						Fatality:CreateAnimation(obj, 0.5, {BackgroundTransparency=t})
					end
				end
			end
			Toggle(BindEvent:GetAttribute('V'))
			BindEvent.Event:Connect(Toggle)

			return {
				SetStatus = function(self, s) if StatusColors[s] then Fatality:CreateAnimation(StatDot, 0.3, {BackgroundColor3=StatusColors[s]}) end end,
				SetButton = function(self, t) 
					InstBtn.Text = t
					InstBtn.TextColor3 = Fatality:GetColor("Text")
					InstBtn.BackgroundColor3 = Fatality:GetColor("Element")
				end,
				SetVisuals = function(self, data)
					if data.Likes ~= nil then LkCnt.Text=tostring(data.Likes) end
					if data.Dislikes ~= nil then DkCnt.Text=tostring(data.Dislikes) end
					if data.Downloads ~= nil then DLCnt.Text=tostring(data.Downloads) end
					
					if data.Vote ~= nil then
						Config.UserVote = data.Vote
						LkBtn.ImageColor3 = (data.Vote==1) and Color3.fromRGB(100,255,100) or Color3.fromRGB(150,150,150)
						DkBtn.ImageColor3 = (data.Vote==-1) and Color3.fromRGB(255,100,100) or Color3.fromRGB(150,150,150)
					end
					
					if data.Fav ~= nil then
						Config.IsFavorite = data.Fav
						FavBtn.ImageColor3 = data.Fav and Color3.fromRGB(255,220,80) or Color3.fromRGB(80,80,80)
					end
				end,
				Destroy = function(self) Product:Destroy() end,
				SetVisible = function(self, b) Product.Visible = b end,
				GetButton = function() return InstBtn end
			}
		end;

		return MenuLib; 
	end;

	do
		local SearchFrame = Instance.new("Frame")
		local UIStroke = Instance.new("UIStroke")
		local UICorner = Instance.new("UICorner")
		local DropShadow = Instance.new("ImageLabel")
		local SearchBox = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local UIStroke_2 = Instance.new("UIStroke")
		local TextBox = Instance.new("TextBox")
		local ScrollingFrame = Instance.new("ScrollingFrame")
		local UIListLayout = Instance.new("UIListLayout")
		local EmptyLabel = Instance.new("TextLabel") 
		local searchScale = UDim2.new(0, 295, 0, 295);
		
		Fatality:AddDragBlacklist(SearchFrame);
		
		local SearchToggle = function(value)
			if value then
				SearchFrame.Position = UDim2.fromOffset(SearchButton.AbsolutePosition.X - 5,SearchButton.AbsolutePosition.Y + (SearchButton.AbsoluteSize.Y * 3))
				Fatality:CreateAnimation(SearchFrame,0.35,{ Size = searchScale }) 
				Fatality:CreateAnimation(DropShadow,0.35,{ ImageTransparency = 0.750 }) 
				Fatality:CreateAnimation(SearchBox,0.35,{ BackgroundTransparency = 0 }) 
				Fatality:CreateAnimation(UIStroke_2,0.5,{ Transparency = 0.650 }) 
				Fatality:CreateAnimation(UIStroke,0.5,{ Transparency = 0 }) 
				Fatality:CreateAnimation(TextBox,0.5,{ TextTransparency = 0 })
			else
				Fatality:CreateAnimation(UIStroke,0.5,{ Transparency = 1 }) 
				Fatality:CreateAnimation(SearchFrame,0.35,{ Size = UDim2.new(searchScale.X.Scale, searchScale.X.Offset, 0, 0) }) 
				Fatality:CreateAnimation(DropShadow,0.35,{ ImageTransparency = 1 }) 
				Fatality:CreateAnimation(SearchBox,0.5,{ BackgroundTransparency = 1 }) 
				Fatality:CreateAnimation(UIStroke_2,0.5,{ Transparency = 1 }) 
				Fatality:CreateAnimation(TextBox,0.5,{ TextTransparency = 1 }) 
				for i,v in next , ScrollingFrame:GetChildren() do 
					if v:IsA('Frame') then v:Destroy(); end; 
				end;
				EmptyLabel.Visible = false
			end;
		end;
		
		SearchFrame.Name = Fatality:RandomString()
		SearchFrame.Parent = Fatalitywin;
		SearchFrame.AnchorPoint = Vector2.new(0, 1)
		Fatality:Register(SearchFrame, "Background")
		SearchFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SearchFrame.BorderSizePixel = 0
		SearchFrame.Position = UDim2.new(4,0,4,0)
		SearchFrame.Size = searchScale
		SearchFrame.ZIndex = 100
		SearchFrame.ClipsDescendants = true
		
		UIStroke.Color = Color3.fromRGB(29, 29, 29)
		Fatality:Register(UIStroke, "Stroke", "Color")
		UIStroke.Parent = SearchFrame
		UICorner.CornerRadius = UDim.new(0, 2)
		UICorner.Parent = SearchFrame
		
		DropShadow.Name = Fatality:RandomString()
		DropShadow.Parent = SearchFrame
		DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
		DropShadow.BackgroundTransparency = 1.000
		DropShadow.BorderSizePixel = 0
		DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
		DropShadow.Rotation = 0.010
		DropShadow.Size = UDim2.new(1, 47, 1, 47)
		DropShadow.ZIndex = 99
		DropShadow.Image = "rbxassetid://6014261993"
		Fatality:Register(DropShadow, "Outline", "ImageColor3")
		DropShadow.ImageTransparency = 0.750
		DropShadow.ScaleType = Enum.ScaleType.Slice
		DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
		
		SearchBox.Name = Fatality:RandomString()
		SearchBox.Parent = SearchFrame
		SearchBox.AnchorPoint = Vector2.new(0.5, 0)
		Fatality:Register(SearchBox, "Element")
		SearchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SearchBox.BorderSizePixel = 0
		SearchBox.Position = UDim2.new(0.5, 0, 0, 9)
		SearchBox.Size = UDim2.new(1, -15, 0, 25)
		SearchBox.ZIndex = 101
		UICorner_2.CornerRadius = UDim.new(0, 2)
		UICorner_2.Parent = SearchBox
		
		UIStroke_2.Transparency = 0.650
		UIStroke_2.Color = Color3.fromRGB(29, 29, 29)
		Fatality:Register(UIStroke_2, "Stroke", "Color")
		UIStroke_2.Parent = SearchBox
		
		TextBox.Parent = SearchBox
		TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
		TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextBox.BackgroundTransparency = 1.000
		TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextBox.BorderSizePixel = 0
		TextBox.Position = UDim2.new(0.5, 0, 0.5, 0)
		TextBox.Size = UDim2.new(1, -15, 1, -5)
		TextBox.ZIndex = 102
		TextBox.ClearTextOnFocus = false
		TextBox.FontFace = Fatality.FontSemiBold;
		TextBox.PlaceholderText = "Search by name, author or tags..."
		TextBox.Text = ""
		Fatality:Register(TextBox, "Text", "TextColor3")
		TextBox.TextSize = 12.000
		TextBox.TextXAlignment = Enum.TextXAlignment.Left
		
		ScrollingFrame.Parent = SearchFrame
		ScrollingFrame.Active = true
		ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0)
		Fatality:Register(ScrollingFrame, "Background")
		ScrollingFrame.BackgroundTransparency = 1
		ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ScrollingFrame.BorderSizePixel = 0
		ScrollingFrame.Position = UDim2.new(0.5, 0, 0, 40)
		ScrollingFrame.Size = UDim2.new(1, -15, 1, -45)
		ScrollingFrame.ZIndex = 102
		ScrollingFrame.ScrollBarThickness = 0
		
		EmptyLabel.Name = "EmptyLabel"
		EmptyLabel.Parent = SearchFrame
		EmptyLabel.BackgroundTransparency = 1
		EmptyLabel.Size = UDim2.new(1, 0, 0, 20)
		EmptyLabel.Position = UDim2.new(0, 0, 0.5, 0)
		EmptyLabel.ZIndex = 105
		EmptyLabel.Font = Enum.Font.GothamBold
		EmptyLabel.Text = "No results found"
		Fatality:Register(EmptyLabel, "TextDark", "TextColor3")
		EmptyLabel.TextSize = 14
		EmptyLabel.Visible = false
		
		UIListLayout.Parent = ScrollingFrame
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Padding = UDim.new(0, 4)
		UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() ScrollingFrame.CanvasSize = UDim2.fromOffset(0,UIListLayout.AbsoluteContentSize.Y) end)
		
		SearchToggle(false);
		Fatality:CreateHover(SearchButton,function(bool) if bool then Fatality:CreateAnimation(SearchButton,0.5,{ ImageTransparency = 0.1 }) else Fatality:CreateAnimation(SearchButton,0.5,{ ImageTransparency = 0.5 }) end	end);
		
		local SearchInformation = {};
		
		local function GetTypeIcon(tabName)
			if tabName == "SCRIPTS" then return "rbxassetid://10709810463" end 
			if tabName == "CONFIGS" then return "rbxassetid://10734950309" end 
			return "rbxassetid://10709752906" 
		end
		
		local get_button = function(Name, Path, TAB_WARP, TabType)
			local ResultFrame = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local TypeIcon = Instance.new("ImageLabel") 
			local FeatureName = Instance.new("TextLabel")
			local FeaturePath = Instance.new("TextLabel")
			
			ResultFrame.Name = Fatality:RandomString()
			ResultFrame.Parent = ScrollingFrame;
			Fatality:Register(ResultFrame, "Element")
			ResultFrame.BackgroundTransparency = 1.000
			ResultFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ResultFrame.BorderSizePixel = 0
			ResultFrame.Size = UDim2.new(1, 0, 0, 42)
			ResultFrame.ZIndex = 103
			
			UICorner.CornerRadius = UDim.new(0, 4)
			UICorner.Parent = ResultFrame
			
			TypeIcon.Parent = ResultFrame
			TypeIcon.BackgroundTransparency = 1
			TypeIcon.Position = UDim2.new(0, 8, 0.5, -8) 
			TypeIcon.Size = UDim2.new(0, 16, 0, 16)
			TypeIcon.Image = GetTypeIcon(TabType)
			TypeIcon.ImageColor3 = Fatality:GetColor("TextDark")
			Fatality:Register(TypeIcon, "TextDark", "ImageColor3")
			TypeIcon.ZIndex = 104
			
			FeatureName.Name = Fatality:RandomString()
			FeatureName.Parent = ResultFrame
			FeatureName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			FeatureName.BackgroundTransparency = 1.000
			FeatureName.BorderColor3 = Color3.fromRGB(0, 0, 0)
			FeatureName.BorderSizePixel = 0
			FeatureName.Position = UDim2.new(0, 32, 0, 5) 
			FeatureName.Size = UDim2.new(1, -35, 0, 15)
			FeatureName.ZIndex = 104
			FeatureName.FontFace = Fatality.FontSemiBold
			FeatureName.Text = Name
			Fatality:Register(FeatureName, "Text", "TextColor3")
			FeatureName.TextSize = 14.000
			FeatureName.TextXAlignment = Enum.TextXAlignment.Left
			FeatureName.TextTruncate = Enum.TextTruncate.AtEnd
			
			FeaturePath.Name = Fatality:RandomString()
			FeaturePath.Parent = ResultFrame
			FeaturePath.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			FeaturePath.BackgroundTransparency = 1.000
			FeaturePath.BorderColor3 = Color3.fromRGB(0, 0, 0)
			FeaturePath.BorderSizePixel = 0
			FeaturePath.Position = UDim2.new(0, 32, 0, 22) 
			FeaturePath.Size = UDim2.new(1, -35, 0, 15)
			FeaturePath.ZIndex = 104
			FeaturePath.FontFace = Fatality.FontSemiBold
			FeaturePath.Text = Path
			Fatality:Register(FeaturePath, "Text", "TextColor3")
			FeaturePath.TextSize = 12.000
			FeaturePath.TextTransparency = 0.500
			FeaturePath.TextXAlignment = Enum.TextXAlignment.Left
			FeaturePath.TextTruncate = Enum.TextTruncate.AtEnd
			
			local button = Fatality:NewInput(ResultFrame);
			
			Fatality:CreateHover(button,function(bool) 
				if bool then 
					Fatality:CreateAnimation(ResultFrame,0.5,{ BackgroundTransparency = 0 }) 
					Fatality:CreateAnimation(TypeIcon, 0.5, { ImageColor3 = Fatality:GetColor("Main") })
				else 
					Fatality:CreateAnimation(ResultFrame,0.5,{ BackgroundTransparency = 1 }) 
					Fatality:CreateAnimation(TypeIcon, 0.5, { ImageColor3 = Fatality:GetColor("TextDark") })
				end	
			end);
			
			button.MouseButton1Click:Connect(function() 
				if TAB_WARP then 
					for i,v in next , Fatal.Menus do 
						if v.Root == TAB_WARP.Root then 
							Fatal.MenuSelected = v; 
							v.ValueSelect(true) 
						else 
							v.ValueSelect(false) 
						end; 
					end; 
				end; 
			end);
			return ResultFrame;
		end
		
		SearchButton.MouseButton1Click:Connect(function() 
			TextBox.Text = ""; 
			SearchToggle(true); 
			table.clear(SearchInformation); 
			EmptyLabel.Visible = false
			
			for i,v in next , ScrollingFrame:GetChildren() do 
				if v:IsA('Frame') then v:Destroy(); end; 
			end; 
			
			for i, v in pairs(Fatal.ElementContents) do
				local rootTab = ""
				if v.MenuName then rootTab = v.MenuName else local parts = string.split(v.Path, " > "); rootTab = parts[1] or "" end
				rootTab = string.upper(rootTab)

				if rootTab ~= "CONFIGS" and rootTab ~= "SCRIPTS" then continue end
				
				local searchString = string.lower(v.Name)
				if v.Author then searchString = searchString .. " " .. string.lower(v.Author) end
				if v.Description then searchString = searchString .. " " .. string.lower(v.Description) end
				if v.Tags then searchString = searchString .. " " .. string.lower(v.Tags) end
				
				local displayPath = v.Path
				if v.IsProduct then displayPath = "Click to view product page" end
				
				local button = get_button(v.Name, displayPath, v._TAB, rootTab);
				
				table.insert(SearchInformation, {
					root = button,
					searchData = searchString
				})
			end
		end)
		
		local DearchDelay = tick();
		TextBox:GetPropertyChangedSignal('Text'):Connect(function()
			DearchDelay = tick();
			local currentText = TextBox.Text
			
			if not currentText:byte() then 
				for i,v in next , SearchInformation do v.root.Visible = true; end; 
				EmptyLabel.Visible = false
				return; 
			end;
			
			task.delay(0.5, function() 
				if (tick() - DearchDelay) > 0.5 and TextBox.Text == currentText then 
					local queryParts = string.split(string.lower(currentText), " ")
					local visibleCount = 0
					
					for i, v in next, SearchInformation do 
						local match = true
						for _, word in ipairs(queryParts) do
							if word ~= "" and not string.find(v.searchData, word, 1, true) then
								match = false
								break
							end
						end
						
						if match then 
							v.root.Visible = true; 
							visibleCount = visibleCount + 1
						else 
							v.root.Visible = false; 
						end; 
					end; 
					
					EmptyLabel.Visible = (visibleCount == 0)
				end; 
			end)
		end);
		
		UserInputService.InputBegan:Connect(function(input) 
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
				if not Fatality:IsMouseOverFrame(SearchFrame) then SearchToggle(false); end 
			end 
		end)
	end;

	do
		local AboutFrame = Instance.new("Frame")
		local UIStroke = Instance.new("UIStroke")
		local UICorner = Instance.new("UICorner")
		local DropShadow = Instance.new("ImageLabel")
		local HeaderText = Instance.new("TextLabel")
		local CloseButton = Instance.new("TextButton")
		local ContentFrame = Instance.new("Frame")
		local LogoContainer = Instance.new("Frame")
		local LogoRed = Instance.new("TextLabel")
		local LogoBlue = Instance.new("TextLabel")
		local LogoWhite = Instance.new("TextLabel")
		local CreditsText = Instance.new("TextLabel")
		local LinkButton = Instance.new("TextButton")
		local UICorner_Btn = Instance.new("UICorner")
		local UIStroke_Btn = Instance.new("UIStroke")

		AboutFrame.Name = "AboutWindow"
		AboutFrame.Parent = Fatalitywin
		AboutFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		AboutFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		AboutFrame.Size = UDim2.new(0, 220, 0, 260)
		Fatality:Register(AboutFrame, "Background") 
		AboutFrame.BorderSizePixel = 0
		AboutFrame.Visible = false
		AboutFrame.ZIndex = 200
		AboutFrame.Active = true 
		
		local AboutScale = Instance.new("UIScale", AboutFrame)
		AboutScale.Scale = Fatality.Scale
		table.insert(Fatality.ScalesRegistry, AboutScale)
		
		Fatality:AddDragBlacklist(AboutFrame)
		Fatality:Drag(AboutFrame, AboutFrame, 0.1)

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = AboutFrame

		UIStroke.Color = Color3.fromRGB(29, 29, 29)
		Fatality:Register(UIStroke, "Stroke", "Color")
		UIStroke.Parent = AboutFrame

		DropShadow.Name = "Shadow"
		DropShadow.Parent = AboutFrame
		DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
		DropShadow.BackgroundTransparency = 1
		DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
		DropShadow.Size = UDim2.new(1, 60, 1, 60)
		DropShadow.ZIndex = 199
		DropShadow.Image = "rbxassetid://6014261993"
		DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
		DropShadow.ImageTransparency = 0.5
		DropShadow.ScaleType = Enum.ScaleType.Slice
		DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

		HeaderText.Name = "Title"
		HeaderText.Parent = AboutFrame
		HeaderText.BackgroundTransparency = 1
		HeaderText.Position = UDim2.new(0, 10, 0, 8)
		HeaderText.Size = UDim2.new(1, -20, 0, 20)
		HeaderText.ZIndex = 201
		HeaderText.Font = Enum.Font.GothamBold
		HeaderText.Text = "About"
		Fatality:Register(HeaderText, "Main", "TextColor3") 
		HeaderText.TextSize = 14
		HeaderText.TextXAlignment = Enum.TextXAlignment.Left

		CloseButton.Name = "Close"
		CloseButton.Parent = AboutFrame
		CloseButton.BackgroundTransparency = 1
		CloseButton.Position = UDim2.new(1, -25, 0, 8)
		CloseButton.Size = UDim2.new(0, 15, 0, 15)
		CloseButton.ZIndex = 202
		CloseButton.Font = Enum.Font.GothamBold
		CloseButton.Text = "x"
		CloseButton.TextColor3 = Color3.fromRGB(150, 150, 150)
		CloseButton.TextSize = 14
		
		CloseButton.MouseEnter:Connect(function() game:GetService("TweenService"):Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,255,255)}):Play() end)
		CloseButton.MouseLeave:Connect(function() game:GetService("TweenService"):Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150,150,150)}):Play() end)
		CloseButton.MouseButton1Click:Connect(function() AboutFrame.Visible = false end)

		ContentFrame.Name = "Content"
		ContentFrame.Parent = AboutFrame
		ContentFrame.BackgroundTransparency = 1
		ContentFrame.Position = UDim2.new(0, 10, 0, 35)
		ContentFrame.Size = UDim2.new(1, -20, 1, -45)
		ContentFrame.ZIndex = 201

		LogoContainer.Name = "Logo"
		LogoContainer.Parent = ContentFrame
		LogoContainer.BackgroundTransparency = 1
		LogoContainer.Size = UDim2.new(1, 0, 0, 30)
		LogoContainer.ZIndex = 202

		local function createGlitchText(color, offset, z)
			local l = Instance.new("TextLabel")
			l.Parent = LogoContainer
			l.BackgroundTransparency = 1
			l.Size = UDim2.new(1, 0, 1, 0)
			l.Position = UDim2.new(0, offset, 0, 0)
			l.Font = Enum.Font.GothamBlack
			l.Text = "Marketplace"
			l.TextColor3 = color
			l.TextSize = 22
			l.ZIndex = 202 + z
			return l
		end

		LogoRed = createGlitchText(Color3.fromRGB(255, 0, 0), -2, 0)
		LogoBlue = createGlitchText(Color3.fromRGB(0, 255, 255), 2, 0)
		LogoWhite = createGlitchText(Color3.fromRGB(255, 255, 255), 0, 1)

		CreditsText.Name = "Credits"
		CreditsText.Parent = ContentFrame
		CreditsText.BackgroundTransparency = 1
		CreditsText.Position = UDim2.new(0, 0, 0, 40)
		CreditsText.Size = UDim2.new(1, 0, 0, 120)
		CreditsText.ZIndex = 202
		CreditsText.Font = Enum.Font.GothamMedium
		CreditsText.TextSize = 11
		CreditsText.TextColor3 = Color3.fromRGB(200, 200, 200)
		CreditsText.TextXAlignment = Enum.TextXAlignment.Left
		CreditsText.TextYAlignment = Enum.TextYAlignment.Top
		CreditsText.RichText = true
		
		CreditsText.Text = table.concat({
			'<font color="#666666">// developed by</font>',
			'<b>grabis</b>', 
			' ',
			'<font color="#666666">// ui base by</font>',
			'<b>4lpaca</b>',
			' ',
			'<font color="#666666">// special thanks</font>',
			'<b>Mepilok, Tetraquark, ahk_lzt</b>',
			' ',
			'<font color="#666666">// 2026</font> <font color="#ff4a68">MARKETPLACE</font>'
		}, "<br />")

		LinkButton.Name = "LinkButton"
		LinkButton.Parent = ContentFrame
		LinkButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		LinkButton.Position = UDim2.new(0, 0, 1, -25)
		LinkButton.Size = UDim2.new(1, 0, 0, 25)
		LinkButton.ZIndex = 202
		LinkButton.AutoButtonColor = false
		LinkButton.Font = Enum.Font.GothamBold
		LinkButton.Text = "Public Software"
		LinkButton.TextColor3 = Color3.fromRGB(150, 150, 150)
		LinkButton.TextSize = 12
		
		UICorner_Btn.CornerRadius = UDim.new(0, 4)
		UICorner_Btn.Parent = LinkButton
		
		UIStroke_Btn.Color = Color3.fromRGB(29, 29, 29)
		UIStroke_Btn.Parent = LinkButton
		Fatality:Register(UIStroke_Btn, "Stroke", "Color")

		Fatality:CreateHover(LinkButton, function(hover) 
			local TS = game:GetService("TweenService")
			if hover then
				TS:Create(LinkButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play()
			else
				TS:Create(LinkButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150,150,150), BackgroundColor3 = Color3.fromRGB(12,12,12)}):Play()
			end
		end)

		InfoButton.MouseButton1Click:Connect(function()
			AboutFrame.Visible = not AboutFrame.Visible
			if AboutFrame.Visible then
				AboutFrame.Size = UDim2.new(0, 220, 0, 240)
				AboutFrame.BackgroundTransparency = 1
				for _, v in pairs(AboutFrame:GetDescendants()) do
					if v:IsA("TextLabel") or v:IsA("TextButton") then v.TextTransparency = 1 end
					if v:IsA("UIStroke") then v.Transparency = 1 end
				end
				
				local TS = game:GetService("TweenService")
				local info = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				
				TS:Create(AboutFrame, info, {Size = UDim2.new(0, 220, 0, 260), BackgroundTransparency = 0}):Play()
				TS:Create(UIStroke, info, {Transparency = 0}):Play()
				
				task.wait(0.1)
				for _, v in pairs(AboutFrame:GetDescendants()) do
					if v:IsA("TextLabel") or v:IsA("TextButton") then 
						TS:Create(v, TweenInfo.new(0.3), {TextTransparency = 0}):Play() 
					end
					if v:IsA("UIStroke") then TS:Create(v, TweenInfo.new(0.3), {Transparency = 0}):Play() end
				end
			end
		end)

		function Fatal:AddInfo(callback)
			LinkButton.MouseButton1Click:Connect(function()
				LinkButton.TextSize = 11
				task.wait(0.05)
				LinkButton.TextSize = 12
				callback()
			end)
		end;
	end

	function Fatal:GetButton()
		local backpack = Instance.new("TextButton")
		backpack.Name = "FATALITY_MOBILE_TOGGLE"
		backpack.BackgroundColor3 = Fatality:GetColor("Container")
		Fatality:Register(backpack, "Container")
		backpack.BorderSizePixel = 0
		backpack.Size = UDim2.new(0, 50, 0, 50) 
		backpack.AutoButtonColor = false
		backpack.Text = "" 

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = backpack

		local stroke = Instance.new("UIStroke")
		stroke.Color = Fatality:GetColor("Stroke")
		Fatality:Register(stroke, "Stroke", "Color")
		stroke.Parent = backpack
		
		local icon = Instance.new("TextLabel")
		icon.Name = "Icon"
		icon.Parent = backpack
		icon.BackgroundTransparency = 1
		icon.Size = UDim2.new(1, 0, 1, 0)
		icon.Font = Enum.Font.GothamBold
		icon.Text = "V"
		icon.TextColor3 = Fatality:GetColor("Main")
		Fatality:Register(icon, "Main", "TextColor3")
		icon.TextSize = 24

		backpack.MouseButton1Click:Connect(function()
			Fatal.Toggle = not Fatal.Toggle
			ToggleUI(Fatal.Toggle)
		end)

		return backpack
	end

	function Fatal:SetVisible(b)
		Fatal.Toggle = b;
		ToggleUI(b);
		if b then Fatalitywin.Enabled = true elseif FatalFrame.BackgroundTransparency >= 0.99 then Fatalitywin.Enabled = false end
	end;

	if Window.Visible == false then
		Fatal.Toggle = false
		SaveButton.Position = UDim2.new(0,35,1, 20) SearchButton.Position = UDim2.new(0,10,1, 20) InfoButton.Position = UDim2.new(1, -5,1, 20) UIStroke.Thickness = 0 UIStroke.Transparency = 1 UserIcon.ImageTransparency = 1 UserIcon.Position = UDim2.new(1, -10,0.5, 0) User_name.TextTransparency = 1 User_name.Position = UDim2.new(1, -40,0, 3) expire_days.TextTransparency = 1 expire_days.Position = UDim2.new(1, -40,0, 16) HeaderText.TextStrokeTransparency = 1 HeaderText.TextTransparency = 1 HeaderLineShadow_2.BackgroundTransparency = 1 InfoButton.ImageTransparency = 1 SearchButton.ImageTransparency = 1 SaveButton.ImageTransparency = 1 HeaderLineShadow.BackgroundTransparency = 1 FatalFrame.BackgroundTransparency = 1 Header.BackgroundTransparency = 1 HeaderLine.BackgroundTransparency = 1 Bottom.BackgroundTransparency = 1 HeaderLine_2.BackgroundTransparency = 1 DropShadow.ImageTransparency = 1
		Fatalitywin.Enabled = false
	else
		Fatalitywin.Enabled = true 
		ToggleUI(true);
	end

	-- Holiday Mascot
	local oldHoliday = CoreGui:FindFirstChild("Fatality_HolidayParticles")
	if oldHoliday then oldHoliday:Destroy() end

	local HolidayGUI = Instance.new("ScreenGui")
	HolidayGUI.Name = "Fatality_HolidayParticles"
	HolidayGUI.IgnoreGuiInset = true
	HolidayGUI.DisplayOrder = Fatalitywin.DisplayOrder - 1
	HolidayGUI.Parent = CoreGui
	HolidayGUI.Enabled = false

	local ParticlesContainer = Instance.new("Frame")
	ParticlesContainer.Size = UDim2.fromScale(1, 1)
	ParticlesContainer.BackgroundTransparency = 1
	ParticlesContainer.Parent = HolidayGUI

	local MascotContainer = Instance.new("Frame")
	MascotContainer.Name = "MascotContainer"
	MascotContainer.BackgroundTransparency = 1
	MascotContainer.Size = Window.Scale
	MascotContainer.Position = FatalFrame.Position
	MascotContainer.AnchorPoint = FatalFrame.AnchorPoint
	MascotContainer.ZIndex = 1000
	MascotContainer.Parent = Fatalitywin
	
	local MascotScale = Instance.new("UIScale", MascotContainer)
	MascotScale.Scale = Fatality.Scale
	table.insert(Fatality.ScalesRegistry, MascotScale)

	FatalFrame:GetPropertyChangedSignal("Position"):Connect(function() MascotContainer.Position = FatalFrame.Position end)

	local MascotImg = Instance.new("ImageLabel")
	MascotImg.Name = "HolidayMascot"
	MascotImg.BackgroundTransparency = 1
	MascotImg.ZIndex = 1000 
	MascotImg.AnchorPoint = Vector2.new(0, 1)
	MascotImg.Position = UDim2.new(0, 10, 0, 15)
	MascotImg.Size = UDim2.fromOffset(120, 120)
	MascotImg.Parent = MascotContainer
	MascotImg.Visible = true

	Fatal.HolidayState = {
		MainEnabled = true, 
		Mascot = { Enabled = true, Position = "Left", Size = 120 },
		Particles = { Enabled = false, Count = 0, Speed = 40, Size = 15, Index = 0, Images = {}, Colors = {} },
		ActiveParticles = {}
	}

	local function ResetParticle(p)
		p.Pos = Vector2.new(math.random(0, CurrentCamera.ViewportSize.X), math.random(-CurrentCamera.ViewportSize.Y, -20))
		p.Vel = Vector2.new(0, 0)
		p.BaseSpeed = math.random(Fatal.HolidayState.Particles.Speed * 0.5, Fatal.HolidayState.Particles.Speed * 1.5)
		p.Sway = math.random() * 6.28
		p.RotSpeed = math.random(-100, 100) / 100
		p.TargetTrans = math.random(10, 50) / 100
		p.Size = Fatal.HolidayState.Particles.Size + math.random(-4, 4)
		
		local imgs = Fatal.HolidayState.Particles.Images
		local idx = Fatal.HolidayState.Particles.Index
		if idx == 0 or idx > #imgs then idx = math.random(1, math.max(1, #imgs)) end
		p.Obj.Image = imgs[idx] or ""
		
		local cols = Fatal.HolidayState.Particles.Colors
		p.Obj.ImageColor3 = cols[math.random(1, math.max(1, #cols))] or Color3.new(1,1,1)
	end

	local function SpawnParticle()
		local img = Instance.new("ImageLabel")
		img.BackgroundTransparency = 1
		img.Parent = ParticlesContainer
		local p = { Obj = img }
		ResetParticle(p)
		p.Pos = Vector2.new(math.random(0, CurrentCamera.ViewportSize.X), math.random(0, CurrentCamera.ViewportSize.Y))
		return p
	end

	local HolidayRenderConn
	HolidayRenderConn = RunService.RenderStepped:Connect(function(dt)
		if not FatalFrame or not FatalFrame.Parent then
			if HolidayRenderConn then HolidayRenderConn:Disconnect() end
			if HolidayGUI then HolidayGUI:Destroy() end
			return
		end

		local state = Fatal.HolidayState
		if not Fatal.Toggle or not state.MainEnabled or not state.Particles.Enabled then
			HolidayGUI.Enabled = false
			return
		end
		HolidayGUI.Enabled = true

		while #state.ActiveParticles < state.Particles.Count do table.insert(state.ActiveParticles, SpawnParticle()) end
		while #state.ActiveParticles > state.Particles.Count do
			local p = table.remove(state.ActiveParticles)
			if p and p.Obj then p.Obj:Destroy() end
		end

		local mousePos = UserInputService:GetMouseLocation()
		local vpSize = CurrentCamera.ViewportSize
		local time = os.clock()

		for i, p in ipairs(state.ActiveParticles) do
			local sway = math.sin((time * 2) + p.Sway) * 20
			local dir = p.Pos - mousePos
			local dist = dir.Magnitude
			
			if dist < 90 then
				local force = (1 - (dist / 90)) * 700
				p.Vel = p.Vel + (dir.Unit * force * dt)
			end
			
			p.Pos = p.Pos + (Vector2.new(sway, p.BaseSpeed) * dt) + (p.Vel * dt)
			p.Vel = p.Vel * 0.98
			p.Obj.Rotation = p.Obj.Rotation + p.RotSpeed
			p.Obj.Position = UDim2.fromOffset(p.Pos.X, p.Pos.Y)
			p.Obj.Size = UDim2.fromOffset(p.Size, p.Size)
			p.Obj.ImageTransparency = p.TargetTrans

			if p.Pos.Y > vpSize.Y + p.Size then ResetParticle(p) end
		end
	end)

	function Fatal:InitHoliday(Config)
		Config = Config or {}
		MascotImg.Image = Config.MascotImage or "rbxassetid://79279979693699"
		Fatal.HolidayState.Particles.Images = Config.ParticleImages or {"rbxassetid://80131833917905", "rbxassetid://125571352815581", "rbxassetid://102097359445566", "rbxassetid://131567563653537"}
		Fatal.HolidayState.Particles.Colors = Config.ParticleColors or {Color3.new(1,1,1)}
		Fatal.HolidayState.MainEnabled = true
	end

	function Fatal:UpdateHoliday(Category, Setting, Value)
		local state = Fatal.HolidayState
		if Category == "Main" and Setting == "Enabled" then
			state.MainEnabled = Value
			MascotImg.Visible = Value and state.Mascot.Enabled
		elseif state[Category] then
			state[Category][Setting] = Value
			
			if Category == "Mascot" then
				if Setting == "Enabled" then MascotImg.Visible = state.MainEnabled and Value end
				if Setting == "Size" then MascotImg.Size = UDim2.fromOffset(Value, Value) end
				if Setting == "Position" then
					if Value == "Left" then MascotImg.AnchorPoint = Vector2.new(0, 1); MascotImg.Position = UDim2.new(0, 10, 0, 15)
					elseif Value == "Center" then MascotImg.AnchorPoint = Vector2.new(0.5, 1); MascotImg.Position = UDim2.new(0.5, 0, 0, 15)
					elseif Value == "Right" then MascotImg.AnchorPoint = Vector2.new(1, 1); MascotImg.Position = UDim2.new(1, -20, 0, 15) end
				end
			elseif Category == "Particles" then
				if Setting == "Index" then
					for _, p in ipairs(state.ActiveParticles) do
						local imgs = state.Particles.Images
						p.Obj.Image = (Value == 0) and (imgs[math.random(1, #imgs)] or "") or (imgs[Value] or "")
					end
				end
			end
		end
	end

	return Fatal;
end;

function Fatality:Loader(Config: Loader)
	Config = Config or {}
	Config.Name = Config.Name or "FATALITY"
	Config.Duration = Config.Duration or 3.5
	Config.Scale = Config.Scale or 3
	Config.Manual = Config.Manual or false

	local Blur = Instance.new('BlurEffect')
	local Loader = Instance.new("ScreenGui")
	local center = Instance.new("Frame")
	local texts = Instance.new("Frame")
	local UIListLayout = Instance.new("UIListLayout")
	local BlackFrame = Instance.new("Frame")

	Loader.Name = Fatality:RandomString()
	Loader.Parent = CoreGui
	Loader.IgnoreGuiInset = true
	Loader.ZIndexBehavior = Enum.ZIndexBehavior.Global

	center.Parent = Loader
	center.AnchorPoint = Vector2.new(0.5, 0.5)
	center.BackgroundTransparency = 1
	center.Position = UDim2.new(0.5, 0, 0.5, 0)

	texts.Parent = Loader
	texts.AnchorPoint = Vector2.new(0.5, 0.5)
	texts.BackgroundTransparency = 1
	texts.Position = UDim2.new(0.5, 0, 0.5, 0)
	texts.Size = UDim2.new(1, 0, 0, 200)

	UIListLayout.Parent = texts
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIListLayout.Padding = UDim.new(0, Config.Scale * 5)

	BlackFrame.Parent = Loader
	BlackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	BlackFrame.BackgroundTransparency = 1
	BlackFrame.Size = UDim2.new(1, 0, 1, 0)
	BlackFrame.ZIndex = -1

	Blur.Size = 0
	Blur.Parent = game:GetService('Lighting')

	Fatality:CreateAnimation(Blur,1,{ Size = 60 })
	Fatality:CreateAnimation(BlackFrame,0.5,{ BackgroundTransparency = 0.7 })

	local UText = { Y = 14 }
	local PosText = {}
	local IsFirst = true

	local function createText(TEXT)
		local LIT = Instance.new("Frame")
		local ASCII = Instance.new("TextLabel")
		local UIGradient = Instance.new("UIGradient")
		local UIScale = Instance.new("UIScale")

		LIT.BackgroundTransparency = 1
		LIT.Size = UDim2.new(0, 56, 0, 100)
		LIT.ZIndex = 8

		ASCII.Parent = LIT
		ASCII.AnchorPoint = Vector2.new(0.5, 0.5)
		ASCII.BackgroundTransparency = 1
		ASCII.Position = UDim2.new(0.5, 0, 0.5, 0)
		ASCII.Size = UDim2.new(0, 28, 0, 50)
		ASCII.ZIndex = 8
		ASCII.Font = Enum.Font.GothamBold
		ASCII.Text = TEXT
		ASCII.TextColor3 = Color3.fromRGB(255, 255, 255)
		ASCII.TextSize = 50.000
		ASCII.TextWrapped = true

		local textsize = Fatality:GetTextSize(ASCII)
		ASCII.Size = UDim2.new(0, textsize.X + 100, 0, 50)
		LIT.Size = UDim2.new(0, (textsize.X * 2.5) + (UText[TEXT] or 0), 0, 100)

		UIGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 116, 116)), 
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(132, 58, 58))
		}
		UIGradient.Rotation = 88
		UIGradient.Parent = ASCII

		UIScale.Parent = ASCII
		UIScale.Scale = Config.Scale

		return LIT, ASCII
	end

	for i = 1, #Config.Name do
		local char = Config.Name:sub(i,i)
		local L, A = createText(char)
		L.Parent = texts
		A.TextTransparency = 1
		
		if i > 1 then
			A.Position = UDim2.new(0.5,0,0.5,200)
		end
		
		table.insert(PosText,{ Frame = L, Text = A })
	end

	task.spawn(function()
		local FirstChar = PosText[1].Text
		local FirstScale = FirstChar:FindFirstChild("UIScale")
		
		FirstScale.Scale = Config.Scale * 4
		Fatality:CreateAnimation(FirstChar, 0.45, { TextTransparency = 0 })
		Fatality:CreateAnimation(FirstScale, 0.5, { Scale = Config.Scale })
		
		task.wait(0.45)
		
		for i,v in next , PosText do
			if i > 1 then
				Fatality:CreateAnimation(v.Text,0.65,{
					Position = UDim2.new(0.5,0,0.5,0),
					TextTransparency = 0
				})
			end
		end
	end)

	local Controller = {
		IsFinished = false,
		Finish = function(self)
			if self.IsFinished then return end
			self.IsFinished = true
			
			for i,v in next , PosText do
				Fatality:CreateAnimation(v.Text, 1.0, { TextTransparency = 1 })
			end
			Fatality:CreateAnimation(Blur, 1.0, { Size = 0 })
			Fatality:CreateAnimation(BlackFrame, 1.0, { BackgroundTransparency = 1 })
			
			task.wait(1.1)
			Loader:Destroy()
			Blur:Destroy()
		end
	}

	if not Config.Manual then
		task.wait(Config.Duration or 3.5)
		Controller:Finish()
	end

	return Controller
end

function Fatality:CreateNotifier(): Notifier
	if Fatality.__NOTIFIER_CACHE then return Fatality.__NOTIFIER_CACHE end

	local Notify = Instance.new("ScreenGui")
	local layout = Instance.new("Frame")
	local UIListLayout = Instance.new("UIListLayout")

	Notify.Name = Fatality:RandomString()
	Notify.Parent = CoreGui
	Notify.ResetOnSpawn = false
	Notify.ZIndexBehavior = Enum.ZIndexBehavior.Global
	Notify.IgnoreGuiInset = true

	layout.Name = Fatality:RandomString()
	layout.Parent = Notify
	layout.AnchorPoint = Vector2.new(1, 0)
	layout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	layout.BackgroundTransparency = 1.000
	layout.BorderColor3 = Color3.fromRGB(0, 0, 0)
	layout.BorderSizePixel = 0
	layout.Position = UDim2.new(1, -5, 0, 5)
	layout.Size = UDim2.new(0, 150, 0, 50)
	
	local NotifyScale = Instance.new("UIScale", layout) 
	NotifyScale.Scale = Fatality.Scale
	table.insert(Fatality.ScalesRegistry, NotifyScale)

	UIListLayout.Parent = layout
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local res = Fatality:CreateResponse({
		Notify = function(Config: Notify)
			Config = Config or {}
			Config.Icon = Config.Icon or "settings"
			Config.Content = Config.Content or nil
			Config.Title = Config.Title or "Notification"
			Config.Duration = Config.Duration or 5

			local notify = Instance.new("Frame")
			local notify_block = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local UIStroke = Instance.new("UIStroke")
			local Icon = Instance.new("ImageLabel")
			local HeaderText = Instance.new("TextLabel")
			local BodyText = Instance.new("TextLabel")

			notify.Name = Fatality:RandomString()
			notify.Parent = layout
			notify.BackgroundColor3 = Fatality:GetColor("Background")
			notify.BackgroundTransparency = 1.000
			notify.BorderColor3 = Color3.fromRGB(0, 0, 0)
			notify.BorderSizePixel = 0
			notify.Size = UDim2.new(0, 0, 0, 0)

			notify_block.Name = Fatality:RandomString()
			notify_block.Parent = notify
			notify_block.AnchorPoint = Vector2.new(0.5, 0)
			Fatality:Register(notify_block, "Container")
			notify_block.BackgroundTransparency = 1
			notify_block.BorderColor3 = Color3.fromRGB(0, 0, 0)
			notify_block.BorderSizePixel = 0
			notify_block.Position = UDim2.new(0.5, 0, -1, 0)
			notify_block.Size = UDim2.new(1, 0, 1, -12)
			notify_block.ClipsDescendants = true
			notify_block.ZIndex = 54

			UICorner.CornerRadius = UDim.new(0, 3)
			UICorner.Parent = notify_block

			UIStroke.Thickness = 1
			UIStroke.Transparency = 1
			Fatality:Register(UIStroke, "Stroke", "Color") 
			UIStroke.Parent = notify_block

			Icon.Name = Fatality:RandomString()
			Icon.Parent = notify_block
			Fatality:Register(Icon, "Main", "ImageColor3")
			Icon.BackgroundTransparency = 1.000
			Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Icon.BorderSizePixel = 0
			Icon.Position = UDim2.new(0, 7, 0, 7)
			Icon.Size = UDim2.new(0, 18, 0, 18)
			Icon.Image = Fatality:GetIcon(Config.Icon)
			Icon.ImageTransparency = 1
			Icon.ZIndex = 55

			HeaderText.Name = Fatality:RandomString()
			HeaderText.Parent = notify_block
			HeaderText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			HeaderText.BackgroundTransparency = 1.000
			HeaderText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			HeaderText.BorderSizePixel = 0
			HeaderText.Position = UDim2.new(0, 30, 0, 7)
			HeaderText.Size = UDim2.new(1, 0, 0, 15)
			HeaderText.ZIndex = 55
			HeaderText.FontFace = Fatality.FontSemiBold
			HeaderText.Text = Config.Title
			Fatality:Register(HeaderText, "Main", "TextColor3") 
			HeaderText.TextSize = 13.000
			HeaderText.TextTransparency = 1
			HeaderText.TextXAlignment = Enum.TextXAlignment.Left

			BodyText.Name = Fatality:RandomString()
			BodyText.Parent = notify_block
			BodyText.AnchorPoint = Vector2.new(0, 1)
			BodyText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BodyText.BackgroundTransparency = 1.000
			BodyText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			BodyText.BorderSizePixel = 0
			BodyText.Position = UDim2.new(0, 10, 1, 0)
			BodyText.Size = UDim2.new(1, -15, 1, -29)
			BodyText.ZIndex = 55
			BodyText.FontFace = Fatality.FontSemiBold
			BodyText.Text = Config.Content or ""
			Fatality:Register(BodyText, "Text", "TextColor3")
			BodyText.TextSize = 12.000
			BodyText.TextTransparency = 1
			BodyText.TextWrapped = true
			BodyText.TextXAlignment = Enum.TextXAlignment.Left
			BodyText.TextYAlignment = Enum.TextYAlignment.Top

			local updateScale = function()
				local TitleScale = Fatality:GetTextSize(HeaderText,Enum.Font.GothamBold)
				local ContentScale = Fatality:GetTextSize(BodyText,Enum.Font.GothamMedium)

				local XScale = (TitleScale.X > ContentScale.X and TitleScale.X) or ContentScale.X
				local YScale = (TitleScale.Y > ContentScale.Y and TitleScale.Y) or ContentScale.Y

				notify.Size = UDim2.new(0, XScale + 25, 0, YScale + 50)

				Fatality:CreateAnimation(notify_block,0.35,{
					Position = UDim2.new(0.5, 0, 0, 0)
				})
			end

			task.delay(0.1,function()
				Fatality:CreateAnimation(notify_block,0.25,{
					BackgroundTransparency = 0.1
				})

				Fatality:CreateAnimation(UIStroke,0.25,{
					Thickness = 2.500,
					Transparency = 0.900
				})

				Fatality:CreateAnimation(Icon,0.25,{
					ImageTransparency = 0
				})

				Fatality:CreateAnimation(HeaderText,0.25,{
					TextTransparency = 0.200
				})

				Fatality:CreateAnimation(BodyText,0.25,{
					TextTransparency = 0.3
				})
			end)

			updateScale()

			task.delay(Config.Duration + 0.25,function()
				Fatality:CreateAnimation(notify_block,0.35,{
					Position = UDim2.new(0.5, 0, 1, 0)
				})

				Fatality:CreateAnimation(notify_block,0.25,{
					BackgroundTransparency = 1
				})

				Fatality:CreateAnimation(UIStroke,0.25,{
					Thickness = 1,
					Transparency = 1
				})

				Fatality:CreateAnimation(Icon,0.25,{
					ImageTransparency = 1
				})

				Fatality:CreateAnimation(HeaderText,0.25,{
					TextTransparency = 1
				})

				Fatality:CreateAnimation(BodyText,0.25,{
					TextTransparency = 1
				})

				task.delay(0.35,function()
					Fatality:CreateAnimation(notify,0.5,{
						Size = UDim2.new(0,0,0,0)
					})
					task.wait(0.5)
					notify:Destroy()
				end)
			end)
		end,
	})

	Fatality.__NOTIFIER_CACHE = res

	return res
end

Fatality.FATALITY_PID = Fatality:RandomString()

return Fatality
