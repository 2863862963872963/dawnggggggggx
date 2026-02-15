--[[
    Ascent UI Library - Example Usage
    This demonstrates all features including:
    - Window creation
    - Tab management
    - All UI elements
    - DPI scaling
    - Mobile support
    - Notifications
    - Settings integration
]]

-- Load the library
local AscentUI = loadstring(game:HttpGet("your-url-here"))()
-- Or if local: local AscentUI = loadfile("AscentUI.lua")()

-- Auto-detect and set optimal DPI
local detectedDPI = AscentUI:AutoDetectDPI()
print("Detected DPI Scale:", detectedDPI)

-- Check if running on mobile
local isMobile = AscentUI.Utils:IsMobile()
print("Mobile Device:", isMobile)

-- Create main window
local Window = AscentUI:CreateWindow({
    Title = "Ascent NextGen",
    Subtitle = "PREMIUM",
    Size = UDim2.new(0, 600, 0, 450),
    Draggable = true,
    Resizable = false,
    CloseButton = true
})

-- Show welcome notification
AscentUI:Notify({
    Title = "Welcome!",
    Description = "Ascent UI has been loaded successfully.",
    Duration = 3,
    Type = "Success"
})

-- ═══════════════════════════════════════════════════════════
-- HOME TAB
-- ═══════════════════════════════════════════════════════════

local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "🏠"
})

local WelcomeSection = HomeTab:CreateSection("Welcome")
WelcomeSection:SetSubtitle("Get started with Ascent UI")

WelcomeSection:CreateLabel("Welcome to Ascent NextGen! This is a modern, iOS-styled UI library for Roblox with full mobile support and DPI scaling.")

WelcomeSection:CreateDivider()

local statusLabel = WelcomeSection:CreateLabel("Status: Active ✓")

WelcomeSection:CreateButton({
    Name = "Test Notification",
    Callback = function()
        AscentUI:Notify({
            Title = "Button Clicked!",
            Description = "This is a test notification.",
            Duration = 2,
            Type = "Info"
        })
    end
})

local QuickActionsSection = HomeTab:CreateSection("Quick Actions")

QuickActionsSection:CreateButton({
    Name = "Show Success Notification",
    Callback = function()
        AscentUI:Notify({
            Title = "Success!",
            Description = "Operation completed successfully.",
            Duration = 3,
            Type = "Success"
        })
    end
})

QuickActionsSection:CreateButton({
    Name = "Show Warning",
    Callback = function()
        AscentUI:Notify({
            Title = "Warning!",
            Description = "This is a warning message.",
            Duration = 3,
            Type = "Warning"
        })
    end
})

QuickActionsSection:CreateButton({
    Name = "Show Error",
    Callback = function()
        AscentUI:Notify({
            Title = "Error!",
            Description = "Something went wrong.",
            Duration = 3,
            Type = "Error"
        })
    end
})

-- ═══════════════════════════════════════════════════════════
-- FEATURES TAB
-- ═══════════════════════════════════════════════════════════

local FeaturesTab = Window:CreateTab({
    Name = "Features",
    Icon = "⚡",
    Badge = 3
})

local TogglesSection = FeaturesTab:CreateSection("Toggle Controls")
TogglesSection:SetSubtitle("Enable or disable features")

local espToggle = TogglesSection:CreateToggle({
    Name = "ESP",
    Description = "Show player boxes",
    Default = false,
    Callback = function(value)
        print("ESP:", value)
        AscentUI:Notify({
            Title = "ESP " .. (value and "Enabled" or "Disabled"),
            Description = "ESP has been " .. (value and "turned on" or "turned off"),
            Duration = 2,
            Type = value and "Success" or "Info"
        })
    end
})

TogglesSection:CreateToggle({
    Name = "Tracers",
    Description = "Draw lines to players",
    Default = false,
    Callback = function(value)
        print("Tracers:", value)
    end
})

TogglesSection:CreateToggle({
    Name = "Name Tags",
    Description = "Display player names",
    Default = true,
    Callback = function(value)
        print("Name Tags:", value)
    end
})

