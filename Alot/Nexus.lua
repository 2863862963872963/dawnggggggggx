--[[
    NEXUS UI Library for Roblox
    A modern, glassmorphic UI library with advanced components
    Converted from HTML/CSS design
]]

local Nexus = {}
Nexus.__index = Nexus

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Theme Configuration
Nexus.Theme = {
    AccentPrimary = Color3.fromRGB(255, 51, 102),
    AccentSecondary = Color3.fromRGB(0, 255, 204),
    AccentWarning = Color3.fromRGB(255, 170, 0),
    GlassSidebar = Color3.fromRGB(15, 15, 25),
    GlassMain = Color3.fromRGB(20, 20, 35),
    GlassCard = Color3.fromRGB(25, 25, 40),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(156, 163, 175),
    TextDim = Color3.fromRGB(107, 114, 128),
    StatusOnline = Color3.fromRGB(0, 255, 136),
    StatusWarning = Color3.fromRGB(255, 170, 0),
    BackgroundTransparency = 0.25,
    SidebarTransparency = 0.15,
    CardTransparency = 0.35
}

-- Utility Functions
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.92
    stroke.Parent = parent
    return stroke
end

local function CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    gradient.Rotation = rotation or 135
    gradient.Parent = parent
    return gradient
end

local function Tween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Create Main Window
function Nexus:CreateWindow(config)
    config = config or {}
    local window = {
        Title = config.Title or "NEXUS",
        Subtitle = config.Subtitle or "ADVANCED UI",
        CurrentTab = nil,
        Tabs = {},
        Callbacks = {}
    }
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Main Frame (Window Container)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 1200, 0, 750)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Nexus.Theme.GlassMain
    mainFrame.BackgroundTransparency = Nexus.Theme.BackgroundTransparency
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    CreateCorner(mainFrame, 20)
    CreateStroke(mainFrame, Color3.fromRGB(255, 255, 255), 1, 0.92)
    
    -- Glow Effect
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(2, 0, 2, 0)
    glow.Position = UDim2.new(-0.5, 0, -0.5, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4996891970"
    glow.ImageColor3 = Nexus.Theme.AccentPrimary
    glow.ImageTransparency = 0.5
    glow.ZIndex = 0
    glow.Parent = mainFrame
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 280, 1, 0)
    sidebar.BackgroundColor3 = Nexus.Theme.GlassSidebar
    sidebar.BackgroundTransparency = Nexus.Theme.SidebarTransparency
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    CreateStroke(sidebar, Color3.fromRGB(255, 255, 255), 1, 0.92)
    
    -- Sidebar Header
    local sidebarHeader = Instance.new("Frame")
    sidebarHeader.Name = "Header"
    sidebarHeader.Size = UDim2.new(1, 0, 0, 100)
    sidebarHeader.BackgroundTransparency = 1
    sidebarHeader.Parent = sidebar
    
    -- Logo Container
    local logoContainer = Instance.new("Frame")
    logoContainer.Name = "Logo"
    logoContainer.Size = UDim2.new(1, -40, 0, 60)
    logoContainer.Position = UDim2.new(0, 20, 0, 10)
    logoContainer.BackgroundTransparency = 1
    logoContainer.Parent = sidebarHeader
    
    -- Logo Icon
    local logoIcon = Instance.new("Frame")
    logoIcon.Name = "Icon"
    logoIcon.Size = UDim2.new(0, 42, 0, 42)
    logoIcon.BackgroundColor3 = Nexus.Theme.AccentPrimary
    logoIcon.BorderSizePixel = 0
    logoIcon.Parent = logoContainer
    
    CreateCorner(logoIcon, 12)
    CreateGradient(logoIcon, Nexus.Theme.AccentPrimary, Nexus.Theme.AccentSecondary, 135)
    
    local logoIconText = Instance.new("TextLabel")
    logoIconText.Size = UDim2.new(1, 0, 1, 0)
    logoIconText.BackgroundTransparency = 1
    logoIconText.Text = "N"
    logoIconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoIconText.Font = Enum.Font.GothamBold
    logoIconText.TextSize = 24
    logoIconText.Parent = logoIcon
    
    -- Logo Text
    local logoTitle = Instance.new("TextLabel")
    logoTitle.Name = "Title"
    logoTitle.Size = UDim2.new(1, -54, 0, 25)
    logoTitle.Position = UDim2.new(0, 54, 0, 0)
    logoTitle.BackgroundTransparency = 1
    logoTitle.Text = window.Title
    logoTitle.TextColor3 = Nexus.Theme.AccentPrimary
    logoTitle.Font = Enum.Font.GothamBold
    logoTitle.TextSize = 22
    logoTitle.TextXAlignment = Enum.TextXAlignment.Left
    logoTitle.Parent = logoContainer
    
    local logoSubtitle = Instance.new("TextLabel")
    logoSubtitle.Name = "Subtitle"
    logoSubtitle.Size = UDim2.new(1, -54, 0, 15)
    logoSubtitle.Position = UDim2.new(0, 54, 0, 27)
    logoSubtitle.BackgroundTransparency = 1
    logoSubtitle.Text = window.Subtitle
    logoSubtitle.TextColor3 = Nexus.Theme.TextMuted
    logoSubtitle.Font = Enum.Font.GothamBold
    logoSubtitle.TextSize = 10
    logoSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    logoSubtitle.Parent = logoContainer
    
    -- Status Bar
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, -40, 0, 30)
    statusBar.Position = UDim2.new(0, 20, 0, 65)
    statusBar.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    statusBar.BackgroundTransparency = 0.9
    statusBar.BorderSizePixel = 0
    statusBar.Parent = sidebarHeader
    
    CreateCorner(statusBar, 8)
    CreateStroke(statusBar, Color3.fromRGB(0, 255, 136), 1, 0.7)
    
    local statusDot = Instance.new("Frame")
    statusDot.Name = "Dot"
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0, 12, 0.5, -4)
    statusDot.BackgroundColor3 = Nexus.Theme.StatusOnline
    statusDot.BorderSizePixel = 0
    statusDot.Parent = statusBar
    
    CreateCorner(statusDot, 4)
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -32, 1, 0)
    statusText.Position = UDim2.new(0, 28, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "SYSTEM ACTIVE"
    statusText.TextColor3 = Nexus.Theme.StatusOnline
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 11
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar
    
    -- Navigation Container
    local navContainer = Instance.new("ScrollingFrame")
    navContainer.Name = "Navigation"
    navContainer.Size = UDim2.new(1, 0, 1, -110)
    navContainer.Position = UDim2.new(0, 0, 0, 110)
    navContainer.BackgroundTransparency = 1
    navContainer.BorderSizePixel = 0
    navContainer.ScrollBarThickness = 4
    navContainer.ScrollBarImageColor3 = Nexus.Theme.AccentPrimary
    navContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    navContainer.Parent = sidebar
    
    local navLayout = Instance.new("UIListLayout")
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 4)
    navLayout.Parent = navContainer
    
    local navPadding = Instance.new("UIPadding")
    navPadding.PaddingLeft = UDim.new(0, 15)
    navPadding.PaddingRight = UDim.new(0, 15)
    navPadding.PaddingTop = UDim.new(0, 15)
    navPadding.PaddingBottom = UDim.new(0, 15)
    navPadding.Parent = navContainer
    
    -- Main Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "Content"
    contentArea.Size = UDim2.new(1, -280, 1, 0)
    contentArea.Position = UDim2.new(0, 280, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame
    
    -- Content Header
    local contentHeader = Instance.new("Frame")
    contentHeader.Name = "Header"
    contentHeader.Size = UDim2.new(1, 0, 0, 70)
    contentHeader.BackgroundTransparency = 1
    contentHeader.Parent = contentArea
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Name = "PageTitle"
    pageTitle.Size = UDim2.new(1, -40, 1, 0)
    pageTitle.Position = UDim2.new(0, 30, 0, 0)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "Dashboard"
    pageTitle.TextColor3 = Nexus.Theme.TextMain
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextSize = 28
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.TextYAlignment = Enum.TextYAlignment.Center
    pageTitle.Parent = contentHeader
    
    -- Tabs Container
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(1, 0, 1, -70)
    tabsContainer.Position = UDim2.new(0, 0, 0, 70)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = contentArea
    
    window.ScreenGui = screenGui
    window.MainFrame = mainFrame
    window.Sidebar = sidebar
    window.NavContainer = navContainer
    window.NavLayout = navLayout
    window.TabsContainer = tabsContainer
    window.PageTitle = pageTitle
    
    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    mainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Update canvas size when tabs are added
    navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        navContainer.CanvasSize = UDim2.new(0, 0, 0, navLayout.AbsoluteContentSize.Y + 30)
    end)
    
    setmetatable(window, Nexus)
    return window
