
# Fluriore UI – Documentation

Fluriore UI is a modern Roblox UI Library designed for speed, customization, and simplicity.  
This documentation covers every function, all UI elements, and usage examples.

## Load Library
```lua
local FlurioreLib = loadstring(game:HttpGet("YOUR_LIBRARY_URL"))()
```

## Notification
```lua
local Notify = FlurioreLib:MakeNotify({
    Title = "Fluriore UI",
    Description = "Notification",
    Color = Color3.fromRGB(255, 0, 255),
    Content = "Welcome to Fluriore UI",
    Time = 1,
    Delay = 10
})
```

## Create Main GUI
```lua
local FlurioreGui = FlurioreLib:MakeGui({
    NameHub = "Fluriore UI",
    Description = "made by Teru",
    Color = Color3.fromRGB(255, 0, 255),
    LogoPlayer = "https://www.roblox.com/headshot-thumbnail/image?userId="..
        game.Players.LocalPlayer.UserId.."&width=420&height=420&format=png",
    NamePlayer = game.Players.LocalPlayer.Name,
    TabWidth = 125
})
```

## Create Tabs
```lua
local MainTab = FlurioreGui:CreateTab({
    Name = "Main",
    Icon = "rbxassetid://7733960981"
})

local SettingTab = FlurioreGui:CreateTab({
    Name = "Setting",
    Icon = "rbxassetid://7734053495"
})
```

## Sections
```lua
local Section = MainTab:AddSection("Setting Farm")
```

## Paragraph
```lua
local Paragraph = Section:AddParagraph({
    Title = "Paragraph",
    Content = "This is a Paragraph"
})
Paragraph:Set({
    Title = "Paragraph",
    Content = "This is a Paragraph"
})
```

## Toggle
```lua
local Toggle = Section:AddToggle({
    Title = "Toggle",
    Content = "This is a Toggle",
    Default = false,
    Callback = function(value)
        print(value)
    end
})
Toggle:Set(false)
print(Toggle.Value)
```

## Button
```lua
local Button = Section:AddButton({
    Title = "Button",
    Content = "This is a Button",
    Icon = "rbxassetid://16932740082",
    Callback = function()
        print("Button Clicked!")
    end
})
```

## Slider
```lua
local Slider = Section:AddSlider({
    Title = "Slider",
    Content = "This is a Slider",
    Min = 0,
    Max = 100,
    Increment = 1,
    Default = 30,
    Callback = function(value)
        print(value)
    end
})
Slider:Set(30)
print(Slider.Value)
```

## Input
```lua
local Input = Section:AddInput({
    Title = "Input",
    Content = "This is a Input",
    Callback = function(value)
        print(value)
    end
})
Input:Set("Input TextBox")
print(Input.Value)
```

## Dropdown
```lua
local Dropdown = Section:AddDropdown({
    Title = "Dropdown",
    Content = "This is a Dropdown",
    Multi = false,
    Options = {"Option 1", "Option 2"},
    Default = {"Option 1"},
    Callback = function(value)
        print(value)
    end
})
Dropdown:Set({"Option 1"})
Dropdown:AddOption("Option 3")
Dropdown:Clear()
Dropdown:Refresh({"Option 1", "Option 2"}, {"Option 1"})
print(Dropdown.Value)
print(Dropdown.Options)
```
