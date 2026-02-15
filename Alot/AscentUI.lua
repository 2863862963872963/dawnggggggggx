--[[
	Ascent UI Library for Roblox
	Version: 1.0.0
	
	Features:
	- Modern glassmorphic design
	- Full mobile support with touch gestures
	- DPI scaling for all screen sizes
	- Lucide icon support
	- Customizable themes
	- Comprehensive API
	
	Usage:
		local AscentUI = loadstring(game:HttpGet("..."))()
		local window = AscentUI:CreateWindow({
			Title = "My Application",
			Subtitle = "Advanced Utility",
			Size = UDim2.new(0, 1100, 0, 720)
		})
]]

local AscentUI = {}
AscentUI.__index = AscentUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Constants
local MOBILE_BREAKPOINT = 768
local TABLET_BREAKPOINT = 1024

-- Theme Configuration
local Theme = {
	Colors = {
		Primary = Color3.fromRGB(0, 212, 255),
		PrimaryDark = Color3.fromRGB(0, 153, 204),
		Danger = Color3.fromRGB(255, 71, 87),
		Success = Color3.fromRGB(46, 213, 115),
		Warning = Color3.fromRGB(255, 165, 2),
		
		GlassSidebar = Color3.fromRGB(15, 15, 25),
		GlassMain = Color3.fromRGB(20, 20, 35),
		GlassCard = Color3.fromRGB(30, 30, 50),
		GlassBorder = Color3.fromRGB(255, 255, 255),
		
		TextMain = Color3.fromRGB(232, 232, 240),
		TextMuted = Color3.fromRGB(136, 136, 168),
		TextDim = Color3.fromRGB(85, 85, 112),
		
		Background1 = Color3.fromRGB(15, 12, 41),
		Background2 = Color3.fromRGB(48, 43, 99),
		Background3 = Color3.fromRGB(36, 36, 62)
	},
	
	Transparency = {
		GlassSidebar = 0.15,
		GlassMain = 0.25,
		GlassCard = 0.4,
		GlassBorder = 0.9
	},
	
	Animations = {
		Fast = 0.15,
		Normal = 0.25,
		Slow = 0.35
	}
}

-- Lucide Icons (subset - add more as needed)
local Icons = {
	Home = "rbxassetid://10734950309",
	Target = "rbxassetid://10747372992",
	Eye = "rbxassetid://10747318883",
	Crosshair = "rbxassetid://10734896389",
	Settings = "rbxassetid://10734950309",
	Shield = "rbxassetid://10747374131",
	Users = "rbxassetid://10747373176",
	FileText = "rbxassetid://10747318893",
	Download = "rbxassetid://10734896209",
	Upload = "rbxassetid://10734950309",
	Plus = "rbxassetid://10734896784",
	Trash = "rbxassetid://10747373176",
	Edit = "rbxassetid://10734896209",
	ChevronRight = "rbxassetid://10734896209",
	Info = "rbxassetid://10747318883",
	Warning = "rbxassetid://10747318883",
	X = "rbxassetid://10747373176",
	Check = "rbxassetid://10734896784"
}

-- Utility Functions
local Utils = {}

function Utils.IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utils.IsTablet()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	return Utils.IsMobile() and viewportSize.X >= MOBILE_BREAKPOINT
end

function Utils.GetDPIScale()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local baseWidth = 1920
	local scale = math.clamp(viewportSize.X / baseWidth, 0.5, 2)
	return scale
end

function Utils.GetTextScale()
	local isMobile = Utils.IsMobile() and not Utils.IsTablet()
	return isMobile and 0.9 or 1
end

function Utils.ScaleText(baseSize)
	return math.floor(baseSize * Utils.GetTextScale())
end

function Utils.ScaleUDim2(udim2, scale)
	return UDim2.new(
		udim2.X.Scale,
		udim2.X.Offset * scale,
		udim2.Y.Scale,
		udim2.Y.Offset * scale
	)
end

function Utils.Tween(instance, properties, duration, easingStyle, easingDirection)
	local tweenInfo = TweenInfo.new(
		duration or Theme.Animations.Normal,
		easingStyle or Enum.EasingStyle.Quad,
		easingDirection or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

function Utils.CreateGradient(parent, rotation, colors)
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = rotation or 0
	
	if colors then
		local colorSequence = {}
		for i, colorData in ipairs(colors) do
			table.insert(colorSequence, ColorSequenceKeypoint.new(colorData[1], colorData[2]))
		end
		gradient.Color = ColorSequence.new(colorSequence)
	end
	
	gradient.Parent = parent
	return gradient
end

function Utils.CreateCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = parent
	return corner
end

function Utils.CreateStroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Theme.Colors.GlassBorder
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or Theme.Transparency.GlassBorder
	stroke.Parent = parent
	return stroke
end

function Utils.CreatePadding(parent, padding)
	local uiPadding = Instance.new("UIPadding")
	if typeof(padding) == "number" then
		uiPadding.PaddingTop = UDim.new(0, padding)
		uiPadding.PaddingBottom = UDim.new(0, padding)
		uiPadding.PaddingLeft = UDim.new(0, padding)
		uiPadding.PaddingRight = UDim.new(0, padding)
	elseif typeof(padding) == "table" then
		uiPadding.PaddingTop = UDim.new(0, padding.Top or 0)
		uiPadding.PaddingBottom = UDim.new(0, padding.Bottom or 0)
		uiPadding.PaddingLeft = UDim.new(0, padding.Left or 0)
		uiPadding.PaddingRight = UDim.new(0, padding.Right or 0)
	end
	uiPadding.Parent = parent
	return uiPadding
end

-- Component Builders
local Components = {}

function Components.CreateIcon(parent, iconName, size, color)
	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, size or 20, 0, size or 20)
	icon.BackgroundTransparency = 1
	icon.Image = Icons[iconName] or Icons.Home
	icon.ImageColor3 = color or Theme.Colors.TextMain
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Parent = parent
	return icon
end

