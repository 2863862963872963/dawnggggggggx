--[[
    Ascent UI Library v2.0 (Remastered)
    Update 2.0 Features:
    - Built-in Settings & Config System
    - New Themes (Midnight, High Contrast)
    - Visual Overhaul (Glassmorphism, smoother animations)
    - New Components: ColorPicker, Keybind, Textbox
    - Performance Optimizations
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Ascent = {
    Version = "2.0.0",
    IsMobile = UserInputService.TouchEnabled,
    Icons = {
        Search = "rbxassetid://6031154871",
        Arrow = "rbxassetid://6034818372",
        Check = "rbxassetid://6031094620",
        Close = "rbxassetid://3944676354",
        Settings = "rbxassetid://3944680069", -- Gear icon
        Edit = "rbxassetid://6031302932"
    },
    CurrentWindow = nil,
    Flags = {},
    ConfigFolder = "AscentConfig",
    ConfigFile = "default.json",
    Theme = nil,
    Keybind = Enum.KeyCode.RightControl
}

--// THEMES
Ascent.Themes = {
    MacDark = {
        Main = Color3.fromRGB(32, 32, 37),
        Sidebar = Color3.fromRGB(40, 40, 45),
        Element = Color3.fromRGB(50, 50, 56),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 170),
        Divider = Color3.fromRGB(65, 65, 70),
        Accent = Color3.fromRGB(0, 122, 255),
        Hover = Color3.fromRGB(60, 60, 66),
        Stroke = Color3.fromRGB(80, 80, 90),
        Success = Color3.fromRGB(48, 209, 88),
        Warning = Color3.fromRGB(255, 214, 10),
        Error = Color3.fromRGB(255, 69, 58),
        Transparency = 0.05
    },
    MacLight = {
        Main = Color3.fromRGB(245, 245, 250),
        Sidebar = Color3.fromRGB(230, 230, 235),
        Element = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(20, 20, 20),
        SubText = Color3.fromRGB(100, 100, 110),
        Divider = Color3.fromRGB(210, 210, 220),
        Accent = Color3.fromRGB(0, 122, 255),
        Hover = Color3.fromRGB(245, 245, 245),
        Stroke = Color3.fromRGB(200, 200, 210),
        Success = Color3.fromRGB(52, 199, 89),
        Warning = Color3.fromRGB(255, 204, 0),
        Error = Color3.fromRGB(255, 59, 48),
        Transparency = 0.05
    },
    Midnight = {
        Main = Color3.fromRGB(15, 15, 20),
        Sidebar = Color3.fromRGB(20, 20, 25),
        Element = Color3.fromRGB(25, 25, 30),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(130, 130, 140),
        Divider = Color3.fromRGB(40, 40, 50),
        Accent = Color3.fromRGB(138, 43, 226), -- Purple
        Hover = Color3.fromRGB(35, 35, 40),
        Stroke = Color3.fromRGB(50, 50, 60),
        Success = Color3.fromRGB(100, 255, 100),
        Warning = Color3.fromRGB(255, 230, 50),
        Error = Color3.fromRGB(255, 80, 80),
        Transparency = 0.1
    },
    HighContrast = {
        Main = Color3.fromRGB(0, 0, 0),
        Sidebar = Color3.fromRGB(10, 10, 10),
        Element = Color3.fromRGB(0, 0, 0),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 200),
        Divider = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 255, 255), -- Cyan
        Hover = Color3.fromRGB(30, 30, 30),
        Stroke = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 255, 0),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 0, 0),
        Transparency = 0
    }
}
Ascent.Theme = Ascent.Themes.MacDark

--// UTILITY FUNCTIONS
local function Create(class, props)
    local inst = Instance.new(class)
    if props.Parent then inst.Parent = props.Parent end
    if class:find("Text") then inst.RichText = true end
    for k, v in pairs(props) do 
        if k ~= "Parent" then inst[k] = v end 
    end
    return inst
end

local function Tween(obj, duration, props, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(duration, style, dir), props):Play()
end

local function AddShadow(Parent, Transparency)
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = Parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -25, 0, -25),
        Size = UDim2.new(1, 50, 1, 50),
        ZIndex = 0,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = Transparency or 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })
    return Shadow
end

local function MakeDraggable(TopBar, Object)
    local Dragging, DragInput, DragStart, StartPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = Object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            TweenService:Create(Object, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
            }):Play()
        end
    end)
end

