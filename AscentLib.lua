--[[
    Ascent UI Library v3.0 (Ultimate Edition)
    - MacOS Inspired Design
    - Optimized Performance
    - Mobile Support
    - Drag & Drop Elements
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
    Version = "3.0.0",
    IsMobile = UserInputService.TouchEnabled,
    Icons = {
        Search = "rbxassetid://6031154871",
        Arrow = "rbxassetid://6034818372",
        Check = "rbxassetid://6031094620",
        Close = "rbxassetid://3944676354",
        Drag = "rbxassetid://3944700940" -- Hamburger menu icon used for drag handle
    },
    CurrentWindow = nil,
    Flags = {},
    Theme = nil
}

--// THEMES
Ascent.Themes = {
    MacDark = {
        Main = Color3.fromRGB(32, 32, 37),
        Sidebar = Color3.fromRGB(40, 40, 45),
        Element = Color3.fromRGB(50, 50, 56),
        Text = Color3.fromRGB(250, 250, 250),
        SubText = Color3.fromRGB(160, 160, 170),
        Divider = Color3.fromRGB(65, 65, 70),
        Accent = Color3.fromRGB(0, 122, 255),
        Hover = Color3.fromRGB(60, 60, 66),
        Success = Color3.fromRGB(48, 209, 88),
        Warning = Color3.fromRGB(255, 214, 10),
        Error = Color3.fromRGB(255, 69, 58),
        Transparency = 0.02
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
        Success = Color3.fromRGB(52, 199, 89),
        Warning = Color3.fromRGB(255, 204, 0),
        Error = Color3.fromRGB(255, 59, 48),
        Transparency = 0.02
    }
}
Ascent.Theme = Ascent.Themes.MacDark

--// UTILITY FUNCTIONS
local function Create(class, props)
    local inst = Instance.new(class)
    if props.Parent then inst.Parent = props.Parent end -- Handle parent last typically, but here mostly fine
    if class:find("Text") then inst.RichText = true end
    for k, v in pairs(props) do 
        if k ~= "Parent" then inst[k] = v end 
    end
    return inst
end

local function AddShadow(Parent, Transparency)
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = Parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -20, 0, -20),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = 0,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = Transparency or 0.5,
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
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            local Tween = TweenService:Create(Object, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
            })
            Tween:Play()
        end
    end)
end

