--[[
    Ascent UI - Complete Example Script
    This example demonstrates all available features and best practices
]]

-- Load the library
local AscentUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/2863862963872963/dawnggggggggx/refs/heads/main/Alot/AscentUI.lua"))()

-- Create the main window
local Window = AscentUI:CreateWindow({
    Title = "Ascent",
    Subtitle = "PREMIUM UTILITY",
    Size = UDim2.new(0, 1100, 0, 720),
    Theme = "Cyan"  -- Options: Cyan, Purple, Red, Green, Orange
})

-- Show welcome notification
Window:CreateNotification({
    Title = "Welcome!",
    Message = "Ascent UI loaded successfully",
    Icon = "👋",
    Duration = 4
})

--[[
    TAB 1: COMBAT
    Demonstrates combat-related features
]]

local CombatTab = Window:CreateTab({
    Name = "Combat",
    Icon = "rbxassetid://7733779610",
    Description = "Combat features and weapon modifications"
})

-- Aimbot Section (Left Column)
local AimbotSection = CombatTab:CreateSection({
    Name = "Aimbot",
    Icon = "🎯",
    Side = "Left"
})

-- Global variables to store settings
_G.Settings = {
    Aimbot = {
        Enabled = false,
        FOV = 90,
        Smoothness = 0.5,
        TargetPart = "Head",
        TeamCheck = true,
        VisibilityCheck = true
    },
    ESP = {
        Enabled = false,
        Distance = 2000,
        ShowHealth = true,
        ShowDistance = true,
        BoxColor = "Cyan"
    },
    Weapon = {
        InfiniteAmmo = false,
        NoRecoil = false,
        RapidFire = false,
        FireRate = 1
    }
}

-- Aimbot Toggle
local AimbotToggle = AimbotSection:CreateToggle({
    Name = "Enable Aimbot",
    Description = "Automatically aim at targets",
    Default = false,
    Callback = function(value)
        _G.Settings.Aimbot.Enabled = value
        Window:CreateNotification({
            Title = value and "Aimbot Enabled" or "Aimbot Disabled",
            Message = value and "Target locking active" or "Aimbot deactivated",
            Icon = value and "✅" or "❌",
            Duration = 3
        })
    end
})

-- FOV Slider
local FOVSlider = AimbotSection:CreateSlider({
    Name = "FOV Size",
    Description = "Field of view radius in pixels",
    Min = 0,
    Max = 360,
    Default = 90,
    Increment = 5,
    Callback = function(value)
        _G.Settings.Aimbot.FOV = value
    end
})

-- Smoothness Slider
local SmoothnessSlider = AimbotSection:CreateSlider({
    Name = "Aim Smoothness",
    Description = "Lower = faster, Higher = smoother",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Increment = 0.1,
    Callback = function(value)
        _G.Settings.Aimbot.Smoothness = value
    end
})

-- Target Part Dropdown
local TargetPartDropdown = AimbotSection:CreateDropdown({
    Name = "Target Part",
    Description = "Body part to aim at",
    Options = {"Head", "Torso", "HumanoidRootPart", "UpperTorso", "Random"},
    Default = "Head",
    Callback = function(value)
        _G.Settings.Aimbot.TargetPart = value
        Window:CreateNotification({
            Title = "Target Changed",
            Message = "Now targeting: " .. value,
            Icon = "🎯",
            Duration = 2
        })
    end
})

-- Team Check Toggle
AimbotSection:CreateToggle({
    Name = "Team Check",
    Description = "Don't target teammates",
    Default = true,
    Callback = function(value)
        _G.Settings.Aimbot.TeamCheck = value
    end
})

-- Visibility Check Toggle
AimbotSection:CreateToggle({
    Name = "Visibility Check",
    Description = "Only target visible enemies",
    Default = true,
    Callback = function(value)
        _G.Settings.Aimbot.VisibilityCheck = value
    end
})

