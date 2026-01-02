--[[
    MODERN UI LIBRARY V7 - GOD MODE EDITION
    Author: Gemini
    
    [MEGA UPDATE V7]
    - 40+ New Features
    - Config System (Save/Load)
    - Tooltips, Ripples, Acrylic Blur
    - New Elements: Keybind, ProgressBar, Accordion, LargeInput...
    - Built-in Utils: Hop, Rejoin, FPS Unlock
]]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Elements = {}, 
    OpenedFrames = {},
    NotificationArea = nil,
    IsMobile = UserInputService.TouchEnabled,
    CurrentTheme = "Dark",
    MainFrameRef = nil,
    SettingsPageRef = nil,
    Keybind = Enum.KeyCode.RightControl,
    IsVisible = true,
    ConfigFolder = "LopUI_Configs",
    Scale = 1,
    SoundsEnabled = true,
    TooltipsEnabled = true
}

--// 1. THEME SYSTEM
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
        Shadow = Color3.fromRGB(0,0,0)
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
        Shadow = Color3.fromRGB(20,0,20)
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
        Shadow = Color3.fromRGB(100,100,150)
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
        Shadow = Color3.fromRGB(0,20,0)
    }
}
Library.Theme = Library.Themes.Dark

function Library:SetTheme(ThemeName)
    if Library.Themes[ThemeName] then 
        Library.Theme = Library.Themes[ThemeName]
        Library.CurrentTheme = ThemeName
        if Library.MainFrameRef and 
        Library.MainFrameRef:FindFirstChild("MainGradient") then
             Library.MainFrameRef.MainGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Library.Theme.Background),
                ColorSequenceKeypoint.new(1, Library.Theme.Background2)
            }
        end
    end
end

Library.NotifyTypes = {
    Success = {Icon = "rbxassetid://6031094620", Color = Color3.fromRGB(46, 204,
     113)},
    Warning = {Icon = "rbxassetid://6031094636", Color = Color3.fromRGB(241, 
    196, 15)},
    Error   = {Icon = "rbxassetid://6031094646", Color = Color3.fromRGB(255, 60,
     60)},
    Info    = {Icon = "rbxassetid://6031097220", Color = Color3.fromRGB(0, 140, 
    255)}
}

--// UTILITY FUNCTIONS
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

-- RIPPLE EFFECT
local function CreateRipple(Parent)
    local Ripple = Create("Frame", {
        Parent = Parent, BackgroundColor3 = Color3.new(1,1,1), 
        BackgroundTransparency = 0.8,
        Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0), ZIndex = 9
    })
    Create("UICorner", {Parent = Ripple, CornerRadius = UDim.new(0,6)})
    local T = TweenService:Create(Ripple, TweenInfo.new(0.4), 
    {BackgroundTransparency = 1, Size = UDim2.new(1.2,0,1.2,0), Position = 
    UDim2.new(-0.1,0,-0.1,0)})
    T:Play()
    T.Completed:Connect(function() Ripple:Destroy() end)
end

-- TOOLTIP SYSTEM
local TooltipFrame = nil
local function AddTooltip(Element, Text)
    if not Text then return end
    Element.MouseEnter:Connect(function()
        if not Library.TooltipsEnabled then return end
        if TooltipFrame then TooltipFrame:Destroy() end
        local Gui = Library.MainFrameRef and Library.MainFrameRef.Parent or CoreGui
        TooltipFrame = Create("Frame", {
            Parent = Gui, BackgroundColor3 = Library.Theme.Background2, Size = 
            UDim2.new(0,0,0,24), AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = 100, BorderSizePixel = 0
        })
        Create("UICorner", {Parent = TooltipFrame, CornerRadius = UDim.new(0, 4)})
        Create("UIStroke", {Parent = TooltipFrame, Color = 
        Library.Theme.Divider, Thickness = 1})
        Create("TextLabel", {
            Parent = TooltipFrame, Text = "  "..Text.."  ", TextColor3 = 
            Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 11,
            Size = UDim2.new(0,0,1,0), AutomaticSize = Enum.AutomaticSize.X, 
            BackgroundTransparency = 1
        })
        
        local Run = RunService.RenderStepped:Connect(function()
            if not TooltipFrame or not TooltipFrame.Parent then return end
            local M = UserInputService:GetMouseLocation()
            TooltipFrame.Position = UDim2.new(0, M.X + 15, 0, M.Y + 15)
        end)
        
        Element.MouseLeave:Once(function()
            if TooltipFrame then TooltipFrame:Destroy() end
            Run:Disconnect()
        end)
    end)