end

-- Add Tab
function Nexus:AddTab(config)
    config = config or {}
    local tab = {
        Name = config.Name or "Tab",
        Icon = config.Icon or "🏠",
        Parent = self,
        Active = false,
        Sections = {}
    }
    
    -- Create Nav Button
    local navButton = Instance.new("TextButton")
    navButton.Name = tab.Name
    navButton.Size = UDim2.new(1, 0, 0, 44)
    navButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    navButton.BackgroundTransparency = 1
    navButton.BorderSizePixel = 0
    navButton.AutoButtonColor = false
    navButton.Text = ""
    navButton.Parent = self.NavContainer
    
    CreateCorner(navButton, 10)
    
    local navIcon = Instance.new("TextLabel")
    navIcon.Name = "Icon"
    navIcon.Size = UDim2.new(0, 20, 0, 20)
    navIcon.Position = UDim2.new(0, 15, 0.5, -10)
    navIcon.BackgroundTransparency = 1
    navIcon.Text = tab.Icon
    navIcon.TextColor3 = Nexus.Theme.TextMuted
    navIcon.Font = Enum.Font.GothamBold
    navIcon.TextSize = 18
    navIcon.Parent = navButton
    
    local navLabel = Instance.new("TextLabel")
    navLabel.Name = "Label"
    navLabel.Size = UDim2.new(1, -50, 1, 0)
    navLabel.Position = UDim2.new(0, 45, 0, 0)
    navLabel.BackgroundTransparency = 1
    navLabel.Text = tab.Name
    navLabel.TextColor3 = Nexus.Theme.TextMuted
    navLabel.Font = Enum.Font.GothamSemibold
    navLabel.TextSize = 14
    navLabel.TextXAlignment = Enum.TextXAlignment.Left
    navLabel.Parent = navButton
    
    -- Create Tab Content
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = tab.Name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.Visible = false
    tabContent.ScrollBarThickness = 6
    tabContent.ScrollBarImageColor3 = Nexus.Theme.AccentPrimary
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.Parent = self.TabsContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 20)
    contentLayout.Parent = tabContent
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 30)
    contentPadding.PaddingRight = UDim.new(0, 30)
    contentPadding.PaddingTop = UDim.new(0, 20)
    contentPadding.PaddingBottom = UDim.new(0, 30)
    contentPadding.Parent = tabContent
    
    -- Update canvas size
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 50)
    end)
    
    tab.NavButton = navButton
    tab.Content = tabContent
    tab.Layout = contentLayout
    
    -- Hover Effects
    navButton.MouseEnter:Connect(function()
        if not tab.Active then
            Tween(navButton, {BackgroundTransparency = 0.95}, 0.2)
        end
    end)
    
    navButton.MouseLeave:Connect(function()
        if not tab.Active then
            Tween(navButton, {BackgroundTransparency = 1}, 0.2)
        end
    end)
    
    -- Click Handler
    navButton.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Auto-select first tab
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