-- ESP Section (Right Column)
local ESPSection = CombatTab:CreateSection({
    Name = "ESP / Visuals",
    Icon = "👁️",
    Side = "Right"
})

-- ESP Toggle
local ESPToggle = ESPSection:CreateToggle({
    Name = "Enable ESP",
    Description = "Show player boxes and information",
    Default = false,
    Callback = function(value)
        _G.Settings.ESP.Enabled = value
        Window:CreateNotification({
            Title = value and "ESP Enabled" or "ESP Disabled",
            Message = value and "Player boxes visible" or "ESP deactivated",
            Icon = value and "✅" or "❌",
            Duration = 3
        })
    end
})

-- ESP Distance Slider
ESPSection:CreateSlider({
    Name = "Max Distance",
    Description = "Maximum render distance for ESP",
    Min = 100,
    Max = 5000,
    Default = 2000,
    Increment = 100,
    Callback = function(value)
        _G.Settings.ESP.Distance = value
    end
})

-- Show Health Toggle
ESPSection:CreateToggle({
    Name = "Show Health",
    Description = "Display health bars",
    Default = true,
    Callback = function(value)
        _G.Settings.ESP.ShowHealth = value
    end
})

-- Show Distance Toggle
ESPSection:CreateToggle({
    Name = "Show Distance",
    Description = "Display distance to players",
    Default = true,
    Callback = function(value)
        _G.Settings.ESP.ShowDistance = value
    end
})

-- Box Color Dropdown
ESPSection:CreateDropdown({
    Name = "Box Color",
    Description = "Color of ESP boxes",
    Options = {"Cyan", "Red", "Green", "Yellow", "Purple", "White"},
    Default = "Cyan",
    Callback = function(value)
        _G.Settings.ESP.BoxColor = value
    end
})

-- Weapon Modifications Section (Left Column)
local WeaponSection = CombatTab:CreateSection({
    Name = "Weapon Mods",
    Icon = "🔫",
    Side = "Left"
})

-- Infinite Ammo Toggle
WeaponSection:CreateToggle({
    Name = "Infinite Ammo",
    Description = "Never run out of ammunition",
    Default = false,
    Callback = function(value)
        _G.Settings.Weapon.InfiniteAmmo = value
        Window:CreateNotification({
            Title = value and "Infinite Ammo ON" or "Infinite Ammo OFF",
            Message = value and "Unlimited ammunition" or "Normal ammo count",
            Icon = "🔫",
            Duration = 3
        })
    end
})

-- No Recoil Toggle
WeaponSection:CreateToggle({
    Name = "No Recoil",
    Description = "Remove weapon recoil",
    Default = false,
    Callback = function(value)
        _G.Settings.Weapon.NoRecoil = value
    end
})

-- Rapid Fire Toggle
WeaponSection:CreateToggle({
    Name = "Rapid Fire",
    Description = "Increase fire rate",
    Default = false,
    Callback = function(value)
        _G.Settings.Weapon.RapidFire = value
    end
})

-- Fire Rate Slider
WeaponSection:CreateSlider({
    Name = "Fire Rate Multiplier",
    Description = "Multiply weapon fire rate",
    Min = 1,
    Max = 10,
    Default = 1,
    Increment = 0.5,
    Callback = function(value)
        _G.Settings.Weapon.FireRate = value
    end
})

--[[
    TAB 2: MOVEMENT
    Demonstrates player movement modifications
]]

local MovementTab = Window:CreateTab({
    Name = "Movement",
    Icon = "rbxassetid://7733920644",
    Description = "Player movement and mobility settings"
})

-- Speed Section (Left Column)
local SpeedSection = MovementTab:CreateSection({
    Name = "Speed Modifications",
    Icon = "⚡",
    Side = "Left"
})

_G.Settings.Movement = {
    SpeedEnabled = false,
    WalkSpeed = 16,
    JumpPower = 50,
    FlightEnabled = false,
    FlightSpeed = 50,
    NoClip = false
}

