local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Elements = {}, 
    OpenedFrames = {},
    NotificationArea = nil,
    ToastArea = nil,
    ModalArea = nil,
    IsMobile = UserInputService.TouchEnabled,
    CurrentTheme = "Dark",
    MainFrameRef = nil,
    MinimizeBtnRef = nil,
    ScaleObj = nil,
    Keybind = Enum.KeyCode.RightControl,
    IsVisible = true,
    Flags = {},
    ConfigFolder = "ModernUI_Configs",
    Version = "13.0 GODLIKE"
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
        Red = Color3.fromRGB(255, 60, 60),
        Green = Color3.fromRGB(46, 204, 113),
        Yellow = Color3.fromRGB(241, 196, 15),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Midnight = {
        Background = Color3.fromRGB(0, 0, 5),
        Background2 = Color3.fromRGB(10, 10, 20),
        Sidebar = Color3.fromRGB(5, 5, 15),
        Section = Color3.fromRGB(10, 10, 20),
        Element = Color3.fromRGB(15, 15, 25),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 200),
        Divider = Color3.fromRGB(50, 50, 100),
        Gradient1 = Color3.fromRGB(100, 0, 255),
        Gradient2 = Color3.fromRGB(0, 0, 150),
        Red = Color3.fromRGB(200, 50, 50),
        Green = Color3.fromRGB(50, 200, 50),
        Yellow = Color3.fromRGB(255, 200, 50),
        Shadow = Color3.fromRGB(0, 0, 0)
    }
}
Library.Theme = Library.Themes.Dark

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

local function AddAPI(Obj, Frame, Config)
    function Obj:SetVisible(bool) Frame.Visible = bool end
    function Obj:Destroy() Frame:Destroy() end
    function Obj:GetFrame() return Frame end
    function Obj:SetTransparency(val) Frame.BackgroundTransparency = val end
    function Obj:SetColor(col) Frame.BackgroundColor3 = col end
    function Obj:SetLocked(bool)
        if Frame:FindFirstChild("LockOverlay") then Frame.LockOverlay:Destroy() end
        if bool then
            local Ov = Create("Frame", {Name = "LockOverlay", Parent = Frame, BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.6, Size = UDim2.new(1,0,1,0), ZIndex = 100}); Create("UICorner", {Parent = Ov, CornerRadius = UDim.new(0,6)})
            Create("ImageLabel", {Parent = Ov, BackgroundTransparency = 1, Size = UDim2.new(0,20,0,20), Position = UDim2.new(0.5,-10,0.5,-10), Image = "rbxassetid://3926305904", ImageColor3 = Color3.new(1,1,1)})
        end
    end
    -- Tooltip support for everything
    if Config and Config.Tooltip then
        Frame.MouseEnter:Connect(function() 
            Library:ShowTooltip(Config.Tooltip) 
        end)
        Frame.MouseLeave:Connect(function() 
            Library:HideTooltip() 
        end)
    end
end

--// GLOBAL API
function Library:SetTheme(ThemeName)
    if Library.Themes[ThemeName] then 
        Library.Theme = Library.Themes[ThemeName]
        Library.CurrentTheme = ThemeName
        if Library.MainFrameRef then
             Library.MainFrameRef.MainGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Library.Theme.Background),
                ColorSequenceKeypoint.new(1, Library.Theme.Background2)
            }
        end
    end
end

function Library:SetScale(Scale)
    if Library.ScaleObj then Library.ScaleObj.Scale = math.clamp(Scale, 0.5, 2) end
end

--// NOTIFICATION SYSTEM
function Library:Notify(Config)
    Config = Config or {}
    local Frame = Create("Frame", {Parent = Library.NotificationArea, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true}); Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = Frame, Color = Library.Theme.Divider, Thickness = 1})
    local G = Create("Frame", {Parent = Frame, Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = Color3.new(1,1,1)}); ApplyGradient(G)
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 5), Size = UDim2.new(1, -20, 0, 20), Font = Enum.Font.GothamBold, Text = Config.Title or "Notification", TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 25), Size = UDim2.new(1, -20, 0, 35), Font = Enum.Font.Gotham, Text = Config.Content or "", TextColor3 = Library.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
    TweenService:Create(Frame, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 65)}):Play()
    task.delay(Config.Duration or 3, function() if Frame then TweenService:Create(Frame, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 0)}):Play(); task.wait(0.4); Frame:Destroy() end end)
