local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Elements = {}, 
    OpenedFrames = {},
    NotificationArea = nil,
    IsMobile = UserInputService.TouchEnabled,
    CurrentTheme = "Dark",
    MainFrameRef = nil,
    MinimizeBtnRef = nil,
    Keybind = Enum.KeyCode.RightControl,
    IsVisible = true,
    Flags = {},
    ConfigFolder = "ModernUI_Configs"
}

--// THEME SYSTEM
Library.Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 20),
        Background2 = Color3.fromRGB(25, 25, 35),
        Sidebar = Color3.fromRGB(20, 20, 25),
        Section = Color3.fromRGB(25, 25, 30),
        Element = Color3.fromRGB(30, 30, 35),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Divider = Color3.fromRGB(45, 45, 50),
        Gradient1 = Color3.fromRGB(0, 140, 255),
        Gradient2 = Color3.fromRGB(140, 0, 255),
        Red = Color3.fromRGB(255, 60, 60)
    },
    PastelPurple = {
        Background = Color3.fromRGB(24, 20, 30),
        Background2 = Color3.fromRGB(40, 30, 50),
        Sidebar = Color3.fromRGB(30, 25, 40),
        Section = Color3.fromRGB(35, 30, 45),
        Element = Color3.fromRGB(40, 35, 50),
        Text = Color3.fromRGB(255, 230, 255),
        SubText = Color3.fromRGB(180, 160, 190),
        Divider = Color3.fromRGB(60, 50, 70),
        Gradient1 = Color3.fromRGB(255, 150, 255),
        Gradient2 = Color3.fromRGB(150, 100, 255),
        Red = Color3.fromRGB(255, 100, 100)
    },
    Sky = {
        Background = Color3.fromRGB(230, 240, 255),
        Background2 = Color3.fromRGB(200, 220, 255),
        Sidebar = Color3.fromRGB(210, 230, 255),
        Section = Color3.fromRGB(255, 255, 255),
        Element = Color3.fromRGB(240, 245, 255),
        Text = Color3.fromRGB(50, 50, 70),
        SubText = Color3.fromRGB(100, 100, 120),
        Divider = Color3.fromRGB(200, 220, 240),
        Gradient1 = Color3.fromRGB(50, 180, 255),
        Gradient2 = Color3.fromRGB(0, 100, 200),
        Red = Color3.fromRGB(255, 80, 80)
    },
    Garden = {
        Background = Color3.fromRGB(20, 30, 20),
        Background2 = Color3.fromRGB(30, 40, 30),
        Sidebar = Color3.fromRGB(25, 35, 25),
        Section = Color3.fromRGB(30, 40, 30),
        Element = Color3.fromRGB(35, 45, 35),
        Text = Color3.fromRGB(220, 255, 220),
        SubText = Color3.fromRGB(150, 180, 150),
        Divider = Color3.fromRGB(50, 70, 50),
        Gradient1 = Color3.fromRGB(46, 204, 113),
        Gradient2 = Color3.fromRGB(39, 174, 96),
        Red = Color3.fromRGB(200, 60, 60)
    }
}
Library.Theme = Library.Themes.Dark

function Library:SetTheme(ThemeName)
    if Library.Themes[ThemeName] then 
        Library.Theme = Library.Themes[ThemeName]
        Library.CurrentTheme = ThemeName
        if Library.MainFrameRef and Library.MainFrameRef:FindFirstChild("MainGradient") then
             Library.MainFrameRef.MainGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Library.Theme.Background),
                ColorSequenceKeypoint.new(1, Library.Theme.Background2)
            }
        end
    end
end

Library.NotifyTypes = {
    Success = {Icon = "rbxassetid://6031094620", Color = Color3.fromRGB(46, 204, 113)},
    Warning = {Icon = "rbxassetid://6031094636", Color = Color3.fromRGB(241, 196, 15)},
    Error   = {Icon = "rbxassetid://6031094646", Color = Color3.fromRGB(255, 60, 60)},
    Info    = {Icon = "rbxassetid://6031097220", Color = Color3.fromRGB(0, 140, 255)}
}

--// UTILITY
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if class:find("Text") then inst.RichText = true end
    return inst
end

local function ApplyGradient(instance)
    local gradient = Create("UIGradient", {
        Parent = instance,
        Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Library.Theme.Gradient1), ColorSequenceKeypoint.new(1, Library.Theme.Gradient2)}
    })
    return gradient
end

local function CreateRipple(Parent)
    task.spawn(function()
        local Ripple = Create("Frame", {
            Parent = Parent, BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.8,
            Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), Size = UDim2.new(0,0,0,0)
        }); Create("UICorner", {Parent = Ripple, CornerRadius = UDim.new(1,0)})
        local T = TweenService:Create(Ripple, TweenInfo.new(0.5), {Size = UDim2.new(2,0,2,0), BackgroundTransparency = 1})
        T:Play(); T.Completed:Wait(); Ripple:Destroy()
    end)
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
    topbar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then Update(input) end end)
end

