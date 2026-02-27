local Library = loadstring(game:HttpGet(""))() -- Replace with your rawlink or use require()
-- Or if loading locally:
-- local Library = require(path.to.Main)

local Window, Loader = Library:Create({
	Title    = "Phantom",
	SubTitle = "Ultimate Suite",
	Version  = "v2.4.1",
	Loader   = true,
})

Loader:Start()

Loader:SetText("Loading core modules...")
task.wait(1.2)

Loader:SetText("Initializing renderer...")
task.wait(0.9)

Loader:SetText("Connecting services...")
task.wait(0.8)

Loader:SetText("Almost ready...")
task.wait(0.6)

Loader:End()

-- ─── Tab 1: Combat ───────────────────────────────────────────────
local CombatTab = Window:Tab("Combat")

local aimSection = CombatTab:Section("Aimbot")

local aimToggle = aimSection:Toggle({
	Name     = "Enable Aimbot",
	Default  = false,
	Callback = function(state)
		print("Aimbot:", state)
	end,
})

local fovSlider = aimSection:Slider({
	Name     = "Field of View",
	Min      = 10,
	Max      = 360,
	Default  = 90,
	Suffix   = "°",
	Callback = function(value)
		print("FOV:", value)
	end,
})

local smoothSlider = aimSection:Slider({
	Name     = "Smoothness",
	Min      = 1,
	Max      = 100,
	Default  = 50,
	Suffix   = "%",
	Callback = function(value)
		print("Smooth:", value)
	end,
})

local targetSection = CombatTab:Section("Target")

local partDrop = targetSection:Dropdown({
	Name     = "Target Part",
	Options  = { "Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm" },
	Default  = "Head",
	Callback = function(value)
		print("Part:", value)
	end,
})

local teamCheck = targetSection:Toggle({
	Name     = "Team Check",
	Default  = true,
	Callback = function(state)
		print("Team Check:", state)
	end,
})

local visCheck = targetSection:Toggle({
	Name     = "Visibility Check",
	Default  = false,
	Callback = function(state)
		print("Vis Check:", state)
	end,
})

-- ─── Tab 2: Player ────────────────────────────────────────────────
local PlayerTab = Window:Tab("Player")

local moveSection = PlayerTab:Section("Movement")

local speedSlider = moveSection:Slider({
	Name     = "Walk Speed",
	Min      = 16,
	Max      = 500,
	Default  = 16,
	Callback = function(value)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = value
		end
	end,
})

local jumpSlider = moveSection:Slider({
	Name     = "Jump Power",
	Min      = 0,
	Max      = 500,
	Default  = 50,
	Callback = function(value)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.JumpPower = value
		end
	end,
})

local flyToggle = moveSection:Toggle({
	Name     = "Fly",
	Default  = false,
	Callback = function(state)
		print("Fly:", state)
	end,
})

local miscSection = PlayerTab:Section("Miscellaneous")

miscSection:Button({
	Name     = "Reset Character",
	Callback = function()
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.Health = 0
		end
	end,
})

miscSection:Button({
	Name     = "Rejoin Server",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId)
	end,
})

-- ─── Tab 3: Visual ────────────────────────────────────────────────
local VisualTab = Window:Tab("Visual")

local espSection = VisualTab:Section("ESP")

local espToggle = espSection:Toggle({
	Name     = "Enable ESP",
	Default  = false,
	Callback = function(state)
		print("ESP:", state)
	end,
})

local espModeDrop = espSection:Dropdown({
	Name     = "ESP Mode",
	Options  = { "Box", "Skeleton", "Dot", "Name Tag", "Health Bar" },
	Default  = "Box",
	Callback = function(value)
		print("ESP Mode:", value)
	end,
})

local colorSection = VisualTab:Section("Colors")

local teamColorToggle = colorSection:Toggle({
	Name     = "Team Colors",
	Default  = true,
	Callback = function(state)
		print("Team Colors:", state)
	end,
})

local alphaSlider = colorSection:Slider({
	Name     = "Opacity",
	Min      = 0,
	Max      = 100,
	Default  = 80,
	Suffix   = "%",
	Callback = function(value)
		print("Alpha:", value)
	end,
})

-- ─── Tab 4: Config ────────────────────────────────────────────────
local ConfigTab = Window:Tab("Config")

local profileSection = ConfigTab:Section("Profile")

local profileInput = profileSection:Input({
	Name        = "Config Name",
	Placeholder = "e.g. MyConfig",
	Callback    = function(value)
		print("Config name:", value)
	end,
})

profileSection:Button({
	Name     = "Save Config",
	Callback = function()
		local name = profileInput.Get()
		print("Saving:", name)
	end,
})

profileSection:Button({
	Name     = "Load Config",
	Callback = function()
		print("Loading config...")
	end,
})

local infoSection = ConfigTab:Section("Info")

infoSection:Paragraph({
	Title   = "About Phantom",
	Content = "Phantom is a modern, lightweight UI framework built for performance and clarity. All settings persist across sessions. Join our community for updates and support.",
})

infoSection:Paragraph({
	Title   = "Keybinds",
	Content = "<b>Insert</b> — Toggle visibility\n<b>Delete</b> — Unload script\n<b>F5</b> — Reload config",
})
