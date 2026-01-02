--[[
    MODERN UI LIBRARY V7 - GOD MODE (FIXED EDITION)
    Author: Gemini (Fixed Bugs)
    
    [FIX LOG]
    - Fixed Intro Animation stuck/crash
    - Fixed Section/Accordion logic
    - Fixed Dropdown ZIndex issues
    - Fixed Tooltip positioning error
    - Added Safety Checks for Config/Callback
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
    IsMobile = UserInputService.TouchEnabled,
    CurrentTheme = "Dark",
    MainFrameRef = nil,
    Keybind = Enum.KeyCode.RightControl,
    IsVisible = true,
    SoundsEnabled = true,
    TooltipsEnabled = true
}

--// THEMES
Library.Themes = {
    Dark = {Background = Color3.fromRGB(15,15,20), Background2 = Color3.fromRGB(25,25,35), Sidebar = Color3.fromRGB(20,20,25), Section = Color3.fromRGB(25,25,30), Element = Color3.fromRGB(30,30,35), Text = Color3.fromRGB(240,240,240), SubText = Color3.fromRGB(160,160,160), Divider = Color3.fromRGB(45,45,50), Gradient1 = Color3.fromRGB(0,140,255), Gradient2 = Color3.fromRGB(140,0,255), Shadow = Color3.fromRGB(0,0,0)},
    PastelPurple = {Background = Color3.fromRGB(24,20,30), Background2 = Color3.fromRGB(40,30,50), Sidebar = Color3.fromRGB(30,25,40), Section = Color3.fromRGB(35,30,45), Element = Color3.fromRGB(40,35,50), Text = Color3.fromRGB(255,230,255), SubText = Color3.fromRGB(180,160,190), Divider = Color3.fromRGB(60,50,70), Gradient1 = Color3.fromRGB(255,150,255), Gradient2 = Color3.fromRGB(150,100,255), Shadow = Color3.fromRGB(20,0,20)},
    Sky = {Background = Color3.fromRGB(230,240,255), Background2 = Color3.fromRGB(200,220,255), Sidebar = Color3.fromRGB(210,230,255), Section = Color3.fromRGB(255,255,255), Element = Color3.fromRGB(240,245,255), Text = Color3.fromRGB(50,50,70), SubText = Color3.fromRGB(100,100,120), Divider = Color3.fromRGB(200,220,240), Gradient1 = Color3.fromRGB(50,180,255), Gradient2 = Color3.fromRGB(0,100,200), Shadow = Color3.fromRGB(100,100,150)},
    Garden = {Background = Color3.fromRGB(20,30,20), Background2 = Color3.fromRGB(30,40,30), Sidebar = Color3.fromRGB(25,35,25), Section = Color3.fromRGB(30,40,30), Element = Color3.fromRGB(35,45,35), Text = Color3.fromRGB(220,255,220), SubText = Color3.fromRGB(150,180,150), Divider = Color3.fromRGB(50,70,50), Gradient1 = Color3.fromRGB(46,204,113), Gradient2 = Color3.fromRGB(39,174,96), Shadow = Color3.fromRGB(0,20,0)}
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
    local gradient = Create("UIGradient", {Parent = instance, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Library.Theme.Gradient1), ColorSequenceKeypoint.new(1, Library.Theme.Gradient2)}})
    return gradient
end

local function CreateRipple(Parent)
    local Ripple = Create("Frame", {Parent = Parent, BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.8, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0), ZIndex = 9})
    Create("UICorner", {Parent = Ripple, CornerRadius = UDim.new(0,6)})
    local T = TweenService:Create(Ripple, TweenInfo.new(0.4), {BackgroundTransparency = 1, Size = UDim2.new(1.2,0,1.2,0), Position = UDim2.new(-0.1,0,-0.1,0)})
    T:Play()
    T.Completed:Connect(function() Ripple:Destroy() end)
end

local TooltipFrame = nil
local function AddTooltip(Element, Text)
    if not Text then return end
    Element.MouseEnter:Connect(function()
        if not Library.TooltipsEnabled then return end
        if TooltipFrame then TooltipFrame:Destroy() end
        local Gui = Library.MainFrameRef and Library.MainFrameRef.Parent or CoreGui
        TooltipFrame = Create("Frame", {Parent = Gui, BackgroundColor3 = Library.Theme.Background2, Size = UDim2.new(0,0,0,24), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 200, BorderSizePixel = 0})
        Create("UICorner", {Parent = TooltipFrame, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = TooltipFrame, Color = Library.Theme.Divider, Thickness = 1})
        Create("TextLabel", {Parent = TooltipFrame, Text = "  "..Text.."  ", TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 11, Size = UDim2.new(0,0,1,0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1})
        local Run = RunService.RenderStepped:Connect(function()
            if not TooltipFrame or not TooltipFrame.Parent then return end
            local M = UserInputService:GetMouseLocation()
            TooltipFrame.Position = UDim2.new(0, M.X + 15, 0, M.Y + 15)
        end)
        Element.MouseLeave:Once(function() if TooltipFrame then TooltipFrame:Destroy() end; Run:Disconnect() end)
    end)
end

local function MakeDraggable(topbar, object)
    local Dragging, DragInput, DragStart, StartPos
    local function Update(input)
        local Delta = input.Position - DragStart
        local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        TweenService:Create(object, TweenInfo.new(0.15), {Position = Position}):Play()
    end
    topbar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = true; DragStart = input.Position; StartPos = object.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end) end end)
    topbar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then Update(input) end end)
end

