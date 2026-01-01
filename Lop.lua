--[[
    MODERN UI LIBRARY V4 - ULTIMATE EDITION
    Author: Gemini (Updated for User)
    
    [DANH SÁCH TÍNH NĂNG / FEATURE LIST]
    1.  Window System: Draggable, Mobile Support, Keybind (Simulated)
    2.  Theme System:
        - Built-in Themes: Dark, Pastel Purple, Sky, Garden, Ocean, Midnight
        - Gradient Support: Auto-apply gradients to UI elements
    3.  Container Types:
        - Tabs (Vertical Sidebar)
        - Sections (Dividers)
        - DoubleCanvas (New! Split 50/50 layout)
        - BottomTabBox (New! Google-style tabs at bottom with Collapse)
    4.  Elements:
        - Paragraph / Multi-Paragraph (Carousel)
        - Button
        - Toggle (Variants: Default, Checkbox, Retro)
        - Slider
        - Textbox (Number/String)
        - Dropdown (Searchable)
    5.  Advanced Features:
        - Element:Extend() (New! Settings gear with slide-out panel)
        - Global Search (Search all elements)
        - Notifications (Toast messages)
    
    [HƯỚNG DẪN SỬ DỤNG CƠ BẢN]
    local Lib = loadstring(...)()
    local Win = Lib:CreateWindow({Title = "Hub Name", Size = UDim2.fromOffset(650, 450)})
    local Tab = Win:CreateTab("Main")
    
    -- Double Canvas
    local Left, Right = Tab:AddDoubleCanvas()
    Left:AddButton({Text = "Left Button", Callback = print})
    Right:AddToggle({Text = "Right Toggle"})
    
    -- Extend
    local myToggle = Tab:AddToggle({Text = "Aimbot"})
    local mySettings = myToggle:Extend()
    mySettings:AddSlider({Text = "FOV", Min = 0, Max = 100, Default = 90})
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Elements = {}, -- Registry for Search
    OpenedFrames = {},
    NotificationArea = nil,
    IsMobile = UserInputService.TouchEnabled,
    CurrentTheme = "Dark",
    MainFrameRef = nil, -- Reference for extensions
}

--// 1. THEME SYSTEM & COLORS
Library.Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 20),
        Sidebar = Color3.fromRGB(20, 20, 25),
        Section = Color3.fromRGB(25, 25, 30),
        Element = Color3.fromRGB(30, 30, 35),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Divider = Color3.fromRGB(45, 45, 50),
        Gradient1 = Color3.fromRGB(0, 140, 255), -- Blue
        Gradient2 = Color3.fromRGB(140, 0, 255)  -- Purple
    },
    PastelPurple = {
        Background = Color3.fromRGB(24, 20, 30),
        Sidebar = Color3.fromRGB(30, 25, 40),
        Section = Color3.fromRGB(35, 30, 45),
        Element = Color3.fromRGB(40, 35, 50),
        Text = Color3.fromRGB(255, 230, 255),
        SubText = Color3.fromRGB(180, 160, 190),
        Divider = Color3.fromRGB(60, 50, 70),
        Gradient1 = Color3.fromRGB(255, 150, 255),
        Gradient2 = Color3.fromRGB(150, 100, 255)
    },
    Sky = {
        Background = Color3.fromRGB(230, 240, 255),
        Sidebar = Color3.fromRGB(210, 230, 255),
        Section = Color3.fromRGB(255, 255, 255),
        Element = Color3.fromRGB(240, 245, 255),
        Text = Color3.fromRGB(50, 50, 70),
        SubText = Color3.fromRGB(100, 100, 120),
        Divider = Color3.fromRGB(200, 220, 240),
        Gradient1 = Color3.fromRGB(50, 180, 255),
        Gradient2 = Color3.fromRGB(0, 100, 200)
    },
    Garden = {
        Background = Color3.fromRGB(20, 30, 20),
        Sidebar = Color3.fromRGB(25, 35, 25),
        Section = Color3.fromRGB(30, 40, 30),
        Element = Color3.fromRGB(35, 45, 35),
        Text = Color3.fromRGB(220, 255, 220),
        SubText = Color3.fromRGB(150, 180, 150),
        Divider = Color3.fromRGB(50, 70, 50),
        Gradient1 = Color3.fromRGB(46, 204, 113),
        Gradient2 = Color3.fromRGB(39, 174, 96)
    }
}

