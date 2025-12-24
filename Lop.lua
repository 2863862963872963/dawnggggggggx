--[[ 
    Modern UI Library v2 - Roblox
    Author: Gemini
    
    Features:
    - Notification System (Extensible)
    - Tab Groups (Foldable folders)
    - Sections & Multi-Page Sections
    - Player Profile Integration
    - Rich Text Support
    - Window Controls (Min/Close)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    OpenedFrames = {},
    NotificationArea = nil
}

--// 1. THEME & CONFIGURATION
Library.Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Sidebar = Color3.fromRGB(25, 25, 25),
    SectionBackground = Color3.fromRGB(30, 30, 30),
    ElementBackground = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(0, 120, 215),
    Divider = Color3.fromRGB(50, 50, 50),
    Hover = Color3.fromRGB(45, 45, 45),
    Red = Color3.fromRGB(255, 60, 60),
    Green = Color3.fromRGB(60, 255, 60),
    Yellow = Color3.fromRGB(255, 200, 50)
}

--// Notification Configuration
Library.NotifyTypes = {
    Success = {Color = Library.Theme.Green, Icon = "rbxassetid://6031094620"}, -- Checkmark
    Warning = {Color = Library.Theme.Yellow, Icon = "rbxassetid://6031094636"}, -- Warning
    Error   = {Color = Library.Theme.Red, Icon = "rbxassetid://6031094646"}, -- Cross
    Info    = {Color = Library.Theme.Accent, Icon = "rbxassetid://6031097220"}, -- Info
    -- Add your custom types here easily
    -- e.g., Custom = {Color = Color3.new(1,1,1), Icon = "..."}
}

--// UTILITY FUNCTIONS
local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    -- Enable RichText by default for all text objects
    if class:find("Text") then
        instance.RichText = true
    end
    return instance
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
            Dragging = true
            DragStart = input.Position
            StartPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

--// 2. NOTIFICATION SYSTEM
function Library:InitNotificationSystem(ParentGUI)
    if Library.NotificationArea then return end
    
    Library.NotificationArea = Create("Frame", {
        Name = "NotificationArea",
        Parent = ParentGUI,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 0, 20),
        Size = UDim2.new(0, 300, 1, -20),
        ZIndex = 100
    })
    
    Create("UIListLayout", {
        Parent = Library.NotificationArea,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })
end

function Library:Notify(Config)
    Config = Config or {}
    Config.Title = Config.Title or "Notification"
    Config.Content = Config.Content or "Message"
    Config.Duration = Config.Duration or 3
    Config.Type = Config.Type or "Info" -- Key from Library.NotifyTypes

    local TypeData = Library.NotifyTypes[Config.Type] or Library.NotifyTypes.Info

    local NotifyFrame = Create("Frame", {
        Parent = Library.NotificationArea,
        BackgroundColor3 = Library.Theme.SectionBackground,
        Size = UDim2.new(1, 0, 0, 0), -- Start collapsed
        ClipsDescendants = true,
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = NotifyFrame, CornerRadius = UDim.new(0, 6)})

    local SideBar = Create("Frame", {
        Parent = NotifyFrame,
        BackgroundColor3 = TypeData.Color,
        Size = UDim2.new(0, 4, 1, 0),
        BorderSizePixel = 0
    })

    local Icon = Create("ImageLabel", {
        Parent = NotifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(0, 24, 0, 24),
        Image = TypeData.Icon,
        ImageColor3 = TypeData.Color
    })

    local Title = Create("TextLabel", {
        Parent = NotifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 5),
        Size = UDim2.new(1, -60, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = Config.Title,
        TextColor3 = Library.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Content = Create("TextLabel", {
        Parent = NotifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 25),
        Size = UDim2.new(1, -60, 0, 35),
        Font = Enum.Font.Gotham,
        Text = Config.Content,
        TextColor3 = Library.Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })

    -- Animation In
    TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 65)}):Play()

    -- Auto Destroy
    task.delay(Config.Duration, function()
        if NotifyFrame then
            TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(0.3)
            NotifyFrame:Destroy()
        end
    end)
end


