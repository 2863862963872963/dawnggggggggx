local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")
local TX  = game:GetService("TextService")
local PLR = game:GetService("Players")

local function SafeParent()
	local ok, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok and cg then return cg end
	return PLR.LocalPlayer:WaitForChild("PlayerGui")
end

local function N(cls, p)
	local o = Instance.new(cls)
	for k, v in pairs(p or {}) do
		if k ~= "Parent" then o[k] = v end
	end
	if p and p.Parent then o.Parent = p.Parent end
	return o
end

local function TI(t, s, d)
	return TweenInfo.new(t or 0.3, s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out)
end

local function Tw(obj, props, info)
	if obj and obj.Parent then
		TS:Create(obj, info or TI(0.3), props):Play()
	end
end

local function Corner(p, r)
	N("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = p })
end

local function Stroke(p, c, t)
	return N("UIStroke", {
		Color           = c or Color3.fromRGB(40, 38, 60),
		Thickness       = t or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent          = p,
	})
end

local function Pad(p, t, r, b, l)
	N("UIPadding", {
		PaddingTop    = UDim.new(0, t or 0),
		PaddingRight  = UDim.new(0, r or t or 0),
		PaddingBottom = UDim.new(0, b or t or 0),
		PaddingLeft   = UDim.new(0, l or r or t or 0),
		Parent        = p,
	})
end

local function List(p, gap, fd, ha, va)
	return N("UIListLayout", {
		Padding             = UDim.new(0, gap or 0),
		FillDirection       = fd or Enum.FillDirection.Vertical,
		HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
		VerticalAlignment   = va or Enum.VerticalAlignment.Top,
		SortOrder           = Enum.SortOrder.LayoutOrder,
		Parent              = p,
	})
end

local function DarkerColor(c)
	local h, s, v = Color3.toHSV(c)
	return Color3.fromHSV(h, s, v * 0.55)
end

local function IsInBounds(pos, frame)
	local fp = frame.AbsolutePosition
	local fs = frame.AbsoluteSize
	return pos.X >= fp.X and pos.X <= fp.X + fs.X
		and pos.Y >= fp.Y and pos.Y <= fp.Y + fs.Y
end

local function MakeGrad(parent, c1, c2, rot)
	local existing = parent:FindFirstChildOfClass("UIGradient")
	if existing then existing:Destroy() end
	parent.BackgroundColor3 = Color3.new(1, 1, 1)
	return N("UIGradient", {
		Color    = ColorSequence.new({
			ColorSequenceKeypoint.new(0, c1),
			ColorSequenceKeypoint.new(1, c2 or DarkerColor(c1)),
		}),
		Rotation = rot or 0,
		Parent   = parent,
	})
end

local function TweenGrad(obj, targetColor, t)
	local g = obj:FindFirstChildOfClass("UIGradient")
	if not g then return end
	local cv = Instance.new("Color3Value")
	cv.Value  = g.Color.Keypoints[1].Value
	cv.Parent = obj
	local tween = TS:Create(cv, TI(t or 0.3), { Value = targetColor })
	local conn
	conn = cv:GetPropertyChangedSignal("Value"):Connect(function()
		if not g.Parent then conn:Disconnect(); cv:Destroy(); return end
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, cv.Value),
			ColorSequenceKeypoint.new(1, DarkerColor(cv.Value)),
		})
	end)
	tween.Completed:Connect(function() conn:Disconnect(); cv:Destroy() end)
	tween:Play()
end

local Assets = {
	Keybind  = "rbxassetid://12974370712",
	Textbox  = "rbxassetid://12975591097",
	Dropdown = "rbxassetid://12967775051",
	Check    = "rbxassetid://3926305904",
	Noise    = "rbxassetid://9968344227",
}

local Library = {}
Library.__index   = Library
Library.Flags     = {}
Library.Registry  = {}
Library.WindowKeybind = Enum.KeyCode.RightControl
Library.WindowOpen    = true

Library.Theme = {
	BG           = Color3.fromRGB(9,  9,  15),
	BG2          = Color3.fromRGB(13, 12, 21),
	BG3          = Color3.fromRGB(20, 18, 32),
	BG4          = Color3.fromRGB(28, 25, 44),
	Accent       = Color3.fromRGB(118, 88, 238),
	AccentDark   = Color3.fromRGB(78,  55, 168),
	AccentGlow   = Color3.fromRGB(148, 118, 255),
	Text         = Color3.fromRGB(228, 225, 248),
	TextDim      = Color3.fromRGB(138, 134, 166),
	TextFaint    = Color3.fromRGB(68,  65,  98),
	Border       = Color3.fromRGB(38,  35,  58),
	BorderBright = Color3.fromRGB(62,  58,  92),
	ToggleOn     = Color3.fromRGB(118, 88, 238),
	ToggleOff    = Color3.fromRGB(30,  27,  48),
	Success      = Color3.fromRGB(76,  200, 130),
	Warning      = Color3.fromRGB(230, 170, 60),
	Error        = Color3.fromRGB(220, 70,  70),
	Font         = Enum.Font.GothamMedium,
	FontBold     = Enum.Font.GothamBold,
	AnimSpeed    = 1,
}

local function GetTime(t)
	return t / Library.Theme.AnimSpeed
end

local function BindTheme(obj, prop, key)
	if not Library.Theme[key] then return obj end
	obj[prop] = Library.Theme[key]
	for _, item in Library.Registry do
		if item.Obj == obj and item.Prop == prop then
			item.Key = key
			return obj
		end
	end
	table.insert(Library.Registry, { Obj = obj, Prop = prop, Key = key, Type = "Prop" })
	return obj
end

local function BindGrad(obj, key)
	if not Library.Theme[key] then return end
	local c = Library.Theme[key]
	obj.BackgroundColor3 = Color3.new(1, 1, 1)
	local g = MakeGrad(obj, c, DarkerColor(c), 90)
	for _, item in Library.Registry do
		if item.Obj == obj and item.Type == "Grad" then
			item.Key = key; item.Grad = g
			return
		end
	end
	table.insert(Library.Registry, { Obj = obj, Grad = g, Key = key, Type = "Grad" })
end

function Library:SetTheme(newTheme)
	for k, v in pairs(newTheme) do Library.Theme[k] = v end
	for _, item in Library.Registry do
		if item.Obj and item.Obj.Parent then
			if item.Type == "Prop" then
				Tw(item.Obj, { [item.Prop] = Library.Theme[item.Key] }, TI(GetTime(0.5)))
			elseif item.Type == "Grad" and item.Grad and item.Grad.Parent then
				TweenGrad(item.Obj, Library.Theme[item.Key], GetTime(0.5))
			end
		end
	end
end

function Library:GetTheme()
	return Library.Theme
end

function Library:GetFlag(flag)
	return Library.Flags[flag]
end

function Library:SetWindowKeybind(key)
	Library.WindowKeybind = key
end

local NotifGui, NotifContainer

local function EnsureNotifs()
	if NotifGui and NotifGui.Parent then return end
	NotifGui = N("ScreenGui", {
		Name         = "StellarNotifs",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent       = SafeParent(),
	})
	NotifContainer = N("Frame", {
		Size                 = UDim2.new(0, 290, 1, 0),
		Position             = UDim2.new(1, -306, 0, 0),
		BackgroundTransparency = 1,
		Parent               = NotifGui,
	})
	List(NotifContainer, 8)
	Pad(NotifContainer, 16, 0, 16, 0)
end

