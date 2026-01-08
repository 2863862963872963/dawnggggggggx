local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local MarketPlaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Ascent = {
    Version = "3.0.0",
    IsMobile = UserInputService.TouchEnabled,
    Icons = {
        Search = "rbxassetid://6031154871",
        Arrow = "rbxassetid://6034818372",
        Check = "rbxassetid://6031094620",
        Close = "rbxassetid://3944676354",
        Settings = "rbxassetid://3944680069",
        Home = "rbxassetid://3944680069", -- Using generic icons for now
        User = "rbxassetid://3944673858",
        Gamepad = "rbxassetid://3944680069",
        Lock = "rbxassetid://3944676354"
    },
    CurrentWindow = nil,
    Flags = {},
    Registry = {}, -- Stores all elements for search
    ConfigFolder = "AscentConfig",
    ConfigFile = "default.json",
    Theme = nil,
    Keybind = Enum.KeyCode.RightControl,
    AnonymousMode = false,
    Open = true
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
        Locked = Color3.fromRGB(0, 0, 0),
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
        Locked = Color3.fromRGB(200, 200, 200),
        Transparency = 0.05
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

local function PlaySound(id)
    local S = Instance.new("Sound")
    S.SoundId = id
    S.Parent = SoundService
    S.PlayOnRemove = true
    S.Destroy(S)
end

--// CONFIG SYSTEM
function Ascent:SaveSettings()
    if not isfolder or not writefile then return end
    local Config = {
        Flags = Ascent.Flags,
        Theme = "MacDark",
        Keybind = tostring(Ascent.Keybind),
        Anonymous = Ascent.AnonymousMode
    }
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
            for flag, value in pairs(Decoded.Flags or {}) do Ascent.Flags[flag] = value end
            if Decoded.Keybind then
                local K = Enum.KeyCode[Decoded.Keybind:gsub("Enum.KeyCode.", "")]
                if K then Ascent.Keybind = K end
            end
            if Decoded.Theme and Ascent.Themes[Decoded.Theme] then Ascent.Theme = Ascent.Themes[Decoded.Theme] end
            if Decoded.Anonymous ~= nil then Ascent.AnonymousMode = Decoded.Anonymous end
        end
    end
end

--// NOTIFICATION SYSTEM
function Ascent:Notify(Config)
    Config = Config or {}
    if not Ascent.NotificationArea then return end
    
    PlaySound("rbxassetid://12221967") -- Generic notification sound
    
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

    local function Register(Obj, Type, Name)
        table.insert(Ascent.Registry, {
            Object = Obj,
            Type = Type,
            Name = Name,
            Parent = Obj.Parent
        })
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
        
        Register(Frame, "Button", Config.Text)
        
        -- API
        local API = {}
        function API:SetText(t) Btn.Text = t end
        function API:Lock(val) 
            Frame.Active = not val
            Btn.Active = not val
            Tween(Frame, 0.3, {BackgroundColor3 = val and Ascent.Theme.Sidebar or Ascent.Theme.Element})
            Btn.TextColor3 = val and Ascent.Theme.SubText or Ascent.Theme.Text
        end
        function API:Toggle(bool) Frame.Visible = bool end
        return API
    end

    --// TOGGLE
    function Funcs:AddToggle(Config)
        local State = Ascent.Flags[Config.Flag] or Config.Default or false
        local Container = ElementBase(0) -- Auto height
        Container.AutomaticSize = Enum.AutomaticSize.Y
        Container.ClipsDescendants = true
        
        local Frame = Create("Frame", {
            Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38)
        })

        Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -80, 1, 0),
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
        
        local SettingsBtn = Create("ImageButton", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -75, 0.5, -8), Size = UDim2.new(0, 16, 0, 16),
            Image = Ascent.Icons.Settings, ImageColor3 = Ascent.Theme.SubText, Visible = false
        })

        local Button = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Text = ""})
        
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
        
        Register(Container, "Toggle", Config.Text)

        -- Extension Logic
        local ExtContainer = Create("Frame", {
            Parent = Container, BackgroundColor3 = Ascent.Theme.Sidebar, BackgroundTransparency = 0.5,
            Size = UDim2.new(1, -10, 0, 0), Position = UDim2.new(0, 5, 0, 40),
            AutomaticSize = Enum.AutomaticSize.Y, Visible = false
        })
        Create("UICorner", {Parent = ExtContainer, CornerRadius = UDim.new(0, 6)})
        Create("UIListLayout", {Parent = ExtContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
        Create("UIPadding", {Parent = ExtContainer, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})

        local ExtOpen = false
        SettingsBtn.MouseButton1Click:Connect(function()
            ExtOpen = not ExtOpen
            ExtContainer.Visible = ExtOpen
            Tween(SettingsBtn, 0.3, {Rotation = ExtOpen and 180 or 0})
        end)
        
        local API = {}
        function API:Set(v) State = v; Update() end
        function API:Get() return State end
        function API:Toggle(bool) Container.Visible = bool end
        function API:Lock(val) Button.Active = not val; Tween(Container, 0.3, {BackgroundTransparency = val and 0.2 or Ascent.Theme.Transparency}) end
        
        -- :extend implementation
        function API:extend(BuilderFunc)
            SettingsBtn.Visible = true
            local SubFuncs = CreateContainer(ExtContainer)
            if BuilderFunc then BuilderFunc(SubFuncs) end
        end
        
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
        Register(Frame, "Slider", Config.Text)

        local API = {}
        function API:Set(v) Update(v) end
        function API:Get() return Value end
        function API:Lock(val) Interact.Active = not val; Input.Editable = not val; Tween(Frame, 0.3, {BackgroundTransparency = val and 0.5 or Ascent.Theme.Transparency}) end
        function API:Toggle(bool) Frame.Visible = bool end
        return API
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
        
        Register(Frame, "Dropdown", Config.Text)

        local API = {}
        function API:Refresh(n) Items = n; Refresh() end
        function API:Set(v) Selected = v; Label.Text = Config.Text .. ": " .. tostring(v) end
        function API:Get() return Selected end
        function API:Lock(val) Trigger.Active = not val; Tween(Frame, 0.3, {BackgroundTransparency = val and 0.5 or Ascent.Theme.Transparency}) end
        function API:Toggle(bool) Frame.Visible = bool end
        return API
    end

    --// COLOR PICKER & KEYBIND & TEXTBOX (Simplified for v3 length)
    function Funcs:AddKeybind(Config)
        local Frame = ElementBase(38)
        local Val = Config.Default or Enum.KeyCode.RightControl
        Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -100, 1, 0),
            Text = Config.Text or "Keybind", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        local Btn = Create("TextButton", {
            Parent = Frame, BackgroundColor3 = Ascent.Theme.Sidebar, Position = UDim2.new(1, -90, 0.5, -12), Size = UDim2.new(0, 80, 0, 24),
            Text = Val.Name, Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 12
        })
        Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
        Btn.MouseButton1Click:Connect(function()
            Btn.Text = "..."
            Btn.TextColor3 = Ascent.Theme.Accent
            local c; c = UserInputService.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.Keyboard then
                    Val = i.KeyCode; Btn.Text = Val.Name; Btn.TextColor3 = Ascent.Theme.SubText
                    if Config.Callback then Config.Callback(Val) end
                    if Config.Flag then Ascent.Flags[Config.Flag] = Val end
                    c:Disconnect()
                end
            end)
        end)
        Register(Frame, "Keybind", Config.Text)
        return {Toggle=function(_,b) Frame.Visible=b end}
    end

    return Funcs
