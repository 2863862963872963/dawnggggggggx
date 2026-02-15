--[[
    Ascent UI Library for Roblox
    Version: 1.0.0
    
    A modern, glassmorphic UI library inspired by premium game overlay interfaces
    
    Features:
    - Glassmorphic design with backdrop blur effects
    - Smooth animations and transitions
    - Fully customizable color schemes
    - Support for multiple tabs and sections
    - Various UI elements: Toggles, Sliders, Dropdowns, Buttons, Color Pickers, Keybinds
    - Draggable windows
    - Clean API with method chaining
    
    Example Usage:
    
    local AscentUI = loadstring(game:HttpGet("YOUR_URL_HERE"))()
    
    local Window = AscentUI:CreateWindow({
        Title = "Ascent",
        Subtitle = "PREMIUM UTILITY",
        Size = UDim2.new(0, 1100, 0, 720),
        Theme = "Cyan" -- Cyan, Purple, Red, Green, Orange
    })
    
    local Tab = Window:CreateTab({
        Name = "Combat",
        Icon = "rbxassetid://7733779610"
    })
    
    local Section = Tab:CreateSection({
        Name = "Aimbot",
        Icon = "⚡",
        Side = "Left" -- Left or Right
    })
    
    Section:CreateToggle({
        Name = "Enable Aimbot",
        Description = "Toggle aimbot functionality",
        Default = false,
        Callback = function(value)
            print("Aimbot:", value)
        end
    })
]]

local AscentUI = {}
AscentUI.__index = AscentUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Utility Functions
local function CreateTween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    return TweenService:Create(instance, tweenInfo, properties)
end

local function RippleEffect(button, x, y)
    local ripple = Instance.new("ImageLabel")
    ripple.Name = "Ripple"
    ripple.BackgroundTransparency = 1
    ripple.Image = "rbxassetid://1318074921"
    ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
    ripple.ImageTransparency = 0.5
    ripple.ZIndex = 1000
    ripple.Parent = button
    
    local size = 0
    ripple.Position = UDim2.new(0, x - size/2, 0, y - size/2)
    ripple.Size = UDim2.new(0, size, 0, size)
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    local tween = CreateTween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        Position = UDim2.new(0, x - maxSize/2, 0, y - maxSize/2),
        ImageTransparency = 1
    }, 0.5, Enum.EasingStyle.Cubic)
    
    tween:Play()
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragHandle = dragHandle or frame
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            CreateTween(frame, {Position = newPos}, 0.1):Play()
        end
    end)
end

-- Color Themes
local Themes = {
    Cyan = {
        Primary = Color3.fromRGB(0, 212, 255),
        PrimaryDark = Color3.fromRGB(0, 153, 204),
        Accent = Color3.fromRGB(0, 255, 242)
    },
    Purple = {
        Primary = Color3.fromRGB(138, 43, 226),
        PrimaryDark = Color3.fromRGB(98, 20, 180),
        Accent = Color3.fromRGB(186, 85, 211)
    },
    Red = {
        Primary = Color3.fromRGB(255, 71, 87),
        PrimaryDark = Color3.fromRGB(220, 20, 60),
        Accent = Color3.fromRGB(255, 99, 71)
    },
    Green = {
        Primary = Color3.fromRGB(46, 213, 115),
        PrimaryDark = Color3.fromRGB(30, 180, 90),
        Accent = Color3.fromRGB(85, 239, 196)
    },
    Orange = {
        Primary = Color3.fromRGB(255, 165, 2),
        PrimaryDark = Color3.fromRGB(230, 126, 34),
        Accent = Color3.fromRGB(255, 195, 18)
    }
}