function Library:Notify(opts)
	opts = opts or {}
	local title    = opts.Title    or "Notification"
	local body     = opts.Body     or ""
	local duration = opts.Duration or 4
	local ntype    = opts.Type     or "Info"

	EnsureNotifs()

	local accentMap = {
		Info    = Library.Theme.Accent,
		Success = Library.Theme.Success,
		Warning = Library.Theme.Warning,
		Error   = Library.Theme.Error,
	}
	local ac = accentMap[ntype] or Library.Theme.Accent

	local card = N("Frame", {
		Size                 = UDim2.new(1, 0, 0, 0),
		AutomaticSize        = Enum.AutomaticSize.Y,
		BackgroundColor3     = Library.Theme.BG2,
		ClipsDescendants     = true,
		Parent               = NotifContainer,
	})
	Corner(card, 8)
	Stroke(card, Library.Theme.BorderBright)

	N("Frame", {
		Size             = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = ac,
		ZIndex           = 2,
		Parent           = card,
	})
	Corner(card:FindFirstChildOfClass("Frame"), 2)

	local inner = N("Frame", {
		Size          = UDim2.new(1, -18, 0, 0),
		Position      = UDim2.new(0, 14, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent        = card,
	})
	Pad(inner, 10, 0, 10, 0)
	List(inner, 3)

	N("TextLabel", {
		Size               = UDim2.new(1, 0, 0, 0),
		AutomaticSize      = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text               = title,
		TextColor3         = Library.Theme.Text,
		TextSize           = 13,
		Font               = Library.Theme.FontBold,
		TextXAlignment     = Enum.TextXAlignment.Left,
		TextWrapped        = true,
		Parent             = inner,
	})

	if body ~= "" then
		N("TextLabel", {
			Size               = UDim2.new(1, 0, 0, 0),
			AutomaticSize      = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text               = body,
			TextColor3         = Library.Theme.TextDim,
			TextSize           = 12,
			Font               = Library.Theme.Font,
			TextXAlignment     = Enum.TextXAlignment.Left,
			TextWrapped        = true,
			Parent             = inner,
		})
	end

	local prog = N("Frame", {
		Size             = UDim2.new(1, 0, 0, 2),
		Position         = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = ac,
		BackgroundTransparency = 0.55,
		ZIndex           = 3,
		Parent           = card,
	})

	card.Position = UDim2.new(1, 20, 0, 0)
	card.BackgroundTransparency = 0.08
	Tw(card, { Position = UDim2.new(0, 0, 0, 0) }, TI(GetTime(0.45), Enum.EasingStyle.Back))
	Tw(prog, { Size = UDim2.new(0, 0, 0, 2) }, TI(GetTime(duration), Enum.EasingStyle.Linear))

	task.delay(duration - 0.4, function()
		if card and card.Parent then
			Tw(card, { Position = UDim2.new(1, 20, 0, 0) }, TI(GetTime(0.35)))
			task.delay(GetTime(0.4), function()
				if card and card.Parent then card:Destroy() end
			end)
		end
	end)
end

local LoaderClass = {}
LoaderClass.__index = LoaderClass

function LoaderClass:Start()
	self._active = true
	self._gui.Enabled = true

	local frame = self._frame
	frame.BackgroundTransparency = 1
	Tw(frame, { BackgroundTransparency = 0 }, TI(GetTime(0.6), Enum.EasingStyle.Sine))

	task.delay(GetTime(0.2), function()
		for _, d in ipairs(frame:GetDescendants()) do
			if d:IsA("TextLabel") then
				d.TextTransparency = 1
				Tw(d, { TextTransparency = 0 }, TI(GetTime(0.5)))
			end
		end
	end)

	task.spawn(function()
		while self._active do
			self._fill.Position = UDim2.new(-0.35, 0, 0, 0)
			self._fill.Size     = UDim2.new(0.35, 0, 1, 0)
			Tw(self._fill,
				{ Position = UDim2.new(1.0, 0, 0, 0) },
				TI(GetTime(1.1), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			)
			task.wait(GetTime(1.15))
		end
	end)
end

function LoaderClass:SetText(text)
	local lbl = self._label
	Tw(lbl, { TextTransparency = 1 }, TI(GetTime(0.1)))
	task.wait(GetTime(0.13))
	if lbl and lbl.Parent then
		lbl.Text = text
		Tw(lbl, { TextTransparency = 0 }, TI(GetTime(0.15)))
	end
end

function LoaderClass:End()
	self._active = false

	local center = self._center
	for _, d in ipairs(center:GetDescendants()) do
		if d:IsA("TextLabel") then
			Tw(d, { TextTransparency = 1 }, TI(GetTime(0.18)))
		end
	end
	task.wait(GetTime(0.25))

	Tw(self._left,  { Position = UDim2.new(-0.5, 0, 0, 0) }, TI(GetTime(0.72), Enum.EasingStyle.Quart))
	Tw(self._right, { Position = UDim2.new(1.0,  0, 0, 0) }, TI(GetTime(0.72), Enum.EasingStyle.Quart))
	task.wait(GetTime(0.82))

	self._gui:Destroy()
	if self._onEnd then self._onEnd() end
end

function Library:Window(opts)
	opts = opts or {}
	local title    = opts.Title    or "Stellar"
	local subtitle = opts.SubTitle or ""
	local version  = opts.Version  or ""
	local status   = opts.Status   or ""
	local useLoader = opts.Loader  or false
	local winIcon  = opts.Icon     or ""

	local gui = N("ScreenGui", {
		Name            = "Stellar_" .. title:gsub("%s+", ""),
		ResetOnSpawn    = false,
		ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
		Enabled         = not useLoader,
		Parent          = SafeParent(),
	})

	local main = N("CanvasGroup", {
		Name                 = "MainFrame",
		Size                 = UDim2.new(0, 700, 0, 520),
		Position             = UDim2.new(0.5, -350, 0.5, -260),
		BackgroundColor3     = Library.Theme.BG,
		GroupTransparency    = 0,
		ClipsDescendants     = false,
		Parent               = gui,
	})
	BindTheme(main, "BackgroundColor3", "BG")
	Corner(main, 10)
	local mainStroke = Stroke(main, Library.Theme.Border)

	N("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 11, 28)),
			ColorSequenceKeypoint.new(0.55, Library.Theme.BG),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 7, 16)),
		}),
		Rotation = 125,
		Parent   = main,
	})

	N("ImageLabel", {
		Size               = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image              = Assets.Noise,
		ImageTransparency  = 0.965,
		ScaleType          = Enum.ScaleType.Tile,
		TileSize           = UDim2.new(0, 64, 0, 64),
		ZIndex             = 0,
		Parent             = main,
	})

	local dragOk = pcall(function()
		N("UIDragDetector", { Parent = main })
	end)
	if not dragOk then
		local dragging, dragStart, frameStart = false, Vector2.new(), Vector2.new()
		main.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging   = true
				dragStart  = inp.Position
				local ap   = main.AbsolutePosition
				frameStart = Vector2.new(ap.X, ap.Y)
			end
		end)
		UIS.InputChanged:Connect(function(inp)
			if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
				local d = inp.Position - dragStart
				main.Position = UDim2.new(0, frameStart.X + d.X, 0, frameStart.Y + d.Y)
			end
		end)
		UIS.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
	end

	UIS.InputBegan:Connect(function(inp, gpe)
		if not gpe and inp.KeyCode == Library.WindowKeybind then
			Library.WindowOpen = not Library.WindowOpen
			mainStroke.Enabled = false
			if Library.WindowOpen then
				main.Visible = true
				Tw(main, { GroupTransparency = 0 }, TI(GetTime(0.4)))
				task.delay(GetTime(0.41), function()
					if Library.WindowOpen then mainStroke.Enabled = true end
				end)
			else
				Tw(main, { GroupTransparency = 1 }, TI(GetTime(0.4)))
				task.delay(GetTime(0.41), function()
					if not Library.WindowOpen then main.Visible = false end
				end)
			end
		end
	end)

	local header = N("Frame", {
		Name             = "Header",
		Size             = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Library.Theme.BG2,
		BackgroundTransparency = 0.18,
		ZIndex           = 3,
		Parent           = main,
	})
	BindTheme(header, "BackgroundColor3", "BG2")
	Corner(header, 10)
	N("Frame", {
		Size             = UDim2.new(1, 0, 0.5, 0),
		Position         = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Library.Theme.BG2,
		BackgroundTransparency = 0.18,
		ZIndex           = 2,
		Parent           = header,
	})
	BindTheme(header:FindFirstChild("Frame"), "BackgroundColor3", "BG2")
	Stroke(header, Library.Theme.Border)

	local accentPill = N("Frame", {
		Size             = UDim2.new(0, 2, 0, 26),
		Position         = UDim2.new(0, 15, 0.5, -13),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex           = 4,
		Parent           = header,
	})
	Corner(accentPill, 1)
	MakeGrad(accentPill, Library.Theme.AccentGlow, Library.Theme.AccentDark, 90)

	local headerLeft = N("Frame", {
		Size               = UDim2.new(0.55, 0, 1, 0),
		Position           = UDim2.new(0, 27, 0, 0),
		BackgroundTransparency = 1,
		ZIndex             = 4,
		Parent             = header,
	})
	List(headerLeft, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

	if winIcon ~= "" then
		N("ImageLabel", {
			Size               = UDim2.new(0, 20, 0, 20),
			BackgroundTransparency = 1,
			Image              = winIcon,
			ZIndex             = 5,
			Parent             = headerLeft,
		})
	end

	local titleLbl = N("TextLabel", {
		Size               = UDim2.new(0, 0, 1, 0),
		AutomaticSize      = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text               = title,
		TextColor3         = Library.Theme.Text,
		TextSize           = 17,
		Font               = Library.Theme.FontBold,
		TextXAlignment     = Enum.TextXAlignment.Left,
		ZIndex             = 5,
		Parent             = headerLeft,
	})
	BindTheme(titleLbl, "TextColor3", "Text")

	if subtitle ~= "" then
		local subPill = N("Frame", {
			Size               = UDim2.new(0, 0, 0, 20),
			AutomaticSize      = Enum.AutomaticSize.X,
			BackgroundColor3   = Library.Theme.BG4,
			ZIndex             = 5,
			Parent             = headerLeft,
		})
		Corner(subPill, 5)
		Stroke(subPill, Library.Theme.Border)
		Pad(subPill, 0, 8, 0, 8)
		local subLbl = N("TextLabel", {
			Size               = UDim2.new(0, 0, 1, 0),
			AutomaticSize      = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Text               = subtitle,
			TextColor3         = Library.Theme.TextDim,
			TextSize           = 11,
			Font               = Library.Theme.Font,
			ZIndex             = 6,
			Parent             = subPill,
		})
		BindTheme(subLbl, "TextColor3", "TextDim")
	end

	if version ~= "" then
		local verPill = N("Frame", {
			Size               = UDim2.new(0, 0, 0, 20),
			AutomaticSize      = Enum.AutomaticSize.X,
			BackgroundColor3   = Library.Theme.Accent,
			BackgroundTransparency = 0.82,
			ZIndex             = 5,
			Parent             = headerLeft,
		})
		Corner(verPill, 5)
		Pad(verPill, 0, 6, 0, 6)
		N("TextLabel", {
			Size               = UDim2.new(0, 0, 1, 0),
			AutomaticSize      = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Text               = version,
			TextColor3         = Library.Theme.AccentGlow,
			TextSize           = 10,
			Font               = Library.Theme.FontBold,
			ZIndex             = 6,
			Parent             = verPill,
		})
	end

	local ctrlBar = N("Frame", {
		Size               = UDim2.new(0, 56, 0, 24),
		Position           = UDim2.new(1, -68, 0.5, -12),
		BackgroundTransparency = 1,
		ZIndex             = 4,
		Parent             = header,
	})
	List(ctrlBar, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

	local function MakeCtrl(col, lbl)
		local btn = N("TextButton", {
			Size               = UDim2.new(0, 24, 0, 24),
			BackgroundColor3   = col,
			BackgroundTransparency = 0.42,
			Text               = lbl,
			TextColor3         = Color3.new(1, 1, 1),
			TextTransparency   = 0.25,
			TextSize           = 14,
			Font               = Library.Theme.FontBold,
			AutoButtonColor    = false,
			ZIndex             = 5,
			Parent             = ctrlBar,
		})
		Corner(btn, 6)
		btn.MouseEnter:Connect(function()  Tw(btn, { BackgroundTransparency = 0.05 }, TI(GetTime(0.15))) end)
		btn.MouseLeave:Connect(function()  Tw(btn, { BackgroundTransparency = 0.42 }, TI(GetTime(0.15))) end)
		return btn
	end

	local minimized = false
	local fullSize  = main.Size

	local minBtn   = MakeCtrl(Color3.fromRGB(230, 168, 48), "–")
	local closeBtn = MakeCtrl(Color3.fromRGB(218, 68, 68),  "×")

	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			Tw(main, { Size = UDim2.new(0, 700, 0, 50) }, TI(GetTime(0.45), Enum.EasingStyle.Back))
		else
			Tw(main, { Size = fullSize }, TI(GetTime(0.45), Enum.EasingStyle.Back))
		end
	end)
	closeBtn.MouseButton1Click:Connect(function()
		Tw(main, { GroupTransparency = 1 }, TI(GetTime(0.3)))
		task.delay(GetTime(0.35), function() gui:Destroy() end)
	end)

	local sidebar = N("ScrollingFrame", {
		Name                 = "Sidebar",
		Size                 = UDim2.new(0, 178, 1, -82),
		Position             = UDim2.new(0, 0, 0, 50),
		BackgroundColor3     = Library.Theme.BG2,
		BackgroundTransparency = 0.25,
		BorderSizePixel      = 0,
		ScrollBarThickness   = 0,
		CanvasSize           = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize  = Enum.AutomaticSize.Y,
		ClipsDescendants     = true,
		ZIndex               = 2,
		Parent               = main,
	})
	BindTheme(sidebar, "BackgroundColor3", "BG2")

	N("Frame", {
		Size             = UDim2.new(0, 1, 1, 0),
		Position         = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Library.Theme.Border,
		ZIndex           = 3,
		Parent           = sidebar,
	})

	Pad(sidebar, 12, 10, 12, 10)
	List(sidebar, 5)

	local contentArea = N("Frame", {
		Name             = "ContentArea",
		Size             = UDim2.new(1, -178, 1, -82),
		Position         = UDim2.new(0, 178, 0, 50),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent           = main,
	})

	local footer = N("Frame", {
		Name             = "Footer",
		Size             = UDim2.new(1, 0, 0, 32),
		Position         = UDim2.new(0, 0, 1, -32),
		BackgroundColor3 = Library.Theme.BG2,
		BackgroundTransparency = 0.2,
		Parent           = main,
	})
	BindTheme(footer, "BackgroundColor3", "BG2")
	Corner(footer, 10)
	N("Frame", {
		Size             = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = Library.Theme.BG2,
		BackgroundTransparency = 0.2,
		ZIndex           = 1,
		Parent           = footer,
	})
	Stroke(footer, Library.Theme.Border)

	local statusLbl = N("TextLabel", {
		Size               = UDim2.new(1, -90, 1, 0),
		Position           = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Text               = status,
		TextColor3         = Library.Theme.TextFaint,
		TextSize           = 11,
		Font               = Library.Theme.Font,
		TextXAlignment     = Enum.TextXAlignment.Left,
		Parent             = footer,
	})
	BindTheme(statusLbl, "TextColor3", "TextFaint")

	local dotRow = N("Frame", {
		Size               = UDim2.new(0, 0, 0, 8),
		Position           = UDim2.new(1, -22, 0.5, -4),
		AutomaticSize      = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent             = footer,
	})
	List(dotRow, 3, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	for i, trans in ipairs({ 0, 0.45, 0.75 }) do
		local d = N("Frame", {
			Size             = UDim2.new(0, 5, 0, 5),
			BackgroundColor3 = Library.Theme.Accent,
			BackgroundTransparency = trans,
			Parent           = dotRow,
		})
		Corner(d, 3)
	end

	local popupCont = N("Frame", {
		Name             = "PopupContainer",
		ZIndex           = 500,
		Visible          = false,
		Size             = UDim2.new(0, 0, 0, 0),
		AutomaticSize    = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		BackgroundColor3 = Library.Theme.BG3,
		Parent           = gui,
	})
	BindTheme(popupCont, "BackgroundColor3", "BG3")
	Corner(popupCont, 8)
	Stroke(popupCont, Library.Theme.BorderBright)
	Pad(popupCont, 5, 5, 5, 5)
	List(popupCont, 0)

	N("UIGradient", {
		Color    = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 20, 36)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 14, 26)),
		}),
		Rotation = 90,
		Parent   = popupCont,
	})

	local popupOwner = nil
	local popupConn  = nil

	local function ClosePopup()
		if not popupCont.Visible then return end
		local sz = popupCont.AbsoluteSize
		Tw(popupCont, { Size = UDim2.new(0, sz.X, 0, 0) }, TI(GetTime(0.22)))
		task.delay(GetTime(0.25), function()
			popupCont.Visible = false
			popupOwner = nil
		end)
		if popupConn then popupConn:Disconnect(); popupConn = nil end
	end

	local function OpenPopup(owner, builder)
		if popupCont.Visible and popupOwner == owner then ClosePopup(); return end
		for _, c in ipairs(popupCont:GetChildren()) do
			if not c:IsA("UIListLayout") and not c:IsA("UICorner") and not c:IsA("UIStroke") and not c:IsA("UIPadding") and not c:IsA("UIGradient") then
				c:Destroy()
			end
		end
		popupCont.Size = UDim2.new(0, 0, 0, 0)
		popupCont.Visible = true
		builder(popupCont)
		popupOwner = owner

		local bp  = owner.AbsolutePosition
		local mp  = main.AbsolutePosition
		local msz = main.AbsoluteSize
		popupCont.Position = UDim2.new(0, mp.X + msz.X + 10, 0, bp.Y)

		Tw(popupCont, { Size = UDim2.new(0, 168, 0, 0) }, TI(GetTime(0.38), Enum.EasingStyle.Back))
		popupCont.AutomaticSize = Enum.AutomaticSize.Y

		if popupConn then popupConn:Disconnect() end
		popupConn = UIS.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.MouseButton2 then
				local mp2 = Vector2.new(inp.Position.X, inp.Position.Y)
				if not IsInBounds(mp2, popupCont) and not IsInBounds(mp2, owner) then
					ClosePopup()
				end
			end
		end)
	end

	local WindowFuncs = {}
	local tabs          = {}
	local activeTab     = nil
	local activeTabIdx  = 1
	local firstTab      = true

	function WindowFuncs:SetStatus(text)
		statusLbl.Text = text
	end

	function WindowFuncs:Separator(opts)
		opts = opts or {}
		local txt = (opts.Title or ""):upper()
		local sep = N("Frame", {
			Size               = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			Parent             = sidebar,
		})
		Pad(sep, 0, 0, 0, 2)
		if txt ~= "" then
			N("TextLabel", {
				Size               = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text               = txt,
				TextColor3         = Library.Theme.TextFaint,
				TextSize           = 9,
				Font               = Library.Theme.FontBold,
				TextXAlignment     = Enum.TextXAlignment.Left,
				LetterSpacing      = 3,
				Parent             = sep,
			})
		else
			N("Frame", {
				Size             = UDim2.new(1, 0, 0, 1),
				Position         = UDim2.new(0, 0, 0.5, 0),
				BackgroundColor3 = Library.Theme.Border,
				Parent           = sep,
			})
		end
	end

	function WindowFuncs:Tab(tabOpts)
		tabOpts = tabOpts or {}
		local tabTitle = tabOpts.Title or "Tab"
		local tabIcon  = tabOpts.Icon  or ""

		local tabBtn = N("TextButton", {
			Size               = UDim2.new(1, 0, 0, 36),
			BackgroundColor3   = Library.Theme.BG3,
			BackgroundTransparency = 1,
			Text               = "",
			AutoButtonColor    = false,
			ZIndex             = 3,
			Parent             = sidebar,
		})
		Corner(tabBtn, 7)

		local tabBtnContent = N("Frame", {
			Size               = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex             = 3,
			Parent             = tabBtn,
		})
		List(tabBtnContent, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
		Pad(tabBtnContent, 0, 0, 0, 12)

		if tabIcon ~= "" then
			N("ImageLabel", {
				Size               = UDim2.new(0, 15, 0, 15),
				BackgroundTransparency = 1,
				Image              = tabIcon,
				ImageColor3        = Library.Theme.TextDim,
				ZIndex             = 4,
				Parent             = tabBtnContent,
			})
		end

		local tabBtnLbl = N("TextLabel", {
			Size               = UDim2.new(1, tabIcon ~= "" and -27 or 0, 1, 0),
			BackgroundTransparency = 1,
			Text               = tabTitle,
			TextColor3         = Library.Theme.TextDim,
			TextSize           = 13,
			Font               = Library.Theme.Font,
			TextXAlignment     = Enum.TextXAlignment.Left,
			ZIndex             = 4,
			Parent             = tabBtnContent,
		})

		local indicator = N("Frame", {
			Size             = UDim2.new(0, 2, 0, 20),
			Position         = UDim2.new(0, 0, 0.5, -10),
			BackgroundColor3 = Library.Theme.Accent,
			BackgroundTransparency = 1,
			ZIndex           = 4,
			Parent           = tabBtn,
		})
		Corner(indicator, 1)

		local tabContent = N("Frame", {
			Size               = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible            = false,
			Parent             = contentArea,
		})

		local scrollFrame = N("ScrollingFrame", {
			Size                 = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel      = 0,
			ScrollBarThickness   = 2,
			ScrollBarImageColor3 = Library.Theme.Accent,
			ScrollBarImageTransparency = 0.5,
			CanvasSize           = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize  = Enum.AutomaticSize.Y,
			Parent               = tabContent,
		})
		Pad(scrollFrame, 14, 14, 14, 14)
		List(scrollFrame, 12)

		local thisTabIdx = #tabs + 1

		local function ActivateTab()
			for _, t in ipairs(tabs) do
				t.Content.Visible = false
				Tw(t.Label, { TextColor3 = Library.Theme.TextDim }, TI(GetTime(0.2)))
				Tw(t.Label, { Font = Library.Theme.Font })
				Tw(t.Indicator, { BackgroundTransparency = 1 }, TI(GetTime(0.2)))
				Tw(t.Btn, { BackgroundTransparency = 1 }, TI(GetTime(0.2)))
			end

			if activeTab and activeTab ~= tabContent then
				local old = activeTab
				local dir = thisTabIdx > activeTabIdx and 1 or -1
				old.Position = UDim2.new(0, 0, 0, 0)
				Tw(old, { Position = UDim2.new(dir * 0.07, 0, 0, 0) }, TI(GetTime(0.28)))
				task.delay(GetTime(0.3), function() if activeTab ~= old then old.Visible = false end end)
				tabContent.Visible   = true
				tabContent.Position  = UDim2.new(-dir * 0.07, 0, 0, 0)
				Tw(tabContent, { Position = UDim2.new(0, 0, 0, 0) }, TI(GetTime(0.28)))
			else
				tabContent.Visible = true
			end

			activeTab    = tabContent
			activeTabIdx = thisTabIdx

			Tw(tabBtnLbl, { TextColor3 = Library.Theme.Text }, TI(GetTime(0.2)))
			tabBtnLbl.Font = Library.Theme.FontBold
			Tw(indicator, { BackgroundTransparency = 0 }, TI(GetTime(0.2)))
			Tw(tabBtn, { BackgroundTransparency = 0.55 }, TI(GetTime(0.2)))
		end

		tabBtn.MouseEnter:Connect(function()
			if activeTab ~= tabContent then
				Tw(tabBtn, { BackgroundTransparency = 0.82 }, TI(GetTime(0.15)))
				Tw(tabBtnLbl, { TextColor3 = Library.Theme.Text }, TI(GetTime(0.15)))
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if activeTab ~= tabContent then
				Tw(tabBtn, { BackgroundTransparency = 1 }, TI(GetTime(0.15)))
				Tw(tabBtnLbl, { TextColor3 = Library.Theme.TextDim }, TI(GetTime(0.15)))
			end
		end)
		tabBtn.MouseButton1Click:Connect(ActivateTab)

		table.insert(tabs, {
			Btn       = tabBtn,
			Label     = tabBtnLbl,
			Indicator = indicator,
			Content   = tabContent,
		})

		if firstTab then firstTab = false; ActivateTab() end

		local TabFuncs = {}

		function TabFuncs:Section(sectionName)
			sectionName = sectionName or "Section"

			local secWrap = N("Frame", {
				Size           = UDim2.new(1, 0, 0, 0),
				AutomaticSize  = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Parent         = scrollFrame,
			})
			List(secWrap, 7)

			local secHeader = N("Frame", {
				Size               = UDim2.new(1, 0, 0, 22),
				BackgroundTransparency = 1,
				Parent             = secWrap,
			})
			Pad(secHeader, 0, 0, 0, 2)

			N("TextLabel", {
				Size               = UDim2.new(0, 0, 1, 0),
				AutomaticSize      = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Text               = sectionName:upper(),
				TextColor3         = Library.Theme.TextDim,
				TextSize           = 10,
				Font               = Library.Theme.FontBold,
				TextXAlignment     = Enum.TextXAlignment.Left,
				LetterSpacing      = 3,
				ZIndex             = 2,
				Parent             = secHeader,
			})

			local divider = N("Frame", {
				Size             = UDim2.new(1, 0, 0, 1),
				Position         = UDim2.new(0, 0, 1, -1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent           = secHeader,
			})
			N("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Library.Theme.Accent),
					ColorSequenceKeypoint.new(0.3, Library.Theme.Border),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
				}),
				Transparency = NumberSequence.new(0),
				Parent       = divider,
			})

			local elemsFrame = N("Frame", {
				Size           = UDim2.new(1, 0, 0, 0),
				AutomaticSize  = Enum.AutomaticSize.Y,
				BackgroundColor3 = Library.Theme.BG3,
				BackgroundTransparency = 0.35,
				Parent         = secWrap,
			})
			BindTheme(elemsFrame, "BackgroundColor3", "BG3")
			Corner(elemsFrame, 8)
			Stroke(elemsFrame, Library.Theme.Border)
			List(elemsFrame, 0)

			local ElemFuncs = {}

			local function CreateRow(rowTitle, rowDesc)
				local hasDesc = rowDesc and rowDesc ~= ""
				local rowH    = hasDesc and 48 or 42

				local rowFrame = N("Frame", {
					Size               = UDim2.new(1, 0, 0, rowH),
					BackgroundTransparency = 1,
					Parent             = elemsFrame,
				})

				local sepLine = N("Frame", {
					Size             = UDim2.new(1, -20, 0, 1),
					Position         = UDim2.new(0, 10, 1, -1),
					BackgroundColor3 = Library.Theme.Border,
					BackgroundTransparency = 0.5,
					Parent           = rowFrame,
				})

				local textBox = N("Frame", {
					Size               = UDim2.new(0.5, 0, 1, 0),
					BackgroundTransparency = 1,
					Parent             = rowFrame,
				})
				Pad(textBox, 0, 0, 0, 14)
				List(textBox, 2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

				local rTitle = N("TextLabel", {
					Size               = UDim2.new(1, 0, 0, hasDesc and 16 or 18),
					BackgroundTransparency = 1,
					Text               = rowTitle,
					TextColor3         = Library.Theme.Text,
					TextSize           = 13,
					Font               = Library.Theme.Font,
					TextXAlignment     = Enum.TextXAlignment.Left,
					Parent             = textBox,
				})
				BindTheme(rTitle, "TextColor3", "Text")

				if hasDesc then
					local rDesc = N("TextLabel", {
						Size               = UDim2.new(1, 0, 0, 13),
						BackgroundTransparency = 1,
						Text               = rowDesc,
						TextColor3         = Library.Theme.TextDim,
						TextSize           = 11,
						Font               = Library.Theme.Font,
						TextXAlignment     = Enum.TextXAlignment.Left,
						TextTruncate       = Enum.TextTruncate.AtEnd,
						Parent             = textBox,
					})
					BindTheme(rDesc, "TextColor3", "TextDim")
				end

				return rowFrame
			end

			local function CreateAttachments(container, toggleCB)
				local AttFuncs = {}

				function AttFuncs:Bind(bindOpts)
					bindOpts = bindOpts or {}
					local defKey  = bindOpts.Default  or Enum.KeyCode.RightShift
					local mode    = bindOpts.Mode     or "Toggle"
					local bindCB  = bindOpts.Callback or function() end

					local bindBtn = N("TextButton", {
						Size               = UDim2.new(0, 0, 0, 22),
						AutomaticSize      = Enum.AutomaticSize.X,
						BackgroundColor3   = Library.Theme.BG4,
						Text               = "",
						AutoButtonColor    = false,
						LayoutOrder        = 5,
						ZIndex             = 3,
						Parent             = container,
					})
					Corner(bindBtn, 5)
					Stroke(bindBtn, Library.Theme.Border)
					Pad(bindBtn, 0, 8, 0, 8)

					local bindInner = N("Frame", {
						Size               = UDim2.new(0, 0, 1, 0),
						AutomaticSize      = Enum.AutomaticSize.X,
						BackgroundTransparency = 1,
						Parent             = bindBtn,
					})
					List(bindInner, 4, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)

					local keyLbl = N("TextLabel", {
						Size               = UDim2.new(0, 0, 1, 0),
						AutomaticSize      = Enum.AutomaticSize.X,
						BackgroundTransparency = 1,
						Text               = defKey.Name,
						TextColor3         = Library.Theme.TextDim,
						TextSize           = 11,
						Font               = Library.Theme.Font,
						LayoutOrder        = 1,
						ZIndex             = 4,
						Parent             = bindInner,
					})

					N("ImageLabel", {
						Size               = UDim2.new(0, 10, 0, 10),
						BackgroundTransparency = 1,
						Image              = Assets.Keybind,
						ImageColor3        = Library.Theme.TextDim,
						LayoutOrder        = 2,
						ZIndex             = 4,
						Parent             = bindInner,
					})

					local curKey = defKey
					local binding = false

					local function SetKey(newKey)
						curKey = newKey
						if type(newKey) == "string" then
							keyLbl.Text = newKey
						elseif newKey.EnumType == Enum.KeyCode then
							keyLbl.Text = newKey.Name
						else
							local names = {
								[Enum.UserInputType.MouseButton1] = "MB1",
								[Enum.UserInputType.MouseButton2] = "MB2",
								[Enum.UserInputType.MouseButton3] = "MB3",
							}
							keyLbl.Text = names[newKey] or "?"
						end
						bindCB(newKey)
					end

					bindBtn.MouseButton1Click:Connect(function()
						binding = true
						keyLbl.Text = "..."
						Tw(bindBtn, { BackgroundColor3 = Library.Theme.Accent }, TI(GetTime(0.15)))
					end)

					bindBtn.MouseButton2Click:Connect(function()
						OpenPopup(bindBtn, function(pop)
							local sf = N("ScrollingFrame", {
								Size               = UDim2.new(1, 0, 0, 90),
								BackgroundTransparency = 1,
								CanvasSize         = UDim2.new(0, 0, 0, 0),
								ScrollBarThickness = 0,
								Parent             = pop,
							})
							List(sf, 0)
							for _, m in ipairs({"Toggle", "Hold", "Always"}) do
								local ob = N("TextButton", {
									Size               = UDim2.new(1, 0, 0, 30),
									BackgroundTransparency = 1,
									Text               = m,
									TextColor3         = mode == m and Library.Theme.Accent or Library.Theme.TextDim,
									TextSize           = 12,
									Font               = Library.Theme.Font,
									TextXAlignment     = Enum.TextXAlignment.Left,
									AutoButtonColor    = false,
									ZIndex             = 501,
									Parent             = sf,
								})
								Pad(ob, 0, 0, 0, 10)
								ob.MouseEnter:Connect(function() ob.TextColor3 = Library.Theme.Text end)
								ob.MouseLeave:Connect(function() ob.TextColor3 = mode == m and Library.Theme.Accent or Library.Theme.TextDim end)
								ob.MouseButton1Click:Connect(function() mode = m; ClosePopup() end)
							end
						end)
					end)

					UIS.InputBegan:Connect(function(inp)
						if binding then
							if inp.UserInputType == Enum.UserInputType.Keyboard then
								binding = false
								Tw(bindBtn, { BackgroundColor3 = Library.Theme.BG4 }, TI(GetTime(0.15)))
								if inp.KeyCode == Enum.KeyCode.Escape then
									curKey = nil; keyLbl.Text = "None"
								else
									SetKey(inp.KeyCode)
								end
							elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
								binding = false
								Tw(bindBtn, { BackgroundColor3 = Library.Theme.BG4 }, TI(GetTime(0.15)))
								SetKey(inp.UserInputType)
							end
						elseif curKey and toggleCB then
							local trigger = false
							if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == curKey then trigger = true end
							if inp.UserInputType == curKey then trigger = true end
							if trigger then
								if mode == "Toggle"      then toggleCB("Toggle")
								elseif mode == "Hold"    then toggleCB(true)
								end
							end
						end
					end)

					UIS.InputEnded:Connect(function(inp)
						if curKey and toggleCB and mode == "Hold" then
							local trigger = false
							if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == curKey then trigger = true end
							if inp.UserInputType == curKey then trigger = true end
							if trigger then toggleCB(false) end
						end
					end)

					local BindObj = {}
					function BindObj:GetValue()     return curKey end
					function BindObj:SetValue(v)    SetKey(v) end
					function BindObj:GetMode()      return mode end
					function BindObj:SetMode(m)     mode = m end
					function BindObj:GetComponentType() return "Bind" end
					if bindOpts.Flag then Library.Flags[bindOpts.Flag] = BindObj end
					return AttFuncs
				end

				function AttFuncs:Colorpicker(cpOpts)
					cpOpts = cpOpts or {}
					local def      = cpOpts.Default  or Color3.fromRGB(255, 255, 255)
					local cpCB     = cpOpts.Callback or function() end
					local curColor = def
					local curAlpha = 1
					local hsv      = { Color3.toHSV(curColor) }

					local cpBtn = N("TextButton", {
						Size               = UDim2.new(0, 18, 0, 18),
						BackgroundColor3   = curColor,
						Text               = "",
						AutoButtonColor    = false,
						LayoutOrder        = 3,
						ZIndex             = 3,
						Parent             = container,
					})
					Corner(cpBtn, 9)
					Stroke(cpBtn, Library.Theme.Border)

					local picker = N("Frame", {
						Name             = "ColorPickerPopup",
						Parent           = gui,
						Size             = UDim2.new(0, 232, 0, 248),
						BackgroundColor3 = Library.Theme.BG,
						Visible          = false,
						ZIndex           = 3000,
					})
					BindTheme(picker, "BackgroundColor3", "BG")
					Corner(picker, 10)
					Stroke(picker, Library.Theme.BorderBright)
					Pad(picker, 10, 10, 10, 10)
					pcall(function() N("UIDragDetector", { Parent = picker }) end)
					List(picker, 7)

					N("UIGradient", {
						Color    = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 10, 28)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 7, 18)),
						}),
						Rotation = 135,
						Parent   = picker,
					})

					local colorMap = N("TextButton", {
						Size            = UDim2.new(1, 0, 0, 132),
						BackgroundColor3 = Color3.fromHSV(hsv[1], 1, 1),
						Text            = "",
						AutoButtonColor = false,
						ZIndex          = 3001,
						LayoutOrder     = 1,
						Parent          = picker,
					})
					Corner(colorMap, 7)

					local satOver = N("Frame", { Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 3002, Parent = colorMap })
					N("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1) }), Parent = satOver })
					local valOver = N("Frame", { Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0), ZIndex = 3003, Parent = colorMap })
					N("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0) }), Parent = valOver })
					Corner(colorMap, 7)

					local cursor = N("Frame", {
						Size             = UDim2.new(0, 11, 0, 11),
						AnchorPoint      = Vector2.new(0.5, 0.5),
						Position         = UDim2.new(hsv[2], 0, 1 - hsv[3], 0),
						BackgroundColor3 = Color3.new(1, 1, 1),
						ZIndex           = 3005,
						Parent           = colorMap,
					})
					Corner(cursor, 6)
					N("UIStroke", { Color = Color3.fromRGB(0,0,0), Thickness = 1.5, Parent = cursor })

					local function MkSlider(lbl, lo)
						local sf = N("Frame", {
							Size           = UDim2.new(1, 0, 0, 34),
							BackgroundTransparency = 1,
							LayoutOrder    = lo,
							Parent         = picker,
						})
						N("TextLabel", {
							Size               = UDim2.new(1, -32, 0, 14),
							BackgroundTransparency = 1,
							Text               = lbl,
							TextColor3         = Library.Theme.TextDim,
							TextSize           = 11,
							Font               = Library.Theme.Font,
							TextXAlignment     = Enum.TextXAlignment.Left,
							Parent             = sf,
						})
						local vLbl = N("TextLabel", {
							Size               = UDim2.new(0, 32, 0, 14),
							Position           = UDim2.new(1, -32, 0, 0),
							BackgroundTransparency = 1,
							Text               = "0",
							TextColor3         = Library.Theme.Text,
							TextSize           = 11,
							Font               = Library.Theme.FontBold,
							TextXAlignment     = Enum.TextXAlignment.Right,
							Parent             = sf,
						})
						local track = N("TextButton", {
							Size             = UDim2.new(1, 0, 0, 5),
							Position         = UDim2.new(0, 0, 0, 22),
							BackgroundColor3 = Library.Theme.BG4,
							Text             = "",
							AutoButtonColor  = false,
							ZIndex           = 3002,
							Parent           = sf,
						})
						Corner(track, 3)
						local fill = N("Frame", {
							Size             = UDim2.new(0, 0, 1, 0),
							BackgroundColor3 = Color3.new(1,1,1),
							ZIndex           = 3003,
							Parent           = track,
						})
						Corner(fill, 3)
						MakeGrad(fill, Library.Theme.Accent, Library.Theme.AccentDark, 0)
						local thumb = N("Frame", {
							Size             = UDim2.new(0, 12, 0, 12),
							AnchorPoint      = Vector2.new(0.5, 0.5),
							Position         = UDim2.new(0, 0, 0.5, 0),
							BackgroundColor3 = Color3.new(1, 1, 1),
							ZIndex           = 3005,
							Parent           = track,
						})
						Corner(thumb, 6)
						N("UIStroke", { Color = Library.Theme.Accent, Thickness = 2, Parent = thumb })
						return { Track = track, Fill = fill, Thumb = thumb, Label = vLbl }
					end

					local hueSld   = MkSlider("Hue",     2)
					local alphaSld = MkSlider("Opacity", 3)

					local function UpdateVisuals()
						cpBtn.BackgroundColor3    = curColor
						colorMap.BackgroundColor3 = Color3.fromHSV(hsv[1], 1, 1)
						Tw(cursor, { Position = UDim2.new(hsv[2], 0, 1 - hsv[3], 0) }, TI(GetTime(0.04)))
						local hp = hsv[1]
						Tw(hueSld.Fill,  { Size = UDim2.new(hp, 0, 1, 0) }, TI(GetTime(0.04)))
						Tw(hueSld.Thumb, { Position = UDim2.new(hp, 0, 0.5, 0) }, TI(GetTime(0.04)))
						hueSld.Label.Text   = tostring(math.floor(hsv[1] * 360))
						local ap = curAlpha
						Tw(alphaSld.Fill,  { Size = UDim2.new(ap, 0, 1, 0) }, TI(GetTime(0.04)))
						Tw(alphaSld.Thumb, { Position = UDim2.new(ap, 0, 0.5, 0) }, TI(GetTime(0.04)))
						alphaSld.Label.Text = math.floor(curAlpha * 100) .. "%"
						cpCB(curColor, curAlpha)
					end

					local function HandleInput(guiObj, iType, inp)
						local function Update(pos)
							local mx = guiObj.AbsoluteSize.X
							local my = guiObj.AbsoluteSize.Y
							local px = math.clamp(pos.X - guiObj.AbsolutePosition.X, 0, mx) / mx
							local py = math.clamp(pos.Y - guiObj.AbsolutePosition.Y, 0, my) / my
							if iType == "Map"   then hsv[2] = px; hsv[3] = 1 - py
							elseif iType == "Hue"   then hsv[1] = px
							elseif iType == "Alpha" then curAlpha = px
							end
							curColor = Color3.fromHSV(hsv[1], hsv[2], hsv[3])
							UpdateVisuals()
						end
						Update(inp.Position)
						local mc = UIS.InputChanged:Connect(function(mv)
							if mv.UserInputType == Enum.UserInputType.MouseMovement or mv.UserInputType == Enum.UserInputType.Touch then
								Update(mv.Position)
							end
						end)
						local ec; ec = UIS.InputEnded:Connect(function(e)
							if e.UserInputType == Enum.UserInputType.MouseButton1 or e.UserInputType == Enum.UserInputType.Touch then
								mc:Disconnect(); ec:Disconnect()
							end
						end)
					end

					colorMap.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then HandleInput(colorMap, "Map", i) end
					end)
					hueSld.Track.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then HandleInput(hueSld.Track, "Hue", i) end
					end)
					alphaSld.Track.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then HandleInput(alphaSld.Track, "Alpha", i) end
					end)

					cpBtn.MouseButton1Click:Connect(function()
						if picker.Visible then
							picker.Visible = false
						else
							ClosePopup()
							local bp = cpBtn.AbsolutePosition
							local ss = gui.AbsoluteSize
							local x  = bp.X - 242
							local y  = bp.Y + 24
							if x < 5 then x = bp.X + 24 end
							if y + 252 > ss.Y then y = ss.Y - 257 end
							picker.Position = UDim2.new(0, x, 0, y)
							picker.Visible  = true
						end
					end)

					UIS.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 and picker.Visible then
							local mp = Vector2.new(i.Position.X, i.Position.Y)
							if not IsInBounds(mp, picker) and not IsInBounds(mp, cpBtn) then
								picker.Visible = false
							end
						end
					end)

					local CPObj = {}
					function CPObj:GetValue()          return curColor end
					function CPObj:SetValue(v)         curColor = v; hsv = { Color3.toHSV(v) }; UpdateVisuals() end
					function CPObj:GetTransparency()   return curAlpha end
					function CPObj:SetTransparency(v)  curAlpha = v; UpdateVisuals() end
					function CPObj:GetComponentType()  return "Colorpicker" end
					if cpOpts.Flag then Library.Flags[cpOpts.Flag] = CPObj end

					UpdateVisuals()
					return AttFuncs
				end

				return AttFuncs
			end

			function ElemFuncs:Toggle(opts)
				opts = opts or {}
				local state = opts.Default  or false
				local togCB = opts.Callback or function() end

				local row       = CreateRow(opts.Title or "Toggle", opts.Description or "")
				local rightSide = N("Frame", {
					Size               = UDim2.new(0, 110, 1, 0),
					Position           = UDim2.new(1, -110, 0, 0),
					BackgroundTransparency = 1,
					Parent             = row,
				})
				List(rightSide, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

				local track = N("TextButton", {
					Size               = UDim2.new(0, 40, 0, 22),
					BackgroundColor3   = state and Library.Theme.ToggleOn or Library.Theme.ToggleOff,
					Text               = "",
					AutoButtonColor    = false,
					LayoutOrder        = 10,
					ZIndex             = 3,
					Parent             = rightSide,
				})
				Corner(track, 11)
				local trackStroke = Stroke(track, state and Library.Theme.Accent or Library.Theme.Border)

				local knob = N("Frame", {
					Size             = UDim2.new(0, 16, 0, 16),
					Position         = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
					BackgroundColor3 = Color3.new(1, 1, 1),
					ZIndex           = 4,
					Parent           = track,
				})
				Corner(knob, 8)

				local function SetState(newState)
					if newState == "Toggle" then newState = not state end
					if newState == state then return end
					state = newState
					Tw(track, { BackgroundColor3 = state and Library.Theme.ToggleOn or Library.Theme.ToggleOff }, TI(GetTime(0.25)))
					Tw(trackStroke, { Color = state and Library.Theme.Accent or Library.Theme.Border }, TI(GetTime(0.25)))
					Tw(knob, { Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }, TI(GetTime(0.25), Enum.EasingStyle.Back))
					togCB(state)
				end

				track.MouseButton1Click:Connect(function() SetState("Toggle") end)

				local TglObj = {}
				function TglObj:GetValue()          return state end
				function TglObj:SetValue(v)         SetState(v) end
				function TglObj:GetComponentType()  return "Toggle" end
				if opts.Flag then Library.Flags[opts.Flag] = TglObj end

				return CreateAttachments(rightSide, SetState)
			end

			function ElemFuncs:Button(opts)
				opts = opts or {}
				local btnCB = opts.Callback or function() end

				local row = CreateRow(opts.Title or "Button", opts.Description or "")
				local box = N("TextButton", {
					AnchorPoint        = Vector2.new(1, 0.5),
					Position           = UDim2.new(1, -12, 0.5, 0),
					Size               = UDim2.new(0, 0, 0, 26),
					AutomaticSize      = Enum.AutomaticSize.X,
					BackgroundColor3   = Library.Theme.BG4,
					Text               = "",
					AutoButtonColor    = false,
					ZIndex             = 3,
					Parent             = row,
				})
				Corner(box, 6)
				Stroke(box, Library.Theme.Border)
				Pad(box, 0, 12, 0, 12)

				local boxLbl = N("TextLabel", {
					Size               = UDim2.new(0, 0, 1, 0),
					AutomaticSize      = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					Text               = opts.Action or opts.Text or "Execute",
					TextColor3         = Library.Theme.TextDim,
					TextSize           = 12,
					Font               = Library.Theme.Font,
					ZIndex             = 4,
					Parent             = box,
				})

				box.MouseEnter:Connect(function()
					Tw(box,    { BackgroundColor3 = Library.Theme.Accent }, TI(GetTime(0.2)))
					Tw(boxLbl, { TextColor3 = Color3.new(1,1,1) }, TI(GetTime(0.2)))
				end)
				box.MouseLeave:Connect(function()
					Tw(box,    { BackgroundColor3 = Library.Theme.BG4 }, TI(GetTime(0.2)))
					Tw(boxLbl, { TextColor3 = Library.Theme.TextDim }, TI(GetTime(0.2)))
				end)
				box.MouseButton1Down:Connect(function()
					Tw(box, { BackgroundColor3 = Library.Theme.AccentDark }, TI(GetTime(0.1)))
				end)
				box.MouseButton1Click:Connect(btnCB)
			end

			function ElemFuncs:Slider(opts)
				opts = opts or {}
				local mn      = opts.Min      or 0
				local mx      = opts.Max      or 100
				local default = opts.Default  or mn
				local suffix  = opts.Suffix   or ""
				local prefix  = opts.Prefix   or ""
				local decimals = opts.Decimal
				local dual    = opts.Dual     or false
				local sldCB   = opts.Callback or function() end

				local prec = decimals and 10 ^ decimals or 1

				local curVal = math.clamp(default, mn, mx)
				local curMin = mn
				local curMax = dual and (type(default) == "table" and default.Max or mx) or mx
				if dual and type(default) == "table" then curMin = default.Min or mn end

				local function Round(v)
					return math.clamp(math.floor(v * prec + 0.5) / prec, mn, mx)
				end
				local function Fmt(v)
					if decimals then return string.format("%." .. decimals .. "f", v) end
					return tostring(math.floor(v + 0.5))
				end

				local rootFrame = N("Frame", {
					Size           = UDim2.new(1, 0, 0, 0),
					AutomaticSize  = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Parent         = elemsFrame,
				})
				List(rootFrame, 0)

				local topRow = N("Frame", {
					Size               = UDim2.new(1, 0, 0, 38),
					BackgroundTransparency = 1,
					Parent             = rootFrame,
				})
				Pad(topRow, 0, 14, 0, 14)

				local titleL = N("TextLabel", {
					Size               = UDim2.new(0.58, 0, 1, 0),
					BackgroundTransparency = 1,
					Text               = opts.Title or "Slider",
					TextColor3         = Library.Theme.Text,
					TextSize           = 13,
					Font               = Library.Theme.Font,
					TextXAlignment     = Enum.TextXAlignment.Left,
					Parent             = topRow,
				})
				BindTheme(titleL, "TextColor3", "Text")

				local valLbl = N("TextLabel", {
					Size               = UDim2.new(0.42, 0, 1, 0),
					Position           = UDim2.new(0.58, 0, 0, 0),
					BackgroundTransparency = 1,
					Text               = dual and (prefix .. Fmt(curMin) .. " – " .. Fmt(curMax) .. suffix) or (prefix .. Fmt(curVal) .. suffix),
					TextColor3         = Library.Theme.Accent,
					TextSize           = 12,
					Font               = Library.Theme.FontBold,
					TextXAlignment     = Enum.TextXAlignment.Right,
					Parent             = topRow,
				})

				local trackRow = N("Frame", {
					Size               = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1,
					Parent             = rootFrame,
				})
				Pad(trackRow, 0, 14, 8, 14)

				local track = N("TextButton", {
					Size             = UDim2.new(1, 0, 0, 4),
					Position         = UDim2.new(0, 0, 0.5, -2),
					BackgroundColor3 = Library.Theme.BG4,
					Text             = "",
					AutoButtonColor  = false,
					ZIndex           = 2,
					Parent           = trackRow,
				})
				Corner(track, 2)

				local fillBase = N("Frame", {
					Size             = UDim2.new(dual and curMin / (mx - mn + 0.001) or 0, 0, 1, 0),
					BackgroundColor3 = Library.Theme.BG4,
					ZIndex           = 2,
					Visible          = dual,
					Parent           = track,
				})
				Corner(fillBase, 2)

				local fill = N("Frame", {
					Size             = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					ZIndex           = 3,
					Parent           = track,
				})
				Corner(fill, 2)
				MakeGrad(fill, Library.Theme.Accent, Library.Theme.AccentDark, 0)

				local function MakeThumb()
					local t = N("Frame", {
						Size             = UDim2.new(0, 13, 0, 13),
						AnchorPoint      = Vector2.new(0.5, 0.5),
						Position         = UDim2.new(0, 0, 0.5, 0),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 1,
						ZIndex           = 4,
						Parent           = track,
					})
					Corner(t, 7)
					N("UIStroke", { Color = Library.Theme.Accent, Thickness = 2, Parent = t })
					return t
				end

				local thumbMax = MakeThumb()
				local thumbMin = dual and MakeThumb()

				local function UpdateVisuals()
					if dual then
						local minPct = (curMin - mn) / (mx - mn)
						local maxPct = (curMax - mn) / (mx - mn)
						Tw(fillBase, { Size = UDim2.new(minPct, 0, 1, 0) }, TI(GetTime(0.05)))
						Tw(fill, { Size = UDim2.new(maxPct - minPct, 0, 1, 0), Position = UDim2.new(minPct, 0, 0, 0) }, TI(GetTime(0.05)))
						Tw(thumbMax, { Position = UDim2.new(maxPct, 0, 0.5, 0) }, TI(GetTime(0.05)))
						if thumbMin then Tw(thumbMin, { Position = UDim2.new(minPct, 0, 0.5, 0) }, TI(GetTime(0.05))) end
						valLbl.Text = prefix .. Fmt(curMin) .. " – " .. Fmt(curMax) .. suffix
					else
						local pct = (curVal - mn) / (mx - mn)
						Tw(fill, { Size = UDim2.new(pct, 0, 1, 0) }, TI(GetTime(0.05)))
						Tw(thumbMax, { Position = UDim2.new(pct, 0, 0.5, 0) }, TI(GetTime(0.05)))
						valLbl.Text = prefix .. Fmt(curVal) .. suffix
					end
				end
				UpdateVisuals()

				local dragging  = false
				local dragTarget = "Max"

				local function ShowThumbs(show)
					Tw(thumbMax, { BackgroundTransparency = show and 0 or 1 }, TI(GetTime(0.18)))
					if thumbMin then Tw(thumbMin, { BackgroundTransparency = show and 0 or 1 }, TI(GetTime(0.18))) end
				end

				track.MouseEnter:Connect(function() ShowThumbs(true) end)
				track.MouseLeave:Connect(function() if not dragging then ShowThumbs(false) end end)

				local function UpdateFromInput(inp)
					local pct = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					local v   = Round(mn + (mx - mn) * pct)
					if dual then
						if dragTarget == "Min" then curMin = math.min(v, curMax)
						else curMax = math.max(v, curMin) end
						UpdateVisuals()
						sldCB(curMin, curMax)
					else
						curVal = v
						UpdateVisuals()
						sldCB(curVal)
					end
				end

				track.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						if dual and thumbMin then
							local dx = inp.Position.X
							dragTarget = math.abs(dx - thumbMin.AbsolutePosition.X) < math.abs(dx - thumbMax.AbsolutePosition.X) and "Min" or "Max"
						end
						UpdateFromInput(inp)
					end
				end)
				UIS.InputChanged:Connect(function(inp)
					if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then UpdateFromInput(inp) end
				end)
				UIS.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
						dragging = false
						ShowThumbs(false)
					end
				end)

				local SldObj = {}
				function SldObj:GetValue() return dual and { Min = curMin, Max = curMax } or curVal end
				function SldObj:SetValue(v)
					if dual and type(v) == "table" then curMin = v.Min or mn; curMax = v.Max or mx
					elseif not dual then curVal = math.clamp(v, mn, mx) end
					UpdateVisuals()
				end
				function SldObj:GetComponentType() return "Slider" end
				if opts.Flag then Library.Flags[opts.Flag] = SldObj end
			end

			function ElemFuncs:Dropdown(opts)
				opts = opts or {}
				local options  = opts.Options  or {}
				local multi    = opts.Multi    or false
				local default  = opts.Default  or (multi and {}) or options[1]
				local dropCB   = opts.Callback or function() end

				local selected = multi and (type(default) == "table" and default or {}) or default

				local row = CreateRow(opts.Title or "Dropdown", opts.Description or "")
				local box = N("TextButton", {
					AnchorPoint        = Vector2.new(1, 0.5),
					Position           = UDim2.new(1, -12, 0.5, 0),
					Size               = UDim2.new(0, 152, 0, 26),
					BackgroundColor3   = Library.Theme.BG4,
					Text               = "",
					AutoButtonColor    = false,
					ZIndex             = 3,
					Parent             = row,
				})
				Corner(box, 6)
				Stroke(box, Library.Theme.Border)

				local curLbl = N("TextLabel", {
					Size               = UDim2.new(1, -30, 1, 0),
					Position           = UDim2.new(0, 10, 0, 0),
					BackgroundTransparency = 1,
					Text               = "",
					TextColor3         = Library.Theme.Text,
					TextSize           = 12,
					Font               = Library.Theme.Font,
					TextXAlignment     = Enum.TextXAlignment.Left,
					TextTruncate       = Enum.TextTruncate.AtEnd,
					ZIndex             = 4,
					Parent             = box,
				})

				N("ImageLabel", {
					Size               = UDim2.new(0, 14, 0, 14),
					Position           = UDim2.new(1, -22, 0.5, -7),
					BackgroundTransparency = 1,
					Image              = Assets.Dropdown,
					ImageColor3        = Library.Theme.TextDim,
					ZIndex             = 4,
					Parent             = box,
				})

				local function UpdateText()
					if multi then
						curLbl.Text = #selected == 0 and "Select..." or table.concat(selected, ", ")
					else
						curLbl.Text = tostring(selected or "Select...")
					end
					local tsz    = TX:GetTextSize(curLbl.Text, 12, Library.Theme.Font, Vector2.new(1000, 26)).X
					local targetW = math.clamp(tsz + 42, 152, 270)
					Tw(box, { Size = UDim2.new(0, targetW, 0, 26) }, TI(GetTime(0.2)))
				end
				UpdateText()

				box.MouseEnter:Connect(function() Tw(box, { BackgroundColor3 = Library.Theme.BG3 }, TI(GetTime(0.15))) end)
				box.MouseLeave:Connect(function() Tw(box, { BackgroundColor3 = Library.Theme.BG4 }, TI(GetTime(0.15))) end)

				box.MouseButton1Click:Connect(function()
					OpenPopup(box, function(pop)
						local maxH = math.min(#options * 32, 256)
						local sf = N("ScrollingFrame", {
							Size               = UDim2.new(1, 0, 0, maxH),
							BackgroundTransparency = 1,
							CanvasSize         = UDim2.new(0, 0, 0, 0),
							AutomaticCanvasSize = Enum.AutomaticSize.Y,
							ScrollBarThickness = 2,
							ScrollBarImageColor3 = Library.Theme.Accent,
							ZIndex             = 501,
							Parent             = pop,
						})
						List(sf, 0)
						for _, opt in ipairs(options) do
							local isSel = false
							if multi then
								for _, s in ipairs(selected) do if s == opt then isSel = true; break end end
							else
								isSel = (selected == opt)
							end

							local ob = N("TextButton", {
								Size               = UDim2.new(1, 0, 0, 32),
								BackgroundColor3   = Library.Theme.Accent,
								BackgroundTransparency = isSel and 0.84 or 1,
								Text               = tostring(opt),
								TextColor3         = isSel and Library.Theme.AccentGlow or Library.Theme.TextDim,
								TextSize           = 12,
								Font               = Library.Theme.Font,
								TextXAlignment     = Enum.TextXAlignment.Left,
								AutoButtonColor    = false,
								ZIndex             = 502,
								Parent             = sf,
							})
							Corner(ob, 5)
							Pad(ob, 0, 0, 0, 10)

							ob.MouseEnter:Connect(function()
								if not isSel then Tw(ob, { BackgroundTransparency = 0.92, TextColor3 = Library.Theme.Text }, TI(GetTime(0.12))) end
							end)
							ob.MouseLeave:Connect(function()
								if not isSel then Tw(ob, { BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim }, TI(GetTime(0.12))) end
							end)
							ob.MouseButton1Click:Connect(function()
								if multi then
									local found = false
									for idx, s in ipairs(selected) do
										if s == opt then table.remove(selected, idx); found = true; break end
									end
									if not found then table.insert(selected, opt) end
									isSel = not isSel
									UpdateText()
									dropCB(selected)
								else
									selected = opt
									UpdateText()
									dropCB(opt)
									ClosePopup()
								end
							end)
						end
					end)
				end)

				local DropObj = {}
				function DropObj:GetValue()          return selected end
				function DropObj:SetValue(v)         selected = v; UpdateText() end
				function DropObj:GetOptions()        return options end
				function DropObj:SetOptions(v)       options = v end
				function DropObj:GetComponentType()  return "Dropdown" end
				if opts.Flag then Library.Flags[opts.Flag] = DropObj end
			end

			function ElemFuncs:Textbox(opts)
				opts = opts or {}
				local txtCB = opts.Callback or function() end

				local row = CreateRow(opts.Title or "Textbox", opts.Description or "")
				local box = N("Frame", {
					AnchorPoint        = Vector2.new(1, 0.5),
					Position           = UDim2.new(1, -12, 0.5, 0),
					Size               = UDim2.new(0, 152, 0, 26),
					BackgroundColor3   = Library.Theme.BG4,
					ClipsDescendants   = true,
					ZIndex             = 3,
					Parent             = row,
				})
				Corner(box, 6)
				local boxStroke = Stroke(box, Library.Theme.Border)

				local input = N("TextBox", {
					Size               = UDim2.new(1, -28, 1, 0),
					Position           = UDim2.new(0, 10, 0, 0),
					BackgroundTransparency = 1,
					Text               = opts.Default or "",
					PlaceholderText    = opts.Placeholder or "Enter text...",
					PlaceholderColor3  = Library.Theme.TextFaint,
					TextColor3         = Library.Theme.Text,
					TextSize           = 12,
					Font               = Library.Theme.Font,
					TextXAlignment     = Enum.TextXAlignment.Left,
					ClearTextOnFocus   = opts.ClearOnFocus or false,
					TextTruncate       = Enum.TextTruncate.AtEnd,
					ZIndex             = 4,
					Parent             = box,
				})

				N("ImageLabel", {
					Size               = UDim2.new(0, 12, 0, 12),
					Position           = UDim2.new(1, -18, 0.5, -6),
					BackgroundTransparency = 1,
					Image              = Assets.Textbox,
					ImageColor3        = Library.Theme.TextDim,
					ZIndex             = 4,
					Parent             = box,
				})

				input.Focused:Connect(function()
					Tw(boxStroke, { Color = Library.Theme.Accent }, TI(GetTime(0.2)))
					Tw(box, { BackgroundColor3 = Library.Theme.BG3 }, TI(GetTime(0.2)))
				end)
				input.FocusLost:Connect(function(enter)
					Tw(boxStroke, { Color = Library.Theme.Border }, TI(GetTime(0.2)))
					Tw(box, { BackgroundColor3 = Library.Theme.BG4 }, TI(GetTime(0.2)))
					if enter or not opts.EnterOnly then txtCB(input.Text) end
				end)

				if opts.Numeric then
					input:GetPropertyChangedSignal("Text"):Connect(function()
						local clean = input.Text:gsub("[^%d%.%-]", "")
						if input.Text ~= clean then input.Text = clean end
					end)
				end
				if opts.LiveUpdate then
					input:GetPropertyChangedSignal("Text"):Connect(function() txtCB(input.Text) end)
				end

				local function UpdateWidth()
					local tsz = TX:GetTextSize(input.Text, 12, Library.Theme.Font, Vector2.new(1000, 26)).X
					Tw(box, { Size = UDim2.new(0, math.clamp(tsz + 34, 152, 270), 0, 26) }, TI(GetTime(0.2)))
				end
				input:GetPropertyChangedSignal("Text"):Connect(UpdateWidth)

				local TxtObj = {}
				function TxtObj:GetValue()          return input.Text end
				function TxtObj:SetValue(v)         input.Text = tostring(v); UpdateWidth() end
				function TxtObj:GetComponentType()  return "Textbox" end
				if opts.Flag then Library.Flags[opts.Flag] = TxtObj end
			end

			function ElemFuncs:Label(opts)
				opts = opts or {}
				local row       = CreateRow(opts.Title or "", opts.Description or "")
				local rightSide = N("Frame", {
					Size               = UDim2.new(0, 110, 1, 0),
					Position           = UDim2.new(1, -110, 0, 0),
					BackgroundTransparency = 1,
					Parent             = row,
				})
				List(rightSide, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
				return CreateAttachments(rightSide)
			end

			function ElemFuncs:Paragraph(opts)
				opts = opts or {}
				local parFrame = N("Frame", {
					Size           = UDim2.new(1, 0, 0, 0),
					AutomaticSize  = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Parent         = elemsFrame,
				})
				Pad(parFrame, 10, 14, 10, 14)
				List(parFrame, 5)

				if opts.Title and opts.Title ~= "" then
					N("TextLabel", {
						Size               = UDim2.new(1, 0, 0, 0),
						AutomaticSize      = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						Text               = opts.Title,
						TextColor3         = Library.Theme.Text,
						TextSize           = 13,
						Font               = Library.Theme.FontBold,
						TextXAlignment     = Enum.TextXAlignment.Left,
						TextWrapped        = true,
						Parent             = parFrame,
					})
				end

				N("TextLabel", {
					Size               = UDim2.new(1, 0, 0, 0),
					AutomaticSize      = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Text               = opts.Content or opts.Description or "",
					TextColor3         = Library.Theme.TextDim,
					TextSize           = 12,
					Font               = Library.Theme.Font,
					TextXAlignment     = Enum.TextXAlignment.Left,
					TextWrapped        = true,
					RichText           = true,
					LineHeight         = 1.45,
					Parent             = parFrame,
				})
			end

			function ElemFuncs:Separator(opts)
				opts = opts or {}
				local sf = N("Frame", {
					Size           = UDim2.new(1, 0, 0, 22),
					BackgroundTransparency = 1,
					Parent         = elemsFrame,
				})
				Pad(sf, 0, 14, 0, 14)
				if opts.Title and opts.Title ~= "" then
					N("TextLabel", {
						Size               = UDim2.new(0, 0, 1, 0),
						AutomaticSize      = Enum.AutomaticSize.X,
						BackgroundTransparency = 1,
						Text               = opts.Title:upper(),
						TextColor3         = Library.Theme.TextFaint,
						TextSize           = 9,
						Font               = Library.Theme.FontBold,
						LetterSpacing      = 2,
						Parent             = sf,
					})
				end
				N("Frame", {
					Size             = UDim2.new(1, 0, 0, 1),
					Position         = UDim2.new(0, 0, 1, -1),
					BackgroundColor3 = Library.Theme.Border,
					Parent           = sf,
				})
			end

			return ElemFuncs
		end

		return TabFuncs
	end

	if useLoader then
		local lGui = N("ScreenGui", {
			Name            = "StellarLoader",
			ResetOnSpawn    = false,
			ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
			Enabled         = false,
			Parent          = SafeParent(),
		})

		local lFrame = N("Frame", {
			Size             = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Library.Theme.BG,
			BackgroundTransparency = 1,
			Parent           = lGui,
		})
		N("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 4, 12)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 7, 22)),
			}),
			Rotation = 130,
			Parent   = lFrame,
		})

		local lLeft = N("Frame", {
			Size             = UDim2.new(0.5, 0, 1, 0),
			Position         = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Library.Theme.BG,
			ZIndex           = 5,
			Parent           = lFrame,
		})
		N("UIGradient", {
			Color    = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(5,4,12)), ColorSequenceKeypoint.new(1, Color3.fromRGB(9,6,20)) }),
			Rotation = 45, Parent = lLeft,
		})

		local lRight = N("Frame", {
			Size             = UDim2.new(0.5, 0, 1, 0),
			Position         = UDim2.new(0.5, 0, 0, 0),
			BackgroundColor3 = Library.Theme.BG,
			ZIndex           = 5,
			Parent           = lFrame,
		})
		N("UIGradient", {
			Color    = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(9,6,20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(5,4,12)) }),
			Rotation = 45, Parent = lRight,
		})

		local lCenter = N("Frame", {
			Size               = UDim2.new(0, 360, 0, 210),
			Position           = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint        = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ZIndex             = 10,
			Parent             = lFrame,
		})
		List(lCenter, 10)

		local dots = N("Frame", {
			Size               = UDim2.new(0, 0, 0, 8),
			AutomaticSize      = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			ZIndex             = 11,
			Parent             = lCenter,
		})
		List(dots, 5, Enum.FillDirection.Horizontal)
		for _, alpha in ipairs({ 0, 0.42, 0.72 }) do
			local d = N("Frame", { Size = UDim2.new(0, 7, 0, 7), BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = alpha, ZIndex = 11, Parent = dots })
			Corner(d, 4)
		end

		N("TextLabel", {
			Size               = UDim2.new(1, 0, 0, 46),
			BackgroundTransparency = 1,
			Text               = title,
			TextColor3         = Library.Theme.Text,
			TextSize           = 34,
			Font               = Library.Theme.FontBold,
			TextXAlignment     = Enum.TextXAlignment.Left,
			ZIndex             = 11,
			Parent             = lCenter,
		})

		if subtitle ~= "" then
			N("TextLabel", {
				Size               = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Text               = subtitle,
				TextColor3         = Library.Theme.TextDim,
				TextSize           = 14,
				Font               = Library.Theme.Font,
				TextXAlignment     = Enum.TextXAlignment.Left,
				ZIndex             = 11,
				Parent             = lCenter,
			})
		end

		N("Frame", { Size = UDim2.new(1, 0, 0, 5), BackgroundTransparency = 1, Parent = lCenter })

		local loadLabel = N("TextLabel", {
			Size               = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			Text               = "Initializing...",
			TextColor3         = Library.Theme.TextDim,
			TextSize           = 12,
			Font               = Library.Theme.Font,
			TextXAlignment     = Enum.TextXAlignment.Left,
			ZIndex             = 11,
			Parent             = lCenter,
		})

		local progBG = N("Frame", {
			Size             = UDim2.new(1, 0, 0, 2),
			BackgroundColor3 = Library.Theme.Border,
			ClipsDescendants = true,
			ZIndex           = 11,
			Parent           = lCenter,
		})
		Corner(progBG, 1)

		local progFill = N("Frame", {
			Size             = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Color3.new(1,1,1),
			ZIndex           = 12,
			Parent           = progBG,
		})
		Corner(progFill, 1)
		MakeGrad(progFill, Library.Theme.Accent, Library.Theme.AccentDark, 0)

		local loader = setmetatable({
			_gui    = lGui,
			_frame  = lFrame,
			_left   = lLeft,
			_right  = lRight,
			_center = lCenter,
			_label  = loadLabel,
			_fill   = progFill,
			_active = false,
			_onEnd  = function()
				gui.Enabled = true
				main.Position = UDim2.new(0.5, -350, 0.58, -260)
				main.GroupTransparency = 1
				Tw(main, { Position = UDim2.new(0.5, -350, 0.5, -260), GroupTransparency = 0 }, TI(GetTime(0.65), Enum.EasingStyle.Back))
			end,
		}, LoaderClass)

		return WindowFuncs, loader
	end

	return WindowFuncs
end

return Library