end

--// MAIN
function Ascent:CreateWindow(Config)
    if Ascent.CurrentWindow then Ascent.CurrentWindow:Destroy() end
    
    local Title = Config.Title or "Ascent Library 3.0"
    local Size = Config.Size or UDim2.fromOffset(650, 420)
    Ascent.Keybind = Config.Keybind or Enum.KeyCode.RightControl
    
    Ascent:LoadSettings()
    
    local Gui = Create("ScreenGui", {Name = "AscentApp", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    Ascent.CurrentWindow = Gui
    
    Ascent.NotificationArea = Create("Frame", {
        Parent = Gui, BackgroundTransparency = 1, Position = UDim2.new(1, -320, 0, 40), Size = UDim2.new(0, 300, 1, -40), ZIndex = 100
    })
    Create("UIListLayout", {Parent = Ascent.NotificationArea, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom})

    local MainFrame = Create("Frame", {
        Name = "Main", Parent = Gui, BackgroundColor3 = Ascent.Theme.Main,
        Size = Size, Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = Ascent.Theme.Transparency, ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 12)})
    Create("UIStroke", {Parent = MainFrame, Color = Ascent.Theme.Stroke, Thickness = 1, Transparency = 0.6})
    AddShadow(MainFrame, 0.6)
    MakeDraggable(MainFrame, MainFrame)
    
    local Sidebar = Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = Ascent.Theme.Sidebar,
        Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = Ascent.Theme.Transparency
    })
    Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 12)})
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Ascent.Theme.Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0})
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Ascent.Theme.Divider, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BorderSizePixel = 0})

    -- Search Bar
    local SearchBar = Create("TextBox", {
        Parent = Sidebar, BackgroundColor3 = Ascent.Theme.Main, Position = UDim2.new(0, 10, 0, 15), Size = UDim2.new(1, -20, 0, 30),
        PlaceholderText = "Search...", Text = "", Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.Text, TextSize = 13
    })
    Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = SearchBar, Color = Ascent.Theme.Stroke, Thickness = 1, Transparency = 0.5})
    Create("ImageLabel", {
        Parent = SearchBar, BackgroundTransparency = 1, Position = UDim2.new(1, -25, 0, 7), Size = UDim2.new(0, 16, 0, 16),
        Image = Ascent.Icons.Search, ImageColor3 = Ascent.Theme.SubText
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 60), Size = UDim2.new(1, 0, 1, -60),
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0
    })
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
    Create("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 10)})
    
    local PageContainer = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 180, 0, 0), Size = UDim2.new(1, -180, 1, 0), ClipsDescendants = true
    })

    -- SEARCH LOGIC
    local SearchPage = Create("ScrollingFrame", {
        Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false,
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2
    })
    Create("UIListLayout", {Parent = SearchPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
    Create("UIPadding", {Parent = SearchPage, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})
    
    SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
        local Text = SearchBar.Text:lower()
        if Text == "" then
            SearchPage.Visible = false
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") and v.Name ~= "SearchTabDummy" then
                    -- Restore active tab
                    if v.BackgroundColor3 == Ascent.Theme.Hover then
                        -- This tab was active
                    end
                end
            end
            -- Revert frames
            for _, item in pairs(Ascent.Registry) do
                item.Object.Parent = item.Parent
                item.Object.Visible = true
            end
        else
            -- Hide all pages
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            SearchPage.Visible = true
            
            -- Filter
            for _, item in pairs(Ascent.Registry) do
                if item.Name:lower():find(Text) then
                    item.Object.Parent = SearchPage
                    item.Object.Visible = true
                else
                    item.Object.Parent = item.Parent
                end
            end
        end
    end)

    -- TABS
    local WindowAPI = {}
    local FirstTab = true
    
    local function AddTabBtn(Name, Icon)
        local TabBtn = Create("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 32),
            Text = "       " .. Name, Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        if Icon then
            Create("ImageLabel", {
                Parent = TabBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(0, 16, 0, 16),
                Image = Icon, ImageColor3 = Ascent.Theme.SubText
            })
        end
        return TabBtn
    end

    function WindowAPI:AddTab(Name)
        local TabBtn = AddTabBtn(Name, nil)
        
        local Page = Create("ScrollingFrame", {
            Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false,
            CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Ascent.Theme.Accent
        })
        Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then Tween(v, 0.2, {BackgroundColor3 = Ascent.Theme.Sidebar, TextColor3 = Ascent.Theme.SubText}) end
            end
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            
            Tween(TabBtn, 0.2, {BackgroundColor3 = Ascent.Theme.Hover, TextColor3 = Ascent.Theme.Text})
            Page.Visible = true
        end)
        
        if FirstTab then 
            Tween(TabBtn, 0.2, {BackgroundColor3 = Ascent.Theme.Hover, TextColor3 = Ascent.Theme.Text})
            Page.Visible = true 
            FirstTab = false 
        end
        
        return CreateContainer(Page)
    end
    
    --// HOME TAB
    local HomeTabBtn = AddTabBtn("Home", Ascent.Icons.Home)
    HomeTabBtn.LayoutOrder = -2
    local HomePage = Create("ScrollingFrame", {
        Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false,
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Create("UIListLayout", {Parent = HomePage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
    Create("UIPadding", {Parent = HomePage, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})
    
    local HomeContainer = CreateContainer(HomePage)
    
    -- Player Card
    local Card = Create("Frame", {
        Parent = HomePage, BackgroundColor3 = Ascent.Theme.Element, Size = UDim2.new(1, 0, 0, 80)
    })
    Create("UICorner", {Parent = Card, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = Card, Color = Ascent.Theme.Accent, Thickness = 1})
    local Avatar = Create("ImageLabel", {
        Parent = Card, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(0, 50, 0, 50),
        Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    })
    Create("UICorner", {Parent = Avatar, CornerRadius = UDim.new(1, 0)})
    local UserLbl = Create("TextLabel", {
        Parent = Card, BackgroundTransparency = 1, Position = UDim2.new(0, 80, 0, 15), Size = UDim2.new(1, -90, 0, 25),
        Text = LocalPlayer.DisplayName, Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left
    })
    local NameLbl = Create("TextLabel", {
        Parent = Card, BackgroundTransparency = 1, Position = UDim2.new(0, 80, 0, 40), Size = UDim2.new(1, -90, 0, 20),
        Text = "@" .. LocalPlayer.Name, Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    HomeContainer:AddSection("Settings")
    HomeContainer:AddToggle({
        Text = "Anonymous Mode",
        Default = Ascent.AnonymousMode,
        Callback = function(v)
            Ascent.AnonymousMode = v
            UserLbl.Text = v and "Anonymous" or LocalPlayer.DisplayName
            NameLbl.Text = v and "@Hidden" or "@" .. LocalPlayer.Name
            Avatar.ImageTransparency = v and 1 or 0
        end
    })
    HomeContainer:AddDropdown({
        Text = "Theme",
        Items = {"MacDark", "MacLight"},
        Default = "MacDark",
        Callback = function(v) 
            Ascent.Theme = Ascent.Themes[v] 
            Ascent:Notify({Title="Theme", Content="Theme set to "..v..". Restart to apply fully."})
        end
    })
    HomeContainer:AddKeybind({
        Text = "Menu Keybind",
        Default = Ascent.Keybind,
        Callback = function(k) Ascent.Keybind = k end
    })
    HomeContainer:AddButton({
        Text = "Save Config",
        Callback = function() Ascent:SaveSettings(); Ascent:Notify({Title="Config", Content="Settings saved successfully!", Type="Success"}) end
    })
    
    HomeTabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then Tween(v, 0.2, {BackgroundColor3 = Ascent.Theme.Sidebar, TextColor3 = Ascent.Theme.SubText}) end end
        for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
        Tween(HomeTabBtn, 0.2, {BackgroundColor3 = Ascent.Theme.Hover, TextColor3 = Ascent.Theme.Text})
        HomePage.Visible = true
    end)
    
    --// PROFILE TAB
    local ProfileBtn = AddTabBtn("Profile", Ascent.Icons.User)
    ProfileBtn.LayoutOrder = -1
    local ProfilePage = Create("ScrollingFrame", {
        Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false,
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Create("UIListLayout", {Parent = ProfilePage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
    Create("UIPadding", {Parent = ProfilePage, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})
    
    local ProfCont = CreateContainer(ProfilePage)
    ProfCont:AddSection("Current Game")
    local GameCard = Create("Frame", {
        Parent = ProfilePage, BackgroundColor3 = Ascent.Theme.Element, Size = UDim2.new(1, 0, 0, 100)
    })
    Create("UICorner", {Parent = GameCard, CornerRadius = UDim.new(0, 8)})
    local GameIcon = Create("ImageLabel", {
        Parent = GameCard, BackgroundColor3 = Ascent.Theme.Sidebar, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 80, 0, 80),
        Image = "rbxassetid://6031302932" -- Placeholder since we can't fetch game thumbnail easily
    })
    Create("UICorner", {Parent = GameIcon, CornerRadius = UDim.new(0, 6)})
    Create("TextLabel", {
        Parent = GameCard, BackgroundTransparency = 1, Position = UDim2.new(0, 100, 0, 10), Size = UDim2.new(1, -110, 0, 25),
        Text = MarketPlaceService:GetProductInfo(game.PlaceId).Name or "Unknown Game", Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("TextLabel", {
        Parent = GameCard, BackgroundTransparency = 1, Position = UDim2.new(0, 100, 0, 35), Size = UDim2.new(1, -110, 0, 20),
        Text = "Playing Now", Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.Success, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    ProfCont:AddSection("People in Server")
    local FriendList = Create("Frame", {
        Parent = ProfilePage, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
    })
    Create("UIListLayout", {Parent = FriendList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local Row = Create("Frame", {Parent = FriendList, BackgroundColor3 = Ascent.Theme.Element, Size = UDim2.new(1, 0, 0, 40)})
            Create("UICorner", {Parent = Row, CornerRadius = UDim.new(0, 6)})
            local PAv = Create("ImageLabel", {
                Parent = Row, BackgroundTransparency = 1, Position = UDim2.new(0, 5, 0, 5), Size = UDim2.new(0, 30, 0, 30),
                Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            })
            Create("UICorner", {Parent = PAv, CornerRadius = UDim.new(1, 0)})
            Create("TextLabel", {
                Parent = Row, BackgroundTransparency = 1, Position = UDim2.new(0, 45, 0, 0), Size = UDim2.new(1, -50, 1, 0),
                Text = plr.DisplayName .. " (@"..plr.Name..")", Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
            })
        end
    end
    
    ProfileBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then Tween(v, 0.2, {BackgroundColor3 = Ascent.Theme.Sidebar, TextColor3 = Ascent.Theme.SubText}) end end
        for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
        Tween(ProfileBtn, 0.2, {BackgroundColor3 = Ascent.Theme.Hover, TextColor3 = Ascent.Theme.Text})
        ProfilePage.Visible = true
    end)
    
    local function ToggleUI()
        Ascent.Open = not Ascent.Open
        MainFrame.Visible = Ascent.Open
    end
    UserInputService.InputBegan:Connect(function(input, g) if not g and input.KeyCode == Ascent.Keybind then ToggleUI() end end)
    
    -- Select Home by Default
    HomeTabBtn.BackgroundColor3 = Ascent.Theme.Hover
    HomeTabBtn.TextColor3 = Ascent.Theme.Text
    HomePage.Visible = true

    return WindowAPI
end

return Ascent
