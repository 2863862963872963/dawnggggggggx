-- ============================================================
--   NovaUI v2.0 — Example Script
--   Paste this into a LocalScript inside StarterPlayerScripts
-- ============================================================

local Nova = loadstring(game:HttpGet("https://raw.githubusercontent.com/2863862963872963/Nova-Library/main/Nova.lua"))()

-- ─────────────────────────────────────────────────────────
--   CREATE WINDOW
-- ─────────────────────────────────────────────────────────
local win = Nova.new("⚡ NovaScript", {
    dpi       = Nova.AutoDPI(),
    draggable = true,
    hideKey   = Enum.KeyCode.RightControl,
})

-- ─────────────────────────────────────────────────────────
--   TAB 1 — COMBAT
-- ─────────────────────────────────────────────────────────
local combatTab = win:AddTab("⚔️ Combat")

-- ── ESP Module ────────────────────────────────────────────
local espModule = combatTab:AddModule("Player ESP", "See players through walls")

local espToggle = espModule:AddToggle("Enable ESP", false)
local espRange  = espModule:AddSlider("Range", 50, 2000, 500, " studs")
local espColor  = espModule:AddColorPicker("Color", Color3.fromRGB(79, 142, 247))
local espNames  = espModule:AddToggle("Show Names", true)
local espDist   = espModule:AddToggle("Show Distance", false)

espToggle:OnChanged(function(v)
    print("[ESP] Enabled:", v)
end)

espRange:OnChanged(function(v)
    print("[ESP] Range:", v)
end)

espColor:OnChanged(function(v)
    print("[ESP] Color:", v)
end)

espNames:OnChanged(function(v)
    print("[ESP] Show Names:", v)
end)

espDist:OnChanged(function(v)
    print("[ESP] Show Distance:", v)
end)

-- ── Aimbot Module ─────────────────────────────────────────
local aimModule = combatTab:AddModule("Aimbot", "Auto-aim assistance")