function Library:Notify(Config)
    Config = Config or {}
    local TypeData = Library.NotifyTypes[Config.Type or "Info"]
    local Frame = Create("Frame", {Parent = Library.NotificationArea, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, BorderSizePixel = 0})
    Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
    Create("ImageLabel", {Parent = Frame, Image = "rbxassetid://6015897843", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.5, Size = UDim2.new(1, 40, 1, 40), Position = UDim2.new(0,-20,0,-20), ZIndex = -1})
    local G = Create("Frame", {Parent = Frame, Size = UDim2.new(0, 3, 1, 0), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1,1,1)}); ApplyGradient(G)
    Create("ImageLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 10), Size = UDim2.new(0, 24, 0, 24), Image = TypeData.Icon, ImageColor3 = TypeData.Color})
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 5), Size = UDim2.new(1, -60, 0, 20), Font = Enum.Font.GothamBold, Text = Config.Title or "Notification", TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 25), Size = UDim2.new(1, -60, 0, 35), Font = Enum.Font.Gotham, Text = Config.Content or "Message", TextColor3 = Library.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
    if Library.SoundsEnabled then local Sound = Instance.new("Sound", Frame); Sound.SoundId = "rbxassetid://4590657391"; Sound.Volume = 0.5; Sound:Play() end
    TweenService:Create(Frame, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 65)}):Play()
    task.delay(Config.Duration or 3, function() if Frame then TweenService:Create(Frame, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 0)}):Play(); task.wait(0.4); Frame:Destroy() end end)
end
function Library:InitNotifications(Gui)
    Library.NotificationArea = Create("Frame", {Name = "Notifications", Parent = Gui, BackgroundTransparency = 1, Position = UDim2.new(1, -320, 0, 20), Size = UDim2.new(0, 300, 1, -20), ZIndex = 1000})
    Create("UIListLayout", {Parent = Library.NotificationArea, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom})
end
function Library:Watermark(Title)
    local Gui = Library.MainFrameRef and Library.MainFrameRef.Parent or CoreGui
    local WFrame = Create("Frame", {Parent = Gui, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0.01, 0, 0.01, 0), Size = UDim2.new(0, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 900})
    Create("UICorner", {Parent = WFrame, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = WFrame, Color = Library.Theme.Gradient1, Thickness = 1})
    local Text = Create("TextLabel", {Parent = WFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Text, TextSize = 12})
    task.spawn(function()
        while WFrame.Parent do
            local fps = math.floor(1 / RunService.RenderStepped:Wait()); local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1] or 0)
            Text.Text = (Title or "Lop UI") .. " | " .. os.date("%H:%M:%S") .. " | FPS: " .. fps .. " | Ping: " .. ping .. "ms"
            task.wait(1)
        end
    end)
    return WFrame
end