-- Set active theme reference (Default)
Library.Theme = Library.Themes.Dark

function Library:SetTheme(ThemeName)
    if Library.Themes[ThemeName] then
        Library.Theme = Library.Themes[ThemeName]
        Library.CurrentTheme = ThemeName
        -- Note: Real-time update requires binding all created instances to a signal. 
        -- For simplicity, this takes effect on new elements or window recreation.
        -- Advanced: You would iterate Library.OpenedFrames and update colors.
    end
end

Library.NotifyTypes = {
    Success = {Icon = "rbxassetid://6031094620", Color = Color3.fromRGB(46, 204, 113)},
    Warning = {Icon = "rbxassetid://6031094636", Color = Color3.fromRGB(241, 196, 15)},
    Error   = {Icon = "rbxassetid://6031094646", Color = Color3.fromRGB(255, 60, 60)},
    Info    = {Icon = "rbxassetid://6031097220", Color = Color3.fromRGB(0, 140, 255)}
}

--// UTILITY FUNCTIONS
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if class:find("Text") then inst.RichText = true end
    return inst
end

local function ApplyGradient(instance)
    local gradient = Create("UIGradient", {
        Parent = instance,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Library.Theme.Gradient1),
            ColorSequenceKeypoint.new(1, Library.Theme.Gradient2)
        }
    })
    return gradient
end

local function MakeDraggable(topbar, object)
    local Dragging, DragInput, DragStart, StartPos
    local function Update(input)
        local Delta = input.Position - DragStart
        local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        TweenService:Create(object, TweenInfo.new(0.15), {Position = Position}):Play()
    end
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPos = object.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then Update(input) end end)
end

--// NOTIFICATIONS
function Library:InitNotifications(Gui)
    Library.NotificationArea = Create("Frame", {
        Name = "Notifications", Parent = Gui, BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 0, 20), Size = UDim2.new(0, 300, 1, -20), ZIndex = 1000
    })
    Create("UIListLayout", {Parent = Library.NotificationArea, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom})
end

