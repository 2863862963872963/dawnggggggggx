local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Ascent = {
    Elements = {}, 
    OpenedFrames = {},
    NotificationArea = nil,
    IsMobile = UserInputService.TouchEnabled,
    CurrentTheme = "MacDark",
    MainFrameRef = nil,
    MinimizeBtnRef = nil,
    ScreenGuiRef = nil,
    ScaleObj = nil, -- New Scale Object
    Keybind = Enum.KeyCode.RightControl,
    IsVisible = true,
    Flags = {},
    ConfigFolder = "AscentLib_Configs",
    Version = "1.2 Ultimate"
}

--// THEME SYSTEM (Refined macOS Palette)
Ascent.Themes = {
    MacDark = {
        Background = Color3.fromRGB(30, 30, 35),
        Sidebar = Color3.fromRGB(40, 40, 45),
        Section = Color3.fromRGB(45, 45, 50),
        Element = Color3.fromRGB(50, 50, 55),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(160, 160, 170),
        Divider = Color3.fromRGB(60, 60, 65),
        Accent = Color3.fromRGB(0, 122, 255),
        Red = Color3.fromRGB(255, 69, 58),
        Green = Color3.fromRGB(48, 209, 88),
        Yellow = Color3.fromRGB(255, 214, 10),
        TrafficRed = Color3.fromRGB(255, 95, 87),
        TrafficYellow = Color3.fromRGB(255, 189, 46),
        TrafficGreen = Color3.fromRGB(40, 201, 64)
    },
    MacLight = {
        Background = Color3.fromRGB(240, 240, 245),
        Sidebar = Color3.fromRGB(225, 225, 230),
        Section = Color3.fromRGB(235, 235, 240),
        Element = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(20, 20, 20),
        SubText = Color3.fromRGB(100, 100, 110),
        Divider = Color3.fromRGB(200, 200, 210),
        Accent = Color3.fromRGB(0, 122, 255),
        Red = Color3.fromRGB(255, 59, 48),
        Green = Color3.fromRGB(52, 199, 89),
        Yellow = Color3.fromRGB(255, 204, 0),
        TrafficRed = Color3.fromRGB(255, 95, 87),
        TrafficYellow = Color3.fromRGB(255, 189, 46),
        TrafficGreen = Color3.fromRGB(40, 201, 64)
    }
}
Ascent.Theme = Ascent.Themes.MacDark

--// UTILITY FUNCTIONS
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if class:find("Text") then inst.RichText = true end
    return inst
end

local function AddShadow(Parent, Transparency)
    local Shadow = Create("ImageLabel", {
        Name = "Shadow", Parent = Parent, BackgroundTransparency = 1,
        Position = UDim2.new(0, -20, 0, -20), Size = UDim2.new(1, 40, 1, 40), ZIndex = 0,
        Image = "rbxassetid://6015897843", ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = Transparency or 0.4, ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })
    return Shadow
end

local function CreateRipple(Parent)
    task.spawn(function()
        local Ripple = Create("Frame", {
            Parent = Parent, BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.8,
            Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), Size = UDim2.new(0,0,0,0)
        }); Create("UICorner", {Parent = Ripple, CornerRadius = UDim.new(1,0)})
        local T = TweenService:Create(Ripple, TweenInfo.new(0.4), {Size = UDim2.new(1.5,0,1.5,0), BackgroundTransparency = 1})
        T:Play(); T.Completed:Wait(); Ripple:Destroy()
    end)
end

--// MOBILE SUPPORTED DRAG
local function MakeDraggable(topbar, object)
    local Dragging, DragInput, DragStart, StartPos
    local function Update(input)
        local Delta = input.Position - DragStart
        local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        TweenService:Create(object, TweenInfo.new(0.05), {Position = Position}):Play() -- Faster response for mobile
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

--// GLOBAL API
function Ascent:SetTheme(ThemeName)
    if Ascent.Themes[ThemeName] then 
        Ascent.Theme = Ascent.Themes[ThemeName]
        Ascent.CurrentTheme = ThemeName
        if Ascent.MainFrameRef then
            Ascent.MainFrameRef.BackgroundColor3 = Ascent.Theme.Background
            if Ascent.MainFrameRef:FindFirstChild("Sidebar") then
                Ascent.MainFrameRef.Sidebar.BackgroundColor3 = Ascent.Theme.Sidebar
            end
            -- Note: A full theme refresh would require iterating over all elements, 
            -- but for this snippet we update main containers.
        end
    end
