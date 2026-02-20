--[[
    yerba_example.lua
    Full demonstration of every API and element in yerba_final.lua
    Uses fake FPS cheat functions (all print() based, nothing real)
--]]

local Yerba = loadstring(game:HttpGet("..."))() -- replace with your loadstring

-- ─────────────────────────────────────────────────────────────────────────────
-- Fake game state (simulates what a real cheat script would track)
-- ─────────────────────────────────────────────────────────────────────────────
local State = {
    -- aimbot
    AimbotEnabled   = false,
    AimbotFOV       = 90,
    AimbotSmoothing = 5,
    AimbotBone      = "Head",
    AimbotTeamCheck = true,
    AimbotKey       = nil,

    -- visuals
    ESPEnabled      = false,
    ESPDistance     = 500,
    SkeletonEnabled = false,
    HealthBar       = true,
    ChamsEnabled    = false,
    ChamsColor      = Color3.fromRGB(255, 50, 50),
    TracersEnabled  = false,
    TracerFrom      = "Bottom",
    BoxType         = "2D",

    -- movement
    SpeedEnabled    = false,
    SpeedValue      = 16,
    FlyEnabled      = false,
    FlySpeed        = 50,
    NoClipEnabled   = false,
    JumpPower       = 50,

    -- misc
    InfiniteJump    = false,
    NoFallDamage    = false,
    AutoFarm        = false,
    FarmDelay       = 1,
    Notifications   = true,
    UITheme         = "dark",
    UIDpi           = 1,
}

-- Fake "apply" functions that just print what changed
local function ApplyAimbot()
    print(string.format("[Aimbot] enabled=%s  fov=%d  smooth=%d  bone=%s  teamcheck=%s",
        tostring(State.AimbotEnabled), State.AimbotFOV,
        State.AimbotSmoothing, State.AimbotBone, tostring(State.AimbotTeamCheck)))
end

local function ApplyESP()
    print(string.format("[ESP] enabled=%s  dist=%d  skeleton=%s  health=%s  chams=%s  tracers=%s  box=%s",
        tostring(State.ESPEnabled), State.ESPDistance,
        tostring(State.SkeletonEnabled), tostring(State.HealthBar),
        tostring(State.ChamsEnabled), tostring(State.TracersEnabled), State.BoxType))
end

local function ApplyMovement()
    print(string.format("[Movement] speed=%s(%d)  fly=%s(%d)  noclip=%s  jump=%d  infinitejump=%s  nofall=%s",
        tostring(State.SpeedEnabled), State.SpeedValue,
        tostring(State.FlyEnabled), State.FlySpeed,
        tostring(State.NoClipEnabled), State.JumpPower,
        tostring(State.InfiniteJump), tostring(State.NoFallDamage)))
end

local function ApplyFarm()
    print(string.format("[Farm] autofarm=%s  delay=%.1fs", tostring(State.AutoFarm), State.FarmDelay))
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Create window
-- ─────────────────────────────────────────────────────────────────────────────
local Window = Yerba:CreateWindow("apex.gg", "best fps cheat")