local aimToggle  = aimModule:AddToggle("Enable Aimbot", false)
local aimSmooth  = aimModule:AddSlider("Smoothing", 1, 100, 50, "%")
local aimFOV     = aimModule:AddSlider("FOV Size", 10, 360, 90, "°")
local aimTarget  = aimModule:AddDropdown("Target Part", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head")
local aimKey     = aimModule:AddKeybind("Hold Key", Enum.KeyCode.Q)
local aimPredict = aimModule:AddToggle("Prediction", false)

aimToggle:OnChanged(function(v)
    print("[Aimbot] Enabled:", v)
end)

aimSmooth:OnChanged(function(v)
    print("[Aimbot] Smoothing:", v)
end)

aimFOV:OnChanged(function(v)
    print("[Aimbot] FOV:", v)
end)

aimTarget:OnChanged(function(v)
    print("[Aimbot] Target:", v)
end)

aimKey:OnChanged(function(v)
    print("[Aimbot] Hold Key:", v.Name)
end)

aimPredict:OnChanged(function(v)
    print("[Aimbot] Prediction:", v)
end)

-- ─────────────────────────────────────────────────────────
--   TAB 2 — MOVEMENT
-- ─────────────────────────────────────────────────────────
local moveTab = win:AddTab("🏃 Move")

-- ── Speed Module ──────────────────────────────────────────
local speedModule = moveTab:AddModule("Speed", "Modify walk speed")

local speedToggle = speedModule:AddToggle("Enable Speed", false)
local speedValue  = speedModule:AddSlider("Speed", 16, 200, 16, " ws")

speedToggle:OnChanged(function(v)
    print("[Speed] Enabled:", v)
end)

speedValue:OnChanged(function(v)
    print("[Speed] Value:", v)
end)

-- ── Jump Module ───────────────────────────────────────────
local jumpModule = moveTab:AddModule("Jump", "Modify jump height")

local jumpToggle = jumpModule:AddToggle("Infinite Jump", false)
local jumpPower  = jumpModule:AddSlider("Power", 50, 500, 50, " jp")
local jumpAuto   = jumpModule:AddToggle("Auto Jump", false)

jumpToggle:OnChanged(function(v)
    print("[Jump] Infinite Jump:", v)
end)

jumpPower:OnChanged(function(v)
    print("[Jump] Power:", v)
end)

jumpAuto:OnChanged(function(v)
    print("[Jump] Auto Jump:", v)
end)

-- ── Fly Module ────────────────────────────────────────────
local flyModule = moveTab:AddModule("Fly", "Fly around the map")

local flyToggle = flyModule:AddToggle("Enable Fly", false)
local flySpeed  = flyModule:AddSlider("Fly Speed", 10, 300, 60, " ws")

flyToggle:OnChanged(function(v)
    print("[Fly] Enabled:", v)
end)

flySpeed:OnChanged(function(v)
    print("[Fly] Speed:", v)
end)

-- ─────────────────────────────────────────────────────────
--   TAB 3 — VISUALS
-- ─────────────────────────────────────────────────────────
local visualTab = win:AddTab("👁 Visuals")

-- ── Fullbright Module ─────────────────────────────────────
local fbModule = visualTab:AddModule("Fullbright", "Remove darkness from the map")

local fbToggle = fbModule:AddToggle("Enable Fullbright", false)
local fbValue  = fbModule:AddSlider("Brightness", 0, 10, 5, "")

fbToggle:OnChanged(function(v)
    print("[Fullbright] Enabled:", v)
end)

fbValue:OnChanged(function(v)
    print("[Fullbright] Brightness:", v)
end)

-- ── FOV Module ────────────────────────────────────────────
local fovModule = visualTab:AddModule("FOV", "Change field of view")

local fovValue = fovModule:AddSlider("FOV", 70, 120, 70, "°")

fovValue:OnChanged(function(v)
    print("[FOV] Value:", v)
end)

-- ── Crosshair Module ──────────────────────────────────────
local xhModule = visualTab:AddModule("Crosshair", "Custom crosshair overlay")

local xhToggle = xhModule:AddToggle("Show Crosshair", true)
local xhColor  = xhModule:AddColorPicker("Color", Color3.fromRGB(255, 255, 255))
local xhSize   = xhModule:AddSlider("Size", 5, 40, 12, "px")

xhToggle:OnChanged(function(v)
    print("[Crosshair] Visible:", v)
end)

xhColor:OnChanged(function(v)
    print("[Crosshair] Color:", v)
end)

xhSize:OnChanged(function(v)
    print("[Crosshair] Size:", v)
end)

-- ─────────────────────────────────────────────────────────
--   TAB 4 — MISC
-- ─────────────────────────────────────────────────────────
local miscTab = win:AddTab("⚙️ Misc")

-- ── DPI Module ────────────────────────────────────────────
local dpiModule = miscTab:AddModule("Mobile / DPI", "Scale UI for your screen")

local dpiSlider = dpiModule:AddSlider("UI Scale", 5, 30, math.round(Nova.AutoDPI() * 10), "")

dpiSlider:OnChanged(function(v)
    win:SetDPI(v / 10)
    print("[DPI] Scale:", v / 10)
end)

dpiModule:AddSeparator()
dpiModule:AddLabel("Drag the title bar to reposition.")
dpiModule:AddLabel("Press RCtrl to hide/show the UI.")

-- ── Teleport Module ───────────────────────────────────────
local tpModule = miscTab:AddModule("Teleport", "Quick teleport options")

local tpSpawn  = tpModule:AddButton("🏠", "To Spawn")
local tpCursor = tpModule:AddButton("🖱️", "To Cursor")
local tpPlayer = tpModule:AddDropdown("To Player", {"Player1", "Player2", "Player3"}, "Player1")

tpSpawn:OnChanged(function()
    print("[Teleport] To Spawn clicked")
end)

tpCursor:OnChanged(function()
    print("[Teleport] To Cursor clicked")
end)

tpPlayer:OnChanged(function(v)
    print("[Teleport] To Player:", v)
end)

-- ── Anti-AFK Module ───────────────────────────────────────
local afkModule = miscTab:AddModule("Anti-AFK", "Prevent automatic kick")

local afkToggle = afkModule:AddToggle("Enable Anti-AFK", true)

afkToggle:OnChanged(function(v)
    print("[Anti-AFK] Enabled:", v)
end)

-- ── Keybinds Module ───────────────────────────────────────
local kbModule = miscTab:AddModule("Keybinds", "Configure hotkeys")

local kbHide  = kbModule:AddKeybind("Hide UI", Enum.KeyCode.RightControl)
local kbPanic = kbModule:AddKeybind("Panic Key", Enum.KeyCode.End)

kbHide:OnChanged(function(v)
    print("[Keybind] Hide UI set to:", v.Name)
end)

kbPanic:OnChanged(function(v)
    print("[Keybind] Panic Key set to:", v.Name)
end)

-- ─────────────────────────────────────────────────────────
--   STARTUP
-- ─────────────────────────────────────────────────────────
win:Notify("NovaUI Loaded!", "Check output for interaction logs.", "success", 5)
print("[NovaUI] Loaded! DPI:", Nova.AutoDPI())