local SpeedToggle = SpeedSection:CreateToggle({
    Name = "Speed Hack",
    Description = "Modify your walk speed",
    Default = false,
    Callback = function(value)
        _G.Settings.Movement.SpeedEnabled = value
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if value then
                player.Character.Humanoid.WalkSpeed = _G.Settings.Movement.WalkSpeed
            else
                player.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

local WalkSpeedSlider = SpeedSection:CreateSlider({
    Name = "Walk Speed",
    Description = "Set your walking speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 2,
    Callback = function(value)
        _G.Settings.Movement.WalkSpeed = value
        local player = game.Players.LocalPlayer
        if _G.Settings.Movement.SpeedEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

local JumpPowerSlider = SpeedSection:CreateSlider({
    Name = "Jump Power",
    Description = "Set your jump height",
    Min = 50,
    Max = 300,
    Default = 50,
    Increment = 10,
    Callback = function(value)
        _G.Settings.Movement.JumpPower = value
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = value
        end
    end
})

-- Flight Section (Right Column)
local FlightSection = MovementTab:CreateSection({
    Name = "Flight & NoClip",
    Icon = "🕊️",
    Side = "Right"
})

FlightSection:CreateToggle({
    Name = "Flight Mode",
    Description = "Fly freely around the map",
    Default = false,
    Callback = function(value)
        _G.Settings.Movement.FlightEnabled = value
        Window:CreateNotification({
            Title = value and "Flight Enabled" or "Flight Disabled",
            Message = value and "Press Space to fly" or "Flight deactivated",
            Icon = value and "🕊️" or "❌",
            Duration = 3
        })
        -- Add your flight script here
    end
})

FlightSection:CreateSlider({
    Name = "Flight Speed",
    Description = "How fast you fly",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 5,
    Callback = function(value)
        _G.Settings.Movement.FlightSpeed = value
    end
})

FlightSection:CreateToggle({
    Name = "NoClip",
    Description = "Walk through walls",
    Default = false,
    Callback = function(value)
        _G.Settings.Movement.NoClip = value
        -- Add your noclip script here
    end
})

-- Teleport Section (Left Column)
local TeleportSection = MovementTab:CreateSection({
    Name = "Teleportation",
    Icon = "🌀",
    Side = "Left"
})

TeleportSection:CreateLabel("Teleport to predefined locations")

TeleportSection:CreateButton({
    Name = "Teleport to Spawn",
    Description = "Return to spawn point",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = workspace.SpawnLocation.CFrame * CFrame.new(0, 5, 0)
            Window:CreateNotification({
                Title = "Teleported",
                Message = "Returned to spawn",
                Icon = "🌀",
                Duration = 2
            })
        end
    end
})

--[[
    TAB 3: VISUALS
    Demonstrates visual modifications
]]

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "rbxassetid://7733764811",
    Description = "Visual modifications and enhancements"
})

-- Environment Section (Left Column)
local EnvironmentSection = VisualsTab:CreateSection({
    Name = "Environment",
    Icon = "🌍",
    Side = "Left"
})

_G.Settings.Visuals = {
    Fullbright = false,
    NoFog = false,
    CustomTime = false,
    TimeValue = 14,
    Ambient = false
}

EnvironmentSection:CreateToggle({
    Name = "Fullbright",
    Description = "Maximum brightness everywhere",
    Default = false,
    Callback = function(value)
        _G.Settings.Visuals.Fullbright = value
        local Lighting = game:GetService("Lighting")
        if value then
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
    end
})

EnvironmentSection:CreateToggle({
    Name = "No Fog",
    Description = "Remove all fog effects",
    Default = false,
    Callback = function(value)
        _G.Settings.Visuals.NoFog = value
        local Lighting = game:GetService("Lighting")
        if value then
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = 10000
        end
    end
})

local CustomTimeToggle = EnvironmentSection:CreateToggle({
    Name = "Custom Time",
    Description = "Set custom time of day",
    Default = false,
    Callback = function(value)
        _G.Settings.Visuals.CustomTime = value
        if value then
            game:GetService("Lighting").ClockTime = _G.Settings.Visuals.TimeValue
        end
    end
})

EnvironmentSection:CreateSlider({
    Name = "Time of Day",
    Description = "Set the time (0-24 hours)",
    Min = 0,
    Max = 24,
    Default = 14,
    Increment = 0.5,
    Callback = function(value)
        _G.Settings.Visuals.TimeValue = value
        if _G.Settings.Visuals.CustomTime then
            game:GetService("Lighting").ClockTime = value
        end
    end
})

-- Camera Section (Right Column)
local CameraSection = VisualsTab:CreateSection({
    Name = "Camera",
    Icon = "📷",
    Side = "Right"
})

_G.Settings.Camera = {
    FOV = 70,
    RemoveCameraLimits = false,
    CameraShake = true
}

CameraSection:CreateSlider({
    Name = "Field of View",
    Description = "Camera FOV (70 is default)",
    Min = 70,
    Max = 120,
    Default = 70,
    Increment = 5,
    Callback = function(value)
        _G.Settings.Camera.FOV = value
        workspace.CurrentCamera.FieldOfView = value
    end
})

CameraSection:CreateToggle({
    Name = "Remove Camera Limits",
    Description = "Zoom in/out infinitely",
    Default = false,
    Callback = function(value)
        _G.Settings.Camera.RemoveCameraLimits = value
        local player = game.Players.LocalPlayer
        if value then
            player.CameraMaxZoomDistance = 10000
            player.CameraMinZoomDistance = 0
        else
            player.CameraMaxZoomDistance = 20
            player.CameraMinZoomDistance = 0.5
        end
    end
})

CameraSection:CreateToggle({
    Name = "Camera Shake",
    Description = "Toggle camera shake effects",
    Default = true,
    Callback = function(value)
        _G.Settings.Camera.CameraShake = value
    end
})

-- UI Section (Left Column)
local UISection = VisualsTab:CreateSection({
    Name = "User Interface",
    Icon = "🖥️",
    Side = "Left"
})

UISection:CreateToggle({
    Name = "Hide Chat",
    Description = "Hide the chat window",
    Default = false,
    Callback = function(value)
        game:GetService("Players").LocalPlayer.PlayerGui.Chat.Frame.Visible = not value
    end
})

UISection:CreateToggle({
    Name = "Hide Player Names",
    Description = "Remove overhead player names",
    Default = false,
    Callback = function(value)
        local Players = game:GetService("Players")
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                for _, child in pairs(player.Character.Head:GetChildren()) do
                    if child:IsA("BillboardGui") then
                        child.Enabled = not value
                    end
                end
            end
        end
    end
})

--[[
    TAB 4: MISC
    Miscellaneous features and utilities
]]

local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "rbxassetid://7733954760",
    Description = "Miscellaneous features and utilities"
})