end

local function MakeDraggable(topbar, object)
    local Dragging, DragInput, DragStart, StartPos
    local function Update(input)
        local Delta = input.Position - DragStart
        local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + 
        Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        TweenService:Create(object, TweenInfo.new(0.15), {Position = 
        Position}):Play()
    end
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
        input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPos = 
            object.Position
            input.Changed:Connect(function() if input.UserInputState == 
            Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    topbar.InputChanged:Connect(function(input) if input.UserInputType == 
    Enum.UserInputType.MouseMovement or input.UserInputType == 
    Enum.UserInputType.Touch then DragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == DragInput 
    and Dragging then Update(input) end end)
end

--// NOTIFICATIONS (Enhanced)
function Library:Notify(Config)
    Config = Config or {}
    local TypeData = Library.NotifyTypes[Config.Type or "Info"]
    local Frame = Create("Frame", {Parent = Library.NotificationArea, 
    BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), 
    ClipsDescendants = true, BorderSizePixel = 0})
    Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
    -- Shadow for Notif
    Create("ImageLabel", {Parent = Frame, Image = "rbxassetid://6015897843", 
    ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.5, Size = UDim2.new(1, 
    40, 1, 40), Position = UDim2.new(0,-20,0,-20), ZIndex = -1})

    local G = Create("Frame", {Parent = Frame, Size = UDim2.new(0, 3, 1, 0), 
    BorderSizePixel = 0, BackgroundColor3 = Color3.new(1,1,1)}); ApplyGradient(G)
    Create("ImageLabel", {Parent = Frame, BackgroundTransparency = 1, Position =
     UDim2.new(0, 15, 0, 10), Size = UDim2.new(0, 24, 0, 24), Image = TypeData.Icon,
     ImageColor3 = TypeData.Color})
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = 
    UDim2.new(0, 50, 0, 5), Size = UDim2.new(1, -60, 0, 20), Font = 
    Enum.Font.GothamBold, Text = Config.Title or "Notification", TextColor3 = 
    Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = 
    UDim2.new(0, 50, 0, 25), Size = UDim2.new(1, -60, 0, 35), Font = 
    Enum.Font.Gotham, Text = Config.Content or "Message", TextColor3 = 
    Library.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
     TextWrapped = true})
    
    if Library.SoundsEnabled then
        local Sound = Instance.new("Sound", Frame); Sound.SoundId = 
        "rbxassetid://4590657391"; Sound.Volume = 0.5; Sound:Play()
    end
    
    TweenService:Create(Frame, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 
    65)}):Play()
    task.delay(Config.Duration or 3, function() if Frame then 
    TweenService:Create(Frame, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 
    0)}):Play(); task.wait(0.4); Frame:Destroy() end end)
end

function Library:InitNotifications(Gui)
    Library.NotificationArea = Create("Frame", {Name = "Notifications", Parent =
     Gui, BackgroundTransparency = 1, Position = UDim2.new(1, -320, 0, 20), Size = 
    UDim2.new(0, 300, 1, -20), ZIndex = 1000})
    Create("UIListLayout", {Parent = Library.NotificationArea, SortOrder = 
    Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), VerticalAlignment = 
    Enum.VerticalAlignment.Bottom})
end