local SlidersSection = FeaturesTab:CreateSection("Slider Controls")

local fovSlider = SlidersSection:CreateSlider({
    Name = "FOV",
    Min = 60,
    Max = 120,
    Default = 90,
    Increment = 1,
    Callback = function(value)
        print("FOV:", value)
        workspace.CurrentCamera.FieldOfView = value
    end
})

SlidersSection:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        print("Walk Speed:", value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

SlidersSection:CreateSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 200,
    Default = 50,
    Increment = 5,
    Callback = function(value)
        print("Jump Power:", value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = value
        end
    end
})

local DropdownsSection = FeaturesTab:CreateSection("Dropdown Controls")

local weaponDropdown = DropdownsSection:CreateDropdown({
    Name = "Weapon",
    Options = {"Pistol", "Rifle", "Shotgun", "Sniper", "SMG"},
    Default = "Rifle",
    Callback = function(value)
        print("Selected Weapon:", value)
        AscentUI:Notify({
            Title = "Weapon Changed",
            Description = "Selected: " .. value,
            Duration = 2,
            Type = "Info"
        })
    end
})

DropdownsSection:CreateDropdown({
    Name = "Team",
    Options = {"Red Team", "Blue Team", "Green Team", "Yellow Team"},
    Default = "Blue Team",
    Callback = function(value)
        print("Selected Team:", value)
    end
})

-- ═══════════════════════════════════════════════════════════
-- VISUALS TAB
-- ═══════════════════════════════════════════════════════════

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "👁️"
})

local ESPSection = VisualsTab:CreateSection("ESP Settings")

ESPSection:CreateToggle({
    Name = "Box ESP",
    Description = "Draw boxes around players",
    Default = false,
    Callback = function(value)
        print("Box ESP:", value)
    end
})

ESPSection:CreateToggle({
    Name = "Name ESP",
    Description = "Show player names",
    Default = false,
    Callback = function(value)
        print("Name ESP:", value)
    end
})

ESPSection:CreateToggle({
    Name = "Distance ESP",
    Description = "Show distance to players",
    Default = false,
    Callback = function(value)
        print("Distance ESP:", value)
    end
})

ESPSection:CreateToggle({
    Name = "Health ESP",
    Description = "Show player health bars",
    Default = false,
    Callback = function(value)
        print("Health ESP:", value)
    end
})

local ChamsSection = VisualsTab:CreateSection("Chams")

ChamsSection:CreateToggle({
    Name = "Enable Chams",
    Description = "Highlight players through walls",
    Default = false,
    Callback = function(value)
        print("Chams:", value)
    end
})

ChamsSection:CreateSlider({
    Name = "Transparency",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 5,
    Callback = function(value)
        print("Chams Transparency:", value)
    end
})

local WorldSection = VisualsTab:CreateSection("World")

WorldSection:CreateToggle({
    Name = "Fullbright",
    Description = "Remove darkness",
    Default = false,
    Callback = function(value)
        print("Fullbright:", value)
        if value then
            game.Lighting.Brightness = 2
            game.Lighting.ClockTime = 14
            game.Lighting.FogEnd = 100000
            game.Lighting.GlobalShadows = false
            game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            game.Lighting.Brightness = 1
            game.Lighting.ClockTime = 12
            game.Lighting.FogEnd = 100000
            game.Lighting.GlobalShadows = true
            game.Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        end
    end
})

WorldSection:CreateToggle({
    Name = "No Fog",
    Description = "Remove fog effects",
    Default = false,
    Callback = function(value)
        print("No Fog:", value)
        if value then
            game.Lighting.FogEnd = 100000
        else
            game.Lighting.FogEnd = 100000
        end
    end
})

-- ═══════════════════════════════════════════════════════════
-- MISC TAB
-- ═══════════════════════════════════════════════════════════

local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "🔧"
})

local MovementSection = MiscTab:CreateSection("Movement")

