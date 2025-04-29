--[[
暗い kurai.
a sleek roblox ui library based around simplicity, modern design, and csgo inspired aesthetics.

created by @focat on discord - dm me before using any code from this commercially
licensed under Creative Commons Zero v.10 Universal (CC0 1.0) Public Domain Dedication
    > states that you may share/modify this code as you please, but NOT commercially
    > you also must give credit where it is due!

enjoy!
sorry for messy code :(
]]--

local Kurai_Lib = {}
Kurai_Lib.__index = Kurai_Lib

local TweenService = game:GetService("TweenService") -- ts pmo!!!!!!!!!
local UserInputService = game:GetService("UserInputService")

Kurai_Lib.Settings = {
    ToggleKey = Enum.KeyCode.RightControl,
    TogglingUI = false
}
Kurai_Lib.Flags = {}
Kurai_Lib.Theme = {
    Main = Color3.fromRGB(20, 20, 20),
    
    Tab = Color3.fromRGB(23, 23, 23),
    TabAccent = Color3.fromRGB(30, 30, 30),

    Content = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(253, 181, 181),
    
    Text = Color3.fromRGB(212, 212, 212),
    SubText = Color3.fromRGB(89, 89, 89)
}

function Kurai_Lib.Tween(obj, goal, time, style, direction)
    local tween = TweenService:Create(obj, TweenInfo.new(time or 0.5, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), goal)
    tween:Play()
    return tween
end

function Kurai_Lib.RippleEffect(btnInstance, color)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = color or Kurai_Lib.Theme.Accent
    ripple.BackgroundTransparency = 0.8
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.ZIndex = 10
    ripple.Parent = btnInstance
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local mouse = UserInputService:GetMouseLocation()
    local buttonPos = btnInstance.AbsolutePosition
    local relativeX = mouse.X - buttonPos.X
    local relativeY = mouse.Y - buttonPos.Y
    
    ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local targetSize = math.max(btnInstance.AbsoluteSize.X, btnInstance.AbsoluteSize.Y) * 2.5
    
    Kurai_Lib.Tween(ripple, {
        Size = UDim2.new(0, targetSize, 0, targetSize),
        Position = UDim2.new(0, relativeX, 0, relativeY),
        BackgroundTransparency = 1
    }, 0.5)
    
    game:GetService("Debris"):AddItem(ripple, 0.6)
end

function Kurai_Lib.new(options)
    options = options or {}
    local self = setmetatable({}, Kurai_Lib)
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = options.Name or "Kurai_Lib"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.DisplayOrder = 1000
    self.ScreenGui.Parent = gethui and gethui() or game:GetService("CoreGui")
    
    self.Notifications = {}
    self.Open = true
    
    self:_internal_createloader(options)
    return self
end

function Kurai_Lib:ToggleUI()

    if Kurai_Lib.Settings.TogglingUI then
        return
    end

    Kurai_Lib.Settings.TogglingUI = true
    self.Open = not self.Open
    
    if self.Open then
        self.MainWindow.Visible = true
        self.MainWindow.BackgroundTransparency = 1

        local startPos = UDim2.new(
            self.MainWindow.Position.X.Scale, 
            self.MainWindow.Position.X.Offset,
            1, 500
        )
        local targetPos = UDim2.new(
            0.5, -self.MainWindow.AbsoluteSize.X/2,
            0.5, -self.MainWindow.AbsoluteSize.Y/2
        )
        self.MainWindow.Position = startPos
        
        Kurai_Lib.Tween(self.MainWindow, {
            Position = targetPos,
            BackgroundTransparency = 0
        })
        Kurai_Lib.Settings.TogglingUI = false
    else
        local currentPos = self.MainWindow.Position
        
        local targetPos = UDim2.new(
            currentPos.X.Scale, 
            currentPos.X.Offset,
            1, 500
        )
        
        Kurai_Lib.Tween(self.MainWindow, {
            Position = targetPos,
            BackgroundTransparency = 1
        })
        task.wait(0.5) -- default tween time in .Tween lol
        Kurai_Lib.Settings.TogglingUI = false
        self.MainWindow.Visible = false
    end
end

function Kurai_Lib:Notify(props)
    props = props or {}
    local title = props.Title or "Notification"
    local message = props.Message or ""
    local duration = props.Duration or 5
    local notificationType = props.Type or "info"

    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 0)
    notification.Position = UDim2.new(1, -10, 1, 10) -- start below screen
    notification.AnchorPoint = Vector2.new(1, 1)
    notification.BackgroundColor3 = Kurai_Lib.Theme.Content
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.ZIndex = self.ScreenGui.DisplayOrder + 1
    notification.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = notification

    local accentColor = Kurai_Lib.Theme.Accent
    if notificationType == "success" then
        accentColor = Color3.fromRGB(76, 175, 80)
    elseif notificationType == "warn" then
        accentColor = Color3.fromRGB(255, 193, 7)
    elseif notificationType == "err" then
        accentColor = Color3.fromRGB(244, 67, 54)
    end

    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 3, 1, 0)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = notification.ZIndex + 1
    accentBar.Parent = notification

    local accentBarCorner = Instance.new("UICorner")
    accentBarCorner.CornerRadius = UDim.new(0, 4)
    accentBarCorner.Parent = accentBar

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 0) -- 0 for accent bar
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = notification

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -25, 0, 20)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Kurai_Lib.Theme.Text
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.RobotoMono
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = accentBar.ZIndex
    titleLabel.Parent = notification

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -25, 0, 0)
    messageLabel.Position = UDim2.new(0, 15, 0, 25)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Kurai_Lib.Theme.SubText
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.RobotoMono
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.ZIndex = accentBar.ZIndex
    messageLabel.Parent = notification

    local textService = game:GetService("TextService")
    local textSize = textService:GetTextSize(
        message,
        14,
        Enum.Font.RobotoMono,
        Vector2.new(265, math.huge)
    )
    
    messageLabel.Size = UDim2.new(1, -25, 0, textSize.Y)
    notification.Size = UDim2.new(0, 300, 0, textSize.Y + 45)

    Kurai_Lib.Tween(notification, {
        Position = UDim2.new(1, -10, 1, -10)
    }, 0.3)

    local totalHeight = notification.AbsoluteSize.Y + 10
    for _, existingNotif in next, self.Notifications do
        if existingNotif and existingNotif.Parent then
            local currentPos = existingNotif.Position
            Kurai_Lib.Tween(existingNotif, {
                Position = UDim2.new(
                    currentPos.X.Scale, currentPos.X.Offset,
                    currentPos.Y.Scale, currentPos.Y.Offset - totalHeight
                )
            }, 0.3)
        end
    end

    table.insert(self.Notifications, notification)
    task.spawn(function()
        task.wait(duration)
        
        Kurai_Lib.Tween(notification, {
            BackgroundTransparency = 1
        }, 0.3)
        
        Kurai_Lib.Tween(titleLabel, {
            TextTransparency = 1
        }, 0.3)
        
        Kurai_Lib.Tween(messageLabel, {
            TextTransparency = 1
        }, 0.3)
        
        Kurai_Lib.Tween(accentBar, {
            BackgroundTransparency = 1
        }, 0.3)
        
        task.wait(0.3)
        
        for i, notif in next, self.Notifications do
            if notif == notification then
                table.remove(self.Notifications, i)
                break
            end
        end
        
        for _, remainingNotif in next, self.Notifications do
            if remainingNotif and remainingNotif.Parent then
                local currentPos = remainingNotif.Position
                Kurai_Lib.Tween(remainingNotif, {
                    Position = UDim2.new(
                        currentPos.X.Scale, currentPos.X.Offset,
                        currentPos.Y.Scale, currentPos.Y.Offset + totalHeight
                    )
                }, 0.3)
            end
        end
        
        notification:Destroy()
    end)
    
    return notification
