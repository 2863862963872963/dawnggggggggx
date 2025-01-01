# Emperion Library Documentation

## Booting the Library
To load the library, use the following code snippet:
```lua
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/astacodes/Emperion/main/Source.lua'))()
```

## Creating a Window
To create a window, use the `CreateWindow` method:
```lua
local Window = Library:CreateWindow({
    Name = "Library Name"
})

--[[
Name = <string> - The name of the UI window.
]]
```

### Methods for Window
To scale the size of the window, use the `Scale` method:
```lua
Window:Scale(0.8)
```

To destroy the window, use the `Destroy` method:
```lua
Window:Destroy()
```

## Creating a Notification
To create a notification, use the `Notification` method:
```lua
local Notification = Window:Notification({
    Title = "Notification Title",
    Description = "This is an example notification!",
    Button = { -- To disable the button, you can set Button to false!
        Name = "Okay!",
        Callback = function()
            print("Button Clicked")
            Notification:Destroy()
        end,
    }
})

--[[
Title = <string> - The title of the notification.
Description = <string> - The description of the notification.
Button = <table> - The button details.
    Name = <string> - The name of the button.
    Callback = <function> - The function called when the button is clicked.
]]
```

### Methods for Notification
To destroy the notification, use the `Destroy` method:
```lua
Notification:Destroy()
```

## Creating a Tab
To create a tab within the window, use the `CreateTab` method:
```lua
local Tab = Window:CreateTab({
    Name = "Tab Name",
    Icon = "rbxassetid://10723407389"
})

--[[
Name = <string> - The name of the tab.
Icon = <string> - The icon of the tab.
]]
```

## Creating a Label
To create a label within a tab, use the `CreateLabel` method:
```lua
local Label = Tab:CreateLabel({
    Text = "Label Text",
    Type = "Label"
})

--[[
Text = <string> - The text of the label.
Type = <string> - The type of label ("Label", "Info", "Warning").
]]
```

### Methods for Label
To set the text of the label, use the `SetText` method:
```lua
Label:SetText("New Text")
```

To get the current text of the label, use the `GetText` method:
```lua
local Text = Label:GetText()
```

## Creating a Button
To create a button within a tab, use the `CreateButton` method:
```lua
local Button = Tab:CreateButton({
    Name = "Button Name",
    Callback = function()
        print("Button Clicked")
    end
})

--[[
Name = <string> - The name of the button.
Callback = <function> - The function called when the button is clicked.
]]
```

### Methods for Button
To set the name of the button, use the `SetName` method:
```lua
Button:SetName("New Button Name")
```

To set the callback function for the button, use the `SetCallback` method:
```lua
Button:SetCallback(function()
    print("New Callback")
end)
```

## Creating an Input
To create an input field, use the `CreateInput` method:
```lua
local Input = Tab:CreateInput({
    Name = "Input",
    Default = "Text",
    Callback = function(Value)
        print("The Value is " .. Value .. "!")
    end,
})

--[[
Name = <string> - The name of the input field.
Default = <string> - The default text in the input field.
Callback = <function> - The function called when the input value changes.
]]
```

### Methods for Input
To set the callback function for the input field, use the `SetCallback` method:
```lua
Input:SetCallback(function(Value)
    print("New Value: " .. Value)
end)
```

To set the name of the input field, use the `SetName` method:
```lua
Input:SetName("New Input Name")
```

To set the text of the input field, use the `SetText` method:
```lua
Input:SetText("New Text")
```

To get the current text of the input field, use the `GetText` method:
```lua
Input:GetText()
```

## Creating a Slider
To create a slider within a tab, use the `CreateSlider` method:
```lua
local Slider = Tab:CreateSlider({
    Name = "Slider Name",
    Min = 0,
    Max = 100,
    Default = 50,
    Round = 1,
    Callback = function(Value)
        print("Slider Value: " .. Value)
    end
})

--[[
Name = <string> - The name of the slider.
Min = <number> - The minimum value of the slider.
Max = <number> - The maximum value of the slider.
Default = <number> - The default value of the slider.
Round = <number> - The number of decimal places to round the slider value to.
Callback = <function> - The function called when the slider value changes.
]]
```

### Methods for Slider
To set the value of the slider, use the `SetValue` method:
```lua
Slider:SetValue(75)
```

To get the current value of the slider, use the `GetValue` method:
```lua
local Value = Slider:GetValue()
```

To set the name of the slider, use the `SetName` method:
```lua
Slider:SetName("New Slider Name")
```

To set the callback function for the slider, use the `SetCallback` method:
```lua
Slider:SetCallback(function(Value)
    print("New Slider Value: " .. Value)
end)
```

## Creating a Toggle
To create a toggle within a tab, use the `CreateToggle` method:
```lua
local Toggle = Tab:CreateToggle({
    Name = "Toggle Name",
    Default = false,
    Callback = function(Value)
        print("Toggle Value: " .. tostring(Value))
    end
})

--[[
Name = <string> - The name of the toggle.
Default = <bool> - The default value of the toggle.
Callback = <function> - The function called when the toggle value changes.
]]
```

### Methods for Toggle
To set the state of the toggle, use the `SetState` method:
```lua
Toggle:SetState(true)
```

To get the current state of the toggle, use the `GetState` method:
```lua
local State = Toggle:GetState()
```

To set the name of the toggle, use the `SetName` method:
```lua
Toggle:SetName("New Toggle Name")
```

To set the callback function for the toggle, use the `SetCallback` method:
```lua
Toggle:SetCallback(function(Value)
    print("New Toggle Value: " .. tostring(Value))
end)
```

## Creating a Dropdown
To create a dropdown within a tab, use the `CreateDropdown` method:
```lua
local Dropdown = Tab:CreateDropdown({
    Name = "Dropdown Name",
    Items = {"Option 1", "Option 2"},
    Default = "Option 1",
    Callback = function(Value)
        print("Dropdown Selected: " .. Value)
    end
})

--[[
Name = <string> - The name of the dropdown.
Items = <table> - The list of items in the dropdown.
Default = <string> - The default selected item in the dropdown.
Callback = <function> - The function called when a dropdown item is selected.
]]
```

### Methods for Dropdown
To add an item to the dropdown, use the `AddItem` method:
```lua
Dropdown:AddItem("Option 3")
```

To remove an item from the dropdown, use the `RemoveItem` method:
```lua
Dropdown:RemoveItem("Option 1")
```

To clear all items from the dropdown, use the `ClearItems` method:
```lua
Dropdown:ClearItems()
```

To set the name of the dropdown, use the `SetName` method:
```lua
Dropdown:SetName("New Dropdown Name")
```

To set the callback function for the dropdown, use the `SetCallback` method:
```lua
Dropdown:SetCallback(function(Value)
    print("New Dropdown Selected: " .. Value)
end)
```

## Destroying the Interface
To destroy the interface, use the `Destroy` method:
```lua
Window:Destroy()
```
