--[[
	Ascent UI Library - Example Usage
	
	This example demonstrates all features of the library including:
	- Window creation
	- Tabs and sections
	- All UI components (toggles, sliders, dropdowns, buttons, etc.)
	- Mobile support
	- DPI scaling
	- Notifications
	- Custom themes
]]

-- Load the library
local AscentUI = loadstring(game:HttpGet("YOUR_SCRIPT_URL_HERE"))()

-- Optional: Customize theme before creating window
AscentUI:SetTheme({
	Colors = {
		Primary = Color3.fromRGB(0, 212, 255), -- Cyan
		-- You can override any theme color here
	}
})

-- Create main window
local window = AscentUI:CreateWindow({
	Title = "Ascent",
	Subtitle = "Advanced CSGO Utility",
	Size = UDim2.new(0, 1100, 0, 720) -- Auto-adjusts for mobile
})

--[[ ============================================
	DASHBOARD TAB
============================================ ]]
local dashboardTab = window:CreateTab({
	Name = "Dashboard",
	Icon = "Home"
})

-- Welcome Section
local welcomeSection = dashboardTab:CreateSection({
	Title = "Welcome",
	Icon = "Info",
	IconColor = "primary"
})

welcomeSection:AddLabel({
	Text = "Welcome to Ascent UI! This is a modern, mobile-friendly UI library for Roblox.",
	Size = 14
})

welcomeSection:AddButton({
	Title = "Show Notification",
	Icon = "Info",
	Style = "primary",
	Callback = function()
		window:CreateNotification({
			Title = "Hello!",
			Message = "This is a notification example.",
			Type = "success",
			Duration = 3
		})
	end
})

-- Statistics Section
local statsSection = dashboardTab:CreateSection({
	Title = "Statistics",
	Icon = "Target",
	IconColor = "success"
})

statsSection:AddLabel({
	Text = "Session Time: 00:45:23",
	Size = 13
})

statsSection:AddLabel({
	Text = "Total Toggles: 42",
	Size = 13
})

statsSection:AddLabel({
	Text = "Active Features: 18",
	Size = 13
})

--[[ ============================================
	AIMBOT TAB
============================================ ]]
local aimbotTab = window:CreateTab({
	Name = "Aimbot",
	Icon = "Target",
	Badge = "NEW"
})

-- Main Aimbot Settings
local mainAimbotSection = aimbotTab:CreateSection({
	Title = "Main Settings",
	Icon = "Crosshair",
	IconColor = "primary"
})

mainAimbotSection:AddToggle({
	Title = "Enable Aimbot",
	Description = "Master toggle for aimbot",
	Default = false,
	Callback = function(state)
		print("Aimbot enabled:", state)
	end
})

mainAimbotSection:AddSlider({
	Title = "FOV Circle",
	Min = 0,
	Max = 500,
	Default = 150,
	Step = 1,
	Callback = function(value)
		print("FOV set to:", value)
	end
})

mainAimbotSection:AddSlider({
	Title = "Smoothness",
	Min = 0,
	Max = 100,
	Default = 50,
	Step = 1,
	Callback = function(value)
		print("Smoothness set to:", value)
	end
})

mainAimbotSection:AddDropdown({
	Title = "Target Part",
	Options = {"Head", "Chest", "Torso", "Random"},
	Default = "Head",
	Callback = function(value)
		print("Target part:", value)
	end
})

mainAimbotSection:AddDropdown({
	Title = "Target Selection",
	Options = {"Closest", "Lowest HP", "Highest Threat", "Random"},
	Default = "Closest",
	Callback = function(value)
		print("Target selection:", value)
	end
})

-- Advanced Aimbot Settings
local advancedAimbotSection = aimbotTab:CreateSection({
	Title = "Advanced",
	Icon = "Settings",
	IconColor = "warning"
})

advancedAimbotSection:AddToggle({
	Title = "Visible Check",
	Description = "Only target visible enemies",
	Default = true,
	Callback = function(state)
		print("Visible check:", state)
	end
})

advancedAimbotSection:AddToggle({
	Title = "Team Check",
	Description = "Don't target teammates",
	Default = true,
	Callback = function(state)
		print("Team check:", state)
	end
})