end

function Kurai_Lib:_internal_createloader(options)
    self.Loader = Instance.new("Frame")
    self.Loader.Name = "Loader"
    self.Loader.BackgroundColor3 = Kurai_Lib.Theme.Main
    self.Loader.BorderSizePixel = 0
    self.Loader.Position = UDim2.new(0.5, -150, 0.5, -150)
    self.Loader.Size = UDim2.new(0, 300, 0, 300)
    self.Loader.Visible = false
    self.Loader.Parent = self.ScreenGui
    
    -- [ Loader elements (status bar, text, etc) ]
    self.LoaderBar = Instance.new("Frame")
    self.LoaderBar.Name = "LoaderBar"
    self.LoaderBar.BackgroundColor3 = Kurai_Lib.Theme.Accent
    self.LoaderBar.BorderSizePixel = 0
    self.LoaderBar.Size = UDim2.new(0, 300, 0, 1)
    self.LoaderBar.Parent = self.Loader
    -- [ gay rainbow ]
    Kurai_Lib.Rainbow(self.LoaderBar, 0.5)
    
    self.StatusText = Instance.new("TextLabel")
    self.StatusText.Name = "StatusText"
    self.StatusText.Font = Enum.Font.RobotoMono
    self.StatusText.Text = "initializing..."
    self.StatusText.TextColor3 = Kurai_Lib.Theme.SubText
    self.StatusText.TextSize = 14
    self.StatusText.BackgroundTransparency = 1
    self.StatusText.Position = UDim2.new(0.5, -150, 0.1, 0)
    self.StatusText.Size = UDim2.new(0, 300, 0, 21)
    self.StatusText.Parent = self.Loader

    self.LoaderLogo = Instance.new("ImageLabel")
    self.LoaderLogo.Image = "rbxassetid://108502703403650"
    self.LoaderLogo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.LoaderLogo.BackgroundTransparency = 1
    self.LoaderLogo.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.LoaderLogo.BorderSizePixel = 0
    self.LoaderLogo.Position = UDim2.new(0.416666657, -100, 0.416666657, -100)
    self.LoaderLogo.Size = UDim2.new(0, 250, 0, 250)
    self.LoaderLogo.Parent = self.Loader

    self.LoaderCredits = Instance.new("TextLabel")
    self.LoaderCredits.Font = Enum.Font.RobotoMono
    self.LoaderCredits.Text = "暗い - kurai."
    self.LoaderCredits.TextColor3 = Color3.fromRGB(89.00000229477882, 89.00000229477882, 89.00000229477882)
    self.LoaderCredits.TextSize = 12
    self.LoaderCredits.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.LoaderCredits.BackgroundTransparency = 1
    self.LoaderCredits.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.LoaderCredits.BorderSizePixel = 0
    self.LoaderCredits.Position = UDim2.new(0.5, -150, 0.906666696, 0)
    self.LoaderCredits.Size = UDim2.new(0, 300, 0, 21)
    self.LoaderCredits.Name = "credits"
    self.LoaderCredits.Parent = self.Loader
    
    self:_internal_initload(options)
end

function Kurai_Lib:_internal_initload(options)
    self.Loader.Visible = true
    Kurai_Lib.Tween(self.Loader, {BackgroundTransparency = 0})
    
    -- ts pmo (doesnt do anything related to version checking YET...)
    self:_internal_setloaderstatus("fetching version...")
    task.wait(0.5)
    
    self:_internal_setloaderstatus("comparing local <-> remote...")
    task.wait(1)
    
    self:_internal_setloaderstatus("remote == local")
    task.wait(1)
    
    self:_internal_setloaderstatus("loading components...")
    task.wait(2)
    
    self:_internal_setloaderstatus("initializing UI...")
    task.wait(1)
    
    self:_internal_createmainwindow(options)
    
    Kurai_Lib.Tween(self.Loader, {BackgroundTransparency = 1})
    -- [ fade out all text, images, frames ]
    for _, child in next, self.Loader:GetDescendants() do
        if child:IsA("GuiObject") then
            Kurai_Lib.Tween(child, {BackgroundTransparency = 1})
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                Kurai_Lib.Tween(child, {TextTransparency = 1})
            end
            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                Kurai_Lib.Tween(child, {ImageTransparency = 1})
            end
        end
    end

    task.wait(0.5)
    self.Loader.Visible = false
end

function Kurai_Lib:_internal_setloaderstatus(text)
    self.StatusText.Text = text
end