-- Player Section (Left Column)
local PlayerSection = MiscTab:CreateSection({
    Name = "Player",
    Icon = "👤",
    Side = "Left"
})

PlayerSection:CreateToggle({
    Name = "God Mode",
    Description = "Take no damage",
    Default = false,
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if value then
                player.Character.Humanoid.Health = math.huge
            else
                player.Character.Humanoid.Health = 100
            end
        end
        Window:CreateNotification({
            Title = value and "God Mode ON" or "God Mode OFF",
            Message = value and "You are invincible" or "Vulnerability restored",
            Icon = value and "🛡️" or "❌",
            Duration = 3
        })
    end
})

PlayerSection:CreateToggle({
    Name = "Infinite Stamina",
    Description = "Never get tired",
    Default = false,
    Callback = function(value)
        -- Add your stamina script here
    end
})

PlayerSection:CreateButton({
    Name = "Reset Character",
    Description = "Respawn your character",
    Callback = function()
        game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health = 0
        Window:CreateNotification({
            Title = "Respawning",
            Message = "Your character is respawning",
            Icon = "🔄",
            Duration = 2
        })
    end
})

-- Game Section (Right Column)
local GameSection = MiscTab:CreateSection({
    Name = "Game",
    Icon = "🎮",
    Side = "Right"
})