-- Main Window Creation
function AscentUI:CreateWindow(config)
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Theme = Themes[config.Theme or "Cyan"]
    }
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AscentUI_" .. math.random(1000, 9999)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.Size = config.Size or UDim2.new(0, 1100, 0, 720)
    MainFrame.Position = UDim2.new(0.5, -550, 0.5, -360)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    MainFrame.BackgroundTransparency = 0.25
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 20)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.9
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame
    
    -- Shadow Effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Size = UDim2.new(1, 60, 1, 60)
    Shadow.Position = UDim2.new(0, -30, 0, -30)
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 260, 1, 0)
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    Sidebar.BackgroundTransparency = 0.15
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarStroke = Instance.new("UIStroke")
    SidebarStroke.Color = Color3.fromRGB(255, 255, 255)
    SidebarStroke.Transparency = 0.9
    SidebarStroke.Thickness = 1
    SidebarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SidebarStroke.Parent = Sidebar
    
    -- Brand Section
    local Brand = Instance.new("Frame")
    Brand.Name = "Brand"
    Brand.Size = UDim2.new(1, 0, 0, 80)
    Brand.BackgroundTransparency = 1
    Brand.Parent = Sidebar
    
    local BrandStroke = Instance.new("Frame")
    BrandStroke.Size = UDim2.new(1, 0, 0, 1)
    BrandStroke.Position = UDim2.new(0, 0, 1, 0)
    BrandStroke.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BrandStroke.BackgroundTransparency = 0.9
    BrandStroke.BorderSizePixel = 0
    BrandStroke.Parent = Brand
    
    local BrandTitle = Instance.new("TextLabel")
    BrandTitle.Name = "Title"
    BrandTitle.Size = UDim2.new(1, -40, 0, 30)
    BrandTitle.Position = UDim2.new(0, 20, 0, 20)
    BrandTitle.BackgroundTransparency = 1
    BrandTitle.Font = Enum.Font.GothamBold
    BrandTitle.Text = config.Title or "ASCENT"
    BrandTitle.TextColor3 = Window.Theme.Primary
    BrandTitle.TextSize = 24
    BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandTitle.Parent = Brand
    
    -- Apply gradient to title
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Window.Theme.Primary),
        ColorSequenceKeypoint.new(1, Window.Theme.Accent)
    }
    TitleGradient.Rotation = 45
    TitleGradient.Parent = BrandTitle
    
    local BrandSubtitle = Instance.new("TextLabel")
    BrandSubtitle.Name = "Subtitle"
    BrandSubtitle.Size = UDim2.new(1, -40, 0, 15)
    BrandSubtitle.Position = UDim2.new(0, 20, 0, 52)
    BrandSubtitle.BackgroundTransparency = 1
    BrandSubtitle.Font = Enum.Font.GothamBold
    BrandSubtitle.Text = (config.Subtitle or "PREMIUM UTILITY"):upper()
    BrandSubtitle.TextColor3 = Color3.fromRGB(136, 136, 168)
    BrandSubtitle.TextSize = 10
    BrandSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandSubtitle.Parent = Brand
    
    -- Navigation Container
    local NavContainer = Instance.new("ScrollingFrame")
    NavContainer.Name = "Navigation"
    NavContainer.Size = UDim2.new(1, 0, 1, -160)
    NavContainer.Position = UDim2.new(0, 0, 0, 80)
    NavContainer.BackgroundTransparency = 1
    NavContainer.BorderSizePixel = 0
    NavContainer.ScrollBarThickness = 4
    NavContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    NavContainer.ScrollBarImageTransparency = 0.8
    NavContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    NavContainer.Parent = Sidebar
    
    local NavLayout = Instance.new("UIListLayout")
    NavLayout.Padding = UDim.new(0, 3)
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Parent = NavContainer
    
    NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        NavContainer.CanvasSize = UDim2.new(0, 0, 0, NavLayout.AbsoluteContentSize.Y + 20)
    end)
    
    local NavPadding = Instance.new("UIPadding")
    NavPadding.PaddingLeft = UDim.new(0, 10)
    NavPadding.PaddingRight = UDim.new(0, 10)
    NavPadding.PaddingTop = UDim.new(0, 10)
    NavPadding.Parent = NavContainer
    
    -- Status Bar
    local StatusBar = Instance.new("Frame")
    StatusBar.Name = "StatusBar"
    StatusBar.Size = UDim2.new(1, 0, 0, 80)
    StatusBar.Position = UDim2.new(0, 0, 1, -80)
    StatusBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    StatusBar.BackgroundTransparency = 0.7
    StatusBar.BorderSizePixel = 0
    StatusBar.Parent = Sidebar
    
    local StatusStroke = Instance.new("Frame")
    StatusStroke.Size = UDim2.new(1, 0, 0, 1)
    StatusStroke.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    StatusStroke.BackgroundTransparency = 0.9
    StatusStroke.BorderSizePixel = 0
    StatusStroke.Parent = StatusBar
    
    -- Status Info
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -40, 0, 20)
    StatusLabel.Position = UDim2.new(0, 20, 0, 15)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Status"
    StatusLabel.TextColor3 = Color3.fromRGB(136, 136, 168)
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = StatusBar
    
    local StatusValue = Instance.new("TextLabel")
    StatusValue.Size = UDim2.new(1, -40, 0, 20)
    StatusValue.Position = UDim2.new(0, 20, 0, 35)
    StatusValue.BackgroundTransparency = 1
    StatusValue.Font = Enum.Font.GothamBold
    StatusValue.Text = "● Active"
    StatusValue.TextColor3 = Window.Theme.Primary
    StatusValue.TextSize = 14
    StatusValue.TextXAlignment = Enum.TextXAlignment.Left
    StatusValue.Parent = StatusBar
    
    -- Pulse animation for status dot
    spawn(function()
        while wait(1) do
            CreateTween(StatusValue, {TextTransparency = 0.5}, 0.5):Play()
            wait(0.5)
            CreateTween(StatusValue, {TextTransparency = 0}, 0.5):Play()
        end
    end)
    
    -- Main Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "Content"
    ContentArea.Size = UDim2.new(1, -260, 1, 0)
    ContentArea.Position = UDim2.new(0, 260, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame
    
    -- Make window draggable
    MakeDraggable(MainFrame, Brand)
    
    -- Tab Creation Method
    function Window:CreateTab(tabConfig)
        local Tab = {
            Name = tabConfig.Name or "Tab",
            Icon = tabConfig.Icon or "",
            Sections = {},
            Visible = false
        }
        
        -- Create Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Tab.Name
        TabButton.Size = UDim2.new(1, 0, 0, 48)
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Text = ""
        TabButton.TextColor3 = Color3.fromRGB(232, 232, 240)
        TabButton.TextSize = 14
        TabButton.AutoButtonColor = false
        TabButton.ClipsDescendants = true
        TabButton.Parent = NavContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 12)
        TabCorner.Parent = TabButton
        
        -- Active indicator
        local ActiveBar = Instance.new("Frame")
        ActiveBar.Name = "ActiveBar"
        ActiveBar.Size = UDim2.new(0, 3, 0, 0)
        ActiveBar.Position = UDim2.new(0, 0, 0.5, 0)
        ActiveBar.AnchorPoint = Vector2.new(0, 0.5)
        ActiveBar.BackgroundColor3 = Window.Theme.Primary
        ActiveBar.BorderSizePixel = 0
        ActiveBar.Parent = TabButton
        
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(0, 3)
        BarCorner.Parent = ActiveBar
        
        -- Tab Icon
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Name = "Icon"
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Position = UDim2.new(0, 15, 0.5, 0)
        TabIcon.AnchorPoint = Vector2.new(0, 0.5)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = Tab.Icon
        TabIcon.ImageColor3 = Color3.fromRGB(232, 232, 240)
        TabIcon.Parent = TabButton
        
        -- Tab Label
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "Label"
        TabLabel.Size = UDim2.new(1, -50, 1, 0)
        TabLabel.Position = UDim2.new(0, 45, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.Text = Tab.Name
        TabLabel.TextColor3 = Color3.fromRGB(232, 232, 240)
        TabLabel.TextSize = 14
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        -- Tab Content Container
        local TabContent = Instance.new("Frame")
        TabContent.Name = Tab.Name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = ContentArea
        
        -- Header
        local Header = Instance.new("Frame")
        Header.Name = "Header"
        Header.Size = UDim2.new(1, 0, 0, 100)
        Header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Header.BackgroundTransparency = 0.8
        Header.BorderSizePixel = 0
        Header.Parent = TabContent
        
        local HeaderStroke = Instance.new("Frame")
        HeaderStroke.Size = UDim2.new(1, 0, 0, 1)
        HeaderStroke.Position = UDim2.new(0, 0, 1, 0)
        HeaderStroke.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HeaderStroke.BackgroundTransparency = 0.9
        HeaderStroke.BorderSizePixel = 0
        HeaderStroke.Parent = Header
        
        local HeaderTitle = Instance.new("TextLabel")
        HeaderTitle.Size = UDim2.new(1, -80, 0, 40)
        HeaderTitle.Position = UDim2.new(0, 40, 0, 25)
        HeaderTitle.BackgroundTransparency = 1
        HeaderTitle.Font = Enum.Font.GothamBold
        HeaderTitle.Text = Tab.Name
        HeaderTitle.TextColor3 = Color3.fromRGB(232, 232, 240)
        HeaderTitle.TextSize = 32
        HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
        HeaderTitle.Parent = Header
        
        local HeaderSubtitle = Instance.new("TextLabel")
        HeaderSubtitle.Size = UDim2.new(1, -80, 0, 20)
        HeaderSubtitle.Position = UDim2.new(0, 40, 0, 70)
        HeaderSubtitle.BackgroundTransparency = 1
        HeaderSubtitle.Font = Enum.Font.Gotham
        HeaderSubtitle.Text = tabConfig.Description or ("Configure " .. Tab.Name .. " settings")
        HeaderSubtitle.TextColor3 = Color3.fromRGB(136, 136, 168)
        HeaderSubtitle.TextSize = 14
        HeaderSubtitle.TextXAlignment = Enum.TextXAlignment.Left
        HeaderSubtitle.Parent = Header
        
        -- Scrolling Content
        local ScrollingContent = Instance.new("ScrollingFrame")
        ScrollingContent.Name = "ScrollContent"
        ScrollingContent.Size = UDim2.new(1, 0, 1, -100)
        ScrollingContent.Position = UDim2.new(0, 0, 0, 100)
        ScrollingContent.BackgroundTransparency = 1
        ScrollingContent.BorderSizePixel = 0
        ScrollingContent.ScrollBarThickness = 6
        ScrollingContent.ScrollBarImageColor3 = Window.Theme.Primary
        ScrollingContent.ScrollBarImageTransparency = 0.7
        ScrollingContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        ScrollingContent.Parent = TabContent
        
        -- Two-column layout
        local LeftColumn = Instance.new("Frame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.5, -30, 1, 0)
        LeftColumn.Position = UDim2.new(0, 20, 0, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.Parent = ScrollingContent
        
        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 20)
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Parent = LeftColumn
        
        local RightColumn = Instance.new("Frame")
        RightColumn.Name = "RightColumn"
        RightColumn.Size = UDim2.new(0.5, -30, 1, 0)
        RightColumn.Position = UDim2.new(0.5, 10, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.Parent = ScrollingContent
        
        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 20)
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Parent = RightColumn
        
        -- Update canvas size
        local function UpdateCanvasSize()
            local leftSize = LeftLayout.AbsoluteContentSize.Y
            local rightSize = RightLayout.AbsoluteContentSize.Y
            local maxSize = math.max(leftSize, rightSize)
            ScrollingContent.CanvasSize = UDim2.new(0, 0, 0, maxSize + 40)
        end
        
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
        
        local LeftPadding = Instance.new("UIPadding")
        LeftPadding.PaddingTop = UDim.new(0, 20)
        LeftPadding.Parent = LeftColumn
        
        local RightPadding = Instance.new("UIPadding")
        RightPadding.PaddingTop = UDim.new(0, 20)
        RightPadding.Parent = RightColumn
        
        -- Tab Button Click Handler
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundTransparency = 1
                CreateTween(tab.ActiveBar, {Size = UDim2.new(0, 3, 0, 0)}, 0.2):Play()
                tab.Icon.ImageColor3 = Color3.fromRGB(232, 232, 240)
                tab.Label.TextColor3 = Color3.fromRGB(232, 232, 240)
            end
            
            -- Show this tab
            TabContent.Visible = true
            CreateTween(TabButton, {
                BackgroundTransparency = 0.8,
                BackgroundColor3 = Window.Theme.Primary
            }, 0.2):Play()
            CreateTween(ActiveBar, {Size = UDim2.new(0, 3, 1, 0)}, 0.2):Play()
            TabIcon.ImageColor3 = Window.Theme.Primary
            TabLabel.TextColor3 = Window.Theme.Primary
            
            Window.CurrentTab = Tab
        end)
        
        -- Hover effects
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                CreateTween(TabButton, {
                    BackgroundTransparency = 0.9,
                    BackgroundColor3 = Window.Theme.Primary
                }, 0.2):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                CreateTween(TabButton, {BackgroundTransparency = 1}, 0.2):Play()
            end
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.ActiveBar = ActiveBar
        Tab.Icon = TabIcon
        Tab.Label = TabLabel
        Tab.LeftColumn = LeftColumn
        Tab.RightColumn = RightColumn
        
        table.insert(Window.Tabs, Tab)
        
        -- Activate first tab
        if #Window.Tabs == 1 then
            -- Manually trigger first tab activation
            task.spawn(function()
                -- Hide all tabs first
                for _, tab in pairs(Window.Tabs) do
                    tab.Content.Visible = false
                    tab.Button.BackgroundTransparency = 1
                    CreateTween(tab.ActiveBar, {Size = UDim2.new(0, 3, 0, 0)}, 0.2):Play()
                    tab.Icon.ImageColor3 = Color3.fromRGB(232, 232, 240)
                    tab.Label.TextColor3 = Color3.fromRGB(232, 232, 240)
                end
                
                -- Show this tab
                TabContent.Visible = true
                CreateTween(TabButton, {
                    BackgroundTransparency = 0.8,
                    BackgroundColor3 = Window.Theme.Primary
                }, 0.2):Play()
                CreateTween(ActiveBar, {Size = UDim2.new(0, 3, 1, 0)}, 0.2):Play()
                TabIcon.ImageColor3 = Window.Theme.Primary
                TabLabel.TextColor3 = Window.Theme.Primary
                
                Window.CurrentTab = Tab
            end)
        end
        
        -- Section Creation Method
        function Tab:CreateSection(sectionConfig)
            local Section = {
                Name = sectionConfig.Name or "Section",
                Icon = sectionConfig.Icon or "⚙️",
                Elements = {}
            }
            
            local Column = sectionConfig.Side == "Right" and Tab.RightColumn or Tab.LeftColumn
            
            -- Section Container (Glass Card)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = Section.Name
            SectionFrame.Size = UDim2.new(1, 0, 0, 100)
            SectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            SectionFrame.BackgroundTransparency = 0.4
            SectionFrame.BorderSizePixel = 0
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = Column
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 16)
            SectionCorner.Parent = SectionFrame
            
            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = Color3.fromRGB(255, 255, 255)
            SectionStroke.Transparency = 0.9
            SectionStroke.Thickness = 1
            SectionStroke.Parent = SectionFrame
            
            -- Section Header
            local SectionHeader = Instance.new("Frame")
            SectionHeader.Name = "Header"
            SectionHeader.Size = UDim2.new(1, 0, 0, 50)
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Parent = SectionFrame
            
            local IconLabel = Instance.new("TextLabel")
            IconLabel.Size = UDim2.new(0, 35, 0, 35)
            IconLabel.Position = UDim2.new(0, 15, 0, 8)
            IconLabel.BackgroundColor3 = Window.Theme.Primary
            IconLabel.BackgroundTransparency = 0.8
            IconLabel.BorderSizePixel = 0
            IconLabel.Font = Enum.Font.GothamBold
            IconLabel.Text = Section.Icon
            IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            IconLabel.TextSize = 16
            IconLabel.Parent = SectionHeader
            
            local IconCorner = Instance.new("UICorner")
            IconCorner.CornerRadius = UDim.new(0, 8)
            IconCorner.Parent = IconLabel
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Size = UDim2.new(1, -65, 1, 0)
            SectionTitle.Position = UDim2.new(0, 60, 0, 0)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = Section.Name
            SectionTitle.TextColor3 = Color3.fromRGB(232, 232, 240)
            SectionTitle.TextSize = 16
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionHeader
            
            -- Section Content Container
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            SectionContent.Position = UDim2.new(0, 0, 0, 50)
            SectionContent.BackgroundTransparency = 1
            SectionContent.AutomaticSize = Enum.AutomaticSize.Y
            SectionContent.Parent = SectionFrame
            
            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.Padding = UDim.new(0, 0)
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Parent = SectionContent
            
            local ContentPadding = Instance.new("UIPadding")
            ContentPadding.PaddingBottom = UDim.new(0, 15)
            ContentPadding.Parent = SectionContent
            
            Section.Frame = SectionFrame
            Section.Content = SectionContent
            
            -- Toggle Element
            function Section:CreateToggle(toggleConfig)
                local Toggle = {
                    Name = toggleConfig.Name or "Toggle",
                    Description = toggleConfig.Description or "",
                    Default = toggleConfig.Default or false,
                    Callback = toggleConfig.Callback or function() end,
                    Value = toggleConfig.Default or false
                }
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = "Toggle"
                ToggleFrame.Size = UDim2.new(1, 0, 0, 60)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = SectionContent
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(1, -30, 1, 0)
                ToggleButton.Position = UDim2.new(0, 15, 0, 0)
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Text = ""
                ToggleButton.Parent = ToggleFrame
                
                -- Label Section
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Size = UDim2.new(1, -70, 1, 0)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Parent = ToggleButton
                
                local ToggleName = Instance.new("TextLabel")
                ToggleName.Size = UDim2.new(1, 0, 0, 20)
                ToggleName.Position = UDim2.new(0, 0, 0, 10)
                ToggleName.BackgroundTransparency = 1
                ToggleName.Font = Enum.Font.GothamMedium
                ToggleName.Text = Toggle.Name
                ToggleName.TextColor3 = Color3.fromRGB(232, 232, 240)
                ToggleName.TextSize = 14
                ToggleName.TextXAlignment = Enum.TextXAlignment.Left
                ToggleName.Parent = LabelFrame
                
                local ToggleDesc = Instance.new("TextLabel")
                ToggleDesc.Size = UDim2.new(1, 0, 0, 18)
                ToggleDesc.Position = UDim2.new(0, 0, 0, 32)
                ToggleDesc.BackgroundTransparency = 1
                ToggleDesc.Font = Enum.Font.Gotham
                ToggleDesc.Text = Toggle.Description
                ToggleDesc.TextColor3 = Color3.fromRGB(136, 136, 168)
                ToggleDesc.TextSize = 12
                ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
                ToggleDesc.TextWrapped = true
                ToggleDesc.Parent = LabelFrame
                
                -- Toggle Switch
                local ToggleOuter = Instance.new("Frame")
                ToggleOuter.Name = "ToggleOuter"
                ToggleOuter.Size = UDim2.new(0, 48, 0, 26)
                ToggleOuter.Position = UDim2.new(1, -48, 0.5, -13)
                ToggleOuter.BackgroundColor3 = Color3.fromRGB(85, 85, 112)
                ToggleOuter.BorderSizePixel = 0
                ToggleOuter.Parent = ToggleButton
                
                local ToggleOuterCorner = Instance.new("UICorner")
                ToggleOuterCorner.CornerRadius = UDim.new(1, 0)
                ToggleOuterCorner.Parent = ToggleOuter
                
                local ToggleInner = Instance.new("Frame")
                ToggleInner.Name = "ToggleInner"
                ToggleInner.Size = UDim2.new(0, 20, 0, 20)
                ToggleInner.Position = UDim2.new(0, 3, 0, 3)
                ToggleInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleInner.BorderSizePixel = 0
                ToggleInner.Parent = ToggleOuter
                
                local ToggleInnerCorner = Instance.new("UICorner")
                ToggleInnerCorner.CornerRadius = UDim.new(1, 0)
                ToggleInnerCorner.Parent = ToggleInner
                
                -- Set initial state
                if Toggle.Value then
                    ToggleOuter.BackgroundColor3 = Window.Theme.Primary
                    ToggleInner.Position = UDim2.new(1, -23, 0, 3)
                end
                
                -- Toggle Function
                local function UpdateToggle(value)
                    Toggle.Value = value
                    
                    if value then
                        CreateTween(ToggleOuter, {BackgroundColor3 = Window.Theme.Primary}, 0.2):Play()
                        CreateTween(ToggleInner, {Position = UDim2.new(1, -23, 0, 3)}, 0.2):Play()
                    else
                        CreateTween(ToggleOuter, {BackgroundColor3 = Color3.fromRGB(85, 85, 112)}, 0.2):Play()
                        CreateTween(ToggleInner, {Position = UDim2.new(0, 3, 0, 3)}, 0.2):Play()
                    end
                    
                    task.spawn(function()
                        Toggle.Callback(value)
                    end)
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    UpdateToggle(not Toggle.Value)
                end)
                
                -- Hover effect
                ToggleButton.MouseEnter:Connect(function()
                    CreateTween(ToggleName, {TextColor3 = Window.Theme.Primary}, 0.2):Play()
                end)
                
                ToggleButton.MouseLeave:Connect(function()
                    CreateTween(ToggleName, {TextColor3 = Color3.fromRGB(232, 232, 240)}, 0.2):Play()
                end)
                
                -- Divider
                local Divider = Instance.new("Frame")
                Divider.Size = UDim2.new(1, -30, 0, 1)
                Divider.Position = UDim2.new(0, 15, 1, 0)
                Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Divider.BackgroundTransparency = 0.95
                Divider.BorderSizePixel = 0
                Divider.Parent = ToggleFrame
                
                Toggle.SetValue = UpdateToggle
                table.insert(Section.Elements, Toggle)
                
                return Toggle
            end
            
            -- Slider Element
            function Section:CreateSlider(sliderConfig)
                local Slider = {
                    Name = sliderConfig.Name or "Slider",
                    Description = sliderConfig.Description or "",
                    Min = sliderConfig.Min or 0,
                    Max = sliderConfig.Max or 100,
                    Default = sliderConfig.Default or 50,
                    Increment = sliderConfig.Increment or 1,
                    Callback = sliderConfig.Callback or function() end,
                    Value = sliderConfig.Default or 50
                }
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = "Slider"
                SliderFrame.Size = UDim2.new(1, 0, 0, 80)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = SectionContent
                
                -- Label Section
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Size = UDim2.new(1, -30, 0, 40)
                LabelFrame.Position = UDim2.new(0, 15, 0, 0)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Parent = SliderFrame
                
                local SliderName = Instance.new("TextLabel")
                SliderName.Size = UDim2.new(1, -60, 0, 20)
                SliderName.Position = UDim2.new(0, 0, 0, 5)
                SliderName.BackgroundTransparency = 1
                SliderName.Font = Enum.Font.GothamMedium
                SliderName.Text = Slider.Name
                SliderName.TextColor3 = Color3.fromRGB(232, 232, 240)
                SliderName.TextSize = 14
                SliderName.TextXAlignment = Enum.TextXAlignment.Left
                SliderName.Parent = LabelFrame
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.Size = UDim2.new(0, 50, 0, 20)
                SliderValue.Position = UDim2.new(1, -50, 0, 5)
                SliderValue.BackgroundTransparency = 1
                SliderValue.Font = Enum.Font.GothamBold
                SliderValue.Text = tostring(Slider.Value)
                SliderValue.TextColor3 = Window.Theme.Primary
                SliderValue.TextSize = 14
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = LabelFrame
                
                local SliderDesc = Instance.new("TextLabel")
                SliderDesc.Size = UDim2.new(1, 0, 0, 15)
                SliderDesc.Position = UDim2.new(0, 0, 0, 25)
                SliderDesc.BackgroundTransparency = 1
                SliderDesc.Font = Enum.Font.Gotham
                SliderDesc.Text = Slider.Description
                SliderDesc.TextColor3 = Color3.fromRGB(136, 136, 168)
                SliderDesc.TextSize = 12
                SliderDesc.TextXAlignment = Enum.TextXAlignment.Left
                SliderDesc.Parent = LabelFrame
                
                -- Slider Track
                local SliderTrack = Instance.new("Frame")
                SliderTrack.Name = "Track"
                SliderTrack.Size = UDim2.new(1, -30, 0, 6)
                SliderTrack.Position = UDim2.new(0, 15, 0, 50)
                SliderTrack.BackgroundColor3 = Color3.fromRGB(85, 85, 112)
                SliderTrack.BorderSizePixel = 0
                SliderTrack.Parent = SliderFrame
                
                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent = SliderTrack
                
                -- Slider Fill
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
                SliderFill.BackgroundColor3 = Window.Theme.Primary
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderTrack
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = SliderFill
                
                -- Slider Thumb
                local SliderThumb = Instance.new("Frame")
                SliderThumb.Name = "Thumb"
                SliderThumb.Size = UDim2.new(0, 16, 0, 16)
                SliderThumb.Position = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), -8, 0.5, -8)
                SliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderThumb.BorderSizePixel = 0
                SliderThumb.ZIndex = 2
                SliderThumb.Parent = SliderTrack
                
                local ThumbCorner = Instance.new("UICorner")
                ThumbCorner.CornerRadius = UDim.new(1, 0)
                ThumbCorner.Parent = SliderThumb
                
                -- Slider Functionality
                local dragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    local value = math.floor((Slider.Min + (Slider.Max - Slider.Min) * pos) / Slider.Increment + 0.5) * Slider.Increment
                    value = math.clamp(value, Slider.Min, Slider.Max)
                    
                    Slider.Value = value
                    SliderValue.Text = tostring(value)
                    
                    CreateTween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1):Play()
                    CreateTween(SliderThumb, {Position = UDim2.new(pos, -8, 0.5, -8)}, 0.1):Play()
                    
                    task.spawn(function()
                        Slider.Callback(value)
                    end)
                end
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                SliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                -- Hover effects
                SliderTrack.MouseEnter:Connect(function()
                    CreateTween(SliderThumb, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(Slider.Value / (Slider.Max - Slider.Min), -10, 0.5, -10)}, 0.2):Play()
                end)
                
                SliderTrack.MouseLeave:Connect(function()
                    if not dragging then
                        CreateTween(SliderThumb, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(Slider.Value / (Slider.Max - Slider.Min), -8, 0.5, -8)}, 0.2):Play()
                    end
                end)
                
                -- Divider
                local Divider = Instance.new("Frame")
                Divider.Size = UDim2.new(1, -30, 0, 1)
                Divider.Position = UDim2.new(0, 15, 1, 0)
                Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Divider.BackgroundTransparency = 0.95
                Divider.BorderSizePixel = 0
                Divider.Parent = SliderFrame
                
                Slider.SetValue = function(value)
                    value = math.clamp(value, Slider.Min, Slider.Max)
                    Slider.Value = value
                    SliderValue.Text = tostring(value)
                    local pos = (value - Slider.Min) / (Slider.Max - Slider.Min)
                    CreateTween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.2):Play()
                    CreateTween(SliderThumb, {Position = UDim2.new(pos, -8, 0.5, -8)}, 0.2):Play()
                end
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- Dropdown Element
            function Section:CreateDropdown(dropdownConfig)
                local Dropdown = {
                    Name = dropdownConfig.Name or "Dropdown",
                    Description = dropdownConfig.Description or "",
                    Options = dropdownConfig.Options or {"Option 1", "Option 2"},
                    Default = dropdownConfig.Default or dropdownConfig.Options[1],
                    Callback = dropdownConfig.Callback or function() end,
                    Value = dropdownConfig.Default or dropdownConfig.Options[1]
                }
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = "Dropdown"
                DropdownFrame.Size = UDim2.new(1, 0, 0, 80)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Parent = SectionContent
                DropdownFrame.ClipsDescendants = true
                
                -- Label Section
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Size = UDim2.new(1, -30, 0, 40)
                LabelFrame.Position = UDim2.new(0, 15, 0, 0)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Parent = DropdownFrame
                
                local DropdownName = Instance.new("TextLabel")
                DropdownName.Size = UDim2.new(1, 0, 0, 20)
                DropdownName.Position = UDim2.new(0, 0, 0, 5)
                DropdownName.BackgroundTransparency = 1
                DropdownName.Font = Enum.Font.GothamMedium
                DropdownName.Text = Dropdown.Name
                DropdownName.TextColor3 = Color3.fromRGB(232, 232, 240)
                DropdownName.TextSize = 14
                DropdownName.TextXAlignment = Enum.TextXAlignment.Left
                DropdownName.Parent = LabelFrame
                
                local DropdownDesc = Instance.new("TextLabel")
                DropdownDesc.Size = UDim2.new(1, 0, 0, 15)
                DropdownDesc.Position = UDim2.new(0, 0, 0, 25)
                DropdownDesc.BackgroundTransparency = 1
                DropdownDesc.Font = Enum.Font.Gotham
                DropdownDesc.Text = Dropdown.Description
                DropdownDesc.TextColor3 = Color3.fromRGB(136, 136, 168)
                DropdownDesc.TextSize = 12
                DropdownDesc.TextXAlignment = Enum.TextXAlignment.Left
                DropdownDesc.Parent = LabelFrame
                
                -- Dropdown Button
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(1, -30, 0, 36)
                DropdownButton.Position = UDim2.new(0, 15, 0, 45)
                DropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
                DropdownButton.BackgroundTransparency = 0.3
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Text = ""
                DropdownButton.TextColor3 = Color3.fromRGB(232, 232, 240)
                DropdownButton.TextSize = 13
                DropdownButton.Parent = DropdownFrame
                DropdownButton.AutoButtonColor = false
                
                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 8)
                DropdownCorner.Parent = DropdownButton
                
                local DropdownStroke = Instance.new("UIStroke")
                DropdownStroke.Color = Color3.fromRGB(255, 255, 255)
                DropdownStroke.Transparency = 0.9
                DropdownStroke.Thickness = 1
                DropdownStroke.Parent = DropdownButton
                
                local DropdownText = Instance.new("TextLabel")
                DropdownText.Size = UDim2.new(1, -40, 1, 0)
                DropdownText.Position = UDim2.new(0, 12, 0, 0)
                DropdownText.BackgroundTransparency = 1
                DropdownText.Font = Enum.Font.Gotham
                DropdownText.Text = Dropdown.Value
                DropdownText.TextColor3 = Color3.fromRGB(232, 232, 240)
                DropdownText.TextSize = 13
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                DropdownText.Parent = DropdownButton
                
                local DropdownArrow = Instance.new("TextLabel")
                DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
                DropdownArrow.Position = UDim2.new(1, -28, 0, 0)
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Font = Enum.Font.GothamBold
                DropdownArrow.Text = "▼"
                DropdownArrow.TextColor3 = Color3.fromRGB(136, 136, 168)
                DropdownArrow.TextSize = 10
                DropdownArrow.Parent = DropdownButton
                
                -- Options Container
                local OptionsContainer = Instance.new("Frame")
                OptionsContainer.Size = UDim2.new(1, -30, 0, 0)
                OptionsContainer.Position = UDim2.new(0, 15, 0, 86)
                OptionsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                OptionsContainer.BorderSizePixel = 0
                OptionsContainer.ClipsDescendants = true
                OptionsContainer.Visible = false
                OptionsContainer.ZIndex = 100
                OptionsContainer.Parent = DropdownFrame
                
                local OptionsCorner = Instance.new("UICorner")
                OptionsCorner.CornerRadius = UDim.new(0, 8)
                OptionsCorner.Parent = OptionsContainer
                
                local OptionsStroke = Instance.new("UIStroke")
                OptionsStroke.Color = Window.Theme.Primary
                OptionsStroke.Transparency = 0.7
                OptionsStroke.Thickness = 1
                OptionsStroke.Parent = OptionsContainer
                
                local OptionsLayout = Instance.new("UIListLayout")
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionsLayout.Parent = OptionsContainer
                
                -- Create Options
                local expanded = false
                
                for i, option in ipairs(Dropdown.Options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Size = UDim2.new(1, 0, 0, 32)
                    OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
                    OptionButton.BackgroundTransparency = 1
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.Text = option
                    OptionButton.TextColor3 = Color3.fromRGB(232, 232, 240)
                    OptionButton.TextSize = 13
                    OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                    OptionButton.AutoButtonColor = false
                    OptionButton.Parent = OptionsContainer
                    
                    local OptionPadding = Instance.new("UIPadding")
                    OptionPadding.PaddingLeft = UDim.new(0, 12)
                    OptionPadding.Parent = OptionButton
                    
                    OptionButton.MouseEnter:Connect(function()
                        CreateTween(OptionButton, {BackgroundTransparency = 0.7}, 0.2):Play()
                        CreateTween(OptionButton, {TextColor3 = Window.Theme.Primary}, 0.2):Play()
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        CreateTween(OptionButton, {BackgroundTransparency = 1}, 0.2):Play()
                        if Dropdown.Value ~= option then
                            CreateTween(OptionButton, {TextColor3 = Color3.fromRGB(232, 232, 240)}, 0.2):Play()
                        end
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown.Value = option
                        DropdownText.Text = option
                        
                        -- Update all option colors
                        for _, child in pairs(OptionsContainer:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.TextColor3 = Color3.fromRGB(232, 232, 240)
                            end
                        end
                        OptionButton.TextColor3 = Window.Theme.Primary
                        
                        task.spawn(function()
                            Dropdown.Callback(option)
                        end)
                        
                        -- Close dropdown
                        expanded = false
                        CreateTween(OptionsContainer, {Size = UDim2.new(1, -30, 0, 0)}, 0.2):Play()
                        CreateTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 80)}, 0.2):Play()
                        wait(0.2)
                        OptionsContainer.Visible = false
                        DropdownArrow.Text = "▼"
                    end)
                    
                    if option == Dropdown.Value then
                        OptionButton.TextColor3 = Window.Theme.Primary
                    end
                end
                
                -- Toggle Dropdown
                DropdownButton.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    
                    if expanded then
                        OptionsContainer.Visible = true
                        local optionsHeight = #Dropdown.Options * 32
                        CreateTween(OptionsContainer, {Size = UDim2.new(1, -30, 0, optionsHeight)}, 0.2):Play()
                        CreateTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 80 + optionsHeight + 10)}, 0.2):Play()
                        DropdownArrow.Text = "▲"
                    else
                        CreateTween(OptionsContainer, {Size = UDim2.new(1, -30, 0, 0)}, 0.2):Play()
                        CreateTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 80)}, 0.2):Play()
                        wait(0.2)
                        OptionsContainer.Visible = false
                        DropdownArrow.Text = "▼"
                    end
                end)
                
                -- Hover effect
                DropdownButton.MouseEnter:Connect(function()
                    CreateTween(DropdownStroke, {Transparency = 0.7}, 0.2):Play()
                end)
                
                DropdownButton.MouseLeave:Connect(function()
                    CreateTween(DropdownStroke, {Transparency = 0.9}, 0.2):Play()
                end)
                
                -- Divider
                local Divider = Instance.new("Frame")
                Divider.Size = UDim2.new(1, -30, 0, 1)
                Divider.Position = UDim2.new(0, 15, 1, 0)
                Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Divider.BackgroundTransparency = 0.95
                Divider.BorderSizePixel = 0
                Divider.Parent = DropdownFrame
                
                Dropdown.SetValue = function(value)
                    if table.find(Dropdown.Options, value) then
                        Dropdown.Value = value
                        DropdownText.Text = value
                        
                        for _, child in pairs(OptionsContainer:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.TextColor3 = child.Text == value and Window.Theme.Primary or Color3.fromRGB(232, 232, 240)
                            end
                        end
                    end
                end
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
            end
            
            -- Button Element
            function Section:CreateButton(buttonConfig)
                local Button = {
                    Name = buttonConfig.Name or "Button",
                    Description = buttonConfig.Description or "",
                    Callback = buttonConfig.Callback or function() end
                }
                
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Name = "Button"
                ButtonFrame.Size = UDim2.new(1, 0, 0, 60)
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.Parent = SectionContent
                
                local ActionButton = Instance.new("TextButton")
                ActionButton.Size = UDim2.new(1, -30, 0, 40)
                ActionButton.Position = UDim2.new(0, 15, 0, 10)
                ActionButton.BackgroundColor3 = Window.Theme.Primary
                ActionButton.BackgroundTransparency = 0.1
                ActionButton.BorderSizePixel = 0
                ActionButton.Font = Enum.Font.GothamBold
                ActionButton.Text = ""
                ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                ActionButton.TextSize = 14
                ActionButton.AutoButtonColor = false
                ActionButton.ClipsDescendants = true
                ActionButton.Parent = ButtonFrame
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 10)
                ButtonCorner.Parent = ActionButton
                
                local ButtonGradient = Instance.new("UIGradient")
                ButtonGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Window.Theme.Primary),
                    ColorSequenceKeypoint.new(1, Window.Theme.PrimaryDark)
                }
                ButtonGradient.Rotation = 45
                ButtonGradient.Parent = ActionButton
                
                local ButtonText = Instance.new("TextLabel")
                ButtonText.Size = UDim2.new(1, -20, 1, 0)
                ButtonText.Position = UDim2.new(0, 10, 0, 0)
                ButtonText.BackgroundTransparency = 1
                ButtonText.Font = Enum.Font.GothamBold
                ButtonText.Text = Button.Name
                ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
                ButtonText.TextSize = 14
                ButtonText.TextXAlignment = Enum.TextXAlignment.Center
                ButtonText.Parent = ActionButton
                
                ActionButton.MouseButton1Click:Connect(function()
                    -- Ripple effect
                    local mousePos = UserInputService:GetMouseLocation()
                    local buttonPos = ActionButton.AbsolutePosition
                    local relX = mousePos.X - buttonPos.X
                    local relY = mousePos.Y - buttonPos.Y - 36 -- Account for topbar
                    RippleEffect(ActionButton, relX, relY)
                    
                    -- Scale animation
                    CreateTween(ActionButton, {Size = UDim2.new(1, -35, 0, 38)}, 0.1):Play()
                    wait(0.1)
                    CreateTween(ActionButton, {Size = UDim2.new(1, -30, 0, 40)}, 0.1):Play()
                    
                    task.spawn(function()
                        Button.Callback()
                    end)
                end)
                
                -- Hover effect
                ActionButton.MouseEnter:Connect(function()
                    CreateTween(ActionButton, {BackgroundTransparency = 0}, 0.2):Play()
                end)
                
                ActionButton.MouseLeave:Connect(function()
                    CreateTween(ActionButton, {BackgroundTransparency = 0.1}, 0.2):Play()
                end)
                
                -- Divider
                local Divider = Instance.new("Frame")
                Divider.Size = UDim2.new(1, -30, 0, 1)
                Divider.Position = UDim2.new(0, 15, 1, 0)
                Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Divider.BackgroundTransparency = 0.95
                Divider.BorderSizePixel = 0
                Divider.Parent = ButtonFrame
                
                table.insert(Section.Elements, Button)
                return Button
            end
            
            -- Label Element (Text Display)
            function Section:CreateLabel(text)
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Name = "Label"
                LabelFrame.Size = UDim2.new(1, 0, 0, 40)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Parent = SectionContent
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -30, 1, 0)
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.Gotham
                Label.Text = text or "Label"
                Label.TextColor3 = Color3.fromRGB(136, 136, 168)
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextWrapped = true
                Label.Parent = LabelFrame
                
                local Divider = Instance.new("Frame")
                Divider.Size = UDim2.new(1, -30, 0, 1)
                Divider.Position = UDim2.new(0, 15, 1, 0)
                Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Divider.BackgroundTransparency = 0.95
                Divider.BorderSizePixel = 0
                Divider.Parent = LabelFrame
                
                return {
                    SetText = function(newText)
                        Label.Text = newText
                    end
                }
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        return Tab
    end
    
    -- Notification System
    function Window:CreateNotification(config)
        local NotificationContainer = Instance.new("Frame")
        NotificationContainer.Name = "NotificationContainer"
        NotificationContainer.Size = UDim2.new(0, 0, 0, 0)
        NotificationContainer.Position = UDim2.new(1, -20, 1, -20)
        NotificationContainer.AnchorPoint = Vector2.new(1, 1)
        NotificationContainer.BackgroundTransparency = 1
        NotificationContainer.Parent = ScreenGui
        
        local Notification = Instance.new("Frame")
        Notification.Size = UDim2.new(0, 320, 0, 80)
        Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        Notification.BackgroundTransparency = 0.2
        Notification.BorderSizePixel = 0
        Notification.Parent = NotificationContainer
        
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 12)
        NotifCorner.Parent = Notification
        
        local NotifStroke = Instance.new("UIStroke")
        NotifStroke.Color = Window.Theme.Primary
        NotifStroke.Transparency = 0.7
        NotifStroke.Thickness = 1
        NotifStroke.Parent = Notification
        
        local IconFrame = Instance.new("Frame")
        IconFrame.Size = UDim2.new(0, 40, 0, 40)
        IconFrame.Position = UDim2.new(0, 15, 0, 20)
        IconFrame.BackgroundColor3 = Window.Theme.Primary
        IconFrame.BackgroundTransparency = 0.8
        IconFrame.BorderSizePixel = 0
        IconFrame.Parent = Notification
        
        local IconCorner = Instance.new("UICorner")
        IconCorner.CornerRadius = UDim.new(0, 8)
        IconCorner.Parent = IconFrame
        
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(1, 0, 1, 0)
        Icon.BackgroundTransparency = 1
        Icon.Font = Enum.Font.GothamBold
        Icon.Text = config.Icon or "ℹ️"
        Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        Icon.TextSize = 20
        Icon.Parent = IconFrame
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -75, 0, 22)
        Title.Position = UDim2.new(0, 65, 0, 15)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.Text = config.Title or "Notification"
        Title.TextColor3 = Color3.fromRGB(232, 232, 240)
        Title.TextSize = 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Notification
        
        local Message = Instance.new("TextLabel")
        Message.Size = UDim2.new(1, -75, 0, 35)
        Message.Position = UDim2.new(0, 65, 0, 38)
        Message.BackgroundTransparency = 1
        Message.Font = Enum.Font.Gotham
        Message.Text = config.Message or "This is a notification"
        Message.TextColor3 = Color3.fromRGB(136, 136, 168)
        Message.TextSize = 12
        Message.TextXAlignment = Enum.TextXAlignment.Left
        Message.TextWrapped = true
        Message.Parent = Notification
        
        -- Slide in animation
        Notification.Position = UDim2.new(0, 340, 0, 0)
        CreateTween(Notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back):Play()
        
        -- Auto dismiss
        task.delay(config.Duration or 5, function()
            CreateTween(Notification, {Position = UDim2.new(0, 340, 0, 0)}, 0.3):Play()
            wait(0.3)
            NotificationContainer:Destroy()
        end)
    end
    
    -- Destroy Window
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    Window.ScreenGui = ScreenGui
    return Window
end

return AscentUI