function Kurai_Lib:_internal_createmainwindow(options)
    self.MainWindow = Instance.new("Frame")
    self.MainWindow.Name = "MainWindow"
    self.MainWindow.Size = UDim2.new(0, 500, 0, 500)
    self.MainWindow.Position = UDim2.new(0.5, -250, 0.5, -250)
    self.MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainWindow.BackgroundColor3 = Kurai_Lib.Theme.Main
    self.MainWindow.BorderSizePixel = 0
    self.MainWindow.ClipsDescendants = true
    self.MainWindow.Parent = self.ScreenGui
    
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 53)
    self.TitleBar.BackgroundTransparency = 1
    self.TitleBar.Parent = self.MainWindow
    
    self.TitleAccent = Instance.new("Frame")
    self.TitleAccent.Name = "TitleAccent"
    self.TitleAccent.BackgroundColor3 = Kurai_Lib.Theme.Accent
    self.TitleAccent.BorderSizePixel = 0
    self.TitleAccent.Size = UDim2.new(1, 0, 0, 1)
    self.TitleAccent.Parent = self.TitleBar
    
    self.GameTitle = Instance.new("TextLabel")
    self.GameTitle.Name = "GameTitle"
    self.GameTitle.Font = Enum.Font.RobotoMono
    self.GameTitle.Text = options.GameName or "[GAME NAME]"
    self.GameTitle.TextColor3 = Kurai_Lib.Theme.Text
    self.GameTitle.TextSize = 18
    self.GameTitle.TextXAlignment = Enum.TextXAlignment.Left
    self.GameTitle.BackgroundTransparency = 1
    self.GameTitle.Position = UDim2.new(0.43, -150, 0.44, -9)
    self.GameTitle.Size = UDim2.new(0, 300, 0, 18)
    self.GameTitle.Parent = self.TitleBar

    self.LogoIcon = Instance.new("ImageLabel")
    self.LogoIcon.Image = "rbxassetid://108502703403650"
    self.LogoIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.LogoIcon.BackgroundTransparency = 1
    self.LogoIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.LogoIcon.BorderSizePixel = 0
    self.LogoIcon.Position = UDim2.new(0.0659999996, -25, 0.613207519, -25)
    self.LogoIcon.Size = UDim2.new(0, 50, 0, 50)
    self.LogoIcon.Name = "icon"
    self.LogoIcon.Parent = self.TitleBar
    
    self.ScriptHubName = Instance.new("TextLabel")
    self.ScriptHubName.Name = "ScriptHubName"
    self.ScriptHubName.Font = Enum.Font.RobotoMono
    self.ScriptHubName.Text = options.ScriptHubName or "JEWISH SCRIPT HUB"
    self.ScriptHubName.TextColor3 = Kurai_Lib.Theme.SubText
    self.ScriptHubName.TextSize = 18
    self.ScriptHubName.TextXAlignment = Enum.TextXAlignment.Left
    self.ScriptHubName.BackgroundTransparency = 1
    self.ScriptHubName.Position = UDim2.new(0.43, -150, 0.78, -9)
    self.ScriptHubName.Size = UDim2.new(0, 300, 0, 18)
    self.ScriptHubName.Parent = self.TitleBar
    
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, 0, 0, 35)
    self.TabContainer.Position = UDim2.new(0, 0, 0.12, 0)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainWindow
    
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -20, 1, -100)
    self.ContentContainer.Position = UDim2.new(0, 10, 0, 95)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = self.MainWindow
    
    self:InitTabs(options.Tabs or {"Main", "Visuals", "Settings"})

    -- [ toggle key ]
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Kurai_Lib.Settings.ToggleKey then
            self:ToggleUI()
        end
    end)

    -- [ make draggable ]
    self:Draggable(self.MainWindow, self.TitleBar)
end

function Kurai_Lib:SetToggleKeybind(keyCode)
    if keyCode and table.find(Enum.KeyCode:GetEnumItems(), keyCode) then
        Kurai_Lib.Settings.ToggleKey = keyCode
    else
        warn("[Kurai] Invalid keybind!")
    end
end

function Kurai_Lib:Draggable(frame, handle)
    local dragStartPos, frameStartPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStartPos = input.Position
            frameStartPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStartPos = nil
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStartPos then
            local delta = input.Position - dragStartPos
            frame.Position = UDim2.new(
                frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Kurai_Lib:InitTabs(tabNames)
    self.Tabs = {}
    self.CurrentTab = nil
    
    local tabButtonsContainer = Instance.new("ScrollingFrame")
    tabButtonsContainer.Name = "TabButtons"
    tabButtonsContainer.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabButtonsContainer.ScrollBarThickness = 0
    tabButtonsContainer.ScrollingDirection = Enum.ScrollingDirection.X
    tabButtonsContainer.BackgroundTransparency = 1
    tabButtonsContainer.BorderSizePixel = 0
    tabButtonsContainer.Size = UDim2.new(1, 0, 1, 0)
    tabButtonsContainer.Parent = self.TabContainer
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.FillDirection = Enum.FillDirection.Horizontal
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Parent = tabButtonsContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 10)
    tabPadding.PaddingRight = UDim.new(0, 10)
    tabPadding.Parent = tabButtonsContainer
    
    for i, tabName in next, tabNames do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Text = tabName
        tabButton.Font = Enum.Font.RobotoMono
        tabButton.TextColor3 = Kurai_Lib.Theme.Text
        tabButton.TextSize = 14
        tabButton.BackgroundColor3 = Kurai_Lib.Theme.Tab
        tabButton.Size = UDim2.new(0.23, 0, 0, 34)
        tabButton.LayoutOrder = i
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = tabButton
        
        tabButton.Parent = tabButtonsContainer
        
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName.."Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Kurai_Lib.Theme.Content
        tabContent.BorderSizePixel = 0
        tabContent.Visible = false
        tabContent.Parent = self.ContentContainer
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local contentListLayout = Instance.new("UIListLayout")
        contentListLayout.Padding = UDim.new(0, 10)
        contentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentListLayout.Parent = tabContent
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 10)
        contentPadding.PaddingLeft = UDim.new(0, 10)
        contentPadding.PaddingRight = UDim.new(0, 10)
        contentPadding.PaddingBottom = UDim.new(0, 10)
        contentPadding.Parent = tabContent
        
        self.Tabs[tabName] = {
            TabButton = tabButton,
            Content = tabContent,
            Elements = {},
            
            Label = function(tabObj, props)
                return self:_createLabel(tabName, props)
            end,
            
            Splitter = function(tabObj, props)
                return self:_createSplitter(tabName, props)
            end,
            
            Button = function(tabObj, props, flag)
                return self:_createButton(tabName, props, flag)
            end,
            
            Toggle = function(tabObj, props, flag)
                return self:_createToggle(tabName, props, flag)
            end,
            
            Slider = function(tabObj, props, flag)
                return self:_createSlider(tabName, props, flag)
            end,
            
            Dropdown = function(tabObj, props, flag)
                return self:_createDropdown(tabName, props, flag)
            end,
            
            Keybind = function(tabObj, props, flag)
                return self:_createKeybind(tabName, props, flag)
            end,
            
            TextField = function(tabObj, props, flag)
                return self:_createTextField(tabName, props, flag)
            end
        }
        
        tabButton.MouseButton1Click:Connect(function()
            self:SwitchTab(tabName)
        end)
    end
    
    if #tabNames > 0 then
        self:SwitchTab(tabNames[1])
    end
end

function Kurai_Lib:SwitchTab(tabName)
    if self.CurrentTab then
        Kurai_Lib.Tween(self.CurrentTab.TabButton, {BackgroundColor3 = Kurai_Lib.Theme.Tab})
        self.CurrentTab.Content.Visible = false
    end
    
    self.CurrentTab = self.Tabs[tabName]
    Kurai_Lib.Tween(self.CurrentTab.TabButton, {BackgroundColor3 = Kurai_Lib.Theme.TabAccent})
    self.CurrentTab.Content.Visible = true
end