advancedAimbotSection:AddToggle({
	Title = "Ignore Knocked",
	Description = "Skip knocked players",
	Default = false,
	Callback = function(state)
		print("Ignore knocked:", state)
	end
})

advancedAimbotSection:AddSlider({
	Title = "Max Distance",
	Min = 0,
	Max = 1000,
	Default = 500,
	Step = 10,
	Callback = function(value)
		print("Max distance:", value)
	end
})

--[[ ============================================
	VISUALS TAB
============================================ ]]
local visualsTab = window:CreateTab({
	Name = "Visuals",
	Icon = "Eye"
})

-- ESP Settings
local espSection = visualsTab:CreateSection({
	Title = "ESP",
	Icon = "Eye",
	IconColor = "primary"
})

espSection:AddToggle({
	Title = "Enable ESP",
	Description = "Master toggle for ESP",
	Default = false,
	Callback = function(state)
		print("ESP enabled:", state)
	end
})

espSection:AddToggle({
	Title = "Box ESP",
	Description = "Draw boxes around players",
	Default = true,
	Callback = function(state)
		print("Box ESP:", state)
	end
})

espSection:AddToggle({
	Title = "Name ESP",
	Description = "Show player names",
	Default = true,
	Callback = function(state)
		print("Name ESP:", state)
	end
})

espSection:AddToggle({
	Title = "Health ESP",
	Description = "Show player health",
	Default = true,
	Callback = function(state)
		print("Health ESP:", state)
	end
})

espSection:AddToggle({
	Title = "Distance ESP",
	Description = "Show distance to players",
	Default = false,
	Callback = function(state)
		print("Distance ESP:", state)
	end
})

espSection:AddToggle({
	Title = "Skeleton ESP",
	Description = "Draw player skeleton",
	Default = false,
	Callback = function(state)
		print("Skeleton ESP:", state)
	end
})

espSection:AddSlider({
	Title = "Max Distance",
	Min = 0,
	Max = 2000,
	Default = 1000,
	Step = 50,
	Callback = function(value)
		print("ESP Max distance:", value)
	end
})

-- Color Customization
local colorSection = visualsTab:CreateSection({
	Title = "Colors",
	Icon = "Settings",
	IconColor = "success"
})

colorSection:AddColorPicker({
	Title = "Box Color",
	Description = "Color of ESP boxes",
	Default = Color3.fromRGB(0, 212, 255),
	Callback = function(color)
		print("Box color:", color)
	end
})

colorSection:AddColorPicker({
	Title = "Name Color",
	Description = "Color of player names",
	Default = Color3.fromRGB(255, 255, 255),
	Callback = function(color)
		print("Name color:", color)
	end
})

colorSection:AddColorPicker({
	Title = "Health Bar Color",
	Description = "Color of health bars",
	Default = Color3.fromRGB(46, 213, 115),
	Callback = function(color)
		print("Health bar color:", color)
	end
})

-- Chams Settings
local chamsSection = visualsTab:CreateSection({
	Title = "Chams",
	Icon = "Eye",
	IconColor = "danger"
})

chamsSection:AddToggle({
	Title = "Enable Chams",
	Description = "Highlight players through walls",
	Default = false,
	Callback = function(state)
		print("Chams enabled:", state)
	end
})

chamsSection:AddSlider({
	Title = "Transparency",
	Min = 0,
	Max = 100,
	Default = 50,
	Step = 1,
	Callback = function(value)
		print("Chams transparency:", value)
	end
})

chamsSection:AddDropdown({
	Title = "Material",
	Options = {"Neon", "ForceField", "Glass", "Plastic"},
	Default = "Neon",
	Callback = function(value)
		print("Chams material:", value)
	end
})

--[[ ============================================
	MISC TAB
============================================ ]]
local miscTab = window:CreateTab({
	Name = "Misc",
	Icon = "Settings"
})

-- Movement Section
local movementSection = miscTab:CreateSection({
	Title = "Movement",
	Icon = "Users",
	IconColor = "primary"
})

movementSection:AddToggle({
	Title = "Speed Boost",
	Description = "Increase movement speed",
	Default = false,
	Callback = function(state)
		print("Speed boost:", state)
	end
})

