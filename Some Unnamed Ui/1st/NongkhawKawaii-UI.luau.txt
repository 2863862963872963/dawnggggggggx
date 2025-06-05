local Env: table = {}

local TweenService: TweenService = game:GetService("TweenService")
local UserInputService: UserInputService = game:GetService("UserInputService")

GetIcon = function(i)
	if type(i) == 'string' and not i:find('rbxassetid://') then
		return "rbxassetid://".. i
	elseif type(i) == 'number' then
		return "rbxassetid://".. i
	else
		return i
	end
end

tw = function(info)
	return TweenService:Create(info.v, TweenInfo.new(info.t, Enum.EasingStyle[info.s], Enum.EasingDirection[info.d]), info.g)
end

lak = function(a)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		local Tween = game:GetService("TweenService"):Create(a, TweenInfo.new(0.3), {Position = pos})
		Tween:Play()
	end

	a.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = a.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	a.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end

click = function(p)
	local Click = Instance.new("TextButton")

	Click.Name = "Click"
	Click.Parent = p
	Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Click.BackgroundTransparency = 1.000
	Click.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Click.BorderSizePixel = 0
	Click.Size = UDim2.new(1, 0, 1, 0)
	Click.Font = Enum.Font.SourceSans
	Click.Text = ""
	Click.TextColor3 = Color3.fromRGB(0, 0, 0)
	Click.TextSize = 14.000

	return Click
end

EffectClick = function(c, p)
	local Mouse = game.Players.LocalPlayer:GetMouse()

	local relativeX = Mouse.X - c.AbsolutePosition.X
	local relativeY = Mouse.Y - c.AbsolutePosition.Y

	if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then
		return
	end

	local ClickButtonCircle = Instance.new("Frame")
	ClickButtonCircle.Parent = p
	ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ClickButtonCircle.BackgroundTransparency = 0.5
	ClickButtonCircle.BorderSizePixel = 0
	ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	ClickButtonCircle.Position = UDim2.new(0, relativeX, 0, relativeY)
	ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
	ClickButtonCircle.ZIndex = 10

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = ClickButtonCircle

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local goal = {
		Size = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
		BackgroundTransparency = 1
	}

	local expandTween = TweenService:Create(ClickButtonCircle, tweenInfo, goal)

	expandTween.Completed:Connect(function()
		ClickButtonCircle:Destroy()
	end)

	expandTween:Play()
end

EffectClick2 = function(c, p)
	local Mouse = game.Players.LocalPlayer:GetMouse()

	local relativeX = Mouse.X - c.AbsolutePosition.X
	local relativeY = Mouse.Y - c.AbsolutePosition.Y

	if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then
		return
	end

	local ClickButtonCircle = Instance.new("Frame")
	ClickButtonCircle.Parent = p
	ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ClickButtonCircle.BackgroundTransparency = 0.5
	ClickButtonCircle.BorderSizePixel = 0
	ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	ClickButtonCircle.Position = UDim2.new(0, relativeX, 0, relativeY)
	ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
	ClickButtonCircle.ZIndex = 10

	local UIGradient_2 = Instance.new("UIGradient")
	UIGradient_2.Parent = ClickButtonCircle
	UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
	UIGradient_2.Rotation = 48

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = ClickButtonCircle

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local goal = {
		Size = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
		BackgroundTransparency = 1
	}

	local expandTween = TweenService:Create(ClickButtonCircle, tweenInfo, goal)

	expandTween.Completed:Connect(function()
		ClickButtonCircle:Destroy()
	end)

	expandTween:Play()
end

local Khaw = Instance.new("ScreenGui")
Khaw.Name = "Khaw"
Khaw.Parent = not game:GetService("RunService"):IsStudio() and game:GetService("CoreGui") or game:GetService("Players").LocalPlayer.PlayerGui
Khaw.ZIndexBehavior = Enum.ZIndexBehavior.Global