--// NOTIFICATIONS
function Library:Notify(Config)
    Config = Config or {}
    local TypeData = Library.NotifyTypes[Config.Type or "Info"]
    local Frame = Create("Frame", {Parent = Library.NotificationArea, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, BorderSizePixel = 0})
    Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
    local G = Create("Frame", {Parent = Frame, Size = UDim2.new(0, 3, 1, 0), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1,1,1)}); ApplyGradient(G)
    Create("ImageLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 10), Size = UDim2.new(0, 24, 0, 24), Image = TypeData.Icon, ImageColor3 = TypeData.Color})
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 5), Size = UDim2.new(1, -60, 0, 20), Font = Enum.Font.GothamBold, Text = Config.Title or "Notification", TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 25), Size = UDim2.new(1, -60, 0, 35), Font = Enum.Font.Gotham, Text = Config.Content or "Message", TextColor3 = Library.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
    
    local Sound = Instance.new("Sound", Frame); Sound.SoundId = "rbxassetid://4590657391"; Sound.Volume = 0.5; Sound:Play()
    
    TweenService:Create(Frame, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 65)}):Play()
    task.delay(Config.Duration or 3, function() if Frame then TweenService:Create(Frame, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 0)}):Play(); task.wait(0.4); Frame:Destroy() end end)
end

function Library:InitNotifications(Gui)
    Library.NotificationArea = Create("Frame", {Name = "Notifications", Parent = Gui, BackgroundTransparency = 1, Position = UDim2.new(1, -320, 0, 20), Size = UDim2.new(0, 300, 1, -20), ZIndex = 1000})
    Create("UIListLayout", {Parent = Library.NotificationArea, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom})
end

--// MINIMIZE TO BUBBLE (V10 NEW)
function Library:InitMinimize(Gui)
    local Btn = Create("ImageButton", {Name = "Bubble", Parent = Gui, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0, 50, 0, 50), Size = UDim2.new(0, 45, 0, 45), Visible = false, AutoButtonColor = false}); Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(1, 0)})
    Create("UIStroke", {Parent = Btn, Color = Library.Theme.Gradient1, Thickness = 2})
    Create("ImageLabel", {Parent = Btn, BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0.5, -12, 0.5, -12), Image = "rbxassetid://6031280882", ImageColor3 = Library.Theme.Gradient1})
    MakeDraggable(Btn, Btn)
    
    Btn.MouseButton1Click:Connect(function()
        Library.IsVisible = true
        Library.MainFrameRef.Visible = true
        Btn.Visible = false
        TweenService:Create(Library.MainFrameRef, TweenInfo.new(0.3), {Size = UDim2.fromOffset(650, 450)}):Play()
    end)
    Library.MinimizeBtnRef = Btn
end