GameSection:CreateLabel("Game-specific features")

GameSection:CreateDropdown({
    Name = "Auto Farm Mode",
    Description = "Select farming mode",
    Options = {"Disabled", "Coins", "XP", "Resources", "All"},
    Default = "Disabled",
    Callback = function(value)
        Window:CreateNotification({
            Title = "Auto Farm",
            Message = "Mode set to: " .. value,
            Icon = "🌾",
            Duration = 3
        })
        -- Add your auto farm logic here
    end
})

GameSection:CreateButton({
    Name = "Collect All Rewards",
    Description = "Claim all available rewards",
    Callback = function()
        Window:CreateNotification({
            Title = "Collecting",
            Message = "Claiming all rewards...",
            Icon = "🎁",
            Duration = 3
        })
        -- Add your reward collection logic here
    end
})

-- Server Section (Left Column)
local ServerSection = MiscTab:CreateSection({
    Name = "Server",
    Icon = "🌐",
    Side = "Left"
})

ServerSection:CreateLabel("Server information and controls")

ServerSection:CreateButton({
    Name = "Server Hop",
    Description = "Join a different server",
    Callback = function()
        Window:CreateNotification({
            Title = "Server Hopping",
            Message = "Finding new server...",
            Icon = "🌐",
            Duration = 2
        })
        -- Add server hop logic here
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        
        local _place,_id = game.PlaceId, game.JobId
        local _servers = Api.._place.."/servers/Public?sortOrder=Desc&limit=100"
        
        function ListServers(cursor)
            local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
            return Http:JSONDecode(Raw)
        end
        
        local Next; repeat
            local Servers = ListServers(Next)
            for i,v in next, Servers.data do
                if v.playing < v.maxPlayers and v.id ~= _id then
                    TPS:TeleportToPlaceInstance(_place,v.id)
                    break
                end
            end
            Next = Servers.nextPageCursor
        until not Next
    end
})

ServerSection:CreateButton({
    Name = "Rejoin Server",
    Description = "Rejoin current server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})

--[[
    TAB 5: SETTINGS
    UI settings and configuration
]]

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "rbxassetid://7733964640",
    Description = "Configuration and preferences"
})

-- UI Settings Section (Left Column)
local UISettingsSection = SettingsTab:CreateSection({
    Name = "UI Configuration",
    Icon = "⚙️",
    Side = "Left"
})

UISettingsSection:CreateLabel("User interface settings and preferences")

local ThemeDropdown = UISettingsSection:CreateDropdown({
    Name = "UI Theme",
    Description = "Change the color theme",
    Options = {"Cyan", "Purple", "Red", "Green", "Orange"},
    Default = "Cyan",
    Callback = function(value)
        Window:CreateNotification({
            Title = "Theme Selected",
            Message = "Reload UI to apply " .. value .. " theme",
            Icon = "🎨",
            Duration = 5
        })
    end
})

UISettingsSection:CreateButton({
    Name = "Reset UI Position",
    Description = "Center the UI window",
    Callback = function()
        Window.ScreenGui.MainWindow.Position = UDim2.new(0.5, -550, 0.5, -360)
        Window:CreateNotification({
            Title = "Position Reset",
            Message = "UI has been centered",
            Icon = "📍",
            Duration = 2
        })
    end
})

-- Controls Section (Right Column)
local ControlsSection = SettingsTab:CreateSection({
    Name = "Controls",
    Icon = "🎮",
    Side = "Right"
})