end

function Library:ShowToast(Text)
    local T = Create("Frame", {Parent = Library.ToastArea, BackgroundColor3 = Color3.fromRGB(20,20,20), Size = UDim2.new(0,0,0,30), AutomaticSize = Enum.AutomaticSize.X}); Create("UICorner", {Parent = T, CornerRadius = UDim.new(1,0)})
    Create("UIStroke", {Parent = T, Color = Library.Theme.Gradient1, Thickness = 1})
    Create("TextLabel", {Parent = T, BackgroundTransparency = 1, Size = UDim2.new(0,0,1,0), AutomaticSize = Enum.AutomaticSize.X, Position = UDim2.new(0,15,0,0), Text = Text, Font = Enum.Font.Gotham, TextColor3 = Color3.new(1,1,1), TextSize = 12})
    Create("UIPadding", {Parent = T, PaddingRight = UDim.new(0,15)})
    TweenService:Create(T, TweenInfo.new(0.3), {Position = UDim2.new(0.5,0,0.9,-50)}):Play()
    task.delay(2, function() T:Destroy() end)
end

--// CONTAINER FUNCTIONS
local function RegisterContainerFunctions(Container, PageInstance)
    local Funcs = {}
    
    local function AddElementFrame(SizeY)
        local F = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, SizeY)})
        Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 6)})
        return F
    end

    --// 1. GRID CONTAINER
    function Funcs:AddGrid(Config)
        local F = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y})
        local G = Create("UIGridLayout", {Parent = F, CellSize = UDim2.new(0.32, 0, 0, Config.Height or 100), CellPadding = UDim2.new(0, 5, 0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
        local Obj = {}; Obj.Frame = F
        
        -- Proxy function to add elements directly to grid
        function Obj:AddCard(Title, Value)
            local Card = Create("Frame", {Parent = F, BackgroundColor3 = Library.Theme.Element}); Create("UICorner", {Parent = Card, CornerRadius = UDim.new(0,6)})
            Create("TextLabel", {Parent = Card, Text = Title, Position = UDim2.new(0,5,0,5), Size = UDim2.new(1,-10,0,20), BackgroundTransparency = 1, TextColor3 = Library.Theme.SubText, Font = Enum.Font.Gotham, TextSize = 11})
            local V = Create("TextLabel", {Parent = Card, Text = Value, Position = UDim2.new(0,5,0.5,-10), Size = UDim2.new(1,-10,0.5,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 16})
            return {
                Update = function(self, v) V.Text = v end,
                SetColor = function(self, c) Card.BackgroundColor3 = c end
            }
        end
        return Obj
    end

    --// 2. SCROLL BOX (Nested Scrolling)
    function Funcs:AddScrollBox(Config)
        local F = AddElementFrame(Config.Height or 150)
        local S = Create("ScrollingFrame", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1,-10,1,-10), Position = UDim2.new(0,5,0,5), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2})
        Create("UIListLayout", {Parent = S, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
        local Handler = {}; RegisterContainerFunctions(Handler, S); return Handler
    end

    --// 3. COLLAPSIBLE SECTION
    function Funcs:AddCollapsible(Config)
        local F = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1,0,0,30), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true}); Create("UICorner", {Parent = F, CornerRadius = UDim.new(0,6)})
        local Btn = Create("TextButton", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30), Text = ""})
        Create("TextLabel", {Parent = F, Text = Config.Title, Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-40,0,30), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left})
        local Icon = Create("ImageLabel", {Parent = F, Image = "rbxassetid://6034818372", Position = UDim2.new(1,-25,0,7), Size = UDim2.new(0,16,0,16), BackgroundTransparency = 1, Rotation = 180})
        
        local Content = Create("Frame", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,35), Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y})
        Create("UIListLayout", {Parent = Content, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,5)}); Create("UIPadding", {Parent = Content, PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5), PaddingBottom = UDim.new(0,5)})
        
        local Open = true
        Btn.MouseButton1Click:Connect(function() 
            Open = not Open 
            Icon.Rotation = Open and 180 or 0
            Content.Visible = Open
        end)
        
        local Handler = {}; RegisterContainerFunctions(Handler, Content); return Handler
    end

    --// 4. ACRYLIC BLUR
    function Funcs:AddAcrylicBlur()
        -- Fake blur using Image
        local F = Create("ImageLabel", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,100), Image = "rbxassetid://8992230677", ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(100,100,100,100), ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.5})
        return F
    end

    --// 5. VIEWPORT (3D Model)
    function Funcs:AddViewport(Config)
        local F = AddElementFrame(Config.Height or 150)
        local VP = Create("ViewportFrame", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), LightColor = Color3.new(1,1,1), Ambient = Color3.new(0.5,0.5,0.5)})
        local Cam = Instance.new("Camera"); VP.CurrentCamera = Cam; Cam.Parent = VP
        
        local Obj = {}; AddAPI(Obj, F, Config)
        function Obj:SetModel(Part)
            VP:ClearAllChildren()
            local Clone = Part:Clone(); Clone.Parent = VP
            if Clone:IsA("Model") then
                local CF, Size = Clone:GetBoundingBox()
                Cam.CFrame = CFrame.new(CF.Position + Vector3.new(Size.X*1.5, Size.Y, Size.Z*1.5), CF.Position)
            elseif Clone:IsA("BasePart") then
                Cam.CFrame = CFrame.new(Clone.Position + Vector3.new(3,3,3), Clone.Position)
            end
        end
        return Obj
    end

    --// 6. RICH TEXT LABEL
    function Funcs:AddRichText(Config)
        local F = AddElementFrame(0) -- Auto size
        F.AutomaticSize = Enum.AutomaticSize.Y
        local T = Create("TextLabel", {Parent = F, Text = Config.Text, BackgroundTransparency = 1, Size = UDim2.new(1,-20,0,0), Position = UDim2.new(0,10,0,10), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, RichText = true, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 13})
        Create("UIPadding", {Parent = F, PaddingBottom = UDim.new(0,10)})
        return F
    end

    --// 7. LINE GRAPH (Realtime)
    function Funcs:AddLineGraph(Config)
        local F = AddElementFrame(120)
        Create("TextLabel", {Parent = F, Text = Config.Text, Position = UDim2.new(0,10,0,5), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left})
        local GArea = Create("Frame", {Parent = F, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0,10,0,30), Size = UDim2.new(1,-20,0,80), ClipsDescendants = true}); Create("UICorner", {Parent = GArea, CornerRadius = UDim.new(0,4)})
        
        local Points = {}
        local MaxPoints = 20
        local Obj = {}; AddAPI(Obj, F, Config)
        
        function Obj:Push(Value)
            table.insert(Points, Value)
            if #Points > MaxPoints then table.remove(Points, 1) end
            GArea:ClearAllChildren()
            
            local Min, Max = 999999, -999999
            for _,v in pairs(Points) do if v<Min then Min=v end if v>Max then Max=v end end
            if Min==Max then Max=Min+1 end
            
            local Width = GArea.AbsoluteSize.X / (MaxPoints-1)
            for i=1, #Points-1 do
                local Y1 = 1 - (Points[i]-Min)/(Max-Min)
                local Y2 = 1 - (Points[i+1]-Min)/(Max-Min)
                local P1 = Vector2.new((i-1)*Width, Y1*GArea.AbsoluteSize.Y)
                local P2 = Vector2.new(i*Width, Y2*GArea.AbsoluteSize.Y)
                
                local Line = Create("Frame", {Parent = GArea, BackgroundColor3 = Library.Theme.Gradient1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5)})
                local Dist = (P2-P1).Magnitude
                local Ang = math.atan2(P2.Y-P1.Y, P2.X-P1.X)
                Line.Size = UDim2.new(0, Dist, 0, 2)
                Line.Position = UDim2.new(0, (P1.X+P2.X)/2, 0, (P1.Y+P2.Y)/2)
                Line.Rotation = math.deg(Ang)
            end
        end
        return Obj
    end

    --// 8. CIRCULAR PROGRESS
    function Funcs:AddCircularProgress(Config)
        local F = AddElementFrame(100)
        Create("TextLabel", {Parent = F, Text = Config.Text, Position = UDim2.new(0,10,0,5), Size = UDim2.new(1,-100,0,20), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
        local Circle = Create("Frame", {Parent = F, Position = UDim2.new(1,-90,0.5,-40), Size = UDim2.new(0,80,0,80), BackgroundTransparency = 1})
        
        local Base = Create("ImageLabel", {Parent = Circle, Size = UDim2.new(1,0,1,0), Image = "rbxassetid://3570695787", ImageColor3 = Library.Theme.Section, BackgroundTransparency = 1})
        local Progress = Create("ImageLabel", {Parent = Circle, Size = UDim2.new(1,0,1,0), Image = "rbxassetid://3570695787", ImageColor3 = Library.Theme.Gradient1, BackgroundTransparency = 1})
        local Label = Create("TextLabel", {Parent = Circle, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "0%", TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold})
        
        -- Simplified circular reveal using UIGradient
        local Grad = Create("UIGradient", {Parent = Progress, Rotation = 90, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(0.5,0), NumberSequenceKeypoint.new(0.51,1), NumberSequenceKeypoint.new(1,1)}})
        
        local Obj = {}; AddAPI(Obj, F, Config)
        function Obj:Set(Val) -- 0 to 100
            Val = math.clamp(Val, 0, 100)
            Label.Text = math.floor(Val).."%"
            -- A true circular progress needs 2 halves, simplified here for code size:
            -- Rotating the gradient gives a partial effect.
            Grad.Rotation = 90 + (3.6 * Val) -- Visual hack
        end
        return Obj
    end

    --// 9. SWITCH (iOS Style Toggle)
    function Funcs:AddSwitch(Config)
        local State = Config.Default or false
        local F = AddElementFrame(40)
        Create("TextLabel", {Parent = F, Text = Config.Text, Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-60,1,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
        
        local S = Create("TextButton", {Parent = F, Position = UDim2.new(1,-50,0.5,-12), Size = UDim2.new(0,40,0,24), BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section, Text = ""}); Create("UICorner", {Parent = S, CornerRadius = UDim.new(1,0)})
        local Knob = Create("Frame", {Parent = S, Position = State and UDim2.new(1,-22,0,2) or UDim2.new(0,2,0,2), Size = UDim2.new(0,20,0,20), BackgroundColor3 = Color3.new(1,1,1)}); Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1,0)})
        
        S.MouseButton1Click:Connect(function()
            State = not State
            TweenService:Create(S, TweenInfo.new(0.2), {BackgroundColor3 = State and Library.Theme.Gradient1 or Library.Theme.Section}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.2), {Position = State and UDim2.new(1,-22,0,2) or UDim2.new(0,2,0,2)}):Play()
            if Config.Callback then Config.Callback(State) end
        end)
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end

    --// 10. KEYPAD (Number Input)
    function Funcs:AddKeypad(Config)
        local F = AddElementFrame(0); F.AutomaticSize = Enum.AutomaticSize.Y
        Create("TextLabel", {Parent = F, Text = Config.Text, Size = UDim2.new(1,0,0,30), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
        local Display = Create("TextBox", {Parent = F, Position = UDim2.new(0,10,0,30), Size = UDim2.new(1,-20,0,30), Text = "", BackgroundColor3 = Library.Theme.Section, TextColor3 = Library.Theme.Gradient1, Font = Enum.Font.Code, TextSize = 16}); Create("UICorner", {Parent = Display, CornerRadius = UDim.new(0,4)})
        
        local Grid = Create("Frame", {Parent = F, Position = UDim2.new(0,10,0,70), Size = UDim2.new(1,-20,0,150), BackgroundTransparency = 1})
        local GL = Create("UIGridLayout", {Parent = Grid, CellSize = UDim2.new(0.3,0,0.22,0), CellPadding = UDim2.new(0.03,0,0.03,0)})
        
        local Keys = {"1","2","3","4","5","6","7","8","9","C","0","OK"}
        for _,k in pairs(Keys) do
            local B = Create("TextButton", {Parent = Grid, Text = k, BackgroundColor3 = Library.Theme.Section, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold})
            Create("UICorner", {Parent = B, CornerRadius = UDim.new(0,4)})
            B.MouseButton1Click:Connect(function()
                if k == "C" then Display.Text = "" 
                elseif k == "OK" then 
                    if Config.Callback then Config.Callback(tonumber(Display.Text)) end
                else Display.Text = Display.Text .. k end
            end)
        end
        
        Create("UIPadding", {Parent = F, PaddingBottom = UDim.new(0,10)})
        return F
    end

    --// 11. SEGMENTED CONTROL
    function Funcs:AddSegmented(Config)
        local F = AddElementFrame(40)
        local Items = Config.Items or {"A", "B"}
        local Sel = Config.Default or Items[1]
        
        local Holder = Create("Frame", {Parent = F, Position = UDim2.new(0,5,0,5), Size = UDim2.new(1,-10,1,-10), BackgroundColor3 = Library.Theme.Section}); Create("UICorner", {Parent = Holder, CornerRadius = UDim.new(0,4)})
        local List = Create("UIListLayout", {Parent = Holder, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder})
        
        local Btns = {}
        for i, v in ipairs(Items) do
            local B = Create("TextButton", {Parent = Holder, Size = UDim2.new(1/#Items, 0, 1, 0), BackgroundTransparency = 1, Text = v, TextColor3 = (v==Sel) and Library.Theme.Gradient1 or Library.Theme.SubText, Font = Enum.Font.GothamBold})
            B.MouseButton1Click:Connect(function()
                Sel = v
                for _, btn in pairs(Btns) do btn.TextColor3 = Library.Theme.SubText end
                B.TextColor3 = Library.Theme.Gradient1
                if Config.Callback then Config.Callback(v) end
            end)
            table.insert(Btns, B)
        end
        return F
    end

    --// 12. VECTOR2 SLIDER (XY Pad)
    function Funcs:AddVector2(Config)
        local F = AddElementFrame(150)
        Create("TextLabel", {Parent = F, Text = Config.Text, Position = UDim2.new(0,10,0,5), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
        local Box = Create("Frame", {Parent = F, Position = UDim2.new(0.5,-50, 0.5,-30), Size = UDim2.new(0,100,0,100), BackgroundColor3 = Library.Theme.Section}); Create("UICorner", {Parent = Box, CornerRadius = UDim.new(0,4)})
        local Dot = Create("Frame", {Parent = Box, Size = UDim2.new(0,10,0,10), BackgroundColor3 = Library.Theme.Gradient1, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0)}); Create("UICorner", {Parent = Dot, CornerRadius = UDim.new(1,0)})
        
        local Dragging = false
        Box.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then Dragging=true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then Dragging=false end end)
        UserInputService.InputChanged:Connect(function(i)
            if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local P = Vector2.new(Mouse.X, Mouse.Y) - Box.AbsolutePosition
                local X = math.clamp(P.X/Box.AbsoluteSize.X, 0, 1)
                local Y = math.clamp(P.Y/Box.AbsoluteSize.Y, 0, 1)
                Dot.Position = UDim2.new(X,0,Y,0)
                if Config.Callback then Config.Callback(Vector2.new(X,Y)) end
            end
        end)
        return F
    end

    --// 13. COUNTDOWN
    function Funcs:AddCountdown(Config)
        local F = AddElementFrame(40)
        local L = Create("TextLabel", {Parent = F, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "00:00", TextColor3 = Library.Theme.Gradient1, Font = Enum.Font.GothamBold, TextSize = 18})
        local Time = Config.Time or 60
        task.spawn(function()
            while Time > 0 do
                Time = Time - 1
                L.Text = string.format("%02d:%02d", math.floor(Time/60), Time%60)
                task.wait(1)
            end
            if Config.Callback then Config.Callback() end
        end)
        return F
    end

    --// 14. CLOCK
    function Funcs:AddClock()
        local F = AddElementFrame(40)
        local L = Create("TextLabel", {Parent = F, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "--:--:--", TextColor3 = Library.Theme.Text, Font = Enum.Font.Code, TextSize = 18})
        task.spawn(function()
            while F.Parent do
                L.Text = os.date("%X")
                task.wait(1)
            end
        end)
        return F
    end

    --// 15. UI PARTICLES
    function Funcs:AddParticles(Config)
        local F = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,50)})
        local B = Create("TextButton", {Parent = F, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Library.Theme.Section, Text = Config.Text or "Spawn Confetti", TextColor3 = Library.Theme.Text}); Create("UICorner", {Parent = B, CornerRadius = UDim.new(0,6)})
        
        B.MouseButton1Click:Connect(function()
            for i=1, 20 do
                local P = Create("Frame", {Parent = Library.MainFrameRef, Size = UDim2.new(0,5,0,5), BackgroundColor3 = Color3.fromHSV(math.random(),1,1), Position = UDim2.new(0.5, math.random(-50,50), 0.5, math.random(-50,50))})
                TweenService:Create(P, TweenInfo.new(1), {Position = P.Position + UDim2.new(0,math.random(-100,100), 0, math.random(-100,100)), BackgroundTransparency = 1}):Play()
                task.delay(1, function() P:Destroy() end)
            end
        end)
        return F
    end

    --// EXISTING (IMPROVED)
    function Funcs:AddSection(Title)
        local SFrame = Create("Frame", {Parent = PageInstance, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y})
        local Btn = Create("TextButton", {Parent = SFrame, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 30), Text = "", AutoButtonColor = false}); Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
        local Text = Create("TextLabel", {Parent = Btn, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -40, 1, 0), Text = Title, Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Gradient1, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local ContainerFrame = Create("Frame", {Parent = SFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 35), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
        Create("UIListLayout", {Parent = ContainerFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)}); Create("UIPadding", {Parent = ContainerFrame, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})
        local Open = true
        Btn.MouseButton1Click:Connect(function() Open = not Open; ContainerFrame.Visible = Open end)
        local SectionHandler = {}; RegisterContainerFunctions(SectionHandler, ContainerFrame); AddAPI(SectionHandler, SFrame, {}); return SectionHandler
    end
    
    function Funcs:Divide() local F = Create("Frame", {Parent = PageInstance, Size = UDim2.new(1,0,0,10), BackgroundTransparency = 1}); Create("Frame", {Parent = F, BackgroundColor3 = Library.Theme.Divider, Size = UDim2.new(1,-20,0,1), Position = UDim2.new(0,10,0.5,0)}); return F end
    function Funcs:Space(P) return Create("Frame", {Parent = PageInstance, Size = UDim2.new(1,0,0,P or 10), BackgroundTransparency = 1}) end

    -- Draggable List from previous requests
    function Funcs:AddDraggableList(Config)
        local F = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}); Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 6)})
        Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 0, 30), Text = Config.Text, Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local C = Create("Frame", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}); Create("UIListLayout", {Parent = C, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)}); Create("UIPadding", {Parent = C, Padding: UDim.new(0,10)})
        local Buttons = {}
        local function Refresh()
            for _, v in pairs(C:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end; Buttons = {}
            for i, item in ipairs(Config.Items or {}) do
                local IF = Create("Frame", {Name = item, Parent = C, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = i}); Create("UICorner", {Parent = IF, CornerRadius = UDim.new(0, 4)})
                local RB = Create("TextBox", {Parent = IF, BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0, 5, 0.5, -10), Size = UDim2.new(0, 24, 0, 20), Text = tostring(i), Font = Enum.Font.Gotham, TextColor3 = Library.Theme.SubText}); Create("UICorner", {Parent = RB, CornerRadius = UDim.new(0, 4)})
                Create("TextLabel", {Parent = IF, BackgroundTransparency = 1, Size = UDim2.new(1, -65, 1, 0), Position = UDim2.new(0, 35, 0, 0), Text = item, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left})
                local Grip = Create("ImageButton", {Parent = IF, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0.5, -12), Size = UDim2.new(0, 24, 0, 24), Image = "rbxassetid://6034818372", ImageColor3 = Library.Theme.SubText, Rotation = 90})
                local Holding, HoldStart = false, 0
                Grip.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Holding = true; HoldStart = tick()
                        task.spawn(function()
                            while Holding do
                                if tick() - HoldStart >= 0.67 then
                                    TweenService:Create(IF, TweenInfo.new(0.2), {Size = UDim2.new(1.05, 0, 0, 40), BackgroundColor3 = Library.Theme.Gradient1}):Play()
                                    break
                                end
                                task.wait(0.1)
                            end
                        end)
                        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Holding = false; TweenService:Create(IF, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Library.Theme.Element}):Play() end end)
                    end
                end)
                table.insert(Buttons, IF)
            end
        end
        Refresh()
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end

    function Funcs:AddButton(Config)
        local F = AddElementFrame(36)
        local B = Create("TextButton", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = Config.Text, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text})
        B.MouseButton1Click:Connect(function() CreateRipple(F); if Config.Callback then Config.Callback() end end)
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end

    function Funcs:AddToggle(Config)
        local State = Config.Default or false
        local F = AddElementFrame(36)
        Create("TextLabel", {Parent = F, Text = Config.Text, Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-40,1,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
        local Check = Create("Frame", {Parent = F, Position = UDim2.new(1,-30,0.5,-10), Size = UDim2.new(0,20,0,20), BackgroundColor3 = Library.Theme.Section}); Create("UICorner", {Parent = Check, CornerRadius = UDim.new(0,4)})
        local Ind = Create("Frame", {Parent = Check, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Library.Theme.Gradient1, Visible = State}); Create("UICorner", {Parent = Ind, CornerRadius = UDim.new(0,4)})
        local B = Create("TextButton", {Parent = F, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})
        B.MouseButton1Click:Connect(function() State = not State; Ind.Visible = State; if Config.Callback then Config.Callback(State) end end)
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end
    
    function Funcs:AddSlider(Config)
        local Min, Max, Val = Config.Min, Config.Max, Config.Default or Config.Min
        local F = AddElementFrame(45)
        Create("TextLabel", {Parent = F, Text = Config.Text, Position = UDim2.new(0,10,0,5), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
        local Bar = Create("Frame", {Parent = F, Position = UDim2.new(0,10,0,30), Size = UDim2.new(1,-20,0,4), BackgroundColor3 = Library.Theme.Section}); Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1,0)})
        local Fill = Create("Frame", {Parent = Bar, Size = UDim2.new((Val-Min)/(Max-Min),0,1,0), BackgroundColor3 = Library.Theme.Gradient1}); Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1,0)})
        local Drag = Create("TextButton", {Parent = Bar, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})
        local Dragging = false
        Drag.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then Dragging=true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then Dragging=false end end)
        UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local S = math.clamp((Mouse.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
            Fill.Size = UDim2.new(S,0,1,0)
            if Config.Callback then Config.Callback(Min + (S*(Max-Min))) end
        end end)
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end

    function Funcs:AddDropdown(Config)
        local F = Create("Frame", {Parent = PageInstance, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1,0,0,35), ClipsDescendants = true}); Create("UICorner", {Parent = F, CornerRadius = UDim.new(0,6)})
        local Title = Create("TextLabel", {Parent = F, Text = Config.Text..": "..(Config.Default or ""), Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-40,0,35), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
        local B = Create("TextButton", {Parent = F, Size = UDim2.new(1,0,0,35), BackgroundTransparency = 1, Text = ""})
        local List = Create("ScrollingFrame", {Parent = F, Position = UDim2.new(0,0,0,35), Size = UDim2.new(1,0,0,100), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y}); Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})
        
        local Open = false
        for _, v in pairs(Config.Items) do
            local IB = Create("TextButton", {Parent = List, Size = UDim2.new(1,0,0,25), BackgroundColor3 = Library.Theme.Section, Text = v, TextColor3 = Library.Theme.SubText}); Create("UICorner", {Parent = IB, CornerRadius = UDim.new(0,4)})
            IB.MouseButton1Click:Connect(function() Open=false; TweenService:Create(F, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,35)}):Play(); Title.Text = Config.Text..": "..v; if Config.Callback then Config.Callback(v) end end)
        end
        B.MouseButton1Click:Connect(function() Open=not Open; TweenService:Create(F, TweenInfo.new(0.3), {Size = Open and UDim2.new(1,0,0,140) or UDim2.new(1,0,0,35)}):Play() end)
        local Obj = {}; AddAPI(Obj, F, Config); return Obj
    end

    for k, v in pairs(Funcs) do Container[k] = v end