-- Select Tab
function Nexus:SelectTab(tab)
    -- Deselect all tabs
    for _, t in ipairs(self.Tabs) do
        t.Active = false
        t.Content.Visible = false
        Tween(t.NavButton, {BackgroundTransparency = 1}, 0.2)
        t.NavButton.Icon.TextColor3 = Nexus.Theme.TextMuted
        t.NavButton.Label.TextColor3 = Nexus.Theme.TextMuted
    end
    
    -- Select new tab
    tab.Active = true
    tab.Content.Visible = true
    Tween(tab.NavButton, {BackgroundTransparency = 0.95}, 0.2)
    tab.NavButton.Icon.TextColor3 = Nexus.Theme.AccentPrimary
    tab.NavButton.Label.TextColor3 = Nexus.Theme.TextMain
    
    self.CurrentTab = tab
    self.PageTitle.Text = tab.Name
end

-- Add Section to Tab
function Nexus:AddSection(tab, config)
    config = config or {}
    local section = {
        Title = config.Title or "Section",
        Icon = config.Icon or "⚙️",
        Elements = {}
    }
    
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = section.Title
    sectionFrame.Size = UDim2.new(1, 0, 0, 0)
    sectionFrame.BackgroundColor3 = Nexus.Theme.GlassCard
    sectionFrame.BackgroundTransparency = Nexus.Theme.CardTransparency
    sectionFrame.BorderSizePixel = 0
    sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    sectionFrame.Parent = tab.Content
    
    CreateCorner(sectionFrame, 16)
    CreateStroke(sectionFrame, Color3.fromRGB(255, 255, 255), 1, 0.92)
    
    -- Section Header
    local sectionHeader = Instance.new("Frame")
    sectionHeader.Name = "Header"
    sectionHeader.Size = UDim2.new(1, 0, 0, 50)
    sectionHeader.BackgroundTransparency = 1
    sectionHeader.Parent = sectionFrame
    
    local headerIcon = Instance.new("TextLabel")
    headerIcon.Size = UDim2.new(0, 20, 0, 20)
    headerIcon.Position = UDim2.new(0, 20, 0, 15)
    headerIcon.BackgroundTransparency = 1
    headerIcon.Text = section.Icon
    headerIcon.TextColor3 = Nexus.Theme.AccentPrimary
    headerIcon.Font = Enum.Font.GothamBold
    headerIcon.TextSize = 18
    headerIcon.Parent = sectionHeader
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, -50, 1, 0)
    headerTitle.Position = UDim2.new(0, 50, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = section.Title
    headerTitle.TextColor3 = Nexus.Theme.TextMain
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextSize = 16
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = sectionHeader
    
    -- Elements Container
    local elementsContainer = Instance.new("Frame")
    elementsContainer.Name = "Elements"
    elementsContainer.Size = UDim2.new(1, 0, 0, 0)
    elementsContainer.Position = UDim2.new(0, 0, 0, 50)
    elementsContainer.BackgroundTransparency = 1
    elementsContainer.AutomaticSize = Enum.AutomaticSize.Y
    elementsContainer.Parent = sectionFrame
    
    local elementsLayout = Instance.new("UIListLayout")
    elementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    elementsLayout.Padding = UDim.new(0, 0)
    elementsLayout.Parent = elementsContainer
    
    local elementsPadding = Instance.new("UIPadding")
    elementsPadding.PaddingLeft = UDim.new(0, 20)
    elementsPadding.PaddingRight = UDim.new(0, 20)
    elementsPadding.PaddingBottom = UDim.new(0, 15)
    elementsPadding.Parent = elementsContainer
    
    section.Frame = sectionFrame
    section.Container = elementsContainer
    
    table.insert(tab.Sections, section)
    return section
end

-- Add Toggle
function Nexus:AddToggle(section, config)
    config = config or {}
    local toggle = {
        Title = config.Title or "Toggle",
        Description = config.Description or "",
        Default = config.Default or false,
        Callback = config.Callback or function() end
    }
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, 60)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = section.Container
    
    local toggleLabel = Instance.new("Frame")
    toggleLabel.Size = UDim2.new(1, -70, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Parent = toggleFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = toggle.Title
    title.TextColor3 = Nexus.Theme.TextMain
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = toggleLabel
    
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, 0, 0, 16)
    description.Position = UDim2.new(0, 0, 0, 32)
    description.BackgroundTransparency = 1
    description.Text = toggle.Description
    description.TextColor3 = Nexus.Theme.TextMuted
    description.Font = Enum.Font.Gotham
    description.TextSize = 12
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Parent = toggleLabel
    
    -- Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 26)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -13)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = false
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    CreateCorner(toggleButton, 13)
    
    local toggleThumb = Instance.new("Frame")
    toggleThumb.Name = "Thumb"
    toggleThumb.Size = UDim2.new(0, 20, 0, 20)
    toggleThumb.Position = UDim2.new(0, 3, 0.5, -10)
    toggleThumb.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    toggleThumb.BorderSizePixel = 0
    toggleThumb.Parent = toggleButton
    
    CreateCorner(toggleThumb, 10)
    
    toggle.Button = toggleButton
    toggle.Thumb = toggleThumb
    toggle.Value = toggle.Default
    
    local function UpdateToggle(value, silent)
        toggle.Value = value
        if value then
            Tween(toggleButton, {BackgroundColor3 = Nexus.Theme.AccentPrimary}, 0.2)
            Tween(toggleThumb, {Position = UDim2.new(1, -23, 0.5, -10)}, 0.2)
        else
            Tween(toggleButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, 0.2)
            Tween(toggleThumb, {Position = UDim2.new(0, 3, 0.5, -10)}, 0.2)
        end
        
        if not silent then
            task.spawn(function()
                toggle.Callback(value)
            end)
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        UpdateToggle(not toggle.Value)
    end)
    
    -- Initialize
    UpdateToggle(toggle.Default, true)
    
    toggle.SetValue = UpdateToggle
    return toggle