function Components.CreateButton(parent, text, icon, style)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 120, 0, 40)
	button.BackgroundColor3 = style == "primary" and Theme.Colors.Primary or Theme.Colors.GlassCard
	button.BackgroundTransparency = style == "primary" and 0 or 0.4
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = parent
	
	Utils.CreateCorner(button, 10)
	
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = button
	
	if icon then
		Components.CreateIcon(button, icon, 18, style == "primary" and Color3.new(1, 1, 1) or Theme.Colors.TextMain)
	end
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 0, 1, 0)
	label.AutomaticSize = Enum.AutomaticSize.X
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextColor3 = style == "primary" and Color3.new(1, 1, 1) or Theme.Colors.TextMain
	label.Parent = button
	
	-- Hover effect
	button.MouseEnter:Connect(function()
		Utils.Tween(button, {
			BackgroundColor3 = style == "primary" and Theme.Colors.PrimaryDark or Theme.Colors.GlassCard
		}, Theme.Animations.Fast)
	end)
	
	button.MouseLeave:Connect(function()
		Utils.Tween(button, {
			BackgroundColor3 = style == "primary" and Theme.Colors.Primary or Theme.Colors.GlassCard
		}, Theme.Animations.Fast)
	end)
	
	return button
end

function Components.CreateToggle(parent, initialState)
	local toggle = Instance.new("Frame")
	toggle.Size = UDim2.new(0, 48, 0, 26)
	toggle.BackgroundColor3 = initialState and Theme.Colors.Primary or Theme.Colors.GlassCard
	toggle.BackgroundTransparency = 0.3
	toggle.Parent = parent
	
	Utils.CreateCorner(toggle, 13)
	
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 20, 0, 20)
	knob.Position = initialState and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.Parent = toggle
	
	Utils.CreateCorner(knob, 10)
	
	local state = initialState
	local clickDetector = Instance.new("TextButton")
	clickDetector.Size = UDim2.new(1, 0, 1, 0)
	clickDetector.BackgroundTransparency = 1
	clickDetector.Text = ""
	clickDetector.Parent = toggle
	
	local toggleObject = {
		State = state,
		Changed = Instance.new("BindableEvent"),
		Frame = toggle
	}
	
	clickDetector.MouseButton1Click:Connect(function()
		state = not state
		toggleObject.State = state
		
		Utils.Tween(knob, {
			Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
		}, Theme.Animations.Fast, Enum.EasingStyle.Back)
		
		Utils.Tween(toggle, {
			BackgroundColor3 = state and Theme.Colors.Primary or Theme.Colors.GlassCard
		}, Theme.Animations.Fast)
		
		toggleObject.Changed:Fire(state)
	end)
	
	function toggleObject:SetState(newState)
		if state ~= newState then
			clickDetector.MouseButton1Click:Fire()
		end
	end
	
	return toggleObject
end

function Components.CreateSlider(parent, min, max, default, step)
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Size = UDim2.new(1, 0, 0, 40)
	sliderFrame.BackgroundTransparency = 1
	sliderFrame.Parent = parent
	
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 0, 6)
	track.Position = UDim2.new(0, 0, 0.5, -3)
	track.BackgroundColor3 = Theme.Colors.GlassCard
	track.BackgroundTransparency = 0.3
	track.Parent = sliderFrame
	
	Utils.CreateCorner(track, 3)
	
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Theme.Colors.Primary
	fill.Parent = track
	
	Utils.CreateCorner(fill, 3)
	
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = UDim2.new(0, -9, 0.5, -9)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.Parent = track
	
	Utils.CreateCorner(knob, 9)
	Utils.CreateStroke(knob, Theme.Colors.Primary, 2, 0)
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 1, 0)
	valueLabel.Position = UDim2.new(1, 10, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 14
	valueLabel.TextColor3 = Theme.Colors.Primary
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.Parent = sliderFrame
	
	local value = default
	local dragging = false
	
	local sliderObject = {
		Value = value,
		Changed = Instance.new("BindableEvent"),
		Frame = sliderFrame
	}
	
	local function updateSlider(input)
		local trackSize = track.AbsoluteSize.X
		local relativeX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, trackSize)
		local percentage = relativeX / trackSize
		
		value = min + (max - min) * percentage
		if step then
			value = math.floor(value / step + 0.5) * step
		end
		value = math.clamp(value, min, max)
		
		sliderObject.Value = value
		valueLabel.Text = string.format("%.2f", value)
		
		fill.Size = UDim2.new(percentage, 0, 1, 0)
		knob.Position = UDim2.new(percentage, -9, 0.5, -9)
		
		sliderObject.Changed:Fire(value)
	end
	
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateSlider(input)
		end
	end)
	
	track.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)
	
	-- Initialize
	local initialPercentage = (default - min) / (max - min)
	fill.Size = UDim2.new(initialPercentage, 0, 1, 0)
	knob.Position = UDim2.new(initialPercentage, -9, 0.5, -9)
	
	function sliderObject:SetValue(newValue)
		value = math.clamp(newValue, min, max)
		sliderObject.Value = value
		valueLabel.Text = string.format("%.2f", value)
		
		local percentage = (value - min) / (max - min)
		Utils.Tween(fill, {Size = UDim2.new(percentage, 0, 1, 0)}, Theme.Animations.Fast)
		Utils.Tween(knob, {Position = UDim2.new(percentage, -9, 0.5, -9)}, Theme.Animations.Fast)
		
		sliderObject.Changed:Fire(value)
	end
	
	return sliderObject
end