function Kurai_Lib:_createButton(tabName, props, flag)
    props = props or {}
    local tab = self.Tabs[tabName]
    if not tab then return nil end
    
    local btnInstance = Instance.new("TextButton")
    btnInstance.Name = props.Text or "Button"
    btnInstance.Text = props.Text or "Button"
    btnInstance.Font = Enum.Font.RobotoMono
    btnInstance.TextColor3 = Kurai_Lib.Theme.Text
    btnInstance.TextSize = 16
    btnInstance.BackgroundColor3 = Kurai_Lib.Theme.Tab
    btnInstance.Size = UDim2.new(1, 0, 0, 35)
    btnInstance.LayoutOrder = #tab.Elements + 1
    btnInstance.Parent = tab.Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = btnInstance
    
    btnInstance.MouseEnter:Connect(function()
        Kurai_Lib.Tween(btnInstance, {BackgroundColor3 = Kurai_Lib.Theme.Accent})
    end)
    
    btnInstance.MouseLeave:Connect(function()
        Kurai_Lib.Tween(btnInstance, {BackgroundColor3 = Kurai_Lib.Theme.Tab})
    end)
    
    btnInstance.MouseButton1Click:Connect(function()
        Kurai_Lib.RippleEffect(btnInstance)
        if props.Callback then
            props.Callback(btnInstance)
        end
    end)
    
    if flag then
        self.Flags = self.Flags or {}
        self.Flags[flag] = btnInstance
    end
    
    table.insert(tab.Elements, btnInstance)
    
    local control = {
        Instance = btnInstance,
        Click = function()
            if props.Callback then
                props.Callback(btnInstance)
            end
            return control
        end
    }
    
    return control
end

function Kurai_Lib:_createLabel(tabName, props)
    props = props or {}
    local tab = self.Tabs[tabName]
    if not tab then return nil end
    
    local label = Instance.new("TextLabel")
    label.Name = props.Text or "Label"
    label.Text = props.Text or ""
    label.Font = Enum.Font.RobotoMono
    label.TextColor3 = Kurai_Lib.Theme.Text
    label.TextSize = 16
    label.TextXAlignment = props.Alignment or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -20, 0, 18)
    label.LayoutOrder = #tab.Elements + 1
    label.Parent = tab.Content
    
    table.insert(tab.Elements, label)
    
    local control = {
        Instance = label,
        SetText = function(text)
            label.Text = text
            return control
        end,
        GetText = function()
            return label.Text
        end
    }
    
    return control
end

function Kurai_Lib:_createSplitter(tabName, props)
    props = props or {}
    local tab = self.Tabs[tabName]
    if not tab then return nil end
    
    local splitter = Instance.new("Frame")
    splitter.Name = props.Text or "Splitter" 
    splitter.BackgroundColor3 = Kurai_Lib.Theme.Accent
    splitter.BorderSizePixel = 0
    splitter.Size = UDim2.new(1, 0, 0, 1)
    splitter.LayoutOrder = #tab.Elements + 1
    splitter.Parent = tab.Content
    
    table.insert(tab.Elements, splitter)
    

    local control = {
        Instance = splitter,
        SetColor = function(color)
            Kurai_Lib.Tween(splitter, {BackgroundColor3 = color})
            return control
        end,
        GetColor = function()
            return splitter.BackgroundColor3
        end
    }
    
    return control
end

function Kurai_Lib:_createSlider(tabName, props, flag)
    props = props or {}
    local tab = self.Tabs[tabName]
    if not tab then return nil end
    
    local slider = Instance.new("Frame")
    slider.Name = props.Text or "Slider"
    slider.BackgroundTransparency = 1
    slider.Size = UDim2.new(1, 0, 0, 50)
    slider.LayoutOrder = #tab.Elements + 1
    slider.Parent = tab.Content
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = props.Text or "Slider"
    label.Font = Enum.Font.RobotoMono
    label.TextColor3 = Kurai_Lib.Theme.Text
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Parent = slider
    
    local labelPadding = Instance.new("UIPadding")
    labelPadding.PaddingLeft = UDim.new(0, 2)
    labelPadding.Parent = label
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Text = props.State and tostring(props.State)..(props.Suffix or "") or "0"
    valueLabel.Font = Enum.Font.RobotoMono
    valueLabel.TextColor3 = Kurai_Lib.Theme.SubText
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0, 0, 0, 16)
    valueLabel.Size = UDim2.new(1, 0, 0, 16)
    valueLabel.Parent = slider
    
    local valuePadding = Instance.new("UIPadding")
    valuePadding.PaddingLeft = UDim.new(0, 2)
    valuePadding.Parent = valueLabel
    
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.BackgroundColor3 = Kurai_Lib.Theme.Content
    track.BorderSizePixel = 0
    track.Position = UDim2.new(0, 0, 0, 36)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Parent = slider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.BackgroundColor3 = Kurai_Lib.Theme.Accent
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.Position = UDim2.new(0, 0, 0.5, -6)
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.Parent = track
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local min = props.Min or 0
    local max = props.Max or 100
    local increment = props.Increment or 1
    local defaultValue = math.clamp(props.State or min, min, max)
    local suffix = props.Suffix or ""
    
    self.Flags = self.Flags or {}
    self.Flags[flag or props.Text or "Slider"] = defaultValue
    
    local value = defaultValue
    local sliding = false
    
    local function updateSlider(percent)
        percent = math.clamp(percent, 0, 1)
        value = math.floor(min + (max - min) * percent / increment) * increment
        value = math.clamp(value, min, max)
        
        local displayValue = props.Precise and string.format("%.2f", value) or tostring(value)
        valueLabel.Text = displayValue..suffix
        
        fill.Size = UDim2.new(percent, 0, 1, 0)
        thumb.Position = UDim2.new(percent, -6, 0.5, -6)
        
        self.Flags[flag or props.Text or "Slider"] = value
        if props.Callback then
            props.Callback(value, slider)
        end
    end
    
    updateSlider((defaultValue - min) / (max - min))
    
    local function updateValueFromInput(input)
        local absoluteX = input.Position.X - track.AbsolutePosition.X
        local percent = math.clamp(absoluteX / track.AbsoluteSize.X, 0, 1)
        updateSlider(percent)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            updateValueFromInput(input)
        end
    end)
    
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValueFromInput(input)
        end
    end)
    
    table.insert(tab.Elements, slider)
    

    local control = {
        Instance = slider,
        Set = function(self, newValue)
            if type(self) ~= "table" and newValue == nil then
                newValue = self
            end
            
            newValue = tonumber(newValue) or min
            newValue = math.clamp(newValue, min, max)
            updateSlider((newValue - min) / (max - min))
            return control
        end,
        Get = function()
            return value
        end
    }
    
    return control
end