end

-- Add Slider
function Nexus:AddSlider(section, config)
    config = config or {}
    local slider = {
        Title = config.Title or "Slider",
        Description = config.Description or "",
        Min = config.Min or 0,
        Max = config.Max or 100,
        Default = config.Default or 50,
        Increment = config.Increment or 1,
        Suffix = config.Suffix or "",
        Callback = config.Callback or function() end
    }
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "Slider"
    sliderFrame.Size = UDim2.new(1, 0, 0, 75)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = section.Container
    
    local sliderLabel = Instance.new("Frame")
    sliderLabel.Size = UDim2.new(1, 0, 0, 35)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Parent = sliderFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = slider.Title
    title.TextColor3 = Nexus.Theme.TextMain
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = sliderLabel
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 60, 1, 0)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = slider.Default .. slider.Suffix
    valueLabel.TextColor3 = Nexus.Theme.AccentPrimary
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderLabel
    
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, 0, 0, 16)
    description.Position = UDim2.new(0, 0, 0, 20)
    description.BackgroundTransparency = 1
    description.Text = slider.Description
    description.TextColor3 = Nexus.Theme.TextMuted
    description.Font = Enum.Font.Gotham
    description.TextSize = 11
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Parent = sliderLabel
    
    -- Slider Track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 45)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    
    CreateCorner(sliderTrack, 3)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = Nexus.Theme.AccentPrimary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    CreateCorner(sliderFill, 3)
    
    local sliderThumb = Instance.new("Frame")
    sliderThumb.Name = "Thumb"
    sliderThumb.Size = UDim2.new(0, 16, 0, 16)
    sliderThumb.Position = UDim2.new(0.5, -8, 0.5, -8)
    sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderThumb.BorderSizePixel = 0
    sliderThumb.Parent = sliderTrack
    
    CreateCorner(sliderThumb, 8)
    
    slider.Track = sliderTrack
    slider.Fill = sliderFill
    slider.Thumb = sliderThumb
    slider.ValueLabel = valueLabel
    slider.Value = slider.Default
    
    local dragging = false
    
    local function UpdateSlider(value, silent)
        value = math.clamp(value, slider.Min, slider.Max)
        value = math.floor(value / slider.Increment + 0.5) * slider.Increment
        slider.Value = value
        
        local percent = (value - slider.Min) / (slider.Max - slider.Min)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderThumb.Position = UDim2.new(percent, -8, 0.5, -8)
        valueLabel.Text = tostring(value) .. slider.Suffix
        
        if not silent then
            task.spawn(function()
                slider.Callback(value)
            end)
        end
    end
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percent = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            local value = slider.Min + (slider.Max - slider.Min) * percent
            UpdateSlider(value)
        end
    end)
    
    sliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            local value = slider.Min + (slider.Max - slider.Min) * percent
            UpdateSlider(value)
        end
    end)
    
    -- Initialize
    UpdateSlider(slider.Default, true)
    
    slider.SetValue = UpdateSlider
    return slider