function Components.CreateDropdown(parent, options, default)
	local dropdownFrame = Instance.new("Frame")
	dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
	dropdownFrame.BackgroundTransparency = 1
	dropdownFrame.Parent = parent
	
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundColor3 = Theme.Colors.GlassCard
	button.BackgroundTransparency = 0.4
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = dropdownFrame
	
	Utils.CreateCorner(button, 10)
	Utils.CreateStroke(button, Theme.Colors.GlassBorder, 1, Theme.Transparency.GlassBorder)
	Utils.CreatePadding(button, {Left = 15, Right = 15})
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -30, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = default or options[1] or "Select..."
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Theme.Colors.TextMain
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button
	
	local arrow = Components.CreateIcon(button, "ChevronRight", 16, Theme.Colors.TextMuted)
	arrow.Position = UDim2.new(1, -20, 0.5, -8)
	
	local optionsFrame = Instance.new("ScrollingFrame")
	optionsFrame.Size = UDim2.new(1, 0, 0, math.min(#options * 40, 200))
	optionsFrame.Position = UDim2.new(0, 0, 1, 5)
	optionsFrame.BackgroundColor3 = Theme.Colors.GlassCard
	optionsFrame.BackgroundTransparency = 0.1
	optionsFrame.BorderSizePixel = 0
	optionsFrame.ScrollBarThickness = 4
	optionsFrame.ScrollBarImageColor3 = Theme.Colors.Primary
	optionsFrame.Visible = false
	optionsFrame.ZIndex = 10
	optionsFrame.Parent = dropdownFrame
	
	Utils.CreateCorner(optionsFrame, 10)
	Utils.CreateStroke(optionsFrame, Theme.Colors.GlassBorder, 1, Theme.Transparency.GlassBorder)
	
	local optionsLayout = Instance.new("UIListLayout")
	optionsLayout.Padding = UDim.new(0, 2)
	optionsLayout.Parent = optionsFrame
	
	local selected = default or options[1]
	local dropdownObject = {
		Value = selected,
		Changed = Instance.new("BindableEvent"),
		Frame = dropdownFrame
	}
	
	for _, option in ipairs(options) do
		local optionButton = Instance.new("TextButton")
		optionButton.Size = UDim2.new(1, 0, 0, 40)
		optionButton.BackgroundColor3 = Theme.Colors.GlassCard
		optionButton.BackgroundTransparency = option == selected and 0.3 or 1
		optionButton.Text = option
		optionButton.Font = Enum.Font.Gotham
		optionButton.TextSize = 14
		optionButton.TextColor3 = option == selected and Theme.Colors.Primary or Theme.Colors.TextMain
		optionButton.TextXAlignment = Enum.TextXAlignment.Left
		optionButton.AutoButtonColor = false
		optionButton.Parent = optionsFrame
		
		Utils.CreatePadding(optionButton, {Left = 15, Right = 15})
		
		optionButton.MouseEnter:Connect(function()
			if option ~= selected then
				Utils.Tween(optionButton, {BackgroundTransparency = 0.7}, Theme.Animations.Fast)
			end
		end)
		
		optionButton.MouseLeave:Connect(function()
			if option ~= selected then
				Utils.Tween(optionButton, {BackgroundTransparency = 1}, Theme.Animations.Fast)
			end
		end)
		
		optionButton.MouseButton1Click:Connect(function()
			selected = option
			dropdownObject.Value = selected
			label.Text = selected
			
			-- Update all option buttons
			for _, child in ipairs(optionsFrame:GetChildren()) do
				if child:IsA("TextButton") then
					child.BackgroundTransparency = child.Text == selected and 0.3 or 1
					child.TextColor3 = child.Text == selected and Theme.Colors.Primary or Theme.Colors.TextMain
				end
			end
			
			optionsFrame.Visible = false
			Utils.Tween(arrow, {Rotation = 0}, Theme.Animations.Fast)
			
			dropdownObject.Changed:Fire(selected)
		end)
	end
	
	optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		optionsFrame.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y)
	end)
	
	button.MouseButton1Click:Connect(function()
		optionsFrame.Visible = not optionsFrame.Visible
		Utils.Tween(arrow, {Rotation = optionsFrame.Visible and 90 or 0}, Theme.Animations.Fast)
	end)
	
	function dropdownObject:SetValue(newValue)
		if table.find(options, newValue) then
			selected = newValue
			dropdownObject.Value = selected
			label.Text = selected
			
			for _, child in ipairs(optionsFrame:GetChildren()) do
				if child:IsA("TextButton") then
					child.BackgroundTransparency = child.Text == selected and 0.3 or 1
					child.TextColor3 = child.Text == selected and Theme.Colors.Primary or Theme.Colors.TextMain
				end
			end
			
			dropdownObject.Changed:Fire(selected)
		end
	end
	
	return dropdownObject
end

function Components.CreateColorPicker(parent, defaultColor)
	local pickerFrame = Instance.new("Frame")
	pickerFrame.Size = UDim2.new(0, 40, 0, 40)
	pickerFrame.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255)
	pickerFrame.Parent = parent
	
	Utils.CreateCorner(pickerFrame, 10)
	Utils.CreateStroke(pickerFrame, Theme.Colors.GlassBorder, 2, 0.7)
	
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = pickerFrame
	
	local color = defaultColor or Color3.fromRGB(255, 255, 255)
	local pickerObject = {
		Color = color,
		Changed = Instance.new("BindableEvent"),
		Frame = pickerFrame
	}
	
	button.MouseButton1Click:Connect(function()
		-- Create color picker window (simplified version)
		-- In a full implementation, this would open a full color picker UI
		pickerObject.Changed:Fire(color)
	end)
	
	function pickerObject:SetColor(newColor)
		color = newColor
		pickerObject.Color = color
		Utils.Tween(pickerFrame, {BackgroundColor3 = color}, Theme.Animations.Fast)
		pickerObject.Changed:Fire(color)
	end
	
	return pickerObject
end

-- Window Class
local Window = {}
Window.__index = Window

