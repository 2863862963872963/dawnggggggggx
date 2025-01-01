```markdown
# XenonV3 Library Documentation

**XenonV3**

---

## **Installation**

To include the library in your script, use the following `loadstring` method:

local XenonV3 = loadstring(game:HttpGet("https://raw.githubusercontent.com/2863862963872963/Libraries/refs/heads/main/Xenonv3/Source.lua"))()


---

## **Getting Started**

### Initializing the Library
Create a library instance:
```lua
local UI = XenonV3.CreateLib()
```

This will set up the core GUI framework.

---

## **Tabs and Components**

### **Tabs**

#### Adding a Tab
```lua
local Tab = UI:Tab("TabName", "IconId")
```

- `TabName`: Name of the tab.
- `IconId`: The Roblox asset ID for the tab's icon.

---

### **Components**

#### **Button**
```lua
local Button = Tab:Button("ButtonName", function()
    print("Button Clicked!")
end, "Button Description")
```

- `ButtonName`: Text displayed on the button.
- `Callback`: Function executed when the button is clicked.
- `Description`: (Optional) Description shown when the info button is clicked.

#### **Toggle**
```lua
local Toggle = Tab:Toggle("ToggleName", false, function(state)
    print("Toggle State: ", state)
end, "Toggle Description", true)
```

- `ToggleName`: Text displayed on the toggle.
- `StartingState`: Initial state of the toggle (`true` or `false`).
- `Callback`: Function executed when the toggle state changes.
- `Description`: (Optional) Description shown when the info button is clicked.
- `RunOnStart`: (Optional) If `true`, runs the callback immediately after initialization.

#### **Slider**
```lua
local Slider = Tab:Slider("SliderName", 0, 100, 50, function(value)
    print("Slider Value: ", value)
end, false, "Slider Description")
```

- `SliderName`: Text displayed on the slider.
- `Min`: Minimum value.
- `Max`: Maximum value.
- `Start`: Initial value.
- `Callback`: Function executed when the slider value changes.
- `Precise`: (Optional) If `true`, allows decimal values.
- `Description`: (Optional) Description shown when the info button is clicked.

#### **Dropdown**
```lua
local Dropdown = Tab:Dropdown("DropdownName", {"Option1", "Option2"}, function(selected)
    print("Selected Option: ", selected)
end, "Dropdown Description")
```

- `DropdownName`: Text displayed on the dropdown.
- `List`: Table of selectable options.
- `Callback`: Function executed when an option is selected.
- `Description`: (Optional) Description shown when the info button is clicked.

#### **Label**
```lua
local Label = Tab:Label("This is a label")
```

- `Text`: Text displayed on the label.

#### **TextBox**
```lua
local TextBox = Tab:TextBox("TextBoxName", function(input)
    print("Input: ", input)
end, "TextBox Description")
```

- `TextBoxName`: Text displayed above the input box.
- `Callback`: Function executed when the input is submitted.
- `Description`: (Optional) Description shown when the info button is clicked.

#### **Keybind**
```lua
local Keybind = Tab:Keybind("KeybindName", Enum.KeyCode.E, function()
    print("Keybind Pressed!")
end, "Keybind Description", {"W", "A", "S", "D"})
```

- `KeybindName`: Text displayed for the keybind.
- `Starting_Key`: Initial key (e.g., `Enum.KeyCode.E`).
- `Callback`: Function executed when the keybind is pressed.
- `Description`: (Optional) Description shown when the info button is clicked.
- `Blacklisted_Keys`: (Optional) Table of keys to ignore.

---

## **Notifications**

Display notifications in the GUI:
```lua
XenonV3:Notification("Notification Title", "This is the info", 5, {
    { Text = "Option1", Callback = function() print("Option1 Clicked") end },
    { Text = "Option2", Callback = function() print("Option2 Clicked") end }
})
```

- `Title`: The notification title.
- `Info`: The notification message.
- `Duration`: How long the notification should appear (in seconds).
- `ButtonOptions`: (Optional) Table of buttons with text and callbacks.

---

## **Additional Features**

### Toggling UI Visibility
Customize key bindings to show/hide the UI:
```lua
UI.ToggleKey = Enum.KeyCode.RightAlt
UI.BottomMenuToggleKey = Enum.KeyCode.RightControl
```

### Ripple Effect
Add a ripple animation to any GUI object:
```lua
UI.Ripple(Object, X, Y)
```

- `Object`: The GUI object to animate.
- `X`, `Y`: The position of the ripple relative to the object.



### Library
- `CreateLib()`: Initializes the library.
- `:Tab(Name: string, Icon: string)`: Creates a new tab.
- `:Notification(Title: string, Info: string, Duration: number, ButtonOptions: table)`: Displays a notification.

### Tab Components
- `:Button(Name: string, Callback: function, Description: string)`
- `:Toggle(Name: string, StartingState: boolean, Callback: function, Description: string, RunOnStart: boolean)`
- `:Slider(Name: string, Min: number, Max: number, Start: number, Callback: function, Precise: boolean, Description: string)`
- `:Dropdown(Name: string, List: table, Callback: function, Description: string)`
- `:Label(Text: string)`
- `:TextBox(Name: string, Callback: function, Description: string)`
- `:Keybind(Name: string, Starting_Key: Enum.KeyCode, Callback: function, Description: string, Blacklisted_Keys: table)`

---

```