end

function Ascent:SetScale(Scale)
    if Ascent.ScaleObj then
        Ascent.ScaleObj.Scale = Scale
    end
end

--// NOTIFICATIONS
function Ascent:Notify(Config)
    Config = Config or {}
    local Frame = Create("Frame", {Parent = Ascent.NotificationArea, BackgroundColor3 = Ascent.Theme.Background, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, BorderSizePixel = 0})
    Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 10)})
    Create("UIStroke", {Parent = Frame, Color = Ascent.Theme.Divider, Thickness = 1})
    AddShadow(Frame, 0.6)
    
    local IconId = "rbxassetid://3944680095" 
    if Config.Type == "Success" then IconId = "rbxassetid://3944661110" end
    if Config.Type == "Warning" then IconId = "rbxassetid://3944672694" end
    if Config.Type == "Error" then IconId = "rbxassetid://3944676354" end

    Create("ImageLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(0, 24, 0, 24), Image = IconId, ImageColor3 = Config.Type == "Success" and Ascent.Theme.Green or (Config.Type == "Error" and Ascent.Theme.Red or Ascent.Theme.Accent)})
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 15), Size = UDim2.new(1, -60, 0, 20), Font = Enum.Font.GothamBold, Text = Config.Title or "Notification", TextColor3 = Ascent.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 38), Size = UDim2.new(1, -60, 0, 30), Font = Enum.Font.GothamMedium, Text = Config.Content or "Message", TextColor3 = Ascent.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})

    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 80)}):Play()
    task.delay(Config.Duration or 3, function() if Frame then local T = TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)}); T:Play(); T.Completed:Wait(); Frame:Destroy() end end)
end

function Ascent:InitNotifications(Gui)
    Ascent.NotificationArea = Create("Frame", {Name = "Notifications", Parent = Gui, BackgroundTransparency = 1, Position = UDim2.new(1, -320, 0, 20), Size = UDim2.new(0, 300, 1, -20), ZIndex = 1000})
    Create("UIListLayout", {Parent = Ascent.NotificationArea, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom})
end

--// MINIMIZE / MOBILE TOGGLE
function Ascent:InitMinimize(Gui)
    local Btn = Create("ImageButton", {Name = "Bubble", Parent = Gui, BackgroundColor3 = Ascent.Theme.Background, Position = UDim2.new(0, 50, 0, 50), Size = UDim2.new(0, 55, 0, 55), Visible = false, AutoButtonColor = false})
    Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(1, 0)}); Create("UIStroke", {Parent = Btn, Color = Ascent.Theme.Accent, Thickness = 2}); AddShadow(Btn)
    Create("ImageLabel", {Parent = Btn, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0.5, -15, 0.5, -15), Image = "rbxassetid://6031280882", ImageColor3 = Ascent.Theme.Accent})
    MakeDraggable(Btn, Btn)
    Btn.MouseButton1Click:Connect(function() 
        Ascent.IsVisible = true; Ascent.MainFrameRef.Visible = true; Btn.Visible = false
        TweenService:Create(Ascent.MainFrameRef, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(750, 500)}):Play() 
    end)
    Ascent.MinimizeBtnRef = Btn
end

--// TOOLTIPS
function Ascent:AddTooltip(Element, Text)
    if Ascent.IsMobile then return end -- No tooltips on mobile
    local Tooltip = Create("Frame", {Parent = Ascent.MainFrameRef.Parent, BackgroundColor3 = Ascent.Theme.Sidebar, Size = UDim2.new(0, 0, 0, 28), AutomaticSize = Enum.AutomaticSize.X, Visible = false, ZIndex = 300})
    Create("UICorner", {Parent = Tooltip, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Tooltip, Color = Ascent.Theme.Divider, Thickness = 1}); AddShadow(Tooltip, 0.5)
    Create("TextLabel", {Parent = Tooltip, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Font = Enum.Font.GothamMedium, Text = Text, TextColor3 = Ascent.Theme.Text, TextSize = 12})
    Element.MouseEnter:Connect(function() Tooltip.Visible = true; local M = UserInputService:GetMouseLocation(); Tooltip.Position = UDim2.new(0, M.X + 15, 0, M.Y - 25) end)
    Element.MouseLeave:Connect(function() Tooltip.Visible = false end)
    Element.MouseMoved:Connect(function() local M = UserInputService:GetMouseLocation(); Tooltip.Position = UDim2.new(0, M.X + 15, 0, M.Y - 25) end)
