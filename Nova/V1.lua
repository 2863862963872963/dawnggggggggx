-- ============================================================
--   NovaUI v2.0 — Glassmorphism / Neumorphism UI Library
--   by NovaUI | Roblox LocalScript UI Framework
-- ============================================================
--[[
    API OVERVIEW:
    
    local Nova = loadstring(game:HttpGet("..."))()

    local win = Nova.new(title, options?)
        options: {
            theme     = "glass" | "dark" | "light"
            position  = UDim2
            size      = UDim2
            draggable = bool
            dpi       = number (0.5 – 3.0)
            hideKey   = Enum.KeyCode
        }

    local tab    = win:AddTab(name)
    local module = tab:AddModule(title, description?)
    
    module:AddToggle(name, default?)        → Toggle
    module:AddSlider(name, min, max, def?)  → Slider
    module:AddButton(icon, label?)          → Button
    module:AddColorPicker(name, default?)   → ColorPicker
    module:AddDropdown(name, options, def?) → Dropdown
    module:AddKeybind(name, default?)       → Keybind
    module:AddLabel(text)
    module:AddSeparator()

    component:OnChanged(callback)
    component:SetValue(value)

    win:SetDPI(scale)
    win:Hide()
    win:Show()
    win:Destroy()

    Nova:Notify(title, message, type?, duration?)
        type: "info" | "success" | "warn" | "error"
--]]

local Nova = {}
Nova.__index = Nova

-- ── Services ──────────────────────────────────────────────
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ── Theme ─────────────────────────────────────────────────
local THEME = {
    -- Surfaces
    Background      = Color3.fromRGB(14, 16, 28),
    Surface         = Color3.fromRGB(20, 23, 40),
    SurfaceHover    = Color3.fromRGB(26, 30, 52),
    Module          = Color3.fromRGB(22, 25, 44),
    ModuleBorder    = Color3.fromRGB(45, 50, 80),

    -- Accents
    Blue            = Color3.fromRGB(79, 142, 247),
    BlueHover       = Color3.fromRGB(100, 160, 255),
    Cyan            = Color3.fromRGB(56, 217, 245),
    Green           = Color3.fromRGB(52, 211, 153),
    Red             = Color3.fromRGB(248, 113, 113),
    Amber           = Color3.fromRGB(251, 191, 36),
    Purple          = Color3.fromRGB(139, 92, 246),

    -- Text
    Text            = Color3.fromRGB(232, 236, 255),
    TextDim         = Color3.fromRGB(130, 145, 190),
    TextMuted       = Color3.fromRGB(70, 85, 130),

    -- Misc
    ToggleOff       = Color3.fromRGB(40, 45, 70),
    ToggleOn        = Color3.fromRGB(79, 142, 247),
    SliderTrack     = Color3.fromRGB(30, 34, 58),
    SliderFill      = Color3.fromRGB(79, 142, 247),
    TabActive       = Color3.fromRGB(30, 34, 58),
    TabInactive     = Color3.fromRGB(0, 0, 0, 0),
    TitleBar        = Color3.fromRGB(16, 19, 33),
    Shadow          = Color3.fromRGB(0, 0, 0),
}

-- ── Tween helper ──────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

-- ── Spring Tween (for toggles) ────────────────────────────
local function SpringTween(obj, props, t)
    local info = TweenInfo.new(t or 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

-- ── Make corner / padding / stroke helpers ────────────────
local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function AddPadding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 8)
    p.PaddingRight  = UDim.new(0, right  or 8)
    p.PaddingBottom = UDim.new(0, bottom or 8)
    p.PaddingLeft   = UDim.new(0, left   or 8)
    p.Parent = parent
    return p
end

local function AddStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.ModuleBorder
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.6
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function AddListLayout(parent, direction, padding, ha, va)
    local l = Instance.new("UIListLayout")
    l.FillDirection = direction or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, padding or 6)
    l.HorizontalAlignment = ha or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = va or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function MakeFrame(props)
    local f = Instance.new("Frame")
    f.BackgroundColor3  = props.Color or THEME.Surface
    f.BackgroundTransparency = props.Transparency or 0
    f.BorderSizePixel   = 0
    f.Size              = props.Size or UDim2.new(1,0,0,30)
    f.Position          = props.Position or UDim2.new(0,0,0,0)
    f.ClipsDescendants  = props.Clips or false
    f.Name              = props.Name or "Frame"
    if props.Parent then f.Parent = props.Parent end
    return f
end

local function MakeLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.TextColor3    = props.Color or THEME.Text
    l.Font          = props.Font or Enum.Font.GothamMedium
    l.TextSize      = props.TextSize or 13
    l.Text          = props.Text or ""
    l.RichText      = props.RichText or false
    l.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
    l.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
    l.TextTruncate  = props.Truncate or Enum.TextTruncate.None
    l.Size          = props.Size or UDim2.new(1,0,0,20)
    l.Position      = props.Position or UDim2.new(0,0,0,0)
    l.Name          = props.Name or "Label"
    if props.Parent then l.Parent = props.Parent end
    return l
end