end

--// MAIN WINDOW CREATION
function Library:CreateWindow(Config)
    if Library.ScreenGuiRef then Library.ScreenGuiRef:Destroy() end
    local Gui = Create("ScreenGui", {Name = "ModernUI_V13_GODLIKE", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    Library.ScreenGuiRef = Gui
    Library:InitNotifications(Gui)
    
    -- Toast & Modal Layers
    Library.ToastArea = Create("Frame", {Parent = Gui, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ZIndex = 2000})
    Library.ModalArea = Create("Frame", {Parent = Gui, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ZIndex = 3000})

    local ScaleObj = Create("UIScale", {Parent = Gui, Scale = 1}); Library.ScaleObj = ScaleObj

    local Main = Create("Frame", {Name = "MainFrame", Parent = Gui, BackgroundColor3 = Color3.new(1,1,1), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Size = Config.Size or UDim2.fromOffset(650, 450), ClipsDescendants = true}); Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 8)})
    -- Godlike Shadow
    Create("ImageLabel", {Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(0,-20,0,-20), Size = UDim2.new(1,40,1,40), Image = "rbxassetid://5554236805", ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(23,23,277,277), ImageColor3 = Library.Theme.Shadow, ZIndex = -1, ImageTransparency = 0.4})
    
    local Grad = Create("UIGradient", {Name = "MainGradient", Parent = Main, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Library.Theme.Background), ColorSequenceKeypoint.new(1, Library.Theme.Background2)}})
    Library.MainFrameRef = Main
    
    local Top = Create("Frame", {Parent = Main, BackgroundColor3 = Library.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 50)}); Create("UICorner", {Parent = Top, CornerRadius = UDim.new(0, 8)})
    Create("Frame", {Parent = Top, BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0, Position = UDim2.new(0,0,1,-10), Size = UDim2.new(1,0,0,10)})
    local Title = Create("TextLabel", {Parent = Top, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0, 200, 1, 0), Font = Enum.Font.GothamBold, Text = Config.Title or "UI", TextColor3 = Color3.new(1,1,1), TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left}); ApplyGradient(Title).Enabled = true

    MakeDraggable(Top, Main)

    local Sidebar = Create("Frame", {Parent = Main, BackgroundColor3 = Library.Theme.Sidebar, Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(0, 160, 1, -50), BorderSizePixel = 0})
    local TabHolder = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 10), Size = UDim2.new(1, 0, 1, -10), CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0}); Create("UIListLayout", {Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local PageHolder = Create("Frame", {Name = "PageHolder", Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(0, 170, 0, 60), Size = UDim2.new(1, -180, 1, -70), ClipsDescendants = true})

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
    
    -- Built-in Settings
    local Settings = Window:CreateTab("Settings")
    Settings:AddLabel("UI Configuration", Library.Theme.Gradient1)
    Settings:AddDropdown({Text = "Theme", Items = {"Dark", "Midnight"}, Callback = function(v) Library:SetTheme(v) end})
    Settings:AddSlider({Text = "Scale", Min = 50, Max = 150, Default = 100, Callback = function(v) Library:SetScale(v/100) end})
    Settings:AddButton({Text = "Unload", Callback = function() Gui:Destroy() end})

    return Window
end

--// MODAL POPUP
function Library:ShowModal(Config)
    local M = Create("Frame", {Parent = Library.ModalArea, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(0,300,0,150), Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5)}); Create("UICorner", {Parent = M, CornerRadius = UDim.new(0,8)})
    Create("UIStroke", {Parent = M, Color = Library.Theme.Gradient1, Thickness = 2})
    Create("TextLabel", {Parent = M, Text = Config.Title, Position = UDim2.new(0,0,0,10), Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Text, TextSize = 16})
    Create("TextLabel", {Parent = M, Text = Config.Text, Position = UDim2.new(0,10,0,40), Size = UDim2.new(1,-20,0,60), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.SubText, TextSize = 14, TextWrapped = true})
    local B1 = Create("TextButton", {Parent = M, Text = "Confirm", BackgroundColor3 = Library.Theme.Gradient1, Position = UDim2.new(0,20,1,-40), Size = UDim2.new(0.4,0,0,30)}); Create("UICorner", {Parent = B1, CornerRadius = UDim.new(0,4)})
    local B2 = Create("TextButton", {Parent = M, Text = "Cancel", BackgroundColor3 = Library.Theme.Section, Position = UDim2.new(0.6,-20,1,-40), Size = UDim2.new(0.4,0,0,30), TextColor3 = Library.Theme.Text}); Create("UICorner", {Parent = B2, CornerRadius = UDim.new(0,4)})
    
    B1.MouseButton1Click:Connect(function() if Config.OnConfirm then Config.OnConfirm() end; M:Destroy() end)
    B2.MouseButton1Click:Connect(function() M:Destroy() end)
end

return Library