end

--// ELEMENT API HELPERS
local function AddAPI(Obj, Frame, Config)
    function Obj:SetVisible(bool) Frame.Visible = bool end
    function Obj:Destroy() Frame:Destroy() end
    function Obj:SetLocked(bool)
        if Frame:FindFirstChild("LockOverlay") then Frame.LockOverlay:Destroy() end
        if bool then
            local Ov = Create("Frame", {Name = "LockOverlay", Parent = Frame, BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.6, Size = UDim2.new(1,0,1,0), ZIndex = 10}); Create("UICorner", {Parent = Ov, CornerRadius = UDim.new(0,8)})
            Create("ImageLabel", {Parent = Ov, BackgroundTransparency = 1, Size = UDim2.new(0,24,0,24), Position = UDim2.new(0.5,-12,0.5,-12), Image = "rbxassetid://3926305904", ImageColor3 = Color3.new(1,1,1)})
        end
    end
end

--// MAIN ELEMENT CREATION
local function RegisterContainerFunctions(Container, PageInstance)
    local Funcs = {}
    local function AddElementFrame(SizeY)
        local F = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Ascent.Theme.Element, Size = UDim2.new(1, 0, 0, SizeY), BorderSizePixel = 0})
        Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})
        return F
    end

    function Funcs:AddSection(Title)
        local SFrame = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y})
        Create("TextLabel", {Parent = SFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 5, 0, 5), Size = UDim2.new(1, -10, 0, 20), Text = Title:upper(), Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.SubText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
        local C = Create("Frame", {Parent = SFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
        Create("UIListLayout", {Parent = C, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        local SectionHandler = {}; RegisterContainerFunctions(SectionHandler, C); AddAPI(SectionHandler, SFrame, {}); return SectionHandler
    end
    
    function Funcs:Divide()
        local F = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,10)})
        Create("Frame", {Parent = F, BackgroundColor3 = Ascent.Theme.Divider, Size = UDim2.new(1, -20, 0, 1), Position = UDim2.new(0, 10, 0.5, 0)})
        return F
    end
    function Funcs:Space(pixels) return Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1,0,0, pixels or 20)}) end

    function Funcs:AddDoubleCanvas()
        local Holder = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 100), AutomaticSize = Enum.AutomaticSize.Y})
        local Left = Create("Frame", {Parent = Holder, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        local Right = Create("Frame", {Parent = Holder, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        Create("UIListLayout", {Parent = Left, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        Create("UIListLayout", {Parent = Right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        local LH, RH = {}, {}; RegisterContainerFunctions(LH, Left); RegisterContainerFunctions(RH, Right); return LH, RH
    end

    function Funcs:AddLabel(Text, Color)
        local F = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), Text = Text, Font = Enum.Font.GothamMedium, TextColor3 = Color or Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
        return F
    end

    -- IMPROVED BUTTON WITH VARIANTS
    function Funcs:AddButton(Config)
        local Variant = Config.Variant or "Default" -- Default, Outline
        local F = AddElementFrame(40)
        
        -- API Object
        local Obj = {}; AddAPI(Obj, F, Config)

        if Variant == "Outline" then
            F.BackgroundColor3 = Ascent.Theme.Background
            Create("UIStroke", {Parent = F, Color = Ascent.Theme.Divider, Thickness = 1})
        end

        local B = Create("TextButton", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamMedium, Text = Config.Text, TextColor3 = Ascent.Theme.Text, TextSize = 14})
        if Config.Tooltip then Ascent:AddTooltip(B, Config.Tooltip) end
        
        B.MouseButton1Click:Connect(function() 
            CreateRipple(F)
            if Config.Callback then Config.Callback() end 
        end)
        
        function Obj:SetText(t) B.Text = t end
        return Obj
    end

    -- IMPROVED TOGGLE WITH VARIANTS
    function Funcs:AddToggle(Config)
        local State = Config.Default or false
        local Variant = Config.Variant or "Switch" -- Switch, Checkbox
        if Config.Flag then Ascent.Flags[Config.Flag] = State end
        
        local F = AddElementFrame(40)
        local Obj = {}; AddAPI(Obj, F, Config)

        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -70, 1, 0), Font = Enum.Font.GothamMedium, Text = Config.Text, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Trig = Create("TextButton", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""})
        if Config.Tooltip then Ascent:AddTooltip(Trig, Config.Tooltip) end

        -- Visuals
        local Display, Knob, CheckIcon
        
        if Variant == "Checkbox" then
            Display = Create("Frame", {Parent = F, BackgroundColor3 = State and Ascent.Theme.Accent or Ascent.Theme.Divider, Position = UDim2.new(1, -35, 0.5, -10), Size = UDim2.new(0, 20, 0, 20)}); Create("UICorner", {Parent = Display, CornerRadius = UDim.new(0, 6)})
            CheckIcon = Create("ImageLabel", {Parent = Display, BackgroundTransparency = 1, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0.5, -7, 0.5, -7), Image = "rbxassetid://6031094620", ImageColor3 = Color3.new(1,1,1), Visible = State})
        else
            -- Default Switch
            Display = Create("Frame", {Parent = F, BackgroundColor3 = State and Ascent.Theme.Accent or Ascent.Theme.Divider, Position = UDim2.new(1, -50, 0.5, -11), Size = UDim2.new(0, 36, 0, 22)}); Create("UICorner", {Parent = Display, CornerRadius = UDim.new(1, 0)})
            Knob = Create("Frame", {Parent = Display, BackgroundColor3 = Color3.new(1,1,1), Position = State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), Size = UDim2.new(0, 18, 0, 18)}); Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
        end

        local function Upd()
            if Config.Flag then Ascent.Flags[Config.Flag] = State end
            
            if Variant == "Checkbox" then
                Display.BackgroundColor3 = State and Ascent.Theme.Accent or Ascent.Theme.Divider
                CheckIcon.Visible = State
            else
                TweenService:Create(Knob, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
                TweenService:Create(Display, TweenInfo.new(0.2), {BackgroundColor3 = State and Ascent.Theme.Accent or Ascent.Theme.Divider}):Play()
            end
        end

        Trig.MouseButton1Click:Connect(function() State = not State; if Config.Callback then Config.Callback(State) end; Upd() end)
        
        function Obj:Set(v) State = v; Upd(); if Config.Callback then Config.Callback(State) end end
        return Obj
    end

    function Funcs:AddSlider(Config)
        local Min, Max, Def = Config.Min, Config.Max, Config.Default or Config.Min; if Config.Flag then Ascent.Flags[Config.Flag] = Def end
        local F = AddElementFrame(50)
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 5), Size = UDim2.new(1, -50, 0, 20), Text = Config.Text, Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local VLab = Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(1, -50, 0, 5), Size = UDim2.new(0, 40, 0, 20), Text = tostring(Def), Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right})
        local Bg = Create("Frame", {Parent = F, BackgroundColor3 = Ascent.Theme.Divider, Position = UDim2.new(0, 12, 0, 35), Size = UDim2.new(1, -24, 0, 4)}); Create("UICorner", {Parent = Bg, CornerRadius = UDim.new(1, 0)})
        local Fill = Create("Frame", {Parent = Bg, BackgroundColor3 = Ascent.Theme.Accent, Size = UDim2.new((Def-Min)/(Max-Min), 0, 1, 0)}); Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
        local Knob = Create("Frame", {Parent = Fill, BackgroundColor3 = Color3.new(1,1,1), Position = UDim2.new(1, -6, 0.5, -6), Size = UDim2.new(0, 12, 0, 12), ZIndex = 2}); Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)}); AddShadow(Knob, 0.8)
        local Btn = Create("TextButton", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,25), Size = UDim2.new(1,0,0,25), Text = ""})
        local Drag, Update = false, function(i)
            local s = math.clamp((i.Position.X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1); local res = math.floor(Min + (s * (Max - Min)))
            TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new((res-Min)/(Max-Min), 0, 1, 0)}):Play(); VLab.Text = tostring(res)
            if Config.Flag then Ascent.Flags[Config.Flag] = res end; if Config.Callback then Config.Callback(res) end
        end
        Btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Drag = true; Update(i) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Drag = false end end)
        UserInputService.InputChanged:Connect(function(i) if Drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
        local Obj = {}; AddAPI(Obj, F, Config); function Obj:Set(v) Fill.Size = UDim2.new((v-Min)/(Max-Min),0,1,0); VLab.Text = tostring(v) end; return Obj
    end

    function Funcs:AddDropdown(Config)
        local IsOpen, Selected = false, Config.Default or "None"; if Config.Flag then Ascent.Flags[Config.Flag] = Selected end
        local F = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Ascent.Theme.Element, Size = UDim2.new(1, 0, 0, 40), ClipsDescendants = true}); Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})
        local Lab = Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -40, 0, 40), Text = Config.Text..": "..tostring(Selected), Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local Arr = Create("ImageLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0, 10), Size = UDim2.new(0, 20, 0, 20), Image = "rbxassetid://6034818372", ImageColor3 = Ascent.Theme.SubText})
        local List = Create("ScrollingFrame", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(1, 0, 1, -45), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Ascent.Theme.Accent}); Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}); Create("UIPadding", {Parent = List, PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)})
        local function Refresh()
            for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            for _, item in pairs(Config.Items) do
                local B = Create("TextButton", {Parent = List, BackgroundColor3 = (Selected == item) and Ascent.Theme.Accent or Ascent.Theme.Background, Size = UDim2.new(1, 0, 0, 30), Text = "  "..item, Font = Enum.Font.Gotham, TextColor3 = (Selected == item) and Color3.new(1,1,1) or Ascent.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}); Create("UICorner", {Parent = B, CornerRadius = UDim.new(0, 6)})
                B.MouseButton1Click:Connect(function() Selected = item; IsOpen = false; TweenService:Create(F, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 40)}):Play(); TweenService:Create(Arr, TweenInfo.new(0.3), {Rotation = 0}):Play(); Lab.Text = Config.Text..": "..item; if Config.Flag then Ascent.Flags[Config.Flag] = Selected end; if Config.Callback then Config.Callback(item) end; Refresh() end)
            end
        end
        local B = Create("TextButton", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,40), Text = ""}); B.MouseButton1Click:Connect(function() IsOpen = not IsOpen; TweenService:Create(F, TweenInfo.new(0.3), {Size = IsOpen and UDim2.new(1, 0, 0, 160) or UDim2.new(1, 0, 0, 40)}):Play(); TweenService:Create(Arr, TweenInfo.new(0.3), {Rotation = IsOpen and 180 or 0}):Play(); if IsOpen then Refresh() end end)
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end
    
    function Funcs:AddTextbox(Config) 
        local F = AddElementFrame(50); Create("TextLabel", {Parent = F, Text = Config.Text, Position = UDim2.new(0,12,0,5), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = Ascent.Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left}); 
        local B = Create("TextBox", {Parent = F, BackgroundColor3 = Ascent.Theme.Background, Position = UDim2.new(0,12,0,28), Size = UDim2.new(1,-24,0,16), Text = "", PlaceholderText = Config.Placeholder or "Input...", Font = Enum.Font.Gotham, TextColor3 = Ascent.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0}); Create("UICorner", {Parent = B, CornerRadius = UDim.new(0,4)}); B.FocusLost:Connect(function() if Config.Callback then Config.Callback(B.Text) end end); local Obj = {}; AddAPI(Obj, F, Config); return Obj 
    end
    function Funcs:AddKeybind(Config)
        local F = AddElementFrame(40); local Key = Config.Default or Enum.KeyCode.RightControl
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -100, 1, 0), Font = Enum.Font.GothamMedium, Text = Config.Text, TextColor3 = Ascent.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local B = Create("TextButton", {Parent = F, BackgroundColor3 = Ascent.Theme.Background, Position = UDim2.new(1, -90, 0.5, -10), Size = UDim2.new(0, 80, 0, 20), Text = Key.Name, Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.SubText, TextSize = 12}); Create("UICorner", {Parent = B, CornerRadius = UDim.new(0, 5)})
        local L = false; B.MouseButton1Click:Connect(function() L = true; B.Text = "..."; B.TextColor3 = Ascent.Theme.Accent end)
        UserInputService.InputBegan:Connect(function(i) if L and i.UserInputType == Enum.UserInputType.Keyboard then Key = i.KeyCode; B.Text = Key.Name; B.TextColor3 = Ascent.Theme.SubText; L = false; if Config.Callback then Config.Callback(Key) end end end)
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end

    for k, v in pairs(Funcs) do Container[k] = v end
