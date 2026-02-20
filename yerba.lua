--[[
    		yerba interface

    creator: n-0clip
    original: yerba external

        ver: 1.4
	-- nothing new :(

--]]

local Yerba = {
	Version = '1.4',
	Logo = "rbxassetid://74807357385705",
	Windows = {},
	Scale = {
		Window = UDim2.new(0, 620, 0, 480),
		TabOpen = 185,
		TabClose = 85,
		TopBar = 50,
		SectionWidth = 290,
		SectionGap = 10,
		ContentPadding = 12,
	},
	DPI = 1,         
	PerformanceMode = false,
	WindowsNil = {},
	NilFolder = Instance.new('Folder'),
	ProtectGui = protect_gui or protectgui or (syn and syn.protect_gui) or function(s) return s end,
}

Yerba.__index = Yerba

--[[
    DPI / UI Scale API
    ─────────────────
    Yerba:SetDPI(scale)
        Sets the UI scale for every open window.
        scale  – a number. 1 = 100% (default), 0.8 = 80%, 1.5 = 150%, etc.
        Accepts a "dpi" shorthand too: pass 96 (= 1×), 144 (= 1.5×), 72 (= 0.75×).
        Any value ≥ 4 is treated as a raw DPI number and converted (value / 96).
        Clamps between 0.5 and 3.0.

    Yerba:GetDPI()
        Returns the current scale factor (e.g. 1, 0.8, 1.25).

    Window:SetDPI(scale)
        Same as above but only affects a single window.

    Window:GetDPI()
        Returns the current scale of this specific window.
--]]

local function NormalizeDPI(value)
	if value >= 4 then
		value = value / 96  -- treat as raw DPI (96 = 1×)
	end
	return math.clamp(value, 0.5, 3.0)
end

local function ApplyScale(uiScale, scale)
	Tween(uiScale, {Scale = scale}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

function Yerba:SetDPI(value)
	local scale = NormalizeDPI(value)
	Yerba.DPI = scale
	for _, win in pairs(Yerba.Windows) do
		if win._UIScale then
			ApplyScale(win._UIScale, scale)
		end
	end
end

function Yerba:GetDPI()
	return Yerba.DPI
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

-- Mobile detection
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function IsTouchOrMouse1(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function IsTouchOrMouseMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local Fonts = {
	ComicNeue = Font.new("rbxasset://fonts/families/ComicNeueAngular.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	Inconsolata = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	SourceSans = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
}

local Theme = {
	Background = Color3.fromRGB(12, 15, 13),
	Secondary = Color3.fromRGB(18, 18, 18),
	Tertiary = Color3.fromRGB(24, 24, 24),
	TopBar = Color3.fromRGB(32, 32, 32),
	Accent = Color3.fromRGB(82, 106, 117),
	AccentDark = Color3.fromRGB(42, 55, 61),
	AccentMid = Color3.fromRGB(81, 105, 116),
	AccentBlue = Color3.fromRGB(7, 101, 160),
	Border = Color3.fromRGB(43, 43, 43),
	BorderAccent = Color3.fromRGB(17, 41, 71),
	Text = Color3.fromRGB(191, 187, 191),
	TextDark = Color3.fromRGB(154, 151, 154),
	TextDarker = Color3.fromRGB(129, 129, 129),
	Divider = Color3.fromRGB(61, 67, 76),
	TabFrame = Color3.fromRGB(28, 28, 26),
	Stroke = Color3.fromRGB(33, 31, 33),
	Blue = Color3.fromRGB(67, 144, 186),
	Enabled = Color3.fromRGB(67, 144, 186),
	Disabled = Color3.fromRGB(24, 24, 24),
	Hover = Color3.fromRGB(35, 35, 35),
	DotPattern = Color3.fromRGB(20, 23, 21),
	DotHover = Color3.fromRGB(67, 144, 186)
}

local function Create(instanceType, properties, children)
	local instance = Instance.new(instanceType)
	for prop, value in pairs(properties or {}) do
		instance[prop] = value
	end
	for _, child in pairs(children or {}) do
		child.Parent = instance
	end
	return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection)
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
		properties
	)
	tween:Play()
	return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness)
    if not parent then return end
    
    local filler = Instance.new("UIStroke")
    filler.Color = Theme.Stroke
    filler.Thickness = (thickness or 0.75) + 1
    filler.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    filler.LineJoinMode = Enum.LineJoinMode.Round
    filler.Parent = parent
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = parent
    
    return stroke
end

local function AddContextualStroke(parent)
	return Create("UIStroke", {
		Name = "Contextual",
		Color = Theme.Stroke,
		Thickness = 1.5,
		Parent = parent
	})
end

local function AddGradientLine(parent, position, size)
	local line = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = size or UDim2.new(1, 0, 0, 2),
		Position = position or UDim2.new(0, 0, 1, -2),
		Parent = parent
	})
	Create("UIGradient", {
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Theme.AccentDark),
			ColorSequenceKeypoint.new(0.5, Theme.AccentMid),
			ColorSequenceKeypoint.new(1, Theme.AccentDark)
		},
		Parent = line
	})
	return line
end

local function AddSlash(parent, x, zindex)
	return Create("TextLabel", {
		Name = "Slash",
		BackgroundTransparency = 1,
		FontFace = Fonts.ComicNeue,
		Text = "|",
		TextColor3 = Theme.AccentDark,
		TextSize = 21,
		Size = UDim2.new(0, 10, 1, 0),
		Position = UDim2.new(0, x - 5, 0, 0),
		ZIndex = zindex or 2,
		Parent = parent
	})
end

local function AddDotPattern(parent, enableHover)
	if Yerba.PerformanceMode then return end

	local DotContainer = Create("Frame", {
		Name = "DotPattern",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 0,
		Parent = parent
	})

	local dotSize = 2
	local spacing = 15
	local dots = {}

	for x = 0, parent.AbsoluteSize.X, spacing do
		for y = 0, parent.AbsoluteSize.Y, spacing do
			local dot = Create("Frame", {
				BackgroundColor3 = Theme.DotPattern,
				BorderSizePixel = 0,
				Size = UDim2.new(0, dotSize, 0, dotSize),
				Position = UDim2.new(0, x, 0, y),
				ZIndex = 0,
				Parent = DotContainer
			})
			AddCorner(dot, 1)
			table.insert(dots, {frame = dot, x = x + dotSize/2, y = y + dotSize/2})
		end
	end

	if enableHover then
		local lastHighlighted = {}

		local function HighlightNearbyDots(mouseX, mouseY)
			for _, dot in pairs(lastHighlighted) do
				Tween(dot, {BackgroundColor3 = Theme.DotPattern}, 0.15)
			end
			lastHighlighted = {}

			local containerPos = DotContainer.AbsolutePosition
			local relativeX = mouseX - containerPos.X
			local relativeY = mouseY - containerPos.Y

			for _, dotData in pairs(dots) do
				local distance = math.sqrt((relativeX - dotData.x)^2 + (relativeY - dotData.y)^2)

				if distance < 50 then
					local alpha = 1 - (distance / 50)
					local highlightColor = Color3.new(
						Theme.DotPattern.R + (Theme.DotHover.R - Theme.DotPattern.R) * alpha,
						Theme.DotPattern.G + (Theme.DotHover.G - Theme.DotPattern.G) * alpha,
						Theme.DotPattern.B + (Theme.DotHover.B - Theme.DotPattern.B) * alpha
					)
					Tween(dotData.frame, {BackgroundColor3 = highlightColor}, 0.1)
					table.insert(lastHighlighted, dotData.frame)
				end
			end
		end

		local function ResetDots()
			for _, dot in pairs(lastHighlighted) do
				Tween(dot, {BackgroundColor3 = Theme.DotPattern}, 0.2)
			end
			lastHighlighted = {}
		end

		local connection
		connection = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local mousePos
				if input.UserInputType == Enum.UserInputType.Touch then
					mousePos = Vector2.new(input.Position.X, input.Position.Y)
				else
					local mouse = LocalPlayer:GetMouse()
					mousePos = Vector2.new(mouse.X, mouse.Y)
				end

				local containerPos = DotContainer.AbsolutePosition
				local containerSize = DotContainer.AbsoluteSize

				if mousePos.X >= containerPos.X and mousePos.X <= containerPos.X + containerSize.X and
					mousePos.Y >= containerPos.Y and mousePos.Y <= containerPos.Y + containerSize.Y then
					HighlightNearbyDots(mousePos.X, mousePos.Y)
				else
					ResetDots()
				end
			end
		end)

		DotContainer.Destroying:Connect(function()
			if connection then 
				connection:Disconnect() 
			end
			ResetDots()
		end)
	end

	return DotContainer
end