MovementSection:CreateToggle({
    Name = "Infinite Jump",
    Description = "Jump infinitely",
    Default = false,
    Callback = function(value)
        print("Infinite Jump:", value)
        local player = game.Players.LocalPlayer
        local infjump = value
        
        if infjump then
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if infjump and player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

MovementSection:CreateToggle({
    Name = "No Clip",
    Description = "Walk through walls",
    Default = false,
    Callback = function(value)
        print("No Clip:", value)
        local player = game.Players.LocalPlayer
        local noclip = value
        
        if noclip then
            game:GetService("RunService").Stepped:Connect(function()
                if noclip and player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

local TeleportSection = MiscTab:CreateSection("Teleport")

TeleportSection:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local spawn = workspace:FindFirstChild("SpawnLocation")
            if spawn then
                player.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
                AscentUI:Notify({
                    Title = "Teleported",
                    Description = "Teleported to spawn location",
                    Duration = 2,
                    Type = "Success"
                })
            end
        end
    end
})

local UtilitySection = MiscTab:CreateSection("Utility")

UtilitySection:CreateButton({
    Name = "Copy Game ID",
    Callback = function()
        setclipboard(tostring(game.PlaceId))
        AscentUI:Notify({
            Title = "Copied!",
            Description = "Game ID copied to clipboard",
            Duration = 2,
            Type = "Success"
        })
    end
})

UtilitySection:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

UtilitySection:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        
        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
        
        AscentUI:Notify({
            Title = "Server Hopping",
            Description = "Finding new server...",
            Duration = 2,
            Type = "Info"
        })
    end
})

-- ═══════════════════════════════════════════════════════════
-- SETTINGS TAB (Built-in)
-- ═══════════════════════════════════════════════════════════

local SettingsTab = AscentUI:CreateSettingsTab(Window)

-- Add custom settings to the settings tab
local CustomSection = SettingsTab:CreateSection("Custom Settings")

CustomSection:CreateToggle({
    Name = "Save Settings",
    Description = "Auto-save settings on change",
    Default = true,
    Callback = function(value)
        print("Auto-save settings:", value)
    end
})

CustomSection:CreateButton({
    Name = "Reset Settings",
    Callback = function()
        AscentUI:Notify({
            Title = "Settings Reset",
            Description = "All settings have been reset to default",
            Duration = 3,
            Type = "Warning"
        })
    end
})

-- ═══════════════════════════════════════════════════════════
-- KEYBINDS
-- ═══════════════════════════════════════════════════════════

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle UI with Right Shift
    if input.KeyCode == Enum.KeyCode.RightShift then
        Window:Toggle()
    end
    
    -- Toggle ESP with E
    if input.KeyCode == Enum.KeyCode.E then
        espToggle:SetValue(not espToggle.Value)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- INFO
-- ═══════════════════════════════════════════════════════════

print([[
════════════════════════════════════════════════════════════════
             ASCENT UI - LOADED SUCCESSFULLY
════════════════════════════════════════════════════════════════
Version: 2.0.0
Mobile Support: ]] .. tostring(isMobile) .. [[

DPI Scale: ]] .. tostring(AscentUI.Settings.DPIScale) .. [[

Theme: ]] .. AscentUI.Settings.Theme .. [[


Keybinds:
  [Right Shift] - Toggle UI
  [E] - Toggle ESP

API Functions:
  - AscentUI:CreateWindow(config)
  - AscentUI:SetDPIScale(scale)
  - AscentUI:AutoDetectDPI()
  - AscentUI:SetTheme(themeName)
  - AscentUI:Notify(config)
  - Window:CreateTab(config)
  - Tab:CreateSection(name)
  - Section:CreateButton(config)
  - Section:CreateToggle(config)
  - Section:CreateSlider(config)
  - Section:CreateDropdown(config)
  - Section:CreateLabel(text)
  - Section:CreateDivider()

════════════════════════════════════════════════════════════════
]])

-- Show info notification
AscentUI:Notify({
    Title = "Ascent UI v2.0.0",
    Description = "Press Right Shift to toggle UI",
    Duration = 5,
    Type = "Info"
})