end

function Ascent:SaveConfig() if not isfolder(Ascent.ConfigFolder) then makefolder(Ascent.ConfigFolder) end; writefile(Ascent.ConfigFolder .. "/config.json", HttpService:JSONEncode(Ascent.Flags)); Ascent:Notify({Title = "Config", Content = "Saved!", Type = "Success"}) end
function Ascent:LoadConfig() if isfile(Ascent.ConfigFolder .. "/config.json") then Ascent.Flags = HttpService:JSONDecode(readfile(Ascent.ConfigFolder .. "/config.json")); Ascent:Notify({Title = "Config", Content = "Loaded!", Type = "Success"}) end end

function Ascent:CreateWindow(Config)
    if Ascent.ScreenGuiRef then Ascent.ScreenGuiRef:Destroy() end
    local Gui = Create("ScreenGui", {Name = "AscentUI", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}); Ascent.ScreenGuiRef = Gui
    
    -- SCALE OBJECT
    local ScaleObj = Create("UIScale", {Parent = Gui, Scale = 1})
    Ascent.ScaleObj = ScaleObj

    Ascent:InitNotifications(Gui); Ascent:InitMinimize(Gui)

    local Main = Create("Frame", {Name = "MainFrame", Parent = Gui, BackgroundColor3 = Ascent.Theme.Background, Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Size = Config.Size or UDim2.fromOffset(750, 500), ClipsDescendants = false}); Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 12)}); AddShadow(Main, 0.4); Ascent.MainFrameRef = Main
    local Sidebar = Create("Frame", {Name = "Sidebar", Parent = Main, BackgroundColor3 = Ascent.Theme.Sidebar, Size = UDim2.new(0, 200, 1, 0)}); Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 12)}); Create("Frame", {Parent = Sidebar, BackgroundColor3 = Ascent.Theme.Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0})

    local Controls = Create("Frame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)})
    local C, M, MX = Create("ImageButton", {Parent = Controls, BackgroundColor3 = Ascent.Theme.TrafficRed, Position = UDim2.new(0, 18, 0, 18), Size = UDim2.new(0, 12, 0, 12), AutoButtonColor = false}), Create("ImageButton", {Parent = Controls, BackgroundColor3 = Ascent.Theme.TrafficYellow, Position = UDim2.new(0, 38, 0, 18), Size = UDim2.new(0, 12, 0, 12), AutoButtonColor = false}), Create("ImageButton", {Parent = Controls, BackgroundColor3 = Ascent.Theme.TrafficGreen, Position = UDim2.new(0, 58, 0, 18), Size = UDim2.new(0, 12, 0, 12), AutoButtonColor = false})
    for _, b in pairs({C, M, MX}) do Create("UICorner", {Parent = b, CornerRadius = UDim.new(1,0)}) end
    C.MouseButton1Click:Connect(function() Ascent.IsVisible = false; Main.Visible = false; Ascent.MinimizeBtnRef.Visible = true end)
    
    Create("TextLabel", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 50), Size = UDim2.new(1, -20, 0, 30), Text = Config.Title or "Ascent Lib", Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left})
    local TabHolder = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 90), Size = UDim2.new(1, -20, 1, -140), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0}); Create("UIListLayout", {Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local PageHolder = Create("Frame", {Name = "PageHolder", Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(0, 200, 0, 0), Size = UDim2.new(1, -200, 1, 0), ClipsDescendants = true})
    
    local Footer = Create("Frame", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, -50), Size = UDim2.new(1, 0, 0, 50)}); Create("Frame", {Parent = Footer, BackgroundColor3 = Ascent.Theme.Divider, Size = UDim2.new(1, -40, 0, 1), Position = UDim2.new(0, 20, 0, 0)})
    local Av = Create("ImageLabel", {Parent = Footer, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0.5, -12), Size = UDim2.new(0, 24, 0, 24), Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)}); Create("UICorner", {Parent = Av, CornerRadius = UDim.new(1, 0)})
    Create("TextLabel", {Parent = Footer, BackgroundTransparency = 1, Position = UDim2.new(0, 54, 0, 0), Size = UDim2.new(0, 100, 1, 0), Text = LocalPlayer.Name, Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
    MakeDraggable(Sidebar, Main)

    local Window = {}
    local FirstTab = true

    -- TAB & GROUP LOGIC
    local function CreateTabLogic(Name, IconId, ParentList, ParentPage)
        local Tab = {Elements = {}}
        local Page = Create("ScrollingFrame", {Name = Name, Parent = ParentPage, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = Ascent.Theme.Divider}); Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)}); Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})
        local Btn = Create("TextButton", {Parent = ParentList, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Text = "       "..Name, Font = Enum.Font.GothamMedium, TextColor3 = Ascent.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false}); Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
        local Icon = Create("ImageLabel", {Parent = Btn, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = IconId or "rbxassetid://6034509923", ImageColor3 = Ascent.Theme.SubText})

        local function Activate()
            for _, v in pairs(TabHolder:GetDescendants()) do if v:IsA("TextButton") and v.Parent == TabHolder then TweenService:Create(v, TweenInfo.new(0.2), {BackgroundColor3 = Ascent.Theme.Sidebar, TextColor3 = Ascent.Theme.SubText}):Play(); if v:FindFirstChild("ImageLabel") then TweenService:Create(v.ImageLabel, TweenInfo.new(0.2), {ImageColor3 = Ascent.Theme.SubText}):Play() end end end
            for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Ascent.Theme.Element, TextColor3 = Ascent.Theme.Text}):Play(); TweenService:Create(Icon, TweenInfo.new(0.2), {ImageColor3 = Ascent.Theme.Accent}):Play()
            Page.Visible = true
        end
        Btn.MouseButton1Click:Connect(Activate)
        if FirstTab then Activate(); FirstTab = false end
        RegisterContainerFunctions(Tab, Page)
        function Tab:SetVisible(v) Btn.Visible = v end
        function Tab:Show() Activate() end
        return Tab
    end

    function Window:CreateTab(Name, IconId) return CreateTabLogic(Name, IconId, TabHolder, PageHolder) end

    function Window:CreateTabGroup(Name, IconId)
        local Group = {}
        local GBtn = Create("TextButton", {Parent = TabHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Text = "       "..Name, Font = Enum.Font.GothamBold, TextColor3 = Ascent.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false}); Create("UICorner", {Parent = GBtn, CornerRadius = UDim.new(0, 6)})
        local Icon = Create("ImageLabel", {Parent = GBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = IconId or "rbxassetid://6034509923", ImageColor3 = Ascent.Theme.Text})
        local Arrow = Create("ImageLabel", {Parent = GBtn, BackgroundTransparency = 1, Position = UDim2.new(1, -25, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://6034818372", ImageColor3 = Ascent.Theme.SubText, Rotation = 180})
        
        local GHolder = Create("Frame", {Parent = TabHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true}); Create("UIListLayout", {Parent = GHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}); Create("UIPadding", {Parent = GHolder, PaddingLeft = UDim.new(0, 15)})
        
        local Open = true
        GBtn.MouseButton1Click:Connect(function() Open = not Open; TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Open and 180 or 0}):Play(); GHolder.Visible = Open end)

        function Group:CreateTab(Name, Icon)
            return CreateTabLogic(Name, Icon, GHolder, PageHolder)
        end
        return Group
    end

    return Window
end
return Ascent