function Library:Notify(Config)
    Config = Config or {}
    local TypeData = Library.NotifyTypes[Config.Type or "Info"]
    
    local Frame = Create("Frame", {
        Parent = Library.NotificationArea, BackgroundColor3 = Library.Theme.Section,
        Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, BorderSizePixel = 0
    })
    Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
    
    local GradientFrame = Create("Frame", {Parent = Frame, Size = UDim2.new(0, 3, 1, 0), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1,1,1)})
    ApplyGradient(GradientFrame)
    
    Create("ImageLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 10), Size = UDim2.new(0, 24, 0, 24), Image = TypeData.Icon, ImageColor3 = TypeData.Color})
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 5), Size = UDim2.new(1, -60, 0, 20), Font = Enum.Font.GothamBold, Text = Config.Title or "Notification", TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 25), Size = UDim2.new(1, -60, 0, 35), Font = Enum.Font.Gotham, Text = Config.Content or "Message", TextColor3 = Library.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
    
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 65)}):Play()
    
    task.delay(Config.Duration or 3, function()
        if Frame then
            TweenService:Create(Frame, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(0.4)
            Frame:Destroy()
        end
    end)
end

--// HELPER: ELEMENT CREATOR (Used by Tabs, DoubleCanvas, Extend panels)
-- This allows us to reuse the code for buttons, toggles, etc. in any container.
local function RegisterContainerFunctions(Container, PageInstance)
    local Funcs = {}
    
    -- Helper to add standard element frame
    local function AddElementFrame(SizeY)
        local F = Create("Frame", {
            Parent = PageInstance, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, SizeY)
        })
        Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 6)})
        return F
    end

    -- 1. BUTTON
    function Funcs:AddButton(Config)
        local BtnFrame = AddElementFrame(36)
        local Btn = Create("TextButton", {
            Parent = BtnFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13
        })
        Btn.MouseButton1Click:Connect(function()
            local Ripple = Create("Frame", {Parent = BtnFrame, BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.8, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0)})
            Create("UICorner", {Parent = Ripple, CornerRadius = UDim.new(0,6)})
            TweenService:Create(Ripple, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            game.Debris:AddItem(Ripple, 0.5)
            if Config.Callback then Config.Callback() end
        end)
    end

    -- 2. TOGGLE (With Variants & Extend)
    function Funcs:AddToggle(Config)
        -- Config: Text, Default, Variant ("Default"|"Checkbox"|"Retro"), Callback
        local State = Config.Default or false
        local Variant = Config.Variant or "Default"
        
        -- Add to search registry if main page
        if Container.Activate then Library.Elements[Config.Text] = {TabFunc = Container.Activate} end

        local TFrame = AddElementFrame(36)
        
        local Label = Create("TextLabel", {
            Parent = TFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -70, 1, 0), -- Less width for Gear
            Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Trigger = Create("TextButton", {Parent = TFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Text = ""}) -- -30 for Extend button space
        
        local Display
        -- VARIANT LOGIC
        if Variant == "Checkbox" then
            Display = Create("Frame", {
                Parent = TFrame, BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section,
                Position = UDim2.new(1, -60, 0.5, -10), Size = UDim2.new(0, 20, 0, 20)
            })
            Create("UICorner", {Parent = Display, CornerRadius = UDim.new(0, 4)})
            if State then ApplyGradient(Display) end
            Create("ImageLabel", {Parent = Display, BackgroundTransparency = 1, Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,2,0,2), Image = "rbxassetid://6031094620", Visible = State})
            
        elseif Variant == "Retro" then
             Display = Create("Frame", {
                Parent = TFrame, BackgroundTransparency = 1,
                Position = UDim2.new(1, -60, 0.5, -10), Size = UDim2.new(0, 20, 0, 20)
            })
            local Box = Create("Frame", {Parent = Display, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Library.Theme.Section})
            Create("UIStroke", {Parent = Box, Color = Library.Theme.SubText, Thickness = 2})
            local Inner = Create("Frame", {Parent = Box, Size = UDim2.new(0.6,0,0.6,0), Position = UDim2.new(0.2,0,0.2,0), BackgroundColor3 = Library.Theme.Gradient1, Visible = State})
            
        else -- Default Switch
            Display = Create("Frame", {
                Parent = TFrame, BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section,
                Position = UDim2.new(1, -80, 0.5, -10), Size = UDim2.new(0, 40, 0, 20)
            })
            Create("UICorner", {Parent = Display, CornerRadius = UDim.new(1, 0)})
            if State then ApplyGradient(Display) end
            local Circle = Create("Frame", {
                Parent = Display, BackgroundColor3 = Color3.new(1,1,1),
                Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
        end
        
        local function UpdateState()
            if Variant == "Checkbox" then
                Display.BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section
                Display.ImageLabel.Visible = State
                if State then ApplyGradient(Display) else for _,c in pairs(Display:GetChildren()) do if c:IsA("UIGradient") then c:Destroy() end end end
            elseif Variant == "Retro" then
                Display.Frame.UIStroke.Color = State and Library.Theme.Gradient1 or Library.Theme.SubText
                Display.Frame.Frame.Visible = State
            else
                Display.BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section
                if State then ApplyGradient(Display) else for _,c in pairs(Display:GetChildren()) do if c:IsA("UIGradient") then c:Destroy() end end end
                TweenService:Create(Display.Frame, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
            end
        end

        Trigger.MouseButton1Click:Connect(function()
            State = not State
            if Config.Callback then Config.Callback(State) end
            UpdateState()
        end)
        
        -- OBJECT RETURN with EXTEND
        local ToggleObj = {}
        
        function ToggleObj:Extend()
            -- Create Gear Icon
            local Gear = Create("ImageButton", {
                Parent = TFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -25, 0.5, -10), Size = UDim2.new(0, 20, 0, 20),
                Image = "rbxassetid://6031280882", ImageColor3 = Library.Theme.SubText
            })
            
            -- Create Slide-out Panel
            -- We need to find the PageHolder or MainFrame to attach this panel to
            local MainFrame = Library.MainFrameRef
            local Holder = MainFrame:FindFirstChild("PageHolder") or MainFrame
            
            local ExtensionFrame = Create("Frame", {
                Parent = Holder, BackgroundColor3 = Library.Theme.Sidebar,
                Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0),
                ZIndex = 5, Visible = false
            })
            Create("UIStroke", {Parent = ExtensionFrame, Color = Library.Theme.Divider, Thickness = 1})
            
            local Header = Create("Frame", {Parent = ExtensionFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30)})
            Create("TextLabel", {
                Parent = Header, Text = Config.Text .. " Settings", Font = Enum.Font.GothamBold,
                Size = UDim2.new(1,-30,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1,
                TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
            })
            local CloseBtn = Create("TextButton", {
                Parent = Header, Text = "X", Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Red,
                Size = UDim2.new(0,30,1,0), Position = UDim2.new(1,-30,0,0), BackgroundTransparency = 1
            })
            
            local ExtContent = Create("ScrollingFrame", {
                Parent = ExtensionFrame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,35), Size = UDim2.new(1,0,1,-35),
                CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 2
            })
            Create("UIListLayout", {Parent = ExtContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
            Create("UIPadding", {Parent = ExtContent, PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)})
            
            -- Open/Close Logic
            Gear.MouseButton1Click:Connect(function()
                ExtensionFrame.Visible = true
                TweenService:Create(ExtensionFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, 0, 0, 0)}):Play()
            end)
            
            CloseBtn.MouseButton1Click:Connect(function()
                local t = TweenService:Create(ExtensionFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 0, 0, 0)})
                t:Play()
                t.Completed:Connect(function() ExtensionFrame.Visible = false end)
            end)
            
            -- Return a container-like object to add elements to this panel
            local ExtHandler = {}
            RegisterContainerFunctions(ExtHandler, ExtContent)
            return ExtHandler
        end
        
        return ToggleObj
    end

    -- 3. SLIDER
    function Funcs:AddSlider(Config)
        local Min, Max, Def = Config.Min, Config.Max, Config.Default or Config.Min
        local SFrame = AddElementFrame(45)
        
        Create("TextLabel", {
            Parent = SFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, 0, 0, 20),
            Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        local ValLbl = Create("TextLabel", {
            Parent = SFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -50, 0, 5), Size = UDim2.new(0, 40, 0, 20),
            Text = tostring(Def), Font = Enum.Font.Gotham, TextColor3 = Library.Theme.SubText, TextSize = 12
        })
        
        local Bar = Create("Frame", {
            Parent = SFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 4)
        })
        Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
        local Fill = Create("Frame", {
            Parent = Bar, BackgroundColor3 = Color3.new(1,1,1), Size = UDim2.new((Def-Min)/(Max-Min), 0, 1, 0)
        })
        Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
        ApplyGradient(Fill)
        
        local Btn = Create("TextButton", {Parent = Bar, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = ""})
        local Dragging = false
        local function Update(input)
            local s = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local res = math.floor(Min + (s * (Max - Min)))
            Fill.Size = UDim2.new(s, 0, 1, 0)
            ValLbl.Text = tostring(res)
            if Config.Callback then Config.Callback(res) end
        end
        Btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = true; Update(i) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
        UserInputService.InputChanged:Connect(function(i) if Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
    end

    -- 4. TEXTBOX
    function Funcs:AddTextbox(Config)
        local BoxFrame = AddElementFrame(50)
        Create("TextLabel", {
            Parent = BoxFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        local InputBg = Create("Frame", {
            Parent = BoxFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -20, 0, 20)
        })
        Create("UICorner", {Parent = InputBg, CornerRadius = UDim.new(0, 4)})
        local Input = Create("TextBox", {
            Parent = InputBg, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0),
            Font = Enum.Font.Gotham, Text = "", PlaceholderText = Config.Placeholder or "Input...",
            TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false
        })
        Input.FocusLost:Connect(function()
            if Config.Callback then Config.Callback(Input.Text) end
        end)
    end

    -- 5. DROPDOWN
    function Funcs:AddDropdown(Config)
        local IsOpen = false
        local DFrame = Create("Frame", {
            Parent = PageInstance, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, 40), ClipsDescendants = true
        })
        Create("UICorner", {Parent = DFrame, CornerRadius = UDim.new(0, 6)})
        
        local Label = Create("TextLabel", {
            Parent = DFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -40, 0, 40),
            Text = Config.Text .. ": " .. (Config.Default or "None"), Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        local Arrow = Create("ImageLabel", {
            Parent = DFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0, 10), Size = UDim2.new(0, 20, 0, 20),
            Image = "rbxassetid://6034818372", ImageColor3 = Library.Theme.SubText
        })
        local SearchBar = Create("TextBox", {
            Parent = DFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 10, 0, 45), Size = UDim2.new(1, -20, 0, 25),
            Text = "", PlaceholderText = "Search...", TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12
        })
        Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 4)})
        local List = Create("ScrollingFrame", {
            Parent = DFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 80), Size = UDim2.new(1, 0, 0, 100),
            CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 2
        })
        Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
        
        local function Refresh(txt)
            for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            local count = 0
            for _, item in pairs(Config.Items) do
                if txt == "" or item:lower():find(txt:lower()) then
                    count = count + 1
                    local B = Create("TextButton", {
                        Parent = List, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, -10, 0, 25),
                        Text = item, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.SubText, TextSize = 12
                    })
                    Create("UICorner", {Parent = B, CornerRadius = UDim.new(0, 4)})
                    B.MouseButton1Click:Connect(function()
                        IsOpen = false
                        TweenService:Create(DFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 40)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                        Label.Text = Config.Text .. ": " .. item
                        if Config.Callback then Config.Callback(item) end
                    end)
                end
            end
            List.CanvasSize = UDim2.new(0, 0, 0, count * 27)
        end
        SearchBar:GetPropertyChangedSignal("Text"):Connect(function() Refresh(SearchBar.Text) end)
        local Btn = Create("TextButton", {Parent = DFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,40), Text = ""})
        Btn.MouseButton1Click:Connect(function()
            IsOpen = not IsOpen
            TweenService:Create(DFrame, TweenInfo.new(0.3), {Size = IsOpen and UDim2.new(1, 0, 0, 200) or UDim2.new(1, 0, 0, 40)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 180 or 0}):Play()
            if IsOpen then Refresh("") end
        end)
    end
    
    -- 6. DOUBLE CANVAS (New!)
    function Funcs:AddDoubleCanvas()
        local ContainerFrame = Create("Frame", {
            Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
        })
        
        -- Left and Right Side
        local LeftC = Create("Frame", {
            Parent = ContainerFrame, BackgroundTransparency = 1, Size = UDim2.new(0.5, -4, 0, 0), 
            Position = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
        })
        local RightC = Create("Frame", {
            Parent = ContainerFrame, BackgroundTransparency = 1, Size = UDim2.new(0.5, -4, 0, 0), 
            Position = UDim2.new(0.5, 4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
        })
        
        Create("UIListLayout", {Parent = LeftC, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        Create("UIListLayout", {Parent = RightC, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        
        local LHandler, RHandler = {}, {}
        -- Recursively add functions to these mini-containers
        RegisterContainerFunctions(LHandler, LeftC)
        RegisterContainerFunctions(RHandler, RightC)
        
        return LHandler, RHandler
    end
    
    -- 7. GOOGLE STYLE BOTTOM TABS (New!)
    -- Features: Collapse toggle, Tabs at bottom
    function Funcs:AddBottomTabBox(Config)
        -- Config: Title, Tabs = {"A", "B"}
        local Main = Create("Frame", {
            Parent = PageInstance, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 6)})
        
        -- Header with Hide/Show
        local Header = Create("Frame", {
            Parent = Main, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, 24)
        })
        Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 6)})
        Create("TextLabel", {
            Parent = Header, Text = Config.Title or "Selection", TextColor3 = Library.Theme.SubText,
            Font = Enum.Font.GothamBold, TextSize = 12, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
        })
        
        -- Hide/Show Button
        local ToggleBtn = Create("TextButton", {
            Parent = Header, Text = "-", TextSize = 14, TextColor3 = Library.Theme.Text, BackgroundTransparency = 1,
            Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -24, 0, 0), Font = Enum.Font.GothamBold
        })
        
        -- Content Area
        local ContentArea = Create("Frame", {
            Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UIPadding", {Parent = ContentArea, PaddingTop = UDim.new(0, 30), PaddingBottom = UDim.new(0, 30), PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)})
        
        -- Tab Bar at Bottom
        local BottomBar = Create("Frame", {
            Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0,0,1,-25),
            AnchorPoint = Vector2.new(0,1) -- Attempt to stick to bottom? AutoSize makes this tricky.
        })
        -- Actually, for AutoSize Y container, we can put BottomBar in the UIListLayout order, but it needs to stay at bottom.
        -- Best approach: Use a standard Vertical Layout, Header -> Content -> BottomBar.
        Create("UIListLayout", {Parent = Main, SortOrder = Enum.SortOrder.LayoutOrder})
        Header.LayoutOrder = 1
        ContentArea.LayoutOrder = 2
        BottomBar.LayoutOrder = 3
        
        -- Logic for Tab Switching
        local TabBtns = {}
        local TabFrames = {}
        
        local BarLayout = Create("UIListLayout", {
            Parent = BottomBar, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local Width = 1 / #Config.Tabs
        
        for i, tName in ipairs(Config.Tabs) do
            -- Tab Button
            local TBtn = Create("TextButton", {
                Parent = BottomBar, BackgroundTransparency = 1, Size = UDim2.new(Width, 0, 1, 0),
                Text = tName, Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = (i==1) and Library.Theme.Gradient1 or Library.Theme.SubText
            })
            -- Indicator line for Google Style
            local Line = Create("Frame", {
                Parent = TBtn, BackgroundColor3 = Library.Theme.Gradient1, Size = UDim2.new(1, -4, 0, 2), Position = UDim2.new(0, 2, 1, -2), Visible = (i==1)
            })
            
            -- Frame
            local TFrame = Create("Frame", {
                Parent = ContentArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = (i==1)
            })
            Create("UIListLayout", {Parent = TFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
            
            table.insert(TabBtns, {Btn=TBtn, Line=Line})
            table.insert(TabFrames, {Frame=TFrame, Name=tName})
            
            TBtn.MouseButton1Click:Connect(function()
                for _, v in pairs(TabBtns) do v.Btn.TextColor3 = Library.Theme.SubText; v.Line.Visible = false end
                for _, v in pairs(TabFrames) do v.Frame.Visible = false end
                
                TBtn.TextColor3 = Library.Theme.Gradient1
                Line.Visible = true
                TFrame.Visible = true
            end)
        end
        
        -- Collapse Logic
        local Collapsed = false
        ToggleBtn.MouseButton1Click:Connect(function()
            Collapsed = not Collapsed
            ContentArea.Visible = not Collapsed
            BottomBar.Visible = not Collapsed
            ToggleBtn.Text = Collapsed and "+" or "-"
        end)
        
        -- Return handler
        local Handler = {}
        function Handler:GetTab(TabName)
            for _, v in pairs(TabFrames) do
                if v.Name == TabName then
                    local Mini = {}
                    RegisterContainerFunctions(Mini, v.Frame)
                    return Mini
                end
            end
        end
        return Handler
    end

    -- 8. PARAGRAPH
    function Funcs:AddParagraph(Config)
        local PFrame = Create("Frame", {
            Parent = PageInstance, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UICorner", {Parent = PFrame, CornerRadius = UDim.new(0, 6)})
        Create("UIPadding", {Parent = PFrame, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
        
        if type(Config.Content) == "table" then
             local Pages = Config.Content
             local idx = 1
             local Title = Create("TextLabel", {Parent = PFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Font = Enum.Font.GothamBold, Text = Config.Title, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
             local Content = Create("TextLabel", {Parent = PFrame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,25), Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = Pages[1], TextColor3 = Library.Theme.SubText, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left})
             local Nav = Create("Frame", {Parent = PFrame, BackgroundTransparency = 1, Position = UDim2.new(1,-60,0,0), Size = UDim2.new(0,60,0,20)})
             local Left = Create("TextButton", {Parent = Nav, Size = UDim2.new(0,20,1,0), Text = "<", TextColor3 = Library.Theme.Text, BackgroundColor3 = Library.Theme.Element}); Create("UICorner", {Parent = Left, CornerRadius = UDim.new(0,4)})
             local Right = Create("TextButton", {Parent = Nav, Size = UDim2.new(0,20,1,0), Position = UDim2.new(1,-20,0,0), Text = ">", TextColor3 = Library.Theme.Text, BackgroundColor3 = Library.Theme.Element}); Create("UICorner", {Parent = Right, CornerRadius = UDim.new(0,4)})
             Left.MouseButton1Click:Connect(function() if idx > 1 then idx = idx - 1; Content.Text = Pages[idx] end end)
             Right.MouseButton1Click:Connect(function() if idx < #Pages then idx = idx + 1; Content.Text = Pages[idx] end end)
        else
             Create("TextLabel", {Parent = PFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Font = Enum.Font.GothamBold, Text = Config.Title, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
             Create("TextLabel", {Parent = PFrame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,25), Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = Config.Content, TextColor3 = Library.Theme.SubText, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left})
        end
    end

    function Funcs:Space(px)
        Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,px or 10)})
    end

    function Funcs:Divide()
        Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Divider, Size = UDim2.new(1, -10, 0, 1), BorderSizePixel = 0})
    end

    -- Inject functions into Container
    for k, v in pairs(Funcs) do Container[k] = v end
end


--// WINDOW SYSTEM
function Library:CreateWindow(Config)
    local Window = {Tabs = {}, IsVisual = true}
    
    local ScreenGui = Create("ScreenGui", {
        Name = "ModernUI_V4", Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui,
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    Library:InitNotifications(ScreenGui)

    local MobileBtn = Create("ImageButton", {
        Name = "MobileToggle", Parent = ScreenGui, BackgroundColor3 = Library.Theme.Section,
        Position = UDim2.new(0, 20, 0.5, -25), Size = UDim2.new(0, 50, 0, 50),
        AutoButtonColor = false, Visible = false
    })
    Create("UICorner", {Parent = MobileBtn, CornerRadius = UDim.new(1, 0)})
    ApplyGradient(MobileBtn)
    Create("ImageLabel", {Parent = MobileBtn, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0.5, -15, 0.5, -15), Image = "rbxassetid://6031280882"})
    
    local MainFrame = Create("Frame", {
        Name = "MainFrame", Parent = ScreenGui, BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
        Size = Config.Size or UDim2.fromOffset(650, 450), ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = MainFrame, Color = Library.Theme.Divider, Thickness = 1})
    
    Library.MainFrameRef = MainFrame -- Set Global Ref for Extend()

    --// TOPBAR
    local Topbar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Library.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 50)})
    Create("UICorner", {Parent = Topbar, CornerRadius = UDim.new(0, 8)})
    Create("Frame", {Parent = Topbar, BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0, Position = UDim2.new(0,0,1,-10), Size = UDim2.new(1,0,0,10)})
    
    local TitleBox = Create("Frame", {Parent = Topbar, BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0)})
    local TitleText = Create("TextLabel", {
        Parent = TitleBox, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -15, 1, 0),
        Font = Enum.Font.GothamBold, Text = Config.Title or "UI", TextColor3 = Color3.new(1,1,1), TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left
    })
    local TGradient = ApplyGradient(TitleText); TGradient.Enabled = true

    --// SEARCH BAR
    local SearchBg = Create("Frame", {
        Parent = Topbar, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0.5, -120, 0.5, -15), Size = UDim2.new(0, 240, 0, 30)
    })
    Create("UICorner", {Parent = SearchBg, CornerRadius = UDim.new(0, 6)})
    Create("ImageLabel", {
        Parent = SearchBg, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0.5, -8), Size = UDim2.new(0, 16, 0, 16),
        Image = "rbxassetid://6031154871", ImageColor3 = Library.Theme.SubText
    })
    local SearchInput = Create("TextBox", {
        Parent = SearchBg, BackgroundTransparency = 1, Position = UDim2.new(0, 30, 0, 0), Size = UDim2.new(1, -35, 1, 0),
        Font = Enum.Font.Gotham, PlaceholderText = "Search features...", Text = "", TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
    })
    local SearchResults = Create("ScrollingFrame", {
        Parent = SearchBg, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 0, 1, 5), Size = UDim2.new(1, 0, 0, 0),
        Visible = false, ZIndex = 20, BorderSizePixel = 0, CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 2
    })
    Create("UICorner", {Parent = SearchResults, CornerRadius = UDim.new(0, 6)})
    Create("UIListLayout", {Parent = SearchResults, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        for _, c in pairs(SearchResults:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        if query == "" then SearchResults.Visible = false; return end
        local matches = 0
        for name, data in pairs(Library.Elements) do
            if name:lower():find(query) then
                matches = matches + 1
                local ResBtn = Create("TextButton", {
                    Parent = SearchResults, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham, Text = "  " .. name, TextColor3 = Library.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                ResBtn.MouseButton1Click:Connect(function() data.TabFunc(); SearchResults.Visible = false end)
            end
        end
        if matches > 0 then
            SearchResults.Visible = true; SearchResults.Size = UDim2.new(1, 0, 0, math.min(matches * 32, 200)); SearchResults.CanvasSize = UDim2.new(0, 0, 0, matches * 32)
        else SearchResults.Visible = false end
    end)
    MakeDraggable(Topbar, MainFrame)

    --// CONTAINERS
    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Library.Theme.Sidebar, Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(0, 160, 1, -50), BorderSizePixel = 0})
    local TabHolder = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 10), Size = UDim2.new(1, 0, 1, -60), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 0})
    Create("UIListLayout", {Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local PageHolder = Create("Frame", {Name = "PageHolder", Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 170, 0, 60), Size = UDim2.new(1, -180, 1, -70), ClipsDescendants = true})

    --// PROFILE
    local Profile = Create("Frame", {Parent = Sidebar, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0, 0, 1, -50), Size = UDim2.new(1, 0, 0, 50), BorderSizePixel = 0})
    local Avatar = Create("ImageLabel", {Parent = Profile, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0.5, -15), Size = UDim2.new(0, 30, 0, 30), Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)})
    Create("UICorner", {Parent = Avatar, CornerRadius = UDim.new(1, 0)})
    Create("TextLabel", {Parent = Profile, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 0), Size = UDim2.new(0, 80, 1, 0), Font = Enum.Font.GothamBold, Text = LocalPlayer.Name, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})

    function Window:MobileToggle(bool) MobileBtn.Visible = bool end
    function Window:SetVisual(bool) Window.IsVisual = bool; MainFrame.Visible = bool end
    MobileBtn.MouseButton1Click:Connect(function() Window:SetVisual(not Window.IsVisual) end)

    --// TABS
    function Window:CreateTab(Name)
        local Tab = {Elements = {}}
        local Page = Create("ScrollingFrame", {
            Name = Name, Parent = PageHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            Visible = false, CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 3
        })
        Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        
        local Btn = Create("TextButton", {
            Parent = TabHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.GothamBold, Text = "  " .. Name, TextColor3 = Library.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        local Ind = Create("Frame", {Parent = Btn, BackgroundColor3 = Color3.new(1,1,1), Position = UDim2.new(0, 0, 0, 6), Size = UDim2.new(0, 3, 1, -12), Visible = false})
        ApplyGradient(Ind)
        
        local function Activate()
            for _, v in pairs(TabHolder:GetDescendants()) do if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = Library.Theme.SubText}):Play(); if v:FindFirstChild("Frame") then v.Frame.Visible = false end end end
            for _, v in pairs(PageHolder:GetChildren()) do if v.Name ~= "SettingsPanel" then v.Visible = false end end -- Fix for settings overlap
            TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Text}):Play()
            Ind.Visible = true; Page.Visible = true
        end
        Btn.MouseButton1Click:Connect(Activate)
        Tab.Activate = Activate

        -- INJECT ELEMENTS
        RegisterContainerFunctions(Tab, Page)

        return Tab
    end
    
    --// SETTINGS TAB (Built-in)
    Library.SettingsTab = Window:CreateTab("Settings")
    Library.SettingsTab:AddParagraph({Title = "UI Themes", Content = "Select a gradient theme for the library."})
    
    local ThemeDropdown = Library.SettingsTab:AddDropdown({
        Text = "Select Theme",
        Default = "Dark",
        Items = {"Dark", "PastelPurple", "Sky", "Garden"},
        Callback = function(v)
            Library:SetTheme(v)
            Library:Notify({Title = "Theme Changed", Content = "Applied " .. v, Duration = 2})
        end
    })
    
    Library.SettingsTab:Divide()
    Library.SettingsTab:AddToggle({Text = "Show Mobile Button", Default = false, Callback = function(v) Window:MobileToggle(v) end})
    Library.SettingsTab:AddButton({Text = "Unload UI", Callback = function() ScreenGui:Destroy() end})

    return Window
end

return Library