movementSection:AddSlider({
	Title = "Speed Multiplier",
	Min = 1,
	Max = 5,
	Default = 1.5,
	Step = 0.1,
	Callback = function(value)
		print("Speed multiplier:", value)
	end
})

movementSection:AddToggle({
	Title = "Infinite Jump",
	Description = "Jump unlimited times",
	Default = false,
	Callback = function(state)
		print("Infinite jump:", state)
	end
})

movementSection:AddToggle({
	Title = "No Clip",
	Description = "Walk through walls",
	Default = false,
	Callback = function(state)
		print("No clip:", state)
	end
})

-- Automation Section
local automationSection = miscTab:CreateSection({
	Title = "Automation",
	Icon = "Target",
	IconColor = "success"
})

automationSection:AddToggle({
	Title = "Auto Accept",
	Description = "Accept matches automatically",
	Default = true,
	Callback = function(state)
		print("Auto accept:", state)
	end
})

automationSection:AddToggle({
	Title = "Auto Pistol",
	Description = "Rapid fire for semi-auto",
	Default = false,
	Callback = function(state)
		print("Auto pistol:", state)
	end
})

automationSection:AddToggle({
	Title = "Backtrack",
	Description = "Lag compensation exploit",
	Default = false,
	Callback = function(state)
		print("Backtrack:", state)
	end
})

-- Removals Section
local removalsSection = miscTab:CreateSection({
	Title = "Removals",
	Icon = "Eye",
	IconColor = "danger"
})

removalsSection:AddToggle({
	Title = "No Flash",
	Description = "Remove flashbang effect",
	Default = true,
	Callback = function(state)
		print("No flash:", state)
	end
})

removalsSection:AddToggle({
	Title = "No Smoke",
	Description = "See through smoke",
	Default = true,
	Callback = function(state)
		print("No smoke:", state)
	end
})

removalsSection:AddToggle({
	Title = "No Visual Recoil",
	Description = "Remove screen shake",
	Default = false,
	Callback = function(state)
		print("No visual recoil:", state)
	end
})

removalsSection:AddToggle({
	Title = "No Scope Border",
	Description = "Remove scope overlay",
	Default = false,
	Callback = function(state)
		print("No scope border:", state)
	end
})

-- Information Section
local infoSection = miscTab:CreateSection({
	Title = "Information",
	Icon = "Info",
	IconColor = "success"
})

infoSection:AddToggle({
	Title = "Spectator List",
	Description = "Show who's watching",
	Default = true,
	Callback = function(state)
		print("Spectator list:", state)
	end
})

infoSection:AddToggle({
	Title = "Rank Revealer",
	Description = "Show enemy ranks",
	Default = false,
	Callback = function(state)
		print("Rank revealer:", state)
	end
})

infoSection:AddToggle({
	Title = "Bomb Timer",
	Description = "Display detonation time",
	Default = true,
	Callback = function(state)
		print("Bomb timer:", state)
	end
})

infoSection:AddToggle({
	Title = "Grenade Prediction",
	Description = "Show trajectory path",
	Default = true,
	Callback = function(state)
		print("Grenade prediction:", state)
	end
})

--[[ ============================================
	CONFIGS TAB
============================================ ]]
local configsTab = window:CreateTab({
	Name = "Configs",
	Icon = "FileText"
})

local configSection = configsTab:CreateSection({
	Title = "Configuration Manager",
	Icon = "Settings",
	IconColor = "primary"
})

configSection:AddLabel({
	Text = "Save and load your settings configurations.",
	Size = 13
})

configSection:AddButton({
	Title = "Create New Config",
	Icon = "Plus",
	Style = "primary",
	Callback = function()
		window:CreateNotification({
			Title = "Config Created",
			Message = "Your configuration has been saved.",
			Type = "success",
			Duration = 3
		})
	end
})

configSection:AddButton({
	Title = "Import Config",
	Icon = "Upload",
	Style = "secondary",
	Callback = function()
		window:CreateNotification({
			Title = "Import",
			Message = "Select a configuration file to import.",
			Type = "info",
			Duration = 3
		})
	end
})

configSection:AddButton({
	Title = "Export Config",
	Icon = "Download",
	Style = "secondary",
	Callback = function()
		window:CreateNotification({
			Title = "Exported",
			Message = "Configuration exported to clipboard.",
			Type = "success",
			Duration = 3
		})
	end
})