end

-- Add Dropdown
function Nexus:AddDropdown(section, config)
    config = config or {}
    local dropdown = {
        Title = config.Title or "Dropdown",
        Description = config.Description or "",
        Options = config.Options or {"Option 1", "Option 2"},
        Default = config.Default or config.Options[1],
        Callback = config.Callback or function() end
    }
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 90)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = section.Container
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = dropdown.Title
    title.TextColor3 = Nexus.Theme.TextMain
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = dropdownFrame
    
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, 0, 0, 16)
    description.Position = UDim2.new(0, 0, 0, 22)
    description.BackgroundTransparency = 1
    description.Text = dropdown.Description
    description.TextColor3 = Nexus.Theme.TextMuted
    description.Font = Enum.Font.Gotham
    description.TextSize = 11
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Parent = dropdownFrame
    
    -- Dropdown Button
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 0, 40)
    dropdownButton.Position = UDim2.new(0, 0, 0, 45)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    dropdownButton.BackgroundTransparency = 0.3
    dropdownButton.BorderSizePixel = 0
    dropdownButton.AutoButtonColor = false
    dropdownButton.Text = ""
    dropdownButton.Parent = dropdownFrame
    
    CreateCorner(dropdownButton, 10)
    CreateStroke(dropdownButton, Color3.fromRGB(255, 255, 255), 1, 0.92)
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(1, -50, 1, 0)
    selectedLabel.Position = UDim2.new(0, 15, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = dropdown.Default
    selectedLabel.TextColor3 = Nexus.Theme.TextMain
    selectedLabel.Font = Enum.Font.GothamSemibold
    selectedLabel.TextSize = 13
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.Parent = dropdownButton
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Nexus.Theme.TextMuted
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 10
    arrow.Parent = dropdownButton
    
    -- Dropdown Menu
    local dropdownMenu = Instance.new("Frame")
    dropdownMenu.Name = "Menu"
    dropdownMenu.Size = UDim2.new(1, 0, 0, 0)
    dropdownMenu.Position = UDim2.new(0, 0, 1, 5)
    dropdownMenu.BackgroundColor3 = Nexus.Theme.GlassCard
    dropdownMenu.BackgroundTransparency = 0.1
    dropdownMenu.BorderSizePixel = 0
    dropdownMenu.Visible = false
    dropdownMenu.ZIndex = 10
    dropdownMenu.ClipsDescendants = true
    dropdownMenu.Parent = dropdownButton
    
    CreateCorner(dropdownMenu, 10)
    CreateStroke(dropdownMenu, Color3.fromRGB(255, 255, 255), 1, 0.92)
    
    local menuLayout = Instance.new("UIListLayout")
    menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    menuLayout.Padding = UDim.new(0, 2)
    menuLayout.Parent = dropdownMenu
    
    local menuPadding = Instance.new("UIPadding")
    menuPadding.PaddingLeft = UDim.new(0, 8)
    menuPadding.PaddingRight = UDim.new(0, 8)
    menuPadding.PaddingTop = UDim.new(0, 8)
    menuPadding.PaddingBottom = UDim.new(0, 8)
    menuPadding.Parent = dropdownMenu
    
    dropdown.Button = dropdownButton
    dropdown.Menu = dropdownMenu
    dropdown.Label = selectedLabel
    dropdown.Value = dropdown.Default
    dropdown.Open = false
    
    local function ToggleMenu()
        dropdown.Open = not dropdown.Open
        if dropdown.Open then
            local targetHeight = math.min(#dropdown.Options * 36 + 16, 200)
            dropdownMenu.Visible = true
            Tween(dropdownMenu, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
            Tween(arrow, {Rotation = 180}, 0.2)
        else
            Tween(dropdownMenu, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            Tween(arrow, {Rotation = 0}, 0.2)
            task.wait(0.2)
            dropdownMenu.Visible = false
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(ToggleMenu)
    
    -- Create option buttons
    for _, option in ipairs(dropdown.Options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 32)
        optionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.BackgroundTransparency = 1
        optionButton.BorderSizePixel = 0
        optionButton.AutoButtonColor = false
        optionButton.Text = option
        optionButton.TextColor3 = Nexus.Theme.TextMain
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextSize = 13
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.Parent = dropdownMenu
        
        CreateCorner(optionButton, 6)
        
        local optionPadding = Instance.new("UIPadding")
        optionPadding.PaddingLeft = UDim.new(0, 10)
        optionPadding.Parent = optionButton
        
        optionButton.MouseEnter:Connect(function()
            Tween(optionButton, {BackgroundTransparency = 0.9}, 0.1)
        end)
        
        optionButton.MouseLeave:Connect(function()
            Tween(optionButton, {BackgroundTransparency = 1}, 0.1)
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            dropdown.Value = option
            selectedLabel.Text = option
            ToggleMenu()
            task.spawn(function()
                dropdown.Callback(option)
            end)
        end)
    end
    
    return dropdown
end

-- Add Button
function Nexus:AddButton(section, config)
    config = config or {}
    local button = {
        Title = config.Title or "Button",
        Description = config.Description or "",
        Callback = config.Callback or function() end
    }
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "Button"
    buttonFrame.Size = UDim2.new(1, 0, 0, 60)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = section.Container
    
    local buttonLabel = Instance.new("Frame")
    buttonLabel.Size = UDim2.new(1, -120, 1, 0)
    buttonLabel.BackgroundTransparency = 1
    buttonLabel.Parent = buttonFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = button.Title
    title.TextColor3 = Nexus.Theme.TextMain
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = buttonLabel
    
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, 0, 0, 16)
    description.Position = UDim2.new(0, 0, 0, 32)
    description.BackgroundTransparency = 1
    description.Text = button.Description
    description.TextColor3 = Nexus.Theme.TextMuted
    description.Font = Enum.Font.Gotham
    description.TextSize = 12
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Parent = buttonLabel
    
    -- Action Button
    local actionButton = Instance.new("TextButton")
    actionButton.Size = UDim2.new(0, 110, 0, 36)
    actionButton.Position = UDim2.new(1, -110, 0.5, -18)
    actionButton.BackgroundColor3 = Nexus.Theme.AccentPrimary
    actionButton.BackgroundTransparency = 0
    actionButton.BorderSizePixel = 0
    actionButton.AutoButtonColor = false
    actionButton.Text = "Execute"
    actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionButton.Font = Enum.Font.GothamBold
    actionButton.TextSize = 13
    actionButton.Parent = buttonFrame
    
    CreateCorner(actionButton, 8)
    
    actionButton.MouseEnter:Connect(function()
        Tween(actionButton, {BackgroundColor3 = Color3.fromRGB(255, 71, 122)}, 0.2)
    end)
    
    actionButton.MouseLeave:Connect(function()
        Tween(actionButton, {BackgroundColor3 = Nexus.Theme.AccentPrimary}, 0.2)
    end)
    
    actionButton.MouseButton1Click:Connect(function()
        Tween(actionButton, {BackgroundColor3 = Color3.fromRGB(255, 31, 82)}, 0.1)
        task.wait(0.1)
        Tween(actionButton, {BackgroundColor3 = Nexus.Theme.AccentPrimary}, 0.2)
        
        task.spawn(function()
            button.Callback()
        end)
    end)
    
    return button
end

-- Add Keybind
function Nexus:AddKeybind(section, config)
    config = config or {}
    local keybind = {
        Title = config.Title or "Keybind",
        Description = config.Description or "",
        Default = config.Default or Enum.KeyCode.E,
        Callback = config.Callback or function() end
    }
    
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = "Keybind"
    keybindFrame.Size = UDim2.new(1, 0, 0, 60)
    keybindFrame.BackgroundTransparency = 1
    keybindFrame.Parent = section.Container
    
    local keybindLabel = Instance.new("Frame")
    keybindLabel.Size = UDim2.new(1, -100, 1, 0)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Parent = keybindFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = keybind.Title
    title.TextColor3 = Nexus.Theme.TextMain
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = keybindLabel
    
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, 0, 0, 16)
    description.Position = UDim2.new(0, 0, 0, 32)
    description.BackgroundTransparency = 1
    description.Text = keybind.Description
    description.TextColor3 = Nexus.Theme.TextMuted
    description.Font = Enum.Font.Gotham
    description.TextSize = 12
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Parent = keybindLabel
    
    -- Keybind Button
    local keybindButton = Instance.new("TextButton")
    keybindButton.Size = UDim2.new(0, 90, 0, 36)
    keybindButton.Position = UDim2.new(1, -90, 0.5, -18)
    keybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    keybindButton.BackgroundTransparency = 0.3
    keybindButton.BorderSizePixel = 0
    keybindButton.AutoButtonColor = false
    keybindButton.Text = keybind.Default.Name
    keybindButton.TextColor3 = Nexus.Theme.TextMain
    keybindButton.Font = Enum.Font.GothamBold
    keybindButton.TextSize = 12
    keybindButton.Parent = keybindFrame
    
    CreateCorner(keybindButton, 8)
    CreateStroke(keybindButton, Color3.fromRGB(255, 255, 255), 1, 0.92)
    
    keybind.Button = keybindButton
    keybind.Value = keybind.Default
    keybind.Listening = false
    
    keybindButton.MouseButton1Click:Connect(function()
        if keybind.Listening then return end
        keybind.Listening = true
        keybindButton.Text = "..."
        keybindButton.TextColor3 = Nexus.Theme.AccentPrimary
    end)
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
            keybind.Value = input.KeyCode
            keybindButton.Text = input.KeyCode.Name
            keybindButton.TextColor3 = Nexus.Theme.TextMain
            keybind.Listening = false
        end
    end)
    
    -- Listen for keybind activation
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == keybind.Value and not keybind.Listening then
            task.spawn(function()
                keybind.Callback()
            end)
        end
    end)
    
    return keybind
end

-- Add Label
function Nexus:AddLabel(section, config)
    config = config or {}
    local label = {
        Text = config.Text or "Label"
    }
    
    local labelFrame = Instance.new("Frame")
    labelFrame.Name = "Label"
    labelFrame.Size = UDim2.new(1, 0, 0, 35)
    labelFrame.BackgroundTransparency = 1
    labelFrame.Parent = section.Container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label.Text
    labelText.TextColor3 = Nexus.Theme.TextMuted
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.TextWrapped = true
    labelText.Parent = labelFrame
    
    label.Label = labelText
    
    function label:SetText(text)
        labelText.Text = text
    end
    
    return label
end

-- Destroy Window
function Nexus:Destroy()
    self.ScreenGui:Destroy()
end

return Nexus