--// NOTIFICATION SYSTEM
function Ascent:Notify(Config)
    Config = Config or {}
    -- Config: {Title, Content, Duration, Type (Info/Success/Warning/Error)}
    if not Ascent.NotificationArea then return end
    
    local TypeColors = {
        Success = Ascent.Theme.Success,
        Warning = Ascent.Theme.Warning,
        Error = Ascent.Theme.Error,
        Info = Ascent.Theme.Accent
    }
    local Color = TypeColors[Config.Type] or Ascent.Theme.Accent
    
    local Card = Create("Frame", {
        Parent = Ascent.NotificationArea,
        BackgroundColor3 = Ascent.Theme.Main,
        Size = UDim2.new(1, 0, 0, 0), -- Animated height
        BackgroundTransparency = 0.1,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = Card, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = Card, Color = Ascent.Theme.Divider, Thickness = 1})
    
    -- Strip
    Create("Frame", {Parent = Card, BackgroundColor3 = Color, Size = UDim2.new(0, 4, 1, 0), Position = UDim2.new(0,0,0,0)})
    
    local Title = Create("TextLabel", {
        Parent = Card, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 10), Size = UDim2.new(1, -20, 0, 20),
        Text = Config.Title or "Notification", Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local Content = Create("TextLabel", {
        Parent = Card, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 30), Size = UDim2.new(1, -20, 0, 0),
        Text = Config.Content or "", Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y
    })
    
    -- Animation
    TweenService:Create(Card, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 80)}):Play()
    
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
            Parent = Parent,
            BackgroundColor3 = Ascent.Theme.Element,
            BackgroundTransparency = Ascent.Theme.Transparency,
            Size = UDim2.new(1, 0, 0, Height),
            BorderSizePixel = 0
        })
        Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 6)})
        return F
    end

    --// SECTION
    function Funcs:AddSection(Title)
        local SectionFrame = Create("Frame", {
            Parent = Parent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25), AutomaticSize = Enum.AutomaticSize.Y
        })
        local Text = Create("TextLabel", {
            Parent = SectionFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25),
            Text = Title:upper(), Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.SubText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
        })
        Create("UIPadding", {Parent = Text, PaddingLeft = UDim.new(0, 5)})
        
        local Container = Create("Frame", {
            Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        
        local Handler = CreateContainer(Container)
        return Handler
    end

    --// BUTTON
    function Funcs:AddButton(Config)
        local Frame = ElementBase(35)
        local Btn = Create("TextButton", {
            Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            Text = Config.Text or "Button", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13
        })
        
        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Ascent.Theme.Accent}):Play()
            task.delay(0.1, function() TweenService:Create(Frame, TweenInfo.new(0.3), {BackgroundColor3 = Ascent.Theme.Element}):Play() end)
            if Config.Callback then Config.Callback() end
        end)
        
        local API = {}
        function API:SetText(t) Btn.Text = t end
        return API
    end
    
    --// PARAGRAPH
    function Funcs:AddParagraph(Config)
        local Frame = ElementBase(0) -- Auto height
        Frame.AutomaticSize = Enum.AutomaticSize.Y
        
        local Title = Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5),
            Text = Config.Title or "Title", Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Desc = Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 25),
            Text = Config.Content or "Content...", Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y
        })
        
        Create("UIPadding", {Parent = Frame, PaddingBottom = UDim.new(0, 10)})
    end

    --// TOGGLE
    function Funcs:AddToggle(Config)
        local State = Config.Default or false
        local Frame = ElementBase(35)
        
        local Label = Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -60, 1, 0),
            Text = Config.Text or "Toggle", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local SwitchBg = Create("Frame", {
            Parent = Frame, BackgroundColor3 = State and Ascent.Theme.Accent or Ascent.Theme.Divider,
            Position = UDim2.new(1, -45, 0.5, -10), Size = UDim2.new(0, 34, 0, 20)
        })
        Create("UICorner", {Parent = SwitchBg, CornerRadius = UDim.new(1, 0)})
        
        local Knob = Create("Frame", {
            Parent = SwitchBg, BackgroundColor3 = Color3.new(1,1,1),
            Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)
        })
        Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
        
        local Button = Create("TextButton", {
            Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""
        })
        
        local function Update()
            if Config.Flag then Ascent.Flags[Config.Flag] = State end
            local TargetPos = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local TargetColor = State and Ascent.Theme.Accent or Ascent.Theme.Divider
            TweenService:Create(Knob, TweenInfo.new(0.2), {Position = TargetPos}):Play()
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor}):Play()
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
        local Def = Config.Default or Min
        local Value = Def
        
        local Frame = ElementBase(45)
        
        local Label = Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -50, 0, 20),
            Text = Config.Text or "Slider", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Input = Create("TextBox", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -50, 0, 5), Size = UDim2.new(0, 40, 0, 20),
            Text = tostring(Value), Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right
        })
        
        local Bar = Create("Frame", {
            Parent = Frame, BackgroundColor3 = Ascent.Theme.Divider, Position = UDim2.new(0, 10, 0, 32), Size = UDim2.new(1, -20, 0, 4)
        })
        Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
        
        local Fill = Create("Frame", {
            Parent = Bar, BackgroundColor3 = Ascent.Theme.Accent, Size = UDim2.new((Value - Min)/(Max - Min), 0, 1, 0)
        })
        Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
        
        local Interact = Create("TextButton", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 20), Text = ""
        })
        
        local function Update(InputVal)
            local Clamped = math.clamp(InputVal, Min, Max)
            local Percent = (Clamped - Min) / (Max - Min)
            Value = Clamped
            
            TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(Percent, 0, 1, 0)}):Play()
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
    
    --// ADVANCED DROPDOWN
    function Funcs:AddDropdown(Config)
        local Selected = Config.Multi and {} or (Config.Default or nil)
        local Items = Config.Items or {}
        local IsOpen = false
        
        local Frame = ElementBase(35)
        Frame.ClipsDescendants = true
        Frame.ZIndex = 2 -- Ensure it sits above subsequent elements when expanded
        
        local HeaderBtn = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35), Text = "", AutoButtonColor = false})
        
        local Label = Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -40, 0, 35),
            Text = Config.Text, Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Arrow = Create("ImageLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0, 10), Size = UDim2.new(0, 15, 0, 15),
            Image = Ascent.Icons.Arrow, ImageColor3 = Ascent.Theme.SubText
        })
        
        -- Search Bar
        local SearchBar = Create("TextBox", {
            Parent = Frame, BackgroundColor3 = Ascent.Theme.Sidebar, Position = UDim2.new(0, 10, 0, 35), Size = UDim2.new(1, -20, 0, 25),
            PlaceholderText = "Search...", Text = "", Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.Text, TextSize = 12
        })
        Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 4)})
        
        local Scroll = Create("ScrollingFrame", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 65), Size = UDim2.new(1, 0, 1, -65),
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = Ascent.Theme.Accent
        })
        local ListLayout = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
        Create("UIPadding", {Parent = Scroll, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
        
        local ItemButtons = {}
        
        local function UpdateText()
            if Config.Multi then
                Label.Text = Config.Text .. " (" .. #Selected .. ")"
            else
                Label.Text = Config.Text .. ": " .. (Selected or "None")
            end
        end
        
        local function RenderItems(Filter)
            -- Hide/Show logic for performance
            local H = 0
            for _, btn in ipairs(ItemButtons) do
                if not Filter or btn.Name:lower():find(Filter:lower()) then
                    btn.Visible = true
                    H = H + 30
                else
                    btn.Visible = false
                end
            end
        end
        
        local function CreateItems()
            -- Clear old
            for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            ItemButtons = {}
            
            for _, item in ipairs(Items) do
                local Btn = Create("TextButton", {
                    Name = item,
                    Parent = Scroll, BackgroundColor3 = Ascent.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 28),
                    Text = "  " .. item, Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                
                table.insert(ItemButtons, Btn)
                
                Btn.MouseButton1Click:Connect(function()
                    if Config.Multi then
                        if table.find(Selected, item) then
                            table.remove(Selected, table.find(Selected, item))
                            Btn.TextColor3 = Ascent.Theme.SubText
                            Btn.BackgroundColor3 = Ascent.Theme.Sidebar
                        else
                            table.insert(Selected, item)
                            Btn.TextColor3 = Color3.new(1,1,1)
                            Btn.BackgroundColor3 = Ascent.Theme.Accent
                        end
                    else
                        -- Single select
                        for _, b in ipairs(ItemButtons) do 
                            b.TextColor3 = Ascent.Theme.SubText
                            b.BackgroundColor3 = Ascent.Theme.Sidebar
                        end
                        Selected = item
                        Btn.TextColor3 = Color3.new(1,1,1)
                        Btn.BackgroundColor3 = Ascent.Theme.Accent
                        
                        -- Close
                        IsOpen = false
                        TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    end
                    UpdateText()
                    if Config.Callback then Config.Callback(Selected) end
                end)
            end
        end
        
        CreateItems()
        UpdateText()
        
        SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
            RenderItems(SearchBar.Text)
        end)
        
        HeaderBtn.MouseButton1Click:Connect(function()
            IsOpen = not IsOpen
            local TargetHeight = IsOpen and 180 or 35
            TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, TargetHeight)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 180 or 0}):Play()
        end)
        
        local API = {}
        function API:Refresh(NewItems) Items = NewItems; CreateItems() end
        return API
    end
    
    --// DRAG AND DROP LIST (Sortable)
    function Funcs:AddSortableList(Config)
        local Items = Config.Items or {} -- {"Option A", "Option B"}
        local Frame = ElementBase(0)
        Frame.AutomaticSize = Enum.AutomaticSize.Y
        
        Create("TextLabel", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 0, 30),
            Text = Config.Text or "Reorder List", Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Container = Create("Frame", {
            Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UIPadding", {Parent = Frame, PaddingBottom = UDim.new(0, 10)})
        local ListLayout = Create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
        
        local function Refresh()
            -- Simple swap logic (Up/Down arrows) for stability across all executors
            -- Real drag/drop is complex and buggy in simple UI libs
            for _, v in pairs(Container:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
            
            for i, item in ipairs(Items) do
                local Row = Create("Frame", {
                    Parent = Container, BackgroundColor3 = Ascent.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 25), LayoutOrder = i
                })
                Create("UICorner", {Parent = Row, CornerRadius = UDim.new(0, 4)})
                
                Create("TextLabel", {
                    Parent = Row, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -60, 1, 0),
                    Text = item, Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Up = Create("TextButton", {
                    Parent = Row, BackgroundTransparency = 1, Position = UDim2.new(1, -50, 0, 0), Size = UDim2.new(0, 25, 1, 0),
                    Text = "▲", TextColor3 = Ascent.Theme.Text
                })
                local Down = Create("TextButton", {
                    Parent = Row, BackgroundTransparency = 1, Position = UDim2.new(1, -25, 0, 0), Size = UDim2.new(0, 25, 1, 0),
                    Text = "▼", TextColor3 = Ascent.Theme.Text
                })
                
                Up.MouseButton1Click:Connect(function()
                    if i > 1 then
                        Items[i], Items[i-1] = Items[i-1], Items[i]
                        Refresh()
                        if Config.Callback then Config.Callback(Items) end
                    end
                end)
                
                Down.MouseButton1Click:Connect(function()
                    if i < #Items then
                        Items[i], Items[i+1] = Items[i+1], Items[i]
                        Refresh()
                        if Config.Callback then Config.Callback(Items) end
                    end
                end)
            end
        end
        Refresh()
    end
    
    return Funcs
end

--// MAIN
function Ascent:CreateWindow(Config)
    if Ascent.CurrentWindow then Ascent.CurrentWindow:Destroy() end
    
    local Config = Config or {}
    local Title = Config.Title or "Ascent Library"
    local Size = Config.Size or UDim2.fromOffset(650, 400)
    local Keybind = Config.Keybind or Enum.KeyCode.RightControl
    
    local Gui = Create("ScreenGui", {Name = "AscentApp", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    Ascent.CurrentWindow = Gui
    
    Ascent.NotificationArea = Create("Frame", {
        Parent = Gui, BackgroundTransparency = 1, Position = UDim2.new(1, -320, 0, 20), Size = UDim2.new(0, 300, 1, -40), ZIndex = 100
    })
    Create("UIListLayout", {Parent = Ascent.NotificationArea, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom})

    --// MAIN FRAME
    local MainFrame = Create("Frame", {
        Name = "Main", Parent = Gui, BackgroundColor3 = Ascent.Theme.Main,
        Size = Size, Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = Ascent.Theme.Transparency
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 10)})
    AddShadow(MainFrame, 0.6)
    
    if Config.Intro then
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Size}):Play()
    end
    
    MakeDraggable(MainFrame, MainFrame)
    
    --// SIDEBAR
    local Sidebar = Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = Ascent.Theme.Sidebar,
        Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = Ascent.Theme.Transparency
    })
    Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 10)})
    -- Flatten Right Side
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Ascent.Theme.Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0})
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Ascent.Theme.Divider, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BorderSizePixel = 0})
    
    -- Traffic Lights
    local Controls = Create("Frame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40)})
    local CloseBtn = Create("TextButton", {Parent = Controls, BackgroundColor3 = Ascent.Theme.Error, Position = UDim2.new(0, 15, 0, 12), Size = UDim2.new(0, 12, 0, 12), AutoButtonColor = false, Text = ""})
    Create("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(1, 0)})
    
    local MinBtn = Create("TextButton", {Parent = Controls, BackgroundColor3 = Ascent.Theme.Warning, Position = UDim2.new(0, 35, 0, 12), Size = UDim2.new(0, 12, 0, 12), AutoButtonColor = false, Text = ""})
    Create("UICorner", {Parent = MinBtn, CornerRadius = UDim.new(1, 0)})
    
    local MaxBtn = Create("TextButton", {Parent = Controls, BackgroundColor3 = Ascent.Theme.Success, Position = UDim2.new(0, 55, 0, 12), Size = UDim2.new(0, 12, 0, 12), AutoButtonColor = false, Text = ""})
    Create("UICorner", {Parent = MaxBtn, CornerRadius = UDim.new(1, 0)})
    
    local TitleLabel = Create("TextLabel", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 45), Size = UDim2.new(1, -15, 0, 20),
        Text = Title, Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 75), Size = UDim2.new(1, 0, 1, -85),
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0
    })
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    
    local PageContainer = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 180, 0, 0), Size = UDim2.new(1, -180, 1, 0), ClipsDescendants = true
    })
    
    --// MOBILE MENU
    local MobileBtn = Create("TextButton", {
        Parent = Gui, BackgroundColor3 = Ascent.Theme.Main, Position = UDim2.new(0, 20, 0, 20), Size = UDim2.new(0, 40, 0, 40),
        Visible = false, Text = "Menu", Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Text, AutoButtonColor = false
    })
    Create("UICorner", {Parent = MobileBtn, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = MobileBtn, Color = Ascent.Theme.Accent, Thickness = 2})
    
    local function ToggleUI()
        MainFrame.Visible = not MainFrame.Visible
        if Ascent.IsMobile then
            MobileBtn.Visible = not MainFrame.Visible
        end
    end
    
    CloseBtn.MouseButton1Click:Connect(ToggleUI)
    MobileBtn.MouseButton1Click:Connect(ToggleUI)
    
    UserInputService.InputBegan:Connect(function(input, g)
        if not g and input.KeyCode == Keybind then
            ToggleUI()
        end
    end)
    
    --// TAB HANDLING
    local WindowAPI = {}
    local FirstTab = true
    
    function WindowAPI:AddTab(Name)
        local TabBtn = Create("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 32), Position = UDim2.new(0, 10, 0, 0),
            Text = "      " .. Name, Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        
        -- Selection Indicator
        local Indicator = Create("Frame", {
            Parent = TabBtn, BackgroundColor3 = Ascent.Theme.Accent, Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(0, 0, 0.2, 0), Visible = false
        })
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
        
        local Page = Create("ScrollingFrame", {
            Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false,
            CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = Ascent.Theme.Accent
        })
        Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})
        
        local function Activate()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.2), {BackgroundColor3 = Ascent.Theme.Sidebar, TextColor3 = Ascent.Theme.SubText}):Play()
                    v.Frame.Visible = false
                end
            end
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Ascent.Theme.Hover, TextColor3 = Ascent.Theme.Text}):Play()
            Indicator.Visible = true
            Page.Visible = true
        end
        
        TabBtn.MouseButton1Click:Connect(Activate)
        
        if FirstTab then Activate() FirstTab = false end
        
        return CreateContainer(Page)
    end
    
    return WindowAPI
end

return Ascent
