--[[
    Ascent UI Library for Roblox
    Version: 2.0.0
    
    Features:
    - iOS-styled modern interface
    - Full mobile support with touch optimization
    - DPI scaling and resolution adaptation
    - Window management system
    - Built-in settings framework
    - Comprehensive utility functions
    - Glassmorphism design
    - Smooth animations
    
    Usage:
        local AscentUI = loadstring(game:HttpGet("your-url-here"))()
        local Window = AscentUI:CreateWindow({
            Title = "My Script",
            Subtitle = "PREMIUM",
            Size = UDim2.new(0, 600, 0, 400)
        })
]]

local AscentUI = {}
AscentUI.__index = AscentUI
AscentUI.Windows = {}
AscentUI.Settings = {
    DPIScale = 1,
    MobileOptimizations = true,
    AnimationSpeed = 0.3,
    BlurIntensity = 20,
    Theme = "Light"
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Utility Functions
local Utils = {}

function Utils:IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utils:GetScreenSize()
    local ViewportSize = workspace.CurrentCamera.ViewportSize
    return ViewportSize
end

function Utils:CalculateDPI()
    local ViewportSize = self:GetScreenSize()
    local BaseResolution = Vector2.new(1920, 1080)
    local Scale = math.min(ViewportSize.X / BaseResolution.X, ViewportSize.Y / BaseResolution.Y)
    return math.clamp(Scale, 0.5, 2)
end

function Utils:ScaleSize(size)
    local dpiScale = AscentUI.Settings.DPIScale
    if typeof(size) == "UDim2" then
        return UDim2.new(
            size.X.Scale,
            size.X.Offset * dpiScale,
            size.Y.Scale,
            size.Y.Offset * dpiScale
        )
    elseif typeof(size) == "number" then
        return size * dpiScale
    end
    return size
end

function Utils:Tween(object, properties, duration, easingStyle, easingDirection)
    duration = duration or AscentUI.Settings.AnimationSpeed
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(object, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    tween:Play()
    return tween
end

function Utils:CreateRipple(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.5
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.ZIndex = button.ZIndex + 1
    ripple.Parent = button
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    Utils:Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    task.delay(0.6, function()
        ripple:Destroy()
    end)
end

function Utils:CreateBlur(parent, intensity)
    local blur = Instance.new("BlurEffect")
    blur.Size = intensity or AscentUI.Settings.BlurIntensity
    blur.Parent = parent or workspace.CurrentCamera
    return blur
end

function Utils:Lerp(a, b, t)
    return a + (b - a) * t
end

function Utils:RGBToHex(rgb)
    return string.format("#%02X%02X%02X", 
        math.floor(rgb.R * 255),
        math.floor(rgb.G * 255),
        math.floor(rgb.B * 255)
    )
end

function Utils:HexToRGB(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber("0x" .. hex:sub(1,2)),
        tonumber("0x" .. hex:sub(3,4)),
        tonumber("0x" .. hex:sub(5,6))
    )
end

-- Theme System
local Themes = {
    Light = {
        Primary = Color3.fromRGB(0, 122, 255),
        Secondary = Color3.fromRGB(175, 82, 222),
        Success = Color3.fromRGB(52, 199, 89),
        Danger = Color3.fromRGB(255, 59, 48),
        Warning = Color3.fromRGB(255, 149, 0),
        
        Background = Color3.fromRGB(255, 255, 255),
        BackgroundSecondary = Color3.fromRGB(242, 242, 247),
        
        TextPrimary = Color3.fromRGB(0, 0, 0),
        TextSecondary = Color3.fromRGB(60, 60, 67),
        TextTertiary = Color3.fromRGB(142, 142, 147),
        
        Border = Color3.fromRGB(60, 60, 67),
        Separator = Color3.fromRGB(60, 60, 67),
        
        Glass = Color3.fromRGB(255, 255, 255),
        GlassTransparency = 0.28
    },
    Dark = {
        Primary = Color3.fromRGB(10, 132, 255),
        Secondary = Color3.fromRGB(191, 90, 242),
        Success = Color3.fromRGB(48, 209, 88),
        Danger = Color3.fromRGB(255, 69, 58),
        Warning = Color3.fromRGB(255, 159, 10),
        
        Background = Color3.fromRGB(0, 0, 0),
        BackgroundSecondary = Color3.fromRGB(28, 28, 30),
        
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(235, 235, 245),
        TextTertiary = Color3.fromRGB(142, 142, 147),
        
        Border = Color3.fromRGB(84, 84, 88),
        Separator = Color3.fromRGB(84, 84, 88),
        
        Glass = Color3.fromRGB(30, 30, 30),
        GlassTransparency = 0.3
    }
}

function AscentUI:GetTheme()
    return Themes[self.Settings.Theme] or Themes.Light
end

-- Window Management
function AscentUI:CreateWindow(config)
    config = config or {}
    
    local Window = {
        Title = config.Title or "Ascent UI",
        Subtitle = config.Subtitle or "NEXTGEN",
        Size = Utils:ScaleSize(config.Size or UDim2.new(0, 600, 0, 450)),
        MinSize = config.MinSize or Vector2.new(400, 300),
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        Draggable = config.Draggable ~= false,
        Resizable = config.Resizable ~= false,
        CloseButton = config.CloseButton ~= false
    }
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AscentUI_" .. Window.Title
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100
    
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
    
    Window.ScreenGui = ScreenGui
    
    -- Main Frame (Device Frame)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = Window.Size
    MainFrame.BackgroundColor3 = AscentUI:GetTheme().Glass
    MainFrame.BackgroundTransparency = AscentUI:GetTheme().GlassTransparency
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, Utils:ScaleSize(42))
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.6
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame
    
    -- Shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 50, 1, 50)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = MainFrame.ZIndex - 1
    Shadow.Parent = MainFrame
    
    Window.MainFrame = MainFrame
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(80))
    Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Header.BackgroundTransparency = 0.1
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    HeaderGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.28)
    })
    HeaderGradient.Rotation = 90
    HeaderGradient.Parent = Header
    
    local HeaderSeparator = Instance.new("Frame")
    HeaderSeparator.Name = "Separator"
    HeaderSeparator.Position = UDim2.new(0, 0, 1, 0)
    HeaderSeparator.Size = UDim2.new(1, 0, 0, 1)
    HeaderSeparator.BackgroundColor3 = AscentUI:GetTheme().Separator
    HeaderSeparator.BackgroundTransparency = 0.82
    HeaderSeparator.BorderSizePixel = 0
    HeaderSeparator.Parent = Header
    
    -- Brand Section
    local BrandFrame = Instance.new("Frame")
    BrandFrame.Name = "Brand"
    BrandFrame.Position = UDim2.new(0, Utils:ScaleSize(32), 0, Utils:ScaleSize(20))
    BrandFrame.Size = UDim2.new(0, Utils:ScaleSize(200), 0, Utils:ScaleSize(48))
    BrandFrame.BackgroundTransparency = 1
    BrandFrame.Parent = Header
    
    local BrandIcon = Instance.new("Frame")
    BrandIcon.Name = "Icon"
    BrandIcon.Size = UDim2.new(0, Utils:ScaleSize(48), 0, Utils:ScaleSize(48))
    BrandIcon.BackgroundColor3 = AscentUI:GetTheme().Primary
    BrandIcon.BorderSizePixel = 0
    BrandIcon.Parent = BrandFrame
    
    local BrandIconCorner = Instance.new("UICorner")
    BrandIconCorner.CornerRadius = UDim.new(0, Utils:ScaleSize(14))
    BrandIconCorner.Parent = BrandIcon
    
    local BrandIconGradient = Instance.new("UIGradient")
    BrandIconGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, AscentUI:GetTheme().Primary),
        ColorSequenceKeypoint.new(1, AscentUI:GetTheme().Secondary)
    })
    BrandIconGradient.Rotation = 135
    BrandIconGradient.Parent = BrandIcon
    
    local BrandIconText = Instance.new("TextLabel")
    BrandIconText.Size = UDim2.new(1, 0, 1, 0)
    BrandIconText.BackgroundTransparency = 1
    BrandIconText.Text = "A"
    BrandIconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    BrandIconText.TextSize = Utils:ScaleSize(28)
    BrandIconText.Font = Enum.Font.GothamBold
    BrandIconText.Parent = BrandIcon
    
    local BrandText = Instance.new("Frame")
    BrandText.Name = "Text"
    BrandText.Position = UDim2.new(0, Utils:ScaleSize(60), 0, 0)
    BrandText.Size = UDim2.new(1, Utils:ScaleSize(-60), 1, 0)
    BrandText.BackgroundTransparency = 1
    BrandText.Parent = BrandFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(28))
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Window.Title
    TitleLabel.TextColor3 = AscentUI:GetTheme().TextPrimary
    TitleLabel.TextSize = Utils:ScaleSize(26)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Top
    TitleLabel.Parent = BrandText
    
    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Name = "Subtitle"
    SubtitleLabel.Position = UDim2.new(0, 0, 0, Utils:ScaleSize(26))
    SubtitleLabel.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(20))
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Text = Window.Subtitle
    SubtitleLabel.TextColor3 = AscentUI:GetTheme().TextTertiary
    SubtitleLabel.TextSize = Utils:ScaleSize(13)
    SubtitleLabel.Font = Enum.Font.GothamBold
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.TextYAlignment = Enum.TextYAlignment.Top
    SubtitleLabel.Parent = BrandText
    
    -- Header Actions
    local ActionsFrame = Instance.new("Frame")
    ActionsFrame.Name = "Actions"
    ActionsFrame.AnchorPoint = Vector2.new(1, 0)
    ActionsFrame.Position = UDim2.new(1, Utils:ScaleSize(-32), 0, Utils:ScaleSize(20))
    ActionsFrame.Size = UDim2.new(0, Utils:ScaleSize(100), 0, Utils:ScaleSize(36))
    ActionsFrame.BackgroundTransparency = 1
    ActionsFrame.Parent = Header
    
    local ActionsLayout = Instance.new("UIListLayout")
    ActionsLayout.FillDirection = Enum.FillDirection.Horizontal
    ActionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ActionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ActionsLayout.Padding = UDim.new(0, Utils:ScaleSize(8))
    ActionsLayout.Parent = ActionsFrame
    
    -- Close Button
    if Window.CloseButton then
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Name = "CloseButton"
        CloseBtn.Size = UDim2.new(0, Utils:ScaleSize(36), 0, Utils:ScaleSize(36))
        CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        CloseBtn.BackgroundTransparency = 0.96
        CloseBtn.BorderSizePixel = 0
        CloseBtn.Text = "✕"
        CloseBtn.TextColor3 = AscentUI:GetTheme().Primary
        CloseBtn.TextSize = Utils:ScaleSize(18)
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.Parent = ActionsFrame
        
        local CloseBtnCorner = Instance.new("UICorner")
        CloseBtnCorner.CornerRadius = UDim.new(0, Utils:ScaleSize(12))
        CloseBtnCorner.Parent = CloseBtn
        
        CloseBtn.MouseButton1Click:Connect(function()
            Utils:CreateRipple(CloseBtn, CloseBtn.AbsoluteSize.X/2, CloseBtn.AbsoluteSize.Y/2)
            Window:Toggle()
        end)
        
        CloseBtn.MouseEnter:Connect(function()
            Utils:Tween(CloseBtn, {BackgroundTransparency = 0.9}, 0.2)
        end)
        
        CloseBtn.MouseLeave:Connect(function()
            Utils:Tween(CloseBtn, {BackgroundTransparency = 0.96}, 0.2)
        end)
    end
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Position = UDim2.new(0, 0, 0, Utils:ScaleSize(80))
    ContentContainer.Size = UDim2.new(1, 0, 1, Utils:ScaleSize(-80 - 70))
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame
    
    Window.ContentContainer = ContentContainer
    
    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Position = UDim2.new(0, 0, 1, Utils:ScaleSize(-70))
    TabBar.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(70))
    TabBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabBar.BackgroundTransparency = 0.15
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainFrame
    
    local TabBarSeparator = Instance.new("Frame")
    TabBarSeparator.Name = "Separator"
    TabBarSeparator.Size = UDim2.new(1, 0, 0, 1)
    TabBarSeparator.BackgroundColor3 = AscentUI:GetTheme().Separator
    TabBarSeparator.BackgroundTransparency = 0.82
    TabBarSeparator.BorderSizePixel = 0
    TabBarSeparator.Parent = TabBar
    
    local TabBarLayout = Instance.new("UIListLayout")
    TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    TabBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabBarLayout.Padding = UDim.new(0, 0)
    TabBarLayout.Parent = TabBar
    
    Window.TabBar = TabBar
    Window.TabBarLayout = TabBarLayout
    
    -- Dragging functionality
    if Window.Draggable then
        local dragging = false
        local dragInput, mousePos, framePos
        
        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                mousePos = input.Position
                framePos = MainFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        Header.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                MainFrame.Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    -- Window methods
    function Window:Toggle()
        self.Visible = not self.Visible
        if self.Visible then
            MainFrame.Visible = true
            Utils:Tween(MainFrame, {Size = self.Size}, 0.3, Enum.EasingStyle.Back)
        else
            Utils:Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back).Completed:Connect(function()
                MainFrame.Visible = false
            end)
        end
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
        for i, v in pairs(AscentUI.Windows) do
            if v == self then
                table.remove(AscentUI.Windows, i)
            end
        end
    end
    
    function Window:SetTitle(title)
        self.Title = title
        TitleLabel.Text = title
    end
    
    function Window:SetSubtitle(subtitle)
        self.Subtitle = subtitle
        SubtitleLabel.Text = subtitle
    end
    
    -- Tab creation
    function Window:CreateTab(config)
        config = config or {}
        
        local Tab = {
            Name = config.Name or "Tab",
            Icon = config.Icon or "📄",
            Badge = config.Badge,
            Sections = {},
            Active = false
        }
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton_" .. Tab.Name
        TabButton.Size = UDim2.new(0, Utils:ScaleSize(100), 1, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.Parent = TabBar
        
        local TabIcon = Instance.new("TextLabel")
        TabIcon.Name = "Icon"
        TabIcon.Position = UDim2.new(0.5, 0, 0, Utils:ScaleSize(8))
        TabIcon.Size = UDim2.new(0, Utils:ScaleSize(28), 0, Utils:ScaleSize(28))
        TabIcon.AnchorPoint = Vector2.new(0.5, 0)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Text = Tab.Icon
        TabIcon.TextColor3 = AscentUI:GetTheme().TextTertiary
        TabIcon.TextSize = Utils:ScaleSize(24)
        TabIcon.Font = Enum.Font.Gotham
        TabIcon.Parent = TabButton
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "Label"
        TabLabel.Position = UDim2.new(0, 0, 1, Utils:ScaleSize(-18))
        TabLabel.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(14))
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = Tab.Name
        TabLabel.TextColor3 = AscentUI:GetTheme().TextTertiary
        TabLabel.TextSize = Utils:ScaleSize(11)
        TabLabel.Font = Enum.Font.Gotham
        TabLabel.Parent = TabButton
        
        if Tab.Badge then
            local Badge = Instance.new("TextLabel")
            Badge.Name = "Badge"
            Badge.AnchorPoint = Vector2.new(1, 0)
            Badge.Position = UDim2.new(1, Utils:ScaleSize(-8), 0, Utils:ScaleSize(4))
            Badge.Size = UDim2.new(0, Utils:ScaleSize(20), 0, Utils:ScaleSize(20))
            Badge.BackgroundColor3 = AscentUI:GetTheme().Danger
            Badge.BorderSizePixel = 0
            Badge.Text = tostring(Tab.Badge)
            Badge.TextColor3 = Color3.fromRGB(255, 255, 255)
            Badge.TextSize = Utils:ScaleSize(10)
            Badge.Font = Enum.Font.GothamBold
            Badge.Parent = TabButton
            
            local BadgeCorner = Instance.new("UICorner")
            BadgeCorner.CornerRadius = UDim.new(1, 0)
            BadgeCorner.Parent = Badge
            
            Tab.BadgeLabel = Badge
        end
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "TabContent_" .. Tab.Name
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = Utils:ScaleSize(4)
        TabContent.ScrollBarImageColor3 = AscentUI:GetTheme().TextTertiary
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingTop = UDim.new(0, Utils:ScaleSize(24))
        TabPadding.PaddingBottom = UDim.new(0, Utils:ScaleSize(24))
        TabPadding.PaddingLeft = UDim.new(0, Utils:ScaleSize(32))
        TabPadding.PaddingRight = UDim.new(0, Utils:ScaleSize(32))
        TabPadding.Parent = TabContent
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, Utils:ScaleSize(16))
        TabLayout.Parent = TabContent
        
        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + Utils:ScaleSize(48))
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Layout = TabLayout
        
        -- Tab activation
        TabButton.MouseButton1Click:Connect(function()
            Utils:CreateRipple(TabButton, TabButton.AbsoluteSize.X/2, TabButton.AbsoluteSize.Y/2)
            Window:SelectTab(Tab)
        end)
        
        TabButton.MouseEnter:Connect(function()
            if not Tab.Active then
                Utils:Tween(TabIcon, {TextColor3 = AscentUI:GetTheme().Primary}, 0.2)
                Utils:Tween(TabLabel, {TextColor3 = AscentUI:GetTheme().Primary}, 0.2)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if not Tab.Active then
                Utils:Tween(TabIcon, {TextColor3 = AscentUI:GetTheme().TextTertiary}, 0.2)
                Utils:Tween(TabLabel, {TextColor3 = AscentUI:GetTheme().TextTertiary}, 0.2)
            end
        end)
        
        -- Section creation
        function Tab:CreateSection(name)
            local Section = {
                Name = name or "Section",
                Elements = {}
            }
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section_" .. Section.Name
            SectionFrame.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(50))
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Parent = TabContent
            
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, Utils:ScaleSize(12))
            SectionLayout.Parent = SectionFrame
            
            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y)
            end)
            
            -- Section Header
            if name and name ~= "" then
                local SectionHeader = Instance.new("Frame")
                SectionHeader.Name = "Header"
                SectionHeader.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(36))
                SectionHeader.BackgroundTransparency = 1
                SectionHeader.Parent = SectionFrame
                SectionHeader.LayoutOrder = 0
                
                local SectionTitle = Instance.new("TextLabel")
                SectionTitle.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(24))
                SectionTitle.BackgroundTransparency = 1
                SectionTitle.Text = Section.Name
                SectionTitle.TextColor3 = AscentUI:GetTheme().TextPrimary
                SectionTitle.TextSize = Utils:ScaleSize(20)
                SectionTitle.Font = Enum.Font.GothamBold
                SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
                SectionTitle.Parent = SectionHeader
                
                local SectionSubtitle = Instance.new("TextLabel")
                SectionSubtitle.Position = UDim2.new(0, 0, 0, Utils:ScaleSize(22))
                SectionSubtitle.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(14))
                SectionSubtitle.BackgroundTransparency = 1
                SectionSubtitle.Text = ""
                SectionSubtitle.TextColor3 = AscentUI:GetTheme().TextSecondary
                SectionSubtitle.TextSize = Utils:ScaleSize(13)
                SectionSubtitle.Font = Enum.Font.Gotham
                SectionSubtitle.TextXAlignment = Enum.TextXAlignment.Left
                SectionSubtitle.Parent = SectionHeader
                
                Section.SubtitleLabel = SectionSubtitle
                
                function Section:SetSubtitle(text)
                    SectionSubtitle.Text = text
                end
            end
            
            Section.Frame = SectionFrame
            Section.Layout = SectionLayout
            
            -- Element creation methods
            function Section:CreateButton(config)
                config = config or {}
                
                local Button = {
                    Name = config.Name or "Button",
                    Callback = config.Callback or function() end
                }
                
                local ButtonFrame = Instance.new("TextButton")
                ButtonFrame.Name = "Button_" .. Button.Name
                ButtonFrame.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(44))
                ButtonFrame.BackgroundColor3 = AscentUI:GetTheme().Primary
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.AutoButtonColor = false
                ButtonFrame.Text = ""
                ButtonFrame.ClipsDescendants = true
                ButtonFrame.Parent = SectionFrame
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, Utils:ScaleSize(12))
                ButtonCorner.Parent = ButtonFrame
                
                local ButtonLabel = Instance.new("TextLabel")
                ButtonLabel.Size = UDim2.new(1, Utils:ScaleSize(-16), 1, 0)
                ButtonLabel.Position = UDim2.new(0, Utils:ScaleSize(16), 0, 0)
                ButtonLabel.BackgroundTransparency = 1
                ButtonLabel.Text = Button.Name
                ButtonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                ButtonLabel.TextSize = Utils:ScaleSize(15)
                ButtonLabel.Font = Enum.Font.GothamSemibold
                ButtonLabel.TextXAlignment = Enum.TextXAlignment.Center
                ButtonLabel.Parent = ButtonFrame
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    Utils:CreateRipple(ButtonFrame, Mouse.X - ButtonFrame.AbsolutePosition.X, Mouse.Y - ButtonFrame.AbsolutePosition.Y)
                    Button.Callback()
                end)
                
                ButtonFrame.MouseEnter:Connect(function()
                    Utils:Tween(ButtonFrame, {BackgroundColor3 = AscentUI:GetTheme().Secondary}, 0.2)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Utils:Tween(ButtonFrame, {BackgroundColor3 = AscentUI:GetTheme().Primary}, 0.2)
                end)
                
                Button.Frame = ButtonFrame
                table.insert(Section.Elements, Button)
                return Button
            end
            
            function Section:CreateToggle(config)
                config = config or {}
                
                local Toggle = {
                    Name = config.Name or "Toggle",
                    Default = config.Default or false,
                    Callback = config.Callback or function() end,
                    Value = config.Default or false
                }
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = "Toggle_" .. Toggle.Name
                ToggleFrame.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(60))
                ToggleFrame.BackgroundColor3 = AscentUI:GetTheme().Glass
                ToggleFrame.BackgroundTransparency = AscentUI:GetTheme().GlassTransparency
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Parent = SectionFrame
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, Utils:ScaleSize(16))
                ToggleCorner.Parent = ToggleFrame
                
                local ToggleStroke = Instance.new("UIStroke")
                ToggleStroke.Color = AscentUI:GetTheme().Border
                ToggleStroke.Transparency = 0.85
                ToggleStroke.Thickness = 1
                ToggleStroke.Parent = ToggleFrame
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Text = ""
                ToggleButton.Parent = ToggleFrame
                
                local ToggleInfo = Instance.new("Frame")
                ToggleInfo.Position = UDim2.new(0, Utils:ScaleSize(16), 0, 0)
                ToggleInfo.Size = UDim2.new(1, Utils:ScaleSize(-80), 1, 0)
                ToggleInfo.BackgroundTransparency = 1
                ToggleInfo.Parent = ToggleFrame
                
                local ToggleTitle = Instance.new("TextLabel")
                ToggleTitle.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(20))
                ToggleTitle.Position = UDim2.new(0, 0, 0, Utils:ScaleSize(12))
                ToggleTitle.BackgroundTransparency = 1
                ToggleTitle.Text = Toggle.Name
                ToggleTitle.TextColor3 = AscentUI:GetTheme().TextPrimary
                ToggleTitle.TextSize = Utils:ScaleSize(15)
                ToggleTitle.Font = Enum.Font.GothamSemibold
                ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle.Parent = ToggleInfo
                
                local ToggleDesc = Instance.new("TextLabel")
                ToggleDesc.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(16))
                ToggleDesc.Position = UDim2.new(0, 0, 0, Utils:ScaleSize(32))
                ToggleDesc.BackgroundTransparency = 1
                ToggleDesc.Text = config.Description or ""
                ToggleDesc.TextColor3 = AscentUI:GetTheme().TextSecondary
                ToggleDesc.TextSize = Utils:ScaleSize(12)
                ToggleDesc.Font = Enum.Font.Gotham
                ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
                ToggleDesc.TextTransparency = 0.3
                ToggleDesc.Parent = ToggleInfo
                
                -- Switch
                local Switch = Instance.new("Frame")
                Switch.Name = "Switch"
                Switch.AnchorPoint = Vector2.new(1, 0.5)
                Switch.Position = UDim2.new(1, Utils:ScaleSize(-16), 0.5, 0)
                Switch.Size = UDim2.new(0, Utils:ScaleSize(51), 0, Utils:ScaleSize(31))
                Switch.BackgroundColor3 = AscentUI:GetTheme().TextTertiary
                Switch.BorderSizePixel = 0
                Switch.Parent = ToggleFrame
                
                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(1, 0)
                SwitchCorner.Parent = Switch
                
                local SwitchKnob = Instance.new("Frame")
                SwitchKnob.Name = "Knob"
                SwitchKnob.Position = UDim2.new(0, Utils:ScaleSize(2), 0.5, 0)
                SwitchKnob.AnchorPoint = Vector2.new(0, 0.5)
                SwitchKnob.Size = UDim2.new(0, Utils:ScaleSize(27), 0, Utils:ScaleSize(27))
                SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SwitchKnob.BorderSizePixel = 0
                SwitchKnob.Parent = Switch
                
                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = SwitchKnob
                
                local function UpdateToggle(value, animated)
                    Toggle.Value = value
                    
                    if animated == nil then animated = true end
                    local duration = animated and 0.2 or 0
                    
                    if value then
                        Utils:Tween(Switch, {BackgroundColor3 = AscentUI:GetTheme().Success}, duration)
                        Utils:Tween(SwitchKnob, {
                            Position = UDim2.new(1, Utils:ScaleSize(-2), 0.5, 0),
                            AnchorPoint = Vector2.new(1, 0.5)
                        }, duration)
                    else
                        Utils:Tween(Switch, {BackgroundColor3 = AscentUI:GetTheme().TextTertiary}, duration)
                        Utils:Tween(SwitchKnob, {
                            Position = UDim2.new(0, Utils:ScaleSize(2), 0.5, 0),
                            AnchorPoint = Vector2.new(0, 0.5)
                        }, duration)
                    end
                    
                    Toggle.Callback(value)
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Utils:CreateRipple(ToggleFrame, Mouse.X - ToggleFrame.AbsolutePosition.X, Mouse.Y - ToggleFrame.AbsolutePosition.Y)
                    UpdateToggle(not Toggle.Value, true)
                end)
                
                function Toggle:SetValue(value, animated)
                    UpdateToggle(value, animated)
                end
                
                UpdateToggle(Toggle.Default, false)
                
                Toggle.Frame = ToggleFrame
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            function Section:CreateSlider(config)
                config = config or {}
                
                local Slider = {
                    Name = config.Name or "Slider",
                    Min = config.Min or 0,
                    Max = config.Max or 100,
                    Default = config.Default or 50,
                    Increment = config.Increment or 1,
                    Callback = config.Callback or function() end,
                    Value = config.Default or 50
                }
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = "Slider_" .. Slider.Name
                SliderFrame.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(80))
                SliderFrame.BackgroundColor3 = AscentUI:GetTheme().Glass
                SliderFrame.BackgroundTransparency = AscentUI:GetTheme().GlassTransparency
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = SectionFrame
                
                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, Utils:ScaleSize(16))
                SliderCorner.Parent = SliderFrame
                
                local SliderStroke = Instance.new("UIStroke")
                SliderStroke.Color = AscentUI:GetTheme().Border
                SliderStroke.Transparency = 0.85
                SliderStroke.Thickness = 1
                SliderStroke.Parent = SliderFrame
                
                local SliderTitle = Instance.new("TextLabel")
                SliderTitle.Position = UDim2.new(0, Utils:ScaleSize(16), 0, Utils:ScaleSize(12))
                SliderTitle.Size = UDim2.new(0.6, 0, 0, Utils:ScaleSize(20))
                SliderTitle.BackgroundTransparency = 1
                SliderTitle.Text = Slider.Name
                SliderTitle.TextColor3 = AscentUI:GetTheme().TextPrimary
                SliderTitle.TextSize = Utils:ScaleSize(15)
                SliderTitle.Font = Enum.Font.GothamSemibold
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                SliderTitle.Parent = SliderFrame
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.AnchorPoint = Vector2.new(1, 0)
                SliderValue.Position = UDim2.new(1, Utils:ScaleSize(-16), 0, Utils:ScaleSize(12))
                SliderValue.Size = UDim2.new(0.3, 0, 0, Utils:ScaleSize(20))
                SliderValue.BackgroundTransparency = 1
                SliderValue.Text = tostring(Slider.Value)
                SliderValue.TextColor3 = AscentUI:GetTheme().Primary
                SliderValue.TextSize = Utils:ScaleSize(15)
                SliderValue.Font = Enum.Font.GothamBold
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = SliderFrame
                
                -- Slider Track
                local SliderTrack = Instance.new("Frame")
                SliderTrack.Position = UDim2.new(0, Utils:ScaleSize(16), 1, Utils:ScaleSize(-24))
                SliderTrack.Size = UDim2.new(1, Utils:ScaleSize(-32), 0, Utils:ScaleSize(6))
                SliderTrack.BackgroundColor3 = AscentUI:GetTheme().TextTertiary
                SliderTrack.BackgroundTransparency = 0.7
                SliderTrack.BorderSizePixel = 0
                SliderTrack.Parent = SliderFrame
                
                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent = SliderTrack
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
                SliderFill.BackgroundColor3 = AscentUI:GetTheme().Primary
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderTrack
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = SliderFill
                
                local SliderKnob = Instance.new("Frame")
                SliderKnob.Name = "Knob"
                SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
                SliderKnob.Size = UDim2.new(0, Utils:ScaleSize(20), 0, Utils:ScaleSize(20))
                SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderKnob.BorderSizePixel = 0
                SliderKnob.Parent = SliderFill
                
                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = SliderKnob
                
                local KnobShadow = Instance.new("UIStroke")
                KnobShadow.Color = Color3.fromRGB(0, 0, 0)
                KnobShadow.Transparency = 0.85
                KnobShadow.Thickness = 2
                KnobShadow.Parent = SliderKnob
                
                local dragging = false
                
                local function UpdateSlider(value, animated)
                    value = math.clamp(value, Slider.Min, Slider.Max)
                    value = math.floor(value / Slider.Increment + 0.5) * Slider.Increment
                    Slider.Value = value
                    
                    SliderValue.Text = tostring(value)
                    
                    local percentage = (value - Slider.Min) / (Slider.Max - Slider.Min)
                    
                    if animated == nil then animated = true end
                    local duration = animated and 0.15 or 0
                    
                    Utils:Tween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, duration)
                    
                    Slider.Callback(value)
                end
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        
                        local function Update()
                            local mousePos = UserInputService:GetMouseLocation().X
                            local relativePos = mousePos - SliderTrack.AbsolutePosition.X
                            local percentage = math.clamp(relativePos / SliderTrack.AbsoluteSize.X, 0, 1)
                            local value = Slider.Min + (Slider.Max - Slider.Min) * percentage
                            UpdateSlider(value, false)
                        end
                        
                        Update()
                        
                        local connection
                        connection = UserInputService.InputChanged:Connect(function(input2)
                            if input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch then
                                if dragging then
                                    Update()
                                end
                            end
                        end)
                        
                        local connection2
                        connection2 = UserInputService.InputEnded:Connect(function(input2)
                            if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                                dragging = false
                                connection:Disconnect()
                                connection2:Disconnect()
                            end
                        end)
                    end
                end)
                
                function Slider:SetValue(value, animated)
                    UpdateSlider(value, animated)
                end
                
                UpdateSlider(Slider.Default, false)
                
                Slider.Frame = SliderFrame
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            function Section:CreateDropdown(config)
                config = config or {}
                
                local Dropdown = {
                    Name = config.Name or "Dropdown",
                    Options = config.Options or {},
                    Default = config.Default,
                    Callback = config.Callback or function() end,
                    Value = config.Default,
                    Open = false
                }
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = "Dropdown_" .. Dropdown.Name
                DropdownFrame.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(60))
                DropdownFrame.BackgroundColor3 = AscentUI:GetTheme().Glass
                DropdownFrame.BackgroundTransparency = AscentUI:GetTheme().GlassTransparency
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.ClipsDescendants = false
                DropdownFrame.Parent = SectionFrame
                
                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, Utils:ScaleSize(16))
                DropdownCorner.Parent = DropdownFrame
                
                local DropdownStroke = Instance.new("UIStroke")
                DropdownStroke.Color = AscentUI:GetTheme().Border
                DropdownStroke.Transparency = 0.85
                DropdownStroke.Thickness = 1
                DropdownStroke.Parent = DropdownFrame
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(60))
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Text = ""
                DropdownButton.Parent = DropdownFrame
                
                local DropdownTitle = Instance.new("TextLabel")
                DropdownTitle.Position = UDim2.new(0, Utils:ScaleSize(16), 0, Utils:ScaleSize(12))
                DropdownTitle.Size = UDim2.new(1, Utils:ScaleSize(-48), 0, Utils:ScaleSize(20))
                DropdownTitle.BackgroundTransparency = 1
                DropdownTitle.Text = Dropdown.Name
                DropdownTitle.TextColor3 = AscentUI:GetTheme().TextPrimary
                DropdownTitle.TextSize = Utils:ScaleSize(15)
                DropdownTitle.Font = Enum.Font.GothamSemibold
                DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
                DropdownTitle.Parent = DropdownFrame
                
                local DropdownSelected = Instance.new("TextLabel")
                DropdownSelected.Position = UDim2.new(0, Utils:ScaleSize(16), 0, Utils:ScaleSize(32))
                DropdownSelected.Size = UDim2.new(1, Utils:ScaleSize(-48), 0, Utils:ScaleSize(16))
                DropdownSelected.BackgroundTransparency = 1
                DropdownSelected.Text = Dropdown.Default or "Select..."
                DropdownSelected.TextColor3 = AscentUI:GetTheme().TextSecondary
                DropdownSelected.TextSize = Utils:ScaleSize(13)
                DropdownSelected.Font = Enum.Font.Gotham
                DropdownSelected.TextXAlignment = Enum.TextXAlignment.Left
                DropdownSelected.Parent = DropdownFrame
                
                local DropdownIcon = Instance.new("TextLabel")
                DropdownIcon.AnchorPoint = Vector2.new(1, 0)
                DropdownIcon.Position = UDim2.new(1, Utils:ScaleSize(-16), 0, Utils:ScaleSize(20))
                DropdownIcon.Size = UDim2.new(0, Utils:ScaleSize(20), 0, Utils:ScaleSize(20))
                DropdownIcon.BackgroundTransparency = 1
                DropdownIcon.Text = "▼"
                DropdownIcon.TextColor3 = AscentUI:GetTheme().Primary
                DropdownIcon.TextSize = Utils:ScaleSize(12)
                DropdownIcon.Font = Enum.Font.GothamBold
                DropdownIcon.Parent = DropdownFrame
                
                -- Dropdown List
                local DropdownList = Instance.new("Frame")
                DropdownList.Name = "List"
                DropdownList.Position = UDim2.new(0, 0, 1, Utils:ScaleSize(4))
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.BackgroundColor3 = AscentUI:GetTheme().Background
                DropdownList.BackgroundTransparency = 0.05
                DropdownList.BorderSizePixel = 0
                DropdownList.ClipsDescendants = true
                DropdownList.Visible = false
                DropdownList.ZIndex = 10
                DropdownList.Parent = DropdownFrame
                
                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, Utils:ScaleSize(12))
                ListCorner.Parent = DropdownList
                
                local ListStroke = Instance.new("UIStroke")
                ListStroke.Color = AscentUI:GetTheme().Border
                ListStroke.Transparency = 0.85
                ListStroke.Thickness = 1
                ListStroke.Parent = DropdownList
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding = UDim.new(0, 0)
                ListLayout.Parent = DropdownList
                
                local function UpdateDropdown(value)
                    Dropdown.Value = value
                    DropdownSelected.Text = value
                    Dropdown.Callback(value)
                end
                
                local function ToggleDropdown()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        DropdownList.Visible = true
                        local targetHeight = math.min(#Dropdown.Options * Utils:ScaleSize(40), Utils:ScaleSize(200))
                        Utils:Tween(DropdownList, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                        Utils:Tween(DropdownIcon, {Rotation = 180}, 0.2)
                    else
                        Utils:Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2).Completed:Connect(function()
                            DropdownList.Visible = false
                        end)
                        Utils:Tween(DropdownIcon, {Rotation = 0}, 0.2)
                    end
                end
                
                for _, option in ipairs(Dropdown.Options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(40))
                    OptionButton.BackgroundColor3 = AscentUI:GetTheme().Background
                    OptionButton.BackgroundTransparency = 1
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Text = ""
                    OptionButton.ClipsDescendants = true
                    OptionButton.Parent = DropdownList
                    
                    local OptionLabel = Instance.new("TextLabel")
                    OptionLabel.Size = UDim2.new(1, Utils:ScaleSize(-16), 1, 0)
                    OptionLabel.Position = UDim2.new(0, Utils:ScaleSize(16), 0, 0)
                    OptionLabel.BackgroundTransparency = 1
                    OptionLabel.Text = option
                    OptionLabel.TextColor3 = AscentUI:GetTheme().TextPrimary
                    OptionLabel.TextSize = Utils:ScaleSize(14)
                    OptionLabel.Font = Enum.Font.Gotham
                    OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    OptionLabel.Parent = OptionButton
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Utils:CreateRipple(OptionButton, Mouse.X - OptionButton.AbsolutePosition.X, Mouse.Y - OptionButton.AbsolutePosition.Y)
                        UpdateDropdown(option)
                        ToggleDropdown()
                    end)
                    
                    OptionButton.MouseEnter:Connect(function()
                        Utils:Tween(OptionButton, {BackgroundTransparency = 0.95}, 0.15)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Utils:Tween(OptionButton, {BackgroundTransparency = 1}, 0.15)
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Utils:CreateRipple(DropdownFrame, Mouse.X - DropdownFrame.AbsolutePosition.X, Mouse.Y - DropdownFrame.AbsolutePosition.Y)
                    ToggleDropdown()
                end)
                
                function Dropdown:SetValue(value)
                    UpdateDropdown(value)
                end
                
                function Dropdown:Refresh(options, default)
                    Dropdown.Options = options
                    
                    for _, child in ipairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for _, option in ipairs(options) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(40))
                        OptionButton.BackgroundColor3 = AscentUI:GetTheme().Background
                        OptionButton.BackgroundTransparency = 1
                        OptionButton.BorderSizePixel = 0
                        OptionButton.Text = ""
                        OptionButton.ClipsDescendants = true
                        OptionButton.Parent = DropdownList
                        
                        local OptionLabel = Instance.new("TextLabel")
                        OptionLabel.Size = UDim2.new(1, Utils:ScaleSize(-16), 1, 0)
                        OptionLabel.Position = UDim2.new(0, Utils:ScaleSize(16), 0, 0)
                        OptionLabel.BackgroundTransparency = 1
                        OptionLabel.Text = option
                        OptionLabel.TextColor3 = AscentUI:GetTheme().TextPrimary
                        OptionLabel.TextSize = Utils:ScaleSize(14)
                        OptionLabel.Font = Enum.Font.Gotham
                        OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                        OptionLabel.Parent = OptionButton
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            Utils:CreateRipple(OptionButton, Mouse.X - OptionButton.AbsolutePosition.X, Mouse.Y - OptionButton.AbsolutePosition.Y)
                            UpdateDropdown(option)
                            ToggleDropdown()
                        end)
                        
                        OptionButton.MouseEnter:Connect(function()
                            Utils:Tween(OptionButton, {BackgroundTransparency = 0.95}, 0.15)
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            Utils:Tween(OptionButton, {BackgroundTransparency = 1}, 0.15)
                        end)
                    end
                    
                    if default then
                        UpdateDropdown(default)
                    end
                end
                
                if Dropdown.Default then
                    UpdateDropdown(Dropdown.Default)
                end
                
                Dropdown.Frame = DropdownFrame
                table.insert(Section.Elements, Dropdown)
                return Dropdown
            end
            
            function Section:CreateLabel(text)
                local Label = {
                    Text = text or "Label"
                }
                
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Name = "Label"
                LabelFrame.Size = UDim2.new(1, 0, 0, Utils:ScaleSize(40))
                LabelFrame.BackgroundColor3 = AscentUI:GetTheme().Glass
                LabelFrame.BackgroundTransparency = AscentUI:GetTheme().GlassTransparency
                LabelFrame.BorderSizePixel = 0
                LabelFrame.Parent = SectionFrame
                
                local LabelCorner = Instance.new("UICorner")
                LabelCorner.CornerRadius = UDim.new(0, Utils:ScaleSize(12))
                LabelCorner.Parent = LabelFrame
                
                local LabelStroke = Instance.new("UIStroke")
                LabelStroke.Color = AscentUI:GetTheme().Border
                LabelStroke.Transparency = 0.85
                LabelStroke.Thickness = 1
                LabelStroke.Parent = LabelFrame
                
                local LabelText = Instance.new("TextLabel")
                LabelText.Size = UDim2.new(1, Utils:ScaleSize(-32), 1, 0)
                LabelText.Position = UDim2.new(0, Utils:ScaleSize(16), 0, 0)
                LabelText.BackgroundTransparency = 1
                LabelText.Text = Label.Text
                LabelText.TextColor3 = AscentUI:GetTheme().TextPrimary
                LabelText.TextSize = Utils:ScaleSize(14)
                LabelText.Font = Enum.Font.Gotham
                LabelText.TextXAlignment = Enum.TextXAlignment.Left
                LabelText.TextWrapped = true
                LabelText.Parent = LabelFrame
                
                function Label:SetText(text)
                    Label.Text = text
                    LabelText.Text = text
                end
                
                Label.Frame = LabelFrame
                Label.TextLabel = LabelText
                table.insert(Section.Elements, Label)
                return Label
            end
            
            function Section:CreateDivider()
                local Divider = Instance.new("Frame")
                Divider.Name = "Divider"
                Divider.Size = UDim2.new(1, 0, 0, 1)
                Divider.BackgroundColor3 = AscentUI:GetTheme().Separator
                Divider.BackgroundTransparency = 0.82
                Divider.BorderSizePixel = 0
                Divider.Parent = SectionFrame
                
                return Divider
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then
            Window:SelectTab(Tab)
        end
        
        return Tab
    end
    
    function Window:SelectTab(tab)
        for _, t in ipairs(self.Tabs) do
            if t == tab then
                t.Active = true
                t.Content.Visible = true
                Utils:Tween(t.Button.Icon, {TextColor3 = AscentUI:GetTheme().Primary}, 0.2)
                Utils:Tween(t.Button.Label, {TextColor3 = AscentUI:GetTheme().Primary}, 0.2)
            else
                t.Active = false
                t.Content.Visible = false
                Utils:Tween(t.Button.Icon, {TextColor3 = AscentUI:GetTheme().TextTertiary}, 0.2)
                Utils:Tween(t.Button.Label, {TextColor3 = AscentUI:GetTheme().TextTertiary}, 0.2)
            end
        end
        self.CurrentTab = tab
    end
    
    table.insert(AscentUI.Windows, Window)
    return Window
