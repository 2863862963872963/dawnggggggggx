local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Library = {}

--// iOS Design System
local THEME = {
    Background = Color3.fromRGB(242, 242, 247),
    Card = Color3.fromRGB(255, 255, 255),
    TextPrimary = Color3.fromRGB(0, 0, 0),
    TextSecondary = Color3.fromRGB(142, 142, 147),
    Divider = Color3.fromRGB(229, 229, 234),
    Blue = Color3.fromRGB(0, 122, 255),
    Green = Color3.fromRGB(52, 199, 89),
    FontMain = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
}

local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

--// Helper Functions
local function MakeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

local function Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

function Library:Window(options)
    local title = options.Title or "Menu"
    local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local ScreenGui = Create("ScreenGui", {
        Name = "iOSLibrary_" .. title,
        Parent = PlayerGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 10
    })

    --// 1. Responsive Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = THEME.Background,
        AnchorPoint = Vector2.new(0.5, 0.5), -- Center Pivot
        Position = UDim2.new(0.5, 0, 0.5, 0), -- Center Screen
        Size = UDim2.new(0.9, 0, 0.6, 0), -- 90% Width on Mobile, 60% Height
        BorderSizePixel = 0,
        Active = true -- Important for Mobile input sinking
    })
    
    -- Constraint to keep it from looking huge on PC
    local SizeConstraint = Create("UISizeConstraint", {
        Parent = MainFrame,
        MaxSize = Vector2.new(400, 600), -- Max Width/Height for PC
        MinSize = Vector2.new(250, 300)
    })

    MakeCorner(MainFrame, 18)

    -- Shadow
    local Shadow = Create("ImageLabel", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = 0,
        Image = "rbxassetid://5554236805",
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.5
    })

    --// 2. Mobile Dragging Logic
    local dragging, dragInput, dragStart, startPos
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            -- Use Scale/Offset math to keep AnchorPoint correct
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X, 
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    --// Header
    local Header = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
    })
    
    local TitleLabel = Create("TextLabel", {
        Parent = Header,
        Text = title,
        Font = THEME.FontBold,
        TextSize = 18,
        TextColor3 = THEME.TextPrimary,
        Size = UDim2.new(1, -40, 1, 0), -- Leave room for close button
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Mobile Close Button (Top Right X)
    local CloseBtn = Create("TextButton", {
        Parent = Header,
        Text = "×",
        Font = THEME.FontMain,
        TextSize = 28,
        TextColor3 = THEME.TextSecondary,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 40, 0, 50),
        Position = UDim2.new(1, -40, 0, 0)
    })
    
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    -- Divider
    Create("Frame", {
        Parent = Header,
        BackgroundColor3 = THEME.Divider,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0
    })

    --// Content Container
    local Container = Create("ScrollingFrame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -50),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = THEME.TextSecondary,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    Create("UIListLayout", {
        Parent = Container,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Create("UIPadding", {
        Parent = Container,
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15)
    })

    local function CreateItemContainer(height)
        local Frame = Create("Frame", {
            Parent = Container,
            BackgroundColor3 = THEME.Card,
            Size = UDim2.new(0.9, 0, 0, height or 45),
            BorderSizePixel = 0
        })
        MakeCorner(Frame, 10)
        return Frame
    end

    local Elements = {}

    --// TOGGLE UI VISIBILITY
    function Elements:ToggleUI()
        MainFrame.Visible = not MainFrame.Visible
    end

    --// MOBILE OPEN BUTTON
    function Elements:AddMobileToggle()
        local ToggleScreen = Create("ScreenGui", {
            Name = "iOS_MobileToggle",
            Parent = PlayerGui,
            ResetOnSpawn = false
        })
        
        local OpenBtn = Create("TextButton", {
            Parent = ToggleScreen,
            Text = "Menu",
            Font = THEME.FontBold,
            TextColor3 = Color3.new(1,1,1),
            BackgroundColor3 = THEME.Blue,
            Size = UDim2.new(0, 80, 0, 40),
            Position = UDim2.new(0, 20, 0.5, -20), -- Left side of screen
            AutoButtonColor = true
        })
        MakeCorner(OpenBtn, 20)
        
        OpenBtn.MouseButton1Click:Connect(function()
            MainFrame.Visible = not MainFrame.Visible
        end)
    end

    --// BUTTON
    function Elements:Button(text, callback)
        callback = callback or function() end
        local BtnFrame = CreateItemContainer(45)
        
        local Btn = Create("TextButton", {
            Parent = BtnFrame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            Font = THEME.FontMain,
            TextColor3 = THEME.Blue,
            TextSize = 16
        })

        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
            task.wait(0.1)
            TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
            callback()
        end)
    end

    --// TOGGLE
    function Elements:Toggle(text, default, callback)
        callback = callback or function() end
        local enabled = default or false
        local TogFrame = CreateItemContainer(45)
        
        Create("TextLabel", {
            Parent = TogFrame,
            Text = text,
            Font = THEME.FontMain,
            TextColor3 = THEME.TextPrimary,
            TextSize = 16,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local SwitchBg = Create("Frame", {
            Parent = TogFrame,
            BackgroundColor3 = enabled and THEME.Green or THEME.Divider,
            Size = UDim2.new(0, 50, 0, 30),
            Position = UDim2.new(1, -60, 0.5, -15),
        })
        MakeCorner(SwitchBg, 15)

        local Knob = Create("Frame", {
            Parent = SwitchBg,
            BackgroundColor3 = Color3.new(1,1,1),
            Size = UDim2.new(0, 26, 0, 26),
            Position = enabled and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
        })
        MakeCorner(Knob, 13)
        
        local Trigger = Create("TextButton", {
            Parent = SwitchBg,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = ""
        })

        Trigger.MouseButton1Click:Connect(function()
            enabled = not enabled
            local goalColor = enabled and THEME.Green or THEME.Divider
            local goalPos = enabled and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
            
            TweenService:Create(SwitchBg, TWEEN_INFO, {BackgroundColor3 = goalColor}):Play()
            TweenService:Create(Knob, TWEEN_INFO, {Position = goalPos}):Play()
            callback(enabled)
        end)
    end

    --// SLIDER (Mobile Optimized)
    function Elements:Slider(text, options, callback)
        local min, max = options.Min or 0, options.Max or 100
        local default = options.Default or min
        local value = default
        
        local SliderFrame = CreateItemContainer(65)
        
        Create("TextLabel", {
            Parent = SliderFrame,
            Text = text,
            Font = THEME.FontMain,
            TextColor3 = THEME.TextPrimary,
            TextSize = 16,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 0, 30),
            Position = UDim2.new(0, 15, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local ValueLabel = Create("TextLabel", {
            Parent = SliderFrame,
            Text = tostring(default),
            Font = THEME.FontMain,
            TextColor3 = THEME.TextSecondary,
            TextSize = 14,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 50, 0, 30),
            Position = UDim2.new(1, -65, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Right
        })

        local Track = Create("Frame", {
            Parent = SliderFrame,
            BackgroundColor3 = THEME.Divider,
            Size = UDim2.new(1, -30, 0, 4),
            Position = UDim2.new(0, 15, 0, 40)
        })
        MakeCorner(Track, 2)
        
        local Fill = Create("Frame", {
            Parent = Track,
            BackgroundColor3 = THEME.Blue,
            Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
            BorderSizePixel = 0
        })
        MakeCorner(Fill, 2)
        
        -- Make the trigger cover the specific area
        local Trigger = Create("TextButton", {
            Parent = SliderFrame,
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 0, 0, 40), -- Large hit area
            Position = UDim2.new(0, 0, 0, 25)
        })

        local function UpdateSlider(input)
            local pos = input.Position.X
            local relPos = pos - Track.AbsolutePosition.X
            local percent = math.clamp(relPos / Track.AbsoluteSize.X, 0, 1)
            
            value = math.floor(min + (max - min) * percent)
            ValueLabel.Text = tostring(value)
            TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
            callback(value)
        end
        
        local isSliding = false
        Trigger.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = true
                UpdateSlider(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = false
            end
        end)
    end

    return Elements
end

return Library