--// CONFIG SYSTEM
function Ascent:SaveSettings()
    if not isfolder or not writefile then return end -- Support check
    
    local Config = {
        Flags = Ascent.Flags,
        Theme = "MacDark", -- Default fallback
        Keybind = tostring(Ascent.Keybind)
    }
    
    -- Detect current theme name
    for name, theme in pairs(Ascent.Themes) do
        if Ascent.Theme == theme then Config.Theme = name break end
    end
    
    if not isfolder(Ascent.ConfigFolder) then makefolder(Ascent.ConfigFolder) end
    writefile(Ascent.ConfigFolder .. "/" .. Ascent.ConfigFile, HttpService:JSONEncode(Config))
end

function Ascent:LoadSettings()
    if not isfile or not readfile then return end
    local Path = Ascent.ConfigFolder .. "/" .. Ascent.ConfigFile
    if isfile(Path) then
        local Success, Decoded = pcall(function() return HttpService:JSONDecode(readfile(Path)) end)
        if Success then
            -- Load Flags
            for flag, value in pairs(Decoded.Flags or {}) do
                Ascent.Flags[flag] = value
                -- Note: Elements need to listen to flags, this simply sets the data
            end
            
            -- Load Keybind
            if Decoded.Keybind then
                local K = Enum.KeyCode[Decoded.Keybind:gsub("Enum.KeyCode.", "")]
                if K then Ascent.Keybind = K end
            end
            
            -- Load Theme
            if Decoded.Theme and Ascent.Themes[Decoded.Theme] then
                Ascent.Theme = Ascent.Themes[Decoded.Theme]
                -- Note: Theme reloading requires UI rebuild or heavy binding, skipping for simplicity in v2.0
            end
        end
    end
end