function Yerba:CreateWindow(title, subtitle, options)
	options = options or {}

	local Window = {}
	Window.Tabs = {}
	Window.ActiveTab = nil
	Window.OpenDropdowns = {}
	Window.OpenColorPickers = {}
	Window.OpenSideMenus = {}
	Window.OpenKeybindMenus = {}
	Window.Visible = true
	Window.PlayerLists = {}

	local screenSize = workspace.CurrentCamera.ViewportSize
	local mobileScale = IsMobile and math.min(1, math.min(screenSize.X, screenSize.Y) / 500) or 1
	local WINDOW_WIDTH = options.Width or math.floor(Yerba.Scale.Window.X.Offset * mobileScale)
	local WINDOW_HEIGHT = options.Height or math.floor(Yerba.Scale.Window.Y.Offset * mobileScale)
	local LOGO = options.Logo or Yerba.Logo
	local TOPBAR_HEIGHT = Yerba.Scale.TopBar
	local SECTION_WIDTH = Yerba.Scale.SectionWidth
	local SECTION_GAP = Yerba.Scale.SectionGap
	local CONTENT_PADDING = Yerba.Scale.ContentPadding

    Window.Logo = options.Logo

	local function CloseAllDropdowns()
		for _, dropdown in pairs(Window.OpenDropdowns) do
			if dropdown.Close then dropdown.Close() end
		end
		Window.OpenDropdowns = {}
	end

	local function CloseAllColorPickers()
		for _, picker in pairs(Window.OpenColorPickers) do
			if picker.Close then picker.Close() end
		end
		Window.OpenColorPickers = {}
	end

	local function CloseAllSideMenus()
		for _, menu in pairs(Window.OpenSideMenus) do
			if menu.Close then menu.Close() end
		end
		Window.OpenSideMenus = {}
	end

	local function CloseAllKeybindMenus()
		for _, menu in pairs(Window.OpenKeybindMenus) do
			if menu.Close then menu.Close() end
		end
		Window.OpenKeybindMenus = {}
	end

	local function CloseAllPopups()
		CloseAllDropdowns()
		CloseAllColorPickers()
		CloseAllSideMenus()
		CloseAllKeybindMenus()
	end

	local ScreenGui = Create("ScreenGui", {
		Name = "Core",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		Parent = LocalPlayer:WaitForChild("PlayerGui")
	})

	Yerba.ProtectGui(ScreenGui)

	local MainWindow = Create("Frame", {
		Name = "MainWindow",
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Parent = ScreenGui
	})
	AddCorner(MainWindow, 6)
	AddStroke(MainWindow, Theme.BorderAccent)

	AddDotPattern(MainWindow, true)

	local WindowScale = Create("UIScale", {
		Name = "Scale",
		Scale = Yerba.DPI,  -- inherit global DPI on creation
		Parent = MainWindow
	})

	-- Expose UIScale so Yerba:SetDPI() and Window:SetDPI() can reach it
	Window._UIScale = WindowScale

	--- Per-window DPI setter.
	function Window:SetDPI(value)
		local scale = NormalizeDPI(value)
		ApplyScale(WindowScale, scale)
	end

	--- Per-window DPI getter.
	function Window:GetDPI()
		return WindowScale.Scale
	end

	local TopBar = Create("Frame", {
		Name = "Upframe",
		BackgroundColor3 = Theme.TopBar,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT),
		ZIndex = 1,
		Parent = MainWindow
	})
	AddCorner(TopBar, 6)
	AddGradientLine(TopBar, UDim2.new(0, 0, 1, -2), UDim2.new(1, 0, 0, 2))

	Create("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Image = LOGO,
		Size = UDim2.new(0, 45, 0, 45),
		Position = UDim2.new(0, 3, 0.5, -22),
		ZIndex = 2,
		Parent = TopBar
	})

	AddSlash(TopBar, 52, 2)

	local TabContainer = Create("Frame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 360, 0, 30),
		Position = UDim2.new(0, 60, 0.5, -15),
		ZIndex = 2,
		Parent = TopBar
	})

	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = TabContainer
	})

	local TabHover = Create("Frame", {
		Name = "TabHover",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 50, 0, 2),
		Position = UDim2.new(0, 60, 0, 40),
		ZIndex = 3,
		Parent = TopBar
	})
	AddCorner(TabHover, 2)
	Create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Theme.AccentDark),
			ColorSequenceKeypoint.new(0.5, Theme.AccentMid),
			ColorSequenceKeypoint.new(1, Theme.AccentDark)
		},
		Parent = TabHover
	})

	AddSlash(TopBar, 440, 2)

	local SearchFrame = Create("Frame", {
		Name = "Searchbox",
		BackgroundColor3 = Theme.Tertiary,
		Size = UDim2.new(0, 150, 0, 26),
		Position = UDim2.new(0, 455, 0.5, -13),
		ZIndex = 2,
		Parent = TopBar
	})
	AddCorner(SearchFrame, 5)
	AddStroke(SearchFrame, Theme.Border)

	Create("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		ImageColor3 = Color3.fromRGB(174, 174, 175),
		Image = "rbxassetid://128625562276776",
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, 6, 0.5, -8),
		ZIndex = 3,
		Parent = SearchFrame
	})

	Create("TextBox", {
		Name = "Input",
		BackgroundTransparency = 1,
		FontFace = Fonts.Inconsolata,
		PlaceholderText = "search",
		PlaceholderColor3 = Theme.TextDark,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 26, 0, 0),
		ZIndex = 3,
		Parent = SearchFrame
	})

	local ContentArea = Create("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -CONTENT_PADDING*2, 1, -TOPBAR_HEIGHT - CONTENT_PADDING),
		Position = UDim2.new(0, CONTENT_PADDING, 0, TOPBAR_HEIGHT + CONTENT_PADDING/2),
		ClipsDescendants = true,
		ZIndex = 1,
		Parent = MainWindow
	})

	local TabPages = Create("Folder", {
		Name = "TabContent",
		Parent = ContentArea
	})

	local dragging, dragInput, dragStart, startPos
	local isDragging = false

	TopBar.InputBegan:Connect(function(input)
		if IsTouchOrMouse1(input) then
			dragging = true
			dragStart = input.Position
			startPos = MainWindow.Position
			CloseAllPopups()

			if not isDragging then
				isDragging = true
				Tween(WindowScale, {Scale = Yerba.DPI * 1.01}, 0.15, Enum.EasingStyle.Back)
			end

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false

					if isDragging then
						isDragging = false
						Tween(WindowScale, {Scale = Yerba.DPI}, 0.2, Enum.EasingStyle.Back)
					end
				end
			end)
		end
	end)

	TopBar.InputChanged:Connect(function(input)
		if IsTouchOrMouseMove(input) then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart

			local targetPos = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)

			MainWindow.Position = targetPos
		end
	end)

	local function UpdatePlayerListsVisibility()
		for _, plData in pairs(Window.PlayerLists) do
			if Window.Visible and Window.ActiveTab and plData.Tab == Window.ActiveTab then
				plData.Frame.Visible = true
			else
				plData.Frame.Visible = false
			end
		end
	end

	local function ToggleWindow(show)
		Window.Visible = show
		CloseAllPopups()

		local targetScale = WindowScale.Scale > 0.1 and WindowScale.Scale or Yerba.DPI

		if show then
			MainWindow.Visible = true
			WindowScale.Scale = targetScale * 0.9
			MainWindow.BackgroundTransparency = 0.5
			Tween(WindowScale, {Scale = targetScale}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			Tween(MainWindow, {BackgroundTransparency = 0}, 0.2)
		else
			Tween(WindowScale, {Scale = targetScale * 0.9}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			Tween(MainWindow, {BackgroundTransparency = 0.5}, 0.2)
			task.delay(0.2, function()
				if not Window.Visible then
					MainWindow.Visible = false
				end
			end)
		end

		UpdatePlayerListsVisibility()
	end
	
	local function CreateSideMenu(options)
		local SideMenu = {}
		SideMenu.Open = false
		SideMenu.Elements = {}

		local MenuFrame = Create("Frame", {
			Name = "SideMenu",
			BackgroundColor3 = Theme.Secondary,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 200, 0, 0),
			ClipsDescendants = true,
			Visible = false,
			ZIndex = 100,
			Parent = ScreenGui
		})
		AddCorner(MenuFrame, 6)
		AddStroke(MenuFrame, Theme.AccentBlue)

		local MenuHeader = Create("Frame", {
			Name = "Upframe",
			BackgroundColor3 = Theme.TabFrame,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 101,
			Parent = MenuFrame
		})
		AddCorner(MenuHeader, 6)

		local MenuTitle = Create("TextLabel", {
			Name = "TabName",
			BackgroundTransparency = 1,
			FontFace = Fonts.Inconsolata,
			Text = options.Name or "side menu",
			TextColor3 = Theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			ZIndex = 102,
			Parent = MenuHeader
		})
		AddContextualStroke(MenuTitle)

		AddGradientLine(MenuHeader, UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1))

		local MenuContent = Create("ScrollingFrame", {
			Name = "Content",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -10, 1, -38),
			Position = UDim2.new(0, 5, 0, 35),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Accent,
			ZIndex = 101,
			Parent = MenuFrame
		})

		local ContentLayout = Create("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = MenuContent
		})

		Create("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
			Parent = MenuContent
		})

		local function UpdateMenuSize()
			local contentHeight = ContentLayout.AbsoluteContentSize.Y + 48
			local targetHeight = math.clamp(contentHeight, 50, 220)
			if SideMenu.Open then
				Tween(MenuFrame, {Size = UDim2.new(0, 200, 0, targetHeight)}, 0.15)
			end
		end

		function SideMenu.Open_()
			if SideMenu.Open then return end

			CloseAllSideMenus()
			SideMenu.Open = true
			table.insert(Window.OpenSideMenus, SideMenu)

			local btnPos = options.Button.AbsolutePosition
			local btnSize = options.Button.AbsoluteSize
			local screenSize = workspace.CurrentCamera.ViewportSize

			local menuX = btnPos.X + btnSize.X + 10
			local menuY = btnPos.Y - 10

			if menuX + 200 > screenSize.X then
				menuX = btnPos.X - 210
			end

			local contentHeight = ContentLayout.AbsoluteContentSize.Y + 48
			local targetHeight = math.clamp(contentHeight, 50, 220)
			if menuY + targetHeight > screenSize.Y then
				menuY = screenSize.Y - targetHeight - 10
			end

			MenuFrame.Position = UDim2.new(0, menuX, 0, menuY)
			MenuFrame.Size = UDim2.new(0, 200, 0, 0)
			MenuFrame.Visible = true

			Tween(MenuFrame, {Size = UDim2.new(0, 200, 0, targetHeight)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end

		function SideMenu.Close()
			if not SideMenu.Open then return end
			SideMenu.Open = false
			Tween(MenuFrame, {Size = UDim2.new(0, 200, 0, 0)}, 0.15)
			task.delay(0.15, function()
				if not SideMenu.Open then
					MenuFrame.Visible = false
				end
			end)
		end

		function SideMenu:CreateToggle(opts)
			opts = opts or {}
			local toggleName = opts.Name or "Toggle"
			local default = opts.Default or false
			local callback = opts.Callback or function() end

			local Toggle = {}
			Toggle.Value = default

			local ToggleFrame = Create("Frame", {
				Name = toggleName,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 20),
				ZIndex = 102,
				Parent = MenuContent
			})

			local Label = Create("TextLabel", {
				Name = "Name",
				BackgroundTransparency = 1,
				FontFace = Fonts.Inconsolata,
				Text = toggleName,
				TextColor3 = Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -24, 1, 0),
				ZIndex = 103,
				Parent = ToggleFrame
			})
			AddContextualStroke(Label)

			local Checkbox = Create("TextButton", {
				Name = "Button",
				BackgroundColor3 = default and Theme.Enabled or Theme.Disabled,
				BorderSizePixel = 0,
				Text = "",
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(1, -16, 0.5, -8),
				ZIndex = 103,
				Parent = ToggleFrame
			})
			AddCorner(Checkbox, 4)
			local CheckboxStroke = AddStroke(Checkbox, Theme.Border)

			local function UpdateToggle()
				Tween(Checkbox, {BackgroundColor3 = Toggle.Value and Theme.Enabled or Theme.Disabled}, 0.15)
				callback(Toggle.Value)
			end

			Checkbox.MouseEnter:Connect(function()
				Tween(CheckboxStroke, {Color = Theme.Accent}, 0.1)
			end)
			Checkbox.MouseLeave:Connect(function()
				Tween(CheckboxStroke, {Color = Theme.Border}, 0.1)
			end)

			Checkbox.MouseButton1Click:Connect(function()
				Toggle.Value = not Toggle.Value
				UpdateToggle()
			end)

			function Toggle:Set(value)
				Toggle.Value = value
				UpdateToggle()
			end

			function Toggle:Get()
				return Toggle.Value
			end

			Toggle.Frame = ToggleFrame
			table.insert(SideMenu.Elements, Toggle)
			task.defer(UpdateMenuSize)

			if default then callback(default) end
			return Toggle
		end

		function SideMenu:CreateDropdown(opts)
			opts = opts or {}
			local dropdownName = opts.Name or "Dropdown"
			local items = opts.Items or {}
			local default = opts.Default or (items[1] or "None")
			local callback = opts.Callback or function() end

			local Dropdown = {}
			Dropdown.Value = default

			local DropdownFrame = Create("Frame", {
				Name = dropdownName,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 20),
				ZIndex = 102,
				Parent = MenuContent
			})

			local Label = Create("TextLabel", {
				Name = "Name",
				BackgroundTransparency = 1,
				FontFace = Fonts.Inconsolata,
				Text = dropdownName,
				TextColor3 = Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0.4, 0, 1, 0),
				ZIndex = 103,
				Parent = DropdownFrame
			})
			AddContextualStroke(Label)

			local DropdownBtn = Create("TextButton", {
				Name = "Dropdown",
				BackgroundColor3 = Theme.Tertiary,
				Text = "",
				Size = UDim2.new(0.58, 0, 0, 18),
				Position = UDim2.new(0.42, 0, 0.5, -9),
				ZIndex = 103,
				Parent = DropdownFrame
			})
			AddCorner(DropdownBtn, 4)
			AddStroke(DropdownBtn, Theme.Border)

			local ValueLabel = Create("TextLabel", {
				Name = "Value",
				BackgroundTransparency = 1,
				FontFace = Fonts.Inconsolata,
				Text = default,
				TextColor3 = Theme.TextDarker,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -18, 1, 0),
				Position = UDim2.new(0, 5, 0, 0),
				ZIndex = 104,
				Parent = DropdownBtn
			})

			local Arrow = Create("TextLabel", {
				Name = "Arrow",
				BackgroundTransparency = 1,
				FontFace = Fonts.Inconsolata,
				Text = "▼",
				TextColor3 = Theme.TextDark,
				TextSize = 8,
				Size = UDim2.new(0, 12, 1, 0),
				Position = UDim2.new(1, -12, 0, 0),
				ZIndex = 104,
				Parent = DropdownBtn
			})

			local currentIndex = table.find(items, default) or 1

			DropdownBtn.MouseButton1Click:Connect(function()
				currentIndex = currentIndex + 1
				if currentIndex > #items then currentIndex = 1 end
				Dropdown.Value = items[currentIndex]
				ValueLabel.Text = items[currentIndex]
				callback(items[currentIndex])
			end)

			function Dropdown:Set(value)
				Dropdown.Value = value
				ValueLabel.Text = value
				currentIndex = table.find(items, value) or 1
				callback(value)
			end

			Dropdown.Frame = DropdownFrame
			table.insert(SideMenu.Elements, Dropdown)
			task.defer(UpdateMenuSize)

			callback(default)
			return Dropdown
		end

		function SideMenu:CreateSlider(opts)
			opts = opts or {}
			local sliderName = opts.Name or "Slider"
			local min = opts.Min or 0
			local max = opts.Max or 100
			local default = opts.Default or min
			local increment = opts.Increment or 1
			local suffix = opts.Suffix or ""
			local callback = opts.Callback or function() end

			local Slider = {}
			Slider.Value = default

			local SliderFrame = Create("Frame", {
				Name = sliderName,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 32),
				ZIndex = 102,
				Parent = MenuContent
			})

			local Label = Create("TextLabel", {
				Name = "Name",
				BackgroundTransparency = 1,
				FontFace = Fonts.Inconsolata,
				Text = sliderName,
				TextColor3 = Theme.Text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0.6, 0, 0, 12),
				ZIndex = 103,
				Parent = SliderFrame
			})
			AddContextualStroke(Label)

			local ValueBox = Create("TextBox", {
				Name = "ValueBox",
				BackgroundColor3 = Theme.Tertiary,
				FontFace = Fonts.Inconsolata,
				Text = tostring(default) .. suffix,
				TextColor3 = Theme.TextDarker,
				TextSize = 10,
				Size = UDim2.new(0, 35, 0, 12),
				Position = UDim2.new(1, -35, 0, 0),
				ZIndex = 103,
				Parent = SliderFrame
			})
			AddCorner(ValueBox, 3)
			local ValueBoxStroke = AddStroke(ValueBox, Theme.Border)

			local SliderBG = Create("Frame", {
				Name = "Background",
				BackgroundColor3 = Theme.Tertiary,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 5),
				Position = UDim2.new(0, 0, 0, 18),
				ZIndex = 103,
				Parent = SliderFrame
			})
			AddCorner(SliderBG, 3)
			AddStroke(SliderBG, Theme.Border)

			local SliderFill = Create("Frame", {
				Name = "Fill",
				BackgroundColor3 = Theme.Blue,
				BorderSizePixel = 0,
				Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
				ZIndex = 104,
				Parent = SliderBG
			})
			AddCorner(SliderFill, 3)

			local SliderKnob = Create("Frame", {
				Name = "Knob",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 10, 0, 10),
				Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5),
				ZIndex = 105,
				Parent = SliderBG
			})
			AddCorner(SliderKnob, 10)
			local KnobStroke = AddStroke(SliderKnob, Theme.Border)

			local function UpdateSlider(value, skipCallback)
				value = math.clamp(value, min, max)
				value = math.floor(value / increment + 0.5) * increment
				value = math.clamp(value, min, max)

				Slider.Value = value
				local percent = (value - min) / (max - min)
				SliderFill.Size = UDim2.new(percent, 0, 1, 0)
				SliderKnob.Position = UDim2.new(percent, -5, 0.5, -5)
				ValueBox.Text = tostring(value) .. suffix

				if not skipCallback then
					callback(value)
				end
			end

			local function UpdateFromInput(input)
				local percent = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
				local value = min + (percent * (max - min))
				UpdateSlider(value)
			end

			local sliding = false

			SliderBG.InputBegan:Connect(function(input)
				if IsTouchOrMouse1(input) then
					sliding = true
					UpdateFromInput(input)
					Tween(SliderKnob, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(SliderKnob.Position.X.Scale, -6, 0.5, -6)}, 0.1)
					Tween(KnobStroke, {Color = Theme.Accent}, 0.1)
				end
			end)

			SliderBG.InputEnded:Connect(function(input)
				if IsTouchOrMouse1(input) then
					sliding = false
					local percent = (Slider.Value - min) / (max - min)
					Tween(SliderKnob, {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(percent, -5, 0.5, -5)}, 0.1)
					Tween(KnobStroke, {Color = Theme.Border}, 0.1)
				end
			end)

			SliderKnob.InputBegan:Connect(function(input)
				if IsTouchOrMouse1(input) then
					sliding = true
					Tween(SliderKnob, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(SliderKnob.Position.X.Scale, -6, 0.5, -6)}, 0.1)
					Tween(KnobStroke, {Color = Theme.Accent}, 0.1)
				end
			end)

			SliderKnob.InputEnded:Connect(function(input)
				if IsTouchOrMouse1(input) then
					sliding = false
					local percent = (Slider.Value - min) / (max - min)
					Tween(SliderKnob, {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(percent, -5, 0.5, -5)}, 0.1)
					Tween(KnobStroke, {Color = Theme.Border}, 0.1)
				end
			end)

			SliderBG.MouseEnter:Connect(function()
				Tween(SliderFill, {BackgroundColor3 = Theme.Accent}, 0.1)
			end)

			SliderBG.MouseLeave:Connect(function()
				if not sliding then
					Tween(SliderFill, {BackgroundColor3 = Theme.Blue}, 0.1)
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if sliding and IsTouchOrMouseMove(input) then
					UpdateFromInput(input)
				end
			end)

			ValueBox.MouseEnter:Connect(function()
				Tween(ValueBoxStroke, {Color = Theme.Accent}, 0.1)
			end)

			ValueBox.MouseLeave:Connect(function()
				Tween(ValueBoxStroke, {Color = Theme.Border}, 0.1)
			end)

			ValueBox.FocusLost:Connect(function(enterPressed)
				local text = ValueBox.Text:gsub(suffix, "")
				local num = tonumber(text)
				if num then
					UpdateSlider(num)
				else
					ValueBox.Text = tostring(Slider.Value) .. suffix
				end
			end)

			ValueBox.Focused:Connect(function()
				ValueBox.Text = tostring(Slider.Value)
			end)

			function Slider:Set(value)
				UpdateSlider(value)
			end

			function Slider:Get()
				return Slider.Value
			end

			Slider.Frame = SliderFrame
			table.insert(SideMenu.Elements, Slider)
			task.defer(UpdateMenuSize)

			callback(default)
			return Slider
		end

		SideMenu.Frame = MenuFrame
		return SideMenu
	end
	
	function Window:CreateTab(name)
		local Tab = {}
		Tab.Name = name
		Tab.Sections = {}

		local TabButton = Create("TextButton", {
			Name = name,
			BackgroundTransparency = 1,
			FontFace = Fonts.Inconsolata,
			Text = name,
			TextColor3 = #Window.Tabs == 0 and Theme.Text or Theme.TextDark,
			TextSize = 16,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 22),
			ZIndex = 3,
			Parent = TabContainer
		})
		Create("UIPadding", {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			Parent = TabButton
		})
		AddContextualStroke(TabButton)

		local TabPage = Create("Frame", {
			Name = name,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = #Window.Tabs == 0,
			ZIndex = 1,
			Parent = TabPages
		})

		local LeftColumn = Create("Frame", {
			Name = "Left",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, SECTION_WIDTH, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 1,
			Parent = TabPage
		})
		Create("UIListLayout", {
			Padding = UDim.new(0, SECTION_GAP),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = LeftColumn
		})

		local RightColumn = Create("Frame", {
			Name = "Right",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, SECTION_WIDTH, 1, 0),
			Position = UDim2.new(1, -SECTION_WIDTH, 0, 0),
			ZIndex = 1,
			Parent = TabPage
		})
		Create("UIListLayout", {
			Padding = UDim.new(0, SECTION_GAP),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = RightColumn
		})

		Tab.Button = TabButton
		Tab.Page = TabPage
		Tab.LeftColumn = LeftColumn
		Tab.RightColumn = RightColumn

		TabButton.MouseButton1Click:Connect(function()
			CloseAllPopups()

			for _, t in pairs(Window.Tabs) do
				t.Button.TextColor3 = Theme.TextDark
				t.Page.Visible = false
			end
			TabButton.TextColor3 = Theme.Text
			TabPage.Visible = true

			task.defer(function()
				local btnPos = TabButton.AbsolutePosition
				local containerPos = TabContainer.AbsolutePosition
				Tween(TabHover, {
					Position = UDim2.new(0, btnPos.X - containerPos.X + 60, 0, 40),
					Size = UDim2.new(0, TabButton.AbsoluteSize.X, 0, 2)
				}, 0.2)
			end)

			Window.ActiveTab = Tab
			UpdatePlayerListsVisibility()
		end)

		function Tab:CreateSection(sectionName, subtabs, side)
			local Section = {}
			Section.Name = sectionName
			Section.Elements = {}
			Section.Subtabs = subtabs or {}
			Section.CurrentSubtab = subtabs and subtabs[1] or "main"
			Section.SubtabContents = {}

			side = side or (#Tab.Sections % 2 == 0 and "left" or "right")
			local parentColumn = side == "left" and LeftColumn or RightColumn

			local SectionFrame = Create("Frame", {
				Name = sectionName,
				BackgroundColor3 = Theme.Secondary,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Size = UDim2.new(1, 0, 0, 120),
				LayoutOrder = #Tab.Sections,
				ZIndex = 1,
				Parent = parentColumn
			})
			AddCorner(SectionFrame, 6)
			AddStroke(SectionFrame, Theme.Border)

			local Header = Create("Frame", {
				Name = "Upframe",
				BackgroundColor3 = Theme.TabFrame,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 32),
				ZIndex = 2,
				Parent = SectionFrame
			})
			AddCorner(Header, 6)

			local TitleLabel = Create("TextLabel", {
				Name = "TabName",
				BackgroundTransparency = 1,
				FontFace = Fonts.Inconsolata,
				Text = sectionName,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0, 70, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				ZIndex = 3,
				Parent = Header
			})
			AddContextualStroke(TitleLabel)

			local SubtabContainer = nil
			local SubtabButtons = {}

			if subtabs and #subtabs > 0 then
				SubtabContainer = Create("Frame", {
					Name = "Subtabs",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 200, 1, 0),
					Position = UDim2.new(1, -205, 0, 0),
					ClipsDescendants = false,
					ZIndex = 3,
					Parent = Header
				})

				local totalWidth = 0
				local buttonWidths = {}
				local spacing = 6

				for _, subtabName in ipairs(subtabs) do
					local textSize = game:GetService("TextService"):GetTextBoundsAsync(
						Create("GetTextBoundsParams", {
							Text = subtabName,
							Font = Fonts.Inconsolata,
							Size = 13,
							Width = 1000
						})
					)
					local width = textSize.X + 12
					table.insert(buttonWidths, width)
					totalWidth = totalWidth + width
				end

				totalWidth = totalWidth + (spacing * (#subtabs - 1))

				local currentX = 200 - totalWidth
				for i = 1, #subtabs do
					local subtabName = subtabs[i]
					local width = buttonWidths[i]

					local SubtabButton = Create("TextButton", {
						Name = subtabName,
						BackgroundTransparency = 1,
						FontFace = Fonts.Inconsolata,
						Text = subtabName,
						TextColor3 = i == 1 and Theme.Text or Theme.TextDark,
						TextSize = 13,
						Size = UDim2.new(0, width, 0, 28),
						Position = UDim2.new(0, currentX, 0.5, -14),
						ZIndex = 4,
						Parent = SubtabContainer
					})
					AddContextualStroke(SubtabButton)

					SubtabButtons[subtabName] = SubtabButton
					currentX = currentX + width + spacing

					SubtabButton.MouseButton1Click:Connect(function()
						CloseAllPopups()

						for n, btn in pairs(SubtabButtons) do
							btn.TextColor3 = Theme.TextDark
						end
						SubtabButton.TextColor3 = Theme.Text

						for n, data in pairs(Section.SubtabContents) do
							data.Content.Visible = (n == subtabName)
						end
						Section.CurrentSubtab = subtabName
					end)
				end
			end

			AddGradientLine(Header, UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1))

			local ContentHolder = Create("Frame", {
				Name = "Content",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, -36),
				Position = UDim2.new(0, 0, 0, 34),
				ClipsDescendants = true,
				ZIndex = 2,
				Parent = SectionFrame
			})

			Section.Frame = SectionFrame
			Section.ContentHolder = ContentHolder

			local function CreateSubtabContent(subtabName)
				local ContentScroll = Create("ScrollingFrame", {
					Name = subtabName,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, -6, 1, 0),
					Position = UDim2.new(0, 3, 0, 0),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarThickness = 2,
					ScrollBarImageColor3 = Theme.Accent,
					ScrollBarImageTransparency = 0.5,
					Visible = subtabName == Section.CurrentSubtab,
					ZIndex = 3,
					Parent = ContentHolder
				})

				local ContentLayout = Create("UIListLayout", {
					Padding = UDim.new(0, 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = ContentScroll
				})

				Create("UIPadding", {
					PaddingTop = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
					Parent = ContentScroll
				})

				return ContentScroll, ContentLayout
			end

			if subtabs and #subtabs > 0 then
				for i, subtabName in ipairs(subtabs) do
					local content, layout = CreateSubtabContent(subtabName)
					Section.SubtabContents[subtabName] = {Content = content, Layout = layout}
				end
				Section.Content = Section.SubtabContents[subtabs[1]].Content
				Section.Layout = Section.SubtabContents[subtabs[1]].Layout
			else
				local content, layout = CreateSubtabContent("main")
				Section.SubtabContents["main"] = {Content = content, Layout = layout}
				Section.Content = content
				Section.Layout = layout
			end

			local function UpdateSectionSize()
				local currentContent = Section.SubtabContents[Section.CurrentSubtab]
				if currentContent then
					local contentHeight = currentContent.Layout.AbsoluteContentSize.Y + 8
					local newHeight = math.clamp(contentHeight + 42, 80, 220)
					SectionFrame.Size = UDim2.new(1, 0, 0, newHeight)
				end
			end

			for _, data in pairs(Section.SubtabContents) do
				data.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionSize)
			end
			task.defer(UpdateSectionSize)

			local function GetCurrentContent()
				return Section.SubtabContents[Section.CurrentSubtab].Content
			end

			function Section:CreateToggle(options)
				options = options or {}
				local toggleName = options.Name or "Toggle"
				local default = options.Default or false
				local callback = options.Callback or function() end
				local subtab = options.Subtab or Section.CurrentSubtab

				local Toggle = {}
				Toggle.Value = default
				Toggle.HasKeybind = false
				Toggle.HasSideMenu = false

				local parentContent
				if Section.SubtabContents[subtab] then
					parentContent = Section.SubtabContents[subtab].Content
				else
					parentContent = Section.Content
				end

				local ToggleFrame = Create("Frame", {
					Name = toggleName,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					ZIndex = 4,
					Parent = parentContent
				})

				local Label = Create("TextLabel", {
					Name = "Name",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = toggleName,
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -30, 1, 0),
					ZIndex = 5,
					Parent = ToggleFrame
				})
				AddContextualStroke(Label)

				local Checkbox = Create("TextButton", {
					Name = "Button",
					BackgroundColor3 = default and Theme.Enabled or Theme.Disabled,
					BorderSizePixel = 0,
					Text = "",
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(1, -20, 0.5, -9),
					ZIndex = 5,
					Parent = ToggleFrame
				})
				AddCorner(Checkbox, 5)
				local CheckboxStroke = AddStroke(Checkbox, Theme.Border)

				local function UpdateToggle()
					Tween(Checkbox, {BackgroundColor3 = Toggle.Value and Theme.Enabled or Theme.Disabled}, 0.15)
					callback(Toggle.Value)
				end

				Checkbox.MouseEnter:Connect(function()
					Tween(CheckboxStroke, {Color = Theme.Accent}, 0.1)
				end)
				Checkbox.MouseLeave:Connect(function()
					Tween(CheckboxStroke, {Color = Theme.Border}, 0.1)
				end)

				Checkbox.MouseButton1Click:Connect(function()
					Toggle.Value = not Toggle.Value
					UpdateToggle()
				end)

				function Toggle:Set(value)
					Toggle.Value = value
					UpdateToggle()
				end

				function Toggle:Get()
					return Toggle.Value
				end

				local function RecalculatePositions()
					local rightOffset = 5

					if Toggle.HasSideMenu and Toggle.SideMenuBtn then
						Toggle.SideMenuBtn.Position = UDim2.new(1, -rightOffset - 10, 0.5, -11)
						rightOffset = rightOffset + 10 + 6
					end

					if Toggle.HasKeybind and Toggle.KeybindBtn then
						Toggle.KeybindBtn.Position = UDim2.new(1, -rightOffset - 26, 0.5, -9)
						rightOffset = rightOffset + 26 + 6
					end

					Checkbox.Position = UDim2.new(1, -rightOffset - 18, 0.5, -9)
					rightOffset = rightOffset + 18 + 5

					Label.Size = UDim2.new(1, -rightOffset - 3, 1, 0)
				end

				function Toggle:CreateKeybind(opts)
					opts = opts or {}
					local defaultKey = opts.Default or nil
					local keybindCallback = opts.Callback or function() end
					local mode = opts.Mode or "toggle"
                    local onPressCallback = opts.OnPress or function() end

					local Keybind = {}
					Keybind.Value = defaultKey
					Keybind.Mode = mode
					Keybind.Active = false
                    Keybind.Pressed = false

					Toggle.HasKeybind = true

					local KeyBtn = Create("TextButton", {
						Name = "Keybind",
						BackgroundColor3 = Theme.Tertiary,
						FontFace = Fonts.ComicNeue,
						Text = defaultKey and defaultKey.Name:sub(1, 3):upper() or "-",
						TextColor3 = Theme.Text,
						TextSize = 13,
						Size = UDim2.new(0, 26, 0, 18),
						Position = UDim2.new(1, -50, 0.5, -9),
						ZIndex = 5,
						Parent = ToggleFrame
					})
					AddCorner(KeyBtn, 4)
					local KeyStroke = AddStroke(KeyBtn, Theme.Stroke, 1)

					Toggle.KeybindBtn = KeyBtn
					RecalculatePositions()

					local KeybindMenu = Create("Frame", {
						Name = "KeybindMenu",
						BackgroundColor3 = Theme.Tertiary,
						BackgroundTransparency = 0,
						BorderSizePixel = 0,
						Size = UDim2.new(0, 120, 0, 0),
						ClipsDescendants = true,
						Visible = false,
						ZIndex = 150,
						Parent = ScreenGui
					})
					AddCorner(KeybindMenu, 4)
					AddStroke(KeybindMenu, Theme.Stroke, 1)

					local MenuHeader = Create("Frame", {
						Name = "Header",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 24),
						ZIndex = 151,
						Parent = KeybindMenu
					})

					local MenuTitle = Create("TextLabel", {
						Name = "Title",
						BackgroundTransparency = 1,
						FontFace = Fonts.ComicNeue,
						Text = "keybind mode",
						TextColor3 = Theme.Text,
						TextSize = 11,
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 152,
						Parent = MenuHeader
					})
					AddContextualStroke(MenuTitle)

					AddGradientLine(MenuHeader, UDim2.new(0, 0, 1, 0), UDim2.new(1, 0, 0, 1))

					local MenuContent = Create("Frame", {
						Name = "Content",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -8, 1, -30),
						Position = UDim2.new(0, 4, 0, 28),
						ZIndex = 151,
						Parent = KeybindMenu
					})

					Create("UIListLayout", {
						Padding = UDim.new(0, 4),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = MenuContent
					})

					Create("UIPadding", {
						PaddingBottom = UDim.new(0, 4),
						Parent = MenuContent
					})

					local modes = {"Always", "Toggle", "Hold"}
					local modeButtons = {}

					local menuOpen = false

					local function UpdateModeButtons()
						for modeName, btnData in pairs(modeButtons) do
							if modeName:lower() == Keybind.Mode then
								Tween(btnData.Stroke, {Color = Theme.AccentBlue}, 0.1)
								Tween(btnData.Label, {TextColor3 = Theme.Text}, 0.1)
							else
								Tween(btnData.Stroke, {Color = Theme.Border}, 0.1)
								Tween(btnData.Label, {TextColor3 = Theme.TextDark}, 0.1)
							end
						end
					end

					local function CloseKeybindMenu()
						if not menuOpen then return end
						menuOpen = false
						Tween(KeybindMenu, {Size = UDim2.new(0, 120, 0, 0)}, 0.15)
						task.delay(0.15, function()
							KeybindMenu.Visible = false
						end)
					end

					local function OpenKeybindMenu()
						if menuOpen then
							CloseKeybindMenu()
							return
						end

						CloseAllPopups()
						menuOpen = true

						local btnPos = KeyBtn.AbsolutePosition
						local btnSize = KeyBtn.AbsoluteSize
						local screenSize = workspace.CurrentCamera.ViewportSize

						local menuX = btnPos.X + btnSize.X + 5
						local menuY = btnPos.Y - 5

						if menuX + 120 > screenSize.X then
							menuX = btnPos.X - 125
						end

						KeybindMenu.Position = UDim2.new(0, menuX, 0, menuY)
						KeybindMenu.Size = UDim2.new(0, 120, 0, 0)
						KeybindMenu.Visible = true
						UpdateModeButtons()

						Tween(KeybindMenu, {Size = UDim2.new(0, 120, 0, 96)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

						table.insert(Window.OpenKeybindMenus, {Close = CloseKeybindMenu})
					end

					for i, modeName in ipairs(modes) do
						local ModeFrame = Create("Frame", {
							Name = modeName,
							BackgroundColor3 = Theme.Secondary,
							BackgroundTransparency = 0,
							Size = UDim2.new(1, 0, 0, 20),
							LayoutOrder = i,
							ZIndex = 152,
							Parent = MenuContent
						})
						AddCorner(ModeFrame, 4)
						local ModeStroke = AddStroke(ModeFrame, modeName:lower() == mode and Theme.AccentBlue or Theme.Border, 1)

						local ModeLabel = Create("TextLabel", {
							Name = "Label",
							BackgroundTransparency = 1,
							FontFace = Fonts.ComicNeue,
							Text = modeName,
							TextColor3 = modeName:lower() == mode and Theme.Text or Theme.TextDark,
							TextSize = 12,
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 153,
							Parent = ModeFrame
						})
						AddContextualStroke(ModeLabel)

						local ModeBtn = Create("TextButton", {
							Name = "Button",
							BackgroundTransparency = 1,
							Text = "",
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 154,
							Parent = ModeFrame
						})

						modeButtons[modeName] = {Frame = ModeFrame, Stroke = ModeStroke, Label = ModeLabel}

						ModeBtn.MouseEnter:Connect(function()
							if modeName:lower() ~= Keybind.Mode then
								Tween(ModeStroke, {Color = Theme.Accent}, 0.1)
							end
						end)

						ModeBtn.MouseLeave:Connect(function()
							if modeName:lower() ~= Keybind.Mode then
								Tween(ModeStroke, {Color = Theme.Border}, 0.1)
							end
						end)

						ModeBtn.MouseButton1Click:Connect(function()
							Keybind.Mode = modeName:lower()
							mode = modeName:lower()
							UpdateModeButtons()

							if mode == "always" then
								Toggle.Value = true
								UpdateToggle()
							end

							CloseKeybindMenu()
						end)
					end

					local binding = false

					KeyBtn.MouseButton1Click:Connect(function()
						if binding then return end
						binding = true
						KeyBtn.Text = "[...]"
						Tween(KeyStroke, {Color = Theme.Enabled}, 0.1)

						local conn
						conn = UserInputService.InputBegan:Connect(function(input, gpe)
							if gpe then return end
							if binding then return end
							if input.UserInputType == Enum.UserInputType.Keyboard then
								Keybind.Value = input.KeyCode
								KeyBtn.Text = input.KeyCode.Name:sub(1, 3):upper()
								conn:Disconnect()
								Tween(KeyStroke, {Color = Theme.AccentBlue}, 0.1)
								keybindCallback(input.KeyCode)
						        task.delay(0.1, function()
						            binding = false
						        end)
							end
						end)
					end)

					KeyBtn.MouseButton2Click:Connect(function()
						OpenKeybindMenu()
					end)

					UserInputService.InputBegan:Connect(function(input, gpe)
						if gpe then return end
						if binding then return end
						if Keybind.Value and input.KeyCode == Keybind.Value then
							Keybind.Pressed = true
                            
                            if Keybind.Mode == "toggle" then
								-- Toggle.Value = not Toggle.Value -- im dumb lmao
								UpdateToggle()
							elseif Keybind.Mode == "hold" then
								-- Toggle.Value = true -- im dumb lmao
								UpdateToggle()
							end
							keybindCallback(Keybind.Value)

                            if Toggle.Value then
                                onPressCallback(Keybind.Value, Toggle.Value)
                            end
						end
					end)

					UserInputService.InputEnded:Connect(function(input, gpe)
						if Keybind.Value and input.KeyCode == Keybind.Value then
							Keybind.Pressed = false
                            
                            if Keybind.Mode == "hold" then
								-- Toggle.Value = false -- im stupid
								UpdateToggle()
							end
						end
					end)

					function Keybind:Set(key)
						Keybind.Value = key
						KeyBtn.Text = key and key.Name:sub(1, 3):upper() or "-"
					end

                    function Keybind:IsPressed()
                        return Keybind.Pressed
                    end

                    function Keybind:SetOnPress(callback)
                        onPressCallback = callback or function() end
                    end

					function Keybind:SetMode(m)
						Keybind.Mode = m:lower()
						mode = m:lower()
						UpdateModeButtons()

						if mode == "always" then
							Toggle.Value = true
							UpdateToggle()
						end
					end

					function Keybind:GetMode()
						return Keybind.Mode
					end

					Toggle.Keybind = Keybind
					return Keybind
				end

				function Toggle:CreateSideMenu(name)
					Toggle.HasSideMenu = true

					local SideMenuBtn = Create("TextButton", {
						Name = "SideMenuBtn",
						BackgroundTransparency = 1,
						FontFace = Fonts.Inconsolata,
						Text = "+",
						TextColor3 = Theme.TextDark,
						TextSize = 16,
						Size = UDim2.new(0, 10, 0, 22),
						Position = UDim2.new(1, -70, 0.5, -11),
						ZIndex = 5,
						Parent = ToggleFrame
					})
					AddContextualStroke(SideMenuBtn)

					Toggle.SideMenuBtn = SideMenuBtn
					RecalculatePositions()

					local sideMenu = CreateSideMenu({
						Name = name or (toggleName .. " Settings"),
						Button = SideMenuBtn
					})

					SideMenuBtn.MouseEnter:Connect(function()
						Tween(SideMenuBtn, {TextColor3 = Theme.Text}, 0.1)
					end)
					SideMenuBtn.MouseLeave:Connect(function()
						if not sideMenu.Open then
							Tween(SideMenuBtn, {TextColor3 = Theme.TextDark}, 0.1)
						end
					end)

					SideMenuBtn.MouseButton1Click:Connect(function()
						if sideMenu.Open then
							sideMenu.Close()
							SideMenuBtn.Text = "+"
							SideMenuBtn.TextColor3 = Theme.TextDark
						else
							sideMenu.Open_()
							SideMenuBtn.Text = "-"
							SideMenuBtn.TextColor3 = Theme.Text
						end
					end)

					Toggle.SideMenu = sideMenu
					return sideMenu
				end

				Toggle.Frame = ToggleFrame

				if default then callback(default) end
				task.defer(UpdateSectionSize)
				return Toggle
			end
			
			function Section:CreateDropdown(options)
				options = options or {}
				local dropdownName = options.Name or "Dropdown"
				local items = options.Items or {}
				local default = options.Default or (items[1] or "None")
				local callback = options.Callback or function() end
				local subtab = options.Subtab or Section.CurrentSubtab

				local Dropdown = {}
				Dropdown.Value = default
				Dropdown.Open = false

				local parentContent = Section.SubtabContents[subtab] and Section.SubtabContents[subtab].Content or GetCurrentContent()

				local DropdownFrame = Create("Frame", {
					Name = dropdownName,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					ZIndex = 4,
					Parent = parentContent
				})

				local Label = Create("TextLabel", {
					Name = "Name",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = dropdownName,
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(0.42, 0, 1, 0),
					ZIndex = 5,
					Parent = DropdownFrame
				})
				AddContextualStroke(Label)

				local DropdownBtn = Create("TextButton", {
					Name = "Dropdown",
					BackgroundColor3 = Theme.Tertiary,
					Text = "",
					Size = UDim2.new(0.55, 0, 0, 22),
					Position = UDim2.new(0.45, 0, 0, 0),
					ZIndex = 5,
					Parent = DropdownFrame
				})
				AddCorner(DropdownBtn, 5)
				local DropdownStroke = AddStroke(DropdownBtn, Theme.Border)

				local ValueLabel = Create("TextLabel", {
					Name = "Value",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = default,
					TextColor3 = Theme.TextDarker,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Size = UDim2.new(1, -24, 1, 0),
					Position = UDim2.new(0, 6, 0, 0),
					ZIndex = 6,
					Parent = DropdownBtn
				})

				local Plus = Create("TextLabel", {
					Name = "Plus",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = "+",
					TextColor3 = Theme.Text,
					TextSize = 14,
					Size = UDim2.new(0, 18, 1, 0),
					Position = UDim2.new(1, -18, 0, 0),
					ZIndex = 6,
					Parent = DropdownBtn
				})
				AddContextualStroke(Plus)

				local DropdownList = Create("Frame", {
					Name = dropdownName .. "List",
					BackgroundColor3 = Theme.Secondary,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Size = UDim2.new(0, 0, 0, 0),
					Visible = false,
					ZIndex = 50,
					Parent = ScreenGui
				})
				AddCorner(DropdownList, 6)
				AddStroke(DropdownList, Theme.Border)

				local ListScroll = Create("ScrollingFrame", {
					Name = "List",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
					CanvasSize = UDim2.new(0, 0, 0, #items * 26),
					ScrollBarThickness = 2,
					ScrollBarImageColor3 = Theme.Accent,
					ZIndex = 51,
					Parent = DropdownList
				})

				Create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = ListScroll
				})

				local function CloseDropdown()
					if not Dropdown.Open then return end
					Dropdown.Open = false
					Plus.Text = "+"
					Tween(DropdownList, {Size = UDim2.new(0, DropdownBtn.AbsoluteSize.X, 0, 0)}, 0.15)
					task.delay(0.15, function()
						DropdownList.Visible = false
					end)
				end

				Dropdown.Close = CloseDropdown

				local function CreateItems()
					for _, child in pairs(ListScroll:GetChildren()) do
						if child:IsA("TextButton") then child:Destroy() end
					end

					for _, item in ipairs(items) do
						local ItemBtn = Create("TextButton", {
							Name = item,
							BackgroundColor3 = Theme.Secondary,
							FontFace = Fonts.Inconsolata,
							Text = item,
							TextColor3 = Theme.Text,
							TextSize = 13,
							TextXAlignment = Enum.TextXAlignment.Left,
							Size = UDim2.new(1, 0, 0, 26),
							ZIndex = 52,
							Parent = ListScroll
						})

						Create("UIPadding", {
							PaddingLeft = UDim.new(0, 8),
							Parent = ItemBtn
						})

						ItemBtn.MouseEnter:Connect(function()
							Tween(ItemBtn, {BackgroundColor3 = Theme.Hover}, 0.1)
						end)
						ItemBtn.MouseLeave:Connect(function()
							Tween(ItemBtn, {BackgroundColor3 = Theme.Secondary}, 0.1)
						end)

						ItemBtn.MouseButton1Click:Connect(function()
							Dropdown.Value = item
							ValueLabel.Text = item
							CloseDropdown()
							callback(item)
						end)
					end
					ListScroll.CanvasSize = UDim2.new(0, 0, 0, #items * 26)
				end

				CreateItems()

				DropdownBtn.MouseEnter:Connect(function()
					Tween(DropdownStroke, {Color = Theme.Accent}, 0.1)
				end)
				DropdownBtn.MouseLeave:Connect(function()
					if not Dropdown.Open then
						Tween(DropdownStroke, {Color = Theme.Border}, 0.1)
					end
				end)

				DropdownBtn.MouseButton1Click:Connect(function()
					if Dropdown.Open then
						CloseDropdown()
						return
					end

					CloseAllPopups()

					Dropdown.Open = true
					table.insert(Window.OpenDropdowns, Dropdown)

					local btnPos = DropdownBtn.AbsolutePosition
					local btnSize = DropdownBtn.AbsoluteSize
					local listHeight = math.min(#items * 26, 130)

					DropdownList.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 2)
					DropdownList.Size = UDim2.new(0, btnSize.X, 0, 0)
					DropdownList.Visible = true
					Plus.Text = "-"
					Tween(DropdownList, {Size = UDim2.new(0, btnSize.X, 0, listHeight)}, 0.15)
				end)

				function Dropdown:Set(value)
					Dropdown.Value = value
					ValueLabel.Text = value
					callback(value)
				end

				function Dropdown:Refresh(newItems)
					items = newItems
					CreateItems()
				end

				Dropdown.Frame = DropdownFrame

				callback(default)
				task.defer(UpdateSectionSize)
				return Dropdown
			end
			
			function Section:CreateMultiDropdown(options)
				options = options or {}
				local dropdownName = options.Name or "Multi Dropdown"
				local items = options.Items or {}
				local default = options.Default or {}
				local callback = options.Callback or function() end
				local subtab = options.Subtab or Section.CurrentSubtab

				local MultiDropdown = {}
				MultiDropdown.Values = {}
				MultiDropdown.Open = false

				for _, item in pairs(default) do
					MultiDropdown.Values[item] = true
				end

				local parentContent = Section.SubtabContents[subtab] and Section.SubtabContents[subtab].Content or GetCurrentContent()

				local DropdownFrame = Create("Frame", {
					Name = dropdownName,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					ZIndex = 4,
					Parent = parentContent
				})

				local Label = Create("TextLabel", {
					Name = "Name",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = dropdownName,
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(0.42, 0, 1, 0),
					ZIndex = 5,
					Parent = DropdownFrame
				})
				AddContextualStroke(Label)

				local DropdownBtn = Create("TextButton", {
					Name = "Dropdown",
					BackgroundColor3 = Theme.Tertiary,
					Text = "",
					Size = UDim2.new(0.55, 0, 0, 22),
					Position = UDim2.new(0.45, 0, 0, 0),
					ZIndex = 5,
					Parent = DropdownFrame
				})
				AddCorner(DropdownBtn, 5)
				local DropdownStroke = AddStroke(DropdownBtn, Theme.Border)

				local function UpdateText()
					local selected = {}
					for item, enabled in pairs(MultiDropdown.Values) do
						if enabled then
							table.insert(selected, item)
						end
					end

					local text = #selected > 0 and table.concat(selected, ", ") or "None"
					if #text > 20 then
						text = #selected .. " selected"
					end
					return text
				end

				local ValueLabel = Create("TextLabel", {
					Name = "Value",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = UpdateText(),
					TextColor3 = Theme.TextDarker,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Size = UDim2.new(1, -24, 1, 0),
					Position = UDim2.new(0, 6, 0, 0),
					ZIndex = 6,
					Parent = DropdownBtn
				})

				local Plus = Create("TextLabel", {
					Name = "Plus",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = "+",
					TextColor3 = Theme.Text,
					TextSize = 14,
					Size = UDim2.new(0, 18, 1, 0),
					Position = UDim2.new(1, -18, 0, 0),
					ZIndex = 6,
					Parent = DropdownBtn
				})
				AddContextualStroke(Plus)

				local DropdownList = Create("Frame", {
					Name = dropdownName .. "List",
					BackgroundColor3 = Theme.Secondary,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Size = UDim2.new(0, 0, 0, 0),
					Visible = false,
					ZIndex = 50,
					Parent = ScreenGui
				})
				AddCorner(DropdownList, 6)
				AddStroke(DropdownList, Theme.Border)

				local ListScroll = Create("ScrollingFrame", {
					Name = "List",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
					CanvasSize = UDim2.new(0, 0, 0, #items * 26),
					ScrollBarThickness = 2,
					ScrollBarImageColor3 = Theme.Accent,
					ZIndex = 51,
					Parent = DropdownList
				})

				Create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = ListScroll
				})

				local function CloseDropdown()
					if not MultiDropdown.Open then return end
					MultiDropdown.Open = false
					Plus.Text = "+"
					Tween(DropdownList, {Size = UDim2.new(0, DropdownBtn.AbsoluteSize.X, 0, 0)}, 0.15)
					task.delay(0.15, function()
						DropdownList.Visible = false
					end)
				end

				MultiDropdown.Close = CloseDropdown

				local function CreateItems()
					for _, child in pairs(ListScroll:GetChildren()) do
						if child:IsA("Frame") then child:Destroy() end
					end

					for _, item in ipairs(items) do
						local ItemFrame = Create("Frame", {
							Name = item,
							BackgroundColor3 = Theme.Secondary,
							Size = UDim2.new(1, 0, 0, 26),
							ZIndex = 52,
							Parent = ListScroll
						})

						local Dot = Create("Frame", {
							Name = "Dot",
							BackgroundColor3 = Theme.Blue,
							BorderSizePixel = 0,
							Size = UDim2.new(0, 6, 0, 6),
							Position = UDim2.new(0, 6, 0.5, -3),
							Visible = MultiDropdown.Values[item] or false,
							ZIndex = 54,
							Parent = ItemFrame
						})
						AddCorner(Dot, 10)

						local ItemLabel = Create("TextLabel", {
							Name = "Label",
							BackgroundTransparency = 1,
							FontFace = Fonts.Inconsolata,
							Text = item,
							TextColor3 = Theme.Text,
							TextSize = 13,
							TextXAlignment = Enum.TextXAlignment.Left,
							Size = UDim2.new(1, -20, 1, 0),
							Position = UDim2.new(0, MultiDropdown.Values[item] and 18 or 6, 0, 0),
							ZIndex = 53,
							Parent = ItemFrame
						})

						local ItemBtn = Create("TextButton", {
							Name = "Button",
							BackgroundTransparency = 1,
							Text = "",
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 54,
							Parent = ItemFrame
						})

						ItemBtn.MouseEnter:Connect(function()
							Tween(ItemFrame, {BackgroundColor3 = Theme.Hover}, 0.1)
						end)
						ItemBtn.MouseLeave:Connect(function()
							Tween(ItemFrame, {BackgroundColor3 = Theme.Secondary}, 0.1)
						end)

						ItemBtn.MouseButton1Click:Connect(function()
							MultiDropdown.Values[item] = not MultiDropdown.Values[item]

							if MultiDropdown.Values[item] then
								Dot.Visible = true
								Dot.Size = UDim2.new(0, 0, 0, 0)
								Tween(Dot, {Size = UDim2.new(0, 6, 0, 6)}, 0.2, Enum.EasingStyle.Back)
								Tween(ItemLabel, {Position = UDim2.new(0, 18, 0, 0)}, 0.3, Enum.EasingStyle.Back)
							else
								Tween(Dot, {Size = UDim2.new(0, 0, 0, 0)}, 0.15)
								Tween(ItemLabel, {Position = UDim2.new(0, 6, 0, 0)}, 0.3, Enum.EasingStyle.Back)
								task.delay(0.15, function()
									if not MultiDropdown.Values[item] then
										Dot.Visible = false
									end
								end)
							end

							ValueLabel.Text = UpdateText()

							local selected = {}
							for k, v in pairs(MultiDropdown.Values) do
								if v then table.insert(selected, k) end
							end
							callback(selected)
						end)
					end
					ListScroll.CanvasSize = UDim2.new(0, 0, 0, #items * 26)
				end

				CreateItems()

				DropdownBtn.MouseEnter:Connect(function()
					Tween(DropdownStroke, {Color = Theme.Accent}, 0.1)
				end)
				DropdownBtn.MouseLeave:Connect(function()
					if not MultiDropdown.Open then
						Tween(DropdownStroke, {Color = Theme.Border}, 0.1)
					end
				end)

				DropdownBtn.MouseButton1Click:Connect(function()
					if MultiDropdown.Open then
						CloseDropdown()
						return
					end

					CloseAllPopups()

					MultiDropdown.Open = true
					table.insert(Window.OpenDropdowns, MultiDropdown)

					local btnPos = DropdownBtn.AbsolutePosition
					local btnSize = DropdownBtn.AbsoluteSize
					local listHeight = math.min(#items * 26, 130)

					DropdownList.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 2)
					DropdownList.Size = UDim2.new(0, btnSize.X, 0, 0)
					DropdownList.Visible = true
					Plus.Text = "-"
					Tween(DropdownList, {Size = UDim2.new(0, btnSize.X, 0, listHeight)}, 0.15)
				end)

				function MultiDropdown:Set(values)
					MultiDropdown.Values = {}
					for _, item in pairs(values) do
						MultiDropdown.Values[item] = true
					end
					ValueLabel.Text = UpdateText()
					CreateItems()
				end

				function MultiDropdown:Get()
					local selected = {}
					for item, enabled in pairs(MultiDropdown.Values) do
						if enabled then table.insert(selected, item) end
					end
					return selected
				end

				MultiDropdown.Frame = DropdownFrame

				local initial = {}
				for item, enabled in pairs(MultiDropdown.Values) do
					if enabled then table.insert(initial, item) end
				end
				if #initial > 0 then callback(initial) end

				task.defer(UpdateSectionSize)
				return MultiDropdown
			end

			function Section:CreateSlider(options)
				options = options or {}
				local sliderName = options.Name or "Slider"
				local min = options.Min or 0
				local max = options.Max or 100
				local default = options.Default or min
				local increment = options.Increment or 1
				local suffix = options.Suffix or ""
				local callback = options.Callback or function() end
				local subtab = options.Subtab or Section.CurrentSubtab

				local Slider = {}
				Slider.Value = default

				local parentContent = Section.SubtabContents[subtab] and Section.SubtabContents[subtab].Content or GetCurrentContent()

				local SliderFrame = Create("Frame", {
					Name = sliderName,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 32),
					ZIndex = 4,
					Parent = parentContent
				})

				local Label = Create("TextLabel", {
					Name = "Name",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = sliderName,
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(0.7, 0, 0, 16),
					ZIndex = 5,
					Parent = SliderFrame
				})
				AddContextualStroke(Label)

				local ValueBox = Create("TextBox", {
					Name = "ValueBox",
					BackgroundColor3 = Theme.Tertiary,
					FontFace = Fonts.Inconsolata,
					Text = tostring(default) .. suffix,
					TextColor3 = Theme.TextDarker,
					TextSize = 12,
					Size = UDim2.new(0, 40, 0, 16),
					Position = UDim2.new(1, -42, 0, 0),
					ZIndex = 5,
					Parent = SliderFrame
				})
				AddCorner(ValueBox, 4)
				local ValueBoxStroke = AddStroke(ValueBox, Theme.Border)

				local SliderBG = Create("Frame", {
					Name = "Background",
					BackgroundColor3 = Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 6),
					Position = UDim2.new(0, 0, 0, 22),
					ZIndex = 5,
					Parent = SliderFrame
				})
				AddCorner(SliderBG, 4)
				AddStroke(SliderBG, Theme.Border)

				local SliderFill = Create("Frame", {
					Name = "Fill",
					BackgroundColor3 = Theme.Blue,
					BorderSizePixel = 0,
					Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
					ZIndex = 6,
					Parent = SliderBG
				})
				AddCorner(SliderFill, 4)

				local SliderKnob = Create("Frame", {
					Name = "Knob",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 12, 0, 12),
					Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
					ZIndex = 7,
					Parent = SliderBG
				})
				AddCorner(SliderKnob, 10)
				local KnobStroke = AddStroke(SliderKnob, Theme.Border)

				local function UpdateSlider(value, skipCallback)
					value = math.clamp(value, min, max)
					value = math.floor(value / increment + 0.5) * increment
					value = math.clamp(value, min, max)

					Slider.Value = value
					local percent = (value - min) / (max - min)
					SliderFill.Size = UDim2.new(percent, 0, 1, 0)
					SliderKnob.Position = UDim2.new(percent, -6, 0.5, -6)
					ValueBox.Text = tostring(value) .. suffix

					if not skipCallback then
						callback(value)
					end
				end

				local function UpdateFromInput(input)
					local percent = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
					local value = min + (percent * (max - min))
					UpdateSlider(value)
				end

				local sliding = false

				SliderBG.InputBegan:Connect(function(input)
					if IsTouchOrMouse1(input) then
						sliding = true
						UpdateFromInput(input)
						Tween(SliderKnob, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(SliderKnob.Position.X.Scale, -7, 0.5, -7)}, 0.1)
						Tween(KnobStroke, {Color = Theme.Accent}, 0.1)
					end
				end)

				SliderBG.InputEnded:Connect(function(input)
					if IsTouchOrMouse1(input) then
						sliding = false
						local percent = (Slider.Value - min) / (max - min)
						Tween(SliderKnob, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(percent, -6, 0.5, -6)}, 0.1)
						Tween(KnobStroke, {Color = Theme.Border}, 0.1)
					end
				end)

				SliderKnob.InputBegan:Connect(function(input)
					if IsTouchOrMouse1(input) then
						sliding = true
						Tween(SliderKnob, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(SliderKnob.Position.X.Scale, -7, 0.5, -7)}, 0.1)
						Tween(KnobStroke, {Color = Theme.Accent}, 0.1)
					end
				end)

				SliderKnob.InputEnded:Connect(function(input)
					if IsTouchOrMouse1(input) then
						sliding = false
						local percent = (Slider.Value - min) / (max - min)
						Tween(SliderKnob, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(percent, -6, 0.5, -6)}, 0.1)
						Tween(KnobStroke, {Color = Theme.Border}, 0.1)
					end
				end)

				SliderBG.MouseEnter:Connect(function()
					Tween(SliderFill, {BackgroundColor3 = Theme.Accent}, 0.1)
				end)

				SliderBG.MouseLeave:Connect(function()
					if not sliding then
						Tween(SliderFill, {BackgroundColor3 = Theme.Blue}, 0.1)
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if sliding and IsTouchOrMouseMove(input) then
						UpdateFromInput(input)
					end
				end)

				ValueBox.MouseEnter:Connect(function()
					Tween(ValueBoxStroke, {Color = Theme.Accent}, 0.1)
				end)

				ValueBox.MouseLeave:Connect(function()
					Tween(ValueBoxStroke, {Color = Theme.Border}, 0.1)
				end)

				ValueBox.FocusLost:Connect(function(enterPressed)
					local text = ValueBox.Text:gsub(suffix, "")
					local num = tonumber(text)
					if num then
						UpdateSlider(num)
					else
						ValueBox.Text = tostring(Slider.Value) .. suffix
					end
				end)

				ValueBox.Focused:Connect(function()
					ValueBox.Text = tostring(Slider.Value)
				end)

				function Slider:Set(value)
					UpdateSlider(value)
				end

				function Slider:Get()
					return Slider.Value
				end

				function Slider:SetMin(newMin)
					min = newMin
					UpdateSlider(Slider.Value, true)
				end

				function Slider:SetMax(newMax)
					max = newMax
					UpdateSlider(Slider.Value, true)
				end

				Slider.Frame = SliderFrame

				callback(default)
				task.defer(UpdateSectionSize)
				return Slider
			end

			function Section:CreateKeybind(options)
				options = options or {}
				local keybindName = options.Name or "Keybind"
				local default = options.Default or nil
				local callback = options.Callback or function() end
				local subtab = options.Subtab or Section.CurrentSubtab

				local Keybind = {}
				Keybind.Value = default

				local parentContent
				if Section.SubtabContents[subtab] then
					parentContent = Section.SubtabContents[subtab].Content
				else
					parentContent = Section.Content
				end

				local KeybindFrame = Create("Frame", {
					Name = keybindName,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					Parent = parentContent
				})

				local Label = Create("TextLabel", {
					Name = "Name",
					BackgroundTransparency = 1,
					FontFace = Fonts.ComicNeue,
					Text = keybindName,
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -50, 1, 0),
					Parent = KeybindFrame
				})
				AddContextualStroke(Label)

				local KeyBtn = Create("TextButton", {
					Name = "Key",
					BackgroundColor3 = Theme.Tertiary,
					FontFace = Fonts.ComicNeue,
					Text = default and default.Name or "-",
					TextColor3 = Theme.TextDarker,
					TextSize = 13,
					Size = UDim2.new(0, 45, 0, 20),
					Position = UDim2.new(1, -45, 0.5, -10),
					Parent = KeybindFrame
				})
				AddCorner(KeyBtn, 5)
				local KeyStroke = AddStroke(KeyBtn, Theme.Border)

				local binding = false

				KeyBtn.MouseEnter:Connect(function()
					Tween(KeyStroke, {Color = Theme.Accent}, 0.1)
				end)
				KeyBtn.MouseLeave:Connect(function()
					Tween(KeyStroke, {Color = Theme.Border}, 0.1)
				end)

				KeyBtn.MouseButton1Click:Connect(function()
					if binding then return end
					binding = true
					KeyBtn.Text = "[...]"

					local conn
					conn = UserInputService.InputBegan:Connect(function(input, gpe)
						if gpe then return end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							Keybind.Value = input.KeyCode
							KeyBtn.Text = input.KeyCode.Name:sub(1, 4):upper()
							binding = false
							conn:Disconnect()
							callback(input.KeyCode)
						end
					end)
				end)

				UserInputService.InputBegan:Connect(function(input, gpe)
					if gpe then return end
					if Keybind.Value and input.KeyCode == Keybind.Value then
						callback(Keybind.Value)
					end
				end)

				function Keybind:Set(key)
					Keybind.Value = key
					KeyBtn.Text = key and key.Name:sub(1, 4):upper() or "-"
				end 

				Keybind.Frame = KeybindFrame
				task.defer(UpdateSectionSize)
				return Keybind
			end

			function Section:CreateParagraph(options)
				options = options or {}
				local title = options.Title or "nil"
				local content = options.Content or "creater didnt added content"
				local subtab = options.Subtab or Section.CurrentSubtab

				local parentContent
				if Section.SubtabContents[subtab] then
					parentContent = Section.SubtabContents[subtab].Content
				else
					parentContent = Section.Content
				end

				local ParagraphFrame = Create("Frame", {
					Name = title,
					BackgroundColor3 = Theme.Tertiary,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					Parent = parentContent
				})
				AddCorner(ParagraphFrame, 5)
				AddStroke(ParagraphFrame, Theme.Border)

				local TitleLabel = Create("TextLabel", {
					Name = "Title",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = title,
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -10, 0, 20),
					Position = UDim2.new(0, 5, 0, 2),
					Parent = ParagraphFrame
				})
				AddContextualStroke(TitleLabel)

				local ContentLabel = Create("TextLabel", {
					Name = "Content",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = content,
					TextColor3 = Theme.TextDark,
					TextSize = 13,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, -10, 0, 0),
					Position = UDim2.new(0, 5, 0, 22),
					Parent = ParagraphFrame
				})

				Create("UIPadding", {
					PaddingBottom = UDim.new(0, 5),
					Parent = ParagraphFrame
				})

				local Paragraph = {Frame = ParagraphFrame}

				function Paragraph:SetTitle(t) TitleLabel.Text = t end
				function Paragraph:SetContent(c) ContentLabel.Text = c end

				task.defer(UpdateSectionSize)
				return Paragraph
			end

			function Section:CreateColorPicker(options)
				options = options or {}
				local pickerName = options.Name or "Color"
				local default = options.Default or Theme.Blue
				local callback = options.Callback or function() end
				local subtab = options.Subtab or Section.CurrentSubtab

				local ColorPicker = {}
				ColorPicker.Value = default
				ColorPicker.Open = false

				local parentContent = Section.SubtabContents[subtab] and Section.SubtabContents[subtab].Content or GetCurrentContent()

				local ColorFrame = Create("Frame", {
					Name = pickerName,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					ZIndex = 4,
					Parent = parentContent
				})

				local Label = Create("TextLabel", {
					Name = "Name",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = pickerName,
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -45, 1, 0),
					ZIndex = 5,
					Parent = ColorFrame
				})
				AddContextualStroke(Label)

				local ColorBtn = Create("TextButton", {
					Name = "ColorPicker",
					BackgroundColor3 = default,
					BorderSizePixel = 0,
					Text = "",
					Size = UDim2.new(0, 35, 0, 18),
					Position = UDim2.new(1, -38, 0.5, -9),
					ZIndex = 5,
					Parent = ColorFrame
				})
				AddCorner(ColorBtn, 5)
				local ColorStroke = AddStroke(ColorBtn, Theme.Border)

				local PickerPanel = Create("Frame", {
					Name = pickerName .. "Panel",
					BackgroundColor3 = Theme.Secondary,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 180, 0, 160),
					Visible = false,
					ZIndex = 60,
					Parent = ScreenGui
				})
				AddCorner(PickerPanel, 6)
				AddStroke(PickerPanel, Theme.Border)

				local Palette = Create("ImageLabel", {
					Name = "Palette",
					BackgroundColor3 = Color3.fromRGB(255, 0, 0),
					Image = "rbxassetid://4155801252",
					Size = UDim2.new(0, 145, 0, 140),
					Position = UDim2.new(0, 10, 0, 10),
					ZIndex = 61,
					Parent = PickerPanel
				})
				AddCorner(Palette, 5)

				local PaletteSelector = Create("Frame", {
					Name = "Selector",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 8, 0, 8),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(1, 0, 0, 0),
					ZIndex = 62,
					Parent = Palette
				})
				AddCorner(PaletteSelector, 8)
				AddStroke(PaletteSelector, Color3.fromRGB(0, 0, 0), 1)

				local HueSlider = Create("Frame", {
					Name = "HueSlider",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0, 14, 0, 140),
					Position = UDim2.new(0, 160, 0, 10),
					ZIndex = 61,
					Parent = PickerPanel
				})
				AddCorner(HueSlider, 5)
				Create("UIGradient", {
					Rotation = 90,
					Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
						ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					},
					Parent = HueSlider
				})

				local HueSelector = Create("Frame", {
					Name = "Selector",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 4, 0, 4),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0, 0),
					ZIndex = 62,
					Parent = HueSlider
				})
				AddCorner(HueSelector, 3)
				AddStroke(HueSelector, Color3.fromRGB(0, 0, 0), 1)

				local h, s, v = default:ToHSV()
				local hue = h

				local function UpdateColor()
					local color = Color3.fromHSV(hue, s, v)
					ColorPicker.Value = color
					ColorBtn.BackgroundColor3 = color
					Palette.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
					callback(color)
				end

				local function CloseColorPicker()
					if not ColorPicker.Open then return end
					ColorPicker.Open = false
					PickerPanel.Visible = false
				end

				ColorPicker.Close = CloseColorPicker

				ColorBtn.MouseEnter:Connect(function()
					Tween(ColorStroke, {Color = Theme.Accent}, 0.1)
				end)
				ColorBtn.MouseLeave:Connect(function()
					if not ColorPicker.Open then
						Tween(ColorStroke, {Color = Theme.Border}, 0.1)
					end
				end)

				ColorBtn.MouseButton1Click:Connect(function()
					if ColorPicker.Open then
						CloseColorPicker()
						return
					end

					CloseAllPopups()

					ColorPicker.Open = true
					table.insert(Window.OpenColorPickers, ColorPicker)

					local btnPos = ColorBtn.AbsolutePosition
					PickerPanel.Position = UDim2.new(0, btnPos.X - 145, 0, btnPos.Y + 22)
					PickerPanel.Visible = true
				end)

				local paletteDragging = false
				Palette.InputBegan:Connect(function(input)
					if IsTouchOrMouse1(input) then
						paletteDragging = true
					end
				end)
				Palette.InputEnded:Connect(function(input)
					if IsTouchOrMouse1(input) then
						paletteDragging = false
					end
				end)

				local hueDragging = false
				HueSlider.InputBegan:Connect(function(input)
					if IsTouchOrMouse1(input) then
						hueDragging = true
					end
				end)
				HueSlider.InputEnded:Connect(function(input)
					if IsTouchOrMouse1(input) then
						hueDragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if IsTouchOrMouseMove(input) then
						if paletteDragging then
							local rx = math.clamp((input.Position.X - Palette.AbsolutePosition.X) / Palette.AbsoluteSize.X, 0, 1)
							local ry = math.clamp((input.Position.Y - Palette.AbsolutePosition.Y) / Palette.AbsoluteSize.Y, 0, 1)
							s, v = rx, 1 - ry
							PaletteSelector.Position = UDim2.new(rx, 0, ry, 0)
							UpdateColor()
						elseif hueDragging then
							local ry = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
							hue = ry
							HueSelector.Position = UDim2.new(0.5, 0, ry, 0)
							UpdateColor()
						end
					end
				end)

				function ColorPicker:Set(color)
					ColorPicker.Value = color
					ColorBtn.BackgroundColor3 = color
					h, s, v = color:ToHSV()
					hue = h
					PaletteSelector.Position = UDim2.new(s, 0, 1 - v, 0)
					HueSelector.Position = UDim2.new(0.5, 0, hue, 0)
					Palette.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
					callback(color)
				end

				ColorPicker.Frame = ColorFrame

				callback(default)
				task.defer(UpdateSectionSize)
				return ColorPicker
			end

			function Section:CreateButton(options)
				options = options or {}
				local buttonName = options.Name or "Button"
				local callback = options.Callback or function() end
				local subtab = options.Subtab or Section.CurrentSubtab

				local parentContent = Section.SubtabContents[subtab] and Section.SubtabContents[subtab].Content or GetCurrentContent()

				local ButtonFrame = Create("Frame", {
					Name = "ButtonContainer",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
					ZIndex = 4,
					Parent = parentContent
				})

				local Button = Create("TextButton", {
					Name = buttonName,
					BackgroundColor3 = Theme.TabFrame,
					FontFace = Fonts.SourceSans,
					Text = buttonName,
					TextColor3 = Theme.Text,
					TextSize = 15,
					Size = UDim2.new(1, 0, 0, 26),
					Position = UDim2.new(0, 0, 0, 2),
					ZIndex = 5,
					Parent = ButtonFrame
				})
				AddCorner(Button, 5)
				local ButtonStroke = AddStroke(Button, Theme.Border)

				local ClickEffect = Create("Frame", {
					Name = "ClickEffect",
					BackgroundColor3 = Theme.Accent,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 0, 0),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					ZIndex = 6,
					Parent = Button
				})
				AddCorner(ClickEffect, 100)

				local isHovering = false

				Button.MouseEnter:Connect(function()
					if isHovering then return end
					isHovering = true

					Tween(Button, {BackgroundColor3 = Theme.Hover}, 0.2)
					Tween(ButtonStroke, {Color = Theme.Accent}, 0.2)
				end)

				Button.MouseLeave:Connect(function()
					if not isHovering then return end
					isHovering = false

					Tween(Button, {BackgroundColor3 = Theme.TabFrame}, 0.2)
					Tween(ButtonStroke, {Color = Theme.Border}, 0.2)
				end)

				Button.MouseButton1Click:Connect(function()
					ClickEffect.Size = UDim2.new(0, 0, 0, 0)
					ClickEffect.BackgroundTransparency = 0.7

					Tween(ClickEffect, {
						Size = UDim2.new(2, 0, 2, 0),
						BackgroundTransparency = 1
					}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

					callback()
				end)

				Button.MouseButton1Down:Connect(function()
					Tween(Button, {BackgroundColor3 = Theme.AccentDark}, 0.1)
				end)

				Button.MouseButton1Up:Connect(function()
					Tween(Button, {BackgroundColor3 = isHovering and Theme.Hover or Theme.TabFrame}, 0.1)
				end)

				local ButtonObj = {
					Frame = ButtonFrame,
					Button = Button,
					SetText = function(_, text)
						Button.Text = text
					end,
					SetCallback = function(_, newCallback)
						callback = newCallback or function() end
					end
				}

				task.defer(UpdateSectionSize)
				return ButtonObj
			end

			function Section:CreateLabel(text, subtab)
				subtab = subtab or Section.CurrentSubtab
				local parentContent = Section.SubtabContents[subtab] and Section.SubtabContents[subtab].Content or GetCurrentContent()

				local LabelEl = Create("TextLabel", {
					Name = "Label",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = text,
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, 0, 0, 18),
					ZIndex = 4,
					Parent = parentContent
				})
				AddContextualStroke(LabelEl)

				task.defer(UpdateSectionSize)
				return {
					Set = function(_, newText)
						LabelEl.Text = newText
					end,
					Frame = LabelEl
				}
			end

			function Section:CreateTextbox(options)
				options = options or {}
				local textboxName = options.Name or "Textbox"
				local default = options.Default or ""
				local placeholder = options.Placeholder or "..."
				local callback = options.Callback or function() end
				local subtab = options.Subtab or Section.CurrentSubtab

				local Textbox = {}
				Textbox.Value = default

				local parentContent = Section.SubtabContents[subtab] and Section.SubtabContents[subtab].Content or GetCurrentContent()

				local TextboxFrame = Create("Frame", {
					Name = textboxName,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					ZIndex = 4,
					Parent = parentContent
				})

				local Label = Create("TextLabel", {
					Name = "Name",
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = textboxName,
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(0.4, 0, 1, 0),
					ZIndex = 5,
					Parent = TextboxFrame
				})
				AddContextualStroke(Label)

				local Input = Create("TextBox", {
					Name = "Input",
					BackgroundColor3 = Theme.Tertiary,
					FontFace = Fonts.Inconsolata,
					PlaceholderText = placeholder,
					PlaceholderColor3 = Theme.TextDark,
					Text = default,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(0.58, 0, 0, 22),
					Position = UDim2.new(0.42, 0, 0, 0),
					ZIndex = 5,
					Parent = TextboxFrame
				})
				AddCorner(Input, 5)
				AddStroke(Input, Theme.Border)
				Create("UIPadding", {
					PaddingLeft = UDim.new(0, 6),
					Parent = Input
				})

				Input.FocusLost:Connect(function(enterPressed)
					Textbox.Value = Input.Text
					callback(Input.Text, enterPressed)
				end)

				function Textbox:Set(value)
					Textbox.Value = value
					Input.Text = value
				end

				Textbox.Frame = TextboxFrame

				task.defer(UpdateSectionSize)
				return Textbox
			end

			table.insert(Tab.Sections, Section)
			return Section
		end

		if #Window.Tabs == 0 then
			task.defer(function()
				task.wait(0.1)
				local btnPos = TabButton.AbsolutePosition
				local containerPos = TabContainer.AbsolutePosition
				TabHover.Position = UDim2.new(0, btnPos.X - containerPos.X + 60, 0, 40)
				TabHover.Size = UDim2.new(0, TabButton.AbsoluteSize.X, 0, 2)
			end)
		end

		table.insert(Window.Tabs, Tab)
		return Tab
	end

	function Window:CreatePlayerList(options)
		options = options or {}
		local side = options.Side or "right"
		local gap = options.Gap or 10
		local linkedTab = options.Tab or nil
		local onSpectate = options.OnSpectate or function() end
		local onTeleport = options.OnTeleport or function() end

		local PlayerList = {}
		PlayerList.SelectedPlayer = nil
		PlayerList.Tab = linkedTab

		local PlayerListFrame = Create("Frame", {
			Name = "Players",
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Size = UDim2.new(0, 270, 0, 470),
			Visible = false,
			Parent = ScreenGui
		})
		AddCorner(PlayerListFrame, 5)
		AddStroke(PlayerListFrame, Theme.Border)

		local function UpdatePosition()
			local windowPos = MainWindow.AbsolutePosition
			local windowSize = MainWindow.AbsoluteSize
			local listSize = PlayerListFrame.AbsoluteSize

			if side == "right" then
				PlayerListFrame.Position = UDim2.new(
					0, windowPos.X + windowSize.X + gap,
					0, windowPos.Y
				)
			else
				PlayerListFrame.Position = UDim2.new(
					0, windowPos.X - listSize.X - gap,
					0, windowPos.Y
				)
			end
		end

		MainWindow:GetPropertyChangedSignal("Position"):Connect(UpdatePosition)
		MainWindow:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePosition)
		task.defer(UpdatePosition)

		AddGradientLine(PlayerListFrame, UDim2.new(0, 0, 0.069, 0), UDim2.new(1, 0, 0, 2))

		local SearchContainer = Create("Frame", {
			Name = "Searchbox",
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
			BorderSizePixel = 0,
			Size = UDim2.new(0, 247, 0, 25),
			Position = UDim2.new(0.039, 0, 0.086, 0),
			Parent = PlayerListFrame
		})
		AddCorner(SearchContainer, 4)
		AddStroke(SearchContainer, Theme.Border)

		Create("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(174, 174, 175),
			Image = "rbxassetid://128625562276776",
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(0, 5, 0.5, -9),
			Parent = SearchContainer
		})

		local SearchBox = Create("TextBox", {
			Name = "Input",
			BackgroundTransparency = 1,
			FontFace = Fonts.Inconsolata,
			PlaceholderText = "search",
			PlaceholderColor3 = Theme.TextDark,
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -30, 1, 0),
			Position = UDim2.new(0, 28, 0, 0),
			Parent = SearchContainer
		})

		local ListSection = Create("Frame", {
			Name = "List",
			BackgroundColor3 = Theme.TabFrame,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 246, 0, 212),
			Position = UDim2.new(0.035, 0, 0.163, 0),
			Parent = PlayerListFrame
		})
		AddCorner(ListSection, 4)
		AddStroke(ListSection, Theme.Border)

		local ListHeader = Create("TextLabel", {
			Name = "TabName",
			BackgroundTransparency = 1,
			FontFace = Fonts.Inconsolata,
			Text = "player list",
			TextColor3 = Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -10, 0, 21),
			Position = UDim2.new(0.026, 0, 0.008, 0),
			Parent = ListSection
		})
		AddContextualStroke(ListHeader)

		AddGradientLine(ListSection, UDim2.new(0, 0, 0.129, 0), UDim2.new(1, 0, 0, 2))

		local ListScroll = Create("ScrollingFrame", {
			Name = "Layout",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -2, 0, 184),
			Position = UDim2.new(0, 0, 0.145, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Accent,
			ScrollBarImageTransparency = 0.5,
			Parent = ListSection
		})

		Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ListScroll
		})

		local DetailSection = Create("Frame", {
			Name = "Detail",
			BackgroundColor3 = Theme.TabFrame,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Size = UDim2.new(0, 246, 0, 121),
			Position = UDim2.new(0.035, 0, 0.647, 0),
			Parent = PlayerListFrame
		})
		AddCorner(DetailSection, 4)
		AddStroke(DetailSection, Theme.Border)

		local DetailHeader = Create("TextLabel", {
			Name = "TabName",
			BackgroundTransparency = 1,
			FontFace = Fonts.Inconsolata,
			Text = "detail",
			TextColor3 = Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -10, 0, 25),
			Position = UDim2.new(0.026, 0, 0.018, 0),
			Parent = DetailSection
		})
		AddContextualStroke(DetailHeader)

		AddGradientLine(DetailSection, UDim2.new(0, 0, 0.228, 0), UDim2.new(1, 0, 0, 2))

		local NameLabel = Create("TextLabel", {
			Name = "name",
			BackgroundTransparency = 1,
			FontFace = Fonts.Inconsolata,
			Text = "name: -",
			TextColor3 = Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0, 238, 0, 21),
			Position = UDim2.new(0.03, 0, 0.291, 0),
			Parent = DetailSection
		})
		AddContextualStroke(NameLabel)

		local DisplayLabel = Create("TextLabel", {
			Name = "display",
			BackgroundTransparency = 1,
			FontFace = Fonts.Inconsolata,
			Text = "display: -",
			TextColor3 = Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0, 238, 0, 21),
			Position = UDim2.new(0.034, 0, 0.459, 0),
			Parent = DetailSection
		})
		AddContextualStroke(DisplayLabel)

		local UserIdLabel = Create("TextLabel", {
			Name = "userid",
			BackgroundTransparency = 1,
			FontFace = Fonts.Inconsolata,
			Text = "userid: -",
			TextColor3 = Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0, 238, 0, 21),
			Position = UDim2.new(0.034, 0, 0.619, 0),
			Parent = DetailSection
		})
		AddContextualStroke(UserIdLabel)

		local SpectateBtn = Create("TextButton", {
			Name = "Spectate",
			BackgroundColor3 = Theme.TabFrame,
			FontFace = Fonts.SourceSans,
			Text = "spectate",
			TextColor3 = Theme.Text,
			TextSize = 17,
			Size = UDim2.new(0, 100, 0, 25),
			Position = UDim2.new(0.032, 0, 1.068, 0),
			Parent = DetailSection
		})
		AddCorner(SpectateBtn, 4)
		AddStroke(SpectateBtn, Theme.Border)
		AddContextualStroke(SpectateBtn)

		local TeleportBtn = Create("TextButton", {
			Name = "Teleport",
			BackgroundColor3 = Theme.TabFrame,
			FontFace = Fonts.SourceSans,
			Text = "teleport",
			TextColor3 = Theme.Text,
			TextSize = 17,
			Size = UDim2.new(0, 100, 0, 25),
			Position = UDim2.new(0.541, 0, 1.068, 0),
			Parent = DetailSection
		})
		AddCorner(TeleportBtn, 4)
		AddStroke(TeleportBtn, Theme.Border)
		AddContextualStroke(TeleportBtn)

		for _, btn in pairs({SpectateBtn, TeleportBtn}) do
			btn.MouseEnter:Connect(function()
				Tween(btn, {BackgroundColor3 = Theme.Hover}, 0.1)
			end)
			btn.MouseLeave:Connect(function()
				Tween(btn, {BackgroundColor3 = Theme.TabFrame}, 0.1)
			end)
		end

		SpectateBtn.MouseButton1Click:Connect(function()
			if PlayerList.SelectedPlayer then
				onSpectate(PlayerList.SelectedPlayer)
			end
		end)

		TeleportBtn.MouseButton1Click:Connect(function()
			if PlayerList.SelectedPlayer then
				onTeleport(PlayerList.SelectedPlayer)
			end
		end)

		local function CreatePlayerButton(player)
			local displayText = player.DisplayName ~= player.Name 
				and player.DisplayName .. " (" .. player.Name .. ")" 
				or player.Name

			local PlayerBtn = Create("TextButton", {
				Name = player.Name,
				BackgroundTransparency = 1,
				FontFace = Fonts.SourceSans,
				Text = displayText,
				TextColor3 = player == LocalPlayer and Theme.Blue or Theme.Text,
				TextSize = 17,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 31),
				Parent = ListScroll
			})
			AddContextualStroke(PlayerBtn)
			Create("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				Parent = PlayerBtn
			})

			PlayerBtn.MouseEnter:Connect(function()
				if PlayerList.SelectedPlayer ~= player then
					Tween(PlayerBtn, {BackgroundTransparency = 0.8}, 0.1)
					PlayerBtn.BackgroundColor3 = Theme.Hover
				end
			end)
			PlayerBtn.MouseLeave:Connect(function()
				if PlayerList.SelectedPlayer ~= player then
					Tween(PlayerBtn, {BackgroundTransparency = 1}, 0.1)
				end
			end)

			PlayerBtn.MouseButton1Click:Connect(function()
				for _, child in pairs(ListScroll:GetChildren()) do
					if child:IsA("TextButton") then
						child.BackgroundTransparency = 1
						child.TextColor3 = child.Name == LocalPlayer.Name and Theme.Blue or Theme.Text
					end
				end

				PlayerList.SelectedPlayer = player
				PlayerBtn.BackgroundTransparency = 0.7
				PlayerBtn.BackgroundColor3 = Theme.AccentDark
				PlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

				NameLabel.Text = "name: " .. player.Name
				DisplayLabel.Text = "display: " .. player.DisplayName
				UserIdLabel.Text = "userid: " .. player.UserId
			end)

			return PlayerBtn
		end

		local function UpdatePlayers()
			for _, child in pairs(ListScroll:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end

			local searchText = SearchBox.Text:lower()

			for _, player in pairs(Players:GetPlayers()) do
				local matchesSearch = searchText == "" or 
					player.Name:lower():find(searchText) or 
					player.DisplayName:lower():find(searchText)

				if matchesSearch then
					CreatePlayerButton(player)
				end
			end
		end

		SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdatePlayers)
		UpdatePlayers()

		Players.PlayerAdded:Connect(UpdatePlayers)
		Players.PlayerRemoving:Connect(function(player)
			if PlayerList.SelectedPlayer == player then
				PlayerList.SelectedPlayer = nil
				NameLabel.Text = "name: -"
				DisplayLabel.Text = "display: -"
				UserIdLabel.Text = "userid: -"
			end
			UpdatePlayers()
		end)

		PlayerList.Frame = PlayerListFrame

		function PlayerList:Refresh() UpdatePlayers() end
		function PlayerList:Toggle(visible) PlayerListFrame.Visible = visible end
		function PlayerList:GetSelected() return PlayerList.SelectedPlayer end
		function PlayerList:SetSide(newSide) 
			side = newSide 
			UpdatePosition() 
		end
		function PlayerList:SetTab(tab)
			PlayerList.Tab = tab
			UpdatePlayerListsVisibility()
		end

		table.insert(Window.PlayerLists, PlayerList)
		task.defer(UpdatePlayerListsVisibility)

		return PlayerList
	end

	function Window:CreateWatermark(options)
		options = options or {}
		local wmTitle = options.Title or "Yerba"
		local wmSubtitle = options.Subtitle or "with<3"
        local wmLogo = Yerba.Logo or Window.Logo

		local TextService = game:GetService("TextService")

		local titleSize = TextService:GetTextBoundsAsync(
			Create("GetTextBoundsParams", {
				Text = wmTitle,
				Font = Fonts.ComicNeue,
				Size = 20,
				Width = 1000
			})
		)

		local subtitleSize = TextService:GetTextBoundsAsync(
			Create("GetTextBoundsParams", {
				Text = wmSubtitle,
				Font = Fonts.ComicNeue,
				Size = 20,
				Width = 1000
			})
		)

		local iconWidth = 38
		local dividerWidth = 10
		local padding = 5

		local titleWidth = titleSize.X + padding * 2
		local subtitleWidth = subtitleSize.X + padding * 2
		local fpsWidth = 70

		local totalWidth = iconWidth + dividerWidth + titleWidth + dividerWidth + subtitleWidth + dividerWidth + fpsWidth

		local Watermark = Create("Frame", {
			Name = "Watermark",
			BackgroundColor3 = Theme.Tertiary,
			BorderSizePixel = 0,
			Size = UDim2.new(0, totalWidth, 0, 36),
			Position = UDim2.new(0, 10, 0, 10),
			Parent = ScreenGui
		})
		AddCorner(Watermark, 4)
		AddStroke(Watermark, Color3.fromRGB(47, 61, 67))

		Create("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Image = wmLogo,
			Size = UDim2.new(0, 34, 0, 34),
			Position = UDim2.new(0, 1, 0, 1),
			Parent = Watermark
		})

		local slash1X = iconWidth
		local titleX = slash1X + dividerWidth
		local slash2X = titleX + titleWidth
		local subtitleX = slash2X + dividerWidth
		local slash3X = subtitleX + subtitleWidth
		local fpsX = slash3X + dividerWidth

		local slashPositions = {slash1X, slash2X, slash3X}

		for i, x in ipairs(slashPositions) do
			AddSlash(Watermark, x, 1)
		end

		local NameLabel = Create("TextLabel", {
			Name = "Name",
			BackgroundTransparency = 1,
			FontFace = Fonts.ComicNeue,
			Text = wmTitle,
			TextColor3 = Theme.TextDark,
			TextSize = 20,
			Size = UDim2.new(0, titleWidth, 1, 0),
			Position = UDim2.new(0, titleX, 0, 0),
			Parent = Watermark
		})

		local SubtitleLabel = Create("TextLabel", {
			Name = "Creator",
			BackgroundTransparency = 1,
			FontFace = Fonts.ComicNeue,
			Text = wmSubtitle,
			TextColor3 = Theme.TextDark,
			TextSize = 20,
			Size = UDim2.new(0, subtitleWidth, 1, 0),
			Position = UDim2.new(0, subtitleX, 0, 0),
			Parent = Watermark
		})

		local FPSLabel = Create("TextLabel", {
			Name = "FPS",
			BackgroundTransparency = 1,
			FontFace = Fonts.ComicNeue,
			Text = "60 fps",
			TextColor3 = Theme.TextDark,
			TextSize = 20,
			Size = UDim2.new(0, fpsWidth, 1, 0),
			Position = UDim2.new(0, fpsX, 0, 0),
			Parent = Watermark
		})

		local lastTime = tick()
		local frameCount = 0
		RunService.RenderStepped:Connect(function()
			frameCount = frameCount + 1
			if tick() - lastTime >= 1 then
				FPSLabel.Text = math.floor(frameCount) .. " fps"
				frameCount = 0
				lastTime = tick()
			end
		end)

		local wmDragging, wmDragInput, wmDragStart, wmStartPos
		Watermark.InputBegan:Connect(function(input)
			if IsTouchOrMouse1(input) then
				wmDragging = true
				wmDragStart = input.Position
				wmStartPos = Watermark.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						wmDragging = false
					end
				end)
			end
		end)
		Watermark.InputChanged:Connect(function(input)
			if IsTouchOrMouseMove(input) then
				wmDragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == wmDragInput and wmDragging then
				local delta = input.Position - wmDragStart
				Watermark.Position = UDim2.new(
					wmStartPos.X.Scale, wmStartPos.X.Offset + delta.X,
					wmStartPos.Y.Scale, wmStartPos.Y.Offset + delta.Y
				)
			end
		end)

		return {
			SetTitle = function(_, t) 
				NameLabel.Text = t 
			end,
			SetSubtitle = function(_, s) 
				SubtitleLabel.Text = s 
			end,
			Toggle = function(_, vis) 
				Watermark.Visible = vis 
			end
		}
	end

	function Window:CreateKeybindsDisplay()
		local KeybindsFrame = Create("Frame", {
			Name = "Keybinds",
			BackgroundColor3 = Theme.Tertiary,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.new(0, 160, 0, 40),
			Position = UDim2.new(1, -170, 0, 10),
			Parent = ScreenGui
		})
		AddCorner(KeybindsFrame, 2)
		AddStroke(KeybindsFrame, Theme.BorderAccent)

		local Header = Create("TextLabel", {
			Name = "Name",
			BackgroundTransparency = 1,
			FontFace = Fonts.Inconsolata,
			Text = "  keybinds",
			TextColor3 = Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 28),
			Parent = KeybindsFrame
		})
		AddGradientLine(KeybindsFrame, UDim2.new(0, 0, 0, 28), UDim2.new(1, 0, 0, 1))

		local Main = Create("Frame", {
			Name = "Main",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, -32),
			Position = UDim2.new(0, 0, 0, 30),
			Parent = KeybindsFrame
		})

		local ListLayout = Create("UIListLayout", {
			Padding = UDim.new(0, 2),
			Parent = Main
		})

		local kbDragging, kbDragInput, kbDragStart, kbStartPos
		Header.InputBegan:Connect(function(input)
			if IsTouchOrMouse1(input) then
				kbDragging = true
				kbDragStart = input.Position
				kbStartPos = KeybindsFrame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						kbDragging = false
					end
				end)
			end
		end)
		Header.InputChanged:Connect(function(input)
			if IsTouchOrMouseMove(input) then
				kbDragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == kbDragInput and kbDragging then
				local delta = input.Position - kbDragStart
				KeybindsFrame.Position = UDim2.new(
					kbStartPos.X.Scale, kbStartPos.X.Offset + delta.X,
					kbStartPos.Y.Scale, kbStartPos.Y.Offset + delta.Y
				)
			end
		end)

		local function UpdateSize()
			local h = ListLayout.AbsoluteContentSize.Y + 36
			KeybindsFrame.Size = UDim2.new(0, 160, 0, math.max(40, h))
		end

		return {
			AddKeybind = function(_, kbName, key, mode)
				mode = mode or "tog"
				local Lbl = Create("TextLabel", {
					Name = kbName,
					BackgroundTransparency = 1,
					FontFace = Fonts.Inconsolata,
					Text = string.format(" [%s] %s - %s", mode, kbName, key),
					TextColor3 = Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, 0, 0, 20),
					Parent = Main
				})
				AddContextualStroke(Lbl)
				task.defer(UpdateSize)
				return {
					Remove = function()
						Lbl:Destroy()
						task.defer(UpdateSize)
					end,
					Update = function(_, newKey, newMode)
						Lbl.Text = string.format(" [%s] %s - %s", newMode or mode, kbName, newKey or key)
					end
				}
			end,
			Toggle = function(_, vis) KeybindsFrame.Visible = vis end
		}
	end

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.RightShift then
			ToggleWindow(not Window.Visible)
		end
	end)

	-- Mobile toggle button (visible only on touch devices)
	if IsMobile then
		local MobileToggleBtn = Create("TextButton", {
			Name = "MobileToggle",
			BackgroundColor3 = Theme.TopBar,
			BorderSizePixel = 0,
			Text = "☰",
			FontFace = Fonts.Inconsolata,
			TextColor3 = Theme.Text,
			TextSize = 20,
			Size = UDim2.new(0, 44, 0, 44),
			Position = UDim2.new(0, 8, 1, -52),
			ZIndex = 200,
			Parent = ScreenGui
		})
		AddCorner(MobileToggleBtn, 8)
		AddStroke(MobileToggleBtn, Theme.BorderAccent)

		MobileToggleBtn.MouseButton1Click:Connect(function()
			ToggleWindow(not Window.Visible)
		end)
	end

	function Window:Toggle(show)
		ToggleWindow(show)
	end

	function Window:Destroy()
		ScreenGui:Destroy()
	end

	table.insert(Yerba.Windows, Window)

	return Window
end

return Yerba
