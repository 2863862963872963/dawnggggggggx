local Library = {}
Library.__index = Library

local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")

local function GetParent()
	local ok, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok then return cg end
	return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local T = {
	BG      = Color3.fromRGB(8,   8,   14),
	BGS     = Color3.fromRGB(13,  13,  20),
	BGT     = Color3.fromRGB(19,  19,  30),
	Ac      = Color3.fromRGB(108, 86,  230),
	AcH     = Color3.fromRGB(132, 110, 255),
	Tx      = Color3.fromRGB(232, 232, 248),
	TxD     = Color3.fromRGB(145, 145, 170),
	Bd      = Color3.fromRGB(36,  36,  56),
	TOn     = Color3.fromRGB(108, 86,  230),
	TOff    = Color3.fromRGB(30,  30,  46),
	White   = Color3.fromRGB(255, 255, 255),
}

local function EI(t, s, d)
	return TweenInfo.new(t, s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out)
end
local ED = EI(0.30)
local ES = EI(0.65)
local EF = EI(0.13)
local EB = EI(0.50, Enum.EasingStyle.Back)
local EN = EI(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function Tw(o, p, e) return TS:Create(o, e or ED, p) end
local function Pl(o, p, e) Tw(o, p, e):Play() end

local function N(cls, props)
	local o = Instance.new(cls)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then o[k] = v end
	end
	if props and props.Parent then o.Parent = props.Parent end
	return o
end

local function AddCorner(p, r)
	N("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p })
end

local function AddStroke(p, c, t)
	return N("UIStroke", {
		Color            = c or T.Bd,
		Thickness        = t or 1,
		ApplyStrokeMode  = Enum.ApplyStrokeMode.Border,
		Parent           = p,
	})
end

local function AddPad(p, v, h)
	N("UIPadding", {
		PaddingTop    = UDim.new(0, v or 8),
		PaddingBottom = UDim.new(0, v or 8),
		PaddingLeft   = UDim.new(0, h or 8),
		PaddingRight  = UDim.new(0, h or 8),
		Parent        = p,
	})
end

local function AddList(p, sp, fd)
	return N("UIListLayout", {
		Padding             = UDim.new(0, sp or 6),
		FillDirection       = fd or Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder           = Enum.SortOrder.LayoutOrder,
		Parent              = p,
	})
end

local function MakeIcon(parent, txt, size, color)
	return N("TextLabel", {
		Size                = UDim2.new(0, size or 18, 0, size or 18),
		BackgroundTransparency = 1,
		Text                = txt,
		TextColor3          = color or T.TxD,
		TextSize            = (size or 18) - 2,
		Font                = Enum.Font.GothamBold,
		TextXAlignment      = Enum.TextXAlignment.Center,
		TextYAlignment      = Enum.TextYAlignment.Center,
		Parent              = parent,
	})
end

local function HoverEffect(frame, enterProps, leaveProps)
	local hb = N("TextButton", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", ZIndex = frame.ZIndex + 1, Parent = frame })
	hb.MouseEnter:Connect(function() Pl(frame, enterProps) end)
	hb.MouseLeave:Connect(function() Pl(frame, leaveProps) end)
	return hb
end

local function MixComponents(cls)

	function cls:Button(cfg)
		cfg = cfg or {}
		local name = cfg.Name or "Button"
		local cb   = cfg.Callback or function() end

		local frame = N("Frame", {
			Size                 = UDim2.new(1, 0, 0, 38),
			BackgroundColor3     = T.BGT,
			BackgroundTransparency = 0.15,
			Parent               = self._c,
		})
		AddCorner(frame, 8)
		local stroke = AddStroke(frame)

		local icon = N("Frame", {
			Size             = UDim2.new(0, 28, 0, 28),
			Position         = UDim2.new(0, 6, 0.5, -14),
			BackgroundColor3 = T.Ac,
			BackgroundTransparency = 0.85,
			Parent           = frame,
		})
		AddCorner(icon, 6)
		MakeIcon(icon, "▸", 14, T.Ac)

		N("TextLabel", {
			Size               = UDim2.new(1, -90, 1, 0),
			Position           = UDim2.new(0, 42, 0, 0),
			BackgroundTransparency = 1,
			Text               = name,
			TextColor3         = T.Tx,
			TextSize           = 13,
			Font               = Enum.Font.GothamMedium,
			TextXAlignment     = Enum.TextXAlignment.Left,
			Parent             = frame,
		})

		local arrowLabel = N("TextLabel", {
			Size               = UDim2.new(0, 22, 1, 0),
			Position           = UDim2.new(1, -26, 0, 0),
			BackgroundTransparency = 1,
			Text               = "›",
			TextColor3         = T.TxD,
			TextSize           = 20,
			Font               = Enum.Font.GothamBold,
			Parent             = frame,
		})

		local btn = N("TextButton", {
			Size               = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			Text               = "",
			ZIndex             = 2,
			Parent             = frame,
		})

		btn.MouseEnter:Connect(function()
			Pl(frame, { BackgroundColor3 = T.Ac, BackgroundTransparency = 0.82 })
			Pl(stroke, { Color = T.Ac })
			Pl(arrowLabel, { TextColor3 = T.AcH })
			Pl(icon, { BackgroundTransparency = 0.6 })
		end)
		btn.MouseLeave:Connect(function()
			Pl(frame, { BackgroundColor3 = T.BGT, BackgroundTransparency = 0.15 })
			Pl(stroke, { Color = T.Bd })
			Pl(arrowLabel, { TextColor3 = T.TxD })
			Pl(icon, { BackgroundTransparency = 0.85 })
		end)
		btn.MouseButton1Down:Connect(function()
			Pl(frame, { BackgroundTransparency = 0.04 }, EF)
			Pl(icon, { BackgroundTransparency = 0.3 }, EF)
		end)
		btn.MouseButton1Up:Connect(function()
			Pl(frame, { BackgroundTransparency = 0.82 }, EF)
			Pl(icon, { BackgroundTransparency = 0.6 }, EF)
		end)
		btn.MouseButton1Click:Connect(cb)

		return self
	end

	function cls:Toggle(cfg)
		cfg = cfg or {}
		local name = cfg.Name or "Toggle"
		local def  = cfg.Default or false
		local cb   = cfg.Callback or function() end
		local state = def

		local frame = N("Frame", {
			Size                 = UDim2.new(1, 0, 0, 38),
			BackgroundColor3     = T.BGT,
			BackgroundTransparency = 0.15,
			Parent               = self._c,
		})
		AddCorner(frame, 8)
		AddStroke(frame)

		N("TextLabel", {
			Size               = UDim2.new(1, -62, 1, 0),
			Position           = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1,
			Text               = name,
			TextColor3         = T.Tx,
			TextSize           = 13,
			Font               = Enum.Font.GothamMedium,
			TextXAlignment     = Enum.TextXAlignment.Left,
			Parent             = frame,
		})

		local track = N("Frame", {
			Size             = UDim2.new(0, 40, 0, 22),
			Position         = UDim2.new(1, -52, 0.5, -11),
			BackgroundColor3 = state and T.TOn or T.TOff,
			Parent           = frame,
		})
		AddCorner(track, 11)
		AddStroke(track, state and T.Ac or T.Bd)

		local knob = N("Frame", {
			Size             = UDim2.new(0, 16, 0, 16),
			Position         = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
			BackgroundColor3 = T.White,
			ZIndex           = 2,
			Parent           = track,
		})
		AddCorner(knob, 8)

		local trackStroke = AddStroke(track, state and T.Ac or T.Bd)

		local function SetToggle(v)
			state = v
			Pl(track, { BackgroundColor3 = state and T.TOn or T.TOff })
			Pl(trackStroke, { Color = state and T.Ac or T.Bd })
			Pl(knob, { Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) })
			cb(state)
		end

		local btn = N("TextButton", {
			Size               = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			Text               = "",
			ZIndex             = 2,
			Parent             = frame,
		})
		btn.MouseEnter:Connect(function() Pl(frame, { BackgroundTransparency = 0.04 }) end)
		btn.MouseLeave:Connect(function() Pl(frame, { BackgroundTransparency = 0.15 }) end)
		btn.MouseButton1Click:Connect(function() SetToggle(not state) end)

		return {
			Get = function() return state end,
			Set = SetToggle,
		}
	end

	function cls:Dropdown(cfg)
		cfg = cfg or {}
		local name = cfg.Name or "Dropdown"
		local opts = cfg.Options or {}
		local def  = cfg.Default or opts[1]
		local cb   = cfg.Callback or function() end
		local sel  = def
		local open = false

		local itemH   = 28
		local padH    = 10
		local dropH   = #opts * itemH + padH * 2 + (#opts - 1) * 3

		local wrapper = N("Frame", {
			Size               = UDim2.new(1, 0, 0, 38),
			BackgroundTransparency = 1,
			ClipsDescendants   = false,
			Parent             = self._c,
		})

		local frame = N("Frame", {
			Size                 = UDim2.new(1, 0, 0, 38),
			BackgroundColor3     = T.BGT,
			BackgroundTransparency = 0.15,
			ClipsDescendants     = false,
			ZIndex               = 5,
			Parent               = wrapper,
		})
		AddCorner(frame, 8)
		AddStroke(frame)

		N("TextLabel", {
			Size               = UDim2.new(0.55, 0, 1, 0),
			Position           = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1,
			Text               = name,
			TextColor3         = T.Tx,
			TextSize           = 13,
			Font               = Enum.Font.GothamMedium,
			TextXAlignment     = Enum.TextXAlignment.Left,
			ZIndex             = 5,
			Parent             = frame,
		})

		local selLabel = N("TextLabel", {
			Size               = UDim2.new(0.35, -28, 1, 0),
			Position           = UDim2.new(0.55, 0, 0, 0),
			BackgroundTransparency = 1,
			Text               = tostring(sel or "Select"),
			TextColor3         = T.TxD,
			TextSize           = 12,
			Font               = Enum.Font.Gotham,
			TextXAlignment     = Enum.TextXAlignment.Right,
			ZIndex             = 5,
			Parent             = frame,
		})

		local arrowLabel = N("TextLabel", {
			Size               = UDim2.new(0, 22, 1, 0),
			Position           = UDim2.new(1, -26, 0, 0),
			BackgroundTransparency = 1,
			Text               = "⌄",
			TextColor3         = T.TxD,
			TextSize           = 14,
			Font               = Enum.Font.GothamBold,
			ZIndex             = 5,
			Parent             = frame,
		})

		local dropdown = N("Frame", {
			Size             = UDim2.new(1, 0, 0, 0),
			Position         = UDim2.new(0, 0, 1, 5),
			BackgroundColor3 = T.BGS,
			ClipsDescendants = true,
			ZIndex           = 20,
			Parent           = frame,
		})
		AddCorner(dropdown, 8)
		AddStroke(dropdown)

		local dropContent = N("Frame", {
			Size               = UDim2.new(1, 0, 0, dropH),
			BackgroundTransparency = 1,
			ZIndex             = 21,
			Parent             = dropdown,
		})
		AddPad(dropContent, padH, 5)
		AddList(dropContent, 3)

		local optButtons = {}
		for _, opt in ipairs(opts) do
			local isSel = tostring(opt) == tostring(sel)
			local ob = N("TextButton", {
				Size               = UDim2.new(1, 0, 0, itemH),
				BackgroundColor3   = T.BGT,
				BackgroundTransparency = isSel and 0.5 or 1,
				Text               = tostring(opt),
				TextColor3         = isSel and T.Ac or T.TxD,
				TextSize           = 12,
				Font               = Enum.Font.Gotham,
				ZIndex             = 22,
				Parent             = dropContent,
			})
			AddCorner(ob, 5)
			optButtons[tostring(opt)] = ob

			ob.MouseEnter:Connect(function()
				if tostring(opt) ~= tostring(sel) then
					Pl(ob, { BackgroundTransparency = 0.75, TextColor3 = T.Tx })
				end
			end)
			ob.MouseLeave:Connect(function()
				if tostring(opt) ~= tostring(sel) then
					Pl(ob, { BackgroundTransparency = 1, TextColor3 = T.TxD })
				end
			end)
			ob.MouseButton1Click:Connect(function()
				local prev = tostring(sel)
				sel = opt
				selLabel.Text = tostring(opt)

				if optButtons[prev] then
					Pl(optButtons[prev], { BackgroundTransparency = 1, TextColor3 = T.TxD })
				end
				Pl(ob, { BackgroundTransparency = 0.5, TextColor3 = T.Ac })

				open = false
				Pl(dropdown, { Size = UDim2.new(1, 0, 0, 0) })
				Pl(arrowLabel, { Rotation = 0 })
				Pl(wrapper, { Size = UDim2.new(1, 0, 0, 38) })
				cb(opt)
			end)
		end

		local hBtn = N("TextButton", {
			Size               = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text               = "",
			ZIndex             = 10,
			Parent             = frame,
		})
		hBtn.MouseEnter:Connect(function() Pl(frame, { BackgroundTransparency = 0.04 }) end)
		hBtn.MouseLeave:Connect(function() Pl(frame, { BackgroundTransparency = 0.15 }) end)
		hBtn.MouseButton1Click:Connect(function()
			open = not open
			if open then
				Pl(dropdown, { Size = UDim2.new(1, 0, 0, dropH) }, EB)
				Pl(arrowLabel, { Rotation = 180 })
				Pl(wrapper, { Size = UDim2.new(1, 0, 0, 38 + dropH + 5) })
			else
				Pl(dropdown, { Size = UDim2.new(1, 0, 0, 0) })
				Pl(arrowLabel, { Rotation = 0 })
				Pl(wrapper, { Size = UDim2.new(1, 0, 0, 38) })
			end
		end)

		return {
			Get = function() return sel end,
			Set = function(v)
				local prev = tostring(sel)
				sel = v
				selLabel.Text = tostring(v)
				if optButtons[prev] then Pl(optButtons[prev], { BackgroundTransparency = 1, TextColor3 = T.TxD }) end
				if optButtons[tostring(v)] then Pl(optButtons[tostring(v)], { BackgroundTransparency = 0.5, TextColor3 = T.Ac }) end
				cb(v)
			end,
		}
	end

	function cls:Input(cfg)
		cfg = cfg or {}
		local name  = cfg.Name or "Input"
		local ph    = cfg.Placeholder or "Enter value..."
		local num   = cfg.Numeric or false
		local cb    = cfg.Callback or function() end
		local live  = cfg.LiveUpdate or false

		local frame = N("Frame", {
			Size                 = UDim2.new(1, 0, 0, 64),
			BackgroundColor3     = T.BGT,
			BackgroundTransparency = 0.15,
			Parent               = self._c,
		})
		AddCorner(frame, 8)
		AddStroke(frame)

		N("TextLabel", {
			Size               = UDim2.new(1, -16, 0, 22),
			Position           = UDim2.new(0, 12, 0, 6),
			BackgroundTransparency = 1,
			Text               = name,
			TextColor3         = T.Tx,
			TextSize           = 13,
			Font               = Enum.Font.GothamMedium,
			TextXAlignment     = Enum.TextXAlignment.Left,
			Parent             = frame,
		})

		local inputFrame = N("Frame", {
			Size             = UDim2.new(1, -24, 0, 26),
			Position         = UDim2.new(0, 12, 0, 32),
			BackgroundColor3 = T.BGS,
			BackgroundTransparency = 0.1,
			Parent           = frame,
		})
		AddCorner(inputFrame, 6)
		local inputStroke = AddStroke(inputFrame, T.Bd)

		local inputBox = N("TextBox", {
			Size               = UDim2.new(1, -16, 1, 0),
			Position           = UDim2.new(0, 8, 0, 0),
			BackgroundTransparency = 1,
			Text               = cfg.Default or "",
			PlaceholderText    = ph,
			PlaceholderColor3  = T.TxD,
			TextColor3         = T.Tx,
			TextSize           = 12,
			Font               = Enum.Font.Gotham,
			TextXAlignment     = Enum.TextXAlignment.Left,
			ClearTextOnFocus   = false,
			Parent             = inputFrame,
		})

		inputBox.Focused:Connect(function()
			Pl(inputStroke, { Color = T.Ac })
			Pl(inputFrame, { BackgroundTransparency = 0.0 })
		end)
		inputBox.FocusLost:Connect(function(enter)
			Pl(inputStroke, { Color = T.Bd })
			Pl(inputFrame, { BackgroundTransparency = 0.1 })
			if enter then cb(inputBox.Text) end
		end)

		if num then
			inputBox:GetPropertyChangedSignal("Text"):Connect(function()
				local clean = inputBox.Text:gsub("[^%d%.%-]", "")
				if inputBox.Text ~= clean then inputBox.Text = clean end
			end)
		end

		if live then
			inputBox:GetPropertyChangedSignal("Text"):Connect(function()
				cb(inputBox.Text)
			end)
		end

		return {
			Get = function() return inputBox.Text end,
			Set = function(v) inputBox.Text = tostring(v) end,
		}
	end

	function cls:Slider(cfg)
		cfg = cfg or {}
		local name = cfg.Name or "Slider"
		local mn   = cfg.Min or 0
		local mx   = cfg.Max or 100
		local suf  = cfg.Suffix or ""
		local cb   = cfg.Callback or function() end
		local dec  = cfg.Decimals or 0
		local val  = math.clamp(cfg.Default or mn, mn, mx)

		local frame = N("Frame", {
			Size                 = UDim2.new(1, 0, 0, 56),
			BackgroundColor3     = T.BGT,
			BackgroundTransparency = 0.15,
			Parent               = self._c,
		})
		AddCorner(frame, 8)
		AddStroke(frame)

		N("TextLabel", {
			Size               = UDim2.new(0.65, 0, 0, 22),
			Position           = UDim2.new(0, 12, 0, 7),
			BackgroundTransparency = 1,
			Text               = name,
			TextColor3         = T.Tx,
			TextSize           = 13,
			Font               = Enum.Font.GothamMedium,
			TextXAlignment     = Enum.TextXAlignment.Left,
			Parent             = frame,
		})

		local function Fmt(v)
			if dec > 0 then
				return string.format("%." .. dec .. "f", v) .. suf
			end
			return tostring(math.floor(v + 0.5)) .. suf
		end

		local valLabel = N("TextLabel", {
			Size               = UDim2.new(0.35, -12, 0, 22),
			Position           = UDim2.new(0.65, 0, 0, 7),
			BackgroundTransparency = 1,
			Text               = Fmt(val),
			TextColor3         = T.Ac,
			TextSize           = 13,
			Font               = Enum.Font.GothamBold,
			TextXAlignment     = Enum.TextXAlignment.Right,
			Parent             = frame,
		})

		local trackBG = N("Frame", {
			Size             = UDim2.new(1, -24, 0, 4),
			Position         = UDim2.new(0, 12, 0, 42),
			BackgroundColor3 = T.BGS,
			Parent           = frame,
		})
		AddCorner(trackBG, 2)

		local pct0 = (val - mn) / (mx - mn)
		local fill = N("Frame", {
			Size             = UDim2.new(pct0, 0, 1, 0),
			BackgroundColor3 = T.Ac,
			Parent           = trackBG,
		})
		AddCorner(fill, 2)

		local knob = N("Frame", {
			Size             = UDim2.new(0, 14, 0, 14),
			Position         = UDim2.new(pct0, -7, 0.5, -7),
			BackgroundColor3 = T.White,
			ZIndex           = 3,
			Parent           = trackBG,
		})
		AddCorner(knob, 7)
		N("UIStroke", { Color = T.Ac, Thickness = 2, Parent = knob })

		local dragging = false

		local function UpdateVal(x)
			local rel = math.clamp((x - trackBG.AbsolutePosition.X) / trackBG.AbsoluteSize.X, 0, 1)
			if dec > 0 then
				local step = 10^dec
				val = math.floor((mn + rel * (mx - mn)) * step + 0.5) / step
			else
				val = math.floor(mn + rel * (mx - mn) + 0.5)
			end
			val = math.clamp(val, mn, mx)
			local p = (val - mn) / (mx - mn)
			Pl(fill, { Size = UDim2.new(p, 0, 1, 0) }, EF)
			Pl(knob, { Position = UDim2.new(p, -7, 0.5, -7) }, EF)
			valLabel.Text = Fmt(val)
			cb(val)
		end

		local sBtn = N("TextButton", {
			Size               = UDim2.new(1, 0, 0, 24),
			Position           = UDim2.new(0, 0, 0.5, -12),
			BackgroundTransparency = 1,
			Text               = "",
			ZIndex             = 4,
			Parent             = trackBG,
		})
		sBtn.MouseButton1Down:Connect(function(x, _) dragging = true; UpdateVal(x) end)
		UIS.InputChanged:Connect(function(inp)
			if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
				UpdateVal(inp.Position.X)
			end
		end)
		UIS.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		return {
			Get = function() return val end,
			Set = function(v)
				val = math.clamp(v, mn, mx)
				local p = (val - mn) / (mx - mn)
				Pl(fill, { Size = UDim2.new(p, 0, 1, 0) })
				Pl(knob, { Position = UDim2.new(p, -7, 0.5, -7) })
				valLabel.Text = Fmt(val)
			end,
		}
	end

	function cls:Paragraph(cfg)
		cfg = cfg or {}
		local title   = cfg.Title or ""
		local content = cfg.Content or ""

		local frame = N("Frame", {
			Size                 = UDim2.new(1, 0, 0, 0),
			AutomaticSize        = Enum.AutomaticSize.Y,
			BackgroundColor3     = T.BGT,
			BackgroundTransparency = 0.3,
			Parent               = self._c,
		})
		AddCorner(frame, 8)
		AddStroke(frame)
		AddPad(frame, 10, 12)
		AddList(frame, 5)

		if title ~= "" then
			N("TextLabel", {
				Size               = UDim2.new(1, 0, 0, 0),
				AutomaticSize      = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Text               = title,
				TextColor3         = T.Tx,
				TextSize           = 13,
				Font               = Enum.Font.GothamBold,
				TextXAlignment     = Enum.TextXAlignment.Left,
				TextWrapped        = true,
				Parent             = frame,
			})
		end

		N("TextLabel", {
			Size               = UDim2.new(1, 0, 0, 0),
			AutomaticSize      = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text               = content,
			TextColor3         = T.TxD,
			TextSize           = 12,
			Font               = Enum.Font.Gotham,
			TextXAlignment     = Enum.TextXAlignment.Left,
			TextWrapped        = true,
			RichText           = true,
			LineHeight         = 1.4,
			Parent             = frame,
		})

		return self
	end

end

local SectionClass = {}
SectionClass.__index = SectionClass
MixComponents(SectionClass)

local TabClass = {}
TabClass.__index = TabClass
MixComponents(TabClass)

function TabClass:Section(name)
	local secWrap = N("Frame", {
		Size              = UDim2.new(1, 0, 0, 0),
		AutomaticSize     = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent            = self._c,
	})
	AddList(secWrap, 6)

	local headerRow = N("Frame", {
		Size               = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Parent             = secWrap,
	})

	N("TextLabel", {
		Size               = UDim2.new(0, 0, 1, 0),
		AutomaticSize      = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text               = (name or "Section"):upper(),
		TextColor3         = T.TxD,
		TextSize           = 10,
		Font               = Enum.Font.GothamBold,
		TextXAlignment     = Enum.TextXAlignment.Left,
		LetterSpacing      = 2,
		Parent             = headerRow,
	})

	local dividerFrame = N("Frame", {
		Size               = UDim2.new(1, 0, 0, 1),
		BackgroundColor3   = T.Bd,
		Parent             = secWrap,
	})

	local gradient = N("UIGradient", {
		Color   = ColorSequence.new({
			ColorSequenceKeypoint.new(0, T.Ac),
			ColorSequenceKeypoint.new(0.3, T.Bd),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
		}),
		Transparency = NumberSequence.new(0),
		Parent = dividerFrame,
	})

	local secContent = N("Frame", {
		Size              = UDim2.new(1, 0, 0, 0),
		AutomaticSize     = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent            = secWrap,
	})
	AddList(secContent, 5)

	return setmetatable({ _c = secContent }, SectionClass)
end

local WindowClass = {}
WindowClass.__index = WindowClass
MixComponents(WindowClass)

function WindowClass:Tab(name)
	local isFirst = #self._tabs == 0

	local tabBtn = N("TextButton", {
		Size               = UDim2.new(0, 0, 1, -8),
		Position           = UDim2.new(0, 0, 0.5, 0),
		AutomaticSize      = Enum.AutomaticSize.X,
		BackgroundColor3   = isFirst and T.BGT or Color3.new(0,0,0),
		BackgroundTransparency = isFirst and 0.4 or 1,
		Text               = "",
		AutoButtonColor    = false,
		Parent             = self._tabBar,
	})
	AddCorner(tabBtn, 6)
	AddPad(tabBtn, 0, 10)

	local tabLabel = N("TextLabel", {
		Size               = UDim2.new(0, 0, 1, 0),
		AutomaticSize      = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text               = name or "Tab",
		TextColor3         = isFirst and T.Tx or T.TxD,
		TextSize           = 13,
		Font               = isFirst and Enum.Font.GothamBold or Enum.Font.GothamMedium,
		Parent             = tabBtn,
	})

	local indicator = N("Frame", {
		Size             = UDim2.new(1, 0, 0, 2),
		Position         = UDim2.new(0, 0, 1, 1),
		BackgroundColor3 = T.Ac,
		BackgroundTransparency = isFirst and 0 or 1,
		Parent           = tabBtn,
	})
	AddCorner(indicator, 1)

	local tabContent = N("ScrollingFrame", {
		Size               = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel    = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = T.Ac,
		ScrollBarImageTransparency = 0.4,
		CanvasSize         = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible            = isFirst,
		Parent             = self._body,
	})
	AddPad(tabContent, 10, 8)
	AddList(tabContent, 8)

	local tab = setmetatable({
		_c   = tabContent,
		_btn = tabBtn,
		_ind = indicator,
		_lbl = tabLabel,
		_win = self,
	}, TabClass)

	table.insert(self._tabs, tab)

	tabBtn.MouseEnter:Connect(function()
		if self._activeTab ~= tab then
			Pl(tabLabel, { TextColor3 = T.Tx })
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if self._activeTab ~= tab then
			Pl(tabLabel, { TextColor3 = T.TxD })
		end
	end)
	tabBtn.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	if isFirst then
		self._activeTab = tab
	end

	return tab
end

function WindowClass:SelectTab(tab)
	for _, t in ipairs(self._tabs) do
		t._c.Visible = false
		Pl(t._lbl, { TextColor3 = T.TxD, Font = Enum.Font.GothamMedium })
		Pl(t._ind, { BackgroundTransparency = 1 })
		Pl(t._btn, { BackgroundTransparency = 1 })
	end
	tab._c.Visible = true
	Pl(tab._lbl, { TextColor3 = T.Tx, Font = Enum.Font.GothamBold })
	Pl(tab._ind, { BackgroundTransparency = 0 })
	Pl(tab._btn, { BackgroundTransparency = 0.4 })
	self._activeTab = tab
end

local LoaderClass = {}
LoaderClass.__index = LoaderClass

function LoaderClass:Start()
	self._running = true
	self._gui.Enabled = true

	local frame = self._frame
	frame.BackgroundTransparency = 1
	Pl(frame, { BackgroundTransparency = 0 }, ES)

	task.delay(0.1, function()
		for _, d in ipairs(frame:GetDescendants()) do
			if d:IsA("TextLabel") then
				local orig = d.TextTransparency
				d.TextTransparency = 1
				Pl(d, { TextTransparency = orig }, ES)
			elseif d:IsA("Frame") and d ~= self._leftPanel and d ~= self._rightPanel and d.Name ~= "LoaderProgress" then
				local orig = d.BackgroundTransparency
				if orig < 1 then
					d.BackgroundTransparency = 1
					Pl(d, { BackgroundTransparency = orig }, ES)
				end
			end
		end
	end)

	task.spawn(function()
		local bar    = self._progressBar
		local barFill = self._progressFill

		while self._running do
			bar.BackgroundTransparency = 0.5
			barFill.Position  = UDim2.new(-0.25, 0, 0, 0)
			barFill.Size      = UDim2.new(0.25, 0, 1, 0)
			Tw(barFill, { Position = UDim2.new(1.0, 0, 0, 0) }, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)):Play()
			task.wait(0.95)
		end
	end)
end

function LoaderClass:SetText(text)
	local lbl = self._loadLabel
	Pl(lbl, { TextTransparency = 1 }, EF)
	task.wait(0.14)
	if lbl and lbl.Parent then
		lbl.Text = text
		Pl(lbl, { TextTransparency = 0 }, EF)
	end
end

function LoaderClass:End()
	self._running = false

	local ct = self._centerContent
	local lp = self._leftPanel
	local rp = self._rightPanel

	for _, d in ipairs(ct:GetDescendants()) do
		if d:IsA("TextLabel") then
			Pl(d, { TextTransparency = 1 }, EF)
		elseif d:IsA("Frame") and d.BackgroundTransparency < 1 then
			Pl(d, { BackgroundTransparency = 1 }, EF)
		end
	end
	task.wait(0.18)

	Pl(lp, { Position = UDim2.new(-0.5, 0, 0, 0) }, ES)
	Pl(rp, { Position = UDim2.new(1.0, 0, 0, 0) }, ES)
	task.wait(0.7)

	self._gui:Destroy()

	if self._window then
		local wGui  = self._window._gui
		local wFrame = self._window._mainFrame
		wGui.Enabled = true
		wFrame.Position = UDim2.new(0.5, 0, 0.58, 0)
		wFrame.BackgroundTransparency = 1
		Pl(wFrame, { Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 0 }, EB)
		for _, d in ipairs(wFrame:GetDescendants()) do
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
				d.TextTransparency = 1
				Pl(d, { TextTransparency = 0 }, ES)
			elseif d:IsA("ImageLabel") then
				d.ImageTransparency = 1
				Pl(d, { ImageTransparency = 0 }, ES)
			end
		end
	end
end

function Library:Create(config)
	config = config or {}
	local title    = config.Title or "Library"
	local subtitle = config.SubTitle or ""
	local version  = config.Version or ""
	local useLoader = config.Loader or false

	local windowGui = N("ScreenGui", {
		Name              = "LibUI_" .. title,
		ResetOnSpawn      = false,
		ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
		Enabled           = not useLoader,
		Parent            = GetParent(),
	})

	local mainFrame = N("Frame", {
		Name                 = "MainFrame",
		Size                 = UDim2.new(0, 560, 0, 380),
		Position             = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint          = Vector2.new(0.5, 0.5),
		BackgroundColor3     = T.BG,
		BackgroundTransparency = 0.06,
		ClipsDescendants     = true,
		Parent               = windowGui,
	})
	AddCorner(mainFrame, 12)
	AddStroke(mainFrame, T.Bd, 1)

	N("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 16, 40)),
			ColorSequenceKeypoint.new(0.5, T.BG),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 8, 24)),
		}),
		Rotation = 135,
		Parent   = mainFrame,
	})

	local noiseBG = N("ImageLabel", {
		Size               = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image              = "rbxassetid://9968344227",
		ImageTransparency  = 0.95,
		ScaleType          = Enum.ScaleType.Tile,
		TileSize           = UDim2.new(0, 64, 0, 64),
		ZIndex             = 0,
		Parent             = mainFrame,
	})

	local header = N("Frame", {
		Name             = "Header",
		Size             = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = T.BGS,
		BackgroundTransparency = 0.3,
		ZIndex           = 2,
		Parent           = mainFrame,
	})
	N("UICorner", { CornerRadius = UDim.new(0, 12), Parent = header })
	N("Frame", { Size = UDim2.new(1, 0, 0.5, 0), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = T.BGS, BackgroundTransparency = 0.3, ZIndex = 1, Parent = header })
	AddStroke(header, T.Bd)

	local accentBar = N("Frame", {
		Size             = UDim2.new(0, 3, 0, 28),
		Position         = UDim2.new(0, 14, 0.5, -14),
		BackgroundColor3 = T.Ac,
		ZIndex           = 3,
		Parent           = header,
	})
	AddCorner(accentBar, 2)
	N("UIGradient", {
		Color    = ColorSequence.new({
			ColorSequenceKeypoint.new(0, T.AcH),
			ColorSequenceKeypoint.new(1, T.Ac),
		}),
		Rotation = 90,
		Parent   = accentBar,
	})

	local titleLabel = N("TextLabel", {
		Size               = UDim2.new(0, 200, 0, 24),
		Position           = UDim2.new(0, 26, 0, 6),
		BackgroundTransparency = 1,
		Text               = title,
		TextColor3         = T.Tx,
		TextSize           = 16,
		Font               = Enum.Font.GothamBold,
		TextXAlignment     = Enum.TextXAlignment.Left,
		ZIndex             = 3,
		Parent             = header,
	})

	local subRow = N("Frame", {
		Size               = UDim2.new(0, 300, 0, 16),
		Position           = UDim2.new(0, 26, 0, 30),
		BackgroundTransparency = 1,
		ZIndex             = 3,
		Parent             = header,
	})
	AddList(subRow, 6, Enum.FillDirection.Horizontal)

	if subtitle ~= "" then
		N("TextLabel", {
			Size               = UDim2.new(0, 0, 1, 0),
			AutomaticSize      = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Text               = subtitle,
			TextColor3         = T.TxD,
			TextSize           = 11,
			Font               = Enum.Font.Gotham,
			ZIndex             = 3,
			Parent             = subRow,
		})
	end

	if version ~= "" then
		local verPill = N("Frame", {
			Size               = UDim2.new(0, 0, 1, 0),
			AutomaticSize      = Enum.AutomaticSize.X,
			BackgroundColor3   = T.Ac,
			BackgroundTransparency = 0.8,
			ZIndex             = 3,
			Parent             = subRow,
		})
		AddCorner(verPill, 4)
		AddPad(verPill, 0, 5)
		N("TextLabel", {
			Size               = UDim2.new(0, 0, 1, 0),
			AutomaticSize      = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Text               = version,
			TextColor3         = T.Ac,
			TextSize           = 10,
			Font               = Enum.Font.GothamBold,
			ZIndex             = 4,
			Parent             = verPill,
		})
	end

	local btnSize = UDim2.new(0, 22, 0, 22)

	local closeBtn = N("TextButton", {
		Size               = btnSize,
		Position           = UDim2.new(1, -30, 0.5, -11),
		BackgroundColor3   = Color3.fromRGB(220, 70, 70),
		BackgroundTransparency = 0.4,
		Text               = "×",
		TextColor3         = T.White,
		TextSize           = 15,
		Font               = Enum.Font.GothamBold,
		ZIndex             = 5,
		Parent             = header,
	})
	AddCorner(closeBtn, 6)

	local minBtn = N("TextButton", {
		Size               = btnSize,
		Position           = UDim2.new(1, -56, 0.5, -11),
		BackgroundColor3   = Color3.fromRGB(230, 165, 50),
		BackgroundTransparency = 0.4,
		Text               = "–",
		TextColor3         = T.White,
		TextSize           = 13,
		Font               = Enum.Font.GothamBold,
		ZIndex             = 5,
		Parent             = header,
	})
	AddCorner(minBtn, 6)

	closeBtn.MouseEnter:Connect(function() Pl(closeBtn, { BackgroundTransparency = 0.1 }) end)
	closeBtn.MouseLeave:Connect(function() Pl(closeBtn, { BackgroundTransparency = 0.4 }) end)
	closeBtn.MouseButton1Click:Connect(function()
		Pl(mainFrame, { BackgroundTransparency = 1 }, EF)
		task.wait(0.15)
		windowGui:Destroy()
	end)

	local minimized = false
	local fullSize  = mainFrame.Size
	local miniSize  = UDim2.new(0, 560, 0, 50)

	minBtn.MouseEnter:Connect(function() Pl(minBtn, { BackgroundTransparency = 0.1 }) end)
	minBtn.MouseLeave:Connect(function() Pl(minBtn, { BackgroundTransparency = 0.4 }) end)
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			Pl(mainFrame, { Size = miniSize }, EB)
		else
			Pl(mainFrame, { Size = fullSize }, EB)
		end
	end)

	local dragging    = false
	local dragStart   = Vector2.new()
	local frameStart  = Vector2.new()

	local dragTarget = N("TextButton", {
		Size               = UDim2.new(1, -120, 1, 0),
		BackgroundTransparency = 1,
		Text               = "",
		ZIndex             = 4,
		Parent             = header,
	})

	dragTarget.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging   = true
			dragStart  = inp.Position
			local ap   = mainFrame.AbsolutePosition
			frameStart = Vector2.new(ap.X + mainFrame.AbsoluteSize.X / 2, ap.Y + mainFrame.AbsoluteSize.Y / 2)
		end
	end)

	UIS.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = inp.Position - dragStart
			local vp    = workspace.CurrentCamera.ViewportSize
			local nx    = (frameStart.X + delta.X) / vp.X
			local ny    = (frameStart.Y + delta.Y) / vp.Y
			mainFrame.Position = UDim2.new(nx, 0, ny, 0)
		end
	end)

	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	local tabBar = N("Frame", {
		Name             = "TabBar",
		Size             = UDim2.new(1, 0, 0, 36),
		Position         = UDim2.new(0, 0, 0, 50),
		BackgroundColor3 = T.BGS,
		BackgroundTransparency = 0.5,
		ZIndex           = 2,
		Parent           = mainFrame,
	})
	AddPad(tabBar, 0, 10)
	AddList(tabBar, 4, Enum.FillDirection.Horizontal)
	AddStroke(tabBar, T.Bd)
	N("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = T.Bd, ZIndex = 3, Parent = tabBar })

	local body = N("Frame", {
		Name             = "Body",
		Size             = UDim2.new(1, -16, 1, -94),
		Position         = UDim2.new(0, 8, 0, 88),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent           = mainFrame,
	})

	local window = setmetatable({
		_gui       = windowGui,
		_mainFrame = mainFrame,
		_tabBar    = tabBar,
		_body      = body,
		_tabs      = {},
		_activeTab = nil,
		_c         = nil,
	}, WindowClass)

	window._c = body

	if useLoader then
		local loaderGui = N("ScreenGui", {
			Name           = "LibLoader_" .. title,
			ResetOnSpawn   = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Enabled        = false,
			Parent         = GetParent(),
		})

		local loaderFrame = N("Frame", {
			Size             = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = T.BG,
			BackgroundTransparency = 1,
			ZIndex           = 1,
			Parent           = loaderGui,
		})
		N("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 5, 12)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 10, 28)),
			}),
			Rotation = 135,
			Parent   = loaderFrame,
		})

		local leftPanel = N("Frame", {
			Name             = "LeftPanel",
			Size             = UDim2.new(0.5, 0, 1, 0),
			Position         = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = T.BG,
			ZIndex           = 2,
			Parent           = loaderFrame,
		})
		N("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 5, 12)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 10, 28)),
			}),
			Rotation = 45,
			Parent   = leftPanel,
		})

		local rightPanel = N("Frame", {
			Name             = "RightPanel",
			Size             = UDim2.new(0.5, 0, 1, 0),
			Position         = UDim2.new(0.5, 0, 0, 0),
			BackgroundColor3 = T.BG,
			ZIndex           = 2,
			Parent           = loaderFrame,
		})
		N("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 10, 28)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 5, 12)),
			}),
			Rotation = 45,
			Parent   = rightPanel,
		})

		local centerContent = N("Frame", {
			Name               = "CenterContent",
			Size               = UDim2.new(0, 320, 0, 200),
			Position           = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint        = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ZIndex             = 10,
			Parent             = loaderFrame,
		})
		AddList(centerContent, 10)

		local dotRow = N("Frame", {
			Size               = UDim2.new(1, 0, 0, 10),
			BackgroundTransparency = 1,
			ZIndex             = 11,
			Parent             = centerContent,
		})
		AddList(dotRow, 6, Enum.FillDirection.Horizontal)
		N("Frame", { Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = T.Ac, ZIndex = 11, Parent = dotRow })
		N("Frame", { Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = T.AcH, BackgroundTransparency = 0.4, ZIndex = 11, Parent = dotRow })
		N("Frame", { Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = T.Ac, BackgroundTransparency = 0.7, ZIndex = 11, Parent = dotRow })

		for _, d in ipairs(dotRow:GetChildren()) do
			if d:IsA("Frame") then AddCorner(d, 4) end
		end

		N("TextLabel", {
			Size               = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			Text               = title,
			TextColor3         = T.Tx,
			TextSize           = 30,
			Font               = Enum.Font.GothamBold,
			TextXAlignment     = Enum.TextXAlignment.Left,
			ZIndex             = 11,
			Parent             = centerContent,
		})

		if subtitle ~= "" then
			N("TextLabel", {
				Size               = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Text               = subtitle,
				TextColor3         = T.TxD,
				TextSize           = 14,
				Font               = Enum.Font.Gotham,
				TextXAlignment     = Enum.TextXAlignment.Left,
				ZIndex             = 11,
				Parent             = centerContent,
			})
		end

		local spacer = N("Frame", { Size = UDim2.new(1, 0, 0, 8), BackgroundTransparency = 1, Parent = centerContent })

		local loadLabel = N("TextLabel", {
			Size               = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Text               = "Initializing...",
			TextColor3         = T.TxD,
			TextSize           = 12,
			Font               = Enum.Font.Gotham,
			TextXAlignment     = Enum.TextXAlignment.Left,
			ZIndex             = 11,
			Parent             = centerContent,
		})

		local progressBG = N("Frame", {
			Name             = "LoaderProgress",
			Size             = UDim2.new(1, 0, 0, 2),
			BackgroundColor3 = T.Bd,
			BackgroundTransparency = 0.5,
			ClipsDescendants = true,
			ZIndex           = 11,
			Parent           = centerContent,
		})
		AddCorner(progressBG, 1)

		local progressFill = N("Frame", {
			Size             = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = T.Ac,
			ZIndex           = 12,
			Parent           = progressBG,
		})
		AddCorner(progressFill, 1)
		N("UIGradient", {
			Color    = ColorSequence.new({
				ColorSequenceKeypoint.new(0, T.Ac),
				ColorSequenceKeypoint.new(1, T.AcH),
			}),
			Parent = progressFill,
		})

		local loader = setmetatable({
			_gui           = loaderGui,
			_frame         = loaderFrame,
			_leftPanel     = leftPanel,
			_rightPanel    = rightPanel,
			_centerContent = centerContent,
			_loadLabel     = loadLabel,
			_progressBar   = progressBG,
			_progressFill  = progressFill,
			_window        = window,
			_running       = false,
		}, LoaderClass)

		return window, loader
	end

	local tw = Tw(mainFrame, { BackgroundTransparency = 0 })
	tw:Play()

	return window
end

return Library