function Env:Window(meta)
	local Title = meta.Title or "Title"
	local Desc = meta.Desc or "Desc"
	local Logo = meta.Logo or 128185233852701

	local Background_1 = Instance.new("Frame")
	local DropShadow_1 = Instance.new("ImageLabel")
	local UICorner_1 = Instance.new("UICorner")
	local Header_1 = Instance.new("Frame")
	local Title_1 = Instance.new("TextLabel")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local UIPadding_1 = Instance.new("UIPadding")
	local Line_1 = Instance.new("Frame")
	local UIGradient_1 = Instance.new("UIGradient")
	local Desc_1 = Instance.new("TextLabel")
	local Effect_1 = Instance.new("ImageLabel")

	Background_1.Name = "Background"
	Background_1.Parent = Khaw
	Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Background_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
	Background_1.BackgroundTransparency = 0.5
	Background_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Background_1.BorderSizePixel = 0
	Background_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Background_1.Size = UDim2.new(0, 0,0, 0)
	lak(Background_1)
	tw({v = Background_1,t = 1,s = "Bounce",d = "Out",g = {Size = UDim2.new(0, 574,0, 365)}}):Play()

	DropShadow_1.Name = "DropShadow"
	DropShadow_1.Parent = Background_1
	DropShadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow_1.BackgroundColor3 = Color3.fromRGB(28,28,30)
	DropShadow_1.BackgroundTransparency = 1
	DropShadow_1.BorderColor3 = Color3.fromRGB(0,0,0)
	DropShadow_1.BorderSizePixel = 0
	DropShadow_1.Position = UDim2.new(0.5, 0,0.5, 0)
	DropShadow_1.Size = UDim2.new(1, 120,1, 120)
	DropShadow_1.ZIndex = 0
	DropShadow_1.Image = "rbxassetid://8992230677"
	DropShadow_1.ImageColor3 = Color3.fromRGB(0,0,0)
	DropShadow_1.ImageTransparency = 0.30000001192092896
	DropShadow_1.ScaleType = Enum.ScaleType.Slice
	DropShadow_1.SliceCenter = Rect.new(99, 99, 99, 99)

	Effect_1.Name = "Effect"
	Effect_1.Parent = Background_1
	Effect_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Effect_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Effect_1.BackgroundTransparency = 1
	Effect_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Effect_1.BorderSizePixel = 0
	Effect_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Effect_1.Size = UDim2.new(1, 0,1, 0)
	Effect_1.Image = "rbxassetid://132687652275989"
	Effect_1.ImageColor3 = Color3.fromRGB(0,255,127)
	Effect_1.ImageTransparency = 0.1
	Effect_1.ScaleType = Enum.ScaleType.Crop

	UICorner_1.Parent = Background_1
	UICorner_1.CornerRadius = UDim.new(0,20)

	Header_1.Name = "Header"
	Header_1.Parent = Background_1
	Header_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Header_1.BackgroundTransparency = 1
	Header_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Header_1.BorderSizePixel = 0
	Header_1.Size = UDim2.new(1, 0,0, 73)

	Title_1.Name = "Title"
	Title_1.Parent = Header_1
	Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Title_1.BackgroundTransparency = 1
	Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Title_1.BorderSizePixel = 0
	Title_1.Position = UDim2.new(0, 0,0.116666667, 0)
	Title_1.Size = UDim2.new(0, 462,0, 20)
	Title_1.Font = Enum.Font.GothamBold
	Title_1.Text = Title
	Title_1.TextColor3 = Color3.fromRGB(255,255,255)
	Title_1.TextSize = 26
	Title_1.TextWrapped = true
	Title_1.TextXAlignment = Enum.TextXAlignment.Left

	UIListLayout_1.Parent = Header_1
	UIListLayout_1.Padding = UDim.new(0,7)
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

	UIPadding_1.Parent = Header_1
	UIPadding_1.PaddingLeft = UDim.new(0,20)
	UIPadding_1.PaddingTop = UDim.new(0,3)

	Line_1.Name = "Line"
	Line_1.Parent = Header_1
	Line_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Line_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Line_1.BorderSizePixel = 0
	Line_1.Size = UDim2.new(0, 70,0, 2)

	UIGradient_1.Parent = Line_1
	UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

	Desc_1.Name = "Desc"
	Desc_1.Parent = Header_1
	Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Desc_1.BackgroundTransparency = 1
	Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Desc_1.BorderSizePixel = 0
	Desc_1.Position = UDim2.new(0.0179999992, 0,0, 0)
	Desc_1.Size = UDim2.new(0, 191,0, 5)
	Desc_1.Font = Enum.Font.GothamBold
	Desc_1.Text = Desc
	Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
	Desc_1.TextSize = 15
	Desc_1.TextTransparency = 0.5
	Desc_1.TextXAlignment = Enum.TextXAlignment.Left

	local CloseUI = Instance.new("TextButton")
	local UICorner_1z = Instance.new("UICorner")
	local Icon_1 = Instance.new("Frame")
	local ImageLabel = Instance.new("ImageLabel")


	CloseUI.Name = "CloseUI"
	CloseUI.Parent = Khaw
	CloseUI.AnchorPoint = Vector2.new(0, 1)
	CloseUI.BackgroundColor3 = Color3.fromRGB(0,0,0)
	CloseUI.BorderColor3 = Color3.fromRGB(0,0,0)
	CloseUI.BorderSizePixel = 0
	CloseUI.Position = UDim2.new(0.06, 0,0.21, 0)
	CloseUI.Size = UDim2.new(0, 50,0, 50)
	CloseUI.BackgroundTransparency = 0.35
	CloseUI.Text = ""

	lak(CloseUI)

	UICorner_1z.Parent = CloseUI
	UICorner_1z.CornerRadius = UDim.new(0,5)

	Icon_1.Name = "Icon"
	Icon_1.Parent = CloseUI
	Icon_1.BackgroundColor3 = Color3.fromRGB(22,22,22)
	Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Icon_1.BorderSizePixel = 0
	Icon_1.Size = UDim2.new(0, 50,0, 50)
	Icon_1.BackgroundTransparency = 1

	ImageLabel.Parent = Icon_1
	ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.BorderColor3 = Color3.fromRGB(0,0,0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.5, 0,0.5, 0)
	ImageLabel.Size = UDim2.new(0, 45,0, 45)
	ImageLabel.Image = GetIcon(Logo)
	ImageLabel.ImageTransparency = 0

	local function closeopenui()
		task.spawn(function()
			tw({
				v = ImageLabel,
				t = 0.2,
				s = "Back",
				d = "Out",
				g = {Size = UDim2.new(0, 35, 0, 35)}
			}):Play()
			task.wait(0.016) 
			tw({
				v = ImageLabel,
				t = 0.2,
				s = "Back",
				d = "Out",
				g = {Size = UDim2.new(0, 45, 0, 45)}
			}):Play()
		end)
		Background_1.Visible = not Background_1.Visible
	end


	CloseUI.MouseButton1Click:Connect(function()
		closeopenui()
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.F2 then
			closeopenui()
		end
	end)

	local Tab_1 = Instance.new("Frame")
	local ScrollingFrame_1 = Instance.new("ScrollingFrame")
	local UIListLayout_2 = Instance.new("UIListLayout")

	Tab_1.Name = "Tab"
	Tab_1.Parent = Background_1
	Tab_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Tab_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Tab_1.BackgroundTransparency = 1
	Tab_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Tab_1.BorderSizePixel = 0
	Tab_1.Position = UDim2.new(0.5, 0,0.600000024, 0)
	Tab_1.Size = UDim2.new(1, 0,0.800000012, 0)

	ScrollingFrame_1.Name = "ScrollingFrame"
	ScrollingFrame_1.Parent = Tab_1
	ScrollingFrame_1.Active = true
	ScrollingFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
	ScrollingFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ScrollingFrame_1.BackgroundTransparency = 1
	ScrollingFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
	ScrollingFrame_1.BorderSizePixel = 0
	ScrollingFrame_1.Position = UDim2.new(0.5, 0,0.474315077, 0)
	ScrollingFrame_1.Size = UDim2.new(0.950000107, 0,0.960274041, 0)
	ScrollingFrame_1.ClipsDescendants = true
	ScrollingFrame_1.AutomaticCanvasSize = Enum.AutomaticSize.None
	ScrollingFrame_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
	ScrollingFrame_1.CanvasPosition = Vector2.new(0, 0)
	ScrollingFrame_1.CanvasSize = UDim2.new(0, 20,0, 0)
	ScrollingFrame_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	ScrollingFrame_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	ScrollingFrame_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	ScrollingFrame_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
	ScrollingFrame_1.ScrollBarImageTransparency = 1
	ScrollingFrame_1.ScrollBarThickness = 0
	ScrollingFrame_1.ScrollingDirection = Enum.ScrollingDirection.XY
	ScrollingFrame_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
	ScrollingFrame_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
	ScrollingFrame_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

	UIListLayout_2.Parent = ScrollingFrame_1
	UIListLayout_2.Padding = UDim.new(0,10)
	UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

	UIListLayout_2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScrollingFrame_1.CanvasSize = UDim2.new(0, UIListLayout_2.AbsoluteContentSize.X + 20, 0, 0)
	end)

	local Return = Instance.new("Frame")
	local UICorner_1z = Instance.new("UICorner")
	local UIGradient_1z = Instance.new("UIGradient")
	local UIStroke_1z = Instance.new("UIStroke")
	local ImageLabel_1z = Instance.new("ImageLabel")
	local TextLabel_1z = Instance.new("TextLabel")

	Return.Name = "Return"
	Return.Parent = Background_1
	Return.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Return.BorderColor3 = Color3.fromRGB(0,0,0)
	Return.BorderSizePixel = 0
	Return.Position = UDim2.new(0.77003485, 0,0.0493150689, 0)
	Return.Size = UDim2.new(0, 110,0, 29)
	Return.ClipsDescendants = true
	Return.Visible = false

	UICorner_1z.Parent = Return
	UICorner_1z.CornerRadius = UDim.new(0,3)

	UIGradient_1z.Parent = Return
	UIGradient_1z.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 89, 89)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 0, 0))}

	UIStroke_1z.Parent = Return
	UIStroke_1z.Color = Color3.fromRGB(255,85,127)
	UIStroke_1z.Thickness = 1.5

	ImageLabel_1z.Parent = Return
	ImageLabel_1z.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel_1z.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabel_1z.BackgroundTransparency = 1
	ImageLabel_1z.BorderColor3 = Color3.fromRGB(0,0,0)
	ImageLabel_1z.BorderSizePixel = 0
	ImageLabel_1z.Position = UDim2.new(0.5, 0,0.5, 0)
	ImageLabel_1z.Size = UDim2.new(1, 50,1, 0)
	ImageLabel_1z.Image = "rbxassetid://87782680483863"
	ImageLabel_1z.ImageTransparency = 0.8399999737739563
	ImageLabel_1z.ScaleType = Enum.ScaleType.Crop

	TextLabel_1z.Parent = Return
	TextLabel_1z.AnchorPoint = Vector2.new(0.5, 0.5)
	TextLabel_1z.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TextLabel_1z.BackgroundTransparency = 1
	TextLabel_1z.BorderColor3 = Color3.fromRGB(0,0,0)
	TextLabel_1z.BorderSizePixel = 0
	TextLabel_1z.Position = UDim2.new(0.5, 0,0.5, 0)
	TextLabel_1z.Size = UDim2.new(1, 0,1, 0)
	TextLabel_1z.Font = Enum.Font.GothamBold
	TextLabel_1z.Text = "Back"
	TextLabel_1z.TextColor3 = Color3.fromRGB(255,255,255)
	TextLabel_1z.TextSize = 14

	local ClickReturn = click(Return)
	ClickReturn.MouseButton1Click:Connect(function()
		Header_1.Position = UDim2.new(0, -30,0, 0)
		tw({
			v = Header_1,
			t = 0.3,
			s = "Back",
			d = "Out",
			g = {Position = UDim2.new(0, 0,0, 0)}
		}):Play()
		tw({
			v = Title_1,
			t = 0.5,
			s = "Back",
			d = "Out",
			g = {TextTransparency = 1}
		}):Play()
		tw({
			v = Desc_1,
			t = 0.5,
			s = "Back",
			d = "Out",
			g = {TextTransparency = 1}
		}):Play()
		tw({
			v = Line_1,
			t = 0.5,
			s = "Back",
			d = "Out",
			g = {BackgroundTransparency = 1}
		}):Play()
		Desc_1.Text = Desc
		Title_1.Text = Title
		delay(0.2, function()
			tw({
				v = Title_1,
				t = 0.5,
				s = "Back",
				d = "Out",
				g = {TextTransparency = 0}
			}):Play()
			tw({
				v = Desc_1,
				t = 0.5,
				s = "Back",
				d = "Out",
				g = {TextTransparency = 0.5}
			}):Play()
			tw({
				v = Line_1,
				t = 0.5,
				s = "Back",
				d = "Out",
				g = {BackgroundTransparency = 0}
			}):Play()
		end)
		for _, v in pairs(Background_1:GetChildren()) do
			if v.Name == "Pages" then
				v.Visible = false
			end
		end
		Tab_1.Visible = true
		tw({
			v = Tab_1,
			t = 0.3,
			s = "Back",
			d = "Out",
			g = {Size = UDim2.new(1, 0,0.800000012, 0)}
		}):Play()
		tw({
			v = Return,
			t = 0.3,
			s = "Back",
			d = "Out",
			g = {Position = UDim2.new(0.9, 0,0.049, 0)}
		}):Play()
		tw({
			v = Return,
			t = 0.3,
			s = "Back",
			d = "Out",
			g = {BackgroundTransparency = 1}
		}):Play()
		UIStroke_1z.Enabled = false
		tw({
			v = ImageLabel_1z,
			t = 0.3,
			s = "Back",
			d = "Out",
			g = {ImageTransparency = 1}
		}):Play()
		tw({
			v = TextLabel_1z,
			t = 0.3,
			s = "Back",
			d = "Out",
			g = {TextTransparency = 1}
		}):Play()
		task.wait(0.1)
		Return.Visible = false
	end)

	Env.Tabs = {}

	function Env.Tabs:Add(meta)
		local Addtab_1 = Instance.new("Frame")
		local Banner_1 = Instance.new("ImageLabel")
		local UICorner_2 = Instance.new("UICorner")
		local ClickTab = click(Addtab_1)

		local Title = meta.Title
		local Desc = meta.Desc
		local Banner = meta.Banner

		Addtab_1.Name = "Addtab"
		Addtab_1.Parent = ScrollingFrame_1
		Addtab_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Addtab_1.BackgroundTransparency = 1
		Addtab_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Addtab_1.BorderSizePixel = 0
		Addtab_1.Position = UDim2.new(5.54562583e-08, 0,0, 0)
		Addtab_1.Size = UDim2.new(0, 100,1, 0)

		Banner_1.Name = "Banner"
		Banner_1.Parent = Addtab_1
		Banner_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Banner_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Banner_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Banner_1.BorderSizePixel = 0
		Banner_1.Position = UDim2.new(0.5, 0,0.5, 0)
		Banner_1.Size = UDim2.new(1, 0,1, 0)
		Banner_1.BackgroundTransparency = 1
		Banner_1.Image = GetIcon(Banner)

		UICorner_2.Parent = Banner_1

		local Pages_1 = Instance.new("Frame")
		local UIListLayout_5 = Instance.new("UIListLayout")

		Pages_1.Name = "Pages"
		Pages_1.Parent = Background_1
		Pages_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Pages_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Pages_1.BackgroundTransparency = 1
		Pages_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Pages_1.BorderSizePixel = 0
		Pages_1.Position = UDim2.new(0.5, 0,0.58767122, 0)
		Pages_1.Size = UDim2.new(0.965156794, 0,0.767123282, 0)
		Pages_1.Visible = false

		UIListLayout_5.Parent = Pages_1
		UIListLayout_5.Padding = UDim.new(0,6)
		UIListLayout_5.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_5.VerticalAlignment = Enum.VerticalAlignment.Center

		local Left_1 = Instance.new("ScrollingFrame")
		local UIListLayout_3 = Instance.new("UIListLayout")

		Left_1.Name = "Left"
		Left_1.Parent = Pages_1
		Left_1.Active = true
		Left_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Left_1.BackgroundTransparency = 1
		Left_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Left_1.BorderSizePixel = 0
		Left_1.Size = UDim2.new(0, 275,1, 0)
		Left_1.ClipsDescendants = true
		Left_1.AutomaticCanvasSize = Enum.AutomaticSize.None
		Left_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
		Left_1.CanvasPosition = Vector2.new(0, 0)
		Left_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		Left_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		Left_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		Left_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
		Left_1.ScrollBarImageTransparency = 1
		Left_1.ScrollBarThickness = 0
		Left_1.ScrollingDirection = Enum.ScrollingDirection.XY
		Left_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
		Left_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
		Left_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

		UIListLayout_3.Parent = Left_1
		UIListLayout_3.Padding = UDim.new(0,7)
		UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder

		local Right_1 = Instance.new("ScrollingFrame")
		local UIListLayout_6 = Instance.new("UIListLayout")

		Right_1.Name = "Right"
		Right_1.Parent = Pages_1
		Right_1.Active = true
		Right_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Right_1.BackgroundTransparency = 1
		Right_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Right_1.BorderSizePixel = 0
		Right_1.Size = UDim2.new(0, 275,1, 0)
		Right_1.ClipsDescendants = true
		Right_1.AutomaticCanvasSize = Enum.AutomaticSize.None
		Right_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
		Right_1.CanvasPosition = Vector2.new(0, 0)
		Right_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		Right_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		Right_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		Right_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
		Right_1.ScrollBarImageTransparency = 1
		Right_1.ScrollBarThickness = 0
		Right_1.ScrollingDirection = Enum.ScrollingDirection.XY
		Right_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
		Right_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
		Right_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

		UIListLayout_6.Parent = Right_1
		UIListLayout_6.Padding = UDim.new(0,7)
		UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder

		UIListLayout_3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Left_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_3.AbsoluteContentSize.Y + 20)
		end)

		UIListLayout_6:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Right_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_6.AbsoluteContentSize.Y + 20)
		end)

		ClickTab.MouseButton1Click:Connect(function()
			Header_1.Position = UDim2.new(0, -30,0, 0)
			tw({
				v = Header_1,
				t = 0.3,
				s = "Back",
				d = "Out",
				g = {Position = UDim2.new(0, 0,0, 0)}
			}):Play()
			tw({
				v = Title_1,
				t = 0.5,
				s = "Back",
				d = "Out",
				g = {TextTransparency = 1}
			}):Play()
			tw({
				v = Desc_1,
				t = 0.5,
				s = "Back",
				d = "Out",
				g = {TextTransparency = 1}
			}):Play()
			tw({
				v = Line_1,
				t = 0.5,
				s = "Back",
				d = "Out",
				g = {BackgroundTransparency = 1}
			}):Play()
			Desc_1.Text = Desc
			Title_1.Text = Title
			delay(0.2, function()
				tw({
					v = Title_1,
					t = 0.5,
					s = "Back",
					d = "Out",
					g = {TextTransparency = 0}
				}):Play()
				tw({
					v = Desc_1,
					t = 0.5,
					s = "Back",
					d = "Out",
					g = {TextTransparency = 0.5}
				}):Play()
				tw({
					v = Line_1,
					t = 0.5,
					s = "Back",
					d = "Out",
					g = {BackgroundTransparency = 0}
				}):Play()
			end)
			Return.Visible = true
			UIStroke_1z.Enabled = true
			Return.Position = UDim2.new(0.9, 0,0.049, 0)
			tw({
				v = Return,
				t = 0.3,
				s = "Back",
				d = "Out",
				g = {Position = UDim2.new(0.77, 0,0.049, 0)}
			}):Play()
			tw({
				v = Return,
				t = 0.3,
				s = "Back",
				d = "Out",
				g = {BackgroundTransparency = 0}
			}):Play()
			tw({
				v = UIStroke_1z,
				t = 0.3,
				s = "Back",
				d = "Out",
				g = {Transparency = 0}
			}):Play()
			tw({
				v = ImageLabel_1z,
				t = 0.3,
				s = "Back",
				d = "Out",
				g = {ImageTransparency = 0.84}
			}):Play()
			tw({
				v = TextLabel_1z,
				t = 0.3,
				s = "Back",
				d = "Out",
				g = {TextTransparency = 0}
			}):Play()

			tw({
				v = Tab_1,
				t = 0.3,
				s = "Bounce",
				d = "Out",
				g = {Size = UDim2.new(1, 0,0, 0)}
			}):Play()
			Tab_1.Visible = false
			Pages_1.Size = UDim2.new(0.965, 0,0, 0)
			tw({
				v = Pages_1,
				t = 0.25,
				s = "Back",
				d = "Out",
				g = {Size = UDim2.new(0.965, 0,0.767, 0)}
			}):Play()
			Pages_1.Visible = true
		end)

		local function GetSide(side)
			if not side then
				return Left_1
			end
			local sideLower = string.lower(tostring(side))
			if sideLower == "r" or sideLower == "right" or side == 2 then
				return Right_1
			elseif sideLower == "l" or sideLower == "left" or side == 1 then
				return Left_1
			else
				return Left_1
			end
		end

		Env.Section = {}

		function Env.Section:Section(meta)

			local Title = meta.Title or "Section"
			local Side = meta.Side or "l"

			local Section_1 = Instance.new("Frame")
			local UICorner_3 = Instance.new("UICorner")
			local UIListLayout_4 = Instance.new("UIListLayout")
			local Title_2 = Instance.new("TextLabel")
			local UIPadding_2 = Instance.new("UIPadding")
			local Line_2 = Instance.new("Frame")
			local UIGradient_2 = Instance.new("UIGradient")

			Section_1.Name = "Section"
			Section_1.Parent = GetSide(Side)
			Section_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
			Section_1.BackgroundTransparency = 0.6
			Section_1.BorderColor3 = Color3.fromRGB(20, 20, 20)
			Section_1.BorderSizePixel = 0
			Section_1.Size = UDim2.new(1, 0,0, 100)

			UICorner_3.Parent = Section_1
			UICorner_3.CornerRadius = UDim.new(0,5)

			UIListLayout_4.Parent = Section_1
			UIListLayout_4.Padding = UDim.new(0,5)
			UIListLayout_4.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder

			Title_2.Name = "Title"
			Title_2.Parent = Section_1
			Title_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Title_2.BackgroundTransparency = 1
			Title_2.BorderColor3 = Color3.fromRGB(0,0,0)
			Title_2.BorderSizePixel = 0
			Title_2.LayoutOrder = -3
			Title_2.Size = UDim2.new(0.899999976, 0,0, 20)
			Title_2.Font = Enum.Font.GothamBold
			Title_2.Text = Title
			Title_2.TextColor3 = Color3.fromRGB(255,255,255)
			Title_2.TextSize = 15

			UIPadding_2.Parent = Section_1
			UIPadding_2.PaddingTop = UDim.new(0,7)

			Line_2.Name = "Line"
			Line_2.Parent = Section_1
			Line_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Line_2.BorderColor3 = Color3.fromRGB(0,0,0)
			Line_2.BorderSizePixel = 0
			Line_2.BackgroundTransparency = 0.25
			Line_2.LayoutOrder = -2
			Line_2.Position = UDim2.new(-0.209090903, 0,0.215053767, 0)
			Line_2.Size = UDim2.new(1, 0,0, 1)

			UIGradient_2.Parent = Line_2
			UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

			UIListLayout_4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Section_1.Size = UDim2.new(1, 0, 0, UIListLayout_4.AbsoluteContentSize.Y + 15)
			end)

			Env._Class = {}

			function Env._Class:Button(meta)

				local Title = meta.Title
				local Desc = meta.Desc or nil
				local Color = meta.Color or nil
				local Callback = meta.Callback
				local Icon = meta.Icon or nil

				if not Icon and not Desc and not Color then
					local Button = Instance.new("Frame")
					local UIGradient_1 = Instance.new("UIGradient")
					local Title_1 = Instance.new("TextLabel")
					local UICorner_1 = Instance.new("UICorner")
					local ImageLabel_1 = Instance.new("ImageLabel")
					local Clickbutton = click(Button)

					Button.Name = "Button"
					Button.Parent = Section_1
					Button.AnchorPoint = Vector2.new(0.5, 0.5)
					Button.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Button.BorderColor3 = Color3.fromRGB(0,0,0)
					Button.BorderSizePixel = 0
					Button.Size = UDim2.new(0.97, 0,0, 30)
					Button.ClipsDescendants = true

					UIGradient_1.Parent = Button
					UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

					Title_1.Name = "Title"
					Title_1.Parent = Button
					Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Title_1.BackgroundTransparency = 1
					Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Title_1.BorderSizePixel = 0
					Title_1.Position = UDim2.new(0.5, 0,0.5, 0)
					Title_1.Size = UDim2.new(1, 0,1, 0)
					Title_1.Font = Enum.Font.GothamBold
					Title_1.Text = Title
					Title_1.TextColor3 = Color3.fromRGB(255,255,255)
					Title_1.TextSize = 14

					UICorner_1.Parent = Button
					UICorner_1.CornerRadius = UDim.new(0,5)

					ImageLabel_1.Parent = Button
					ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
					ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					ImageLabel_1.BackgroundTransparency = 1
					ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
					ImageLabel_1.BorderSizePixel = 0
					ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
					ImageLabel_1.Size = UDim2.new(1, 50,1, 0)
					ImageLabel_1.Image = "rbxassetid://72380279434385"
					ImageLabel_1.ImageTransparency = 0.800000011920929
					ImageLabel_1.ScaleType = Enum.ScaleType.Crop

					Clickbutton.MouseButton1Click:Connect(function()
						Callback()
						tw({
							v = Button,
							t = 0.15,
							s = "Bounce",
							d = "Out",
							g = {Size = UDim2.new(0.85, 0,0, 30)}
						}):Play()
						delay(0.06, function()
							tw({
								v = Button,
								t = 0.15,
								s = "Bounce",
								d = "Out",
								g = {Size = UDim2.new(0.97, 0,0, 30)}
							}):Play()
						end)
						EffectClick(Clickbutton, Button)
					end)

					local Index = {}

					function Index:Fire()
						Callback()
					end

					function Index:UpdateTitle(v)
						Title_1.Text = v
					end

					function Index:Visible(v)
						Button.Visible = v
					end

					return Index
				else
					local ButtonImage = Instance.new("Frame")
					local Title_1 = Instance.new("TextLabel")
					local UICorner_1 = Instance.new("UICorner")
					local ImageLabel_1 = Instance.new("ImageLabel")
					local UIGradient_1 = Instance.new("UIGradient")
					local icon_1 = Instance.new("ImageLabel")
					local Desc_1 = Instance.new("TextLabel")
					local next_1 = Instance.new("ImageLabel")
					local ClickButton = click(ButtonImage)

					ButtonImage.Name = "ButtonImage"
					ButtonImage.Parent = Section_1
					ButtonImage.AnchorPoint = Vector2.new(0.5, 0.5)
					ButtonImage.BackgroundColor3 = Color3.fromRGB(0,0,0)
					ButtonImage.BackgroundTransparency = 0.5
					ButtonImage.BorderColor3 = Color3.fromRGB(0,0,0)
					ButtonImage.BorderSizePixel = 0
					ButtonImage.Size = UDim2.new(0.97, 0,0, 50)
					ButtonImage.ClipsDescendants = true

					Title_1.Name = "Title"
					Title_1.Parent = ButtonImage
					Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Title_1.BackgroundTransparency = 1
					Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Title_1.BorderSizePixel = 0
					Title_1.Position = UDim2.new(0.575679302, 0,0.368333131, 0)
					Title_1.Size = UDim2.new(0.775981307, 0,0.0700000003, 20)
					Title_1.Font = Enum.Font.GothamBold
					Title_1.RichText = true
					Title_1.Text = Title
					Title_1.TextColor3 = Color3.fromRGB(255,255,255)
					Title_1.TextSize = 14
					Title_1.TextXAlignment = Enum.TextXAlignment.Left

					UICorner_1.Parent = ButtonImage
					UICorner_1.CornerRadius = UDim.new(0,5)

					ImageLabel_1.Parent = ButtonImage
					ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
					ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					ImageLabel_1.BackgroundTransparency = 1
					ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
					ImageLabel_1.BorderSizePixel = 0
					ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
					ImageLabel_1.Size = UDim2.new(1, 50,1, 0)
					ImageLabel_1.Image = "rbxassetid://72380279434385"
					ImageLabel_1.ImageTransparency = 0.8999999761581421
					ImageLabel_1.ScaleType = Enum.ScaleType.Crop

					UIGradient_1.Parent = ImageLabel_1
					UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

					icon_1.Name = "icon"
					icon_1.Parent = ButtonImage
					icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
					icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					icon_1.BackgroundTransparency = 1
					icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
					icon_1.BorderSizePixel = 0
					icon_1.Position = UDim2.new(0, 25,0.5, 0)
					icon_1.Size = UDim2.new(0, 35,0, 35)
					icon_1.Image = GetIcon(Icon)
					icon_1.ScaleType = Enum.ScaleType.Crop

					Desc_1.Name = "Desc"
					Desc_1.Parent = ButtonImage
					Desc_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Desc_1.BackgroundTransparency = 1
					Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Desc_1.BorderSizePixel = 0
					Desc_1.Position = UDim2.new(0.575679302, 0,0.664999783, 0)
					Desc_1.Size = UDim2.new(0.775981307, 0,-0.0366666801, 20)
					Desc_1.Font = Enum.Font.GothamBold
					Desc_1.RichText = true
					Desc_1.Text = Desc
					Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
					Desc_1.TextSize = 10
					Desc_1.TextTransparency = 0.5
					Desc_1.TextXAlignment = Enum.TextXAlignment.Left

					next_1.Name = "next"
					next_1.Parent = ButtonImage
					next_1.AnchorPoint = Vector2.new(0.5, 0.5)
					next_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					next_1.BackgroundTransparency = 1
					next_1.BorderColor3 = Color3.fromRGB(0,0,0)
					next_1.BorderSizePixel = 0
					next_1.Position = UDim2.new(0, 245,0.5, 0)
					next_1.Size = UDim2.new(0, 20,0, 20)
					next_1.Image = "rbxassetid://108028847031522"
					next_1.ScaleType = Enum.ScaleType.Crop

					ClickButton.MouseButton1Click:Connect(function()
						Callback()
						tw({
							v = next_1,
							t = 0.15,
							s = "Bounce",
							d = "Out",
							g = {Position = UDim2.new(0, 252,0.5, 0)}
						}):Play()
						delay(0.06, function()
							tw({
								v = next_1,
								t = 0.15,
								s = "Bounce",
								d = "Out",
								g = {Position = UDim2.new(0, 245,0.5, 0)}
							}):Play()
						end)
						EffectClick2(ClickButton, ButtonImage)
					end)

					local Index = {}

					function Index:Fire()
						Callback()
					end

					function Index:Title(v)
						Title_1.Text = v
					end

					function Index:Visible(v)
						ButtonImage.Visible = v
					end

					return Index
				end
			end

			function Env._Class:ThumnailsImage(meta)
				local Banner = meta.Banner
				local Y = meta.SizeY or 150

				local Image = Instance.new("ImageLabel")
				local UICorner_1 = Instance.new("UICorner")

				Image.Name = "Image"
				Image.Parent = Section_1
				Image.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Image.BorderColor3 = Color3.fromRGB(0,0,0)
				Image.BackgroundTransparency = 1
				Image.BorderSizePixel = 0
				Image.Size = UDim2.new(0.97, 0,0, Y)
				Image.Image = GetIcon(Banner)
				Image.ScaleType = Enum.ScaleType.Crop

				UICorner_1.Parent = Image
				UICorner_1.CornerRadius = UDim.new(0,5)

				local Index = {}

				function Index:Image(v)
					Image.Image = GetIcon(v)
				end

				function Index:Y(v)
					Image.Size = UDim2.new(0.97, 0,0, v)
				end

				function Index:Visible(v)
					Image.Visible = v
				end

				return Index
			end

			local function GetAlig(v)
				if v == 'l' then
					return Enum.TextXAlignment.Left
				elseif v == 'r' then
					return Enum.TextXAlignment.Right
				else
					return Enum.TextXAlignment.Center
				end
			end

			function Env._Class:Label(meta)

				local Title = meta.Title
				local Side = meta.Side

				local Label = Instance.new("TextLabel")
				Label.Name = "Label"
				Label.Parent = Section_1
				Label.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Label.BackgroundTransparency = 1
				Label.BorderColor3 = Color3.fromRGB(0,0,0)
				Label.BorderSizePixel = 0
				Label.Size = UDim2.new(0.899999976, 0,0, 20)
				Label.Font = Enum.Font.GothamBold
				Label.RichText = true
				Label.Text = Title
				Label.TextColor3 = Color3.fromRGB(255,255,255)
				Label.TextSize = 14
				Label.TextXAlignment = GetAlig(Side)

				local Index = {}

				function Index:Visible(v)
					Label.Visible = v
				end

				return Index
			end

			function Env._Class:Line()
				local Line_2 = Instance.new("Frame")
				local UIGradient_2 = Instance.new("UIGradient")

				Line_2.Name = "Line"
				Line_2.Parent = Section_1
				Line_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Line_2.BorderColor3 = Color3.fromRGB(0,0,0)
				Line_2.BorderSizePixel = 0
				Line_2.BackgroundTransparency = 0.25
				Line_2.Position = UDim2.new(-0.209090903, 0,0.215053767, 0)
				Line_2.Size = UDim2.new(1, 0,0, 1)

				UIGradient_2.Parent = Line_2
				UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				local Index = {}

				function Index:Visible(v)
					Line_2.Visible = v
				end

				return Index
			end

			function Env._Class:Discord(Link)

				local Discord = Instance.new("Frame")
				local Title_1 = Instance.new("TextLabel")
				local UICorner_1 = Instance.new("UICorner")
				local ImageLabel_1 = Instance.new("ImageLabel")
				local UIGradient_1 = Instance.new("UIGradient")
				local icon_1 = Instance.new("ImageLabel")
				local Desc_1 = Instance.new("TextLabel")
				local ClickDiscord = click(Discord)

				Discord.Name = "Discord"
				Discord.Parent = Section_1
				Discord.AnchorPoint = Vector2.new(0.5, 0.5)
				Discord.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Discord.BorderColor3 = Color3.fromRGB(0,0,0)
				Discord.BorderSizePixel = 0
				Discord.Size = UDim2.new(0.97, 0,0, 60)
				Discord.ClipsDescendants = true

				Title_1.Name = "Title"
				Title_1.Parent = Discord
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Position = UDim2.new(0.611293197, 0,0.408333331, 0)
				Title_1.Size = UDim2.new(0.704753578, 0,0.150000006, 20)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = "Discord"
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 16
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				UICorner_1.Parent = Discord
				UICorner_1.CornerRadius = UDim.new(0,5)

				ImageLabel_1.Parent = Discord
				ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ImageLabel_1.Size = UDim2.new(1, 50,1, 0)
				ImageLabel_1.Image = "rbxassetid://72380279434385"
				ImageLabel_1.ImageTransparency = 0.8999999761581421
				ImageLabel_1.ScaleType = Enum.ScaleType.Crop

				UIGradient_1.Parent = Discord
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)), ColorSequenceKeypoint.new(1, Color3.fromRGB(142, 130, 255))}

				icon_1.Name = "icon"
				icon_1.Parent = Discord
				icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
				icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				icon_1.BackgroundTransparency = 1
				icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
				icon_1.BorderSizePixel = 0
				icon_1.Position = UDim2.new(0, 35,0.5, 0)
				icon_1.Size = UDim2.new(0, 40,0, 40)
				icon_1.Image = "rbxassetid://94937742565147"
				icon_1.ScaleType = Enum.ScaleType.Crop

				Desc_1.Name = "Desc"
				Desc_1.Parent = Discord
				Desc_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Desc_1.BackgroundTransparency = 1
				Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Desc_1.BorderSizePixel = 0
				Desc_1.Position = UDim2.new(0.611293197, 0,0.675000012, 0)
				Desc_1.Size = UDim2.new(0.704753578, 0,-0.0166666675, 20)
				Desc_1.Font = Enum.Font.GothamBold
				Desc_1.Text = Link
				Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
				Desc_1.TextSize = 13
				Desc_1.TextTransparency = 0.5
				Desc_1.TextXAlignment = Enum.TextXAlignment.Left

				ClickDiscord.MouseButton1Click:Connect(function()
					pcall(setclipboard, tostring(Link))
					EffectClick(ClickDiscord, Discord)
					tw({
						v = icon_1,
						t = 0.15,
						s = "Back",
						d = "Out",
						g = {Rotation = -20}
					}):Play()
					delay(0.1, function()
						tw({
							v = icon_1,
							t = 0.15,
							s = "Bounce",
							d = "Out",
							g = {Rotation = 20}
						}):Play()
						tw({
							v = icon_1,
							t = 0.15,
							s = "Back",
							d = "Out",
							g = {Rotation = 0}
						}):Play()
					end)
					tw({
						v = Discord,
						t = 0.15,
						s = "Bounce",
						d = "Out",
						g = {Size = UDim2.new(0.9, 0,0, 60)}
					}):Play()
					delay(0.06, function()
						tw({
							v = Discord,
							t = 0.15,
							s = "Bounce",
							d = "Out",
							g = {Size = UDim2.new(0.97, 0,0, 60)}
						}):Play()
					end)
				end)
			end
			
			function Env._Class:Icon(meta)
				
				local Icon = meta.Icon
				local Title = meta.Title
				local Desc = meta.Desc
				
				local ToggleImage = Instance.new("Frame")
				local Title_1 = Instance.new("TextLabel")
				local UICorner_1 = Instance.new("UICorner")
				local ImageLabel_1 = Instance.new("ImageLabel")
				local UIGradient_1 = Instance.new("UIGradient")
				local icon_1 = Instance.new("ImageLabel")
				local Desc_1 = Instance.new("TextLabel")

				ToggleImage.Name = "ToggleImage"
				ToggleImage.Parent = Section_1
				ToggleImage.AnchorPoint = Vector2.new(0.5, 0.5)
				ToggleImage.BackgroundColor3 = Color3.fromRGB(0,0,0)
				ToggleImage.BackgroundTransparency = 0.5
				ToggleImage.BorderColor3 = Color3.fromRGB(0,0,0)
				ToggleImage.BorderSizePixel = 0
				ToggleImage.Size = UDim2.new(0.970000029, 0,0, 50)
				ToggleImage.ClipsDescendants = true

				Title_1.Name = "Title"
				Title_1.Parent = ToggleImage
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Position = UDim2.new(0.575679302, 0,0.368333131, 0)
				Title_1.Size = UDim2.new(0.775981307, 0,0.0700000003, 20)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.RichText = true
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(0, 170, 255)
				Title_1.TextSize = 14
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				UICorner_1.Parent = ToggleImage
				UICorner_1.CornerRadius = UDim.new(0,5)

				ImageLabel_1.Parent = ToggleImage
				ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ImageLabel_1.Size = UDim2.new(1, 50,1, 0)
				ImageLabel_1.Image = "rbxassetid://72380279434385"
				ImageLabel_1.ImageTransparency = 0.8999999761581421
				ImageLabel_1.ScaleType = Enum.ScaleType.Crop

				UIGradient_1.Parent = ImageLabel_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				icon_1.Name = "icon"
				icon_1.Parent = ToggleImage
				icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
				icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				icon_1.BackgroundTransparency = 1
				icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
				icon_1.BorderSizePixel = 0
				icon_1.Position = UDim2.new(0, 25,0.5, 0)
				icon_1.Size = UDim2.new(0, 35,0, 35)
				icon_1.Image = GetIcon(Icon)
				icon_1.ScaleType = Enum.ScaleType.Crop

				Desc_1.Name = "Desc"
				Desc_1.Parent = ToggleImage
				Desc_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Desc_1.BackgroundTransparency = 1
				Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Desc_1.BorderSizePixel = 0
				Desc_1.Position = UDim2.new(0.575679302, 0,0.664999783, 0)
				Desc_1.Size = UDim2.new(0.775981307, 0,-0.0366666801, 20)
				Desc_1.Font = Enum.Font.GothamBold
				Desc_1.RichText = true
				Desc_1.Text = Desc
				Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
				Desc_1.TextSize = 10
				Desc_1.TextTransparency = 0.5
				Desc_1.TextXAlignment = Enum.TextXAlignment.Left
				
			end

			function Env._Class:Toggle(meta)
				local Title = meta.Title
				local Desc = meta.Desc
				local Icon = meta.Icon or nil
				local Value = meta.Value
				local Callback = meta.Callback

				if Icon then
					local ToggleImage = Instance.new("Frame")
					local Title_1 = Instance.new("TextLabel")
					local UICorner_1 = Instance.new("UICorner")
					local ImageLabel_1 = Instance.new("ImageLabel")
					local UIGradient_1 = Instance.new("UIGradient")
					local icon_1 = Instance.new("ImageLabel")
					local Desc_1 = Instance.new("TextLabel")
					local Check_1 = Instance.new("Frame")
					local ColorFrame_1 = Instance.new("Frame")
					local UIGradient_2 = Instance.new("UIGradient")
					local UICorner_2 = Instance.new("UICorner")
					local ImageLabel_2 = Instance.new("ImageLabel")
					local UICorner_3 = Instance.new("UICorner")
					local ClickToggle = click(ToggleImage)

					ToggleImage.Name = "ToggleImage"
					ToggleImage.Parent = Section_1
					ToggleImage.AnchorPoint = Vector2.new(0.5, 0.5)
					ToggleImage.BackgroundColor3 = Color3.fromRGB(0,0,0)
					ToggleImage.BackgroundTransparency = 0.5
					ToggleImage.BorderColor3 = Color3.fromRGB(0,0,0)
					ToggleImage.BorderSizePixel = 0
					ToggleImage.Size = UDim2.new(0.970000029, 0,0, 50)
					ToggleImage.ClipsDescendants = true

					Title_1.Name = "Title"
					Title_1.Parent = ToggleImage
					Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Title_1.BackgroundTransparency = 1
					Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Title_1.BorderSizePixel = 0
					Title_1.Position = UDim2.new(0.575679302, 0,0.368333131, 0)
					Title_1.Size = UDim2.new(0.775981307, 0,0.0700000003, 20)
					Title_1.Font = Enum.Font.GothamBold
					Title_1.RichText = true
					Title_1.Text = Title
					Title_1.TextColor3 = Color3.fromRGB(255,255,255)
					Title_1.TextSize = 14
					Title_1.TextXAlignment = Enum.TextXAlignment.Left
					Title_1.TextTransparency = 0.5

					UICorner_1.Parent = ToggleImage
					UICorner_1.CornerRadius = UDim.new(0,5)

					ImageLabel_1.Parent = ToggleImage
					ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
					ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					ImageLabel_1.BackgroundTransparency = 1
					ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
					ImageLabel_1.BorderSizePixel = 0
					ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
					ImageLabel_1.Size = UDim2.new(1, 50,1, 0)
					ImageLabel_1.Image = "rbxassetid://72380279434385"
					ImageLabel_1.ImageTransparency = 0.8999999761581421
					ImageLabel_1.ScaleType = Enum.ScaleType.Crop

					UIGradient_1.Parent = ImageLabel_1
					UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

					icon_1.Name = "icon"
					icon_1.Parent = ToggleImage
					icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
					icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					icon_1.BackgroundTransparency = 1
					icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
					icon_1.BorderSizePixel = 0
					icon_1.Position = UDim2.new(0, 25,0.5, 0)
					icon_1.Size = UDim2.new(0, 35,0, 35)
					icon_1.Image = GetIcon(Icon)
					icon_1.ScaleType = Enum.ScaleType.Crop

					Desc_1.Name = "Desc"
					Desc_1.Parent = ToggleImage
					Desc_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Desc_1.BackgroundTransparency = 1
					Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Desc_1.BorderSizePixel = 0
					Desc_1.Position = UDim2.new(0.575679302, 0,0.664999783, 0)
					Desc_1.Size = UDim2.new(0.775981307, 0,-0.0366666801, 20)
					Desc_1.Font = Enum.Font.GothamBold
					Desc_1.RichText = true
					Desc_1.Text = Desc
					Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
					Desc_1.TextSize = 10
					Desc_1.TextTransparency = 0.5
					Desc_1.TextXAlignment = Enum.TextXAlignment.Left

					Check_1.Name = "Check"
					Check_1.Parent = ToggleImage
					Check_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Check_1.BackgroundColor3 = Color3.fromRGB(42,42,42)
					Check_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Check_1.BorderSizePixel = 0
					Check_1.Position = UDim2.new(0.899999976, 0,0.5, 0)
					Check_1.Size = UDim2.new(0, 25,0, 25)
					Check_1.ClipsDescendants = true

					ColorFrame_1.Name = "ColorFrame"
					ColorFrame_1.Parent = Check_1
					ColorFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
					ColorFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					ColorFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
					ColorFrame_1.BorderSizePixel = 0
					ColorFrame_1.Position = UDim2.new(0.5, 0,0.5, 0)
					ColorFrame_1.Size = UDim2.new(1, 0,1, 0)

					UIGradient_2.Parent = ColorFrame_1
					UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
					UIGradient_2.Rotation = 48

					UICorner_2.Parent = ColorFrame_1

					ImageLabel_2.Parent = ColorFrame_1
					ImageLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
					ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
					ImageLabel_2.BackgroundTransparency = 1
					ImageLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
					ImageLabel_2.BorderSizePixel = 0
					ImageLabel_2.Position = UDim2.new(0.5, 0,0.5, 0)
					ImageLabel_2.Size = UDim2.new(0, 13,0, 13)
					ImageLabel_2.Image = "rbxassetid://86682186031062"
					ImageLabel_2.ScaleType = Enum.ScaleType.Crop

					UICorner_3.Parent = Check_1

					local function Toggle(Value)
						if not Value then 
							Callback(Value)
							tw({
								v = ColorFrame_1,
								t = 0.3,
								s = "Back",
								d = "Out",
								g = {Transparency = 1}
							}):Play()
							tw({
								v = ImageLabel_2,
								t = 0.2,
								s = "Back",
								d = "Out",
								g = {Size = UDim2.new(0, 0,0, 0)}
							}):Play()
							tw({
								v = Title_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {TextTransparency = 0.5}
							}):Play()
						elseif Value then 
							Callback(Value)
							tw({
								v = ColorFrame_1,
								t = 0.3,
								s = "Back",
								d = "Out",
								g = {Transparency = 0}
							}):Play()
							tw({
								v = ImageLabel_2,
								t = 0.1,
								s = "Bounce",
								d = "Out",
								g = {Size = UDim2.new(0, 21,0, 21)}
							}):Play()
							tw({
								v = Title_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {TextTransparency = 0}
							}):Play()
							delay(0.05, function()
								tw({
									v = ImageLabel_2,
									t = 0.2,
									s = "Bounce",
									d = "Out",
									g = {Size = UDim2.new(0, 13,0, 13)}
								}):Play()
							end)
						end
					end

					ClickToggle.MouseButton1Click:Connect(function()
						EffectClick2(ClickToggle, ToggleImage)
						Value = not Value
						Toggle(Value)
					end)

					Toggle(Value)

					local Index = {}

					function Index:Title(v)
						Title_1 = v
					end

					function Index:Desc()
						Desc_1 = Desc
					end

					function Index:Value(v)
						Value = v
						Toggle(Value)
					end

					function Index:Icon(v)
						icon_1.Image = GetIcon(v)
					end

					function Index:Visible(v)
						ToggleImage.Visible = v
					end

					return Index
				else

					local Togglez = Instance.new("Frame")
					local Title_1 = Instance.new("TextLabel")
					local UICorner_1 = Instance.new("UICorner")
					local ImageLabel_1 = Instance.new("ImageLabel")
					local UIGradient_1 = Instance.new("UIGradient")
					local Check_1 = Instance.new("Frame")
					local ColorFrame_1 = Instance.new("Frame")
					local UIGradient_2 = Instance.new("UIGradient")
					local UICorner_2 = Instance.new("UICorner")
					local ImageLabel_2 = Instance.new("ImageLabel")
					local UICorner_3 = Instance.new("UICorner")
					local Desc_1 = Instance.new("TextLabel")
					local ClickToggle = click(Togglez)

					Togglez.Name = "Toggle"
					Togglez.Parent = Section_1
					Togglez.AnchorPoint = Vector2.new(0.5, 0.5)
					Togglez.BackgroundColor3 = Color3.fromRGB(0,0,0)
					Togglez.BackgroundTransparency = 0.5
					Togglez.BorderColor3 = Color3.fromRGB(0,0,0)
					Togglez.BorderSizePixel = 0
					Togglez.Size = UDim2.new(0.970000029, 0,0, 50)
					Togglez.ClipsDescendants = true

					Title_1.Name = "Title"
					Title_1.Parent = Togglez
					Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Title_1.BackgroundTransparency = 1
					Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Title_1.BorderSizePixel = 0
					Title_1.Position = UDim2.new(0.499876201, 0,0.368333131, 0)
					Title_1.Size = UDim2.new(0.927587509, 0,0.0700000003, 20)
					Title_1.Font = Enum.Font.GothamBold
					Title_1.RichText = true
					Title_1.Text = Title
					Title_1.TextColor3 = Color3.fromRGB(255,255,255)
					Title_1.TextSize = 14
					Title_1.TextXAlignment = Enum.TextXAlignment.Left
					Title_1.TextTransparency = 0.5

					UICorner_1.Parent = Togglez
					UICorner_1.CornerRadius = UDim.new(0,5)

					ImageLabel_1.Parent = Togglez
					ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
					ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					ImageLabel_1.BackgroundTransparency = 1
					ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
					ImageLabel_1.BorderSizePixel = 0
					ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
					ImageLabel_1.Size = UDim2.new(1, 50,1, 0)
					ImageLabel_1.Image = "rbxassetid://72380279434385"
					ImageLabel_1.ImageTransparency = 0.8999999761581421
					ImageLabel_1.ScaleType = Enum.ScaleType.Crop

					UIGradient_1.Parent = ImageLabel_1
					UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

					Check_1.Name = "Check"
					Check_1.Parent = Togglez
					Check_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Check_1.BackgroundColor3 = Color3.fromRGB(42,42,42)
					Check_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Check_1.BorderSizePixel = 0
					Check_1.Position = UDim2.new(0.899999976, 0,0.5, 0)
					Check_1.Size = UDim2.new(0, 25,0, 25)
					Check_1.ClipsDescendants = true

					ColorFrame_1.Name = "ColorFrame"
					ColorFrame_1.Parent = Check_1
					ColorFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
					ColorFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					ColorFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
					ColorFrame_1.BorderSizePixel = 0
					ColorFrame_1.Position = UDim2.new(0.5, 0,0.5, 0)
					ColorFrame_1.Size = UDim2.new(1, 0,1, 0)

					UIGradient_2.Parent = ColorFrame_1
					UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
					UIGradient_2.Rotation = 48

					UICorner_2.Parent = ColorFrame_1

					ImageLabel_2.Parent = ColorFrame_1
					ImageLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
					ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
					ImageLabel_2.BackgroundTransparency = 1
					ImageLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
					ImageLabel_2.BorderSizePixel = 0
					ImageLabel_2.Position = UDim2.new(0.5, 0,0.5, 0)
					ImageLabel_2.Size = UDim2.new(0, 13,0, 13)
					ImageLabel_2.Image = "rbxassetid://86682186031062"
					ImageLabel_2.ScaleType = Enum.ScaleType.Crop

					UICorner_3.Parent = Check_1

					Desc_1.Name = "Desc"
					Desc_1.Parent = Togglez
					Desc_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Desc_1.BackgroundTransparency = 1
					Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Desc_1.BorderSizePixel = 0
					Desc_1.Position = UDim2.new(0.499876201, 0,0.664999783, 0)
					Desc_1.Size = UDim2.new(0.927587509, 0,-0.0366666801, 20)
					Desc_1.Font = Enum.Font.GothamBold
					Desc_1.RichText = true
					Desc_1.Text = Desc
					Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
					Desc_1.TextSize = 10
					Desc_1.TextTransparency = 0.5
					Desc_1.TextXAlignment = Enum.TextXAlignment.Left


					local function Toggle(Value)
						if not Value then 
							Callback(Value)
							tw({
								v = ColorFrame_1,
								t = 0.3,
								s = "Back",
								d = "Out",
								g = {Transparency = 1}
							}):Play()
							tw({
								v = ImageLabel_2,
								t = 0.2,
								s = "Back",
								d = "Out",
								g = {Size = UDim2.new(0, 0,0, 0)}
							}):Play()
							tw({
								v = Title_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {TextTransparency = 0.5}
							}):Play()
						elseif Value then 
							Callback(Value)
							tw({
								v = Title_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {TextTransparency = 0}
							}):Play()
							tw({
								v = ColorFrame_1,
								t = 0.3,
								s = "Back",
								d = "Out",
								g = {Transparency = 0}
							}):Play()
							tw({
								v = ImageLabel_2,
								t = 0.1,
								s = "Bounce",
								d = "Out",
								g = {Size = UDim2.new(0, 21,0, 21)}
							}):Play()
							delay(0.05, function()
								tw({
									v = ImageLabel_2,
									t = 0.2,
									s = "Bounce",
									d = "Out",
									g = {Size = UDim2.new(0, 13,0, 13)}
								}):Play()
							end)
						end
					end

					ClickToggle.MouseButton1Click:Connect(function()
						EffectClick2(ClickToggle, Togglez)
						Value = not Value
						Toggle(Value)
					end)

					Toggle(Value)

					local Index = {}

					function Index:Title(v)
						Title_1 = v
					end

					function Index:Desc()
						Desc_1 = Desc
					end

					function Index:Value(v)
						Value = v
						Toggle(Value)
					end

					function Index:Visible(v)
						Togglez.Visible = v
					end

					return Index
				end 
			end

			function Env._Class:Paragarp(meta)
				local Title = meta.Title
				local Desc = meta.Desc

				local Paragarp = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local ImageLabel_1 = Instance.new("ImageLabel")
				local UIGradient_1 = Instance.new("UIGradient")
				local Inside_1 = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local Title_1 = Instance.new("TextLabel")
				local Desc_1 = Instance.new("TextLabel")
				local UIPadding_1 = Instance.new("UIPadding")

				Paragarp.Name = "Paragarp"
				Paragarp.Parent = Section_1
				Paragarp.AnchorPoint = Vector2.new(0.5, 0.5)
				Paragarp.BackgroundColor3 = Color3.fromRGB(0,0,0)
				Paragarp.BackgroundTransparency = 0.5
				Paragarp.BorderColor3 = Color3.fromRGB(0,0,0)
				Paragarp.BorderSizePixel = 0
				Paragarp.Size = UDim2.new(0.970000029, 0,0, 70)
				Paragarp.ClipsDescendants = true

				UICorner_1.Parent = Paragarp
				UICorner_1.CornerRadius = UDim.new(0,5)

				ImageLabel_1.Parent = Paragarp
				ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ImageLabel_1.Size = UDim2.new(1, 50,1, 0)
				ImageLabel_1.Image = "rbxassetid://72380279434385"
				ImageLabel_1.ImageTransparency = 0.8999999761581421
				ImageLabel_1.ScaleType = Enum.ScaleType.Crop

				UIGradient_1.Parent = ImageLabel_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				Inside_1.Name = "Inside"
				Inside_1.Parent = Paragarp
				Inside_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Inside_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Inside_1.BackgroundTransparency = 1
				Inside_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Inside_1.BorderSizePixel = 0
				Inside_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Inside_1.Size = UDim2.new(1, 0,1, 0)

				UIListLayout_1.Parent = Inside_1
				UIListLayout_1.Padding = UDim.new(0,0)
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

				Title_1.Name = "Title"
				Title_1.Parent = Inside_1
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Position = UDim2.new(0.499876201, 0,0.368333131, 0)
				Title_1.Size = UDim2.new(0.927587509, 0,0, 15)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.RichText = true
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 14
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				Desc_1.Name = "Desc"
				Desc_1.Parent = Inside_1
				Desc_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Desc_1.BackgroundTransparency = 1
				Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Desc_1.BorderSizePixel = 0
				Desc_1.Position = UDim2.new(0.499876201, 0,0.664999783, 0)
				Desc_1.Size = UDim2.new(0.927587509, 0,0, 0)
				Desc_1.Font = Enum.Font.GothamBold
				Desc_1.RichText = true
				Desc_1.Text = Desc
				Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
				Desc_1.TextSize = 10
				Desc_1.TextTransparency = 0.5
				Desc_1.TextWrapped = true
				Desc_1.TextXAlignment = Enum.TextXAlignment.Left
				Desc_1.TextYAlignment = Enum.TextYAlignment.Top

				UIPadding_1.Parent = Inside_1
				UIPadding_1.PaddingLeft = UDim.new(0,10)
				UIPadding_1.PaddingTop = UDim.new(0,5)

				local descHeight = Desc_1.TextBounds.Y + 5
				Desc_1.Size = UDim2.new(0.927587509, 0, 0, descHeight)
				Paragarp.Size = UDim2.new(0.97, 0, 0, descHeight + 25)
				
				local Index = {}
				
				function Index:Title(v)
					Title_1.Text = v
				end
				
				function Index:Desc(v)
					Desc_1.Text = v
					local descHeight = Desc_1.TextBounds.Y + 5
					Desc_1.Size = UDim2.new(0.927587509, 0, 0, descHeight)
					Paragarp.Size = UDim2.new(0.97, 0, 0, descHeight + 35)
				end
				
				function Index:Visible(v)
					Paragarp.Visible = v
				end

				return Index
			end

			function Env._Class:Textbox(meta)
				
				local Value = meta.Value or "Example"
				local PlaceHolder = meta.PlaceHolder or "Place"
				local ClearOnFocus = meta.ClearOnFocus or false
				local Callback = meta.Callback
				
				local Textbox = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local ImageLabel_1 = Instance.new("ImageLabel")
				local UIGradient_1 = Instance.new("UIGradient")
				local Edit_1 = Instance.new("TextBox")
				local UICorner_2 = Instance.new("UICorner")
				local UIStroke_1 = Instance.new("UIStroke")
				local UIGradient_2 = Instance.new("UIGradient")
				local UIGradient_3 = Instance.new("UIGradient")

				Textbox.Name = "Textbox"
				Textbox.Parent = Section_1
				Textbox.AnchorPoint = Vector2.new(0.5, 0.5)
				Textbox.BackgroundColor3 = Color3.fromRGB(0,0,0)
				Textbox.BackgroundTransparency = 0.5
				Textbox.BorderColor3 = Color3.fromRGB(0,0,0)
				Textbox.BorderSizePixel = 0
				Textbox.Size = UDim2.new(0.970000029, 0,0, 40)
				Textbox.ClipsDescendants = true

				UICorner_1.Parent = Textbox
				UICorner_1.CornerRadius = UDim.new(0,5)

				ImageLabel_1.Parent = Textbox
				ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ImageLabel_1.Size = UDim2.new(1, 50,1, 0)
				ImageLabel_1.Image = "rbxassetid://72380279434385"
				ImageLabel_1.ImageTransparency = 0.8999999761581421
				ImageLabel_1.ScaleType = Enum.ScaleType.Crop

				UIGradient_1.Parent = ImageLabel_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				Edit_1.Name = "Edit"
				Edit_1.Parent = Textbox
				Edit_1.Active = true
				Edit_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Edit_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Edit_1.BackgroundTransparency = 0.8500000238418579
				Edit_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Edit_1.BorderSizePixel = 0
				Edit_1.CursorPosition = -1
				Edit_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Edit_1.Size = UDim2.new(0.949999988, 0,0.699999988, 0)
				Edit_1.ClipsDescendants = true
				Edit_1.Font = Enum.Font.GothamBold
				Edit_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
				Edit_1.PlaceholderText = tostring(PlaceHolder)
				Edit_1.RichText = true
				Edit_1.Text = tostring(Value)
				Edit_1.TextColor3 = Color3.fromRGB(255,255,255)
				Edit_1.TextSize = 14
				Edit_1.ClearTextOnFocus = ClearOnFocus

				UICorner_2.Parent = Edit_1
				UICorner_2.CornerRadius = UDim.new(1,0)

				UIStroke_1.Parent = Edit_1
				UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke_1.Color = Color3.fromRGB(255,255,255)
				UIStroke_1.Thickness = 1
				UIStroke_1.Transparency = 0.5

				UIGradient_2.Parent = UIStroke_1
				UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				UIGradient_3.Parent = Edit_1
				UIGradient_3.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				Edit_1.FocusLost:Connect(function()
					if #Edit_1.Text > 0 then
						pcall(Callback, Edit_1.Text)
					end
					tw({
						v = UIStroke_1,
						t = 0.3,
						s = "Back",
						d = "Out",
						g = {Transparency = 0.5}
					}):Play()
				end)
				
				Edit_1.Focused:Connect(function()
					tw({
						v = UIStroke_1,
						t = 0.3,
						s = "Back",
						d = "Out",
						g = {Transparency = 0}
					}):Play()
				end)
				
				local Index = {}

				function Index:Value(v)
					Value = v
					Title_1.Text = v
				end

				function Index:Visible(v)
					Textbox.Visible = v
				end

				return Index
			end

			function Env._Class:Slider(info)
				local Title = info.Title
				local Desc = info.Desc
				local Min = info.Min or 0
				local Max = info.Max or 100
				local Rounding = info.Rounding or 0
				local Value = info.Value or Min
				local Callback = info.CallBack or function() end
			
				local Slider = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local ImageLabel_1 = Instance.new("ImageLabel")
				local UIGradient_1 = Instance.new("UIGradient")
				local Title_1 = Instance.new("TextLabel")
				local Bar_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local BarValue_1 = Instance.new("Frame")
				local UICorner_3 = Instance.new("UICorner")
				local UIGradient_2 = Instance.new("UIGradient")
				local ValueBox_1 = Instance.new("TextBox")
				local UICorner_4 = Instance.new("UICorner")
				local Slide = click(Bar_1)

				Slider.Name = "Slider"
				Slider.Parent = Section_1
				Slider.AnchorPoint = Vector2.new(0.5, 0.5)
				Slider.BackgroundColor3 = Color3.fromRGB(0,0,0)
				Slider.BackgroundTransparency = 0.5
				Slider.BorderColor3 = Color3.fromRGB(0,0,0)
				Slider.BorderSizePixel = 0
				Slider.Size = UDim2.new(0.970000029, 0,0, 60)
				Slider.ClipsDescendants = true

				UICorner_1.Parent = Slider
				UICorner_1.CornerRadius = UDim.new(0,5)

				ImageLabel_1.Parent = Slider
				ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ImageLabel_1.Size = UDim2.new(1, 50,1, 0)
				ImageLabel_1.Image = "rbxassetid://72380279434385"
				ImageLabel_1.ImageTransparency = 0.8999999761581421
				ImageLabel_1.ScaleType = Enum.ScaleType.Crop

				UIGradient_1.Parent = ImageLabel_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				Title_1.Name = "Title"
				Title_1.Parent = Slider
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.LayoutOrder = -3
				Title_1.Position = UDim2.new(0.0360824727, 0,0.0857142881, 0)
				Title_1.Size = UDim2.new(0.927834988, 0,0, 20)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 14
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				Bar_1.Name = "Bar"
				Bar_1.Parent = Slider
				Bar_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Bar_1.BackgroundColor3 = Color3.fromRGB(42,42,42)
				Bar_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Bar_1.BorderSizePixel = 0
				Bar_1.Position = UDim2.new(0.5, 0,0.649999976, 0)
				Bar_1.Size = UDim2.new(0, 253,0, 20)
				Bar_1.ClipsDescendants = true

				UICorner_2.Parent = Bar_1
				UICorner_2.CornerRadius = UDim.new(1,0)

				BarValue_1.Name = "BarValue"
				BarValue_1.Parent = Bar_1
				BarValue_1.AnchorPoint = Vector2.new(0, 0.5)
				BarValue_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				BarValue_1.BorderColor3 = Color3.fromRGB(0,0,0)
				BarValue_1.BorderSizePixel = 0
				BarValue_1.Position = UDim2.new(0, 0,0.5, 0)
				BarValue_1.Size = UDim2.new(0, 200,0, 20)

				UICorner_3.Parent = BarValue_1
				UICorner_3.CornerRadius = UDim.new(1,0)

				UIGradient_2.Parent = BarValue_1
				UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				ValueBox_1.Name = "ValueBox"
				ValueBox_1.Parent = Slider
				ValueBox_1.Active = true
				ValueBox_1.AnchorPoint = Vector2.new(1, 0.5)
				ValueBox_1.BackgroundColor3 = Color3.fromRGB(44,44,44)
				ValueBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ValueBox_1.BorderSizePixel = 0
				ValueBox_1.Position = UDim2.new(0.949999988, 0,0.25, 0)
				ValueBox_1.Size = UDim2.new(0, 29,0, 15)
				ValueBox_1.Font = Enum.Font.GothamBold
				ValueBox_1.PlaceholderText = tostring(Value)
				ValueBox_1.Text = tostring(Value)
				ValueBox_1.TextColor3 = Color3.fromRGB(255,255,255)
				ValueBox_1.TextSize = 10
				ValueBox_1.TextTransparency = 0.30000001192092896

				UICorner_4.Parent = ValueBox_1
				UICorner_4.CornerRadius = UDim.new(1,0)
				
				local function roundToDecimal(value, decimals)
					local factor = 10 ^ decimals
					return math.floor(value * factor + 0.5) / factor
				end

				local function updateSlider(value)
					value = math.clamp(value, Min, Max)
					value = roundToDecimal(value, Rounding)

					tw({
						v = BarValue_1,
						t = 0.15,
						s = "Exponential",
						d = "Out",
						g = {Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)}
					}):Play()

					local startValue = tonumber(ValueBox_1.Text) or 0
					local targetValue = value

					local steps = 5
					local currentValue = startValue
					for i = 1, steps do
						wait(0.1 / steps)
						currentValue = currentValue + (targetValue - startValue) / steps
						ValueBox_1.Text = tostring(roundToDecimal(currentValue, Rounding))
						ValueBox_1.Size = UDim2.new(0, ValueBox_1.TextBounds.X + 20, 0, 15)
					end

					ValueBox_1.Text = tostring(roundToDecimal(targetValue, Rounding))
					ValueBox_1.Size = UDim2.new(0, ValueBox_1.TextBounds.X + 20, 0, 15)

					Callback(value)
				end

				updateSlider(Value or 0)

				ValueBox_1.FocusLost:Connect(function()
					local value = tonumber(ValueBox_1.Text) or Min
					updateSlider(value)
				end)

				local function move(input)
					local sliderBar = Bar_1
					local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
					local value = relativeX * (Max - Min) + Min
					updateSlider(value)
				end

				local dragging = false

				Slide.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						move(input)
					end
				end)

				Slide.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						move(input)
					end
				end)

				local NewValue = {}

				function NewValue:SetValue(a)
					Value = a
					updateSlider(Value)
				end

				function NewValue:SetVisible(a)
					Slider.Visible = a
				end

				function NewValue:SetTitle(b)
					Title_1.Text = b
				end

				return NewValue
			end

			function Env._Class:Dropdown(info)
				local Title = info.Title
				local List = info.List
				local Value = info.Value
				local Multi = info.Multi or false
				local Callback = info.Callback
				
				local Dropdownz = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local ImageLabel_1 = Instance.new("ImageLabel")
				local UIGradient_1 = Instance.new("UIGradient")
				local Title_1 = Instance.new("TextLabel")
				local Desc_1 = Instance.new("TextLabel")
				local UIGradient_2 = Instance.new("UIGradient")
				local icon_1 = Instance.new("ImageLabel")
				local UIGradient_3 = Instance.new("UIGradient")
				local ClickDropdown = click(Dropdownz)

				Dropdownz.Name = "Dropdown"
				Dropdownz.Parent = Section_1
				Dropdownz.AnchorPoint = Vector2.new(0.5, 0.5)
				Dropdownz.BackgroundColor3 = Color3.fromRGB(0,0,0)
				Dropdownz.BackgroundTransparency = 0.5
				Dropdownz.BorderColor3 = Color3.fromRGB(0,0,0)
				Dropdownz.BorderSizePixel = 0
				Dropdownz.Size = UDim2.new(0.970000029, 0,0, 45)
				Dropdownz.ClipsDescendants = true

				UICorner_1.Parent = Dropdownz
				UICorner_1.CornerRadius = UDim.new(0,5)

				ImageLabel_1.Parent = Dropdownz
				ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ImageLabel_1.Size = UDim2.new(1, 50,1, 0)
				ImageLabel_1.Image = "rbxassetid://72380279434385"
				ImageLabel_1.ImageTransparency = 0.8999999761581421
				ImageLabel_1.ScaleType = Enum.ScaleType.Crop

				UIGradient_1.Parent = ImageLabel_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				Title_1.Name = "Title"
				Title_1.Parent = Dropdownz
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.LayoutOrder = -3
				Title_1.Position = UDim2.new(0.0360824727, 0,0.0857142881, 0)
				Title_1.Size = UDim2.new(0.927834988, 0,0, 20)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 14
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				Desc_1.Name = "Desc"
				Desc_1.Parent = Dropdownz
				Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Desc_1.BackgroundTransparency = 1
				Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Desc_1.BorderSizePixel = 0
				Desc_1.LayoutOrder = -3
				Desc_1.Position = UDim2.new(0.0360825323, 0,0.435713708, 0)
				Desc_1.Size = UDim2.new(0.927999973, 0,0, 20)
				Desc_1.Font = Enum.Font.GothamBold
				if type(Value) == "table" then
					Desc_1.Text = "( . . . . . . )"
				else
					Desc_1.Text = tostring(Value)
				end
				Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
				Desc_1.TextSize = 12
				Desc_1.TextXAlignment = Enum.TextXAlignment.Left

				UIGradient_2.Parent = Desc_1
				UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
				UIGradient_2.Offset = Vector2.new(0, 0.00999999978)
				UIGradient_2.Rotation = 90

				icon_1.Name = "icon"
				icon_1.Parent = Dropdownz
				icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
				icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				icon_1.BackgroundTransparency = 1
				icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
				icon_1.BorderSizePixel = 0
				icon_1.Position = UDim2.new(0.899999976, 0,0.5, 0)
				icon_1.Size = UDim2.new(0, 30,0, 30)
				icon_1.Image = "rbxassetid://129573215183311"
				icon_1.ScaleType = Enum.ScaleType.Crop

				UIGradient_3.Parent = icon_1
				UIGradient_3.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
				

				local Dropdown = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local Effect_1 = Instance.new("ImageLabel")
				local Head_1 = Instance.new("Frame")
				local Title_1 = Instance.new("TextLabel")
				local Line_1 = Instance.new("Frame")
				local UIGradient_1 = Instance.new("UIGradient")
				local Body_1 = Instance.new("Frame")
				local Search_1 = Instance.new("TextBox")
				local UICorner_2 = Instance.new("UICorner")
				local UIGradient_2 = Instance.new("UIGradient")
				local UIStroke_1 = Instance.new("UIStroke")
				local UIGradient_3 = Instance.new("UIGradient")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local ScrollingFrame_1 = Instance.new("ScrollingFrame")
				local UIListLayout_2 = Instance.new("UIListLayout")

				Dropdown.Name = "Dropdown"
				Dropdown.Parent = Background_1
				Dropdown.AnchorPoint = Vector2.new(1, 0.5)
				Dropdown.BackgroundColor3 = Color3.fromRGB(0,0,0)
				Dropdown.BackgroundTransparency = 0.10000000149011612
				Dropdown.BorderColor3 = Color3.fromRGB(0,0,0)
				Dropdown.BorderSizePixel = 0
				Dropdown.Position = UDim2.new(1.0, 0,0.5, 0)
				Dropdown.Size = UDim2.new(0, 0,1, 0)
				Dropdown.ClipsDescendants = true

				UICorner_1.Parent = Dropdown

				Effect_1.Name = "Effect"
				Effect_1.Parent = Dropdown
				Effect_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Effect_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Effect_1.BackgroundTransparency = 1
				Effect_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Effect_1.BorderSizePixel = 0
				Effect_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Effect_1.Size = UDim2.new(1, 0,1, 0)
				Effect_1.Image = "rbxassetid://132687652275989"
				Effect_1.ImageColor3 = Color3.fromRGB(0,255,127)
				Effect_1.ImageTransparency = 0.5
				Effect_1.ScaleType = Enum.ScaleType.Crop

				Head_1.Name = "Head"
				Head_1.Parent = Dropdown
				Head_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Head_1.BackgroundTransparency = 1
				Head_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Head_1.BorderSizePixel = 0
				Head_1.Size = UDim2.new(1, 0,-0.00410958892, 60)

				Title_1.Name = "Title"
				Title_1.Parent = Head_1
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.LayoutOrder = -3
				Title_1.Position = UDim2.new(0.551162779, 0,0.409273595, 0)
				Title_1.Size = UDim2.new(0.916279078, 0,0.442478806, 0)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 20
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				Line_1.Name = "Line"
				Line_1.Parent = Head_1
				Line_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Line_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Line_1.BorderSizePixel = 0
				Line_1.Position = UDim2.new(0, 20,0, 37)
				Line_1.Size = UDim2.new(0, 70,0, 2)

				UIGradient_1.Parent = Line_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				Body_1.Name = "Body"
				Body_1.Parent = Dropdown
				Body_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Body_1.BackgroundTransparency = 1
				Body_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Body_1.BorderSizePixel = 0
				Body_1.Position = UDim2.new(0, 0,0.128452078, 0)
				Body_1.Size = UDim2.new(1, 0,0.707164347, 60)

				Search_1.Name = "Search"
				Search_1.Parent = Body_1
				Search_1.Active = true
				Search_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Search_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Search_1.BackgroundTransparency = 0.9
				Search_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Search_1.BorderSizePixel = 0
				Search_1.CursorPosition = -1
				Search_1.Position = UDim2.new(0.5, 0,0.0324371532, 0)
				Search_1.Size = UDim2.new(0.899999976, 0,0.0649953708, 0)
				Search_1.Font = Enum.Font.GothamBold
				Search_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
				Search_1.PlaceholderText = "Search"
				Search_1.Text = ""
				Search_1.TextColor3 = Color3.fromRGB(255,255,255)
				Search_1.TextSize = 14

				UICorner_2.Parent = Search_1
				UICorner_2.CornerRadius = UDim.new(1,0)

				UIGradient_2.Parent = Search_1
				UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				UIStroke_1.Parent = Search_1
				UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke_1.Color = Color3.fromRGB(255,255,255)
				UIStroke_1.Thickness = 1

				UIGradient_3.Parent = UIStroke_1
				UIGradient_3.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
				UIGradient_3.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0.5), NumberSequenceKeypoint.new(1,0.5)}

				UIListLayout_1.Parent = Body_1
				UIListLayout_1.Padding = UDim.new(0,7)
				UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

				ScrollingFrame_1.Name = "ScrollingFrame"
				ScrollingFrame_1.Parent = Body_1
				ScrollingFrame_1.Active = true
				ScrollingFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ScrollingFrame_1.BackgroundTransparency = 1
				ScrollingFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ScrollingFrame_1.BorderSizePixel = 0
				ScrollingFrame_1.Position = UDim2.new(0.0500000007, 0,0.0870016962, 0)
				ScrollingFrame_1.Size = UDim2.new(0.899999976, 0,0.886351407, 0)
				ScrollingFrame_1.ClipsDescendants = true
				ScrollingFrame_1.AutomaticCanvasSize = Enum.AutomaticSize.None
				ScrollingFrame_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
				ScrollingFrame_1.CanvasPosition = Vector2.new(0, 0)
				ScrollingFrame_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
				ScrollingFrame_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
				ScrollingFrame_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
				ScrollingFrame_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
				ScrollingFrame_1.ScrollBarImageTransparency = 1
				ScrollingFrame_1.ScrollBarThickness = 0
				ScrollingFrame_1.ScrollingDirection = Enum.ScrollingDirection.XY
				ScrollingFrame_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
				ScrollingFrame_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
				ScrollingFrame_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

				UIListLayout_2.Parent = ScrollingFrame_1
				UIListLayout_2.Padding = UDim.new(0,5)
				UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
				
				local isOpen = false
				UserInputService.InputBegan:Connect(function(A)
					if A.UserInputType == Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch then
						local B, C = Dropdown.AbsolutePosition, Dropdown.AbsoluteSize
						if game:GetService "Players".LocalPlayer:GetMouse().X < B.X or game:GetService "Players".LocalPlayer:GetMouse().X > B.X + C.X or game:GetService "Players".LocalPlayer:GetMouse().Y < (B.Y - 20 - 1) or game:GetService "Players".LocalPlayer:GetMouse().Y > B.Y + C.Y then
							isOpen = false
							tw({
								v = Dropdown,
								t = 0.3,
								s = "Bounce",
								d = "Out",
								g = {Size = UDim2.new(0, 0,1, 0)}
							}):Play()
						end
					end
				end)
				
				ClickDropdown.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					if isOpen then
						tw({
							v = Dropdown,
							t = 0.3,
							s = "Bounce",
							d = "Out",
							g = {Size = UDim2.new(0, 215,1, 0)}
						}):Play()
					else
						tw({
							v = Dropdown,
							t = 0.3,
							s = "Bounce",
							d = "Out",
							g = {Size = UDim2.new(0, 0,1, 0)}
						}):Play()
						task.wait(0.07)
					end
					EffectClick2(ClickDropdown, Dropdownz)
					tw({
						v = icon_1,
						t = 0.15,
						s = "Bounce",
						d = "Out",
						g = {Size = UDim2.new(0, 40,0, 40)}
					}):Play()
					delay(0.06, function()
						tw({
							v = icon_1,
							t = 0.15,
							s = "Bounce",
							d = "Out",
							g = {Size = UDim2.new(0, 30,0, 30)}
						}):Play()
					end)
					EffectClick2(ClickDropdown, Dropdown)
				end)
				
				Search_1.Changed:Connect(function()
					local SearchT = string.lower(Search_1.Text)
					for i, v in pairs(ScrollingFrame_1:GetChildren()) do
						if v:IsA("Frame") then
							local labelText = string.lower(v.Real.Title.Text)
							if string.find(labelText, SearchT, 1, true) then
								v.Visible = true
							else
								v.Visible = false
							end
						end
					end
				end)
				
				
				local itemslist = {}
				local selectedItem

				function itemslist:Clear(a)
					local function shouldClear(v)
						if a == nil then
							return true
						elseif type(a) == "string" then
							return v.Real:FindFirstChild("Title") and v.Real.Title.Text == a
						elseif type(a) == "table" then
							for _, name in ipairs(a) do
								if v.Real:FindFirstChild("Title") and v.Real.Title.Text == name then
									return true
								end
							end
						end
						return false
					end

					for _, v in ipairs(ScrollingFrame_1:GetChildren()) do
						if v:IsA("Frame") and shouldClear(v) then
							if selectedItem and v.Real:FindFirstChild("Title") and v.Real.Title.Text == selectedItem then
								selectedItem = nil
								Desc_1.Text = ""
							end
							v:Destroy()
						end
					end

					if selectedItem == a or Desc_1.Text == a then
						selectedItem = nil
						Desc_1.Text = ""
					end

					if a == nil then
						selectedItem = nil
						Desc_1.Text = ""
					end
				end
				
				local selectedValues = {}
				
				function itemslist:AddList(text)
					local Items = Instance.new("Frame")
					local UIGradient_1 = Instance.new("UIGradient")
					local Real_1 = Instance.new("Frame")
					local Title_1 = Instance.new("TextLabel")
					local Line_1 = Instance.new("Frame")
					local UIGradient_2 = Instance.new("UIGradient")
					local UICorner_1 = Instance.new("UICorner")
					local ClickList = click(Items)

					Items.Name = "Items"
					Items.Parent = ScrollingFrame_1
					Items.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Items.BackgroundTransparency = 0.8999999761581421
					Items.BorderColor3 = Color3.fromRGB(0,0,0)
					Items.BorderSizePixel = 0
					Items.Size = UDim2.new(1, 0,0, 30)

					UIGradient_1.Parent = Items
					UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

					Real_1.Name = "Real"
					Real_1.Parent = Items
					Real_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Real_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Real_1.BackgroundTransparency = 1
					Real_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Real_1.BorderSizePixel = 0
					Real_1.Position = UDim2.new(0.5, 0,0.5, 0)
					Real_1.Size = UDim2.new(1, 0,1, 0)

					Title_1.Name = "Title"
					Title_1.Parent = Real_1
					Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Title_1.BackgroundTransparency = 1
					Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Title_1.BorderSizePixel = 0
					Title_1.Position = UDim2.new(0.541989684, 0,0.5, 0)
					Title_1.Size = UDim2.new(0.916020691, 0,1, 0)
					Title_1.Font = Enum.Font.GothamBold
					Title_1.Text = tostring(text)
					Title_1.TextColor3 = Color3.fromRGB(255,255,255)
					Title_1.TextSize = 14
					Title_1.TextXAlignment = Enum.TextXAlignment.Left
					Title_1.TextTransparency = 0.5

					Line_1.Name = "Line"
					Line_1.Parent = Real_1
					Line_1.AnchorPoint = Vector2.new(0, 0.5)
					Line_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Line_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Line_1.BorderSizePixel = 0
					Line_1.Position = UDim2.new(0, 0,0.5, 0)
					Line_1.Size = UDim2.new(0, 5,0, 30)
					Line_1.BackgroundTransparency = 1

					UIGradient_2.Parent = Line_1
					UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
					UIGradient_2.Rotation = 90

					UICorner_1.Parent = Line_1
					UICorner_1.CornerRadius = UDim.new(1,0)
					
					ClickList.MouseButton1Click:Connect(function()
						if Multi then
							if selectedValues[text] then
								selectedValues[text] = nil
								tw({
									v = Title_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {TextTransparency = 0.5}
								}):Play()
								tw({
									v = Line_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {BackgroundTransparency = 1}
								}):Play()
							else
								selectedValues[text] = true
								tw({
									v = Title_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {TextTransparency = 0}
								}):Play()
								tw({
									v = Line_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {BackgroundTransparency = 0}
								}):Play()
							end
							local selectedList = {}
							for i, v in pairs(selectedValues) do
								table.insert(selectedList, i)
							end
							if #selectedList > 0 then
								Desc_1.Text = table.concat(selectedList, ", ")
							else
								Desc_1.Text = ""
							end
							pcall(Callback, selectedList)
						else
							for i,v in pairs(ScrollingFrame_1:GetChildren()) do
								if v:IsA("Frame") then
									tw({
										v = v.Real.Title,
										t = 0.15,
										s = "Exponential",
										d = "Out",
										g = {TextTransparency = 0.5}
									}):Play()
									tw({
										v = v.Real.Line,
										t = 0.15,
										s = "Exponential",
										d = "Out",
										g = {BackgroundTransparency = 1}
									}):Play()
								end
							end

							tw({
								v = Title_1,
								t = 0.15,
								s = "Exponential",
								d = "Out",
								g = {TextTransparency = 0}
							}):Play()
							tw({
								v = Line_1,
								t = 0.15,
								s = "Exponential",
								d = "Out",
								g = {BackgroundTransparency = 0}
							}):Play()
							tw({
								v = Dropdown,
								t = 0.3,
								s = "Bounce",
								d = "Out",
								g = {Size = UDim2.new(0, 0,1, 0)}
							}):Play()
							isOpen = false
							Value = text
							Desc_1.Text = text
							pcall(function()
								Callback(Desc_1.Text)
							end)
						end
					end)

					local function isValueInTable(val, tbl)
						if type(tbl) ~= "table" then
							return false
						end

						for _, v in pairs(tbl) do
							if v == val then
								return true
							end
						end
						return false
					end

					delay(0,function()
						if Multi then
							if isValueInTable(text, Value) then
								tw({
									v = Title_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {TextTransparency = 0}
								}):Play()
								tw({
									v = Line_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {BackgroundTransparency = 0}
								}):Play()
								selectedValues[text] = true
								local selectedList = {}
								for i, v in pairs(selectedValues) do
									table.insert(selectedList, i)
								end
								if #selectedList > 0 then
									Desc_1.Text = table.concat(selectedList, ", ")
								else
									Desc_1.Text = ""
								end
								pcall(Callback, selectedList)
							end
						else
							if text == Value then
								tw({
									v = Title_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {TextTransparency = 0}
								}):Play()
								tw({
									v = Line_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {BackgroundTransparency = 0}
								}):Play()

								Value = text
								Desc_1.Text = text
								Callback(Desc_1.Text)
							end
						end
					end)
				end
				
				for i,v in ipairs(List) do
					itemslist:AddList(v, i)
				end

				UIListLayout_2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					ScrollingFrame_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_2.AbsoluteContentSize.Y + 5)
				end)

				return itemslist
			end

			function Env._Class:Keybind(info)
				local Title = info.Title
				local Key = info.Key or Enum.KeyCode.Q
				local Value = info.Value or false
				local Callback = info.Callback or function() end
				
				local Keybind = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local ImageLabel_1 = Instance.new("ImageLabel")
				local UIGradient_1 = Instance.new("UIGradient")
				local Title_1 = Instance.new("TextLabel")
				local Bin_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local UIGradient_2 = Instance.new("UIGradient")
				local TextLabel_1 = Instance.new("TextLabel")
				local ClickChange = click(Keybind)

				Keybind.Name = "Keybind"
				Keybind.Parent = Section_1
				Keybind.AnchorPoint = Vector2.new(0.5, 0.5)
				Keybind.BackgroundColor3 = Color3.fromRGB(0,0,0)
				Keybind.BackgroundTransparency = 0.5
				Keybind.BorderColor3 = Color3.fromRGB(0,0,0)
				Keybind.BorderSizePixel = 0
				Keybind.Size = UDim2.new(0.970000029, 0,0, 45)
				Keybind.ClipsDescendants = true

				UICorner_1.Parent = Keybind
				UICorner_1.CornerRadius = UDim.new(0,5)

				ImageLabel_1.Parent = Keybind
				ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ImageLabel_1.Size = UDim2.new(1, 50,1, 0)
				ImageLabel_1.Image = "rbxassetid://72380279434385"
				ImageLabel_1.ImageTransparency = 0.8999999761581421
				ImageLabel_1.ScaleType = Enum.ScaleType.Crop

				UIGradient_1.Parent = ImageLabel_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}

				Title_1.Name = "Title"
				Title_1.Parent = Keybind
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.LayoutOrder = -3
				Title_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Title_1.Size = UDim2.new(0.927834988, 0,0, 20)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 14
				Title_1.TextTransparency = 0.5
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				Bin_1.Name = "Bin"
				Bin_1.Parent = Keybind
				Bin_1.AnchorPoint = Vector2.new(1, 0.5)
				Bin_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Bin_1.BackgroundTransparency = 0.5
				Bin_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Bin_1.BorderSizePixel = 0
				Bin_1.Position = UDim2.new(0.97, 0,0.5, 0)
				Bin_1.Size = UDim2.new(0, 30,0, 25)

				UICorner_2.Parent = Bin_1

				UIGradient_2.Parent = Bin_1
				UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
				UIGradient_2.Rotation = 144

				TextLabel_1.Parent = Bin_1
				TextLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
				TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextLabel_1.BackgroundTransparency = 1
				TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextLabel_1.BorderSizePixel = 0
				TextLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
				TextLabel_1.Size = UDim2.new(1, 0,1, 0)
				TextLabel_1.Font = Enum.Font.GothamBold
				TextLabel_1.Text = tostring(Value)
				TextLabel_1.TextColor3 = Color3.fromRGB(255,255,255)
				TextLabel_1.TextSize = 13
				
				local function adjustBoxBindSize()
					local textSize = game:GetService("TextService"):GetTextSize(TextLabel_1.Text, TextLabel_1.TextSize, TextLabel_1.Font, Vector2.new(1000, 1000))
					Bin_1.Size = UDim2.new(0, textSize.X + 15, 0, 25)
				end

				adjustBoxBindSize()

				local function changeKey()
					TextLabel_1.Text = "..."
					local inputConnection
					tw({
						v = Title_1,
						t = 0.15,
						s = "Linear",
						d = "Out",
						g = {TextTransparency = 0}
					}):Play()

					inputConnection = game:GetService("UserInputService").InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Keyboard then
							Key = input.KeyCode
							TextLabel_1.Text = tostring(Key):gsub("Enum.KeyCode.", "")
							adjustBoxBindSize()
							inputConnection:Disconnect()
							tw({
								v = Title_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {TextTransparency = 0.5}
							}):Play()
							tw({
								v = Bin_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {BackgroundTransparency = 0.5}
							}):Play()
							Callback(Key, Value)
						end
					end)
				end

				UserInputService.InputEnded:Connect(function(input, gameProcessed)
					if input.KeyCode == Key then
						Value = not Value
						if Value then
							tw({
								v = Title_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {TextTransparency = 0}
							}):Play()
							tw({
								v = Bin_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {BackgroundTransparency = 0}
							}):Play()
						else
							tw({
								v = Title_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {TextTransparency = 0.5}
							}):Play()
							tw({
								v = Bin_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {BackgroundTransparency = 0.5}
							}):Play()
						end
						Callback(Key, Value)
					end
				end)

				delay(0, function()
					Callback(Key, Value)
				end)

				ClickChange.MouseButton1Click:Connect(function()
					changeKey()
					EffectClick2(ClickChange, Keybind)
				end)
			end

			return Env._Class
		end

		return Env.Section
	end

	return Env.Tabs
end

return Env