function Window:CreateTab(config)
	local tab = {
		Name = config.Name or "Tab",
		Icon = config.Icon or "Home",
		Window = self,
		Sections = {},
		Active = false
	}
	
	-- Create navigation item
	local navItem = Instance.new("TextButton")
	navItem.Size = UDim2.new(1, 0, 0, 50)
	navItem.BackgroundColor3 = Theme.Colors.GlassCard
	navItem.BackgroundTransparency = 1
	navItem.Text = ""
	navItem.AutoButtonColor = false
	navItem.Parent = self.NavGroup
	
	Utils.CreateCorner(navItem, 12)
	
	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 3, 0, 0)
	indicator.Position = UDim2.new(0, 0, 0.5, 0)
	indicator.AnchorPoint = Vector2.new(0, 0.5)
	indicator.BackgroundColor3 = Theme.Colors.Primary
	indicator.BorderSizePixel = 0
	indicator.Parent = navItem
	
	Utils.CreateCorner(indicator, UDim.new(0, 3))
	
	-- Check if mobile
	local isMobile = Utils.IsMobile() and not Utils.IsTablet()
	
	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, 0, 1, 0)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = navItem
	
	if isMobile then
		-- Mobile: Center icon only
		local icon = Components.CreateIcon(contentFrame, tab.Icon, 24, Theme.Colors.TextMain)
		icon.Position = UDim2.new(0.5, -12, 0.5, -12)
		tab.IconImage = icon
	else
		-- Desktop: Icon + Text
		Utils.CreatePadding(contentFrame, {Left = 15, Right = 15})
		
		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Padding = UDim.new(0, 12)
		layout.Parent = contentFrame
		
		local icon = Components.CreateIcon(contentFrame, tab.Icon, 20, Theme.Colors.TextMain)
		tab.IconImage = icon
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0, 0, 1, 0)
		label.AutomaticSize = Enum.AutomaticSize.X
		label.BackgroundTransparency = 1
		label.Text = tab.Name
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextColor3 = Theme.Colors.TextMain
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = contentFrame
		tab.LabelText = label
		
		if config.Badge then
			local badge = Instance.new("TextLabel")
			badge.Size = UDim2.new(0, 0, 0, 20)
			badge.AutomaticSize = Enum.AutomaticSize.X
			badge.BackgroundColor3 = Theme.Colors.Danger
			badge.Text = config.Badge
			badge.Font = Enum.Font.GothamBold
			badge.TextSize = 10
			badge.TextColor3 = Color3.new(1, 1, 1)
			badge.Parent = contentFrame
			
			Utils.CreateCorner(badge, 10)
			Utils.CreatePadding(badge, {Left = 8, Right = 8})
		end
	end
	
	-- Create content view
	local view = Instance.new("ScrollingFrame")
	view.Size = UDim2.new(1, 0, 1, 0)
	view.BackgroundTransparency = 1
	view.BorderSizePixel = 0
	view.ScrollBarThickness = 6
	view.ScrollBarImageColor3 = Theme.Colors.Primary
	view.ScrollBarImageTransparency = 0.7
	view.Visible = false
	view.Parent = self.ContentFrame
	
	local isMobile = Utils.IsMobile() and not Utils.IsTablet()
	Utils.CreatePadding(view, isMobile and {Top = 15, Bottom = 15, Left = 15, Right = 15} or {Top = 20, Bottom = 20, Left = 20, Right = 20})
	
	local viewLayout = Instance.new("UIListLayout")
	viewLayout.Padding = UDim.new(0, 20)
	viewLayout.SortOrder = Enum.SortOrder.LayoutOrder
	viewLayout.Parent = view
	
	viewLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		view.CanvasSize = UDim2.new(0, 0, 0, viewLayout.AbsoluteContentSize.Y + 40)
	end)
	
	tab.NavItem = navItem
	tab.View = view
	tab.ViewLayout = viewLayout
	
	-- Navigation click handler
	navItem.MouseButton1Click:Connect(function()
		self:SetActiveTab(tab)
	end)
	
	-- Hover effects
	navItem.MouseEnter:Connect(function()
		if not tab.Active then
			Utils.Tween(navItem, {BackgroundTransparency = 0.9}, Theme.Animations.Fast)
		end
	end)
	
	navItem.MouseLeave:Connect(function()
		if not tab.Active then
			Utils.Tween(navItem, {BackgroundTransparency = 1}, Theme.Animations.Fast)
		end
	end)
	
	function tab:CreateSection(sectionConfig)
		local section = {
			Title = sectionConfig.Title or "Section",
			Icon = sectionConfig.Icon or "Settings",
			IconColor = sectionConfig.IconColor or "primary",
			Tab = self,
			Elements = {}
		}
		
		local sectionCard = Instance.new("Frame")
		sectionCard.Size = UDim2.new(1, 0, 0, 0)
		sectionCard.AutomaticSize = Enum.AutomaticSize.Y
		sectionCard.BackgroundColor3 = Theme.Colors.GlassCard
		sectionCard.BackgroundTransparency = Theme.Transparency.GlassCard
		sectionCard.LayoutOrder = #self.Sections + 1
		sectionCard.Parent = self.View
		
		Utils.CreateCorner(sectionCard, 12)
		Utils.CreateStroke(sectionCard, Theme.Colors.GlassBorder, 1, Theme.Transparency.GlassBorder)
		
		local cardHeader = Instance.new("Frame")
		cardHeader.Size = UDim2.new(1, 0, 0, 60)
		cardHeader.BackgroundTransparency = 1
		cardHeader.Parent = sectionCard
		
		Utils.CreatePadding(cardHeader, 20)
		
		local headerLayout = Instance.new("UIListLayout")
		headerLayout.FillDirection = Enum.FillDirection.Horizontal
		headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		headerLayout.Padding = UDim.new(0, 12)
		headerLayout.Parent = cardHeader
		
		local iconFrame = Instance.new("Frame")
		iconFrame.Size = UDim2.new(0, 40, 0, 40)
		iconFrame.BackgroundColor3 = section.IconColor == "primary" and Theme.Colors.Primary or 
									  section.IconColor == "danger" and Theme.Colors.Danger or
									  section.IconColor == "success" and Theme.Colors.Success or
									  Theme.Colors.Warning
		iconFrame.BackgroundTransparency = 0.8
		iconFrame.Parent = cardHeader
		
		Utils.CreateCorner(iconFrame, 10)
		
		local iconImage = Components.CreateIcon(iconFrame, section.Icon, 24, 
			section.IconColor == "primary" and Theme.Colors.Primary or 
			section.IconColor == "danger" and Theme.Colors.Danger or
			section.IconColor == "success" and Theme.Colors.Success or
			Theme.Colors.Warning)
		iconImage.Position = UDim2.new(0.5, -12, 0.5, -12)
		
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, -52, 1, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = section.Title
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 16
		titleLabel.TextColor3 = Theme.Colors.TextMain
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Parent = cardHeader
		
		local contentContainer = Instance.new("Frame")
		contentContainer.Size = UDim2.new(1, 0, 0, 0)
		contentContainer.AutomaticSize = Enum.AutomaticSize.Y
		contentContainer.BackgroundTransparency = 1
		contentContainer.Parent = sectionCard
		contentContainer.Position = UDim2.new(0, 0, 0, 60)
		
		Utils.CreatePadding(contentContainer, {Top = 0, Bottom = 20, Left = 20, Right = 20})
		
		local contentLayout = Instance.new("UIListLayout")
		contentLayout.Padding = UDim.new(0, 15)
		contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		contentLayout.Parent = contentContainer
		
		section.Card = sectionCard
		section.Container = contentContainer
		section.Layout = contentLayout
		
		contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			contentContainer.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y)
		end)
		
		function section:AddToggle(config)
			local elementFrame = Instance.new("Frame")
			elementFrame.Size = UDim2.new(1, 0, 0, 50)
			elementFrame.BackgroundTransparency = 1
			elementFrame.LayoutOrder = #self.Elements + 1
			elementFrame.Parent = self.Container
			
			local labelContainer = Instance.new("Frame")
			labelContainer.Size = UDim2.new(1, -60, 1, 0)
			labelContainer.BackgroundTransparency = 1
			labelContainer.Parent = elementFrame
			
			local labelLayout = Instance.new("UIListLayout")
			labelLayout.Padding = UDim.new(0, 4)
			labelLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			labelLayout.Parent = labelContainer
			
			local mainLabel = Instance.new("TextLabel")
			mainLabel.Size = UDim2.new(1, 0, 0, 18)
			mainLabel.BackgroundTransparency = 1
			mainLabel.Text = config.Title or "Toggle"
			mainLabel.Font = Enum.Font.GothamSemibold
			mainLabel.TextSize = 14
			mainLabel.TextColor3 = Theme.Colors.TextMain
			mainLabel.TextXAlignment = Enum.TextXAlignment.Left
			mainLabel.Parent = labelContainer
			
			if config.Description then
				local descLabel = Instance.new("TextLabel")
				descLabel.Size = UDim2.new(1, 0, 0, 14)
				descLabel.BackgroundTransparency = 1
				descLabel.Text = config.Description
				descLabel.Font = Enum.Font.Gotham
				descLabel.TextSize = 12
				descLabel.TextColor3 = Theme.Colors.TextMuted
				descLabel.TextXAlignment = Enum.TextXAlignment.Left
				descLabel.Parent = labelContainer
			end
			
			local toggle = Components.CreateToggle(elementFrame, config.Default or false)
			toggle.Frame.Position = UDim2.new(1, -48, 0.5, -13)
			
			if config.Callback then
				toggle.Changed.Event:Connect(config.Callback)
			end
			
			table.insert(self.Elements, {Type = "Toggle", Element = toggle, Config = config})
			return toggle
		end
		
		function section:AddSlider(config)
			local elementFrame = Instance.new("Frame")
			elementFrame.Size = UDim2.new(1, 0, 0, 70)
			elementFrame.BackgroundTransparency = 1
			elementFrame.LayoutOrder = #self.Elements + 1
			elementFrame.Parent = self.Container
			
			local labelContainer = Instance.new("Frame")
			labelContainer.Size = UDim2.new(1, 0, 0, 20)
			labelContainer.BackgroundTransparency = 1
			labelContainer.Parent = elementFrame
			
			local labelLayout = Instance.new("UIListLayout")
			labelLayout.FillDirection = Enum.FillDirection.Horizontal
			labelLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
			labelLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			labelLayout.Parent = labelContainer
			
			local mainLabel = Instance.new("TextLabel")
			mainLabel.Size = UDim2.new(0.7, 0, 1, 0)
			mainLabel.BackgroundTransparency = 1
			mainLabel.Text = config.Title or "Slider"
			mainLabel.Font = Enum.Font.GothamSemibold
			mainLabel.TextSize = 14
			mainLabel.TextColor3 = Theme.Colors.TextMain
			mainLabel.TextXAlignment = Enum.TextXAlignment.Left
			mainLabel.Parent = labelContainer
			
			local slider = Components.CreateSlider(
				elementFrame,
				config.Min or 0,
				config.Max or 100,
				config.Default or 50,
				config.Step
			)
			slider.Frame.Position = UDim2.new(0, 0, 1, -40)
			slider.Frame.Size = UDim2.new(1, -60, 0, 40)
			
			if config.Callback then
				slider.Changed.Event:Connect(config.Callback)
			end
			
			table.insert(self.Elements, {Type = "Slider", Element = slider, Config = config})
			return slider
		end
		
		function section:AddDropdown(config)
			local elementFrame = Instance.new("Frame")
			elementFrame.Size = UDim2.new(1, 0, 0, 70)
			elementFrame.BackgroundTransparency = 1
			elementFrame.LayoutOrder = #self.Elements + 1
			elementFrame.Parent = self.Container
			
			local mainLabel = Instance.new("TextLabel")
			mainLabel.Size = UDim2.new(1, 0, 0, 20)
			mainLabel.BackgroundTransparency = 1
			mainLabel.Text = config.Title or "Dropdown"
			mainLabel.Font = Enum.Font.GothamSemibold
			mainLabel.TextSize = 14
			mainLabel.TextColor3 = Theme.Colors.TextMain
			mainLabel.TextXAlignment = Enum.TextXAlignment.Left
			mainLabel.Parent = elementFrame
			
			local dropdown = Components.CreateDropdown(
				elementFrame,
				config.Options or {"Option 1", "Option 2"},
				config.Default
			)
			dropdown.Frame.Position = UDim2.new(0, 0, 1, -40)
			
			if config.Callback then
				dropdown.Changed.Event:Connect(config.Callback)
			end
			
			table.insert(self.Elements, {Type = "Dropdown", Element = dropdown, Config = config})
			return dropdown
		end
		
		function section:AddButton(config)
			local elementFrame = Instance.new("Frame")
			elementFrame.Size = UDim2.new(1, 0, 0, 50)
			elementFrame.BackgroundTransparency = 1
			elementFrame.LayoutOrder = #self.Elements + 1
			elementFrame.Parent = self.Container
			
			local button = Components.CreateButton(
				elementFrame,
				config.Title or "Button",
				config.Icon,
				config.Style or "secondary"
			)
			button.Size = UDim2.new(1, 0, 0, 40)
			button.Position = UDim2.new(0.5, 0, 0.5, 0)
			button.AnchorPoint = Vector2.new(0.5, 0.5)
			
			if config.Callback then
				button.MouseButton1Click:Connect(config.Callback)
			end
			
			table.insert(self.Elements, {Type = "Button", Element = button, Config = config})
			return button
		end
		
		function section:AddColorPicker(config)
			local elementFrame = Instance.new("Frame")
			elementFrame.Size = UDim2.new(1, 0, 0, 50)
			elementFrame.BackgroundTransparency = 1
			elementFrame.LayoutOrder = #self.Elements + 1
			elementFrame.Parent = self.Container
			
			local labelContainer = Instance.new("Frame")
			labelContainer.Size = UDim2.new(1, -60, 1, 0)
			labelContainer.BackgroundTransparency = 1
			labelContainer.Parent = elementFrame
			
			local labelLayout = Instance.new("UIListLayout")
			labelLayout.Padding = UDim.new(0, 4)
			labelLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			labelLayout.Parent = labelContainer
			
			local mainLabel = Instance.new("TextLabel")
			mainLabel.Size = UDim2.new(1, 0, 0, 18)
			mainLabel.BackgroundTransparency = 1
			mainLabel.Text = config.Title or "Color"
			mainLabel.Font = Enum.Font.GothamSemibold
			mainLabel.TextSize = 14
			mainLabel.TextColor3 = Theme.Colors.TextMain
			mainLabel.TextXAlignment = Enum.TextXAlignment.Left
			mainLabel.Parent = labelContainer
			
			if config.Description then
				local descLabel = Instance.new("TextLabel")
				descLabel.Size = UDim2.new(1, 0, 0, 14)
				descLabel.BackgroundTransparency = 1
				descLabel.Text = config.Description
				descLabel.Font = Enum.Font.Gotham
				descLabel.TextSize = 12
				descLabel.TextColor3 = Theme.Colors.TextMuted
				descLabel.TextXAlignment = Enum.TextXAlignment.Left
				descLabel.Parent = labelContainer
			end
			
			local colorPicker = Components.CreateColorPicker(elementFrame, config.Default)
			colorPicker.Frame.Position = UDim2.new(1, -40, 0.5, -20)
			
			if config.Callback then
				colorPicker.Changed.Event:Connect(config.Callback)
			end
			
			table.insert(self.Elements, {Type = "ColorPicker", Element = colorPicker, Config = config})
			return colorPicker
		end
		
		function section:AddLabel(config)
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 0)
			label.AutomaticSize = Enum.AutomaticSize.Y
			label.BackgroundTransparency = 1
			label.Text = config.Text or "Label"
			label.Font = Enum.Font.Gotham
			label.TextSize = config.Size or 13
			label.TextColor3 = config.Color or Theme.Colors.TextMuted
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextWrapped = true
			label.LayoutOrder = #self.Elements + 1
			label.Parent = self.Container
			
			table.insert(self.Elements, {Type = "Label", Element = label, Config = config})
			return label
		end
		
		table.insert(self.Sections, section)
		return section
	end
	
	table.insert(self.Tabs, tab)
	
	-- Set first tab as active
	if #self.Tabs == 1 then
		self:SetActiveTab(tab)
	end
	
	return tab
