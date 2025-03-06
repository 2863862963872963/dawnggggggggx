-- PeakUILib.lua
local PeakUILib = {}
PeakUILib.__index = PeakUILib

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Tab class
local Tab = {}
Tab.__index = Tab

-- Create the library instance
function PeakUILib.new()
    local self = setmetatable({}, PeakUILib)
    return self
end

-- Create a window with a config table
function PeakUILib:CreateWindow(config)
    -- Validate config
    config = config or {}
    local uisize = config.uisize or UDim2.new(0, 300, 0, 200)
    local title = config.Title or "Peak UI"
    local subtitle = config.Subtitle or "Welcome"

    -- ScreenGui setup
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Name = "PeakUI"

    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = uisize
    frame.Position = UDim2.new(0.5, -uisize.X.Offset / 2, 0.5, -uisize.Y.Offset / 2)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, 0, 0, 30)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextSize = 18
    titleText.Parent = titleBar

    -- Subtitle text
    local subtitleText = Instance.new("TextLabel")
    subtitleText.Size = UDim2.new(1, 0, 0, 20)
    subtitleText.Position = UDim2.new(0, 0, 0, 30)
    subtitleText.BackgroundTransparency = 1
    subtitleText.Text = subtitle
    subtitleText.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitleText.Font = Enum.Font.SourceSans
    subtitleText.TextSize = 14
    subtitleText.Parent = titleBar

    -- Dragging functionality
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
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

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Store references for later use
    self.MainFrame = frame
    self.TitleText = titleText
    self.SubtitleText = subtitleText
    return self
end

-- Setter for title
function PeakUILib:SetTitle(newTitle)
    if self.TitleText then
        self.TitleText.Text = newTitle or "Peak UI"
    end
end

-- Setter for subtitle
function PeakUILib:SetSubtitle(newSubtitle)
    if self.SubtitleText then
        self.SubtitleText.Text = newSubtitle or "Welcome"
    end
end

-- Create a button
function PeakUILib:CreateButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Position = UDim2.new(0, 10, 0, 60 + (#self.MainFrame:GetChildren() - 1) * 40)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = text or "Click Me"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 16
    button.Parent = self.MainFrame

    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end)

    return button
end

-- Create a toggle
function PeakUILib:CreateToggle(text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 100, 0, 30)
    toggleFrame.Position = UDim2.new(0, 10, 0, 60 + (#self.MainFrame:GetChildren() - 1) * 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = self.MainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 70, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 20, 0, 20)
    toggle.Position = UDim2.new(1, -20, 0.5, -10)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    toggle.Parent = toggleFrame

    local state = default or false
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            }):Play()
            if callback then callback(state) end
        end
    end)

    return toggleFrame
end

-- Create a tab system
function PeakUILib:CreateTabSystem()
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = self.MainFrame

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, 0, 1, -80)
    contentArea.Position = UDim2.new(0, 0, 0, 80)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = self.MainFrame

    self.Tabs = {}
    self.ContentArea = contentArea
    self.TabContainer = tabContainer
    return self
end

-- Add a new tab
function PeakUILib:AddTab(name)
    if not self.Tabs then
        self:CreateTabSystem()
    end

    local tabButton = Instance.new("TextButton")
    local tabCount = #self.Tabs
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.Position = UDim2.new(0, tabCount * 100, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    tabButton.Text = name or "Tab"
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Font = Enum.Font.SourceSans
    tabButton.TextSize = 16
    tabButton.BorderSizePixel = 0
    tabButton.Parent = self.TabContainer

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Visible = tabCount == 0
    contentFrame.Parent = self.ContentArea

    local tab = setmetatable({
        Button = tabButton,
        Content = contentFrame,
        Elements = {},
        ParentLib = self
    }, Tab)
    table.insert(self.Tabs, tab)

    tabButton.MouseButton1Click:Connect(function()
        for _, otherTab in pairs(self.Tabs) do
            otherTab.Content.Visible = false
            TweenService:Create(otherTab.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            }):Play()
        end
        contentFrame.Visible = true
        TweenService:Create(tabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
    end)

    tabButton.MouseEnter:Connect(function()
        if not contentFrame.Visible then
            TweenService:Create(tabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            }):Play()
        end
    end)
    tabButton.MouseLeave:Connect(function()
        if not contentFrame.Visible then
            TweenService:Create(tabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            }):Play()
        end
    end)

    return tab
end

-- Tab-specific button creation
function Tab:CreateButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Position = UDim2.new(0, 10, 0, 10 + (#self.Elements * 40))
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = text or "Click Me"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 16
    button.Parent = self.Content

    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end)

    table.insert(self.Elements, button)
    return button
end

-- Tab-specific toggle creation
function Tab:CreateToggle(text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 100, 0, 30)
    toggleFrame.Position = UDim2.new(0, 10, 0, 10 + (#self.Elements * 40))
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = self.Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 70, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 20, 0, 20)
    toggle.Position = UDim2.new(1, -20, 0.5, -10)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    toggle.Parent = toggleFrame

    local state = default or false
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            }):Play()
            if callback then callback(state) end
        end
    end)

    table.insert(self.Elements, toggleFrame)
    return toggleFrame
end

return PeakUILib