function Kurai_Lib:_createToggle(tabName, props, flag)
    props = props or {}
    local tab = self.Tabs[tabName]
    if not tab then return nil end
    
    local toggle = Instance.new("Frame")
    toggle.Name = props.Text or "Toggle"
    toggle.BackgroundTransparency = 1
    toggle.Size = UDim2.new(1, 0, 0, 24)
    toggle.LayoutOrder = #tab.Elements + 1
    toggle.Parent = tab.Content
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = props.Text or "Toggle"
    label.Font = Enum.Font.RobotoMono
    label.TextColor3 = Kurai_Lib.Theme.Text
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Parent = toggle
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 2)
    padding.Parent = label
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Text = ""
    toggleButton.AnchorPoint = Vector2.new(1, 0.5)
    toggleButton.BackgroundColor3 = Kurai_Lib.Theme.Tab
    toggleButton.Position = UDim2.new(1, 0, 0.5, 0)
    toggleButton.Size = UDim2.new(0, 36, 0, 18)
    toggleButton.Parent = toggle
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = toggleButton
    
    local dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.AnchorPoint = Vector2.new(0, 0.5)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.Position = UDim2.new(0, 2, 0.5, 0)
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Parent = toggleButton
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    local state = props.State or false
    
    self.Flags = self.Flags or {}
    self.Flags[flag or props.Text or "Toggle"] = state
    
    local function updateToggle()
        if state then
            Kurai_Lib.Tween(toggleButton, {BackgroundColor3 = Kurai_Lib.Theme.Accent})
            Kurai_Lib.Tween(dot, {Position = UDim2.new(1, -18, 0.5, 0)})
        else
            Kurai_Lib.Tween(toggleButton, {BackgroundColor3 = Kurai_Lib.Theme.Tab})
            Kurai_Lib.Tween(dot, {Position = UDim2.new(0, 2, 0.5, 0)})
        end
    end
    
    updateToggle()
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        self.Flags[flag or props.Text or "Toggle"] = state
        updateToggle()
        
        if props.Callback then
            props.Callback(state, toggle)
        end
    end)
    
    table.insert(tab.Elements, toggle)
    

    local control = {
        Instance = toggle,
        Set = function(value)
            state = value
            self.Flags[flag or props.Text or "Toggle"] = state
            updateToggle()
            return control
        end,
        Get = function()
            return state
        end
    }
    
    return control
end

function Kurai_Lib:_createDropdown(tabName, props, flag)
    props = props or {}
    local tab = self.Tabs[tabName]
    if not tab then return nil end
    
    local dropdown = Instance.new("Frame")
    dropdown.Name = props.Text or "Dropdown"
    dropdown.BackgroundTransparency = 1
    dropdown.Size = UDim2.new(1, 0, 0, 50)
    dropdown.LayoutOrder = #tab.Elements + 1
    dropdown.Parent = tab.Content
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = props.Text or "Dropdown"
    label.Font = Enum.Font.RobotoMono
    label.TextColor3 = Kurai_Lib.Theme.Text
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Parent = dropdown
    
    local labelPadding = Instance.new("UIPadding")
    labelPadding.PaddingLeft = UDim.new(0, 2)
    labelPadding.Parent = label
    
    local selectionButton = Instance.new("TextButton")
    selectionButton.Name = "Selection"
    selectionButton.Font = Enum.Font.RobotoMono
    selectionButton.TextColor3 = Kurai_Lib.Theme.Text
    selectionButton.TextSize = 14
    selectionButton.TextXAlignment = Enum.TextXAlignment.Left
    selectionButton.BackgroundColor3 = Kurai_Lib.Theme.Tab
    selectionButton.Size = UDim2.new(1, 0, 0, 30)
    selectionButton.Position = UDim2.new(0, 0, 0, 20)
    selectionButton.Text = props.Default or props.State or (props.Options and props.Options[1]) or "Select..."
    selectionButton.Parent = dropdown
    
    local selectionPadding = Instance.new("UIPadding")
    selectionPadding.PaddingLeft = UDim.new(0, 8)
    selectionPadding.Parent = selectionButton
    
    local selectionCorner = Instance.new("UICorner")
    selectionCorner.CornerRadius = UDim.new(0, 3)
    selectionCorner.Parent = selectionButton
    
    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Name = "Arrow"
    arrowIcon.Image = "rbxassetid://6031091004"
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.AnchorPoint = Vector2.new(1, 0.5)
    arrowIcon.Position = UDim2.new(1, -5, 0.5, 0)
    arrowIcon.Size = UDim2.new(0, 16, 0, 16)
    arrowIcon.Rotation = 0
    arrowIcon.Parent = selectionButton
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "DropdownOptions_" .. (props.Text or "Dropdown")
    optionsFrame.BackgroundColor3 = Kurai_Lib.Theme.Content
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Size = UDim2.new(0, 0, 0, 0)
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 10
    optionsFrame.ClipsDescendants = true
    -- [ don't parent yet - will parent dynamically when shown ]
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 3)
    optionsCorner.Parent = optionsFrame
    
    local optionsList = Instance.new("ScrollingFrame")
    optionsList.Name = "OptionsList"
    optionsList.BackgroundTransparency = 1
    optionsList.BorderSizePixel = 0
    optionsList.Size = UDim2.new(1, 0, 1, 0)
    optionsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    optionsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    optionsList.ScrollBarThickness = 4
    optionsList.ScrollBarImageColor3 = Kurai_Lib.Theme.Accent
    optionsList.ZIndex = 10
    optionsList.Parent = optionsFrame
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Padding = UDim.new(0, 2)
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsList
    
    local optionsPadding = Instance.new("UIPadding")
    optionsPadding.PaddingTop = UDim.new(0, 2)
    optionsPadding.PaddingBottom = UDim.new(0, 2)
    optionsPadding.PaddingLeft = UDim.new(0, 2)
    optionsPadding.PaddingRight = UDim.new(0, 2)
    optionsPadding.Parent = optionsList
    
    local isOpen = false
    local options = props.Options or {}
    local selectedOption = props.Default or props.State or (options[1] or "")
    
    self.Flags = self.Flags or {}
    self.Flags[flag or props.Text or "Dropdown"] = selectedOption
    
    selectionButton.Text = selectedOption
    
    local function createOptions()
        -- [ clear existing optinos ]
        for _, child in next, optionsList:GetChildren() do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for i, option in next, options do
            local optionButton = Instance.new("TextButton")
            optionButton.Name = option
            optionButton.Text = option
            optionButton.Font = Enum.Font.RobotoMono
            optionButton.TextColor3 = Kurai_Lib.Theme.Text
            optionButton.TextSize = 14
            optionButton.TextXAlignment = Enum.TextXAlignment.Left
            optionButton.BackgroundColor3 = Kurai_Lib.Theme.Tab
            optionButton.BackgroundTransparency = 0.5
            optionButton.Size = UDim2.new(1, -4, 0, 24)
            optionButton.ZIndex = 11
            optionButton.LayoutOrder = i
            optionButton.Parent = optionsList
            
            local optionPadding = Instance.new("UIPadding")
            optionPadding.PaddingLeft = UDim.new(0, 6)
            optionPadding.Parent = optionButton
            
            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 3)
            optionCorner.Parent = optionButton
            
            if option == selectedOption then
                optionButton.BackgroundColor3 = Kurai_Lib.Theme.Accent
            end
            
            optionButton.MouseEnter:Connect(function()
                if option ~= selectedOption then
                    Kurai_Lib.Tween(optionButton, {BackgroundTransparency = 0.2})
                end
            end)
            
            optionButton.MouseLeave:Connect(function()
                if option ~= selectedOption then
                    Kurai_Lib.Tween(optionButton, {BackgroundTransparency = 0.5})
                end
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                selectedOption = option
                self.Flags[flag or props.Text or "Dropdown"] = selectedOption
                selectionButton.Text = selectedOption
                
                for _, btn in pairs(optionsList:GetChildren()) do
                    if btn:IsA("TextButton") then
                        if btn.Name == selectedOption then
                            Kurai_Lib.Tween(btn, {BackgroundColor3 = Kurai_Lib.Theme.Accent, BackgroundTransparency = 0})
                        else
                            Kurai_Lib.Tween(btn, {BackgroundColor3 = Kurai_Lib.Theme.Tab, BackgroundTransparency = 0.5})
                        end
                    end
                end
                
                if props.Callback then
                    props.Callback(selectedOption, dropdown)
                end
            end)
        end
    end
    
    local function toggleDropdown(forceState)
        if forceState ~= nil then
            isOpen = forceState
        else
            isOpen = not isOpen
        end
        
        if isOpen then
            -- max 5 visible at once
            local visibleOptions = math.min(#options, 5)
            local targetHeight = visibleOptions * 26 + 4 -- 24px per option + padding
            
            local absPos = selectionButton.AbsolutePosition
            local absSize = selectionButton.AbsoluteSize
            
            optionsFrame.Parent = self.ScreenGui
            optionsFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 5)
            optionsFrame.Size = UDim2.new(0, absSize.X, 0, 0)
            optionsFrame.Visible = true
            
            Kurai_Lib.Tween(optionsFrame, {Size = UDim2.new(0, absSize.X, 0, targetHeight)}, 0.2)
            Kurai_Lib.Tween(arrowIcon, {Rotation = 180}, 0.2)
            
            createOptions()
        else
            Kurai_Lib.Tween(optionsFrame, {Size = UDim2.new(0, optionsFrame.AbsoluteSize.X, 0, 0)}, 0.2)
            Kurai_Lib.Tween(arrowIcon, {Rotation = 0}, 0.2)
            
            task.delay(0.2, function()
                if not isOpen then
                    optionsFrame.Visible = false
                    optionsFrame.Parent = nil
                end
            end)
        end
    end
    
    selectionButton.MouseButton1Click:Connect(function()
        toggleDropdown()
    end)
    
    local inputBeganConnection
    local function setupInputListener()
        if inputBeganConnection then
            inputBeganConnection:Disconnect()
        end
        
        inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if isOpen then
                    local mousePos = input.Position
                    
                    local isInOptionsFrame = false
                    if optionsFrame.Visible then
                        local optionsFramePos = optionsFrame.AbsolutePosition
                        local optionsFrameSize = optionsFrame.AbsoluteSize
                        
                        isInOptionsFrame = 
                            mousePos.X >= optionsFramePos.X and
                            mousePos.X <= optionsFramePos.X + optionsFrameSize.X and
                            mousePos.Y >= optionsFramePos.Y and
                            mousePos.Y <= optionsFramePos.Y + optionsFrameSize.Y
                    end
                    
                    local isInSelectionButton = false
                    local selectionButtonPos = selectionButton.AbsolutePosition
                    local selectionButtonSize = selectionButton.AbsoluteSize
                    
                    isInSelectionButton = 
                        mousePos.X >= selectionButtonPos.X and
                        mousePos.X <= selectionButtonPos.X + selectionButtonSize.X and
                        mousePos.Y >= selectionButtonPos.Y and
                        mousePos.Y <= selectionButtonPos.Y + selectionButtonSize.Y
                    
                    if not isInOptionsFrame and not isInSelectionButton then
                        toggleDropdown(false)
                    end
                end
            end
        end)
    end
    
    setupInputListener()
    
    dropdown.AncestryChanged:Connect(function(_, parent)
        if not parent and inputBeganConnection then
            inputBeganConnection:Disconnect()
            
            if optionsFrame and optionsFrame.Parent then
                optionsFrame:Destroy()
            end
        end
    end)
    
    table.insert(tab.Elements, dropdown)
    

    local control = {
        Instance = dropdown,
        Set = function(option)
            if type(option) == "string" and table.find(options, option) then
                selectedOption = option
                self.Flags[flag or props.Text or "Dropdown"] = selectedOption
                selectionButton.Text = selectedOption
                
                if props.Callback then
                    props.Callback(selectedOption, dropdown)
                end
                
                return control
            end
            
            return control
        end,
        Get = function()
            return selectedOption
        end,
        Refresh = function(newOptions, keepSelection)
            options = newOptions or {}
            
            if not keepSelection or not table.find(options, selectedOption) then
                selectedOption = options[1] or ""
                self.Flags[flag or props.Text or "Dropdown"] = selectedOption
                selectionButton.Text = selectedOption
            end
            
            if isOpen then
                createOptions()
            end
            
            return control
        end
    }
    
    return control