end

function Window:SetActiveTab(tab)
	for _, t in ipairs(self.Tabs) do
		t.Active = false
		t.View.Visible = false
		
		Utils.Tween(t.NavItem, {BackgroundTransparency = 1}, Theme.Animations.Fast)
		Utils.Tween(t.NavItem:FindFirstChild("Frame"), {Size = UDim2.new(0, 3, 0, 0)}, Theme.Animations.Fast)
		
		-- Update icon color
		if t.IconImage then
			Utils.Tween(t.IconImage, {ImageColor3 = Theme.Colors.TextMain}, Theme.Animations.Fast)
		end
		
		-- Update label color if it exists (desktop only)
		if t.LabelText then
			Utils.Tween(t.LabelText, {TextColor3 = Theme.Colors.TextMain}, Theme.Animations.Fast)
		end
	end
	
	tab.Active = true
	tab.View.Visible = true
	
	Utils.Tween(tab.NavItem, {
		BackgroundTransparency = 0.8,
		BackgroundColor3 = Theme.Colors.Primary
	}, Theme.Animations.Fast)
	
	Utils.Tween(tab.NavItem:FindFirstChild("Frame"), {Size = UDim2.new(0, 3, 1, 0)}, Theme.Animations.Fast)
	
	-- Update icon color
	if tab.IconImage then
		Utils.Tween(tab.IconImage, {ImageColor3 = Theme.Colors.Primary}, Theme.Animations.Fast)
	end
	
	-- Update label color if it exists (desktop only)
	if tab.LabelText then
		Utils.Tween(tab.LabelText, {TextColor3 = Theme.Colors.Primary}, Theme.Animations.Fast)
	end