--// ELEMENT CREATOR
local function RegisterContainerFunctions(Container, PageInstance)
    local Funcs = {}
    local function AddElementFrame(SizeY)
        local F = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, SizeY), ZIndex = 1})
        Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 6)})
        return F
    end

    function Funcs:AddButton(Config)
        local BtnFrame = AddElementFrame(36)
        local Btn = Create("TextButton", {Parent = BtnFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13})
        AddTooltip(Btn, Config.Tooltip)
        if Config.Variant == "Danger" then Btn.TextColor3 = Library.Theme.Gradient2; BtnFrame.UIStroke = Create("UIStroke", {Parent = BtnFrame, Color = Color3.fromRGB(255,50,50), Thickness = 1}) end
        Btn.MouseButton1Click:Connect(function() CreateRipple(BtnFrame); if Config.Callback then local success, err = pcall(Config.Callback); if not success then Library:Notify({Title="Error", Content=tostring(err), Type="Error"}) end end end)
    end
    
    function Funcs:AddSection(Config)
        local IsOpen = Config.Default or true
        local Main = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y})
        local Header = Create("TextButton", {Parent = Main, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1,0,0,30), Text = "", AutoButtonColor = false})
        Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0,6)})
        Create("TextLabel", {Parent = Header, Text = Config.Text, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Library.Theme.Text, BackgroundTransparency = 1, Size = UDim2.new(1,-30,1,0), Position = UDim2.new(0,10,0,0), TextXAlignment = Enum.TextXAlignment.Left})
        local Arrow = Create("ImageLabel", {Parent = Header, Image = "rbxassetid://6034818372", Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,-25,0,5), BackgroundTransparency = 1, ImageColor3 = Library.Theme.SubText, Rotation = IsOpen and 0 or 180})
        local Line = Create("Frame", {Parent = Header, BackgroundColor3 = Library.Theme.Gradient1, Size = UDim2.new(0,0,0,2), Position = UDim2.new(0,10,1,-2)})
        local ContainerFrame = Create("Frame", {Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Visible = IsOpen, Position = UDim2.new(0,0,0,35)})
        Create("UIListLayout", {Parent = ContainerFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)}); Create("UIPadding", {Parent = ContainerFrame, PaddingTop = UDim.new(0,8)})
        Header.MouseButton1Click:Connect(function() IsOpen = not IsOpen; ContainerFrame.Visible = IsOpen; TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 0 or 180}):Play(); TweenService:Create(Line, TweenInfo.new(0.3), {Size = IsOpen and UDim2.new(1,-20,0,2) or UDim2.new(0,0,0,2)}):Play() end)
        if IsOpen then Line.Size = UDim2.new(1,-20,0,2) end
        local Handler = {}; RegisterContainerFunctions(Handler, ContainerFrame); return Handler
    end

    function Funcs:AddToggle(Config)
        local State, Variant = Config.Default or false, Config.Variant or "Default"
        if Container.Activate then Library.Elements[Config.Text] = {TabFunc = Container.Activate} end
        local TFrame = AddElementFrame(36)
        AddTooltip(TFrame, Config.Tooltip)
        Create("TextLabel", {Parent = TFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -70, 1, 0), Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Trigger, Display = Create("TextButton", {Parent = TFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Text = ""}), nil
        if Variant == "Lock" then Create("ImageLabel", {Parent = TFrame, Image = "rbxassetid://6031094636", Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,-30,0.5,-10), BackgroundTransparency = 1, ImageColor3 = Library.Theme.SubText}); return end
        if Variant == "Checkbox" then Display = Create("Frame", {Parent = TFrame, BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section, Position = UDim2.new(1, -60, 0.5, -10), Size = UDim2.new(0, 20, 0, 20)}); Create("UICorner", {Parent = Display, CornerRadius = UDim.new(0, 4)}); if State then ApplyGradient(Display) end; Create("ImageLabel", {Parent = Display, BackgroundTransparency = 1, Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,2,0,2), Image = "rbxassetid://6031094620", Visible = State})
        else Display = Create("Frame", {Parent = TFrame, BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section, Position = UDim2.new(1, -80, 0.5, -10), Size = UDim2.new(0, 40, 0, 20)}); Create("UICorner", {Parent = Display, CornerRadius = UDim.new(1, 0)}); if State then ApplyGradient(Display) end; local Circle = Create("Frame", {Parent = Display, BackgroundColor3 = Color3.new(1,1,1), Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)}); Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)}) end
        local function UpdateState()
            if Variant == "Checkbox" then Display.BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section; Display.ImageLabel.Visible = State; if State then ApplyGradient(Display) else for _,c in pairs(Display:GetChildren()) do if c:IsA("UIGradient") then c:Destroy() end end end
            else Display.BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section; if State then ApplyGradient(Display) else for _,c in pairs(Display:GetChildren()) do if c:IsA("UIGradient") then c:Destroy() end end end; TweenService:Create(Display.Frame, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play() end
        end
        Trigger.MouseButton1Click:Connect(function() State = not State; if Config.Callback then Config.Callback(State) end; UpdateState(); CreateRipple(TFrame) end)
        local ToggleObj = {}
        function ToggleObj:Extend()
            local Gear = Create("ImageButton", {Parent = TFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -25, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), Image = "rbxassetid://6031280882", ImageColor3 = Library.Theme.SubText})
            local Holder = Library.MainFrameRef:FindFirstChild("PageHolder")
            if not Holder then return end
            local ExtensionFrame = Create("Frame", {Parent = Holder, BackgroundColor3 = Library.Theme.Sidebar, Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), ZIndex = 30, Visible = false}); Create("UIStroke", {Parent = ExtensionFrame, Color = Library.Theme.Divider, Thickness = 1})
            local Header = Create("Frame", {Parent = ExtensionFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30)}); Create("TextLabel", {Parent = Header, Text = Config.Text.." Set.", Font = Enum.Font.GothamBold, Size = UDim2.new(1,-30,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            local CloseBtn = Create("TextButton", {Parent = Header, Text = "X", Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Red, Size = UDim2.new(0,30,1,0), Position = UDim2.new(1,-30,0,0), BackgroundTransparency = 1})
            local ExtContent = Create("ScrollingFrame", {Parent = ExtensionFrame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,35), Size = UDim2.new(1,0,1,-35), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0}); Create("UIListLayout", {Parent = ExtContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)}); Create("UIPadding", {Parent = ExtContent, PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)})
            Gear.MouseButton1Click:Connect(function() ExtensionFrame.Visible = true; TweenService:Create(ExtensionFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 0, 0)}):Play() end)
            CloseBtn.MouseButton1Click:Connect(function() local t = TweenService:Create(ExtensionFrame, TweenInfo.new(0.3), {Position = UDim2.new(1, 0, 0, 0)}); t:Play(); t.Completed:Connect(function() ExtensionFrame.Visible = false end) end)
            local ExtHandler = {}; RegisterContainerFunctions(ExtHandler, ExtContent); return ExtHandler
        end
        return ToggleObj
    end

    function Funcs:AddSlider(Config)
        local Min, Max, Def = Config.Min, Config.Max, Config.Default or Config.Min
        local SFrame = AddElementFrame(45)
        AddTooltip(SFrame, Config.Tooltip)
        Create("TextLabel", {Parent = SFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, 0, 0, 20), Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local ValBox = Create("TextBox", {Parent = SFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(1, -60, 0, 5), Size = UDim2.new(0, 50, 0, 20), Text = tostring(Def), Font = Enum.Font.Gotham, TextColor3 = Library.Theme.SubText, TextSize = 12}); Create("UICorner", {Parent = ValBox, CornerRadius = UDim.new(0, 4)})
        local Bar = Create("Frame", {Parent = SFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 4)}); Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
        local Fill = Create("Frame", {Parent = Bar, BackgroundColor3 = Color3.new(1,1,1), Size = UDim2.new((Def-Min)/(Max-Min), 0, 1, 0)}); Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)}); ApplyGradient(Fill)
        local Btn = Create("TextButton", {Parent = Bar, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = ""}); local Dragging = false
        local function UpdateFromBar(input) local s = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1); local res = math.floor(Min + (s * (Max - Min))); Fill.Size = UDim2.new(s, 0, 1, 0); ValBox.Text = tostring(res); if Config.Callback then Config.Callback(res) end end
        ValBox.FocusLost:Connect(function() local n = tonumber(ValBox.Text); if n then n = math.clamp(n, Min, Max); ValBox.Text = tostring(n); Fill.Size = UDim2.new((n-Min)/(Max-Min), 0, 1, 0); if Config.Callback then Config.Callback(n) end else ValBox.Text = tostring(Def) end end)
        Btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = true; UpdateFromBar(i) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
        UserInputService.InputChanged:Connect(function(i) if Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then UpdateFromBar(i) end end)
    end
    
    function Funcs:AddKeybind(Config)
        local KFrame = AddElementFrame(36)
        Create("TextLabel", {Parent = KFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -110, 1, 0), Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local BindBtn = Create("TextButton", {Parent = KFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(1, -100, 0.5, -12), Size = UDim2.new(0, 90, 0, 24), Text = Config.Default and Config.Default.Name or "None", Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.SubText, TextSize = 12}); Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
        local Listening = false
        BindBtn.MouseButton1Click:Connect(function() Listening = true; BindBtn.Text = "..."; BindBtn.TextColor3 = Library.Theme.Gradient1 end)
        UserInputService.InputBegan:Connect(function(input) if Listening and input.UserInputType == Enum.UserInputType.Keyboard then Listening = false; BindBtn.Text = input.KeyCode.Name; BindBtn.TextColor3 = Library.Theme.SubText; if Config.Callback then Config.Callback(input.KeyCode) end end end)
    end
    
    function Funcs:AddProgressBar(Config)
        local PFrame = AddElementFrame(45)
        Create("TextLabel", {Parent = PFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, 0, 0, 20), Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Bar = Create("Frame", {Parent = PFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 6)}); Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
        local Fill = Create("Frame", {Parent = Bar, BackgroundColor3 = Library.Theme.Gradient1, Size = UDim2.new((Config.Default or 0)/100, 0, 1, 0)}); Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)}); ApplyGradient(Fill)
        local Handler = {}; function Handler:Update(Val) TweenService:Create(Fill, TweenInfo.new(0.3), {Size = UDim2.new(Val/100, 0, 1, 0)}):Play() end; return Handler
    end

    function Funcs:AddChipTab(Config)
        local Main = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 1}); Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 6)})
        local Header = Create("ScrollingFrame", {Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X}); Create("UIListLayout", {Parent = Header, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), VerticalAlignment = Enum.VerticalAlignment.Center}); Create("UIPadding", {Parent = Header, PaddingLeft = UDim.new(0, 10)})
        local Content = Create("Frame", {Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0,0,0,45)}); Create("UIPadding", {Parent = Content, PaddingTop = UDim.new(0, 45), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10)})
        local TabFrames, TabBtns = {}, {}
        for i, tName in ipairs(Config.Tabs) do
            local Chip = Create("TextButton", {Parent = Header, BackgroundColor3 = (i==1) and Library.Theme.Gradient1 or Library.Theme.Element, Size = UDim2.new(0, 0, 0, 24), AutomaticSize = Enum.AutomaticSize.X, Text = "  " .. tName .. "  ", Font = Enum.Font.GothamBold, TextColor3 = (i==1) and Color3.new(1,1,1) or Library.Theme.SubText, TextSize = 12}); Create("UICorner", {Parent = Chip, CornerRadius = UDim.new(0, 12)})
            local TFrame = Create("Frame", {Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = (i==1)}); Create("UIListLayout", {Parent = TFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
            table.insert(TabFrames, {Name = tName, Frame = TFrame}); table.insert(TabBtns, Chip)
            Chip.MouseButton1Click:Connect(function() for _, btn in pairs(TabBtns) do btn.BackgroundColor3 = Library.Theme.Element; btn.TextColor3 = Library.Theme.SubText end; for _, fr in pairs(TabFrames) do fr.Frame.Visible = false end; Chip.BackgroundColor3 = Library.Theme.Gradient1; Chip.TextColor3 = Color3.new(1,1,1); TFrame.Visible = true end)
        end
        local Handler = {}; function Handler:GetTab(N) for _, v in pairs(TabFrames) do if v.Name == N then local M={}; RegisterContainerFunctions(M, v.Frame); return M end end end; return Handler
    end

    function Funcs:AddDropdown(Config)
        local IsOpen, IsMulti, Selected = false, Config.Multi or false, {}
        local DFrame = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, 40), ClipsDescendants = true, ZIndex = 20}); Create("UICorner", {Parent = DFrame, CornerRadius = UDim.new(0, 6)})
        local Label = Create("TextLabel", {Parent = DFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -40, 0, 40), Text = Config.Text..": "..(Config.Default or "None"), Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Arrow = Create("ImageLabel", {Parent = DFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0, 10), Size = UDim2.new(0, 20, 0, 20), Image = "rbxassetid://6034818372", ImageColor3 = Library.Theme.SubText})
        local SearchBar = Create("TextBox", {Parent = DFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 10, 0, 45), Size = UDim2.new(1, -20, 0, 25), Text = "", PlaceholderText = "Search...", TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12}); Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 4)})
        local List = Create("ScrollingFrame", {Parent = DFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 80), Size = UDim2.new(1, 0, 0, 100), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0}); Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
        local function Refresh(txt)
            for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            for _, item in pairs(Config.Items) do
                if txt == "" or item:lower():find(txt:lower()) then
                    local IsSel = table.find(Selected, item); local B = Create("TextButton", {Parent = List, BackgroundColor3 = IsSel and Library.Theme.Gradient1 or Library.Theme.Section, Size = UDim2.new(1, -10, 0, 25), Text = item, Font = Enum.Font.Gotham, TextColor3 = IsSel and Color3.new(1,1,1) or Library.Theme.SubText, TextSize = 12}); Create("UICorner", {Parent = B, CornerRadius = UDim.new(0, 4)})
                    B.MouseButton1Click:Connect(function()
                        if IsMulti then if table.find(Selected, item) then table.remove(Selected, table.find(Selected, item)) else table.insert(Selected, item) end; Label.Text = Config.Text .. ": " .. table.concat(Selected, ", "); Config.Callback(Selected); Refresh(SearchBar.Text)
                        else IsOpen = false; TweenService:Create(DFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 40)}):Play(); TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play(); Label.Text = Config.Text..": "..item; if Config.Callback then Config.Callback(item) end end
                    end)
                end
            end
        end
        SearchBar:GetPropertyChangedSignal("Text"):Connect(function() Refresh(SearchBar.Text) end)
        local Btn = Create("TextButton", {Parent = DFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,40), Text = ""})
        Btn.MouseButton1Click:Connect(function() IsOpen = not IsOpen; TweenService:Create(DFrame, TweenInfo.new(0.3), {Size = IsOpen and UDim2.new(1, 0, 0, 200) or UDim2.new(1, 0, 0, 40)}):Play(); TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 180 or 0}):Play(); if IsOpen then Refresh("") end end)
    end
    
    function Funcs:AddChipSet(Config)
        local CFrame = AddElementFrame(60)
        Create("TextLabel", {Parent = CFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, 0, 0, 20), Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Scroll = Create("ScrollingFrame", {Parent = CFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -10, 0, 30), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X}); Create("UIListLayout", {Parent = Scroll, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
        local Current = nil; for _, item in ipairs(Config.Items) do local Chip = Create("TextButton", {Parent = Scroll, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Text = "  " .. item .. "  ", Font = Enum.Font.Gotham, TextColor3 = Library.Theme.SubText, TextSize = 12}); Create("UICorner", {Parent = Chip, CornerRadius = UDim.new(0, 15)}); Chip.MouseButton1Click:Connect(function() if Current then Current.BackgroundColor3 = Library.Theme.Section; Current.TextColor3 = Library.Theme.SubText end; Current = Chip; Chip.BackgroundColor3 = Library.Theme.Gradient1; Chip.TextColor3 = Color3.new(1,1,1); Config.Callback(item) end) end
    end

    function Funcs:AddColorPicker(Config)
        local CPFrame = AddElementFrame(40); CPFrame.ZIndex = 25
        Create("TextLabel", {Parent = CPFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -50, 1, 0), Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Preview = Create("TextButton", {Parent = CPFrame, Position = UDim2.new(1, -40, 0.5, -10), Size = UDim2.new(0, 30, 0, 20), BackgroundColor3 = Config.Default or Color3.new(1,1,1), Text = ""}); Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 4)})
        local IsOpen, PickerFrame = false, Create("Frame", {Parent = CPFrame, BackgroundColor3 = Library.Theme.Element, Position = UDim2.new(0,0,1,5), Size = UDim2.new(1,0,0,130), Visible = false, ZIndex = 30}); Create("UICorner", {Parent = PickerFrame, CornerRadius = UDim.new(0,6)})
        local function AddInput(Name, Pos, Get, Set) Create("TextLabel", {Parent = PickerFrame, Text=Name, Position=UDim2.new(0, 10, 0, Pos), Size=UDim2.new(0,20,0,20), BackgroundTransparency=1, TextColor3=Library.Theme.SubText}); local Box = Create("TextBox", {Parent = PickerFrame, Position=UDim2.new(0, 35, 0, Pos), Size=UDim2.new(0, 50, 0, 20), BackgroundColor3=Library.Theme.Section, Text=tostring(Get), TextColor3=Library.Theme.Text}); Create("UICorner", {Parent=Box, CornerRadius=UDim.new(0,4)}); Box.FocusLost:Connect(function() local n = tonumber(Box.Text); if n then Set(math.clamp(n,0,255)) end; local c = Preview.BackgroundColor3; Preview.BackgroundColor3 = Color3.fromRGB(c.R*255, c.G*255, c.B*255); Config.Callback(Preview.BackgroundColor3) end); return Box end
        local R, G, B = 255, 255, 255; local BoxR = AddInput("R", 10, R, function(v) R=v; Preview.BackgroundColor3 = Color3.fromRGB(R, G, B) end); local BoxG = AddInput("G", 40, G, function(v) G=v; Preview.BackgroundColor3 = Color3.fromRGB(R, G, B) end); local BoxB = AddInput("B", 70, B, function(v) B=v; Preview.BackgroundColor3 = Color3.fromRGB(R, G, B) end)
        local RainbowBtn = Create("TextButton", {Parent = PickerFrame, Position = UDim2.new(0, 10, 0, 100), Size = UDim2.new(1, -20, 0, 24), BackgroundColor3 = Library.Theme.Section, Text = "Rainbow Mode", TextColor3 = Library.Theme.SubText, Font = Enum.Font.GothamBold, TextSize = 11}); Create("UICorner", {Parent = RainbowBtn, CornerRadius = UDim.new(0,4)}); local RB = false; local Loop
        RainbowBtn.MouseButton1Click:Connect(function() RB = not RB; RainbowBtn.TextColor3 = RB and Library.Theme.Gradient1 or Library.Theme.SubText; if RB then Loop = RunService.RenderStepped:Connect(function() Preview.BackgroundColor3 = Color3.fromHSV(tick()%5/5, 1, 1); Config.Callback(Preview.BackgroundColor3) end) else if Loop then Loop:Disconnect() end end end)
        Preview.MouseButton1Click:Connect(function() IsOpen = not IsOpen; PickerFrame.Visible = IsOpen; CPFrame.Size = IsOpen and UDim2.new(1,0,0,180) or UDim2.new(1,0,0,40); local c = Preview.BackgroundColor3; R, G, B = math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255); BoxR.Text=R; BoxG.Text=G; BoxB.Text=B end)
    end
    
    function Funcs:AddDoubleCanvas()
        local CF = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        local L, R = Create("Frame", {Parent = CF, BackgroundTransparency = 1, Size = UDim2.new(0.5, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}), Create("Frame", {Parent = CF, BackgroundTransparency = 1, Size = UDim2.new(0.5, -4, 0, 0), Position = UDim2.new(0.5, 4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        Create("UIListLayout", {Parent = L, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)}); Create("UIListLayout", {Parent = R, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        local LH, RH = {}, {}; RegisterContainerFunctions(LH, L); RegisterContainerFunctions(RH, R); return LH, RH
    end
    
    function Funcs:AddBottomTabBox(Config)
        local Main = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}); Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 6)})
        local Header = Create("Frame", {Parent = Main, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, 24)}); Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 6)})
        Create("TextLabel", {Parent = Header, Text = Config.Title or "Box", TextColor3 = Library.Theme.SubText, Font = Enum.Font.GothamBold, TextSize = 12, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1})
        local ToggleBtn = Create("TextButton", {Parent = Header, Text = "-", TextSize = 14, TextColor3 = Library.Theme.Text, BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -24, 0, 0), Font = Enum.Font.GothamBold})
        local Content = Create("Frame", {Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}); Create("UIPadding", {Parent = Content, PaddingTop = UDim.new(0, 30), PaddingBottom = UDim.new(0, 30), PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)})
        local Bar = Create("Frame", {Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25)}); Create("UIListLayout", {Parent = Main, SortOrder = Enum.SortOrder.LayoutOrder}); Header.LayoutOrder=1; Content.LayoutOrder=2; Bar.LayoutOrder=3
        local TabBtns, TabFrames, Collapsed = {}, {}, false
        Create("UIListLayout", {Parent = Bar, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder})
        for i, tName in ipairs(Config.Tabs) do
            local TBtn = Create("TextButton", {Parent = Bar, BackgroundTransparency = 1, Size = UDim2.new(1/#Config.Tabs, 0, 1, 0), Text = tName, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = (i==1) and Library.Theme.Gradient1 or Library.Theme.SubText})
            local Line = Create("Frame", {Parent = TBtn, BackgroundColor3 = Library.Theme.Gradient1, Size = UDim2.new(1, -4, 0, 2), Position = UDim2.new(0, 2, 1, -2), Visible = (i==1)})
            local TFrame = Create("Frame", {Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = (i==1)}); Create("UIListLayout", {Parent = TFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
            table.insert(TabBtns, {Btn=TBtn, Line=Line}); table.insert(TabFrames, {Frame=TFrame, Name=tName})
            TBtn.MouseButton1Click:Connect(function() for _, v in pairs(TabBtns) do v.Btn.TextColor3 = Library.Theme.SubText; v.Line.Visible = false end; for _, v in pairs(TabFrames) do v.Frame.Visible = false end; TBtn.TextColor3 = Library.Theme.Gradient1; Line.Visible = true; TFrame.Visible = true end)
        end
        ToggleBtn.MouseButton1Click:Connect(function() Collapsed = not Collapsed; Content.Visible = not Collapsed; Bar.Visible = not Collapsed; ToggleBtn.Text = Collapsed and "+" or "-" end)
        local H = {}; function H:GetTab(N) for _, v in pairs(TabFrames) do if v.Name == N then local M={}; RegisterContainerFunctions(M, v.Frame); return M end end end; return H
    end

    function Funcs:AddParagraph(Config)
        local PFrame = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}); Create("UICorner", {Parent = PFrame, CornerRadius = UDim.new(0, 6)}); Create("UIPadding", {Parent = PFrame, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
        if Config.Image then local Img = Create("ImageLabel", {Parent = PFrame, Image = Config.Image, BackgroundTransparency = 1, Size = UDim2.new(0, 200, 0, 120), Position = UDim2.new(0.5,-100,0,30)}); Create("UICorner", {Parent = Img, CornerRadius = UDim.new(0,6)}); return end
        if type(Config.Content) == "table" then
             local P, idx = Config.Content, 1; local T = Create("TextLabel", {Parent = PFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Font = Enum.Font.GothamBold, Text = Config.Title, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
             local C = Create("TextLabel", {Parent = PFrame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,25), Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = P[1], TextColor3 = Library.Theme.SubText, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left})
             local Nav = Create("Frame", {Parent = PFrame, BackgroundTransparency = 1, Position = UDim2.new(1,-60,0,0), Size = UDim2.new(0,60,0,20)}); local L = Create("TextButton", {Parent = Nav, Size = UDim2.new(0,20,1,0), Text = "<", TextColor3 = Library.Theme.Text, BackgroundColor3 = Library.Theme.Element}); Create("UICorner", {Parent = L, CornerRadius = UDim.new(0,4)}); local R = Create("TextButton", {Parent = Nav, Size = UDim2.new(0,20,1,0), Position = UDim2.new(1,-20,0,0), Text = ">", TextColor3 = Library.Theme.Text, BackgroundColor3 = Library.Theme.Element}); Create("UICorner", {Parent = R, CornerRadius = UDim.new(0,4)})
             L.MouseButton1Click:Connect(function() if idx > 1 then idx = idx - 1; C.Text = P[idx] end end); R.MouseButton1Click:Connect(function() if idx < #P then idx = idx + 1; C.Text = P[idx] end end)
        else Create("TextLabel", {Parent = PFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Font = Enum.Font.GothamBold, Text = Config.Title, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}); Create("TextLabel", {Parent = PFrame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,25), Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = Config.Content, TextColor3 = Library.Theme.SubText, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left}) end
    end
    
    function Funcs:AddTextbox(Config)
        local BoxFrame = AddElementFrame(50)
        Create("TextLabel", {Parent = BoxFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.Gotham, Text = Config.Text, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local InputBg = Create("Frame", {Parent = BoxFrame, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -20, 0, 20)}); Create("UICorner", {Parent = InputBg, CornerRadius = UDim.new(0, 4)})
        local Input = Create("TextBox", {Parent = InputBg, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), Font = Enum.Font.Gotham, Text = "", PlaceholderText = Config.Placeholder or "Input...", TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
        Input.FocusLost:Connect(function() if Config.Callback then Config.Callback(Input.Text) end end)
    end
    
    function Funcs:AddCopyButton(Config)
        local BtnFrame = AddElementFrame(36)
        local Btn = Create("TextButton", {Parent = BtnFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.Gotham, Text = Config.Text or "Copy to Clipboard", TextColor3 = Library.Theme.Text, TextSize = 13})
        Btn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(Config.Value or "") end; Library:Notify({Title = "Success", Content = "Copied to clipboard!", Duration = 2}) end)
    end
    
    function Funcs:AddLabel(Config)
        local LFrame = AddElementFrame(30)
        local Lbl = Create("TextLabel", {Parent = LFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0,10,0,0), Text = Config.Text, TextColor3 = Library.Theme.SubText, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
        local Func = {}; function Func:Set(Txt) Lbl.Text = Txt end; return Func
    end

    function Funcs:Space(px) Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,px or 10)}) end
    function Funcs:Divide() 
        local D = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 20)})
        Create("Frame", {Parent = D, BackgroundColor3 = Library.Theme.Divider, Size = UDim2.new(0.4, 0, 0, 1), Position = UDim2.new(0,0,0.5,0)})
        Create("Frame", {Parent = D, BackgroundColor3 = Library.Theme.Divider, Size = UDim2.new(0.4, 0, 0, 1), Position = UDim2.new(0.6,0,0.5,0)})
        Create("TextLabel", {Parent = D, Text = "SECTION", TextColor3 = Library.Theme.SubText, TextSize = 10, Font = Enum.Font.GothamBold, Size = UDim2.new(0.2,0,1,0), Position = UDim2.new(0.4,0,0,0), BackgroundTransparency = 1})
    end
    for k, v in pairs(Funcs) do Container[k] = v end
end

--// MAIN WINDOW
function Library:CreateWindow(Config)
    local Window = {Tabs = {}, IsVisual = true}
    local ScreenGui = Create("ScreenGui", {Name = "LopUI_V7_Fixed", Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    Library:InitNotifications(ScreenGui)

    local MobileBtn = Create("ImageButton", {Name = "MobileToggle", Parent = ScreenGui, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 20, 0.5, -25), Size = UDim2.new(0, 50, 0, 50), AutoButtonColor = false, Visible = false}); Create("UICorner", {Parent = MobileBtn, CornerRadius = UDim.new(1, 0)}); ApplyGradient(MobileBtn)
    Create("ImageLabel", {Parent = MobileBtn, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0.5, -15, 0.5, -15), Image = "rbxassetid://6031280882"})
    MakeDraggable(MobileBtn, MobileBtn)
    
    local MainFrame = Create("Frame", {Name = "MainFrame", Parent = ScreenGui, BackgroundColor3 = Color3.new(1,1,1), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Size = Config.Size or UDim2.fromOffset(650, 450), ClipsDescendants = true}); Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)}); Create("UIStroke", {Parent = MainFrame, Color = Library.Theme.Divider, Thickness = 1})
    local MainGrad = Create("UIGradient", {Name = "MainGradient", Parent = MainFrame, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Library.Theme.Background), ColorSequenceKeypoint.new(1, Library.Theme.Background or Library.Theme.Background2)}})
    local Shadow = Create("ImageLabel", {Parent = MainFrame, Image = "rbxassetid://6015897843", ImageColor3 = Library.Theme.Shadow, ImageTransparency = 0.5, Size = UDim2.new(1, 100, 1, 100), Position = UDim2.new(0,-50,0,-50), ZIndex = -1})
    Library.MainFrameRef = MainFrame
    
    local Topbar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Library.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 50)}); Create("UICorner", {Parent = Topbar, CornerRadius = UDim.new(0, 8)})
    Create("Frame", {Parent = Topbar, BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0, Position = UDim2.new(0,0,1,-10), Size = UDim2.new(1,0,0,10)})
    local TitleText = Create("TextLabel", {Parent = Topbar, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0, 200, 1, 0), Font = Enum.Font.GothamBold, Text = Config.Title or "UI", TextColor3 = Color3.new(1,1,1), TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left}); ApplyGradient(TitleText).Enabled = true

    local SearchBg = Create("Frame", {Parent = Topbar, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0.5, -120, 0.5, -15), Size = UDim2.new(0, 240, 0, 30)}); Create("UICorner", {Parent = SearchBg, CornerRadius = UDim.new(0, 6)})
    Create("ImageLabel", {Parent = SearchBg, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://6031154871", ImageColor3 = Library.Theme.SubText})
    local SearchInput = Create("TextBox", {Parent = SearchBg, BackgroundTransparency = 1, Position = UDim2.new(0, 30, 0, 0), Size = UDim2.new(1, -35, 1, 0), Font = Enum.Font.Gotham, PlaceholderText = "Search...", Text = "", TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local SearchResults = Create("ScrollingFrame", {Parent = SearchBg, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 0, 1, 5), Size = UDim2.new(1, 0, 0, 0), Visible = false, ZIndex = 20, BorderSizePixel = 0, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0}); Create("UICorner", {Parent = SearchResults, CornerRadius = UDim.new(0, 6)}); Create("UIListLayout", {Parent = SearchResults, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower(); for _, c in pairs(SearchResults:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        if query == "" then SearchResults.Visible = false return end
        local matches = 0; for name, data in pairs(Library.Elements) do if name:lower():find(query) then matches = matches + 1
        local ResBtn = Create("TextButton", {Parent = SearchResults, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Font = Enum.Font.Gotham, Text = "  "..name, TextColor3 = Library.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
        ResBtn.MouseButton1Click:Connect(function() data.TabFunc(); SearchResults.Visible = false end) end end
        if matches > 0 then SearchResults.Visible = true; SearchResults.Size = UDim2.new(1, 0, 0, math.min(matches * 32, 200)) else SearchResults.Visible = false end
    end)
    MakeDraggable(Topbar, MainFrame)

    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Library.Theme.Sidebar, Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(0, 160, 1, -50), BorderSizePixel = 0})
    local TabHolder = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 10), Size = UDim2.new(1, 0, 1, -60), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0}); Create("UIListLayout", {Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local PageHolder = Create("Frame", {Name = "PageHolder", Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 170, 0, 60), Size = UDim2.new(1, -180, 1, -70), ClipsDescendants = true})

    local Profile = Create("Frame", {Parent = Sidebar, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0, 0, 1, -50), Size = UDim2.new(1, 0, 0, 50), BorderSizePixel = 0})
    local Avatar = Create("ImageLabel", {Parent = Profile, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0.5, -15), Size = UDim2.new(0, 30, 0, 30), Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)}); Create("UICorner", {Parent = Avatar, CornerRadius = UDim.new(1, 0)})
    Create("TextLabel", {Parent = Profile, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 2), Size = UDim2.new(0, 80, 0, 20), Font = Enum.Font.GothamBold, Text = LocalPlayer.Name, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = Profile, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 20), Size = UDim2.new(0, 80, 0, 15), Font = Enum.Font.Gotham, Text = "GOD MODE", TextColor3 = Library.Theme.Gradient1, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left})
    local SettingsBtn = Create("TextButton", {Parent = Profile, BackgroundTransparency = 1, Size = UDim2.new(0, 25, 0, 25), Position = UDim2.new(1, -30, 0.5, -12.5), Text = ""}); Create("ImageLabel", {Parent = SettingsBtn, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Image = "rbxassetid://6031280882", ImageColor3 = Library.Theme.SubText})

    function Window:MobileToggle(bool) MobileBtn.Visible = bool end
    function Window:SetVisual(bool) 
        Library.IsVisible = bool; MainFrame.Visible = bool
    end
    MobileBtn.MouseButton1Click:Connect(function() Window:SetVisual(not Library.IsVisible) end)
    UserInputService.InputBegan:Connect(function(input, gpe) if not gpe and input.KeyCode == Library.Keybind then Window:SetVisual(not Library.IsVisible) end end)

    function Window:CreateTab(Name)
        local Tab = {Elements = {}}
        local Page = Create("ScrollingFrame", {Name = Name, Parent = PageHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.Y})
        Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        local Btn = Create("TextButton", {Parent = TabHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Font = Enum.Font.GothamBold, Text = "  "..Name, TextColor3 = Library.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Ind = Create("Frame", {Parent = Btn, BackgroundColor3 = Color3.new(1,1,1), Position = UDim2.new(0, 0, 0, 6), Size = UDim2.new(0, 3, 1, -12), Visible = false}); ApplyGradient(Ind)
        local function Activate()
            for _, v in pairs(TabHolder:GetDescendants()) do if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = Library.Theme.SubText}):Play(); if v:FindFirstChild("Frame") then v.Frame.Visible = false end end end
            for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end
            TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Text}):Play(); Ind.Visible = true; Page.Visible = true
        end
        Btn.MouseButton1Click:Connect(Activate); Tab.Activate = Activate; RegisterContainerFunctions(Tab, Page); return Tab
    end
    
    local SettingsPage = Create("ScrollingFrame", {Name = "Settings", Parent = PageHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0})
    Create("UIListLayout", {Parent = SettingsPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
    local SettingsHandler = {}; RegisterContainerFunctions(SettingsHandler, SettingsPage)
    SettingsBtn.MouseButton1Click:Connect(function() for _, v in pairs(TabHolder:GetDescendants()) do if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = Library.Theme.SubText}):Play(); if v:FindFirstChild("Frame") then v.Frame.Visible = false end end end; for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end; SettingsPage.Visible = true end)
    
    SettingsHandler:AddParagraph({Title = "Visuals", Content = "Customize the UI appearance."})
    SettingsHandler:AddChipSet({Text = "Themes", Items = {"Dark", "PastelPurple", "Sky", "Garden"}, Callback = function(v) Library:SetTheme(v) end})
    SettingsHandler:AddSlider({Text = "Transparency", Min = 0, Max = 100, Default = 0, Callback = function(v) MainFrame.BackgroundTransparency = v/100 end})
    SettingsHandler:AddSlider({Text = "UI Scale", Min = 70, Max = 150, Default = 100, Callback = function(v) MainFrame.UIScale.Scale = v/100 end}); Create("UIScale", {Parent = MainFrame, Scale = 1})
    SettingsHandler:AddToggle({Text = "Sound Effects", Default = true, Callback = function(v) Library.SoundsEnabled = v end})
    SettingsHandler:AddToggle({Text = "Tooltips", Default = true, Callback = function(v) Library.TooltipsEnabled = v end})
    SettingsHandler:Divide()
    SettingsHandler:AddParagraph({Title = "Utilities", Content = "Useful tools."})
    SettingsHandler:AddButton({Text = "Unlock FPS", Callback = function() if setfpscap then setfpscap(999) end Library:Notify({Title="Success", Content="FPS Unlocked"}) end})
    SettingsHandler:AddButton({Text = "Server Hop", Callback = function() Library:Notify({Title="Hopping", Content="Finding new server..."}); local x = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")); for _,v in pairs(x.data) do if v.playing < v.maxPlayers then TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer) end end end})
    SettingsHandler:AddButton({Text = "Rejoin Server", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end})
    SettingsHandler:AddCopyButton({Text = "Copy Discord Link", Value = "https://discord.gg/yourinvite"})
    SettingsHandler:Divide()
    SettingsHandler:AddToggle({Text = "Mobile Button", Default = false, Callback = function(v) Window:MobileToggle(v) end})
    SettingsHandler:AddKeybind({Text = "Menu Keybind", Default = Enum.KeyCode.RightControl, Callback = function(k) Library.Keybind = k end})
    SettingsHandler:AddButton({Text = "Unload UI", Variant="Danger", Callback = function() ScreenGui:Destroy() end})
    
    MainFrame.Position = UDim2.new(0.5, 0, 1.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Position = UDim2.new(0.5,0,0.5,0)}):Play()
    
    return Window
end

return Library