end

-- DPI Management API
function AscentUI:SetDPIScale(scale)
    self.Settings.DPIScale = math.clamp(scale, 0.5, 2)
    
    -- Update all existing windows
    for _, window in ipairs(self.Windows) do
        -- Would need to recreate UI or scale existing elements
        warn("DPI scaling requires window recreation. Please recreate your windows after changing DPI.")
    end
end

function AscentUI:AutoDetectDPI()
    local dpi = Utils:CalculateDPI()
    self:SetDPIScale(dpi)
    return dpi
end

function AscentUI:GetDPIScale()
    return self.Settings.DPIScale
end

-- Theme Management
function AscentUI:SetTheme(themeName)
    if Themes[themeName] then
        self.Settings.Theme = themeName
        warn("Theme changes require window recreation. Please recreate your windows after changing theme.")
    else
        warn("Theme '" .. themeName .. "' not found!")
    end
end

function AscentUI:GetAvailableThemes()
    local themes = {}
    for name, _ in pairs(Themes) do
        table.insert(themes, name)
    end
    return themes
end

-- Settings System
function AscentUI:CreateSettingsTab(window)
    local SettingsTab = window:CreateTab({
        Name = "Settings",
        Icon = "⚙️"
    })
    
    local GeneralSection = SettingsTab:CreateSection("General Settings")
    
    GeneralSection:CreateLabel("UI Scale: Adjust the interface size")
    GeneralSection:CreateSlider({
        Name = "DPI Scale",
        Min = 50,
        Max = 200,
        Default = self.Settings.DPIScale * 100,
        Increment = 5,
        Callback = function(value)
            self:SetDPIScale(value / 100)
        end
    })
    
    GeneralSection:CreateToggle({
        Name = "Mobile Optimizations",
        Description = "Enable touch-friendly features",
        Default = self.Settings.MobileOptimizations,
        Callback = function(value)
            self.Settings.MobileOptimizations = value
        end
    })
    
    GeneralSection:CreateSlider({
        Name = "Animation Speed",
        Min = 0.1,
        Max = 1,
        Default = self.Settings.AnimationSpeed,
        Increment = 0.05,
        Callback = function(value)
            self.Settings.AnimationSpeed = value
        end
    })
    
    local ThemeSection = SettingsTab:CreateSection("Theme")
    
    ThemeSection:CreateDropdown({
        Name = "Theme",
        Options = self:GetAvailableThemes(),
        Default = self.Settings.Theme,
        Callback = function(value)
            self:SetTheme(value)
        end
    })
    
    return SettingsTab