configSection:AddDropdown({
	Title = "Load Config",
	Options = {"Competitive Rage", "Legit ESP Only", "HvH Configuration", "Legit Aimbot"},
	Default = "Competitive Rage",
	Callback = function(value)
		window:CreateNotification({
			Title = "Config Loaded",
			Message = "Loaded: " .. value,
			Type = "success",
			Duration = 3
		})
	end
})

-- Cloud Sync Section
local cloudSection = configsTab:CreateSection({
	Title = "Cloud Sync",
	Icon = "Upload",
	IconColor = "warning"
})

cloudSection:AddLabel({
	Text = "Enable cloud backup to sync configs across devices.",
	Size = 13
})

cloudSection:AddToggle({
	Title = "Cloud Sync",
	Description = "Sync configurations to cloud",
	Default = false,
	Callback = function(state)
		print("Cloud sync:", state)
		if state then
			window:CreateNotification({
				Title = "Cloud Sync Enabled",
				Message = "Your configs will now sync across devices.",
				Type = "success",
				Duration = 3
			})
		end
	end
})

--[[ ============================================
	SETTINGS TAB
============================================ ]]
local settingsTab = window:CreateTab({
	Name = "Settings",
	Icon = "Settings"
})

-- UI Settings
local uiSection = settingsTab:CreateSection({
	Title = "UI Settings",
	Icon = "Settings",
	IconColor = "primary"
})

uiSection:AddDropdown({
	Title = "Theme",
	Options = {"Dark (Default)", "Blue", "Purple", "Red", "Green"},
	Default = "Dark (Default)",
	Callback = function(value)
		print("Theme:", value)
		window:CreateNotification({
			Title = "Theme Changed",
			Message = "Theme set to: " .. value,
			Type = "info",
			Duration = 3
		})
	end
})

uiSection:AddSlider({
	Title = "UI Scale",
	Min = 0.5,
	Max = 1.5,
	Default = 1,
	Step = 0.1,
	Callback = function(value)
		print("UI Scale:", value)
	end
})

uiSection:AddToggle({
	Title = "Show FPS",
	Description = "Display FPS counter",
	Default = true,
	Callback = function(state)
		print("Show FPS:", state)
	end
})

uiSection:AddToggle({
	Title = "Notifications",
	Description = "Enable notification popups",
	Default = true,
	Callback = function(state)
		print("Notifications:", state)
	end
})

-- Keybinds Section
local keybindsSection = settingsTab:CreateSection({
	Title = "Keybinds",
	Icon = "Target",
	IconColor = "success"
})

keybindsSection:AddLabel({
	Text = "Configure your keyboard shortcuts.",
	Size = 13
})

keybindsSection:AddButton({
	Title = "Toggle UI",
	Style = "secondary",
	Callback = function()
		window:CreateNotification({
			Title = "Keybind",
			Message = "Press a key to bind...",
			Type = "info",
			Duration = 3
		})
	end
})

keybindsSection:AddButton({
	Title = "Toggle Aimbot",
	Style = "secondary",
	Callback = function()
		window:CreateNotification({
			Title = "Keybind",
			Message = "Press a key to bind...",
			Type = "info",
			Duration = 3
		})
	end
})

-- About Section
local aboutSection = settingsTab:CreateSection({
	Title = "About",
	Icon = "Info",
	IconColor = "primary"
})

aboutSection:AddLabel({
	Text = "Ascent UI Library v1.0.0",
	Size = 14
})

aboutSection:AddLabel({
	Text = "A modern, mobile-friendly UI library for Roblox.",
	Size = 12
})

aboutSection:AddLabel({
	Text = "Features: DPI Scaling, Mobile Support, Custom Themes",
	Size = 12
})

aboutSection:AddButton({
	Title = "Check for Updates",
	Icon = "Download",
	Style = "primary",
	Callback = function()
		window:CreateNotification({
			Title = "Up to Date",
			Message = "You're running the latest version!",
			Type = "success",
			Duration = 3
		})
	end
})

-- Show welcome notification
wait(1)
window:CreateNotification({
	Title = "Welcome to Ascent!",
	Message = "All features loaded successfully.",
	Type = "success",
	Duration = 4
})

print("Ascent UI loaded successfully!")
