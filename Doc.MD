<div align="center">

🏔️ Ascent Library v1.7

The Modern, macOS-Inspired UI Library for Luau

<p align="center">
<img src="https://www.google.com/search?q=https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" width="100" alt="Logo Placeholder" />
</p>

Ascent is a high-performance, fully responsive UI library designed to bring the sleek aesthetics of macOS to your Roblox scripts. Featuring dynamic scaling, transparency control, rich text support, and a powerful interactive notification system.

Features • Installation • Documentation • Examples

</div>

✨ Features

🎨 Dynamic Theming: Switch between MacDark and MacLight or adjust global transparency on the fly.

📏 UI Scaling: Built-in SetScale API to support 4K screens or compact mobile displays.

📝 Rich Text: Full support for HTML-like tags (<b>, <i>, <font>) in titles, labels, and toggles.

📱 Mobile Ready: Draggable windows and touch-optimized controls.

🔔 Advanced Notifications: Positionable alerts with interactive buttons (Actions).

🧩 Extensions: Powerful Extend() method for toggles to create side-panels, popups, or sub-menus.

⚙️ Built-in Settings: Auto-generated user settings page for transparency, server hopping, and anonymity.

📥 Installation

Load the library directly into your script using loadstring.

local Ascent = loadstring(game:HttpGet("YOUR_RAW_GITHUB_LINK_HERE.lua"))()


📘 Documentation

1. Global Settings

Control the global appearance of the library.

Method

Description

Example

Ascent:SetScale(number)

Sets the UI size multiplier. Default is 1.0.

Ascent:SetScale(1.2)

Ascent:SetTransparency(number)

Sets the background opacity (0-1).

Ascent:SetTransparency(0.2)

Ascent:SetTheme(string)

Switches the theme.

Ascent:SetTheme("MacLight")

2. Creating a Window

The main entry point. Supports Rich Text in the title.

local Window = Ascent:CreateWindow({
    Title = "<b>Ascent</b> <font color='#007AFF'>Premium</font>",
    Size = UDim2.fromOffset(750, 500)
})


3. Tabs & Layouts

Standard Tab

local MainTab = Window:CreateTab("Home", "rbxassetid://6034509993")


Double Canvas (Side-by-Side)

Creates a tab split into left and right columns.

local Left, Right = Window:CreateDoubleTab("Combat", "rbxassetid://6034509923")
-- Add elements to 'Left' or 'Right'


Tab Groups

Group multiple tabs under a collapsible header in the sidebar.

local Group = Window:CreateTabGroup("Legit", "rbxassetid://...")
local AimbotTab = Group:CreateTab("Aimbot", "rbxassetid://...")


4. Components API

All components are added to a Section. First, create a section:

local Section = MainTab:AddSection("Main Features")


🏷️ Label

Supports Rich Text.

Section:AddLabel("Status: <font color='#48D158'>Active</font>")


🔘 Button

Section:AddButton({
    Text = "Refresh Config",
    Tooltip = "Reloads the configuration file",
    Callback = function()
        print("Clicked!")
    end
})


🎚️ Toggle & Extensions

Toggles allow for Extend(), creating a sub-menu attached to the toggle.

Variants: Switch (Default), Checkbox.

Extension Variants: Side (Slides from right), Full (Covers page), Popup (Floating).

local Aura = Section:AddToggle({
    Text = "Kill Aura",
    Default = false,
    Flag = "AuraEnabled", -- For Config Saving
    Callback = function(state) print(state) end
})

-- Create a Side Settings Panel for this toggle
local AuraSettings = Aura:Extend({ Variant = "Side" })

AuraSettings:AddSlider({ Text = "Range", Min = 1, Max = 25, Default = 15 })


🎚️ Slider

Includes a numeric input box for precise values.

Section:AddSlider({
    Text = "Walkspeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})


🔽 Dropdown

Supports Single or Multi-selection.

Section:AddDropdown({
    Text = "Target Priority",
    Items = {"Distance", "Health", "Shield"},
    Default = "Distance",
    Multi = false, -- Set to true for multiple selections
    Callback = function(value) print(value) end
})


⌨️ Keybind & Textbox

Section:AddKeybind({
    Text = "Toggle Menu",
    Default = Enum.KeyCode.RightControl,
    Callback = function(key) print("New Key:", key) end
})

Section:AddTextbox({
    Text = "Custom Message",
    Placeholder = "Type here...",
    Callback = function(text) print(text) end
})


5. 🔔 Interactive Notifications

The notification system supports HTML styling, positioning, and clickable action buttons.

Set Position

Ascent:SetNotificationPosition("bottom") 
-- Options: "left", "right", "bottom", "under" (Center)


Send Notification

Ascent:Notify({
    Title = "<b>System Alert</b>",
    Content = "Do you want to enable <font color='#FF453A'>Rage Mode</font>?",
    Type = "Warning", -- Success, Warning, Error, Info
    Duration = 10,
    Actions = {
        {
            Text = "Enable",
            Callback = function() print("Enabled") end
        },
        {
            Text = "Cancel",
            Callback = function() print("Cancelled") end
        }
    }
})


💾 Configuration System

Ascent handles saving and loading flags automatically using the Flag parameter in elements.

Ascent:SaveConfig() -- Saves to workspace/AscentLib_Configs/config.json
Ascent:LoadConfig() -- Loads settings and updates UI automatically


<div align="center">

Credits

Created by [Your Name] • UI Design inspired by macOS Big Sur

</div>