-- ─────────────────────────────────────────────────────────────────────────────
-- Watermark (top-left, draggable, shows fps)
-- ─────────────────────────────────────────────────────────────────────────────
local Watermark = Window:CreateWatermark({
    Title    = "apex.gg",
    Subtitle = "v2.0",
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Keybinds display (top-right overlay)
-- ─────────────────────────────────────────────────────────────────────────────
local KBDisplay = Window:CreateKeybindsDisplay()

-- we'll add to this as we create keybinds below
local kbAimbot = KBDisplay:AddKeybind("Aimbot",       "-",   "hold")
local kbESP    = KBDisplay:AddKeybind("ESP",          "-",   "tog")
local kbFly    = KBDisplay:AddKeybind("Fly",          "-",   "tog")

-- ─────────────────────────────────────────────────────────────────────────────
-- Player list (attached to right side of window, linked to a tab later)
-- ─────────────────────────────────────────────────────────────────────────────
local PList = Window:CreatePlayerList({
    Side       = "right",
    Gap        = 10,
    OnSpectate = function(player)
        print("[PlayerList] spectating: " .. player.Name)
        Window:Notify({ Title = "Spectating", Content = player.Name, Type = "info", Duration = 2 })
    end,
    OnTeleport = function(player)
        print("[PlayerList] teleporting to: " .. player.Name)
        Window:Notify({ Title = "Teleporting", Content = "→ " .. player.Name, Type = "warning", Duration = 2 })
    end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- TAB: Aimbot
-- ─────────────────────────────────────────────────────────────────────────────
local TabAimbot = Window:CreateTab("Aimbot")
PList:SetTab(TabAimbot)  -- player list shows only on this tab

-- Section: Main ──────────────────────────────────────────────────────────────
local SecAimbotMain = TabAimbot:CreateSection("Main", nil, "left")

local TogAimbot = SecAimbotMain:CreateToggle({
    Name     = "Enable Aimbot",
    Default  = false,
    Callback = function(v)
        State.AimbotEnabled = v
        ApplyAimbot()
        -- update watermark subtitle to reflect state
        Watermark:SetTitle(v and "apex.gg [ON]" or "apex.gg")
        if v then
            Window:Notify({ Title = "Aimbot", Content = "Enabled", Type = "success", Duration = 2 })
        end
    end,
})

-- Attach a keybind (left-click = bind key, right-click = mode menu)
local KeyAimbot = TogAimbot:CreateKeybind({
    Default  = nil,
    Mode     = "hold",
    Callback = function(key)
        print("[Aimbot] keybind changed to: " .. (key and key.Name or "none"))
        kbAimbot:Update(key and key.Name:sub(1,3):upper() or "-", "hold")
    end,
    OnPress  = function(key, active)
        print("[Aimbot] key pressed, active=" .. tostring(active))
    end,
})

-- Attach a side menu for extra aimbot settings
local SideAimbot = TogAimbot:CreateSideMenu("Aimbot Settings")

SideAimbot:CreateToggle({
    Name     = "Team Check",
    Default  = State.AimbotTeamCheck,
    Callback = function(v) State.AimbotTeamCheck = v; ApplyAimbot() end,
})

SideAimbot:CreateSlider({
    Name     = "Prediction",
    Min      = 0,
    Max      = 10,
    Default  = 3,
    Increment = 0.5,
    Suffix   = "x",
    Callback = function(v)
        print("[Aimbot] prediction: " .. v .. "x")
    end,
})

SideAimbot:CreateDropdown({
    Name     = "Priority",
    Items    = { "Distance", "Health", "Crosshair" },
    Default  = "Distance",
    Callback = function(v)
        print("[Aimbot] priority: " .. v)
    end,
})

-- FOV slider
local SliderAimbotFOV = SecAimbotMain:CreateSlider({
    Name      = "FOV",
    Min       = 10,
    Max       = 360,
    Default   = State.AimbotFOV,
    Increment = 5,
    Suffix    = "°",
    Callback  = function(v)
        State.AimbotFOV = v
        ApplyAimbot()
    end,
})

-- Smoothing stepper (discrete steps feel better here than a slider)
local StepSmoothing = SecAimbotMain:CreateStepper({
    Name      = "Smoothing",
    Min       = 1,
    Max       = 20,
    Increment = 1,
    Default   = State.AimbotSmoothing,
    Callback  = function(v)
        State.AimbotSmoothing = v
        ApplyAimbot()
    end,
})

-- Bone dropdown
local DropBone = SecAimbotMain:CreateDropdown({
    Name     = "Target Bone",
    Items    = { "Head", "Neck", "UpperTorso", "LowerTorso", "RightArm", "LeftArm" },
    Default  = State.AimbotBone,
    Callback = function(v)
        State.AimbotBone = v
        ApplyAimbot()
    end,
})

-- Divider between general and advanced
SecAimbotMain:CreateDivider({ Label = "advanced" })

local TogAimbotVis = SecAimbotMain:CreateToggle({
    Name     = "Visible Only",
    Default  = true,
    Callback = function(v) print("[Aimbot] visible only: " .. tostring(v)) end,
})

local TogAimbotAutoShoot = SecAimbotMain:CreateToggle({
    Name     = "Auto Shoot",
    Default  = false,
    Callback = function(v)
        print("[Aimbot] auto shoot: " .. tostring(v))
        -- disable smoothing when auto shoot is on (example of SetEnabled)
        StepSmoothing:SetEnabled(not v)
        if v then
            Window:Notify({ Title = "Auto Shoot", Content = "Smoothing disabled", Type = "warning", Duration = 3 })
        else
            StepSmoothing:SetEnabled(true)
        end
    end,
})

-- Section: Hitbox ────────────────────────────────────────────────────────────
local SecHitbox = TabAimbot:CreateSection("Hitbox", nil, "right")

SecHitbox:CreateToggle({
    Name     = "Expand Hitbox",
    Default  = false,
    Callback = function(v) print("[Hitbox] expand: " .. tostring(v)) end,
})

SecHitbox:CreateSlider({
    Name      = "Hitbox Size",
    Min       = 1,
    Max       = 20,
    Default   = 3,
    Increment = 0.5,
    Suffix    = "st",
    Callback  = function(v) print("[Hitbox] size: " .. v) end,
})

SecHitbox:CreateDivider()

SecHitbox:CreateToggle({
    Name     = "Head Only",
    Default  = false,
    Callback = function(v) print("[Hitbox] head only: " .. tostring(v)) end,
})

SecHitbox:CreateLabel("Hitbox size applies to all bones", "main")

-- ─────────────────────────────────────────────────────────────────────────────
-- TAB: Visuals
-- ─────────────────────────────────────────────────────────────────────────────
local TabVisuals = Window:CreateTab("Visuals")

-- Section: ESP (with subtabs) ────────────────────────────────────────────────
local SecESP = TabVisuals:CreateSection("ESP", { "Players", "Items" }, "left")

-- Players subtab
local TogESP = SecESP:CreateToggle({
    Name     = "Enable ESP",
    Default  = false,
    Subtab   = "Players",
    Callback = function(v)
        State.ESPEnabled = v
        ApplyESP()
        kbESP:Update("-", v and "tog" or "tog")
    end,
})

KeyAimbotESP = TogESP:CreateKeybind({
    Default  = nil,
    Mode     = "toggle",
    Callback = function(key)
        kbESP:Update(key and key.Name:sub(1,3):upper() or "-", "tog")
    end,
})

SecESP:CreateSlider({
    Name      = "Max Distance",
    Min       = 50,
    Max       = 2000,
    Default   = State.ESPDistance,
    Increment = 50,
    Suffix    = "st",
    Subtab    = "Players",
    Callback  = function(v) State.ESPDistance = v; ApplyESP() end,
})

SecESP:CreateToggle({
    Name     = "Skeleton",
    Default  = false,
    Subtab   = "Players",
    Callback = function(v) State.SkeletonEnabled = v; ApplyESP() end,
})

SecESP:CreateToggle({
    Name     = "Health Bar",
    Default  = true,
    Subtab   = "Players",
    Callback = function(v) State.HealthBar = v; ApplyESP() end,
})

SecESP:CreateToggle({
    Name     = "Tracers",
    Default  = false,
    Subtab   = "Players",
    Callback = function(v) State.TracersEnabled = v; ApplyESP() end,
})

SecESP:CreateDropdown({
    Name     = "Tracer From",
    Items    = { "Bottom", "Top", "Center", "Mouse" },
    Default  = State.TracerFrom,
    Subtab   = "Players",
    Callback = function(v) State.TracerFrom = v; ApplyESP() end,
})

SecESP:CreateDropdown({
    Name     = "Box Type",
    Items    = { "2D", "3D", "Corner", "None" },
    Default  = State.BoxType,
    Subtab   = "Players",
    Callback = function(v) State.BoxType = v; ApplyESP() end,
})

-- Items subtab
SecESP:CreateToggle({
    Name     = "Item ESP",
    Default  = false,
    Subtab   = "Items",
    Callback = function(v) print("[ESP] item esp: " .. tostring(v)) end,
})

SecESP:CreateMultiDropdown({
    Name     = "Show Items",
    Items    = { "Weapons", "Ammo", "Medkits", "Shields", "Backpacks" },
    Default  = { "Weapons", "Medkits" },
    Subtab   = "Items",
    Callback = function(v) print("[ESP] showing items: " .. table.concat(v, ", ")) end,
})

SecESP:CreateSlider({
    Name      = "Item Distance",
    Min       = 10,
    Max       = 500,
    Default   = 200,
    Increment = 10,
    Suffix    = "st",
    Subtab    = "Items",
    Callback  = function(v) print("[ESP] item dist: " .. v) end,
})

-- Section: Chams ─────────────────────────────────────────────────────────────
local SecChams = TabVisuals:CreateSection("Chams", nil, "right")

local TogChams = SecChams:CreateToggle({
    Name     = "Enable Chams",
    Default  = false,
    Callback = function(v)
        State.ChamsEnabled = v
        ApplyESP()
    end,
})

local ColChams = SecChams:CreateColorPicker({
    Name     = "Chams Color",
    Default  = State.ChamsColor,
    Callback = function(c)
        State.ChamsColor = c
        print(string.format("[Chams] color: %.0f, %.0f, %.0f",
            c.R * 255, c.G * 255, c.B * 255))
    end,
})

SecChams:CreateDropdown({
    Name     = "Chams Material",
    Items    = { "Default", "Neon", "Glass", "ForceField" },
    Default  = "Neon",
    Callback = function(v) print("[Chams] material: " .. v) end,
})

SecChams:CreateDivider({ Label = "team" })

SecChams:CreateToggle({
    Name     = "Team Chams",
    Default  = false,
    Callback = function(v) print("[Chams] team chams: " .. tostring(v)) end,
})

SecChams:CreateColorPicker({
    Name     = "Team Color",
    Default  = Color3.fromRGB(50, 150, 255),
    Callback = function(c)
        print(string.format("[Chams] team color: %.0f, %.0f, %.0f",
            c.R * 255, c.G * 255, c.B * 255))
    end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- TAB: Movement
-- ─────────────────────────────────────────────────────────────────────────────
local TabMovement = Window:CreateTab("Movement")

-- Section: Speed ──────────────────────────────────────────────────────────────
local SecSpeed = TabMovement:CreateSection("Speed", nil, "left")

-- Progress bar showing current walkspeed vs max (read-only, updated by slider)
local BarSpeed = SecSpeed:CreateProgressBar({
    Name    = "Current Speed",
    Min     = 0,
    Max     = 100,
    Default = State.SpeedValue,
    Suffix  = " st/s",
    Color   = Color3.fromRGB(67, 144, 186),
})

local TogSpeed = SecSpeed:CreateToggle({
    Name     = "Speed Hack",
    Default  = false,
    Callback = function(v)
        State.SpeedEnabled = v
        ApplyMovement()
    end,
})

local SliderSpeed = SecSpeed:CreateSlider({
    Name      = "Walk Speed",
    Min       = 1,
    Max       = 100,
    Default   = State.SpeedValue,
    Increment = 1,
    Suffix    = " st/s",
    Callback  = function(v)
        State.SpeedValue = v
        BarSpeed:Set(v)   -- live-update the progress bar
        ApplyMovement()
    end,
})

SecSpeed:CreateDivider()

SecSpeed:CreateToggle({
    Name     = "Bunny Hop",
    Default  = false,
    Callback = function(v) print("[Movement] bhop: " .. tostring(v)) end,
})

-- Section: Fly & NoClip ───────────────────────────────────────────────────────
local SecFly = TabMovement:CreateSection("Fly & Misc", nil, "right")

local TogFly = SecFly:CreateToggle({
    Name     = "Fly",
    Default  = false,
    Callback = function(v)
        State.FlyEnabled = v
        ApplyMovement()
    end,
})

TogFly:CreateKeybind({
    Default  = nil,
    Mode     = "toggle",
    Callback = function(key)
        kbFly:Update(key and key.Name:sub(1,3):upper() or "-", "tog")
        print("[Fly] keybind: " .. (key and key.Name or "none"))
    end,
})

SecFly:CreateSlider({
    Name      = "Fly Speed",
    Min       = 10,
    Max       = 300,
    Default   = State.FlySpeed,
    Increment = 5,
    Suffix    = " st/s",
    Callback  = function(v) State.FlySpeed = v; ApplyMovement() end,
})

SecFly:CreateDivider({ Label = "other" })

SecFly:CreateToggle({
    Name     = "No Clip",
    Default  = false,
    Callback = function(v) State.NoClipEnabled = v; ApplyMovement() end,
})

-- Jump power stepper (feels more natural with discrete jumps)
local StepJump = SecFly:CreateStepper({
    Name      = "Jump Power",
    Options   = { 25, 50, 75, 100, 150, 200 },
    Default   = 50,
    Callback  = function(v)
        State.JumpPower = v
        ApplyMovement()
    end,
})

SecFly:CreateToggle({
    Name     = "Infinite Jump",
    Default  = false,
    Callback = function(v) State.InfiniteJump = v; ApplyMovement() end,
})

SecFly:CreateToggle({
    Name     = "No Fall Damage",
    Default  = false,
    Callback = function(v) State.NoFallDamage = v; ApplyMovement() end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- TAB: Farm
-- ─────────────────────────────────────────────────────────────────────────────
local TabFarm = Window:CreateTab("Farm")

local SecFarm = TabFarm:CreateSection("Auto Farm", nil, "left")

SecFarm:CreateParagraph({
    Title   = "Auto Farm",
    Content = "Automatically farms in-game resources. Works best when fly is enabled. Stops if you are detected.",
})

SecFarm:CreateDivider()

local TogFarm = SecFarm:CreateToggle({
    Name     = "Enable Auto Farm",
    Default  = false,
    Callback = function(v)
        State.AutoFarm = v
        ApplyFarm()
        if v then
            Window:Notify({ Title = "Auto Farm", Content = "Started farming", Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Auto Farm", Content = "Stopped", Type = "info", Duration = 2 })
        end
    end,
})

SecFarm:CreateSlider({
    Name      = "Delay",
    Min       = 0.1,
    Max       = 5,
    Default   = State.FarmDelay,
    Increment = 0.1,
    Suffix    = "s",
    Callback  = function(v) State.FarmDelay = v; ApplyFarm() end,
})

SecFarm:CreateDropdown({
    Name     = "Farm Target",
    Items    = { "All", "Enemies Only", "NPCs Only", "Resources" },
    Default  = "All",
    Callback = function(v) print("[Farm] target: " .. v) end,
})

SecFarm:CreateButton({
    Name     = "Teleport to Farm Zone",
    Callback = function()
        print("[Farm] teleporting to farm zone...")
        Window:Notify({ Title = "Farm Zone", Content = "Teleporting...", Type = "info", Duration = 2 })
    end,
})

-- Farm status progress bar (simulates fill over time when enabled)
local BarFarm = SecFarm:CreateProgressBar({
    Name    = "Farm Progress",
    Min     = 0,
    Max     = 100,
    Default = 0,
    Suffix  = "%",
    Color   = Color3.fromRGB(55, 180, 90),
})

-- Simulate progress ticking when farm is on
task.spawn(function()
    local progress = 0
    while true do
        task.wait(0.5)
        if State.AutoFarm then
            progress = (progress + math.random(1, 5)) % 101
            BarFarm:Set(progress)
            if progress == 0 then
                Window:Notify({ Title = "Farm Cycle", Content = "Cycle complete!", Type = "success", Duration = 2 })
            end
        end
    end
end)

-- Section: Textbox example ────────────────────────────────────────────────────
local SecFarmConfig = TabFarm:CreateSection("Config", nil, "right")

SecFarmConfig:CreateTextbox({
    Name        = "Farm Tag",
    Default     = "myconfig",
    Placeholder = "config name",
    Callback    = function(text, enter)
        print("[Config] tag set to: " .. text .. (enter and " (enter)" or ""))
    end,
})

SecFarmConfig:CreateButton({
    Name     = "Save Config",
    Callback = function()
        print("[Config] saving state to file... (simulated)")
        Window:Notify({ Title = "Config Saved", Content = "Settings stored", Type = "success", Duration = 2 })
    end,
})

SecFarmConfig:CreateButton({
    Name     = "Load Config",
    Callback = function()
        print("[Config] loading config... (simulated)")
        Window:Notify({ Title = "Config Loaded", Content = "Settings applied", Type = "info", Duration = 2 })
    end,
})

SecFarmConfig:CreateDivider({ Label = "danger" })

SecFarmConfig:CreateButton({
    Name     = "Reset All",
    Callback = function()
        TogAimbot:Set(false)
        TogESP:Set(false)
        TogChams:Set(false)
        TogFly:Set(false)
        TogSpeed:Set(false)
        TogFarm:Set(false)
        SliderSpeed:Set(16)
        SliderAimbotFOV:Set(90)
        StepSmoothing:Set(5)
        BarFarm:Set(0)
        print("[Config] all values reset")
        Window:Notify({ Title = "Reset", Content = "All settings cleared", Type = "warning", Duration = 3 })
    end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- TAB: Settings (UI settings, DPI, theme, keybinds, etc.)
-- ─────────────────────────────────────────────────────────────────────────────
local TabSettings = Window:CreateTab("Settings")

-- Section: Interface ──────────────────────────────────────────────────────────
local SecUI = TabSettings:CreateSection("Interface", nil, "left")

SecUI:CreateParagraph({
    Title   = "UI Scale",
    Content = "Adjust the DPI slider to change the size of the interface. Works live on mobile and desktop.",
})

-- DPI slider — drives Yerba:SetDPI live
local SliderDPI = SecUI:CreateSlider({
    Name      = "UI Scale (DPI)",
    Min       = 50,
    Max       = 200,
    Default   = 100,  -- 100% = 1.0
    Increment = 5,
    Suffix    = "%",
    Callback  = function(v)
        local scale = v / 100
        State.UIDpi = scale
        Yerba:SetDPI(scale)  -- applies immediately to all windows, no hide/show needed
        print(string.format("[UI] DPI set to %.2f (%.0f%%)", scale, v))
    end,
})

-- Per-window DPI read back
SecUI:CreateButton({
    Name     = "Print Current DPI",
    Callback = function()
        local g = Yerba:GetDPI()
        local w = Window:GetDPI()
        print(string.format("[UI] Global DPI=%.2f  Window DPI=%.2f", g, w))
        Window:Notify({
            Title   = "DPI Info",
            Content = string.format("Global: %.2f  Window: %.2f", g, w),
            Type    = "info",
            Duration = 3,
        })
    end,
})

SecUI:CreateDivider({ Label = "theme" })

-- Theme stepper — cycles through built-in presets
local themes = { "dark", "green", "blue", "red", "purple" }
local themeStep = SecUI:CreateStepper({
    Name     = "Theme",
    Options  = themes,
    Default  = "dark",
    Callback = function(v)
        State.UITheme = v
        Yerba:SetTheme(v)
        print("[UI] theme: " .. v)
        Window:Notify({ Title = "Theme", Content = v, Type = "info", Duration = 2 })
    end,
})

-- Custom accent color picker — feeds into SetTheme custom override
SecUI:CreateColorPicker({
    Name     = "Custom Accent",
    Default  = Color3.fromRGB(82, 106, 117),
    Callback = function(c)
        Yerba:SetTheme({
            Accent    = c,
            AccentMid = c,
            Blue      = c,
            Enabled   = c,
        })
        print(string.format("[UI] custom accent: %.0f, %.0f, %.0f", c.R*255, c.G*255, c.B*255))
    end,
})

-- Section: Window ─────────────────────────────────────────────────────────────
local SecWindow = TabSettings:CreateSection("Window", nil, "right")

-- Minimize / Maximize buttons
SecWindow:CreateButton({
    Name     = "Minimize Window",
    Callback = function()
        Window:Minimize()
        print("[Window] minimized: " .. tostring(Window:IsMinimized()))
    end,
})

SecWindow:CreateButton({
    Name     = "Maximize Window",
    Callback = function()
        Window:Maximize()
        print("[Window] minimized: " .. tostring(Window:IsMinimized()))
    end,
})

SecWindow:CreateDivider()

-- Watermark toggle
SecWindow:CreateToggle({
    Name     = "Show Watermark",
    Default  = true,
    Callback = function(v) Watermark:Toggle(v) end,
})

-- Watermark text edit
SecWindow:CreateTextbox({
    Name        = "Watermark Title",
    Default     = "apex.gg",
    Placeholder = "title...",
    Callback    = function(text)
        if text ~= "" then Watermark:SetTitle(text) end
    end,
})

SecWindow:CreateTextbox({
    Name        = "Watermark Subtitle",
    Default     = "v2.0",
    Placeholder = "subtitle...",
    Callback    = function(text)
        if text ~= "" then Watermark:SetSubtitle(text) end
    end,
})

-- Keybinds display toggle
SecWindow:CreateToggle({
    Name     = "Show Keybinds",
    Default  = true,
    Callback = function(v) KBDisplay:Toggle(v) end,
})

SecWindow:CreateDivider({ Label = "notifications" })

SecWindow:CreateToggle({
    Name     = "Enable Notifications",
    Default  = true,
    Callback = function(v)
        State.Notifications = v
        print("[UI] notifications: " .. tostring(v))
    end,
})

-- Test notification buttons (one for each type)
SecWindow:CreateButton({
    Name     = "Test: Info",
    Callback = function()
        Window:Notify({ Title = "Info", Content = "This is an info notification", Type = "info", Duration = 3 })
    end,
})

SecWindow:CreateButton({
    Name     = "Test: Success",
    Callback = function()
        Window:Notify({ Title = "Success!", Content = "Operation completed", Type = "success", Duration = 3 })
    end,
})

SecWindow:CreateButton({
    Name     = "Test: Warning",
    Callback = function()
        Window:Notify({ Title = "Warning", Content = "Possible detection", Type = "warning", Duration = 3 })
    end,
})

SecWindow:CreateButton({
    Name     = "Test: Error",
    Callback = function()
        local n = Window:Notify({ Title = "Error", Content = "Something went wrong (tap to dismiss)", Type = "error", Duration = 0 })
        -- auto-dismiss after 5s anyway as a fallback
        task.delay(5, function() n:Dismiss() end)
    end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Section: Keybinds ───────────────────────────────────────────────────────────
local SecKeybinds = TabSettings:CreateSection("Keybinds", nil, "left")

-- Standalone keybind for toggling the entire UI (RightShift is default on desktop)
SecKeybinds:CreateKeybind({
    Name     = "Toggle UI",
    Default  = Enum.KeyCode.RightShift,
    Callback = function(key)
        print("[Keybind] toggle UI key: " .. (key and key.Name or "none"))
    end,
})

SecKeybinds:CreateKeybind({
    Name     = "Toggle Aimbot",
    Default  = nil,
    Callback = function(key)
        if key then
            TogAimbot:Set(not TogAimbot:Get())
        end
    end,
})

SecKeybinds:CreateKeybind({
    Name     = "Toggle ESP",
    Default  = nil,
    Callback = function(key)
        if key then
            TogESP:Set(not TogESP:Get())
        end
    end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Performance mode toggle in settings
-- ─────────────────────────────────────────────────────────────────────────────
local SecPerf = TabSettings:CreateSection("Performance", nil, "right")

SecPerf:CreateParagraph({
    Title   = "Performance Mode",
    Content = "Disables dot patterns and background effects. Useful on low-end devices or when you want cleaner UI.",
})

SecPerf:CreateToggle({
    Name     = "Performance Mode",
    Default  = Yerba.PerformanceMode,
    Callback = function(v)
        Yerba.PerformanceMode = v
        print("[Perf] performance mode: " .. tostring(v))
        Window:Notify({
            Title   = "Performance Mode",
            Content = v and "Enabled — reload UI to apply" or "Disabled",
            Type    = v and "warning" or "info",
            Duration = 3
        })
    end,
})

-- SetVisible example — hide the paragraph when perf mode is on
local PerfLabel = SecPerf:CreateLabel("Dot patterns consume the most GPU on this UI.")

SecPerf:CreateToggle({
    Name     = "Hide Tip",
    Default  = false,
    Callback = function(v)
        PerfLabel:SetVisible(not v)
    end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Final startup notification
-- ─────────────────────────────────────────────────────────────────────────────
task.delay(0.5, function()
    Window:Notify({
        Title    = "apex.gg loaded",
        Content  = "Press RShift to toggle UI",
        Type     = "success",
        Duration = 4,
    })
end)

print("[apex.gg] UI loaded — version " .. Yerba.Version)