end

-- Utility API
AscentUI.Utils = Utils

-- Notification System
function AscentUI:Notify(config)
    config = config or {}
    
    local notification = {
        Title = config.Title or "Notification",
        Description = config.Description or "",
        Duration = config.Duration or 3,
        Type = config.Type or "Info" -- Info, Success, Warning, Error
    }
    
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "AscentNotification"
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotificationGui.DisplayOrder = 999
    
    if gethui then
        NotificationGui.Parent = gethui()
    else
        NotificationGui.Parent = CoreGui
    end
    
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.AnchorPoint = Vector2.new(1, 0)
    NotificationFrame.Position = UDim2.new(1, Utils:ScaleSize(20), 0, Utils:ScaleSize(20))
    NotificationFrame.Size = UDim2.new(0, Utils:ScaleSize(300), 0, Utils:ScaleSize(80))
    NotificationFrame.BackgroundColor3 = AscentUI:GetTheme().Glass
    NotificationFrame.BackgroundTransparency = AscentUI:GetTheme().GlassTransparency
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = NotificationGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, Utils:ScaleSize(16))
    NotifCorner.Parent = NotificationFrame
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = Color3.fromRGB(255, 255, 255)
    NotifStroke.Transparency = 0.6
    NotifStroke.Thickness = 1
    NotifStroke.Parent = NotificationFrame
    
    local typeColors = {
        Info = AscentUI:GetTheme().Primary,
        Success = AscentUI:GetTheme().Success,
        Warning = AscentUI:GetTheme().Warning,
        Error = AscentUI:GetTheme().Danger
    }
    
    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(0, Utils:ScaleSize(4), 1, 0)
    AccentBar.BackgroundColor3 = typeColors[notification.Type] or AscentUI:GetTheme().Primary
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = NotificationFrame
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, Utils:ScaleSize(16))
    BarCorner.Parent = AccentBar
    
    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Position = UDim2.new(0, Utils:ScaleSize(16), 0, Utils:ScaleSize(12))
    NotifTitle.Size = UDim2.new(1, Utils:ScaleSize(-32), 0, Utils:ScaleSize(20))
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = notification.Title
    NotifTitle.TextColor3 = AscentUI:GetTheme().TextPrimary
    NotifTitle.TextSize = Utils:ScaleSize(15)
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.Parent = NotificationFrame
    
    local NotifDesc = Instance.new("TextLabel")
    NotifDesc.Position = UDim2.new(0, Utils:ScaleSize(16), 0, Utils:ScaleSize(36))
    NotifDesc.Size = UDim2.new(1, Utils:ScaleSize(-32), 0, Utils:ScaleSize(32))
    NotifDesc.BackgroundTransparency = 1
    NotifDesc.Text = notification.Description
    NotifDesc.TextColor3 = AscentUI:GetTheme().TextSecondary
    NotifDesc.TextSize = Utils:ScaleSize(13)
    NotifDesc.Font = Enum.Font.Gotham
    NotifDesc.TextXAlignment = Enum.TextXAlignment.Left
    NotifDesc.TextYAlignment = Enum.TextYAlignment.Top
    NotifDesc.TextWrapped = true
    NotifDesc.Parent = NotificationFrame
    
    -- Animate in
    NotificationFrame.Position = UDim2.new(1, Utils:ScaleSize(320), 0, Utils:ScaleSize(20))
    Utils:Tween(NotificationFrame, {
        Position = UDim2.new(1, Utils:ScaleSize(-20), 0, Utils:ScaleSize(20))
    }, 0.4, Enum.EasingStyle.Back)
    
    -- Animate out after duration
    task.delay(notification.Duration, function()
        Utils:Tween(NotificationFrame, {
            Position = UDim2.new(1, Utils:ScaleSize(320), 0, Utils:ScaleSize(20))
        }, 0.3).Completed:Connect(function()
            NotificationGui:Destroy()
        end)
    end)
end

-- Initialize
if Utils:IsMobile() and AscentUI.Settings.MobileOptimizations then
    AscentUI.Settings.DPIScale = Utils:CalculateDPI()
end

return AscentUI