ControlsSection:CreateLabel("Keybinds and control settings")

ControlsSection:CreateDropdown({
    Name = "Toggle UI Key",
    Description = "Key to show/hide the UI",
    Options = {"RightShift", "Insert", "End", "Home", "Delete"},
    Default = "RightShift",
    Callback = function(value)
        -- Add keybind logic here
        Window:CreateNotification({
            Title = "Keybind Updated",
            Message = "UI toggle set to: " .. value,
            Icon = "⌨️",
            Duration = 3
        })
    end
})

-- About Section (Left Column)
local AboutSection = SettingsTab:CreateSection({
    Name = "About",
    Icon = "ℹ️",
    Side = "Left"
})

AboutSection:CreateLabel("Ascent UI Library v1.0.0")
AboutSection:CreateLabel("Created for the Roblox community")
AboutSection:CreateLabel("Premium quality • Modern design")

AboutSection:CreateButton({
    Name = "Copy Discord",
    Description = "Copy Discord invite link",
    Callback = function()
        setclipboard("discord.gg/YOUR_INVITE")
        Window:CreateNotification({
            Title = "Copied!",
            Message = "Discord invite copied to clipboard",
            Icon = "📋",
            Duration = 3
        })
    end
})

-- Actions Section (Right Column)
local ActionsSection = SettingsTab:CreateSection({
    Name = "Actions",
    Icon = "⚡",
    Side = "Right"
})

ActionsSection:CreateButton({
    Name = "Save Configuration",
    Description = "Save current settings",
    Callback = function()
        -- Add save logic here
        writefile("AscentUI_Config.json", game:GetService("HttpService"):JSONEncode(_G.Settings))
        Window:CreateNotification({
            Title = "Configuration Saved",
            Message = "Your settings have been saved",
            Icon = "💾",
            Duration = 3
        })
    end
})

ActionsSection:CreateButton({
    Name = "Load Configuration",
    Description = "Load saved settings",
    Callback = function()
        -- Add load logic here
        if isfile("AscentUI_Config.json") then
            local data = readfile("AscentUI_Config.json")
            _G.Settings = game:GetService("HttpService"):JSONDecode(data)
            Window:CreateNotification({
                Title = "Configuration Loaded",
                Message = "Your settings have been restored",
                Icon = "📂",
                Duration = 3
            })
        else
            Window:CreateNotification({
                Title = "No Save Found",
                Message = "No saved configuration exists",
                Icon = "❌",
                Duration = 3
            })
        end
    end
})

ActionsSection:CreateButton({
    Name = "Reset All Settings",
    Description = "Restore default values",
    Callback = function()
        -- Reset all toggles and sliders to default
        AimbotToggle.SetValue(false)
        FOVSlider.SetValue(90)
        ESPToggle.SetValue(false)
        SpeedToggle.SetValue(false)
        WalkSpeedSlider.SetValue(16)
        
        Window:CreateNotification({
            Title = "Settings Reset",
            Message = "All settings restored to default",
            Icon = "🔄",
            Duration = 3
        })
    end
})

ActionsSection:CreateButton({
    Name = "Destroy UI",
    Description = "Close and remove the interface",
    Callback = function()
        Window:CreateNotification({
            Title = "Goodbye!",
            Message = "Thanks for using Ascent UI",
            Icon = "👋",
            Duration = 2
        })
        wait(2)
        Window:Destroy()
    end
})

-- Final setup
print("=====================================")
print("  Ascent UI - Loaded Successfully")
print("=====================================")
print("  Version: 1.0.0")
print("  Theme: " .. (Window.Theme and "Cyan" or "Default"))
print("  Tabs: " .. #Window.Tabs)
print("=====================================")

-- Keybind to toggle UI
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        Window.ScreenGui.Enabled = not Window.ScreenGui.Enabled
    end
end)