local function MakeButton(props)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = props.Color or THEME.Blue
    b.BackgroundTransparency = props.Transparency or 0
    b.BorderSizePixel  = 0
    b.TextColor3       = props.TextColor or THEME.Text
    b.Font             = props.Font or Enum.Font.GothamBold
    b.TextSize         = props.TextSize or 13
    b.Text             = props.Text or ""
    b.Size             = props.Size or UDim2.new(1,0,0,32)
    b.Position         = props.Position or UDim2.new(0,0,0,0)
    b.AutoButtonColor  = false
    b.Name             = props.Name or "Button"
    if props.Parent then b.Parent = props.Parent end
    return b
end

-- ── Auto DPI Detection ────────────────────────────────────
function Nova.AutoDPI()
    local vp = workspace.CurrentCamera.ViewportSize
    local diag = math.sqrt(vp.X^2 + vp.Y^2)
    -- Phone-sized (~720p diagonal or less)
    if diag < 1400 then
        return 1.3
    -- Tablet (~1080p range)
    elseif diag < 2000 then
        return 1.15
    else
        return 1.0
    end
end

-- ─────────────────────────────────────────────────────────
--   WINDOW
-- ─────────────────────────────────────────────────────────
function Nova.new(title, options)
    options = options or {}

    local self = setmetatable({}, Nova)
    self._tabs      = {}
    self._activeTab = nil
    self._dpi       = options.dpi or 1.0
    self._hidden    = false
    self._callbacks = {}
    self._hideKey   = options.hideKey or Enum.KeyCode.RightControl

    local BASE_W = 340
    local BASE_H = 420

    -- ── ScreenGui ─────────────────────────────────────────
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "NovaUI"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.DisplayOrder = 999
    pcall(function() Gui.Parent = CoreGui end)
    if not Gui.Parent then Gui.Parent = LocalPlayer.PlayerGui end
    self._gui = Gui

    -- ── Main Window Frame ─────────────────────────────────
    local WinSize = UDim2.new(0, BASE_W * self._dpi, 0, BASE_H * self._dpi)
    local WinPos  = options.position or UDim2.new(0.5, -(BASE_W * self._dpi)/2, 0.5, -(BASE_H * self._dpi)/2)

    local Win = MakeFrame({
        Name  = "Window",
        Color = THEME.Background,
        Size  = WinSize,
        Position = WinPos,
        Parent = Gui,
    })
    Win.AnchorPoint = Vector2.new(0, 0)
    AddCorner(Win, 18)
    AddStroke(Win, THEME.ModuleBorder, 1, 0.4)
    self._win = Win

    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"  -- rounded shadow
    Shadow.ImageColor3 = Color3.new(0,0,0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49,49,450,450)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.ZIndex = 0
    Shadow.Parent = Win

    -- ── Title Bar ─────────────────────────────────────────
    local TitleBar = MakeFrame({
        Name  = "TitleBar",
        Color = THEME.TitleBar,
        Size  = UDim2.new(1, 0, 0, 44 * self._dpi),
        Parent = Win,
    })
    TitleBar.ZIndex = 10
    AddCorner(TitleBar, 18)
    -- mask bottom corners
    local TitleMask = MakeFrame({
        Color = THEME.TitleBar,
        Size  = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 1, -18),
        Parent = TitleBar,
    })
    TitleMask.Name = "BottomMask"
    AddStroke(TitleBar, THEME.ModuleBorder, 1, 0.5)

    -- Logo dot
    local LogoDot = Instance.new("Frame")
    LogoDot.Name = "Dot"
    LogoDot.BackgroundColor3 = THEME.Blue
    LogoDot.Size = UDim2.new(0, 7 * self._dpi, 0, 7 * self._dpi)
    LogoDot.Position = UDim2.new(0, 14 * self._dpi, 0.5, -3 * self._dpi)
    LogoDot.Parent = TitleBar
    AddCorner(LogoDot, 50)

    -- Title text
    local TitleLabel = MakeLabel({
        Text = title or "NovaUI",
        Color = THEME.Text,
        Font = Enum.Font.GothamBold,
        TextSize = math.floor(13 * self._dpi),
        Size = UDim2.new(1, -90 * self._dpi, 1, 0),
        Position = UDim2.new(0, 28 * self._dpi, 0, 0),
        Parent = TitleBar,
    })

    -- Hide button
    local HideBtn = MakeButton({
        Name = "HideBtn",
        Text = "−",
        Color = THEME.SurfaceHover,
        Transparency = 0,
        TextColor = THEME.TextDim,
        TextSize = math.floor(16 * self._dpi),
        Size = UDim2.new(0, 26 * self._dpi, 0, 26 * self._dpi),
        Position = UDim2.new(1, -36 * self._dpi, 0.5, -13 * self._dpi),
        Parent = TitleBar,
    })
    AddCorner(HideBtn, 8)
    self._hideBtn = HideBtn

    -- Show tab (collapsed state)
    local ShowTab = MakeButton({
        Name = "ShowTab",
        Text = "▶  " .. (title or "NovaUI"),
        Color = THEME.Blue,
        TextColor = Color3.new(1,1,1),
        TextSize = math.floor(12 * self._dpi),
        Size = UDim2.new(0, 120 * self._dpi, 0, 32 * self._dpi),
        Position = options.position or UDim2.new(0, 8, 0.5, 0),
        Parent = Gui,
    })
    ShowTab.Visible = false
    AddCorner(ShowTab, 10)
    self._showTab = ShowTab

    -- ── Tab Bar ───────────────────────────────────────────
    local TabBar = MakeFrame({
        Name = "TabBar",
        Color = THEME.TitleBar,
        Transparency = 0,
        Size = UDim2.new(1, 0, 0, 36 * self._dpi),
        Position = UDim2.new(0, 0, 0, 44 * self._dpi),
        Parent = Win,
    })
    AddPadding(TabBar, 4, 8, 0, 8)
    AddListLayout(TabBar, Enum.FillDirection.Horizontal, 4)
    self._tabBar = TabBar

    -- Tab bar border
    local TabDivider = MakeFrame({
        Color = THEME.ModuleBorder,
        Transparency = 0.6,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        Parent = TabBar,
    })
    TabDivider.ZIndex = 5

    -- ── Content Area ──────────────────────────────────────
    local ContentArea = MakeFrame({
        Name = "ContentArea",
        Color = THEME.Background,
        Transparency = 0,
        Size = UDim2.new(1, 0, 1, -(44 + 36) * self._dpi),
        Position = UDim2.new(0, 0, 0, (44 + 36) * self._dpi),
        Clips = true,
        Parent = Win,
    })
    AddCorner(ContentArea, 0)
    self._contentArea = ContentArea

    -- Round bottom corners only
    local BottomCorner = MakeFrame({
        Color = THEME.Background,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 1, -18),
        Parent = ContentArea,
    })
    AddCorner(BottomCorner, 18)

    -- ── Dragging ──────────────────────────────────────────
    if options.draggable ~= false then
        local dragging, dragStart, startPos = false, nil, nil
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos  = Win.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                             input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Win.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- ── Hide / Show ───────────────────────────────────────
    HideBtn.MouseButton1Click:Connect(function() self:Hide() end)
    ShowTab.MouseButton1Click:Connect(function() self:Show() end)

    -- Keyboard hide key
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self._hideKey then
            if self._hidden then self:Show() else self:Hide() end
        end
    end)

    -- HideBtn hover
    HideBtn.MouseEnter:Connect(function()
        Tween(HideBtn, {BackgroundColor3 = THEME.Blue}, 0.15)
        Tween(HideBtn, {TextColor3 = Color3.new(1,1,1)}, 0.15)
    end)
    HideBtn.MouseLeave:Connect(function()
        Tween(HideBtn, {BackgroundColor3 = THEME.SurfaceHover}, 0.15)
        Tween(HideBtn, {TextColor3 = THEME.TextDim}, 0.15)
    end)

    -- ── Notification Container ────────────────────────────
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "Notifications"
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Size = UDim2.new(0, 280, 1, 0)
    NotifContainer.Position = UDim2.new(1, -290, 0, 0)
    NotifContainer.Parent = Gui
    AddListLayout(NotifContainer, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
    self._notifContainer = NotifContainer

    return self
end

-- ── Hide / Show ───────────────────────────────────────────
function Nova:Hide()
    self._hidden = true
    Tween(self._win, {Position = UDim2.new(self._win.Position.X.Scale, self._win.Position.X.Offset, -0.05, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.delay(0.25, function()
        self._win.Visible = false
        self._showTab.Visible = true
    end)
end

function Nova:Show()
    self._hidden = false
    self._win.Visible = true
    self._showTab.Visible = false
    local pos = self._win.Position
    self._win.Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale - 0.05, pos.Y.Offset)
    Tween(self._win, {Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale + 0.05, pos.Y.Offset)}, 0.35, Enum.EasingStyle.Back)
end

-- ── DPI ───────────────────────────────────────────────────
function Nova:SetDPI(scale)
    self._dpi = math.clamp(scale, 0.5, 3.0)
    -- Rescale the window
    self._win.Size = UDim2.new(0, 340 * self._dpi, 0, 420 * self._dpi)
end

-- ── Destroy ───────────────────────────────────────────────
function Nova:Destroy()
    self._gui:Destroy()
end

-- ── Notify ────────────────────────────────────────────────
local NOTIF_COLORS = {
    info    = Color3.fromRGB(79, 142, 247),
    success = Color3.fromRGB(52, 211, 153),
    warn    = Color3.fromRGB(251, 191, 36),
    error   = Color3.fromRGB(248, 113, 113),
}
local NOTIF_ICONS = {
    info = "💡", success = "✅", warn = "⚠️", error = "❌"
}

function Nova:Notify(title, message, ntype, duration)
    ntype    = ntype or "info"
    duration = duration or 4

    local color = NOTIF_COLORS[ntype] or NOTIF_COLORS.info
    local icon  = NOTIF_ICONS[ntype]  or "💡"

    local Card = MakeFrame({
        Name = "Notif",
        Color = THEME.Surface,
        Size = UDim2.new(1, 0, 0, 70),
        Parent = self._notifContainer,
    })
    AddCorner(Card, 12)
    AddStroke(Card, color, 1, 0.5)
    AddPadding(Card, 10, 12, 10, 10)

    local IconLabel = MakeLabel({
        Text = icon, TextSize = 18,
        Size = UDim2.new(0, 24, 1, 0),
        Parent = Card,
    })
    IconLabel.TextXAlignment = Enum.TextXAlignment.Center

    local TextFrame = MakeFrame({
        Color = Color3.new(0,0,0),
        Transparency = 1,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        Parent = Card,
    })
    MakeLabel({
        Text = title, Font = Enum.Font.GothamBold,
        TextSize = 13, Color = THEME.Text,
        Size = UDim2.new(1, 0, 0, 18),
        Parent = TextFrame,
    })
    MakeLabel({
        Text = message, TextSize = 11,
        Color = THEME.TextDim,
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 20),
        Parent = TextFrame,
    })

    -- Color bar
    local Bar = MakeFrame({
        Color = color,
        Size = UDim2.new(0, 3, 1, 0),
        Parent = Card,
    })
    AddCorner(Bar, 50)

    -- Slide in
    Card.Position = UDim2.new(1, 10, 1, 0)
    Tween(Card, {Position = UDim2.new(0, 0, 1, 0)}, 0.3, Enum.EasingStyle.Back)

    -- Auto dismiss
    task.delay(duration, function()
        Tween(Card, {Position = UDim2.new(1, 10, 1, 0), BackgroundTransparency = 0.8}, 0.25)
        task.wait(0.3)
        Card:Destroy()
    end)
end

-- ─────────────────────────────────────────────────────────
--   TAB
-- ─────────────────────────────────────────────────────────
function Nova:AddTab(name)
    local tabIndex = #self._tabs + 1

    -- Tab button
    local TabBtn = MakeButton({
        Name = "Tab_"..name,
        Text = name,
        Color = THEME.TabInactive,
        Transparency = 1,
        TextColor = THEME.TextMuted,
        TextSize = math.floor(12 * self._dpi),
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(0, 0, 1, -6),
        Parent = self._tabBar,
    })
    TabBtn.AutomaticSize = Enum.AutomaticSize.X
    AddCorner(TabBtn, 8)
    AddPadding(TabBtn, 0, 10, 0, 10)

    -- Scroll area for this tab
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "Scroll_"..name
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollFrame.ScrollBarThickness = 2
    ScrollFrame.ScrollBarImageColor3 = THEME.Blue
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Visible = false
    ScrollFrame.Parent = self._contentArea

    local ScrollContent = MakeFrame({
        Name = "Content",
        Color = Color3.new(0,0,0),
        Transparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = ScrollFrame,
    })
    ScrollContent.AutomaticSize = Enum.AutomaticSize.Y
    AddPadding(ScrollContent, 10, 10, 10, 10)
    AddListLayout(ScrollContent, Enum.FillDirection.Vertical, 8)

    local tabObj = {
        _btn     = TabBtn,
        _scroll  = ScrollFrame,
        _content = ScrollContent,
        _win     = self,
    }

    -- Switch to this tab
    local function activate()
        for _, t in ipairs(self._tabs) do
            t._scroll.Visible = false
            Tween(t._btn, {BackgroundTransparency = 1, TextColor3 = THEME.TextMuted}, 0.15)
        end
        ScrollFrame.Visible = true
        Tween(TabBtn, {BackgroundTransparency = 0, TextColor3 = THEME.Text}, 0.15)
        Tween(TabBtn, {BackgroundColor3 = THEME.TabActive}, 0.15)
        self._activeTab = tabObj
    end

    TabBtn.MouseButton1Click:Connect(activate)

    TabBtn.MouseEnter:Connect(function()
        if self._activeTab ~= tabObj then
            Tween(TabBtn, {TextColor3 = THEME.TextDim}, 0.1)
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if self._activeTab ~= tabObj then
            Tween(TabBtn, {TextColor3 = THEME.TextMuted}, 0.1)
        end
    end)

    table.insert(self._tabs, tabObj)

    -- Auto-activate first tab
    if #self._tabs == 1 then activate() end

    -- Module adder
    function tabObj:AddModule(title, description)
        local modObj = {}
        modObj._tab = tabObj
        modObj._callbacks = {}
        modObj._power = true

        -- Card
        local Card = MakeFrame({
            Name = "Module_"..title,
            Color = THEME.Module,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = self._content,
        })
        Card.AutomaticSize = Enum.AutomaticSize.Y
        AddCorner(Card, 14)
        AddStroke(Card, THEME.ModuleBorder, 1, 0.55)
        AddPadding(Card, 12, 12, 12, 12)

        local CardLayout = AddListLayout(Card, Enum.FillDirection.Vertical, 8)

        -- Header row
        local Header = MakeFrame({
            Name = "Header",
            Color = Color3.new(0,0,0),
            Transparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = Card,
        })

        local TitleLabel = MakeLabel({
            Text = title,
            Font = Enum.Font.GothamBold,
            TextSize = math.floor(13 * tabObj._win._dpi),
            Color = THEME.Text,
            Size = UDim2.new(1, -50, 0, 16),
            Parent = Header,
        })

        if description then
            local DescLabel = MakeLabel({
                Text = description,
                TextSize = math.floor(11 * tabObj._win._dpi),
                Color = THEME.TextDim,
                Size = UDim2.new(1, -50, 0, 14),
                Position = UDim2.new(0, 0, 0, 18),
                Parent = Header,
            })
        end

        -- Power toggle in header
        local PwrTrack = MakeFrame({
            Name = "PwrTrack",
            Color = THEME.ToggleOff,
            Size = UDim2.new(0, 36, 0, 20),
            Position = UDim2.new(1, -36, 0.5, -10),
            Parent = Header,
        })
        AddCorner(PwrTrack, 50)
        AddStroke(PwrTrack, THEME.ModuleBorder, 1, 0.4)

        local PwrThumb = MakeFrame({
            Name = "PwrThumb",
            Color = Color3.fromRGB(160, 170, 200),
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 3, 0.5, -7),
            Parent = PwrTrack,
        })
        AddCorner(PwrThumb, 50)

        local PwrBtn = MakeButton({
            Color = Color3.new(0,0,0),
            Transparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = PwrTrack,
        })

        -- Body (collapses when power off)
        local Body = MakeFrame({
            Name = "Body",
            Color = Color3.new(0,0,0),
            Transparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = Card,
        })
        Body.AutomaticSize = Enum.AutomaticSize.Y
        modObj._body = Body
        AddListLayout(Body, Enum.FillDirection.Vertical, 8)

        local bodyVisible = true
        PwrBtn.MouseButton1Click:Connect(function()
            bodyVisible = not bodyVisible
            modObj._power = bodyVisible
            if bodyVisible then
                Body.Visible = true
                SpringTween(PwrTrack, {BackgroundColor3 = THEME.ToggleOn}, 0.3)
                SpringTween(PwrThumb, {
                    Position = UDim2.new(1, -17, 0.5, -7),
                    BackgroundColor3 = Color3.new(1,1,1)
                }, 0.35)
            else
                Body.Visible = false
                SpringTween(PwrTrack, {BackgroundColor3 = THEME.ToggleOff}, 0.3)
                SpringTween(PwrThumb, {
                    Position = UDim2.new(0, 3, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(120,130,160)
                }, 0.35)
            end
        end)

        -- Card hover
        Card.MouseEnter:Connect(function()
            Tween(Card, {BackgroundColor3 = THEME.SurfaceHover}, 0.15)
        end)
        Card.MouseLeave:Connect(function()
            Tween(Card, {BackgroundColor3 = THEME.Module}, 0.15)
        end)

        -- ── AddToggle ─────────────────────────────────────
        function modObj:AddToggle(name, default)
            local val = default or false
            local comp = { _value = val, _callbacks = {} }

            local Row = MakeFrame({
                Color = Color3.new(0,0,0), Transparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                Parent = Body,
            })

            local Lbl = MakeLabel({
                Text = name, TextSize = math.floor(12 * tabObj._win._dpi),
                Color = THEME.TextDim, Size = UDim2.new(1, -52, 1, 0),
                Parent = Row,
            })

            local Track = MakeFrame({
                Color = val and THEME.ToggleOn or THEME.ToggleOff,
                Size = UDim2.new(0, 40, 0, 22),
                Position = UDim2.new(1, -40, 0.5, -11),
                Parent = Row,
            })
            AddCorner(Track, 50)
            AddStroke(Track, THEME.ModuleBorder, 1, 0.45)

            local Thumb = MakeFrame({
                Color = val and Color3.new(1,1,1) or Color3.fromRGB(130,140,170),
                Size = UDim2.new(0, 16, 0, 16),
                Position = val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                Parent = Track,
            })
            AddCorner(Thumb, 50)

            local ClickBtn = MakeButton({
                Color = Color3.new(0,0,0), Transparency = 1,
                Size = UDim2.new(1, 0, 1, 0), Parent = Track,
            })

            ClickBtn.MouseButton1Click:Connect(function()
                val = not val
                comp._value = val
                if val then
                    SpringTween(Track, {BackgroundColor3 = THEME.ToggleOn}, 0.3)
                    SpringTween(Thumb, {Position = UDim2.new(1,-19,0.5,-8), BackgroundColor3 = Color3.new(1,1,1)}, 0.35)
                    Tween(Lbl, {TextColor3 = THEME.Text}, 0.15)
                else
                    SpringTween(Track, {BackgroundColor3 = THEME.ToggleOff}, 0.3)
                    SpringTween(Thumb, {Position = UDim2.new(0,3,0.5,-8), BackgroundColor3 = Color3.fromRGB(130,140,170)}, 0.35)
                    Tween(Lbl, {TextColor3 = THEME.TextDim}, 0.15)
                end
                for _, cb in ipairs(comp._callbacks) do pcall(cb, val) end
            end)

            function comp:OnChanged(cb) table.insert(self._callbacks, cb) end
            function comp:SetValue(v)
                if v == val then return end
                ClickBtn.MouseButton1Click:Fire()
            end
            function comp:GetValue() return self._value end

            return comp
        end

        -- ── AddSlider ─────────────────────────────────────
        function modObj:AddSlider(name, min, max, default, suffix)
            min     = min or 0
            max     = max or 100
            local val = math.clamp(default or min, min, max)
            suffix  = suffix or ""
            local comp = { _value = val, _callbacks = {} }

            local Wrap = MakeFrame({
                Color = Color3.new(0,0,0), Transparency = 1,
                Size = UDim2.new(1, 0, 0, 44),
                Parent = Body,
            })

            -- Header row
            local HRow = MakeFrame({
                Color = Color3.new(0,0,0), Transparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Parent = Wrap,
            })
            MakeLabel({
                Text = name, TextSize = math.floor(11 * tabObj._win._dpi),
                Color = THEME.TextDim, Size = UDim2.new(0.6, 0, 1, 0),
                Parent = HRow,
            })
            local ValLabel = MakeLabel({
                Text = tostring(val)..suffix,
                TextSize = math.floor(11 * tabObj._win._dpi),
                Color = THEME.Blue, Font = Enum.Font.GothamBold,
                Size = UDim2.new(0.4, 0, 1, 0),
                XAlign = Enum.TextXAlignment.Right,
                Parent = HRow,
            })

            -- Track
            local TrackBg = MakeFrame({
                Color = THEME.SliderTrack,
                Size = UDim2.new(1, 0, 0, 5),
                Position = UDim2.new(0, 0, 0, 28),
                Parent = Wrap,
            })
            AddCorner(TrackBg, 50)

            local Fill = MakeFrame({
                Name = "Fill",
                Color = THEME.SliderFill,
                Size = UDim2.new((val-min)/(max-min), 0, 1, 0),
                Parent = TrackBg,
            })
            AddCorner(Fill, 50)

            -- Glow on fill
            local FillGlow = Instance.new("ImageLabel")
            FillGlow.BackgroundTransparency = 1
            FillGlow.Image = "rbxassetid://6014261993"
            FillGlow.ImageColor3 = THEME.Blue
            FillGlow.ImageTransparency = 0.7
            FillGlow.ScaleType = Enum.ScaleType.Slice
            FillGlow.SliceCenter = Rect.new(49,49,450,450)
            FillGlow.Size = UDim2.new(1, 8, 1, 8)
            FillGlow.Position = UDim2.new(0, -4, 0, -4)
            FillGlow.ZIndex = 0
            FillGlow.Parent = Fill

            -- Thumb
            local Thumb = MakeFrame({
                Color = Color3.new(1,1,1),
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new((val-min)/(max-min), -8, 0.5, -8),
                Parent = TrackBg,
            })
            AddCorner(Thumb, 50)
            Thumb.ZIndex = 5

            -- Invisible drag button over track
            local DragBtn = MakeButton({
                Color = Color3.new(0,0,0), Transparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Position = UDim2.new(0, 0, 0.5, -13),
                Parent = TrackBg,
            })
            DragBtn.ZIndex = 6

            local dragging = false
            local function updateFromPos(inputPos)
                local absPos  = TrackBg.AbsolutePosition
                local absSize = TrackBg.AbsoluteSize
                local rel = math.clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
                local newVal
                -- Snap to integer if min/max are integers
                if math.floor(min) == min and math.floor(max) == max then
                    newVal = math.round(min + rel * (max - min))
                else
                    newVal = min + rel * (max - min)
                    newVal = math.floor(newVal * 100 + 0.5) / 100
                end
                if newVal == val then return end
                val = newVal
                comp._value = val
                ValLabel.Text = tostring(val)..suffix
                Tween(Fill,  {Size = UDim2.new(rel, 0, 1, 0)}, 0.05)
                Tween(Thumb, {Position = UDim2.new(rel, -8, 0.5, -8)}, 0.05)
                for _, cb in ipairs(comp._callbacks) do pcall(cb, val) end
            end

            DragBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromPos(input.Position)
                    SpringTween(Thumb, {Size = UDim2.new(0,20,0,20), Position = UDim2.new((val-min)/(max-min),-10,0.5,-10)}, 0.2)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                                 input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromPos(input.Position)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    SpringTween(Thumb, {Size = UDim2.new(0,16,0,16), Position = UDim2.new((val-min)/(max-min),-8,0.5,-8)}, 0.2)
                end
            end)

            function comp:OnChanged(cb) table.insert(self._callbacks, cb) end
            function comp:SetValue(v)
                val = math.clamp(v, min, max)
                comp._value = val
                local rel = (val-min)/(max-min)
                ValLabel.Text = tostring(val)..suffix
                Tween(Fill,  {Size = UDim2.new(rel, 0, 1, 0)}, 0.15)
                Tween(Thumb, {Position = UDim2.new(rel, -8, 0.5, -8)}, 0.15)
            end
            function comp:GetValue() return self._value end

            return comp
        end

        -- ── AddButton ─────────────────────────────────────
        function modObj:AddButton(icon, label, color)
            local comp = { _active = false, _callbacks = {} }
            local activeColor = color or THEME.Blue

            local BtnFrame = MakeFrame({
                Color = Color3.new(0,0,0), Transparency = 1,
                Size = UDim2.new(1, 0, 0, 42),
                Parent = Body,
            })

            local Btn = MakeButton({
                Text = (icon or "")..( label and "  "..label or ""),
                Color = THEME.SurfaceHover,
                Transparency = 0,
                TextColor = THEME.TextDim,
                TextSize = math.floor(12 * tabObj._win._dpi),
                Font = Enum.Font.GothamMedium,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = BtnFrame,
            })
            AddCorner(Btn, 10)
            AddStroke(Btn, THEME.ModuleBorder, 1, 0.5)

            Btn.MouseEnter:Connect(function()
                if not comp._active then
                    Tween(Btn, {BackgroundColor3 = THEME.Module, TextColor3 = THEME.Text}, 0.12)
                end
            end)
            Btn.MouseLeave:Connect(function()
                if not comp._active then
                    Tween(Btn, {BackgroundColor3 = THEME.SurfaceHover, TextColor3 = THEME.TextDim}, 0.12)
                end
            end)
            Btn.MouseButton1Click:Connect(function()
                for _, cb in ipairs(comp._callbacks) do pcall(cb) end
            end)

            function comp:OnClick(cb) table.insert(self._callbacks, cb) end
            -- Alias
            function comp:OnChanged(cb) self:OnClick(cb) end

            return comp
        end

        -- ── AddColorPicker ────────────────────────────────
        function modObj:AddColorPicker(name, default)
            local palette = {
                Color3.fromRGB(79,142,247),   -- blue
                Color3.fromRGB(52,211,153),   -- green
                Color3.fromRGB(248,113,113),  -- red
                Color3.fromRGB(251,191,36),   -- amber
                Color3.fromRGB(196,181,253),  -- purple
                Color3.fromRGB(255,255,255),  -- white
                Color3.fromRGB(100,116,139),  -- slate
                Color3.fromRGB(249,115,22),   -- orange
            }
            local val = default or palette[1]
            local comp = { _value = val, _callbacks = {} }

            local Wrap = MakeFrame({
                Color = Color3.new(0,0,0), Transparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                Parent = Body,
            })
            MakeLabel({
                Text = name, TextSize = math.floor(11 * tabObj._win._dpi),
                Color = THEME.TextDim, Size = UDim2.new(0.35, 0, 1, 0),
                Parent = Wrap,
            })

            local SwatchRow = MakeFrame({
                Color = Color3.new(0,0,0), Transparency = 1,
                Size = UDim2.new(0.65, 0, 1, 0),
                Position = UDim2.new(0.35, 0, 0, 0),
                Parent = Wrap,
            })
            AddListLayout(SwatchRow, Enum.FillDirection.Horizontal, 5, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

            local swatches = {}
            for i, col in ipairs(palette) do
                local S = MakeFrame({
                    Name = "Swatch"..i,
                    Color = col,
                    Size = UDim2.new(0, 20, 0, 20),
                    Parent = SwatchRow,
                })
                AddCorner(S, 50)

                local active = (col == val)
                local Stroke = AddStroke(S, Color3.new(1,1,1), 2, active and 0.2 or 1)

                local ClickBtn = MakeButton({
                    Color = Color3.new(0,0,0), Transparency = 1,
                    Size = UDim2.new(1,0,1,0), Parent = S,
                })

                local function selectThis()
                    for _, sw in ipairs(swatches) do
                        AddStroke(sw.frame, Color3.new(1,1,1), 2, 1)
                    end
                    Tween(S, {Size = UDim2.new(0,22,0,22)}, 0.15)
                    Stroke.Transparency = 0.2
                    val = col; comp._value = val
                    for _, cb in ipairs(comp._callbacks) do pcall(cb, val) end
                end

                if active then selectThis() end

                ClickBtn.MouseButton1Click:Connect(selectThis)
                table.insert(swatches, {frame=S, stroke=Stroke})
            end

            function comp:OnChanged(cb) table.insert(self._callbacks, cb) end
            function comp:SetValue(v) val = v; comp._value = v end
            function comp:GetValue() return self._value end

            return comp
        end

        -- ── AddDropdown ───────────────────────────────────
        function modObj:AddDropdown(name, items, default)
            local val = default or items[1]
            local open = false
            local comp = { _value = val, _callbacks = {} }

            local Container = MakeFrame({
                Color = Color3.new(0,0,0), Transparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                Parent = Body,
            })
            Container.AutomaticSize = Enum.AutomaticSize.Y
            Container.ClipsDescendants = false

            MakeLabel({
                Text = name, TextSize = math.floor(11 * tabObj._win._dpi),
                Color = THEME.TextDim, Size = UDim2.new(0.45, 0, 0, 32),
                Parent = Container,
            })

            local DropBtn = MakeButton({
                Text = val.."  ▾",
                Color = THEME.SliderTrack,
                TextColor = THEME.Text,
                TextSize = math.floor(11 * tabObj._win._dpi),
                Size = UDim2.new(0.55, 0, 0, 28),
                Position = UDim2.new(0.45, 0, 0, 2),
                Parent = Container,
            })
            AddCorner(DropBtn, 8)
            AddStroke(DropBtn, THEME.ModuleBorder, 1, 0.5)

            local OptionList = MakeFrame({
                Color = THEME.Surface,
                Size = UDim2.new(0.55, 0, 0, 0),
                Position = UDim2.new(0.45, 0, 0, 34),
                Parent = Container,
            })
            OptionList.AutomaticSize = Enum.AutomaticSize.Y
            OptionList.Visible = false
            OptionList.ZIndex = 50
            AddCorner(OptionList, 8)
            AddStroke(OptionList, THEME.ModuleBorder, 1, 0.3)
            AddListLayout(OptionList, Enum.FillDirection.Vertical, 0)

            for _, item in ipairs(items) do
                local Opt = MakeButton({
                    Text = item,
                    Color = Color3.new(0,0,0), Transparency = 1,
                    TextColor = THEME.TextDim,
                    TextSize = math.floor(11 * tabObj._win._dpi),
                    Size = UDim2.new(1, 0, 0, 26),
                    Parent = OptionList,
                })
                Opt.ZIndex = 51
                AddPadding(Opt, 0, 8, 0, 8)

                Opt.MouseEnter:Connect(function()
                    Tween(Opt, {BackgroundTransparency = 0, BackgroundColor3 = THEME.SurfaceHover}, 0.1)
                    Tween(Opt, {TextColor3 = THEME.Text}, 0.1)
                end)
                Opt.MouseLeave:Connect(function()
                    Tween(Opt, {BackgroundTransparency = 1}, 0.1)
                    Tween(Opt, {TextColor3 = THEME.TextDim}, 0.1)
                end)
                Opt.MouseButton1Click:Connect(function()
                    val = item; comp._value = item
                    DropBtn.Text = item.."  ▾"
                    open = false
                    OptionList.Visible = false
                    for _, cb in ipairs(comp._callbacks) do pcall(cb, val) end
                end)
            end

            DropBtn.MouseButton1Click:Connect(function()
                open = not open
                OptionList.Visible = open
            end)

            function comp:OnChanged(cb) table.insert(self._callbacks, cb) end
            function comp:SetValue(v) val = v; comp._value = v; DropBtn.Text = v.."  ▾" end
            function comp:GetValue() return self._value end

            return comp
        end

        -- ── AddKeybind ────────────────────────────────────
        function modObj:AddKeybind(name, default)
            local val = default or Enum.KeyCode.Unknown
            local listening = false
            local comp = { _value = val, _callbacks = {} }

            local Row = MakeFrame({
                Color = Color3.new(0,0,0), Transparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                Parent = Body,
            })
            MakeLabel({
                Text = name, TextSize = math.floor(11 * tabObj._win._dpi),
                Color = THEME.TextDim, Size = UDim2.new(0.55, 0, 1, 0),
                Parent = Row,
            })

            local KeyBtn = MakeButton({
                Text = val.Name,
                Color = THEME.SliderTrack,
                TextColor = THEME.Text,
                TextSize = math.floor(10 * tabObj._win._dpi),
                Font = Enum.Font.GothamBold,
                Size = UDim2.new(0.43, 0, 0, 24),
                Position = UDim2.new(0.57, 0, 0.5, -12),
                Parent = Row,
            })
            AddCorner(KeyBtn, 6)
            AddStroke(KeyBtn, THEME.ModuleBorder, 1, 0.4)

            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
                Tween(KeyBtn, {BackgroundColor3 = THEME.Blue}, 0.1)
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    val = input.KeyCode; comp._value = val
                    KeyBtn.Text = val.Name
                    Tween(KeyBtn, {BackgroundColor3 = THEME.SliderTrack}, 0.2)
                    for _, cb in ipairs(comp._callbacks) do pcall(cb, val) end
                end
            end)

            function comp:OnChanged(cb) table.insert(self._callbacks, cb) end
            function comp:GetValue() return self._value end

            return comp
        end

        -- ── AddLabel ──────────────────────────────────────
        function modObj:AddLabel(text)
            MakeLabel({
                Text = text,
                TextSize = math.floor(11 * tabObj._win._dpi),
                Color = THEME.TextDim,
                Size = UDim2.new(1, 0, 0, 18),
                Parent = Body,
            })
        end

        -- ── AddSeparator ──────────────────────────────────
        function modObj:AddSeparator()
            local Sep = MakeFrame({
                Color = THEME.ModuleBorder,
                Transparency = 0.6,
                Size = UDim2.new(1, 0, 0, 1),
                Parent = Body,
            })
        end

        return modObj
    end

    return tabObj
end

return Nova