--// 3. MAIN WINDOW CREATION
function Library:CreateWindow(Config)
    Config = Config or {}
    Config.Title = Config.Title or "UI Library"
    Config.Subtitle = Config.Subtitle or "v2.0"
    Config.Size = Config.Size or UDim2.fromOffset(600, 400)
    
    local ScreenGui = Create("ScreenGui", {
        Name = "ModernUI_v2",
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    Library:InitNotificationSystem(ScreenGui)
    
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = Config.Size,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    
    --// TOPBAR
    local Topbar = Create("Frame", {
        Name = "Topbar",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Sidebar,
        Size = UDim2.new(1, 0, 0, 45)
    })
    Create("UICorner", {Parent = Topbar, CornerRadius = UDim.new(0, 8)})
    -- Filler to hide bottom rounded corners of topbar
    Create("Frame", {
        Parent = Topbar, BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0,
        Position = UDim2.new(0,0,1,-5), Size = UDim2.new(1,0,0,5)
    })

    local TitleLbl = Create("TextLabel", {
        Parent = Topbar, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold, Text = string.format("%s <font color='rgb(150,150,150)' size='12'>%s</font>", Config.Title, Config.Subtitle),
        TextColor3 = Library.Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, RichText = true
    })

    -- Window Controls
    local ControlsHolder = Create("Frame", {
        Parent = Topbar, BackgroundTransparency = 1, Position = UDim2.new(1, -70, 0, 0), Size = UDim2.new(0, 70, 1, 0)
    })
    Create("UIListLayout", {
        Parent = ControlsHolder, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), VerticalAlignment = Enum.VerticalAlignment.Center
    })

    local function CreateControlBtn(Icon, Color, Callback)
        local Btn = Create("TextButton", {
            Parent = ControlsHolder, BackgroundColor3 = Color, BackgroundTransparency = 0.8, Size = UDim2.new(0, 24, 0, 24),
            Text = "", AutoButtonColor = false
        })
        Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
        Create("ImageLabel", {
            Parent = Btn, BackgroundTransparency = 1, Size = UDim2.new(1, -6, 1, -6), Position = UDim2.new(0, 3, 0, 3),
            Image = Icon, ImageColor3 = Color
        })
        Btn.MouseButton1Click:Connect(Callback)
        return Btn
    end

    CreateControlBtn("rbxassetid://6034818379", Library.Theme.Yellow, function() -- Minimize
        local IsOpen = MainFrame.Size.Y.Offset > 50
        if IsOpen then
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, Config.Size.X.Offset, 0, 45)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Config.Size}):Play()
        end
    end)

    CreateControlBtn("rbxassetid://6031094646", Library.Theme.Red, function() -- Close
        ScreenGui:Destroy()
    end)

    MakeDraggable(Topbar, MainFrame)

    --// SIDEBAR & CONTENT
    local SidebarArea = Create("Frame", {
        Name = "SidebarArea", Parent = MainFrame, BackgroundColor3 = Library.Theme.Sidebar,
        Position = UDim2.new(0, 0, 0, 46), Size = UDim2.new(0, 150, 1, -46), BorderSizePixel = 0
    })

    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer", Parent = SidebarArea, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10), Size = UDim2.new(1, 0, 1, -60), -- Leave room for profile
        ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    local TabListLayout = Create("UIListLayout", {
        Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)
    })
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Player Profile
    local ProfileFrame = Create("Frame", {
        Name = "Profile", Parent = SidebarArea, BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.new(0, 0, 1, -50), Size = UDim2.new(1, 0, 0, 50), BorderSizePixel = 0
    })
    
    local ProfileImg = Create("ImageLabel", {
        Parent = ProfileFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0.5, -15), Size = UDim2.new(0, 30, 0, 30),
        Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    })
    Create("UICorner", {Parent = ProfileImg, CornerRadius = UDim.new(1, 0)})

    local ProfileName = Create("TextLabel", {
        Parent = ProfileFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 0), Size = UDim2.new(0, 60, 1, 0),
        Font = Enum.Font.GothamBold, Text = LocalPlayer.Name, TextColor3 = Library.Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
    })

    -- UI Settings & Custom Button
    local function AddProfileBtn(Icon, Callback)
        local Btn = Create("TextButton", {
            Parent = ProfileFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20),
            Text = "", AutoButtonColor = false
        })
        Create("ImageLabel", {
            Parent = Btn, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            Image = Icon, ImageColor3 = Library.Theme.SubText
        })
        Btn.MouseButton1Click:Connect(Callback)
        return Btn
    end

    local SettingsBtn = AddProfileBtn("rbxassetid://6031280882", function() Library:Notify({Title = "Settings", Content = "UI Settings clicked"}) end)
    SettingsBtn.Position = UDim2.new(1, -25, 0.5, -10)
    
    local CustomBtn = AddProfileBtn("rbxassetid://6034818375", function() Library:Notify({Title = "Custom", Content = "Custom action"}) end) -- Clipboard icon
    CustomBtn.Position = UDim2.new(1, -50, 0.5, -10)

    --// PAGES AREA
    local PageContainer = Create("Frame", {
        Name = "Pages", Parent = MainFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 160, 0, 55), Size = UDim2.new(1, -170, 1, -65), ClipsDescendants = true
    })

    --// LOGIC
    local Window = {}
    local FirstTab = true

    function Window:Minimize()
        -- Trigger minimize logic programmatically
    end

    -- Helper to create elements inside a container
    local function CreateElement(Parent, Config, Type)
        local ElementObj = {}
        
        if Type == "Button" then
            local BtnFrame = Create("TextButton", {
                Name = "Button", Parent = Parent, BackgroundColor3 = Library.Theme.ElementBackground, Size = UDim2.new(1, 0, 0, 36),
                AutoButtonColor = false, Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13
            })
            Create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 4)})
            
            BtnFrame.MouseButton1Click:Connect(function()
                Config.Callback()
                -- Ripple Effect could go here
            end)
            return BtnFrame

        elseif Type == "Toggle" then
            local Toggled = Config.Default or false
            local ToggleFrame = Create("Frame", {
                Name = "Toggle", Parent = Parent, BackgroundColor3 = Library.Theme.ElementBackground, Size = UDim2.new(1, 0, 0, 36)
            })
            Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 4)})
            Create("TextLabel", {
                Parent = ToggleFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SwitchBg = Create("Frame", {
                Parent = ToggleFrame, BackgroundColor3 = Toggled and Library.Theme.Accent or Color3.fromRGB(60,60,60),
                Position = UDim2.new(1, -50, 0.5, -10), Size = UDim2.new(0, 40, 0, 20)
            })
            Create("UICorner", {Parent = SwitchBg, CornerRadius = UDim.new(1, 0)})
            local SwitchDot = Create("Frame", {
                Parent = SwitchBg, BackgroundColor3 = Color3.new(1,1,1),
                Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = SwitchDot, CornerRadius = UDim.new(1, 0)})
            
            local Trigger = Create("TextButton", {Parent = ToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = ""})
            Trigger.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Toggled and Library.Theme.Accent or Color3.fromRGB(60,60,60)}):Play()
                TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                Config.Callback(Toggled)
            end)

        elseif Type == "Slider" then
            local Value = Config.Default or Config.Min
            local SliderFrame = Create("Frame", {
                Parent = Parent, BackgroundColor3 = Library.Theme.ElementBackground, Size = UDim2.new(1, 0, 0, 50)
            })
            Create("UICorner", {Parent = SliderFrame, CornerRadius = UDim.new(0, 4)})
            Create("TextLabel", {
                Parent = SliderFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -60, 0, 20),
                Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
            local ValLbl = Create("TextLabel", {
                Parent = SliderFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -60, 0, 5), Size = UDim2.new(0, 50, 0, 20),
                Font = Enum.Font.Gotham, Text = tostring(Value), TextColor3 = Library.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right
            })
            local Bar = Create("Frame", {
                Parent = SliderFrame, BackgroundColor3 = Color3.fromRGB(50,50,50), Position = UDim2.new(0, 10, 0, 35), Size = UDim2.new(1, -20, 0, 4)
            })
            local Fill = Create("Frame", {
                Parent = Bar, BackgroundColor3 = Library.Theme.Accent, Size = UDim2.new((Value - Config.Min)/(Config.Max - Config.Min), 0, 1, 0)
            })
            
            local Trigger = Create("TextButton", {Parent = Bar, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = ""})
            local Dragging = false
            
            local function UpdateSlide(input)
                local SizeX = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local NewVal = math.floor(Config.Min + ((Config.Max - Config.Min) * SizeX))
                Fill.Size = UDim2.new(SizeX, 0, 1, 0)
                ValLbl.Text = tostring(NewVal)
                Config.Callback(NewVal)
            end
            
            Trigger.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true UpdateSlide(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlide(i) end end)
        end
    end

    --// TABS & GROUPS LOGIC
    function Window:AddTabGroup(Name)
        local Group = {}
        
        local GroupFrame = Create("Frame", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y
        })
        
        local GroupBtn = Create("TextButton", {
            Parent = GroupFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBold, Text = "  " .. Name .. " ↓", TextColor3 = Library.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local GroupContent = Create("Frame", {
            Parent = GroupFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Visible = true
        })
        Create("UIListLayout", {Parent = GroupContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
        
        local Expanded = true
        GroupBtn.MouseButton1Click:Connect(function()
            Expanded = not Expanded
            GroupContent.Visible = Expanded
            GroupBtn.Text = Expanded and "  " .. Name .. " ↓" or "  " .. Name .. " →"
        end)
        
        function Group:AddTab(TabName)
            return Window:CreateTabInternal(TabName, GroupContent, true)
        end
        
        return Group
    end

    function Window:AddTab(Name)
        return Window:CreateTabInternal(Name, TabContainer, false)
    end

    function Window:CreateTabInternal(Name, ParentContainer, IsGrouped)
        local Tab = {}
        
        local TabBtn = Create("TextButton", {
            Name = Name, Parent = ParentContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBold, Text = (IsGrouped and "    " or "  ") .. Name,
            TextColor3 = Library.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        })
        
        local Indicator = Create("Frame", {
            Parent = TabBtn, BackgroundColor3 = Library.Theme.Accent, Position = UDim2.new(0, 0, 0, 5), Size = UDim2.new(0, 3, 1, -10), Visible = false
        })
        
        local Page = Create("ScrollingFrame", {
            Name = Name.."Page", Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false
        })
        local PageLayout = Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local function Activate()
            for _, v in pairs(TabContainer:GetDescendants()) do
                if v:IsA("TextButton") and v:FindFirstChild("Frame") then -- Reset others
                    TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = Library.Theme.SubText}):Play()
                    v.Frame.Visible = false
                end
            end
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Text}):Play()
            Indicator.Visible = true
            Page.Visible = true
        end
        
        TabBtn.MouseButton1Click:Connect(Activate)
        
        if FirstTab then Activate() FirstTab = false end

        --// SECTIONS
        function Tab:AddSection(SectionName)
            local Section = {}
            
            local SectionFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Library.Theme.SectionBackground, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true
            })
            Create("UICorner", {Parent = SectionFrame, CornerRadius = UDim.new(0, 6)})
            
            local Header = Create("Frame", {
                Parent = SectionFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)
            })
            
            local Title = Create("TextLabel", {
                Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.GothamBold, Text = SectionName, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Arrow = Create("ImageLabel", {
                Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(1, -25, 0.5, -8), Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://6034818372", ImageColor3 = Library.Theme.SubText
            })
            
            local ContentContainer = Create("Frame", {
                Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 35), Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UIListLayout", {Parent = ContentContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
            Create("UIPadding", {Parent = ContentContainer, PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
            
            -- Fold Logic
            local Open = true
            local ToggleBtn = Create("TextButton", {Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = ""})
            ToggleBtn.MouseButton1Click:Connect(function()
                Open = not Open
                ContentContainer.Visible = Open
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Open and 0 or 180}):Play()
            end)
            
            -- Wrapper for Adding Elements
            function Section:AddButton(C) CreateElement(ContentContainer, C, "Button") end
            function Section:AddToggle(C) CreateElement(ContentContainer, C, "Toggle") end
            function Section:AddSlider(C) CreateElement(ContentContainer, C, "Slider") end
            
            return Section
        end

        --// MULTI-PAGE SECTION (Variant)
        function Tab:AddMultiSection(SectionName)
            local MultiSec = {}
            local Pages = {}
            local CurrentPageIndex = 1
            
            local SectionFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Library.Theme.SectionBackground, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true
            })
            Create("UICorner", {Parent = SectionFrame, CornerRadius = UDim.new(0, 6)})
            
            local Header = Create("Frame", {Parent = SectionFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)})
            
            local Title = Create("TextLabel", {
                Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, 150, 1, 0),
                Font = Enum.Font.GothamBold, Text = SectionName, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Navigation = Create("Frame", {
                Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(1, -90, 0, 5), Size = UDim2.new(0, 80, 0, 25)
            })
            
            local LeftBtn = Create("TextButton", {
                Parent = Navigation, BackgroundColor3 = Library.Theme.ElementBackground, Size = UDim2.new(0, 25, 1, 0),
                Text = "<", TextColor3 = Library.Theme.Text, AutoButtonColor = false
            })
            Create("UICorner", {Parent = LeftBtn, CornerRadius = UDim.new(0, 4)})
            
            local RightBtn = Create("TextButton", {
                Parent = Navigation, BackgroundColor3 = Library.Theme.ElementBackground, Position = UDim2.new(1, -25, 0, 0), Size = UDim2.new(0, 25, 1, 0),
                Text = ">", TextColor3 = Library.Theme.Text, AutoButtonColor = false
            })
            Create("UICorner", {Parent = RightBtn, CornerRadius = UDim.new(0, 4)})
            
            local CountLbl = Create("TextLabel", {
                Parent = Navigation, BackgroundTransparency = 1, Position = UDim2.new(0, 25, 0, 0), Size = UDim2.new(1, -50, 1, 0),
                Text = "1/1", TextColor3 = Library.Theme.SubText, TextSize = 12, Font = Enum.Font.GothamBold
            })

            local ContentHolder = Create("Frame", {
                Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 35), Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UIPadding", {Parent = ContentHolder, PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
            
            local function UpdatePage()
                for i, pageFrame in ipairs(Pages) do
                    pageFrame.Visible = (i == CurrentPageIndex)
                end
                CountLbl.Text = CurrentPageIndex .. "/" .. #Pages
            end
            
            LeftBtn.MouseButton1Click:Connect(function()
                if CurrentPageIndex > 1 then CurrentPageIndex = CurrentPageIndex - 1 UpdatePage() end
            end)
            
            RightBtn.MouseButton1Click:Connect(function()
                if CurrentPageIndex < #Pages then CurrentPageIndex = CurrentPageIndex + 1 UpdatePage() end
            end)
            
            function MultiSec:AddPage()
                local PageFrame = Create("Frame", {
                    Parent = ContentHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, Visible = (#Pages == 0) -- Visible if first
                })
                Create("UIListLayout", {Parent = PageFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
                
                table.insert(Pages, PageFrame)
                UpdatePage()
                
                local PageObj = {}
                function PageObj:AddButton(C) CreateElement(PageFrame, C, "Button") end
                function PageObj:AddToggle(C) CreateElement(PageFrame, C, "Toggle") end
                function PageObj:AddSlider(C) CreateElement(PageFrame, C, "Slider") end
                return PageObj
            end
            
            return MultiSec
        end
        
        return Tab
    end
    
    return Window
end

--[[ Example Usage:
local Library = require(script)

local Window = Library:CreateWindow({Title = "Gemini", Subtitle = "Solutions", Size = UDim2.fromOffset(600, 450)})

-- Grouping Tabs
local MainGroup = Window:AddTabGroup("Main")
local FarmTab = MainGroup:AddTab("Farming")
local CombatTab = MainGroup:AddTab("Combat")

-- Normal Tab
local SettingsTab = Window:AddTab("Settings")

-- Notifications
FarmTab:AddSection("Notify Test"):AddButton({Text = "Send Info", Callback = function()
    Library:Notify({Title = "Hello", Content = "This is a notification", Type = "Info"})
end})

-- Selection / Sections
local WeaponSection = CombatTab:AddSection("Weapon Settings") -- Foldable
WeaponSection:AddToggle({Text = "Kill Aura", Default = true, Callback = function(v) print(v) end})

-- Multi-Page Selection
local SkinSelector = CombatTab:AddMultiSection("Skin Selection")
local Page1 = SkinSelector:AddPage()
Page1:AddButton({Text = "Blue Skin", Callback = function() end})
local Page2 = SkinSelector:AddPage()
Page2:AddButton({Text = "Red Skin", Callback = function() end})

]]

return Library