end

function Window:CreateNotification(config)
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 350, 0, 80)
	notif.Position = UDim2.new(1, -370, 1, 100)
	notif.BackgroundColor3 = Theme.Colors.GlassCard
	notif.BackgroundTransparency = 0.1
	notif.ZIndex = 1000
	notif.Parent = self.ScreenGui
	
	Utils.CreateCorner(notif, 12)
	Utils.CreateStroke(notif, Theme.Colors.GlassBorder, 1, Theme.Transparency.GlassBorder)
	Utils.CreatePadding(notif, 15)
	
	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 4, 1, 0)
	accent.Position = UDim2.new(0, -15, 0, -15)
	accent.BackgroundColor3 = config.Type == "success" and Theme.Colors.Success or
							  config.Type == "warning" and Theme.Colors.Warning or
							  config.Type == "error" and Theme.Colors.Danger or
							  Theme.Colors.Primary
	accent.BorderSizePixel = 0
	accent.Parent = notif
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = notif
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 20)
	title.BackgroundTransparency = 1
	title.Text = config.Title or "Notification"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 15
	title.TextColor3 = Theme.Colors.TextMain
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = notif
	
	local message = Instance.new("TextLabel")
	message.Size = UDim2.new(1, 0, 0, 0)
	message.AutomaticSize = Enum.AutomaticSize.Y
	message.BackgroundTransparency = 1
	message.Text = config.Message or ""
	message.Font = Enum.Font.Gotham
	message.TextSize = 13
	message.TextColor3 = Theme.Colors.TextMuted
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextWrapped = true
	message.Parent = notif
	
	-- Animate in
	Utils.Tween(notif, {Position = UDim2.new(1, -370, 1, -100)}, 0.3, Enum.EasingStyle.Back)
	
	-- Auto dismiss
	task.delay(config.Duration or 3, function()
		Utils.Tween(notif, {Position = UDim2.new(1, -370, 1, 100)}, 0.3, Enum.EasingStyle.Back)
		task.wait(0.3)
		notif:Destroy()
	end)
	
	return notif