end

function Kurai_Lib:_createKeybind(tabName, props, flag)
    props = props or {}
    local tab = self.Tabs[tabName]
    if not tab then return nil end
    
    local keys = {
        -- qwerty keys (excluding WASD)
        [Enum.KeyCode.Q] = "Q",
        [Enum.KeyCode.E] = "E",
        [Enum.KeyCode.R] = "R",
        [Enum.KeyCode.T] = "T",
        [Enum.KeyCode.Y] = "Y",
        [Enum.KeyCode.U] = "U",
        [Enum.KeyCode.I] = "I",
        [Enum.KeyCode.O] = "O",
        [Enum.KeyCode.P] = "P",
        [Enum.KeyCode.G] = "G",
        [Enum.KeyCode.H] = "H",
        [Enum.KeyCode.J] = "J",
        [Enum.KeyCode.K] = "K",
        [Enum.KeyCode.L] = "L",
        [Enum.KeyCode.Z] = "Z",
        [Enum.KeyCode.X] = "X",
        [Enum.KeyCode.C] = "C",
        [Enum.KeyCode.V] = "V",
        [Enum.KeyCode.B] = "B",
        [Enum.KeyCode.N] = "N",
        [Enum.KeyCode.M] = "M",
        [Enum.KeyCode.F] = "F",
    
        -- modifier keys
        [Enum.KeyCode.LeftShift] = "LS",
        [Enum.KeyCode.RightShift] = "RS",
        [Enum.KeyCode.LeftControl] = "LC",
        [Enum.KeyCode.RightControl] = "RC",
        [Enum.KeyCode.LeftAlt] = "LA",
        [Enum.KeyCode.RightAlt] = "RA",
        [Enum.KeyCode.CapsLock] = "CAPS",
    
        -- function keys
        [Enum.KeyCode.F1] = "F1",
        [Enum.KeyCode.F2] = "F2",
        [Enum.KeyCode.F3] = "F3",
        [Enum.KeyCode.F4] = "F4",
        [Enum.KeyCode.F5] = "F5",
        [Enum.KeyCode.F6] = "F6",
        [Enum.KeyCode.F7] = "F7",
        [Enum.KeyCode.F8] = "F8",
        [Enum.KeyCode.F9] = "F9",
        [Enum.KeyCode.F10] = "F10",
        [Enum.KeyCode.F11] = "F11",
        [Enum.KeyCode.F12] = "F12",
    
        -- number keys
        [Enum.KeyCode.One] = "1",
        [Enum.KeyCode.Two] = "2",
        [Enum.KeyCode.Three] = "3",
        [Enum.KeyCode.Four] = "4",
        [Enum.KeyCode.Five] = "5",
        [Enum.KeyCode.Six] = "6",
        [Enum.KeyCode.Seven] = "7",
        [Enum.KeyCode.Eight] = "8",
        [Enum.KeyCode.Nine] = "9",
        [Enum.KeyCode.Zero] = "0",
    
        -- numpad keys
        [Enum.KeyCode.KeypadOne] = "Num1",
        [Enum.KeyCode.KeypadTwo] = "Num2",
        [Enum.KeyCode.KeypadThree] = "Num3",
        [Enum.KeyCode.KeypadFour] = "Num4",
        [Enum.KeyCode.KeypadFive] = "Num5",
        [Enum.KeyCode.KeypadSix] = "Num6",
        [Enum.KeyCode.KeypadSeven] = "Num7",
        [Enum.KeyCode.KeypadEight] = "Num8",
        [Enum.KeyCode.KeypadNine] = "Num9",
        [Enum.KeyCode.KeypadZero] = "Num0",
    
        -- symbol keys
        [Enum.KeyCode.Minus] = "-",
        [Enum.KeyCode.Equals] = "=",
        [Enum.KeyCode.Tilde] = "~",
        [Enum.KeyCode.LeftBracket] = "[",
        [Enum.KeyCode.RightBracket] = "]",
        [Enum.KeyCode.Semicolon] = ";",
        [Enum.KeyCode.Quote] = "'",
        [Enum.KeyCode.BackSlash] = "\\",
        [Enum.KeyCode.Comma] = ",",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Slash] = "/",
        [Enum.KeyCode.Asterisk] = "*",
        [Enum.KeyCode.Plus] = "+",
        [Enum.KeyCode.Backquote] = "`",
    
        -- special keys
        [Enum.KeyCode.Space] = "SPC",
        [Enum.KeyCode.Tab] = "Tab",
        [Enum.KeyCode.Return] = "Ent",
        [Enum.KeyCode.Backspace] = "BS",
        [Enum.KeyCode.Escape] = "ESC",
        [Enum.KeyCode.Insert] = "INS",
        [Enum.KeyCode.Delete] = "Del",
        [Enum.KeyCode.Home] = "Home",
        [Enum.KeyCode.End] = "End",
        [Enum.KeyCode.PageUp] = "PgUp",
        [Enum.KeyCode.PageDown] = "PgDown",
    
        -- arrow keys
        [Enum.KeyCode.Up] = "↑",
        [Enum.KeyCode.Down] = "↓",
        [Enum.KeyCode.Left] = "←",
        [Enum.KeyCode.Right] = "→",
    
        -- mouse btns
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3"
    }
    
    local defaultKey = props.State or props.Default or Enum.KeyCode.E
    
    local keybind = Instance.new("Frame")
    keybind.Name = props.Text or "Keybind"
    keybind.BackgroundTransparency = 1
    keybind.Size = UDim2.new(1, 0, 0, 24)
    keybind.LayoutOrder = #tab.Elements + 1
    keybind.Parent = tab.Content
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = props.Text or "Keybind"
    label.Font = Enum.Font.RobotoMono
    label.TextColor3 = Kurai_Lib.Theme.Text
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Parent = keybind
    
    local labelPadding = Instance.new("UIPadding")
    labelPadding.PaddingLeft = UDim.new(0, 2)
    labelPadding.Parent = label
    
    local keyButton = Instance.new("TextButton")
    keyButton.Name = "KeyButton"
    keyButton.Text = keys[defaultKey] or defaultKey.Name
    keyButton.Font = Enum.Font.RobotoMono
    keyButton.TextColor3 = Kurai_Lib.Theme.Text
    keyButton.TextSize = 14
    keyButton.BackgroundColor3 = Kurai_Lib.Theme.Tab
    keyButton.Size = UDim2.new(0, 60, 0, 24)
    keyButton.AnchorPoint = Vector2.new(1, 0.5)
    keyButton.Position = UDim2.new(1, 0, 0.5, 0)
    keyButton.AutoButtonColor = false
    keyButton.Parent = keybind
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 3)
    keyCorner.Parent = keyButton
    
    local selectedKey = defaultKey
    local listening = false
    
    self.Flags = self.Flags or {}
    self.Flags[flag or props.Text or "Keybind"] = selectedKey
    
    local function updateVisuals()
        if listening then
            keyButton.Text = "..."
            Kurai_Lib.Tween(keyButton, {BackgroundColor3 = Kurai_Lib.Theme.Accent})
        else
            keyButton.Text = keys[selectedKey] or (type(selectedKey) == "EnumItem" and selectedKey.Name) or "None"
            Kurai_Lib.Tween(keyButton, {BackgroundColor3 = Kurai_Lib.Theme.Tab})
        end
    end
    
    keyButton.MouseEnter:Connect(function()
        if not listening then
            Kurai_Lib.Tween(keyButton, {BackgroundColor3 = Kurai_Lib.Theme.TabAccent})
        end
    end)
    
    keyButton.MouseLeave:Connect(function()
        if not listening then
            Kurai_Lib.Tween(keyButton, {BackgroundColor3 = Kurai_Lib.Theme.Tab})
        end
    end)
    
    keyButton.MouseButton1Click:Connect(function()
        listening = true
        updateVisuals()
    end)
    
    keyButton.MouseButton2Click:Connect(function()
        if listening then
            listening = false
            updateVisuals()
        else
            selectedKey = defaultKey
            self.Flags[flag or props.Text or "Keybind"] = selectedKey
            updateVisuals()
            
            if props.Callback then
                props.Callback(selectedKey, keybind)
            end
        end
    end)
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gpe)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard or 
               input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.MouseButton2 or 
               input.UserInputType == Enum.UserInputType.MouseButton3 then
                
                if input.KeyCode == Enum.KeyCode.Escape then
                    listening = false
                    updateVisuals()
                    return
                end
                
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    selectedKey = input.KeyCode
                else
                    selectedKey = input.UserInputType
                end
                
                self.Flags[flag or props.Text or "Keybind"] = selectedKey
                
                listening = false
                updateVisuals()
                
                if props.Callback then
                    props.Callback(selectedKey, keybind)
                end
            end
        elseif not gpe and input.KeyCode == selectedKey or input.UserInputType == selectedKey then
            if props.OnPressed then
                props.OnPressed(selectedKey, keybind)
            end
        end
    end)
    
    keybind.AncestryChanged:Connect(function(_, parent)
        if not parent then
            connection:Disconnect()
        end
    end)
    
    table.insert(tab.Elements, keybind)
    

    local control = {
        Instance = keybind,
        Set = function(newKey)
            if typeof(newKey) == "EnumItem" then
                selectedKey = newKey
                self.Flags[flag or props.Text or "Keybind"] = selectedKey
                updateVisuals()
                
                if props.Callback then
                    props.Callback(selectedKey, keybind)
                end
            end
            return control
        end,
        Get = function()
            return selectedKey
        end,
        GetText = function()
            return keys[selectedKey] or (type(selectedKey) == "EnumItem" and selectedKey.Name) or "None"
        end
    }
    
    return control