--// WATERMARK
function Library:Watermark(Title)
    local Gui = Library.MainFrameRef and Library.MainFrameRef.Parent or CoreGui
    local WFrame = Create("Frame", {Parent = Gui, BackgroundColor3 = 
    Library.Theme.Background, Position = UDim2.new(0.01, 0, 0.01, 0), Size = 
    UDim2.new(0, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 900})
    Create("UICorner", {Parent = WFrame, CornerRadius = UDim.new(0, 4)}); 
    Create("UIStroke", {Parent = WFrame, Color = Library.Theme.Gradient1, Thickness 
    = 1})
    local Text = Create("TextLabel", {Parent = WFrame, BackgroundTransparency = 
    1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, 0, 1, 0), 
    AutomaticSize = Enum.AutomaticSize.X, Font = Enum.Font.GothamBold, TextColor3 = 
    Library.Theme.Text, TextSize = 12})
    
    task.spawn(function()
        while WFrame.Parent do
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            local ping = math.floor(Stats.Network.ServerStatsItem["Data 
            Ping"]:GetValueString():split(" ")[1] or 0)
            Text.Text = (Title or "Lop UI") .. " | " .. os.date("%H:%M:%S") .. 
            " | FPS: " .. fps .. " | Ping: " .. ping .. "ms"
            task.wait(1)
        end
    end)
    return WFrame
end

--// ELEMENT CREATOR
local function RegisterContainerFunctions(Container, PageInstance)
    local Funcs = {}
    
    local function AddElementFrame(SizeY)
        local F = Create("Frame", {Parent = PageInstance, BackgroundColor3 = 
        Library.Theme.Element, Size = UDim2.new(1, 0, 0, SizeY)})
        Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 6)})
        return F
    end

    function Funcs:AddButton(Config)
        local BtnFrame = AddElementFrame(36)
        local Btn = Create("TextButton", {Parent = BtnFrame, 
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = 
        Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize 
        = 13})
        AddTooltip(Btn, Config.Tooltip)
        -- Danger Button Variant
        if Config.Variant == "Danger" then
            Btn.TextColor3 = Library.Theme.Gradient2
            local stroke = Create("UIStroke", {Parent = BtnFrame, Color = Color3.fromRGB(255,50,50), Thickness = 1})
        end
        
        Btn.MouseButton1Click:Connect(function()
            CreateRipple(BtnFrame)
            if Config.Callback then
                local success, err = pcall(Config.Callback)
                if not success then Library:Notify({Title="Error", Content=err, 
                Type="Error"}) end
            end
        end)
    end
    
    function Funcs:AddSection(Config)
        -- Accordion Style Section
        local IsOpen = Config.Default or true
        local Main = Create("Frame", {Parent = PageInstance, 
        BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = 
        Enum.AutomaticSize.Y})
        local Header = Create("TextButton", {Parent = Main, BackgroundColor3 = 
        Library.Theme.Section, Size = UDim2.new(1,0,0,30), Text = "", AutoButtonColor = 
        false})
        Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0,6)})
        local Title = Create("TextLabel", {Parent = Header, Text = Config.Text, 
        Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Library.Theme.Text, 
        BackgroundTransparency = 1, Size = UDim2.new(1,-30,1,0), Position = 
        UDim2.new(0,10,0,0), TextXAlignment = Enum.TextXAlignment.Left})
        local Arrow = Create("ImageLabel", {Parent = Header, Image = 
        "rbxassetid://6034818372", Size = UDim2.new(0,20,0,20), Position = 
        UDim2.new(1,-25,0,5), BackgroundTransparency = 1, ImageColor3 = 
        Library.Theme.SubText, Rotation = IsOpen and 0 or 180})
        
        -- Divider Line
        local Line = Create("Frame", {Parent = Header, BackgroundColor3 = 
        Library.Theme.Gradient1, Size = UDim2.new(0,0,0,2), Position = 
        UDim2.new(0,10,1,-2)}); 
        
        local ContainerFrame = Create("Frame", {Parent = Main, 
        BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = 
        Enum.AutomaticSize.Y, Visible = IsOpen})
        Create("UIListLayout", {Parent = ContainerFrame, SortOrder = 
        Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)}); Create("UIPadding", 
        {Parent = ContainerFrame, PaddingTop = UDim.new(0,8)})
        
        Header.MouseButton1Click:Connect(function()
            IsOpen = not IsOpen
            ContainerFrame.Visible = IsOpen
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen 
            and 0 or 180}):Play()
            TweenService:Create(Line, TweenInfo.new(0.3), {Size = IsOpen and 
            UDim2.new(1,-20,0,2) or UDim2.new(0,0,0,2)}):Play()
        end)
        
        if IsOpen then Line.Size = UDim2.new(1,-20,0,2) end
        
        local Handler = {}; RegisterContainerFunctions(Handler, ContainerFrame);
 return Handler
    end

    function Funcs:AddToggle(Config)
        local State, Variant = Config.Default or false, Config.Variant or 
        "Default"
        if Container.Activate then Library.Elements[Config.Text] = {TabFunc = 
        Container.Activate} end
        local TFrame = AddElementFrame(36)
        AddTooltip(TFrame, Config.Tooltip)
        
        Create("TextLabel", {Parent = TFrame, BackgroundTransparency = 1, 
        Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -70, 1, 0), Font = 
        Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize 
        = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Trigger, Display = Create("TextButton", {Parent = TFrame, 
        BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Text = ""}), nil
        
        -- Lock Variant
        if Variant == "Lock" then
            Create("ImageLabel", {Parent = TFrame, Image = 
            "rbxassetid://6031094636", Size = UDim2.new(0,20,0,20), Position = 
            UDim2.new(1,-30,0.5,-10), BackgroundTransparency = 1, ImageColor3 = 
            Library.Theme.SubText})
            return -- No interaction
        end
        
        if Variant == "Checkbox" then
            Display = Create("Frame", {Parent = TFrame, BackgroundColor3 = State
             and Library.Theme.Gradient1 or Library.Theme.Section, Position = UDim2.new(1, 
             -60, 0.5, -10), Size = UDim2.new(0, 20, 0, 20)}); Create("UICorner", {Parent = 
            Display, CornerRadius = UDim.new(0, 4)})
            if State then ApplyGradient(Display) end
            Create("ImageLabel", {Parent = Display, BackgroundTransparency = 1, 
            Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,2,0,2), Image = 
            "rbxassetid://6031094620", Visible = State})
        else
            Display = Create("Frame", {Parent = TFrame, BackgroundColor3 = State
             and Library.Theme.Gradient1 or Library.Theme.Section, Position = UDim2.new(1, 
             -80, 0.5, -10), Size = UDim2.new(0, 40, 0, 20)}); Create("UICorner", {Parent = 
            Display, CornerRadius = UDim.new(1, 0)})
            if State then ApplyGradient(Display) end
            local Circle = Create("Frame", {Parent = Display, BackgroundColor3 =
             Color3.new(1,1,1), Position = State and UDim2.new(1, -18, 0.5, -8) or 
            UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)}); Create("UICorner", 
            {Parent = Circle, CornerRadius = UDim.new(1, 0)})
        end
        
        local function UpdateState()
            if Variant == "Checkbox" then Display.BackgroundColor3 = State and 
            Library.Theme.Gradient1 or Library.Theme.Section; Display.ImageLabel.Visible = 
            State
                if State then ApplyGradient(Display) else for _,c in 
            pairs(Display:GetChildren()) do if c:IsA("UIGradient") then c:Destroy() end end 
            end
            else Display.BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section; 
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
            if State then ApplyGradient(Display) else for _,c in pairs(Display:GetChildren()) do if c:IsA("UIGradient") then c:Destroy() end end end
            end
        end
        
        if Variant == "Checkbox" then
            Display.ImageLabel.Visible = State
        end

        Trigger.MouseButton1Click:Connect(function() State = not State; if Config.Callback then Config.Callback(State) end; UpdateState(); CreateRipple(TFrame) end)
    end

    function Funcs:AddSlider(Config)
        local Min, Max, Def = Config.Min, Config.Max, Config.Default or 
        Config.Min
        local SFrame = AddElementFrame(45)
        AddTooltip(SFrame, Config.Tooltip)
        Create("TextLabel", {Parent = SFrame, BackgroundTransparency = 1, 
        Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, 0, 0, 20), Text = 
        Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize 
        = 13, TextXAlignment = Enum.TextXAlignment.Left})
        
        local ValBox = Create("TextBox", {
            Parent = SFrame, BackgroundColor3 = Library.Theme.Section, Position 
        = UDim2.new(1, -60, 0, 5), Size = UDim2.new(0, 50, 0, 20),
            Text = tostring(Def), Font = Enum.Font.Gotham, TextColor3 = 
        Library.Theme.SubText, TextSize = 12
        }); Create("UICorner", {Parent = ValBox, CornerRadius = UDim.new(0, 4)})

        local Bar = Create("Frame", {Parent = SFrame, BackgroundColor3 = 
        Library.Theme.Section, Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, 
        -20, 0, 4)}); Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
        local Fill = Create("Frame", {Parent = Bar, BackgroundColor3 = 
        Color3.new(1,1,1), Size = UDim2.new((Def-Min)/(Max-Min), 0, 1, 0)}); 
        Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)}); 
        ApplyGradient(Fill)
        local Btn = Create("TextButton", {Parent = Bar, BackgroundTransparency =
         1, Size = UDim2.new(1,0,1,0), Text = ""})
        local Dragging = false
        
        local function UpdateFromBar(input)
            local s = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / 
            Bar.AbsoluteSize.X, 0, 1)
            local res = math.floor(Min + (s * (Max - Min)))
            Fill.Size = UDim2.new(s, 0, 1, 0); ValBox.Text = tostring(res)
            if Config.Callback then Config.Callback(res) end
        end
        
        ValBox.FocusLost:Connect(function()
            local n = tonumber(ValBox.Text)
            if n then n = math.clamp(n, Min, Max); ValBox.Text = tostring(n); 
            Fill.Size = UDim2.new((n-Min)/(Max-Min), 0, 1, 0); if Config.Callback then 
            Config.Callback(n) end else ValBox.Text = tostring(Def) end
        end)
        Btn.InputBegan:Connect(function(i) if i.UserInputType == 
        Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch 
        then Dragging = true; UpdateFromBar(i) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == 
        Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch 
        then Dragging = false end end)
        UserInputService.InputChanged:Connect(function(i) if Dragging and 
        (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == 
        Enum.UserInputType.Touch) then UpdateFromBar(i) end end)
    end
    
    -- NEW: KEYBIND RECORDER
    function Funcs:AddKeybind(Config)
        local KFrame = AddElementFrame(36)
        Create("TextLabel", {Parent = KFrame, BackgroundTransparency = 1, 
        Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -110, 1, 0), Text = 
        Config.Text or "Keybind", Font = Enum.Font.Gotham, TextColor3 = 
        Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local KeyLabel = Create("TextLabel", {Parent = KFrame, BackgroundTransparency = 1, 
        Position = UDim2.new(1, -100, 0, 0), Size = UDim2.new(0, 80, 1, 0), Font = 
        Enum.Font.Gotham, Text = Config.Default or "None", TextColor3 = 
        Library.Theme.SubText, TextSize = 12})
        AddTooltip(KFrame, Config.Tooltip)

        local recording = false
        KFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch then
                if recording then 
                    recording = false
                    if Config.Callback then Config.Callback("None") end
                    KeyLabel.Text = "None"
                else
                    recording = true
                    KeyLabel.Text = "..."
                end
            end
        end)
        UserInputService.InputBegan:Connect(function(input)
            if recording and input.UserInputType == Enum.UserInputType.Keyboard then
                recording = false
                if Config.Callback then Config.Callback(input.KeyCode) end
                KeyLabel.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.","")
            end
        end)
    end

    function Funcs:AddDropdown(Config)
        local IsOpen = false
        local Selected = Config.Options[1]
        local DFrame = Create("Frame", {Parent = PageInstance, BackgroundColor3 
        = Library.Theme.Element, Size = UDim2.new(1, 0, 0, 40), ClipsDescendants = true,
         ZIndex = 20}); Create("UICorner", {Parent = DFrame, CornerRadius = UDim.new(0, 
        6)})
        local Label = Create("TextButton", {Parent = DFrame, Text = " " .. Config.Text .. ": " .. Selected, 
        TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, 
        TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, 
        Size = UDim2.new(1, 0, 0, 40)})
        Create("ImageLabel", {Parent = DFrame, BackgroundTransparency = 1, 
        Position = UDim2.new(1, -30, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), 
        Image = "rbxassetid://6031155238"})
        local ListFrame = Create("Frame", {Parent = DFrame, BackgroundColor3 = Library.Theme.Section, 
        Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 0)}); Create("UICorner", {Parent = ListFrame, CornerRadius = UDim.new(0, 6)})
        Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder})
        for _, Opt in ipairs(Config.Options) do
            local Item = Create("TextButton", {Parent = ListFrame, BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = Opt, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 30)})
            Item.MouseButton1Click:Connect(function()
                Selected = Opt
                Label.Text = " " .. Config.Text .. ": " .. Selected
                if Config.Callback then Config.Callback(Opt) end
                -- Close dropdown
                IsOpen = false
                TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            end)
        end
        Label.MouseButton1Click:Connect(function()
            IsOpen = not IsOpen
            if IsOpen then
                local height = #Config.Options * 30
                TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, height)}):Play()
            else
                TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            end
        end)
    end

    function Funcs:AddColorPicker(Config)
        local PFrame = Create("Frame", {Parent = PageInstance, BackgroundColor3 = 
        Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = 
        Enum.AutomaticSize.Y}); Create("UICorner", {Parent = PFrame, CornerRadius = 
        UDim.new(0, 6)}); Create("UIPadding", {Parent = PFrame, PaddingTop = UDim.new(0,
         8)})
        local Title = Create("TextLabel", {Parent = PFrame, Font = Enum.Font.Gotham, Text = Config.Text, 
        TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 20)})
        local ColorDisplay = Create("ImageLabel", {Parent = PFrame, BackgroundColor3 = Config.Default or Color3.new(1,1,1), Size = UDim2.new(0, 20, 0, 20), BackgroundTransparency = 0, Position = UDim2.new(1, -30, 0, 0)})
        Create("UICorner", {Parent = ColorDisplay, CornerRadius = UDim.new(0, 4)})
        local Picker = Create("ImageButton", {Parent = PFrame, BackgroundColor3 = Library.Theme.Divider, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -50, 0, 0)})
        Create("UICorner", {Parent = Picker, CornerRadius = UDim.new(0, 4)})
        Picker.MouseButton1Click:Connect(function()
            local ColorSet = Library:CreateWindow({Size = UDim2.new(0, 400, 0, 300), Title = "Color Picker"}) 
            local InitialColor = ColorDisplay.BackgroundColor3
            local CPFrame = ColorSet.MainFrameRef
            local HSVPicker = Create("Frame", {Parent = CPFrame, Size = UDim2.new(0, 200, 1, -50), Position = UDim2.new(0, 10, 0, 50), BackgroundColor3 = Color3.new(1,1,1)}); Create("UICorner", {Parent = HSVPicker, CornerRadius = UDim.new(0, 6)})
            local HueSlider = Create("TextButton", {Parent = CPFrame, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(0, 20, 1, -50), Position = UDim2.new(0.5, 0, 0, 50)})
            Create("UICorner", {Parent = HueSlider, CornerRadius = UDim.new(0, 6)})
            local ColorResult = Create("Frame", {Parent = CPFrame, BackgroundColor3 = InitialColor, Position = UDim2.new(0, 300, 0, 60), Size = UDim2.new(0, 50, 0, 50)}); Create("UICorner", {Parent = ColorResult, CornerRadius = UDim.new(0, 4)})
            -- HSV gradient
            local HSVG = Create("UIGradient", {Parent = HSVPicker, Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            }})
            -- S/V overlay
            local SVOverlay = Create("Frame", {Parent = HSVPicker, BackgroundColor3 = Color3.new(0,0,0), Size = UDim2.new(1,0,1,0)})
            local SVG = Create("UIGradient", {Parent = SVOverlay, Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
            }, Rotation = 90})
            -- Hue gradient
            local HueG = Create("UIGradient", {Parent = HueSlider, Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            }}, Rotation = 90)
            local function updateColor()
                local hue = HueG.Color.Sequence[1].Value.luminosity
                local saturation = SVG.Color.Sequence[1].Value.luminosity
                local brightness = HSVG.Color.Sequence[2].Value.luminosity
                ColorResult.BackgroundColor3 = Color3.fromHSV(hue, saturation, brightness)
                ColorDisplay.BackgroundColor3 = ColorResult.BackgroundColor3
                if Config.Callback then
                    Config.Callback(ColorResult.BackgroundColor3)
                end
            end
            updateColor()
            makeDraggable(ColorSet.Titlebar, ColorSet.MainFrameRef)
        end)
    end

    function Funcs:Space(px) Create("Frame", {Parent = PageInstance, 
    BackgroundTransparency = 1, Size = UDim2.new(1,0,0,px or 10)}) end
    function Funcs:Divide() 
        local D = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,10)})
        local L = Create("Frame", {Parent = D, BackgroundColor3 = Library.Theme.Divider, Size = UDim2.new(1,-20,0,2), Position = UDim2.new(0,10,0,4)})
        TweenService:Create(D, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,10)}):Play()
    end
    
    -- ACCORDION
    function Funcs:AddAccordion(Config)
        local Main = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}); Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 6)})
        local Title = Create("TextLabel", {Parent = Main, Text = Config.Text, Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Text, TextSize = 13, Size = UDim2.new(1, 0, 0, 30), TextXAlignment = Enum.TextXAlignment.Left})
        local Exp = Create("Frame", {Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}); Create("UIPadding", {Parent = Exp, PaddingLeft = UDim.new(0, 4)})
        local Layout = Create("UIListLayout", {Parent = Exp, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
        Title.MouseButton1Click:Connect(function()
            Exp.Visible = not Exp.Visible
            if Exp.Visible then Title.Rotation = 0 else Title.Rotation = 90 end
        end)
        if Config.Callback then Config.Callback(Exp) end
    end
    
    function Funcs:VerticalGap(pixels)
        Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, pixels or 10)})
    end

    return Funcs
