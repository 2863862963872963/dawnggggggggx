--[[ 
    Modern UI Library for Roblox
    Author: Gemini
    
    Usage:
    local Library = require(path.to.module) -- Or paste this whole script into a LocalScript
    
    local Window = Library:CreateWindow({
        Title = "Hub Title",
        Subtitle = "Game Name",
        Size = UDim2.fromOffset(500, 350)
    })
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Connections = {},
    Flags = {},
    OpenedFrames = {}
}

--// Constants & Theme
local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Sidebar = Color3.fromRGB(30, 30, 30),
    ElementBackground = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(0, 120, 215), -- Blue
    Divider = Color3.fromRGB(50, 50, 50),
    Hover = Color3.fromRGB(45, 45, 45)
}

--// Utility Functions
local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
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

--// Library Functions

function Library:CreateWindow(Config)
    Config = Config or {}
    Config.Title = Config.Title or "UI Library"
    Config.Subtitle = Config.Subtitle or "By Gemini"
    Config.Size = Config.Size or UDim2.fromOffset(550, 350)
    
    local ScreenGui = Create("ScreenGui", {
        Name = "ModernUI",
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = Config.Size,
        ClipsDescendants = true
    })
    
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 6)})
    
    -- Topbar
    local Topbar = Create("Frame", {
        Name = "Topbar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })
    Create("UICorner", {Parent = Topbar, CornerRadius = UDim.new(0, 6)})
    
    -- Fix bottom corners of topbar
    Create("Frame", {
        Parent = Topbar,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -5),
        Size = UDim2.new(1, 0, 0, 5),
        ZIndex = 0
    })

    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 5),
        Size = UDim2.new(0, 200, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = Config.Title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local SubtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 22),
        Size = UDim2.new(0, 200, 0, 15),
        Font = Enum.Font.Gotham,
        Text = Config.Subtitle,
        TextColor3 = Theme.SubText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Containers
    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 41),
        Size = UDim2.new(0, 130, 1, -41),
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    Create("UIPadding", {Parent = TabContainer, PaddingTop = UDim.new(0, 10)})
    
    -- Separator Line
    Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 130, 0, 41),
        Size = UDim2.new(0, 1, 1, -41)
    })

    local PageContainer = Create("Frame", {
        Name = "PageContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 140, 0, 50),
        Size = UDim2.new(1, -150, 1, -60),
        ClipsDescendants = true
    })

    MakeDraggable(Topbar, MainFrame)
    
    -- Window Object
    local Window = {}
    
    function Window:SetTitle(text)
        TitleLabel.Text = text
    end
    
    function Window:SetSubtitle(text)
        SubtitleLabel.Text = text
    end
    
    function Window:SetSize(udim)
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = udim}):Play()
    end
    
    local FirstTab = true
    
    function Window:AddTab(Name)
        local Tab = {}
        
        -- Tab Button
        local TabBtn = Create("TextButton", {
            Name = Name,
            Parent = TabContainer,
            BackgroundColor3 = Theme.Sidebar, -- Transparent mostly
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = Name,
            TextColor3 = Theme.SubText,
            TextSize = 13,
            AutoButtonColor = false
        })
        
        -- Selection Indicator (Blue line)
        local Indicator = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 5),
            Size = UDim2.new(0, 3, 1, -10),
            Visible = false
        })
        
        -- Page Content
        local Page = Create("ScrollingFrame", {
            Name = Name .. "Page",
            Parent = PageContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false
        })
        
        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab Logic
        local function Activate()
            -- Reset others
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = Theme.SubText}):Play()
                    v:FindFirstChild("Frame").Visible = false
                end
            end
            for _, v in pairs(PageContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            
            -- Activate current
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
            Indicator.Visible = true
            Page.Visible = true
        end
        
        TabBtn.MouseButton1Click:Connect(Activate)
        
        if FirstTab then
            Activate()
            FirstTab = false
        end
        
        function Tab:SetName(text)
            TabBtn.Text = text
            Page.Name = text .. "Page"
        end
        
        -- ELEMENTS --
        
        function Tab:AddButton(Config)
            Config.Text = Config.Text or "Button"
            Config.Callback = Config.Callback or function() end
            
            local BtnFrame = Create("TextButton", {
                Name = "Button",
                Parent = Page,
                BackgroundColor3 = Theme.ElementBackground,
                Size = UDim2.new(1, 0, 0, 36),
                AutoButtonColor = false,
                Font = Enum.Font.Gotham,
                Text = Config.Text,
                TextColor3 = Theme.Text,
                TextSize = 13
            })
            Create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 4)})
            
            BtnFrame.MouseEnter:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover}):Play()
            end)
            BtnFrame.MouseLeave:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground}):Play()
            end)
            BtnFrame.MouseButton1Click:Connect(function()
                Config.Callback()
                -- Click Effect
                local Ripple = Create("Frame", {
                    Parent = BtnFrame,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.8,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0)
                })
                Create("UICorner", {Parent = Ripple, CornerRadius = UDim.new(0, 4)})
                TweenService:Create(Ripple, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                game.Debris:AddItem(Ripple, 0.3)
            end)
        end
        
        function Tab:AddToggle(Config)
            Config.Text = Config.Text or "Toggle"
            Config.Default = Config.Default or false
            Config.Callback = Config.Callback or function() end
            
            local Toggled = Config.Default
            
            local ToggleFrame = Create("Frame", {
                Name = "Toggle",
                Parent = Page,
                BackgroundColor3 = Theme.ElementBackground,
                Size = UDim2.new(1, 0, 0, 36)
            })
            Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 4)})
            
            local Label = Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0, 200, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Config.Text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SwitchBg = Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(60, 60, 60),
                Position = UDim2.new(1, -50, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20)
            })
            Create("UICorner", {Parent = SwitchBg, CornerRadius = UDim.new(1, 0)})
            
            local SwitchCircle = Create("Frame", {
                Parent = SwitchBg,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = SwitchCircle, CornerRadius = UDim.new(1, 0)})
            
            local Button = Create("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })
            
            local function Update()
                Toggled = not Toggled
                local TargetColor = Toggled and Theme.Accent or Color3.fromRGB(60, 60, 60)
                local TargetPos = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor}):Play()
                TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = TargetPos}):Play()
                Config.Callback(Toggled)
            end
            
            Button.MouseButton1Click:Connect(Update)
            
            if Config.Default then
                 Config.Callback(true) -- Init
            end
        end
        
        function Tab:AddSlider(Config)
            Config.Text = Config.Text or "Slider"
            Config.Min = Config.Min or 0
            Config.Max = Config.Max or 100
            Config.Default = Config.Default or Config.Min
            Config.Callback = Config.Callback or function() end
            
            local Value = Config.Default
            
            local SliderFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.ElementBackground,
                Size = UDim2.new(1, 0, 0, 50)
            })
            Create("UICorner", {Parent = SliderFrame, CornerRadius = UDim.new(0, 4)})
            
            local Label = Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(0, 200, 0, 20),
                Font = Enum.Font.Gotham,
                Text = Config.Text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ValueLabel = Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -60, 0, 5),
                Size = UDim2.new(0, 50, 0, 20),
                Font = Enum.Font.Gotham,
                Text = tostring(Value),
                TextColor3 = Theme.SubText,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local BarBG = Create("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                Position = UDim2.new(0, 10, 0, 35),
                Size = UDim2.new(1, -20, 0, 4)
            })
            Create("UICorner", {Parent = BarBG, CornerRadius = UDim.new(1, 0)})
            
            local BarFill = Create("Frame", {
                Parent = BarBG,
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new(0, 0, 1, 0)
            })
            Create("UICorner", {Parent = BarFill, CornerRadius = UDim.new(1, 0)})
            
            local Trigger = Create("TextButton", {
                Parent = BarBG,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })
            
            local function Update(Input)
                local SizeX = math.clamp((Input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                local NewValue = math.floor(Config.Min + ((Config.Max - Config.Min) * SizeX))
                
                TweenService:Create(BarFill, TweenInfo.new(0.1), {Size = UDim2.new(SizeX, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(NewValue)
                Config.Callback(NewValue)
            end
            
            -- Set Initial
            local InitPercent = (Config.Default - Config.Min) / (Config.Max - Config.Min)
            BarFill.Size = UDim2.new(InitPercent, 0, 1, 0)
            
            local Dragging = false
            Trigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Update(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)
        end

        function Tab:AddDropdown(Config)
            Config.Text = Config.Text or "Dropdown"
            Config.Items = Config.Items or {}
            Config.Multi = Config.Multi or false
            Config.Callback = Config.Callback or function() end
            
            local IsOpen = false
            local Selected = Config.Multi and {} or nil
            
            local DropFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.ElementBackground,
                Size = UDim2.new(1, 0, 0, 36),
                ClipsDescendants = true
            })
            Create("UICorner", {Parent = DropFrame, CornerRadius = UDim.new(0, 4)})
            
            local Label = Create("TextLabel", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 0, 36),
                Font = Enum.Font.Gotham,
                Text = Config.Text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Arrow = Create("ImageLabel", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -25, 0, 8),
                Size = UDim2.new(0, 20, 0, 20),
                Image = "rbxassetid://6034818372", -- Down Arrow
                ImageColor3 = Theme.SubText
            })
            
            local Button = Create("TextButton", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                Text = ""
            })
            
            local ListContainer = Create("ScrollingFrame", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 36),
                Size = UDim2.new(1, 0, 0, 0), -- Dynamic
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 2
            })
            Create("UIListLayout", {
                Parent = ListContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })
            Create("UIPadding", {Parent = ListContainer, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})
            
            local function UpdateText()
                if Config.Multi then
                    local count = 0
                    for k,v in pairs(Selected) do count = count + 1 end
                    Label.Text = Config.Text .. " (" .. count .. ")"
                else
                    Label.Text = Config.Text .. ": " .. (Selected or "None")
                end
            end
            
            local function ToggleMenu()
                IsOpen = not IsOpen
                local TargetHeight = IsOpen and math.min(#Config.Items * 32 + 10, 150) or 0
                local TargetFrameHeight = IsOpen and TargetHeight + 36 or 36
                
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, TargetFrameHeight)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 180 or 0}):Play()
                ListContainer.Size = UDim2.new(1, 0, 0, TargetHeight)
                ListContainer.CanvasSize = UDim2.new(0, 0, 0, #Config.Items * 32)
            end
            
            local function AddItem(Val)
                local ItemBtn = Create("TextButton", {
                    Parent = ListContainer,
                    BackgroundColor3 = Theme.Background,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = Val,
                    TextColor3 = Theme.SubText,
                    TextSize = 12,
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = ItemBtn, CornerRadius = UDim.new(0, 4)})
                
                ItemBtn.MouseButton1Click:Connect(function()
                    if Config.Multi then
                        if Selected[Val] then
                            Selected[Val] = nil
                            TweenService:Create(ItemBtn, TweenInfo.new(0.2), {TextColor3 = Theme.SubText, BackgroundColor3 = Theme.Background}):Play()
                        else
                            Selected[Val] = true
                            TweenService:Create(ItemBtn, TweenInfo.new(0.2), {TextColor3 = Theme.Accent, BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
                        end
                        Config.Callback(Selected)
                    else
                        Selected = Val
                        ToggleMenu() -- Close on select if single
                        Config.Callback(Selected)
                        
                        -- Reset colors
                        for _, v in pairs(ListContainer:GetChildren()) do
                            if v:IsA("TextButton") then
                                v.TextColor3 = Theme.SubText
                                v.BackgroundColor3 = Theme.Background
                            end
                        end
                        ItemBtn.TextColor3 = Theme.Accent
                        ItemBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
                    end
                    UpdateText()
                end)
            end
            
            for _, v in pairs(Config.Items) do
                AddItem(v)
            end
            
            Button.MouseButton1Click:Connect(ToggleMenu)
        end

        return Tab
    end
    
    return Window
end

--// Example Usage (If running as LocalScript)
-- Remove the comment block below to test immediately!
--[[
local Window = Library:CreateWindow({
    Title = "Gemini Hub",
    Subtitle = "Best Script 2024",
    Size = UDim2.fromOffset(500, 400)
})

local MainTab = Window:AddTab("Main")
local SettingsTab = Window:AddTab("Settings")

MainTab:AddToggle({
    Text = "Auto Farm",
    Default = false,
    Callback = function(Value)
        print("Auto Farm:", Value)
    end
})

MainTab:AddSlider({
    Text = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

MainTab:AddDropdown({
    Text = "Weapon Select",
    Items = {"Sword", "Bow", "Gun"},
    Multi = false,
    Callback = function(Val)
        print("Selected:", Val)
    end
})

SettingsTab:AddButton({
    Text = "Destroy GUI",
    Callback = function()
        game.CoreGui:FindFirstChild("ModernUI"):Destroy()
    end
})

SettingsTab:AddDropdown({
    Text = "Multi Select Test",
    Items = {"A", "B", "C", "D"},
    Multi = true,
    Callback = function(Table)
        for k,v in pairs(Table) do print(k) end
    end
})
]]

return Library