end

function Window:Destroy()
	self.ScreenGui:Destroy()
end

-- Main Library Functions
function AscentUI:CreateWindow(config)
	local window = setmetatable({}, Window)
	
	-- Create ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AscentUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = game:GetService("CoreGui")
	
	-- Calculate DPI scale
	local dpiScale = Utils.GetDPIScale()
	local isMobile = Utils.IsMobile()
	local isTablet = Utils.IsTablet()
	
	-- Adjust size for mobile
	local windowSize = config.Size or UDim2.new(0, 1100, 0, 720)
	if isMobile and not isTablet then
		windowSize = UDim2.new(0.95, 0, 0.85, 0)
	elseif isTablet then
		windowSize = UDim2.new(0.9, 0, 0.8, 0)
	end
	
	-- Create background
	local background = Instance.new("Frame")
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Theme.Colors.Background1
	background.BorderSizePixel = 0
	background.Parent = screenGui
	
	Utils.CreateGradient(background, 135, {
		{0, Theme.Colors.Background1},
		{0.5, Theme.Colors.Background2},
		{1, Theme.Colors.Background3}
	})
	
	-- Grid pattern
	local gridPattern = Instance.new("Frame")
	gridPattern.Size = UDim2.new(1, 0, 1, 0)
	gridPattern.BackgroundTransparency = 0.97
	gridPattern.BackgroundColor3 = Theme.Colors.Primary
	gridPattern.BorderSizePixel = 0
	gridPattern.Parent = background
	
	-- Main window frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = windowSize
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Theme.Colors.GlassMain
	mainFrame.BackgroundTransparency = Theme.Transparency.GlassMain
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	
	Utils.CreateCorner(mainFrame, 20)
	Utils.CreateStroke(mainFrame, Theme.Colors.GlassBorder, 1, Theme.Transparency.GlassBorder)
	
	-- Sidebar
	local sidebar = Instance.new("Frame")
	sidebar.Size = isMobile and UDim2.new(0, 80, 1, 0) or UDim2.new(0, 260, 1, 0)
	sidebar.BackgroundColor3 = Theme.Colors.GlassSidebar
	sidebar.BackgroundTransparency = Theme.Transparency.GlassSidebar
	sidebar.BorderSizePixel = 0
	sidebar.ClipsDescendants = true
	sidebar.Parent = mainFrame
	
	local sidebarBorder = Instance.new("Frame")
	sidebarBorder.Size = UDim2.new(0, 1, 1, 0)
	sidebarBorder.Position = UDim2.new(1, 0, 0, 0)
	sidebarBorder.BackgroundColor3 = Theme.Colors.GlassBorder
	sidebarBorder.BackgroundTransparency = Theme.Transparency.GlassBorder
	sidebarBorder.BorderSizePixel = 0
	sidebarBorder.Parent = sidebar
	
	-- Brand section
	local brand = Instance.new("Frame")
	brand.Size = UDim2.new(1, 0, 0, isMobile and 70 or 80)
	brand.BackgroundTransparency = 1
	brand.Parent = sidebar
	
	local brandBorder = Instance.new("Frame")
	brandBorder.Size = UDim2.new(1, 0, 0, 1)
	brandBorder.Position = UDim2.new(0, 0, 1, 0)
	brandBorder.BackgroundColor3 = Theme.Colors.GlassBorder
	brandBorder.BackgroundTransparency = Theme.Transparency.GlassBorder
	brandBorder.BorderSizePixel = 0
	brandBorder.Parent = brand
	
	if not isMobile then
		Utils.CreatePadding(brand, {Top = 25, Bottom = 25, Left = 20, Right = 20})
		
		local brandTitle = Instance.new("TextLabel")
		brandTitle.Size = UDim2.new(1, 0, 0, 30)
		brandTitle.BackgroundTransparency = 1
		brandTitle.Text = config.Title or "Ascent"
		brandTitle.Font = Enum.Font.GothamBold
		brandTitle.TextSize = 24
		brandTitle.TextColor3 = Theme.Colors.TextMain
		brandTitle.TextXAlignment = Enum.TextXAlignment.Left
		brandTitle.Parent = brand
		
		Utils.CreateGradient(brandTitle, 135, {
			{0, Theme.Colors.Primary},
			{1, Color3.fromRGB(0, 255, 242)}
		})
		
		local brandSubtitle = Instance.new("TextLabel")
		brandSubtitle.Size = UDim2.new(1, 0, 0, 12)
		brandSubtitle.Position = UDim2.new(0, 0, 1, -12)
		brandSubtitle.BackgroundTransparency = 1
		brandSubtitle.Text = (config.Subtitle or "ADVANCED UTILITY"):upper()
		brandSubtitle.Font = Enum.Font.GothamBold
		brandSubtitle.TextSize = 10
		brandSubtitle.TextColor3 = Theme.Colors.TextMuted
		brandSubtitle.TextXAlignment = Enum.TextXAlignment.Left
		brandSubtitle.Parent = brand
	else
		-- Mobile: Just show centered icon
		local iconContainer = Instance.new("Frame")
		iconContainer.Size = UDim2.new(1, 0, 1, 0)
		iconContainer.BackgroundTransparency = 1
		iconContainer.Parent = brand
		
		local icon = Components.CreateIcon(iconContainer, "Target", 32, Theme.Colors.Primary)
		icon.Position = UDim2.new(0.5, -16, 0.5, -16)
	end
	
	-- Navigation group
	local navGroup = Instance.new("ScrollingFrame")
	navGroup.Size = UDim2.new(1, 0, 1, isMobile and -140 or -160)
	navGroup.Position = UDim2.new(0, 0, 0, isMobile and 70 or 80)
	navGroup.BackgroundTransparency = 1
	navGroup.BorderSizePixel = 0
	navGroup.ScrollBarThickness = 4
	navGroup.ScrollBarImageColor3 = Theme.Colors.Primary
	navGroup.ScrollBarImageTransparency = 0.8
	navGroup.Parent = sidebar
	
	Utils.CreatePadding(navGroup, {Top = 10, Bottom = 10, Left = isMobile and 5 or 10, Right = isMobile and 5 or 10})
	
	local navLayout = Instance.new("UIListLayout")
	navLayout.Padding = UDim.new(0, 3)
	navLayout.SortOrder = Enum.SortOrder.LayoutOrder
	navLayout.Parent = navGroup
	
	navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		navGroup.CanvasSize = UDim2.new(0, 0, 0, navLayout.AbsoluteContentSize.Y + 30)
	end)
	
	-- Status bar
	local statusBar = Instance.new("Frame")
	statusBar.Size = UDim2.new(1, 0, 0, isMobile and 70 or 80)
	statusBar.Position = UDim2.new(0, 0, 1, isMobile and -70 or -80)
	statusBar.BackgroundColor3 = Color3.new(0, 0, 0)
	statusBar.BackgroundTransparency = 0.7
	statusBar.BorderSizePixel = 0
	statusBar.Parent = sidebar
	
	local statusBorder = Instance.new("Frame")
	statusBorder.Size = UDim2.new(1, 0, 0, 1)
	statusBorder.BackgroundColor3 = Theme.Colors.GlassBorder
	statusBorder.BackgroundTransparency = Theme.Transparency.GlassBorder
	statusBorder.BorderSizePixel = 0
	statusBorder.Parent = statusBar
	
	if not isMobile then
		Utils.CreatePadding(statusBar, {Top = 15, Bottom = 15, Left = 20, Right = 20})
		
		local statusLabel = Instance.new("TextLabel")
		statusLabel.Size = UDim2.new(1, 0, 0, 14)
		statusLabel.BackgroundTransparency = 1
		statusLabel.Text = "Status"
		statusLabel.Font = Enum.Font.Gotham
		statusLabel.TextSize = 12
		statusLabel.TextColor3 = Theme.Colors.TextMuted
		statusLabel.TextXAlignment = Enum.TextXAlignment.Left
		statusLabel.Parent = statusBar
		
		local statusValue = Instance.new("TextLabel")
		statusValue.Size = UDim2.new(1, -20, 0, 16)
		statusValue.Position = UDim2.new(0, 0, 1, -16)
		statusValue.BackgroundTransparency = 1
		statusValue.Text = "Online"
		statusValue.Font = Enum.Font.GothamBold
		statusValue.TextSize = 14
		statusValue.TextColor3 = Theme.Colors.Success
		statusValue.TextXAlignment = Enum.TextXAlignment.Left
		statusValue.Parent = statusBar
		
		local statusDot = Instance.new("Frame")
		statusDot.Size = UDim2.new(0, 8, 0, 8)
		statusDot.Position = UDim2.new(1, -8, 1, -20)
		statusDot.BackgroundColor3 = Theme.Colors.Success
		statusDot.BorderSizePixel = 0
		statusDot.Parent = statusBar
		
		Utils.CreateCorner(statusDot, UDim.new(1, 0))
		
		-- Pulse animation
		task.spawn(function()
			while statusBar.Parent do
				Utils.Tween(statusDot, {BackgroundTransparency = 0.5}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
				task.wait(1)
				Utils.Tween(statusDot, {BackgroundTransparency = 0}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
				task.wait(1)
			end
		end)
	end
	
	-- Main content area
	local main = Instance.new("Frame")
	main.Size = isMobile and UDim2.new(1, -80, 1, 0) or UDim2.new(1, -260, 1, 0)
	main.Position = isMobile and UDim2.new(0, 80, 0, 0) or UDim2.new(0, 260, 0, 0)
	main.BackgroundTransparency = 1
	main.ClipsDescendants = true
	main.Parent = mainFrame
	
	-- Content frame (where views will be added)
	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, 0, 1, 0)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = main
	
	-- Make window draggable (PC only)
	if not isMobile then
		local dragging = false
		local dragInput, dragStart, startPos
		
		brand.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = mainFrame.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		
		brand.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				mainFrame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	end
	
	-- Handle viewport resize
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		local newScale = Utils.GetDPIScale()
		local newIsMobile = Utils.IsMobile()
		local newIsTablet = Utils.IsTablet()
		
		if newIsMobile and not newIsTablet then
			mainFrame.Size = UDim2.new(0.95, 0, 0.85, 0)
			sidebar.Size = UDim2.new(0, 80, 1, 0)
			main.Size = UDim2.new(1, -80, 1, 0)
			main.Position = UDim2.new(0, 80, 0, 0)
		elseif newIsTablet then
			mainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
			sidebar.Size = UDim2.new(0, 260, 1, 0)
			main.Size = UDim2.new(1, -260, 1, 0)
			main.Position = UDim2.new(0, 260, 0, 0)
		else
			mainFrame.Size = config.Size or UDim2.new(0, 1100, 0, 720)
			sidebar.Size = UDim2.new(0, 260, 1, 0)
			main.Size = UDim2.new(1, -260, 1, 0)
			main.Position = UDim2.new(0, 260, 0, 0)
		end
	end)
	
	window.ScreenGui = screenGui
	window.MainFrame = mainFrame
	window.Sidebar = sidebar
	window.NavGroup = navGroup
	window.ContentFrame = contentFrame
	window.StatusBar = statusBar
	window.Tabs = {}
	
	return window
end

function AscentUI:SetTheme(customTheme)
	for key, value in pairs(customTheme.Colors or {}) do
		Theme.Colors[key] = value
	end
	for key, value in pairs(customTheme.Transparency or {}) do
		Theme.Transparency[key] = value
	end
	for key, value in pairs(customTheme.Animations or {}) do
		Theme.Animations[key] = value
	end
end

function AscentUI:GetTheme()
	return Theme
end

return AscentUI