--// TOOLTIP SYSTEM
function Library:AddTooltip(Element, Text)
    local Tooltip = Create("Frame", {Parent = Library.MainFrameRef.Parent, BackgroundColor3 = Color3.fromRGB(20, 20, 20), Size = UDim2.new(0, 0, 0, 26), AutomaticSize = Enum.AutomaticSize.X, Visible = false, ZIndex = 200}); Create("UICorner", {Parent = Tooltip, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = Tooltip, Color = Library.Theme.SubText, Thickness = 1})
    local Label = Create("TextLabel", {Parent = Tooltip, BackgroundTransparency = 1, Position = UDim2.new(0, 5, 0, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Font = Enum.Font.Gotham, Text = Text, TextColor3 = Color3.new(1,1,1), TextSize = 12})
    
    Element.MouseEnter:Connect(function()
        Tooltip.Visible = true
        local MousePos = UserInputService:GetMouseLocation()
        Tooltip.Position = UDim2.new(0, MousePos.X + 15, 0, MousePos.Y - 25)
    end)
    Element.MouseLeave:Connect(function() Tooltip.Visible = false end)
    Element.MouseMoved:Connect(function()
        local MousePos = UserInputService:GetMouseLocation()
        Tooltip.Position = UDim2.new(0, MousePos.X + 15, 0, MousePos.Y - 25)
    end)
end

--// COMMON API V10
local function AddAPI(Obj, Frame, Config)
    function Obj:SetVisible(bool) Frame.Visible = bool end
    function Obj:Destroy() Frame:Destroy() end
    function Obj:SetLocked(bool)
        if Frame:FindFirstChild("LockOverlay") then Frame.LockOverlay:Destroy() end
        if bool then
            local Ov = Create("Frame", {Name = "LockOverlay", Parent = Frame, BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.6, Size = UDim2.new(1,0,1,0), ZIndex = 10}); Create("UICorner", {Parent = Ov, CornerRadius = UDim.new(0,6)})
            Create("ImageLabel", {Parent = Ov, BackgroundTransparency = 1, Size = UDim2.new(0,20,0,20), Position = UDim2.new(0.5,-10,0.5,-10), Image = "rbxassetid://3926305904", ImageColor3 = Color3.new(1,1,1)})
        end
    end
end

--// ELEMENT CREATOR
local function RegisterContainerFunctions(Container, PageInstance)
    local Funcs = {}
    
    local function AddElementFrame(SizeY)
        local F = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, SizeY)})
        Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 6)})
        return F
    end

    function Funcs:AddSection(Title)
        local SFrame = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y})
        local Btn = Create("TextButton", {Parent = SFrame, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 30), Text = "", AutoButtonColor = false}); Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
        local Text = Create("TextLabel", {Parent = Btn, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -40, 1, 0), Text = Title, Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Gradient1, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Arrow = Create("ImageLabel", {Parent = Btn, BackgroundTransparency = 1, Position = UDim2.new(1, -25, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://6034818372", ImageColor3 = Library.Theme.SubText, Rotation = 180})
        
        local ContainerFrame = Create("Frame", {Parent = SFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 35), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
        Create("UIListLayout", {Parent = ContainerFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)}); Create("UIPadding", {Parent = ContainerFrame, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})
        
        local Open = true
        Btn.MouseButton1Click:Connect(function() Open = not Open; TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Open and 180 or 0}):Play(); ContainerFrame.Visible = Open end)
        
        local SectionHandler = {}; RegisterContainerFunctions(SectionHandler, ContainerFrame); AddAPI(SectionHandler, SFrame, {}); return SectionHandler
    end

    function Funcs:AddButton(Config)
        local BtnFrame = AddElementFrame(36)
        local Btn = Create("TextButton", {Parent = BtnFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13})
        if Config.Tooltip then Library:AddTooltip(Btn, Config.Tooltip) end
        Btn.MouseButton1Click:Connect(function()
            CreateRipple(BtnFrame)
            if Config.Callback then Config.Callback() end
        end)
        local Obj = {}; AddAPI(Obj, BtnFrame, Config); function Obj:SetText(t) Btn.Text = t end; return Obj
    end

    function Funcs:AddToggle(Config)
        local State, Variant = Config.Default or false, Config.Variant or "Default"
        if Config.Flag then Library.Flags[Config.Flag] = State end
        
        local TFrame = AddElementFrame(36)
        Create("TextLabel", {Parent = TFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -70, 1, 0), Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Trigger, Display = Create("TextButton", {Parent = TFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Text = ""}), nil
        if Config.Tooltip then Library:AddTooltip(Trigger, Config.Tooltip) end
        
        if Variant == "Checkbox" then
            Display = Create("Frame", {Parent = TFrame, BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section, Position = UDim2.new(1, -60, 0.5, -10), Size = UDim2.new(0, 20, 0, 20)}); Create("UICorner", {Parent = Display, CornerRadius = UDim.new(0, 4)})
            if State then ApplyGradient(Display) end
            Create("ImageLabel", {Parent = Display, BackgroundTransparency = 1, Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,2,0,2), Image = "rbxassetid://6031094620", Visible = State})
        else
            Display = Create("Frame", {Parent = TFrame, BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section, Position = UDim2.new(1, -80, 0.5, -10), Size = UDim2.new(0, 40, 0, 20)}); Create("UICorner", {Parent = Display, CornerRadius = UDim.new(1, 0)})
            if State then ApplyGradient(Display) end
            local Circle = Create("Frame", {Parent = Display, BackgroundColor3 = Color3.new(1,1,1), Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)}); Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
        end
        
        local function UpdateState()
            if Config.Flag then Library.Flags[Config.Flag] = State end
            if Variant == "Checkbox" then Display.BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section; Display.ImageLabel.Visible = State
                if State then ApplyGradient(Display) else for _,c in pairs(Display:GetChildren()) do if c:IsA("UIGradient") then c:Destroy() end end end
            else Display.BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section
                if State then ApplyGradient(Display) else for _,c in pairs(Display:GetChildren()) do if c:IsA("UIGradient") then c:Destroy() end end end
                TweenService:Create(Display.Frame, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
            end
        end
        Trigger.MouseButton1Click:Connect(function() State = not State; if Config.Callback then Config.Callback(State) end; UpdateState() end)
        
        local ToggleObj = {}
        function ToggleObj:Set(val) State = val; UpdateState(); if Config.Callback then Config.Callback(State) end end
        -- RESTORED EXTEND FUNCTIONALITY FROM V6
        function ToggleObj:Extend()
            local Gear = Create("ImageButton", {Parent = TFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -25, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), Image = "rbxassetid://6031280882", ImageColor3 = Library.Theme.SubText})
            local MainFrame, Holder = Library.MainFrameRef, Library.MainFrameRef:FindFirstChild("PageHolder")
            local ExtensionFrame = Create("Frame", {Parent = Holder, BackgroundColor3 = Library.Theme.Sidebar, Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), ZIndex = 5, Visible = false})
            Create("UIStroke", {Parent = ExtensionFrame, Color = Library.Theme.Divider, Thickness = 1})
            local Header = Create("Frame", {Parent = ExtensionFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30)})
            Create("TextLabel", {Parent = Header, Text = Config.Text.." Set.", Font = Enum.Font.GothamBold, Size = UDim2.new(1,-30,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            local CloseBtn = Create("TextButton", {Parent = Header, Text = "X", Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Red, Size = UDim2.new(0,30,1,0), Position = UDim2.new(1,-30,0,0), BackgroundTransparency = 1})
            local ExtContent = Create("ScrollingFrame", {Parent = ExtensionFrame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,35), Size = UDim2.new(1,0,1,-35), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0})
            Create("UIListLayout", {Parent = ExtContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)}); Create("UIPadding", {Parent = ExtContent, PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)})
            Gear.MouseButton1Click:Connect(function() ExtensionFrame.Visible = true; TweenService:Create(ExtensionFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 0, 0)}):Play() end)
            CloseBtn.MouseButton1Click:Connect(function() local t = TweenService:Create(ExtensionFrame, TweenInfo.new(0.3), {Position = UDim2.new(1, 0, 0, 0)}); t:Play(); t.Completed:Connect(function() ExtensionFrame.Visible = false end) end)
            local ExtHandler = {}; RegisterContainerFunctions(ExtHandler, ExtContent); return ExtHandler
        end
        AddAPI(ToggleObj, TFrame, Config); return ToggleObj
    end

    function Funcs:AddSlider(Config)
        local Min, Max, Def = Config.Min, Config.Max, Config.Default or Config.Min
        if Config.Flag then Library.Flags[Config.Flag] = Def end
        local SFrame = AddElementFrame(45)
        Create("TextLabel", {Parent = SFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, 0, 0, 20), Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local ValBox = Create("TextBox", {Parent = SFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(1, -60, 0, 5), Size = UDim2.new(0, 50, 0, 20), Text = tostring(Def), Font = Enum.Font.Gotham, TextColor3 = Library.Theme.SubText, TextSize = 12}); Create("UICorner", {Parent = ValBox, CornerRadius = UDim.new(0, 4)})
        local Bar = Create("Frame", {Parent = SFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 4)}); Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
        local Fill = Create("Frame", {Parent = Bar, BackgroundColor3 = Library.Theme.Gradient1, Size = UDim2.new((Def-Min)/(Max-Min), 0, 1, 0)}); Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)}); ApplyGradient(Fill)
        local Btn = Create("TextButton", {Parent = Bar, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = ""})
        
        local Dragging = false
        local function UpdateFromBar(input)
            local s = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local res = math.floor(Min + (s * (Max - Min)))
            Fill.Size = UDim2.new(s, 0, 1, 0); ValBox.Text = tostring(res)
            if Config.Flag then Library.Flags[Config.Flag] = res end
            if Config.Callback then Config.Callback(res) end
        end
        ValBox.FocusLost:Connect(function() local n = tonumber(ValBox.Text) if n then n = math.clamp(n, Min, Max); ValBox.Text = tostring(n); Fill.Size = UDim2.new((n-Min)/(Max-Min), 0, 1, 0); if Config.Flag then Library.Flags[Config.Flag] = n end; if Config.Callback then Config.Callback(n) end else ValBox.Text = tostring(Def) end end)
        Btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = true; UpdateFromBar(i) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
        UserInputService.InputChanged:Connect(function(i) if Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then UpdateFromBar(i) end end)
        local Obj = {}; AddAPI(Obj, SFrame, Config); function Obj:Set(v) local s = (v-Min)/(Max-Min); Fill.Size = UDim2.new(s,0,1,0); ValBox.Text = tostring(v) end; return Obj
    end

    function Funcs:AddDropdown(Config)
        local IsOpen = false
        local IsMulti = Config.Multi or false
        local Selected = Config.Default or (IsMulti and {} or "None")
        if Config.Flag then Library.Flags[Config.Flag] = Selected end

        local DFrame = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, 40), ClipsDescendants = true}); Create("UICorner", {Parent = DFrame, CornerRadius = UDim.new(0, 6)})
        local LabelText = IsMulti and table.concat(Selected, ", ") or tostring(Selected)
        local Label = Create("TextLabel", {Parent = DFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -40, 0, 40), Text = Config.Text..": "..LabelText, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Arrow = Create("ImageLabel", {Parent = DFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0, 10), Size = UDim2.new(0, 20, 0, 20), Image = "rbxassetid://6034818372", ImageColor3 = Library.Theme.SubText})
        local SearchBar = Create("TextBox", {Parent = DFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 10, 0, 45), Size = UDim2.new(1, -20, 0, 25), Text = "", PlaceholderText = "Search...", TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12}); Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 4)})
        local List = Create("ScrollingFrame", {Parent = DFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 80), Size = UDim2.new(1, 0, 0, 100), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0}); Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
        
        local function Refresh(txt)
            for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            for _, item in pairs(Config.Items) do
                if txt == "" or item:lower():find(txt:lower()) then
                    local IsSel = IsMulti and table.find(Selected, item) or (Selected == item)
                    local B = Create("TextButton", {Parent = List, BackgroundColor3 = IsSel and Library.Theme.Gradient1 or Library.Theme.Section, Size = UDim2.new(1, -10, 0, 25), Text = item, Font = Enum.Font.Gotham, TextColor3 = IsSel and Color3.new(1,1,1) or Library.Theme.SubText, TextSize = 12}); Create("UICorner", {Parent = B, CornerRadius = UDim.new(0, 4)})
                    B.MouseButton1Click:Connect(function()
                        if IsMulti then
                            if table.find(Selected, item) then table.remove(Selected, table.find(Selected, item)) else table.insert(Selected, item) end
                            Label.Text = Config.Text .. ": " .. table.concat(Selected, ", ")
                            if Config.Flag then Library.Flags[Config.Flag] = Selected end
                            Config.Callback(Selected)
                            Refresh(SearchBar.Text)
                        else
                            Selected = item
                            IsOpen = false; TweenService:Create(DFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 40)}):Play(); TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play(); 
                            Label.Text = Config.Text..": "..item; 
                            if Config.Flag then Library.Flags[Config.Flag] = Selected end
                            if Config.Callback then Config.Callback(item) end
                        end
                    end)
                end
            end
        end
        SearchBar:GetPropertyChangedSignal("Text"):Connect(function() Refresh(SearchBar.Text) end)
        local Btn = Create("TextButton", {Parent = DFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,40), Text = ""})
        Btn.MouseButton1Click:Connect(function() IsOpen = not IsOpen; TweenService:Create(DFrame, TweenInfo.new(0.3), {Size = IsOpen and UDim2.new(1, 0, 0, 200) or UDim2.new(1, 0, 0, 40)}):Play(); TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 180 or 0}):Play(); if IsOpen then Refresh("") end end)
        local Obj = {}; AddAPI(Obj, DFrame, Config); return Obj
    end

    function Funcs:AddChipSet(Config)
        local CFrame = AddElementFrame(60)
        Create("TextLabel", {Parent = CFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, 0, 0, 20), Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Scroll = Create("ScrollingFrame", {Parent = CFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -10, 0, 30), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X})
        Create("UIListLayout", {Parent = Scroll, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
        for _, item in ipairs(Config.Items) do
            local Chip = Create("TextButton", {Parent = Scroll, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Text = "  " .. item .. "  ", Font = Enum.Font.Gotham, TextColor3 = Library.Theme.SubText, TextSize = 12}); Create("UICorner", {Parent = Chip, CornerRadius = UDim.new(0, 15)})
            Chip.MouseButton1Click:Connect(function() Config.Callback(item) end)
        end
        local Obj = {}; AddAPI(Obj, CFrame, Config); return Obj
    end

    -- RESTORED DOUBLE CANVAS
    function Funcs:AddDoubleCanvas()
        local CF = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        local L, R = Create("Frame", {Parent = CF, BackgroundTransparency = 1, Size = UDim2.new(0.5, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}), Create("Frame", {Parent = CF, BackgroundTransparency = 1, Size = UDim2.new(0.5, -4, 0, 0), Position = UDim2.new(0.5, 4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        Create("UIListLayout", {Parent = L, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)}); Create("UIListLayout", {Parent = R, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        local LH, RH = {}, {}; RegisterContainerFunctions(LH, L); RegisterContainerFunctions(RH, R); return LH, RH
    end

    -- DRAGGABLE LIST (MOBILE SCROLL LOCK FIXED)
    function Funcs:AddDraggableList(Config)
        local F = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}); Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 6)})
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 0, 30), Text = Config.Text, Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local C = Create("Frame", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}); Create("UIPadding", {Parent = C, PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), PaddingBottom = UDim.new(0,10)})
        Create("UIListLayout", {Parent = C, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
        local Buttons = {}
        local function Refresh()
            for _, v in pairs(C:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end; Buttons = {}
            for i, item in ipairs(Config.Items or {}) do
                local IF = Create("Frame", {Name = item, Parent = C, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = i, ZIndex = 1}); Create("UICorner", {Parent = IF, CornerRadius = UDim.new(0, 4)})
                Create("TextLabel", {Parent = IF, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), Text = item, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                local Grip = Create("ImageButton", {Parent = IF, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0.5, -12), Size = UDim2.new(0, 24, 0, 24), Image = "rbxassetid://6034818372", ImageColor3 = Library.Theme.SubText, Rotation = 90})
                
                -- MOBILE FIX LOGIC: DISABLE SCROLLING WHEN DRAGGING
                local Dragging = false
                Grip.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        IF.BackgroundColor3 = Library.Theme.Gradient1; IF.ZIndex = 5
                        if PageInstance:IsA("ScrollingFrame") then PageInstance.ScrollingEnabled = false end -- SCROLL LOCK
                        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then
                            Dragging = false; IF.BackgroundColor3 = Library.Theme.Element; IF.ZIndex = 1
                            if PageInstance:IsA("ScrollingFrame") then PageInstance.ScrollingEnabled = true end -- UNLOCK
                            if Config.Callback then
                                local NewOrder = {}; local Sorted = {}
                                for _, btn in pairs(Buttons) do table.insert(Sorted, btn) end
                                table.sort(Sorted, function(a,b) return a.LayoutOrder < b.LayoutOrder end)
                                for _, btn in pairs(Sorted) do table.insert(NewOrder, btn.Name) end
                                Config.Callback(NewOrder)
                            end
                        end end)
                    end
                end)
                Grip.InputChanged:Connect(function(input)
                    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local CY = input.Position.Y
                        for _, other in pairs(Buttons) do
                            if other ~= IF then
                                local OY = other.AbsolutePosition.Y
                                if CY > OY and CY < (OY + other.AbsoluteSize.Y) then
                                    local t = IF.LayoutOrder; IF.LayoutOrder = other.LayoutOrder; other.LayoutOrder = t
                                end
                            end
                        end
                    end
                end)
                table.insert(Buttons, IF)
            end
        end
        Refresh()
        local Obj = {}; AddAPI(Obj, F, Config); function Obj:Set(i) Config.Items = i; Refresh() end; return Obj
    end

    -- NEW ELEMENTS (V10 ADDITIONS)
    function Funcs:AddKnob(Config) -- Radial Slider
        local Min, Max, Def = Config.Min, Config.Max, Config.Default or Config.Min
        local F = AddElementFrame(80)
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -90, 1, 0), Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Circle = Create("Frame", {Parent = F, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(1, -70, 0.5, -30), Size = UDim2.new(0, 60, 0, 60)}); Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
        local Ind = Create("Frame", {Parent = Circle, BackgroundColor3 = Library.Theme.Gradient1, Size = UDim2.new(0, 4, 0, 15), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0)})
        local Val = Create("TextLabel", {Parent = Circle, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = tostring(Def), Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Text, TextSize = 14})
        local Dragging = false
        local function Update(Input)
            local Center = Circle.AbsolutePosition + (Circle.AbsoluteSize/2)
            local Vec = Vector2.new(Input.Position.X, Input.Position.Y) - Center
            local Ang = math.atan2(Vec.Y, Vec.X) + math.rad(90)
            local P = (math.deg(Ang)+180)/360
            local V = math.floor(Min + (P*(Max-Min)))
            Ind.Rotation = math.deg(Ang)
            Ind.Position = UDim2.new(0.5+(math.sin(Ang)*0.4),0,0.5-(math.cos(Ang)*0.4),0)
            Val.Text = tostring(V)
            if Config.Callback then Config.Callback(V) end
        end
        Circle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then Dragging=true; Update(i) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then Dragging=false end end)
        UserInputService.InputChanged:Connect(function(i) if Dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then Update(i) end end)
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end

    function Funcs:AddGraph(Config)
        local F = AddElementFrame(100)
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, 0, 0, 15), Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
        local Area = Create("Frame", {Parent = F, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -20, 0, 65), ClipsDescendants = true}); Create("UICorner", {Parent = Area, CornerRadius = UDim.new(0, 4)})
        local Folder = Create("Folder", {Parent = Area})
        local Values = {}
        local Obj = {}
        function Obj:Update(V)
            table.insert(Values, V); if #Values > 40 then table.remove(Values, 1) end
            Folder:ClearAllChildren(); local Max = 1; for _,v in pairs(Values) do if v>Max then Max=v end end
            local W = Area.AbsoluteSize.X/40
            for i = 1, #Values-1 do
                local Y1, Y2 = math.clamp(Values[i]/Max, 0, 1), math.clamp(Values[i+1]/Max, 0, 1)
                local L = Create("Frame", {Parent = Folder, BackgroundColor3 = Library.Theme.Gradient1, BorderSizePixel = 0})
                local P1, P2 = Vector2.new((i-1)*W, Area.AbsoluteSize.Y*(1-Y1)), Vector2.new(i*W, Area.AbsoluteSize.Y*(1-Y2))
                local Dist, Ang = (P2-P1).Magnitude, math.atan2(P2.Y-P1.Y, P2.X-P1.X)
                L.Size = UDim2.new(0, Dist, 0, 2); L.Position = UDim2.new(0, P1.X, 0, P1.Y); L.Rotation = math.deg(Ang)
            end
        end
        AddAPI(Obj, F, Config); return Obj
    end

    function Funcs:AddDualLabel(Config)
        local F = AddElementFrame(30)
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), Text = Config.Title, Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, -10, 1, 0), Text = Config.Value, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Gradient1, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right})
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end

    -- OTHER BASIC FUNCTIONS (Restored)
    function Funcs:AddParagraph(Config)
        local F = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}); Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 6)}); Create("UIPadding", {Parent = F, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Font = Enum.Font.GothamBold, Text = Config.Title, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,25), Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = Config.Content, TextColor3 = Library.Theme.SubText, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left})
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end
    function Funcs:AddTextbox(Config) local F = AddElementFrame(50); Create("TextLabel", {Parent = F, Text = Config.Text, Position = UDim2.new(0,10,0,5), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left}); local B = Create("TextBox", {Parent = F, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0,10,0,25), Size = UDim2.new(1,-20,0,20), Text = "", PlaceholderText = Config.Placeholder or "Input...", Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text}); Create("UICorner", {Parent = B, CornerRadius = UDim.new(0,4)}); B.FocusLost:Connect(function() if Config.Callback then Config.Callback(B.Text) end end); local Obj = {}; AddAPI(Obj, F, Config); return Obj end
    function Funcs:AddKeybind(Config)
        local F = AddElementFrame(36); local Key = Config.Default or Enum.KeyCode.F
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -100, 1, 0), Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local B = Create("TextButton", {Parent = F, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(1, -90, 0.5, -10), Size = UDim2.new(0, 80, 0, 20), Text = Key.Name, Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.SubText, TextSize = 12}); Create("UICorner", {Parent = B, CornerRadius = UDim.new(0, 4)})
        local Listening = false; B.MouseButton1Click:Connect(function() Listening = true; B.Text = "..."; B.TextColor3 = Library.Theme.Gradient1 end)
        UserInputService.InputBegan:Connect(function(i) if Listening and i.UserInputType == Enum.UserInputType.Keyboard then Key = i.KeyCode; B.Text = Key.Name; B.TextColor3 = Library.Theme.SubText; Listening = false; if Config.Callback then Config.Callback(Key) end end end)
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end
    function Funcs:AddColorPicker(Config)
        local F = AddElementFrame(40); Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-50,1,0), Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
        local P = Create("TextButton", {Parent = F, Position = UDim2.new(1,-40,0.5,-10), Size = UDim2.new(0,30,0,20), BackgroundColor3 = Config.Default or Color3.new(1,1,1), Text = ""}); Create("UICorner", {Parent = P, CornerRadius = UDim.new(0,4)})
        local Obj = {}; AddAPI(Obj, F, Config); return Obj -- Simplified for V10
    end

    for k, v in pairs(Funcs) do Container[k] = v end
