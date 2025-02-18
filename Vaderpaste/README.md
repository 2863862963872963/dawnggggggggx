<br />
<div align="center">
  <h3 align="center">Vaderpaste User Interface</h3>

  <p align="center">
    A user interface that supports roblox script executor lua. 
    <br />
    <br />
    <a href="https://raw.githubusercontent.com/i77lhm/vaderpaste/refs/heads/main/example.lua">View Demo</a>
    &middot;
    <a href="https://discord.gg/HmwRmmSNSb">Report Bug</a>
    &middot;
    <a href="https://discord.gg/HmwRmmSNSb">Request Feature</a>
  </p>

  <div align="center">
    <img src="https://github.com/i77lhm/vaderpaste/blob/main/assets/vaderpaste_preview.png?raw=true" alt="Vaderpaste Preview" />
  </div>
</div>

## Getting Started

This will go through how to use the library in your executor.

### Prerequisites

This is how you import the library through the repository.
* Example:
  ```lua
  -- EXTRA INFO: You can modify this library its open source. The code is horrendous but have fun.
  -- In order to make configs of your own make the inactivity text your own text you want
  -- I may implement theming etc in the future if i come back to this. 
  
  local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/i77lhm/vaderpaste/refs/heads/main/library.lua"))() 
  local flags = library.flags -- access flags from here.
  ```

### Elements

* Window
  ```lua
  local window = library:window({
    name = "vaderpaste", 
    size = UDim2.fromOffset(500, 650) -- x, y in size
  })
  ```

* Tab
  ```lua
  local tab = window:tab({name = "Page"})
  ```

* Section
  ```lua
  local section = tab:section({
    name = "local",
  })
  ```

* Toggle:
   ```lua
   section:toggle({
        enabled = properties.enabled or nil,
        name = "Toggle",
        flag = "ToggleFlag",
        default = false,
        callback = function(bool)
            print(bool)
            print(flags["ToggleFlag"])
        end,
    })
   ```

* Dropdown
  ```lua
  section:dropdown({
        name = "activation", 
        flag = "legit_aimassistactivation", 
        items = {"mouse 1", "mouse 2", "always"}, 
        multi = false, 
        callback = function(option)
            print(option) -- Will return a table if you set multi to true, allowing you to select multiple items
            print(flags["legit_aimassistactivation"])
        end
    })
  ```

* Slider
  ```lua
  section:slider({
        name = "drop prediction inaccuracy", 
        suffix = "%", 
        flag = "legit_bulletdropaccuracy", 
        default = 90, 
        min = 0, 
        max = 100, 
        interval = 0.5,
        callback = function(num)
            print(num)
        end
    })
  ```

* Colorpicker
  ```lua
  -- For the colorpicker to be seperate, include a name to it and parent it to the section using section:colorpicker
  -- Else you should do toggle:colorpicker({}) in order to parent it to a toggle.
  section:colorpicker({
    name = "Hello!",
    flag = "enemy_healthnumbercolor",
    color = Color3.new(1, 1, 1),
    callback = function(color, alpha)
        print(color, alpha)
        print(flags["enemy_healthnumbercolor"].Color, flags["enemy_healthnumbercolor"].Transparency)
    end
  })
  ```

* Keybinds
  ```lua
  -- Same logic with the parenting as the colorpicker, same rules apply.
  section:keybind({
    name = "UI Bind",
    flags = "Keybind Flag",
    default = Enum.KeyCode.End, -- Leave empty for no key.
    callback = function(bool)
        print(bool)
        print(flags["Keybind Flag"].Active)
    end
  })
  ```