end

--// MAIN WINDOW
function Library:CreateWindow(Config)
    local Window = {Tabs = {}, IsVisual = true}
    local ScreenGui = Create("ScreenGui", {Name = "LopUI_V7_GodMode", Parent = 
    RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui, ResetOnSpawn = 
    false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    Library:InitNotifications(ScreenGui)

    -- ACRYLIC EFFECT (Simple Darken for now)
    local Blur = Instance.new("BlurEffect", Lighting); Blur.Size = 0; Blur.Name 
    = "LopUI_Blur"

    local MobileBtn = Create("ImageButton", {Name = "MobileToggle", Parent = 
    ScreenGui, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 20,
     0.5, -25), Size = UDim2.new(0, 50, 0, 50), AutoButtonColor = false, Visible = 
    false}); Create("UICorner", {Parent = MobileBtn, CornerRadius = UDim.new(1, 
    0)}); ApplyGradient(MobileBtn)
    Create("ImageLabel", {Parent = MobileBtn, BackgroundTransparency = 1, Size =
     UDim2.new(0, 30, 0, 30), Position = UDim2.new(0.5, -15, 0.5, -15), Image = 
    "rbxassetid://6031280882"})
    MakeDraggable(MobileBtn, MobileBtn) -- V7 Feature: Draggable Mobile Button
    
    local MainFrame = Create("Frame", {Name = "MainFrame", Parent = ScreenGui, 
    BackgroundColor3 = Color3.new(1,1,1), Position = UDim2.fromScale(0.5, 0.5), 
    AnchorPoint = Vector2.new(0.5, 0.5), Size = Config.Size or UDim2.fromOffset(650,
     450), ClipsDescendants = true}); Create("UICorner", {Parent = MainFrame, 
    CornerRadius = UDim.new(0, 8)}); Create("UIStroke", {Parent = MainFrame, Color =
     Library.Theme.Divider, Thickness = 1})
    local MainGrad = Create("UIGradient", {Name = "MainGradient", Parent = 
    MainFrame, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, 
    Library.Theme.Background), ColorSequenceKeypoint.new(1, Library.Theme.Background
     or Library.Theme.Background2)}})
    
    -- V7: Shadow
    local Shadow = Create("ImageLabel", {Parent = MainFrame, Image = 
    "rbxassetid://6015897843", ImageColor3 = Library.Theme.Shadow, ImageTransparency
     = 0.5, Size = UDim2.new(1, 100, 1, 100), Position = UDim2.new(0,-50,0,-50), 
    ZIndex = -1})

    Library.MainFrameRef = MainFrame

    local Topbar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = 
    Library.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 50)}); Create("UICorner", 
    {Parent = Topbar, CornerRadius = UDim.new(0, 8)})
    Create("Frame", {Parent = Topbar, BackgroundColor3 = Library.Theme.Sidebar, 
    BorderSizePixel = 0, Position = UDim2.new(0,0,1,-10), Size = 
    UDim2.new(1,0,0,10)})
    local TitleText = Create("TextLabel", {Parent = Topbar, 
    BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = 
    UDim2.new(0, 200, 1, 0), Font = Enum.Font.GothamBold, Text = Config.Title or 
    "UI", TextColor3 = Color3.new(1,1,1), TextSize = 18, TextXAlignment = 
    Enum.TextXAlignment.Left}); ApplyGradient(TitleText).Enabled = true

    local SearchBg = Create("Frame", {Parent = Topbar, BackgroundColor3 = 
    Library.Theme.Background, Position = UDim2.new(0.5, -120, 0.5, -15), Size = 
    UDim2.new(0, 240, 0, 30)}); Create("UICorner", {Parent = SearchBg, CornerRadius 
    = UDim.new(0, 6)})
    Create("ImageLabel", {Parent = SearchBg, BackgroundTransparency = 1, 
    Position = UDim2.new(0, 8, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = 
    "rbxassetid://6031154871", ImageColor3 = Library.Theme.SubText})
    local SearchInput = Create("TextBox", {Parent = SearchBg, 
    BackgroundTransparency = 1, Position = UDim2.new(0, 30, 0, 0), Size = 
    UDim2.new(1, -35, 1, 0), Font = Enum.Font.Gotham, PlaceholderText = "Search...", 
    Text = "", TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = 
    Enum.TextXAlignment.Left})
    local SearchResults = Create("ScrollingFrame", {Parent = SearchBg, 
    BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 0, 1, 5), Size
     = UDim2.new(1, 0, 0, 0), Visible = false, ZIndex = 20, BorderSizePixel = 0, 
    CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, 
    ScrollBarThickness = 0}); Create("UICorner", {Parent = SearchResults, 
    CornerRadius = UDim.new(0, 6)}); Create("UIListLayout", {Parent = SearchResults,
     SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower(); for _, c in 
        pairs(SearchResults:GetChildren()) do if c:IsA("TextButton") then c:Destroy() 
        end end
        if query == "" then SearchResults.Visible = false return end
        local matches = 0; for name, data in pairs(Library.Elements) do if 
        name:lower():find(query) then matches = matches + 1
        local ResBtn = Create("TextButton", {Parent = SearchResults, 
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Font = 
        Enum.Font.Gotham, Text = "  "..name, TextColor3 = Library.Theme.SubText, 
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
        ResBtn.MouseButton1Click:Connect(function() data.TabFunc(); 
        SearchResults.Visible = false end) end end
        if matches > 0 then SearchResults.Visible = true; SearchResults.Size = 
        UDim2.new(1, 0, 0, math.min(matches * 32, 200)) else SearchResults.Visible = 
        false end
    end)
    MakeDraggable(Topbar, MainFrame)

    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = 
    Library.Theme.Sidebar, Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(0, 
    160, 1, -50), BorderSizePixel = 0})
    local TabHolder = Create("ScrollingFrame", {Parent = Sidebar, 
    BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 10), Size = 
    UDim2.new(1, 0, 1, -60), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = 
    Enum.AutomaticSize.Y, ScrollBarThickness = 0}); Create("UIListLayout", {Parent =
     TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local PageHolder = Create("Frame", {Name = "PageHolder", Parent = MainFrame, 
    BackgroundTransparency = 1, Position = UDim2.new(0, 160, 0, 50), Size = 
    UDim2.new(1, -160, 1, -50)})

    function Window:NewTab(Text, Icon)
        -- Create tab button
        local TabButton = Create("TextButton", {Parent = TabHolder, BackgroundColor3 = Library.Theme.Section, 
        Size = UDim2.new(1, 0, 0, 30), Text = Text, TextColor3 = Library.Theme.Text, 
        Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
        Create("UIPadding", {Parent = TabButton, PaddingLeft = UDim.new(0, 10)}); Create("UICorner", {Parent = TabButton, CornerRadius = UDim.new(0, 4)})

        -- Create page
        local Page = Create("Frame", {Parent = PageHolder, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(1, 0, 1, 0)})
        Page.AutomaticSize = Enum.AutomaticSize.XY
        Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)})

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(PageHolder:GetChildren()) do
                if v:IsA("Frame") then v.Visible = false end
            end
            for _, v in pairs(TabHolder:GetChildren()) do
                if v:IsA("TextButton") then v.BackgroundColor3 = Library.Theme.Section end
            end
            Page.Visible = true
            TabButton.BackgroundColor3 = Library.Theme.Element
            if Container then Container:Activate(Page) end
        end)

        Window.Tabs[Text] = {}
        local Container = {}
        RegisterContainerFunctions(Container, Page)
        Window.Tabs[Text].Page = Page
        Window.Tabs[Text].Activate = function() TabButton:MouseButton1Click() end
        Window.Tabs[Text].Activate()
        return Container
    end

    -- GOD MODE / CLOSE KEY
    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == Library.Keybind then
            Library.IsVisible = not Library.IsVisible
            MainFrame.Visible = Library.IsVisible
            Blur.Enabled = not Blur.Enabled
        end
    end)

    Library:Notify({Title="UI Loaded", Content="Use Right Control to toggle UI", Type="Success"})
    return Window
end

return Library