end

--// CONFIG SYSTEM
function Library:SaveConfig()
    if not isfolder(Library.ConfigFolder) then makefolder(Library.ConfigFolder) end
    writefile(Library.ConfigFolder .. "/config.json", HttpService:JSONEncode(Library.Flags))
    Library:Notify({Title = "Config", Content = "Saved successfully!", Type = "Success"})
end
function Library:LoadConfig()
    if isfile(Library.ConfigFolder .. "/config.json") then
        Library.Flags = HttpService:JSONDecode(readfile(Library.ConfigFolder .. "/config.json"))
        Library:Notify({Title = "Config", Content = "Loaded successfully!", Type = "Success"})
    end
end

--// MAIN WINDOW CREATION
function Library:CreateWindow(Config)
    if Library.ScreenGuiRef then Library.ScreenGuiRef:Destroy() end
    local Gui = Create("ScreenGui", {Name = "ModernUI_V10", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    Library.ScreenGuiRef = Gui
    Library:InitNotifications(Gui)
    Library:InitMinimize(Gui) -- V10

    local Main = Create("Frame", {Name = "MainFrame", Parent = Gui, BackgroundColor3 = Color3.new(1,1,1), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Size = Config.Size or UDim2.fromOffset(650, 450), ClipsDescendants = true}); Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 8)}); Create("UIStroke", {Parent = Main, Color = Library.Theme.Divider, Thickness = 1})
    local Grad = Create("UIGradient", {Name = "MainGradient", Parent = Main, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Library.Theme.Background), ColorSequenceKeypoint.new(1, Library.Theme.Background or Library.Theme.Background2)}})
    Library.MainFrameRef = Main
    
    local Top = Create("Frame", {Parent = Main, BackgroundColor3 = Library.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 50)}); Create("UICorner", {Parent = Top, CornerRadius = UDim.new(0, 8)})
    Create("Frame", {Parent = Top, BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0, Position = UDim2.new(0,0,1,-10), Size = UDim2.new(1,0,0,10)})
    local Title = Create("TextLabel", {Parent = Top, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0, 200, 1, 0), Font = Enum.Font.GothamBold, Text = Config.Title or "UI", TextColor3 = Color3.new(1,1,1), TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left}); ApplyGradient(Title).Enabled = true

    -- SEARCH BAR (RESTORED)
    local SearchBg = Create("Frame", {Parent = Top, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0.5, -120, 0.5, -15), Size = UDim2.new(0, 240, 0, 30)}); Create("UICorner", {Parent = SearchBg, CornerRadius = UDim.new(0, 6)})
    Create("ImageLabel", {Parent = SearchBg, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://6031154871", ImageColor3 = Library.Theme.SubText})
    local SearchInput = Create("TextBox", {Parent = SearchBg, BackgroundTransparency = 1, Position = UDim2.new(0, 30, 0, 0), Size = UDim2.new(1, -35, 1, 0), Font = Enum.Font.Gotham, PlaceholderText = "Search...", Text = "", TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    
    -- CLOSE/MINIMIZE BUTTON
    local CloseBtn = Create("TextButton", {Parent = Top, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, 0.5, -15), Text = "-", Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Text, TextSize = 20})
    CloseBtn.MouseButton1Click:Connect(function() Library.IsVisible = false; Main.Visible = false; Library.MinimizeBtnRef.Visible = true end)
    
    MakeDraggable(Top, Main)

    local Sidebar = Create("Frame", {Parent = Main, BackgroundColor3 = Library.Theme.Sidebar, Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(0, 160, 1, -50), BorderSizePixel = 0})
    local TabHolder = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 10), Size = UDim2.new(1, 0, 1, -60), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0}); Create("UIListLayout", {Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local PageHolder = Create("Frame", {Name = "PageHolder", Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(0, 170, 0, 60), Size = UDim2.new(1, -180, 1, -70), ClipsDescendants = true})

    -- PROFILE (RESTORED)
    local Profile = Create("Frame", {Parent = Sidebar, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0, 0, 1, -50), Size = UDim2.new(1, 0, 0, 50), BorderSizePixel = 0})
    local Avatar = Create("ImageLabel", {Parent = Profile, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0.5, -15), Size = UDim2.new(0, 30, 0, 30), Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)}); Create("UICorner", {Parent = Avatar, CornerRadius = UDim.new(1, 0)})
    Create("TextLabel", {Parent = Profile, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 2), Size = UDim2.new(0, 80, 0, 20), Font = Enum.Font.GothamBold, Text = LocalPlayer.Name, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = Profile, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 20), Size = UDim2.new(0, 80, 0, 15), Font = Enum.Font.Gotham, Text = "V10 ULTIMATE", TextColor3 = Library.Theme.Gradient1, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left})

    -- SETTINGS BUTTON & PAGE (RESTORED)
    local SettingsBtn = Create("TextButton", {Parent = Profile, BackgroundTransparency = 1, Size = UDim2.new(0, 25, 0, 25), Position = UDim2.new(1, -30, 0.5, -12.5), Text = ""}); Create("ImageLabel", {Parent = SettingsBtn, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Image = "rbxassetid://6031280882", ImageColor3 = Library.Theme.SubText})

    local Window = {}
    function Window:CreateTab(Name)
        local Tab = {Elements = {}}
        local Page = Create("ScrollingFrame", {Name = Name, Parent = PageHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0})
        Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        Create("UIPadding", {Parent = Page, PaddingRight = UDim.new(0, 5)})
        
        local Btn = Create("TextButton", {Parent = TabHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Font = Enum.Font.GothamBold, Text = "  "..Name, TextColor3 = Library.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Ind = Create("Frame", {Parent = Btn, BackgroundColor3 = Color3.new(1,1,1), Position = UDim2.new(0, 0, 0, 6), Size = UDim2.new(0, 3, 1, -12), Visible = false}); ApplyGradient(Ind)
        
        Btn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabHolder:GetDescendants()) do if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = Library.Theme.SubText}):Play(); if v:FindFirstChild("Frame") then v.Frame.Visible = false end end end
            for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end
            TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Text}):Play(); Ind.Visible = true; Page.Visible = true
        end)
        RegisterContainerFunctions(Tab, Page); return Tab
    end
    
    -- BUILT-IN SETTINGS PAGE (RESTORED)
    local SettingsPage = Create("ScrollingFrame", {Name = "Settings", Parent = PageHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0}); Create("UIListLayout", {Parent = SettingsPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
    local SettingsHandler = {}; RegisterContainerFunctions(SettingsHandler, SettingsPage)
    SettingsBtn.MouseButton1Click:Connect(function() 
        for _, v in pairs(TabHolder:GetDescendants()) do if v:IsA("TextButton") then v.TextColor3 = Library.Theme.SubText; if v:FindFirstChild("Frame") then v.Frame.Visible = false end end end
        for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end; SettingsPage.Visible = true 
    end)
    
    SettingsHandler:AddParagraph({Title = "Theme Settings", Content = "Customize your UI appearance."})
    SettingsHandler:AddChipSet({Text = "Themes", Items = {"Dark", "PastelPurple", "Sky", "Garden"}, Callback = function(v) Library:SetTheme(v) end})
    SettingsHandler:AddToggle({Text = "Rainbow Mode", Callback = function(v) 
        -- Rainbow Logic Simplified
        if v then task.spawn(function() while v do local h=tick()%5/5; Library.Theme.Gradient1=Color3.fromHSV(h,1,1); Library.Theme.Gradient2=Color3.fromHSV(h+.5,1,1); if Grad then Grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Library.Theme.Background),ColorSequenceKeypoint.new(1,Library.Theme.Background2)} end; task.wait() end end) else Library:SetTheme(Library.CurrentTheme) end
    end})
    SettingsHandler:AddSlider({Text = "Transparency", Min = 0, Max = 100, Default = 0, Callback = function(v) Main.BackgroundTransparency = v/100 end})
   -- SettingsHandler:Divide()
    SettingsHandler:AddButton({Text = "Save Config", Callback = function() Library:SaveConfig() end})
    SettingsHandler:AddButton({Text = "Load Config", Callback = function() Library:LoadConfig() end})
    SettingsHandler:AddKeybind({Text = "Menu Keybind", Default = Enum.KeyCode.RightControl, Callback = function(k) Library.Keybind = k end})
    SettingsHandler:AddButton({Text = "Unload UI", Callback = function() Gui:Destroy() end})

    return Window
end

return Library
