# 暗い. | kurai

> 暗い kurai (pronounced "koo-rye") is a sleek ui library focused on simplicity, modern design, and csgo inspired aesthetics.  
  
> friendly for both the developer and user's eyes.

## example 暗い
```lua
loadstring(
    game:HttpGetAsync 'https://raw.githubusercontent.com/focat69/kurai/refs/heads/main/example.lua'
)()
```

## installation 暗い
```lua
local lib = loadstring(
    game:HttpGetAsync `https://raw.githubusercontent.com/focat69/kurai/refs/heads/main/source?t={tostring(tick())}`
)()
```

## initialization 暗い
to create a new instance:
```lua
local kurai = lib.new({
    Name = "screenguiname",             -- (optional) name for the screengui
    GameName = "Phantom Forces",        -- displayed in the title bar
    ScriptHubName = "JewWare Premium",  -- displayed under the game name
    Tabs = {"Main", "Visuals"}          -- tab names for your interface
})

local mainTab = kurai.Tabs["Main"] -- direct access to tab
local visualsTab = kurai.Tabs["Visuals"]
```
to toggle ui, press `RCTRL`.  
 you can always change this before initialization.
```lua
kurai:SetKeybind(
    KeyCode: Enum.KeyCode
) -- default is right ctrl 暗い
```

## ui elements 暗い
> note: all methods can be chained - e.g. `mainTab:Button({ ... }):Click()` or `mainTab:Label({ ... }):SetText("New"):GetText()`

### button
creates a clickable button with ripple effect.

```lua
local button = mainTab:Button({
    Text = "Click Me",           -- button text
    Callback = function()        -- function to execute when clicked
        print("Button clicked!")
    end
}, "button_flag")  -- optional flag for accessing the button later

-- optional methods:
button:Click()  -- programmatically click the button
```

### label
creates a text label.

```lua
local label = mainTab:Label({
    Text = "Information Text",   -- label text
    Alignment = Enum.TextXAlignment.Left  -- text alignment (Left/Center/Right)
})

-- optional methods:
label:SetText("New text")        -- change the label text
local text = label:GetText()     -- get current text
```

### splitter
creates a horizontal divider line.

```lua
local splitter = mainTab:Splitter({})

-- optional methods:
splitter:SetColor(Color3.new(1, 0, 0))   -- change color
local currentColor = splitter:GetColor() -- get current color
```

### slider
creates an adjustable slider input.

```lua
local slider = mainTab:Slider({
    Text = "Volume",             -- label text
    Min = 0,                     -- minimum value
    Max = 100,                   -- maximum value
    Default = 50,                -- starting value
    Increment = 1,               -- step size
    Suffix = "%",                -- (optional) text appended to value
    Precise = false,             -- (optional) show decimal places
    Callback = function(value)   -- function called when value changes
        print("New value:", value)
    end
}, "volume_slider")  -- optional flag for accessing the value later

-- optional methods:
slider:Set(75)                    -- set slider value
local value = slider:Get()        -- get current value
```

### toggle
creates a switch toggle.

```lua
local toggle = mainTab:Toggle({
    Text = "Enable Feature",     -- label text
    Default = false,             -- starting state
    Callback = function(state)   -- function called when toggled
        print("Toggle state:", state)
    end
}, "feature_toggle")  -- optional flag for accessing the state later

-- optional methods:
toggle:Set(true)                 -- set toggle state
local state = toggle:Get()       -- get current state
```

### dropdown
creates a dropdown selection menu.

```lua
local dropdown = mainTab:Dropdown({
    Text = "Select Option",                         -- label text
    Options = {"Option 1", "Option 2", "Option 3"}, -- list of options
    Default = "Option 1",                           -- (optional) starting selection
    Callback = function(selected)                   -- function called when an option is selected
        print("Selected:", selected)
    end
}, "dropdown_flag")  -- optional flag for accessing the selection later

-- optional methods:
dropdown:Set("Option 2")         -- set selected option
local selected = dropdown:Get()  -- get current selection
dropdown:Refresh({"New1", "New2"}, false)  -- update options list (second param: keep selection if possible)
```

### keybind
creates a key binding input.

```lua
local keybind = mainTab:Keybind({
    Text = "Toggle Aimbot",      -- label text
    Default = Enum.KeyCode.E,    -- default key
    Callback = function(key)     -- function called when key is changed
        print("Key changed to:", key)
    end,
    OnPressed = function(key)    -- function called when the bound key is pressed
        print("Key was pressed!")
    end
}, "aimbot_key")  -- optional flag for accessing the key later

-- optional methods:
keybind:Set(Enum.KeyCode.F)      -- set the key
local key = keybind:Get()        -- get current key
local keyText = keybind:GetText()  -- get text representation of the key
```

### textfield
creates a text input field.

```lua
local textField = mainTab:TextField({
    Text = "Username",             -- label text
    Default = "Player1",           -- default text
    Placeholder = "Enter name...", -- placeholder text when empty
    CharLimit = 20,                -- (optional) maximum character limit
    ClearTextOnFocus = false,      -- (optional) clear text when focused
    InputType = "alphanumeric",    -- (optional) input validation type: "number", "integer", "alphanumeric"
    Callback = function(text, enterPressed)  -- function called when text changes
        print("Text changed to:", text)
        if enterPressed then
            print("Enter was pressed!")
        end
    end
}, "username_flag")  -- optional flag for accessing the text later

-- optional methods:
textField:Set("NewName")         -- set the text
local text = textField:Get()     -- get current text
textField:Clear()                -- clear the text
```

## utility 暗い

### notification
display a temporary notification.

```lua
kurai:Notify({
    Title = "Your Title",        -- title of the notification
    Message = "Your message",    -- text below title/content
    Duration = 5,                -- [optional] duration in seconds (default 5)
    Type = "success"             -- [optional] notification type: "success", "warn", "err", "info" (default)
})
```

### tween
applies a tween animation to an object.

```lua
kurai.Tween(object, properties, duration, easingStyle, easingDirection)
-- example:
kurai.Tween(frame, {Size = UDim2.new(0, 200, 0, 50)}, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
```

### rainbow effect
applies a rainbow color animation to an element.

```lua
kurai.Rainbow(element, speed)
-- example:
kurai.Rainbow(frame, 0.3)  -- speed is optional (default 0.5)
```

## theming 暗い
customize 暗い's colors by modifying the theme table before initialization:

```lua
lib.Theme = {
    Main = Color3.fromRGB(20, 20, 20),        -- main window background
    Tab = Color3.fromRGB(23, 23, 23),         -- tab button color
    TabAccent = Color3.fromRGB(30, 30, 30),   -- active tab color
    Content = Color3.fromRGB(25, 25, 25),     -- content background
    Accent = Color3.fromRGB(253, 181, 181),   -- accent color (buttons, sliders)
    Text = Color3.fromRGB(212, 212, 212),     -- primary text color
    SubText = Color3.fromRGB(89, 89, 89)      -- secondary text color
}
```

## flags system 暗い
暗い includes a simple flags system to track element states:

```lua
local current_volume = lib.Flags.volume_slider
local toggle_state   = lib.Flags.feature_toggle
local selected_option = lib.Flags.dropdown_flag
local keybind = lib.Flags.aimbot_key
local username = lib.Flags.username_flag
```

## credits 暗い
> i've spent countless hours on this and i wouldnt want my hard work to be skidded without permission  
> please respect my work and do not skid this library without my permission  
> if approved by me, remember to give credits where its due!