end

function Kurai_Lib:_createTextField(tabName, props, flag)
    props = props or {}
    local tab = self.Tabs[tabName]
    if not tab then return nil end
    
    local textField = Instance.new("Frame")
    textField.Name = props.Text or "TextField"
    textField.BackgroundTransparency = 1
    textField.Size = UDim2.new(1, 0, 0, 50)
    textField.LayoutOrder = #tab.Elements + 1
    textField.Parent = tab.Content
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = props.Text or "Text Input"
    label.Font = Enum.Font.RobotoMono
    label.TextColor3 = Kurai_Lib.Theme.Text
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Parent = textField
    
    local labelPadding = Instance.new("UIPadding")
    labelPadding.PaddingLeft = UDim.new(0, 2)
    labelPadding.Parent = label
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "Input"
    textBox.Font = Enum.Font.RobotoMono
    textBox.Text = props.Default or props.State or ""
    textBox.PlaceholderText = props.Placeholder or "Enter text..."
    textBox.TextColor3 = Kurai_Lib.Theme.Text
    textBox.PlaceholderColor3 = Kurai_Lib.Theme.SubText
    textBox.TextSize = 14
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextWrapped = false
    textBox.ClearTextOnFocus = props.ClearTextOnFocus ~= nil and props.ClearTextOnFocus or false
    textBox.BackgroundColor3 = Kurai_Lib.Theme.Tab
    textBox.Size = UDim2.new(1, 0, 0, 30)
    textBox.Position = UDim2.new(0, 0, 0, 20)
    textBox.ClipsDescendants = true
    textBox.Parent = textField
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 3)
    textBoxCorner.Parent = textBox
    
    local textBoxPadding = Instance.new("UIPadding")
    textBoxPadding.PaddingLeft = UDim.new(0, 8)
    textBoxPadding.PaddingRight = UDim.new(0, 8)
    textBoxPadding.Parent = textBox
    
    local charLimit
    if props.CharLimit then
        charLimit = Instance.new("TextLabel")
        charLimit.Name = "CharLimit"
        charLimit.Font = Enum.Font.RobotoMono
        charLimit.Text = string.len(textBox.Text) .. "/" .. props.CharLimit
        charLimit.TextColor3 = Kurai_Lib.Theme.SubText
        charLimit.TextSize = 12
        charLimit.TextXAlignment = Enum.TextXAlignment.Right
        charLimit.BackgroundTransparency = 1
        charLimit.Size = UDim2.new(0, 50, 0, 16)
        charLimit.Position = UDim2.new(1, -50, 0, 0)
        charLimit.Parent = textField
    end
    
    local value = textBox.Text
    
    self.Flags = self.Flags or {}
    self.Flags[flag or props.Text or "TextField"] = value
    
    textBox.Focused:Connect(function()
        Kurai_Lib.Tween(textBox, {BackgroundColor3 = Kurai_Lib.Theme.TabAccent})
    end)
    
    textBox.FocusLost:Connect(function(enterPressed)
        Kurai_Lib.Tween(textBox, {BackgroundColor3 = Kurai_Lib.Theme.Tab})
        
        value = textBox.Text
        self.Flags[flag or props.Text or "TextField"] = value
        
        if props.Callback then
            props.Callback(value, enterPressed, textField)
        end
    end)
    
    if props.CharLimit then
        textBox:GetPropertyChangedSignal("Text"):Connect(function()
            local text = textBox.Text
            local textLen = string.len(text)
            
            if textLen > props.CharLimit then
                textBox.Text = string.sub(text, 1, props.CharLimit)
            end
            
            charLimit.Text = math.min(textLen, props.CharLimit) .. "/" .. props.CharLimit
        end)
    end
    
    if props.InputType then
        textBox:GetPropertyChangedSignal("Text"):Connect(function()
            local text = textBox.Text
            local newText = text
            
            if props.InputType == "number" or props.InputType == "numeric" then -- decimals allowed
                newText = text:gsub("[^%d%.]", "")
                
                local parts = string.split(newText, ".")
                if #parts > 2 then
                    newText = parts[1] .. "." .. parts[2]
                end
            elseif props.InputType == "integer" then -- whole only
                newText = text:gsub("[^%d]", "")
            elseif props.InputType == "alphanumeric" then -- letters and numbers only
                newText = text:gsub("[^%w]", "")
            end -- else: keep as is
            
            if newText ~= text then
                textBox.Text = newText
            end
        end)
    end
    
    table.insert(tab.Elements, textField)
    

    local control = {
        Instance = textField,
        Set = function(text)
            textBox.Text = tostring(text)
            value = textBox.Text
            self.Flags[flag or props.Text or "TextField"] = value
            
            if charLimit then
                charLimit.Text = math.min(string.len(value), props.CharLimit) .. "/" .. props.CharLimit
            end
            
            return control
        end,
        Get = function()
            return value
        end,
        Clear = function()
            textBox.Text = ""
            value = ""
            self.Flags[flag or props.Text or "TextField"] = value
            
            if charLimit then
                charLimit.Text = "0/" .. props.CharLimit
            end
            
            return control
        end
    }
    
    return control
end

function Kurai_Lib.Rainbow(element, speed)
    speed = speed or 0.5
    local hue = 0
    
    coroutine.wrap(function()
        while element and element.Parent do
            hue = (hue + 0.01) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            
            local property = ({
                ["Frame"] = "BackgroundColor3",
                ["TextLabel"] = "TextColor3",
                ["TextButton"] = "TextColor3",
                ["TextBox"] = "TextColor3",
                ["ImageLabel"] = "ImageColor3",
                ["ImageButton"] = "ImageColor3",
                ["UIStroke"] = "Color"
            })[element.ClassName] or "BackgroundColor3"
            
            if element[property] ~= nil then
                Kurai_Lib.Tween(element, {[property] = color}, speed)
            end
            
            task.wait(speed)
        end
    end)()
end

return Kurai_Lib