--// NOTIFICATION SYSTEM
function Ascent:Notify(Config)
    Config = Config or {}
    if not Ascent.NotificationArea then return end
    
    local Card = Create("Frame", {
        Parent = Ascent.NotificationArea, BackgroundColor3 = Ascent.Theme.Main,
        Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 0.1, ClipsDescendants = true
    })
    Create("UICorner", {Parent = Card, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = Card, Color = Ascent.Theme.Stroke, Thickness = 1})
    AddShadow(Card, 0.5)
    
    local Title = Create("TextLabel", {
        Parent = Card, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 10), Size = UDim2.new(1, -20, 0, 20),
        Text = Config.Title or "Notification", Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local Content = Create("TextLabel", {
        Parent = Card, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 30), Size = UDim2.new(1, -20, 0, 0),
        Text = Config.Content or "", Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y
    })
    
    local Bar = Create("Frame", {
        Parent = Card, BackgroundColor3 = Ascent.Theme.Accent, Size = UDim2.new(0, 3, 1, 0), Position = UDim2.new(0, 0, 0, 0)
    })
    Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(0, 2)})

    Tween(Card, 0.5, {Size = UDim2.new(1, 0, 0, 80)}, Enum.EasingStyle.Back)
    
    task.delay(Config.Duration or 3, function()
        if Card and Card.Parent then
            local Out = TweenService:Create(Card, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
            Out:Play()
            Out.Completed:Wait()
            Card:Destroy()
        end
    end)
end

--// COMPONENT LOGIC
local function CreateContainer(Parent)
    local Funcs = {}
    
    local function ElementBase(Height)
        local F = Create("Frame", {
            Parent = Parent, BackgroundColor3 = Ascent.Theme.Element,
            BackgroundTransparency = Ascent.Theme.Transparency, Size = UDim2.new(1, 0, 0, Height),
            BorderSizePixel = 0
        })
        Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {Parent = F, Color = Ascent.Theme.Stroke, Thickness = 1, Transparency = 0.5})
        return F
    end

    --// SECTION
    function Funcs:AddSection(Title)
        local SectionFrame = Create("Frame", {
            Parent = Parent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y
        })
        local Text = Create("TextLabel", {
            Parent = SectionFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
            Text = Title, Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Container = Create("Frame", {
            Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        
        return CreateContainer(Container)
    end

    --// BUTTON
    function Funcs:AddButton(Config)
        local Frame = ElementBase(38)
        local Btn = Create("TextButton", {
            Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            Text = Config.Text or "Button", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13
        })
        
        Btn.MouseEnter:Connect(function() Tween(Frame, 0.2, {BackgroundColor3 = Ascent.Theme.Hover}) end)
        Btn.MouseLeave:Connect(function() Tween(Frame, 0.2, {BackgroundColor3 = Ascent.Theme.Element}) end)
        
        Btn.MouseButton1Click:Connect(function()
            Tween(Frame, 0.1, {BackgroundColor3 = Ascent.Theme.Accent})
            task.delay(0.1, function() Tween(Frame, 0.3, {BackgroundColor3 = Ascent.Theme.Hover}) end)
            if Config.Callback then Config.Callback() end
        end)
        
        local API = {}
        function API:SetText(t) Btn.Text = t end
        return API
    end

    --// TOGGLE
    function Funcs:AddToggle(Config)
        local State = Ascent.Flags[Config.Flag] or Config.Default or false
        local Frame = ElementBase(38)
        
        Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0),
            Text = Config.Text or "Toggle", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local SwitchBg = Create("Frame", {
            Parent = Frame, BackgroundColor3 = State and Ascent.Theme.Accent or Ascent.Theme.Divider,
            Position = UDim2.new(1, -48, 0.5, -10), Size = UDim2.new(0, 36, 0, 20)
        })
        Create("UICorner", {Parent = SwitchBg, CornerRadius = UDim.new(1, 0)})
        
        local Knob = Create("Frame", {
            Parent = SwitchBg, BackgroundColor3 = Color3.new(1,1,1),
            Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)
        })
        Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
        
        local Button = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""})
        
        local function Update()
            if Config.Flag then Ascent.Flags[Config.Flag] = State end
            local TargetPos = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local TargetColor = State and Ascent.Theme.Accent or Ascent.Theme.Divider
            Tween(Knob, 0.25, {Position = TargetPos})
            Tween(SwitchBg, 0.25, {BackgroundColor3 = TargetColor})
            if Config.Callback then Config.Callback(State) end
        end
        
        Button.MouseButton1Click:Connect(function() State = not State; Update() end)
        if Config.Flag then Ascent.Flags[Config.Flag] = State end
        
        local API = {}
        function API:Set(v) State = v; Update() end
        return API
    end
    
    --// SLIDER
    function Funcs:AddSlider(Config)
        local Min, Max = Config.Min or 0, Config.Max or 100
        local Def = Ascent.Flags[Config.Flag] or Config.Default or Min
        local Value = Def
        
        local Frame = ElementBase(50)
        
        Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 5), Size = UDim2.new(1, -50, 0, 20),
            Text = Config.Text or "Slider", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Input = Create("TextBox", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -50, 0, 5), Size = UDim2.new(0, 40, 0, 20),
            Text = tostring(Value), Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Accent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right
        })
        
        local Bar = Create("Frame", {
            Parent = Frame, BackgroundColor3 = Ascent.Theme.Divider, Position = UDim2.new(0, 12, 0, 35), Size = UDim2.new(1, -24, 0, 6)
        })
        Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
        
        local Fill = Create("Frame", {
            Parent = Bar, BackgroundColor3 = Ascent.Theme.Accent, Size = UDim2.new((Value - Min)/(Max - Min), 0, 1, 0)
        })
        Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
        
        local Knob = Create("Frame", {
            Parent = Fill, BackgroundColor3 = Color3.new(1,1,1), Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)
        })
        Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
        
        local Interact = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0), Text = ""})
        
        local function Update(InputVal)
            local Clamped = math.clamp(InputVal, Min, Max)
            local Percent = (Clamped - Min) / (Max - Min)
            Value = Clamped
            
            Tween(Fill, 0.1, {Size = UDim2.new(Percent, 0, 1, 0)})
            Input.Text = tostring(math.floor(Value * 100)/100)
            
            if Config.Flag then Ascent.Flags[Config.Flag] = Value end
            if Config.Callback then Config.Callback(Value) end
        end
        
        local Dragging = false
        Interact.InputBegan:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = true end 
        end)
        UserInputService.InputEnded:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end 
        end)
        UserInputService.InputChanged:Connect(function(input)
            if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local SizeX = Bar.AbsoluteSize.X
                local PosX = Bar.AbsolutePosition.X
                local P = math.clamp((input.Position.X - PosX) / SizeX, 0, 1)
                Update(Min + (P * (Max - Min)))
            end
        end)
        
        Input.FocusLost:Connect(function()
            local N = tonumber(Input.Text)
            if N then Update(N) else Input.Text = tostring(Value) end
        end)
        
        if Config.Flag then Ascent.Flags[Config.Flag] = Value end
        local API = {}
        function API:Set(v) Update(v) end
        return API
    end
    
    --// COLOR PICKER (New!)
    function Funcs:AddColorPicker(Config)
        local Default = Config.Default or Color3.fromRGB(255, 255, 255)
        local CVal = Default
        local Open = false
        
        local Frame = ElementBase(38)
        Frame.ClipsDescendants = true
        
        Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -70, 0, 38),
            Text = Config.Text or "Color Picker", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Preview = Create("TextButton", {
            Parent = Frame, BackgroundColor3 = Default, Position = UDim2.new(1, -50, 0, 9), Size = UDim2.new(0, 40, 0, 20), Text = "", AutoButtonColor = false
        })
        Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 4)})
        Create("UIStroke", {Parent = Preview, Color = Ascent.Theme.Stroke, Thickness = 1})
        
        -- Picker UI inside
        local PickerFrame = Create("Frame", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 0, 100)
        })
        
        -- Quick Implementation of a Color Picker logic needed here, keeping it simple for single file
        local ColorImg = Create("ImageButton", {
            Parent = PickerFrame, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0, 150, 0, 80),
            Image = "rbxassetid://4155801252", ImageColor3 = Color3.new(1,0,0) -- Sat/Val Gradient
        })
        Create("UICorner", {Parent = ColorImg, CornerRadius = UDim.new(0, 4)})
        
        local BarImg = Create("ImageButton", {
            Parent = PickerFrame, Position = UDim2.new(0, 170, 0, 0), Size = UDim2.new(0, 20, 0, 80),
            Image = "rbxassetid://4155801252" -- Reuse or use a hue strip asset
        })
        -- Using a Frame gradient for Hue since asset might fail
        BarImg.ImageTransparency = 1
        local Gradient = Create("UIGradient", {
            Parent = Create("Frame", {Parent = BarImg, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(1,1,1)}),
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.16, Color3.new(1,1,0)),
                ColorSequenceKeypoint.new(0.32, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.48, Color3.new(0,1,1)),
                ColorSequenceKeypoint.new(0.64, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.80, Color3.new(1,0,1)),
                ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
            }, Rotation = 90
        })
        
        local h, s, v = Default:ToHSV()
        
        local function UpdateColor()
            CVal = Color3.fromHSV(h, s, v)
            Preview.BackgroundColor3 = CVal
            ColorImg.ImageColor3 = Color3.fromHSV(h, 1, 1)
            if Config.Callback then Config.Callback(CVal) end
            if Config.Flag then Ascent.Flags[Config.Flag] = CVal end
        end
        
        ColorImg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local dragging = true
                while dragging do
                    local p = UserInputService:GetMouseLocation() - ColorImg.AbsolutePosition
                    s = math.clamp(p.X / ColorImg.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp(p.Y / ColorImg.AbsoluteSize.Y, 0, 1)
                    UpdateColor()
                    RunService.RenderStepped:Wait()
                    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then dragging = false end
                end
            end
        end)
        
        BarImg.InputBegan:Connect(function(input)
             if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local dragging = true
                 while dragging do
                    local p = UserInputService:GetMouseLocation() - BarImg.AbsolutePosition
                    h = 1 - math.clamp(p.Y / BarImg.AbsoluteSize.Y, 0, 1)
                    UpdateColor()
                    RunService.RenderStepped:Wait()
                    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then dragging = false end
                end
            end
        end)
        
        Preview.MouseButton1Click:Connect(function()
            Open = not Open
            Tween(Frame, 0.3, {Size = UDim2.new(1, 0, 0, Open and 130 or 38)})
        end)
    end

    --// TEXTBOX (New!)
    function Funcs:AddTextbox(Config)
        local Frame = ElementBase(38)
        
        Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -120, 1, 0),
            Text = Config.Text or "Textbox", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Input = Create("TextBox", {
            Parent = Frame, BackgroundColor3 = Ascent.Theme.Sidebar, Position = UDim2.new(1, -110, 0.5, -12), Size = UDim2.new(0, 100, 0, 24),
            Text = Config.Default or "", PlaceholderText = Config.Placeholder or "Type...", Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.Text, TextSize = 12
        })
        Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 4)})
        Create("UIStroke", {Parent = Input, Color = Ascent.Theme.Stroke, Thickness = 1})
        
        Input.FocusLost:Connect(function(enter)
            if Config.Callback then Config.Callback(Input.Text, enter) end
        end)
    end
    
    --// KEYBIND (New!)
    function Funcs:AddKeybind(Config)
        local Val = Config.Default or Enum.KeyCode.RightControl
        local Binding = false
        
        local Frame = ElementBase(38)
        
        Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -100, 1, 0),
            Text = Config.Text or "Keybind", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local BindBtn = Create("TextButton", {
            Parent = Frame, BackgroundColor3 = Ascent.Theme.Sidebar, Position = UDim2.new(1, -90, 0.5, -12), Size = UDim2.new(0, 80, 0, 24),
            Text = Val.Name, Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 12
        })
        Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
        Create("UIStroke", {Parent = BindBtn, Color = Ascent.Theme.Stroke, Thickness = 1})
        
        BindBtn.MouseButton1Click:Connect(function()
            Binding = true
            BindBtn.Text = "..."
            BindBtn.TextColor3 = Ascent.Theme.Accent
            
            local Con; Con = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    Val = input.KeyCode
                    BindBtn.Text = Val.Name
                    BindBtn.TextColor3 = Ascent.Theme.SubText
                    Binding = false
                    if Config.Callback then Config.Callback(Val) end
                    if Config.Flag then Ascent.Flags[Config.Flag] = Val end
                    Con:Disconnect()
                end
            end)
        end)
    end

    --// DROPDOWN
    function Funcs:AddDropdown(Config)
        local Selected = Config.Multi and {} or (Config.Default or nil)
        local Items = Config.Items or {}
        local IsOpen = false
        
        local Frame = ElementBase(38)
        Frame.ClipsDescendants = true
        
        local Label = Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -40, 0, 38),
            Text = Config.Text, Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Arrow = Create("ImageLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0, 12), Size = UDim2.new(0, 14, 0, 14),
            Image = Ascent.Icons.Arrow, ImageColor3 = Ascent.Theme.SubText
        })
        
        local Scroll = Create("ScrollingFrame", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 1, -45),
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Ascent.Theme.Accent
        })
        Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
        Create("UIPadding", {Parent = Scroll, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
        
        local function Refresh()
            for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            for _, item in ipairs(Items) do
                local Btn = Create("TextButton", {
                    Parent = Scroll, BackgroundColor3 = Ascent.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 26),
                    Text = "  " .. item, Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                
                Btn.MouseButton1Click:Connect(function()
                    Selected = item
                    Label.Text = Config.Text .. ": " .. item
                    IsOpen = false
                    Tween(Frame, 0.3, {Size = UDim2.new(1, 0, 0, 38)})
                    Tween(Arrow, 0.3, {Rotation = 0})
                    if Config.Callback then Config.Callback(Selected) end
                end)
            end
        end
        Refresh()
        
        local Trigger = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Text = ""})
        Trigger.MouseButton1Click:Connect(function()
            IsOpen = not IsOpen
            local H = math.min(#Items * 30 + 50, 200)
            Tween(Frame, 0.3, {Size = UDim2.new(1, 0, 0, IsOpen and H or 38)})
            Tween(Arrow, 0.3, {Rotation = IsOpen and 180 or 0})
        end)
        
        local API = {}
        function API:Refresh(n) Items = n; Refresh() end
        return API
    end

    return Funcs
end

--// MAIN
function Ascent:CreateWindow(Config)
    if Ascent.CurrentWindow then Ascent.CurrentWindow:Destroy() end
    
    local Title = Config.Title or "Ascent Library 2.0"
    local Size = Config.Size or UDim2.fromOffset(600, 380)
    Ascent.Keybind = Config.Keybind or Enum.KeyCode.RightControl
    
    -- Try Loading Config
    Ascent:LoadSettings()
    
    local Gui = Create("ScreenGui", {Name = "AscentApp", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    Ascent.CurrentWindow = Gui
    
    Ascent.NotificationArea = Create("Frame", {
        Parent = Gui, BackgroundTransparency = 1, Position = UDim2.new(1, -320, 0, 40), Size = UDim2.new(0, 300, 1, -40), ZIndex = 100
    })
    Create("UIListLayout", {Parent = Ascent.NotificationArea, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom})

    --// MAIN FRAME
    local MainFrame = Create("Frame", {
        Name = "Main", Parent = Gui, BackgroundColor3 = Ascent.Theme.Main,
        Size = Size, Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = Ascent.Theme.Transparency, ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 10)})
    Create("UIStroke", {Parent = MainFrame, Color = Ascent.Theme.Stroke, Thickness = 1, Transparency = 0.6})
    AddShadow(MainFrame, 0.6)
    
    MakeDraggable(MainFrame, MainFrame)
    
    --// SIDEBAR
    local Sidebar = Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = Ascent.Theme.Sidebar,
        Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = Ascent.Theme.Transparency
    })
    Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 10)})
    
    -- Cover rounded corners on right
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Ascent.Theme.Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0})
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Ascent.Theme.Divider, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BorderSizePixel = 0})
    
    -- Header
    local TitleLabel = Create("TextLabel", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 20), Size = UDim2.new(1, -20, 0, 25),
        Text = Title, Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 60), Size = UDim2.new(1, 0, 1, -100),
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0
    })
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
    Create("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 10)})
    
    local PageContainer = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 180, 0, 0), Size = UDim2.new(1, -180, 1, 0), ClipsDescendants = true
    })

    --// SETTINGS BUTTON (Bottom of Sidebar)
    local SettingsBtn = Create("TextButton", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 1, -40), Size = UDim2.new(1, -20, 0, 30),
        Text = "    Settings", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.SubText, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
    })
    local SetIcon = Create("ImageLabel", {
        Parent = SettingsBtn, BackgroundTransparency = 1, Position = UDim2.new(1, -24, 0, 5), Size = UDim2.new(0, 20, 0, 20),
        Image = Ascent.Icons.Settings, ImageColor3 = Ascent.Theme.SubText
    })

    --// TOGGLE UI LOGIC
    local function ToggleUI()
        MainFrame.Visible = not MainFrame.Visible
    end
    UserInputService.InputBegan:Connect(function(input, g)
        if not g and input.KeyCode == Ascent.Keybind then ToggleUI() end
    end)
    
    --// TAB LOGIC
    local WindowAPI = {}
    local FirstTab = true
    
    function WindowAPI:AddTab(Name)
        local TabBtn = Create("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 32),
            Text = "    " .. Name, Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        
        local Page = Create("ScrollingFrame", {
            Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false,
            CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Ascent.Theme.Accent
        })
        Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})
        
        local function Activate()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v, 0.2, {BackgroundColor3 = Ascent.Theme.Sidebar, TextColor3 = Ascent.Theme.SubText})
                end
            end
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            
            Tween(TabBtn, 0.2, {BackgroundColor3 = Ascent.Theme.Hover, TextColor3 = Ascent.Theme.Text})
            Page.Visible = true
        end
        
        TabBtn.MouseButton1Click:Connect(Activate)
        if FirstTab then Activate() FirstTab = false end
        
        return CreateContainer(Page)
    end
    
    --// BUILT-IN SETTINGS PAGE
    local SettingsPage = Create("ScrollingFrame", {
        Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false,
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2
    })
    Create("UIListLayout", {Parent = SettingsPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
    Create("UIPadding", {Parent = SettingsPage, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})
    
    local SetContainer = CreateContainer(SettingsPage)
    
    SettingsBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(TabContainer:GetChildren()) do
            if v:IsA("TextButton") then Tween(v, 0.2, {BackgroundColor3 = Ascent.Theme.Sidebar, TextColor3 = Ascent.Theme.SubText}) end
        end
        for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
        SettingsPage.Visible = true
    end)
    
    -- Populate Settings
    SetContainer:AddSection("Menu Config")
    
    SetContainer:AddKeybind({
        Text = "Menu Toggle Key",
        Default = Ascent.Keybind,
        Callback = function(k) Ascent.Keybind = k end
    })
    
    SetContainer:AddDropdown({
        Text = "Theme",
        Items = {"MacDark", "MacLight", "Midnight", "HighContrast"},
        Default = "MacDark",
        Callback = function(t)
            Ascent.Theme = Ascent.Themes[t]
            Ascent:Notify({Title = "Theme Changed", Content = "Please restart script to fully apply theme.", Duration = 3})
            -- Dynamic theme updating is complex for a single file, so we warn user
        end
    })
    
    SetContainer:AddButton({
        Text = "Save Settings",
        Callback = function()
            Ascent:SaveSettings()
            Ascent:Notify({Title = "Settings Saved", Content = "Your configuration has been saved.", Type = "Success", Duration = 2})
        end
    })
    
    SetContainer:AddButton({
        Text = "Unload UI",
        Callback = function()
            Gui:Destroy()
        end
    })
    
    return WindowAPI
end

return Ascent
