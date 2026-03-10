--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║           XOVA UI LIBRARY  ·  v3  Enhanced Edition              ║
    ║                                                                  ║
    ║  Theme & Visuals                                                 ║
    ║  • Library.Theme  +  Library:SetTheme(tbl)                      ║
    ║  • Library:SetTransparency(n)                                    ║
    ║                                                                  ║
    ║  Config / Save Manager                                           ║
    ║  • Window arg  ConfigPath = "folder"  (enables config I/O)      ║
    ║  • Window arg  AutoSave   = true      (save on every change)     ║
    ║  • Window arg  AutoLoad   = true      (load "default" on start)  ║
    ║  • Library:SaveConfig(name?)                                     ║
    ║  • Library:LoadConfig(name?)                                     ║
    ║  • Library:DeleteConfig(name?)                                   ║
    ║  • Library:ListConfigs()  → { string, ... }                     ║
    ║  • ConfigKey = "key"  on Toggle / Slider / Input / Dropdown      ║
    ║                                                                  ║
    ║  Utility                                                         ║
    ║  • Library:Utility("Random",  "Color"|"Number"|"Int"|"Bool"     ║
    ║                              |"String"|"Item"|"HSV", ...)       ║
    ║  • Library:Utility("Format",  "Number"|"Time"|"Bytes", ...)     ║
    ║  • Library:Utility("Color",   "Lerp"|"Darken"|"Lighten"         ║
    ║                              |"ToHex"|"FromHex", ...)           ║
    ║  • Library:Utility("Table",   "Keys"|"Values"|"Contains"        ║
    ║                              |"Shuffle"|"Copy", ...)            ║
    ║  • Library:Utility("String",  "Trim"|"Split"|"Capitalize", ...) ║
    ║  • Library:Utility("Math",    "Clamp"|"Lerp"|"Round", ...)      ║
    ║                                                                  ║
    ║  Sections & Elements                                             ║
    ║  • Page:Section(Name, Side, Icon)  –  column containers         ║
    ║  • Page:AddSettingTab()  –  pre-built config+UI settings panel   ║
    ║  • Icon param on every element  (nil = hidden)                   ║
    ║  • RichText = true on every label                                ║
    ║  • APIs: :Set() :SetTitle() :SetDesc() :SetVisible() :SetEnabled()║
    ╚══════════════════════════════════════════════════════════════════╝
--]]

local Library = {}

-- ── Services ────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")

local Mobile      = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then true else false
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer.PlayerGui

-- ════════════════════════════════════════════════════════════════════
--  THEME  ─  edit before calling Library:Window() or use SetTheme()
-- ════════════════════════════════════════════════════════════════════
Library.Theme = {
    Accent       = Color3.fromRGB(255, 0, 127),   -- primary highlight colour
    Background   = Color3.fromRGB(11,  11,  11),  -- window background
    Surface      = Color3.fromRGB(15,  15,  15),  -- row / element background
    Border       = Color3.fromRGB(25,  25,  25),  -- stroke colour
    Text         = Color3.fromRGB(255, 255, 255), -- main text
    SubText      = Color3.fromRGB(163, 163, 163), -- dimmed text
    Transparency = 0,                              -- window background transparency (0‑1)
}

--- Merge `newTheme` fields into Library.Theme.
--- Call before (or after) Window() – live updates not yet supported.
function Library:SetTheme(newTheme)
    for k, v in pairs(newTheme) do
        Library.Theme[k] = v
    end
end

-- ════════════════════════════════════════════════════════════════════
--  CONFIG / SAVE MANAGER  (internal state)
-- ════════════════════════════════════════════════════════════════════
Library._Registry   = {}    -- { [key] = { get = fn, set = fn } }
Library._ConfigPath = nil   -- folder path set via Window({ ConfigPath = "..." })
Library._AutoSave   = false -- set via Window({ AutoSave = true })
Library._LoadTick   = os.clock()

--- Register an element value with the config system.
--- Called internally by Toggle / Slider / Input / Dropdown when ConfigKey is provided.
function Library:_RegisterElement(key, getValue, setValue)
    if not key or key == "" then return end
    Library._Registry[key] = { get = getValue, set = setValue }
end

--- Serialize and write all registered values to <ConfigPath>/<name>.json
function Library:SaveConfig(name)
    name = tostring(name or "default")
    local path = Library._ConfigPath
    if not path then
        warn("[Xova] ConfigPath not set – call Library:Window({ ConfigPath = '...' })")
        return false
    end
    pcall(function() if not isfolder(path) then makefolder(path) end end)
    local data = {}
    for k, cb in pairs(Library._Registry) do
        local ok, v = pcall(cb.get)
        if ok then data[k] = v end
    end
    local ok, err = pcall(writefile, path .. "/" .. name .. ".json",
        HttpService:JSONEncode(data))
    if not ok then warn("[Xova] SaveConfig failed: " .. tostring(err)) end
    return ok
end

--- Read <ConfigPath>/<name>.json and push values back into registered elements.
function Library:LoadConfig(name)
    name = tostring(name or "default")
    local path = Library._ConfigPath
    if not path then return false end
    local file = path .. "/" .. name .. ".json"
    local ok, exists = pcall(isfile, file)
    if not ok or not exists then return false end
    local ok2, raw = pcall(readfile, file)
    if not ok2 then return false end
    local ok3, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok3 or type(data) ~= "table" then return false end
    for k, cb in pairs(Library._Registry) do
        if data[k] ~= nil then
            pcall(cb.set, data[k])
        end
    end
    return true
end

--- Delete <ConfigPath>/<name>.json
function Library:DeleteConfig(name)
    name = tostring(name or "default")
    local path = Library._ConfigPath
    if not path then return false end
    local file = path .. "/" .. name .. ".json"
    local ok, exists = pcall(isfile, file)
    if not ok or not exists then return false end
    pcall(delfile, file)
    return true
end

--- Return a list of saved config names (without .json extension).
function Library:ListConfigs()
    local path = Library._ConfigPath
    if not path then return {} end
    local ok, files = pcall(listfiles, path)
    if not ok then return {} end
    local out = {}
    for _, f in pairs(files) do
        local n = tostring(f):match("([^/\\]+)%.json$")
        if n then table.insert(out, n) end
    end
    table.sort(out)
    return out
end

-- ════════════════════════════════════════════════════════════════════
--  UTILITY
--
--  Library:Utility(category, type, ...)
--
--  "Random"  "Color"              → random Color3
--            "HSV"                → random HSV Color3 (saturated)
--            "Number", min, max   → random float
--            "Int",    min, max   → random integer
--            "Bool"               → random boolean
--            "String", len, chars?→ random string
--            "Item",   table      → random element of table
--
--  "Format"  "Number", n, dec?   → "1,234.56"
--            "Time",   seconds   → "1h 23m 45s"
--            "Bytes",  bytes     → "1.23 MB"
--
--  "Color"   "Lerp",    c1,c2,t  → lerped Color3
--            "Darken",  c, f     → darkened Color3
--            "Lighten", c, f     → lightened Color3
--            "ToHex",   c        → "#RRGGBB"
--            "FromHex", hex      → Color3
--            "Invert",  c        → inverted Color3
--
--  "Table"   "Keys",     t       → { key, ... }
--            "Values",   t       → { val, ... }
--            "Contains", t, v    → boolean
--            "Shuffle",  t       → shuffled copy
--            "Copy",     t       → shallow copy
--
--  "String"  "Trim",       s     → trimmed
--            "Split",      s,sep → { part, ... }
--            "Capitalize", s     → "Hello World"
--            "Repeat",     s,n   → repeated n times
--
--  "Math"    "Clamp",  n,min,max → clamped
--            "Lerp",   a,b,t     → lerped
--            "Round",  n,dec?    → rounded
--            "Sign",   n         → -1 / 0 / 1
-- ════════════════════════════════════════════════════════════════════
local _UTIL_DEFAULT_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

function Library:Utility(category, utilType, ...)
    local args = { ... }

    -- ── Random ────────────────────────────────────────────────────────
    if category == "Random" then
        if utilType == "Color" then
            return Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))

        elseif utilType == "HSV" then
            return Color3.fromHSV(math.random(), 0.75 + math.random() * 0.25, 0.85 + math.random() * 0.15)

        elseif utilType == "Number" then
            local mn, mx = args[1] or 0, args[2] or 1
            return mn + math.random() * (mx - mn)

        elseif utilType == "Int" then
            local mn, mx = math.floor(args[1] or 0), math.floor(args[2] or 100)
            return math.random(mn, mx)

        elseif utilType == "Bool" then
            return math.random() >= 0.5

        elseif utilType == "String" then
            local len   = math.floor(args[1] or 8)
            local chars = args[2] or _UTIL_DEFAULT_CHARS
            local out   = {}
            for _ = 1, len do
                local i = math.random(1, #chars)
                out[#out + 1] = chars:sub(i, i)
            end
            return table.concat(out)

        elseif utilType == "Item" then
            local t = args[1]
            if type(t) ~= "table" or #t == 0 then return nil end
            return t[math.random(1, #t)]
        end

    -- ── Format ────────────────────────────────────────────────────────
    elseif category == "Format" then
        if utilType == "Number" then
            local n   = tonumber(args[1]) or 0
            local dec = args[2] or 2
            local fmt = string.format("%." .. dec .. "f", n)
            -- insert thousands separators
            local int, frac = fmt:match("^(-?%d+)(%.?.*)$")
            int = int:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
            return int .. frac

        elseif utilType == "Time" then
            local s   = math.floor(math.abs(tonumber(args[1]) or 0))
            local h   = math.floor(s / 3600)
            local m   = math.floor((s % 3600) / 60)
            local sec = s % 60
            if h > 0 then
                return string.format("%dh %dm %ds", h, m, sec)
            elseif m > 0 then
                return string.format("%dm %ds", m, sec)
            else
                return string.format("%ds", sec)
            end

        elseif utilType == "Bytes" then
            local b = tonumber(args[1]) or 0
            if b >= 1073741824 then return string.format("%.2f GB", b / 1073741824)
            elseif b >= 1048576 then return string.format("%.2f MB", b / 1048576)
            elseif b >= 1024    then return string.format("%.2f KB", b / 1024)
            else                     return string.format("%d B",    b) end
        end

    -- ── Color ─────────────────────────────────────────────────────────
    elseif category == "Color" then
        if utilType == "Lerp" then
            local c1, c2, t = args[1], args[2], args[3] or 0.5
            return c1:Lerp(c2, math.clamp(t, 0, 1))

        elseif utilType == "Darken" then
            local c, f = args[1], args[2] or 0.3
            return Color3.new(
                math.clamp(c.R * (1 - f), 0, 1),
                math.clamp(c.G * (1 - f), 0, 1),
                math.clamp(c.B * (1 - f), 0, 1)
            )

        elseif utilType == "Lighten" then
            local c, f = args[1], args[2] or 0.3
            return Color3.new(
                math.clamp(c.R + (1 - c.R) * f, 0, 1),
                math.clamp(c.G + (1 - c.G) * f, 0, 1),
                math.clamp(c.B + (1 - c.B) * f, 0, 1)
            )

        elseif utilType == "ToHex" then
            local c = args[1]
            return string.format("#%02X%02X%02X",
                math.round(c.R * 255),
                math.round(c.G * 255),
                math.round(c.B * 255)
            )

        elseif utilType == "FromHex" then
            local hex = tostring(args[1]):gsub("^#", "")
            local r = tonumber(hex:sub(1,2), 16) or 0
            local g = tonumber(hex:sub(3,4), 16) or 0
            local b = tonumber(hex:sub(5,6), 16) or 0
            return Color3.fromRGB(r, g, b)

        elseif utilType == "Invert" then
            local c = args[1]
            return Color3.new(1 - c.R, 1 - c.G, 1 - c.B)
        end

    -- ── Table ─────────────────────────────────────────────────────────
    elseif category == "Table" then
        if utilType == "Keys" then
            local out = {}
            for k in pairs(args[1] or {}) do out[#out+1] = k end
            return out

        elseif utilType == "Values" then
            local out = {}
            for _, v in pairs(args[1] or {}) do out[#out+1] = v end
            return out

        elseif utilType == "Contains" then
            local t, val = args[1] or {}, args[2]
            for _, v in pairs(t) do if v == val then return true end end
            return false

        elseif utilType == "Shuffle" then
            local t   = args[1] or {}
            local out = {}
            for i, v in ipairs(t) do out[i] = v end
            for i = #out, 2, -1 do
                local j = math.random(1, i)
                out[i], out[j] = out[j], out[i]
            end
            return out

        elseif utilType == "Copy" then
            local out = {}
            for k, v in pairs(args[1] or {}) do out[k] = v end
            return out
        end

    -- ── String ────────────────────────────────────────────────────────
    elseif category == "String" then
        if utilType == "Trim" then
            return (tostring(args[1] or "")):match("^%s*(.-)%s*$")

        elseif utilType == "Split" then
            local s, sep = tostring(args[1] or ""), tostring(args[2] or ",")
            local out    = {}
            for part in s:gmatch("([^" .. sep .. "]+)") do out[#out+1] = part end
            return out

        elseif utilType == "Capitalize" then
            return (tostring(args[1] or "")):gsub("(%a)([%w_']*)", function(a, b)
                return a:upper() .. b:lower()
            end)

        elseif utilType == "Repeat" then
            local s, n = tostring(args[1] or ""), math.floor(args[2] or 1)
            local out  = {}
            for _ = 1, n do out[#out+1] = s end
            return table.concat(out)
        end

    -- ── Math ──────────────────────────────────────────────────────────
    elseif category == "Math" then
        if utilType == "Clamp" then
            return math.clamp(args[1] or 0, args[2] or 0, args[3] or 1)

        elseif utilType == "Lerp" then
            local a, b, t = args[1] or 0, args[2] or 1, args[3] or 0.5
            return a + (b - a) * math.clamp(t, 0, 1)

        elseif utilType == "Round" then
            local n, dec = args[1] or 0, args[2] or 0
            local f = 10 ^ dec
            return math.floor(n * f + 0.5) / f

        elseif utilType == "Sign" then
            local n = args[1] or 0
            return n > 0 and 1 or n < 0 and -1 or 0
        end
    end

    warn("[Xova] Library:Utility – unknown category/type: " .. tostring(category) .. " / " .. tostring(utilType))
    return nil
end

-- ════════════════════════════════════════════════════════════════════
--  CORE HELPERS
-- ════════════════════════════════════════════════════════════════════
function Library:Parent()
    if not RunService:IsStudio() then
        return (gethui and gethui()) or CoreGui
    end
    return PlayerGui
end

function Library:Create(Class, Props)
    local inst = Instance.new(Class)
    for k, v in Props do inst[k] = v end
    return inst
end

-- Greyscale gradient (title decoration)
local function Gradient(parent, rot)
    Library:Create("UIGradient", {
        Parent   = parent,
        Rotation = rot or 90,
        Color    = ColorSequence.new{
            ColorSequenceKeypoint.new(0,        Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.749568, Color3.fromRGB(163, 163, 163)),
            ColorSequenceKeypoint.new(1,        Color3.fromRGB(100, 100, 100)),
        },
    })
end

-- Light→dark gradient (buttons / accent bars)
local function AccentGrad(parent)
    Library:Create("UIGradient", {
        Parent   = parent,
        Rotation = 90,
        Color    = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(56,  56,  56 )),
        },
    })
end

function Library:Tween(info)
    return TweenService:Create(
        info.v,
        TweenInfo.new(info.t, Enum.EasingStyle[info.s], Enum.EasingDirection[info.d]),
        info.g
    )
end

function Library:Draggable(a)
    local Dragging, DragInput, DragStart, StartPos
    a.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            Dragging  = true
            DragStart = i.Position
            StartPos  = a.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    a.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch then
            DragInput = i
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i == DragInput and Dragging then
            local d   = i.Position - DragStart
            local pos = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + d.X,
                                  StartPos.Y.Scale, StartPos.Y.Offset + d.Y)
            TweenService:Create(a, TweenInfo.new(0.3), { Position = pos }):Play()
        end
    end)
end

--- Invisible full-size click capture
function Library:Button(Parent): TextButton
    return Library:Create("TextButton", {
        Name                   = "Click",
        Parent                 = Parent,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
        Font                   = Enum.Font.SourceSans,
        Text                   = "",
        TextColor3             = Color3.fromRGB(0, 0, 0),
        TextSize               = 14,
        ZIndex                 = Parent.ZIndex + 3,
    })
end

--- Ripple effect on click
function Library.Effect(c, p)
    p.ClipsDescendants = true
    local M  = LocalPlayer:GetMouse()
    local rx = M.X - c.AbsolutePosition.X
    local ry = M.Y - c.AbsolutePosition.Y
    if rx < 0 or ry < 0 or rx > c.AbsoluteSize.X or ry > c.AbsoluteSize.Y then return end
    local circle = Library:Create("Frame", {
        Parent                 = p,
        BackgroundColor3       = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.75,
        BorderSizePixel        = 0,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Position               = UDim2.new(0, rx, 0, ry),
        Size                   = UDim2.new(0, 0, 0, 0),
        ZIndex                 = p.ZIndex,
    })
    Library:Create("UICorner", { Parent = circle, CornerRadius = UDim.new(1, 0) })
    local tw = TweenService:Create(circle, TweenInfo.new(2.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size                   = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
        BackgroundTransparency = 1,
    })
    tw.Completed:Once(function() circle:Destroy() end)
    tw:Play()
end

function Library:Asset(rbx)
    if typeof(rbx) == "number" then return "rbxassetid://" .. rbx end
    if typeof(rbx) == "string" and rbx:find("rbxassetid://") then return rbx end
    return rbx
end

-- ════════════════════════════════════════════════════════════════════
--  NewRows  ─  shared row builder
--   Icon  optional asset; when nil no icon is created
-- ════════════════════════════════════════════════════════════════════
function Library:NewRows(Parent, Title, Description, Icon)
    local T = Library.Theme

    local Rows = Library:Create("Frame", {
        Name             = "Rows",
        Parent           = Parent,
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 40),
    })
    Library:Create("UIStroke", { Parent = Rows, Color = T.Border, Thickness = 0.5 })
    Library:Create("UICorner", { Parent = Rows, CornerRadius = UDim.new(0, 3) })
    Library:Create("UIListLayout", {
        Parent            = Rows,
        Padding           = UDim.new(0, 6),
        FillDirection     = Enum.FillDirection.Horizontal,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })
    Library:Create("UIPadding", {
        Parent        = Rows,
        PaddingBottom = UDim.new(0, 6),
        PaddingTop    = UDim.new(0, 5),
    })

    -- Vectorize wrapper
    local Vectorize = Library:Create("Frame", {
        Name                   = "Vectorize",
        Parent                 = Rows,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
    })
    Library:Create("UIPadding", {
        Parent       = Vectorize,
        PaddingLeft  = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    })

    -- Right panel  (controls dock here)
    local Right = Library:Create("Frame", {
        Name                   = "Right",
        Parent                 = Vectorize,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
    })
    Library:Create("UIListLayout", {
        Parent              = Right,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
    })

    -- Left panel  (icon + title/desc)
    local Left = Library:Create("Frame", {
        Name                   = "Left",
        Parent                 = Vectorize,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
    })
    Library:Create("UIListLayout", {
        Parent            = Left,
        Padding           = UDim.new(0, 6),
        FillDirection     = Enum.FillDirection.Horizontal,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    -- Optional icon ─ only created when Icon ~= nil
    local RowIcon = nil
    if Icon ~= nil then
        RowIcon = Library:Create("ImageLabel", {
            Name                   = "RowIcon",
            Parent                 = Left,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            LayoutOrder            = -2,
            Size                   = UDim2.new(0, 15, 0, 15),
            Image                  = Library:Asset(Icon),
            ImageColor3            = T.Accent,
        })
        Gradient(RowIcon)
    end

    -- Text stack  (Title + Desc)
    local Text = Library:Create("Frame", {
        Name                   = "Text",
        Parent                 = Left,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        LayoutOrder            = -1,
        Size                   = UDim2.new(1, 0, 1, 0),
    })
    Library:Create("UIListLayout", {
        Parent              = Text,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
    })

    local TitleLbl = Library:Create("TextLabel", {
        Name                   = "Title",
        Parent                 = Text,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        LayoutOrder            = -1,
        Size                   = UDim2.new(1, 0, 0, 13),
        Font                   = Enum.Font.GothamSemibold,
        RichText               = true,
        Text                   = Title,
        TextColor3             = T.Text,
        TextSize               = 12,
        TextStrokeTransparency = 0.7,
        TextXAlignment         = Enum.TextXAlignment.Left,
    })
    Gradient(TitleLbl)

    Library:Create("TextLabel", {
        Name                   = "Desc",
        Parent                 = Text,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 0, 10),
        Font                   = Enum.Font.GothamMedium,
        RichText               = true,
        Text                   = Description,
        TextColor3             = T.Text,
        TextSize               = 10,
        TextStrokeTransparency = 0.7,
        TextTransparency       = 0.6,
        TextXAlignment         = Enum.TextXAlignment.Left,
    })

    return Rows
end

-- ════════════════════════════════════════════════════════════════════
--  WINDOW
-- ════════════════════════════════════════════════════════════════════
function Library:Window(Args)
    local Title      = Args.Title        or "Xova's Project"
    local SubTitle   = Args.SubTitle     or "Made by s1nve"
    local T          = Library.Theme
    local BgAlpha    = Args.Transparency or T.Transparency or 0

    -- ── Config wiring ────────────────────────────────────────────────
    if Args.ConfigPath then
        Library._ConfigPath = tostring(Args.ConfigPath)
        Library._AutoSave   = Args.AutoSave == true
    end
    local _doAutoLoad = (Args.AutoLoad ~= false) and (Library._ConfigPath ~= nil)

    local Xova = Library:Create("ScreenGui", {
        Name           = "Xova",
        Parent         = Library:Parent(),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true,
    })

    local Background_1 = Library:Create("Frame", {
        Name                   = "Background",
        Parent                 = Xova,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundColor3       = T.Background,
        BackgroundTransparency = BgAlpha,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(0, 500, 0, 350),
    })

    Library:Create("UICorner", { Parent = Background_1 })

    Library:Create("ImageLabel", {
        Name                   = "Shadow",
        Parent                 = Background_1,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 120, 1, 120),
        ZIndex                 = 0,
        Image                  = "rbxassetid://8992230677",
        ImageColor3            = Color3.fromRGB(0, 0, 0),
        ImageTransparency      = 0.5,
        ScaleType              = Enum.ScaleType.Slice,
        SliceCenter            = Rect.new(99, 99, 99, 99),
    })

    -- ── Window APIs ──────────────────────────────────────────────────
    function Library:IsDropdownOpen()
        for _, v in pairs(Background_1:GetChildren()) do
            if v.Name == "Dropdown" and v.Visible then return true end
        end
    end

    --- Adjust window background transparency at runtime (0 = opaque, 1 = invisible)
    function Library:SetTransparency(val)
        Background_1.BackgroundTransparency = math.clamp(val, 0, 1)
    end

    -- ── Header ───────────────────────────────────────────────────────
    local Header_1 = Library:Create("Frame", {
        Name                   = "Header",
        Parent                 = Background_1,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 0, 40),
    })

    local Return_1 = Library:Create("ImageLabel", {
        Name                   = "Return",
        Parent                 = Header_1,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 25, 0.5, 1),
        Size                   = UDim2.new(0, 27, 0, 27),
        Image                  = "rbxassetid://130391877219356",
        ImageColor3            = T.Accent,
        Visible                = false,
    })
    Gradient(Return_1)

    local HeadScale_1 = Library:Create("Frame", {
        Name                   = "HeadScale",
        Parent                 = Header_1,
        AnchorPoint            = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(1, 0, 0, 0),
        Size                   = UDim2.new(1, 0, 1, 0),
    })
    Library:Create("UIListLayout", {
        Parent            = HeadScale_1,
        FillDirection     = Enum.FillDirection.Horizontal,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })
    Library:Create("UIPadding", {
        Parent        = HeadScale_1,
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft   = UDim.new(0, 15),
        PaddingRight  = UDim.new(0, 15),
        PaddingTop    = UDim.new(0, 20),
    })

    -- Info (title + subtitle)
    local Info_1 = Library:Create("Frame", {
        Name                   = "Info",
        Parent                 = HeadScale_1,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, -100, 0, 28),
    })
    Library:Create("UIListLayout", {
        Parent              = Info_1,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
    })

    local WinTitle = Library:Create("TextLabel", {
        Name                   = "Title",
        Parent                 = Info_1,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 14),
        Font                   = Enum.Font.GothamBold,
        RichText               = true,
        Text                   = Title,
        TextColor3             = T.Accent,
        TextSize               = 14,
        TextStrokeTransparency = 0.7,
        TextXAlignment         = Enum.TextXAlignment.Left,
    })
    Gradient(WinTitle)

    Library:Create("TextLabel", {
        Name                   = "SubTitle",
        Parent                 = Info_1,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 10),
        Font                   = Enum.Font.GothamMedium,
        RichText               = true,
        Text                   = SubTitle,
        TextColor3             = T.Text,
        TextSize               = 10,
        TextStrokeTransparency = 0.7,
        TextTransparency       = 0.6,
        TextXAlignment         = Enum.TextXAlignment.Left,
    })

    -- Expires
    local Expires_1 = Library:Create("Frame", {
        Name                   = "Expires",
        Parent                 = HeadScale_1,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(0, 100, 0, 40),
    })
    Library:Create("UIListLayout", {
        Parent              = Expires_1,
        Padding             = UDim.new(0, 10),
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
    })

    local ExpiresIcon = Library:Create("ImageLabel", {
        Name                   = "Asset",
        Parent                 = Expires_1,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        LayoutOrder            = 1,
        Size                   = UDim2.new(0, 20, 0, 20),
        Image                  = "rbxassetid://100865348188048",
        ImageColor3            = T.Accent,
    })
    Gradient(ExpiresIcon)

    local Info_2 = Library:Create("Frame", {
        Name                   = "Info",
        Parent                 = Expires_1,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 28),
    })
    Library:Create("UIListLayout", {
        Parent              = Info_2,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
    })

    local ExpTitle = Library:Create("TextLabel", {
        Name                   = "Title",
        Parent                 = Info_2,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 14),
        Font                   = Enum.Font.GothamSemibold,
        RichText               = true,
        Text                   = "Expires at",
        TextColor3             = T.Accent,
        TextSize               = 13,
        TextStrokeTransparency = 0.7,
        TextXAlignment         = Enum.TextXAlignment.Right,
    })
    Gradient(ExpTitle)

    local THETIME = Library:Create("TextLabel", {
        Name                   = "Time",
        Parent                 = Info_2,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 10),
        Font                   = Enum.Font.GothamMedium,
        RichText               = true,
        Text                   = "00:00:00 Hours",
        TextColor3             = T.Text,
        TextSize               = 10,
        TextStrokeTransparency = 0.7,
        TextTransparency       = 0.6,
        TextXAlignment         = Enum.TextXAlignment.Right,
    })

    -- ── Body / Scale ─────────────────────────────────────────────────
    local Scale_1 = Library:Create("Frame", {
        Name                   = "Scale",
        Parent                 = Background_1,
        AnchorPoint            = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 0, 1, 0),
        Size                   = UDim2.new(1, 0, 1, -40),
    })

    local Home_1 = Library:Create("Frame", {
        Name                   = "Home",
        Parent                 = Scale_1,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
    })
    Library:Create("UIPadding", {
        Parent        = Home_1,
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft   = UDim.new(0, 14),
        PaddingRight  = UDim.new(0, 14),
    })

    local MainTabsScrolling = Library:Create("ScrollingFrame", {
        Name                      = "ScrollingFrame",
        Parent                    = Home_1,
        Active                    = true,
        BackgroundTransparency    = 1,
        BorderSizePixel           = 0,
        Size                      = UDim2.new(1, 0, 1, 0),
        ClipsDescendants          = true,
        AutomaticCanvasSize       = Enum.AutomaticSize.None,
        BottomImage               = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
        CanvasPosition            = Vector2.new(0, 0),
        ElasticBehavior           = Enum.ElasticBehavior.WhenScrollable,
        MidImage                  = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        ScrollBarImageColor3      = Color3.fromRGB(0, 0, 0),
        ScrollBarThickness        = 0,
        ScrollingDirection        = Enum.ScrollingDirection.XY,
        TopImage                  = "rbxasset://textures/ui/Scroll/scroll-top.png",
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
    })
    Library:Create("UIPadding", {
        Parent        = MainTabsScrolling,
        PaddingBottom = UDim.new(0, 1),
        PaddingLeft   = UDim.new(0, 1),
        PaddingRight  = UDim.new(0, 1),
        PaddingTop    = UDim.new(0, 1),
    })

    local TabsLayout = Library:Create("UIListLayout", {
        Parent        = MainTabsScrolling,
        Padding       = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Wraps         = true,
    })
    TabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        MainTabsScrolling.CanvasSize = UDim2.new(0, 0, 0, TabsLayout.AbsoluteContentSize.Y + 15)
    end)

    local PageService: UIPageLayout = Library:Create("UIPageLayout", { Parent = Scale_1 })

    -- ════════════════════════════════════════════════════════════════
    --  Window object
    -- ════════════════════════════════════════════════════════════════
    local Window = {}

    function Window:NewPage(Args)
        local PageTitle = Args.Title or "Unknown"
        local PageDesc  = Args.Desc  or "Description"
        local PageIcon  = Args.Icon  or 127194456372995

        -- Tab card on Home screen
        local NewTabs = Library:Create("Frame", {
            Name             = "NewTabs",
            Parent           = MainTabsScrolling,
            BackgroundColor3 = Color3.fromRGB(10, 10, 10),
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 230, 0, 55),
        })
        Library:Create("UICorner", { Parent = NewTabs, CornerRadius = UDim.new(0, 5) })
        Library:Create("UIStroke", { Parent = NewTabs, Color = Color3.fromRGB(75, 0, 38), Thickness = 1 })

        local TabClick = Library:Button(NewTabs)

        local Banner = Library:Create("ImageLabel", {
            Name                   = "Banner",
            Parent                 = NewTabs,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
            Image                  = "rbxassetid://125411502674016",
            ImageColor3            = T.Accent,
            ScaleType              = Enum.ScaleType.Crop,
        })
        Library:Create("UICorner", { Parent = Banner, CornerRadius = UDim.new(0, 2) })

        local TabInfo = Library:Create("Frame", {
            Name                   = "Info",
            Parent                 = NewTabs,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
        })
        Library:Create("UIListLayout", {
            Parent            = TabInfo,
            Padding           = UDim.new(0, 10),
            FillDirection     = Enum.FillDirection.Horizontal,
            SortOrder         = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })
        Library:Create("UIPadding", { Parent = TabInfo, PaddingLeft = UDim.new(0, 15) })

        local TabIconImg = Library:Create("ImageLabel", {
            Name                   = "Icon",
            Parent                 = TabInfo,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            LayoutOrder            = -1,
            Size                   = UDim2.new(0, 25, 0, 25),
            Image                  = Library:Asset(PageIcon),
            ImageColor3            = T.Accent,
        })
        Gradient(TabIconImg)

        local TabText = Library:Create("Frame", {
            Name                   = "Text",
            Parent                 = TabInfo,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Position               = UDim2.new(0.111, 0, 0.144, 0),
            Size                   = UDim2.new(0, 150, 0, 32),
        })
        Library:Create("UIListLayout", {
            Parent            = TabText,
            Padding           = UDim.new(0, 2),
            SortOrder         = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })

        local TabTitleLbl = Library:Create("TextLabel", {
            Name                   = "Title",
            Parent                 = TabText,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0, 150, 0, 14),
            Font                   = Enum.Font.GothamBold,
            RichText               = true,
            Text                   = PageTitle,
            TextColor3             = T.Accent,
            TextSize               = 15,
            TextStrokeTransparency = 0.45,
            TextXAlignment         = Enum.TextXAlignment.Left,
        })
        Gradient(TabTitleLbl)

        Library:Create("TextLabel", {
            Name                   = "Desc",
            Parent                 = TabText,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0.9, 0, 0, 10),
            Font                   = Enum.Font.GothamMedium,
            RichText               = true,
            Text                   = PageDesc,
            TextColor3             = T.Text,
            TextSize               = 10,
            TextStrokeTransparency = 0.5,
            TextTransparency       = 0.2,
            TextXAlignment         = Enum.TextXAlignment.Left,
        })

        -- Page frame
        local NewPage = Library:Create("Frame", {
            Name                   = "NewPage",
            Parent                 = Scale_1,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
        })

        local PageScrolling = Library:Create("ScrollingFrame", {
            Name                      = "PageScrolling",
            Parent                    = NewPage,
            Active                    = true,
            BackgroundTransparency    = 1,
            BorderSizePixel           = 0,
            Size                      = UDim2.new(1, 0, 1, 0),
            ClipsDescendants          = true,
            AutomaticCanvasSize       = Enum.AutomaticSize.None,
            BottomImage               = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
            CanvasPosition            = Vector2.new(0, 0),
            ElasticBehavior           = Enum.ElasticBehavior.WhenScrollable,
            MidImage                  = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            ScrollBarThickness        = 0,
            ScrollingDirection        = Enum.ScrollingDirection.XY,
            TopImage                  = "rbxasset://textures/ui/Scroll/scroll-top.png",
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
        })
        Library:Create("UIPadding", {
            Parent        = PageScrolling,
            PaddingBottom = UDim.new(0, 1),
            PaddingLeft   = UDim.new(0, 15),
            PaddingRight  = UDim.new(0, 15),
            PaddingTop    = UDim.new(0, 1),
        })

        local PageLayout = Library:Create("UIListLayout", {
            Parent        = PageScrolling,
            Padding       = UDim.new(0, 5),
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder     = Enum.SortOrder.LayoutOrder,
            Wraps         = true,
        })
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageScrolling.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
        end)

        -- activeContainer is the current parent target for element builders.
        -- Page methods write to PageScrolling by default; Section sub-objects
        -- temporarily redirect this to their own inner column frame.
        local activeContainer = PageScrolling

        local function OnChangePage()
            Library:Tween({
                v = HeadScale_1, t = 0.2, s = "Exponential", d = "Out",
                g = { Size = UDim2.new(1, -30, 1, 0) },
            }):Play()
            Return_1.Visible = true
            PageService:JumpTo(NewPage)
        end

        -- ============================================================
        --  Page object  ─  all elements live below
        -- ============================================================
        local Page = {}

        -- ── Section  ─────────────────────────────────────────────────
        --  Creates a column container that elements can be added into.
        --
        --  :Section(Name, Side, Icon)
        --    Name  string              – header label
        --    Side  "Left" | "Right" | nil
        --          "Left"  → left  half-column  (pairs with a "Right" section)
        --          "Right" → right half-column  (pairs with a "Left"  section)
        --          nil     → full-width column  (big canvas, no partner needed)
        --    Icon  asset id | nil      – optional icon in the header
        --
        --  Returns a Section object that exposes the same element methods as
        --  Page (Paragraph, RightLabel, Button, Toggle, Slider, Input, Dropdown,
        --  Banner).  Elements added through the Section go into its inner list.
        --
        --  Usage:
        --    local left  = page:Section("Combat",   "Left",  iconId)
        --    local right = page:Section("Visuals",  "Right", iconId)
        --    local full  = page:Section("Settings", nil,     iconId)
        --    left:Toggle({ Title = "Aimbot", ... })
        --    full:Slider({ Title = "FOV",   ... })
        function Page:Section(Name, Side, Icon)
            -- ── Outer column frame ───────────────────────────────────
            -- nil  → full width;  Left/Right → slightly under half width
            -- (gap of 6px between the two halves)
            local colW = (Side == nil)
                and UDim2.new(1, 0, 0, 0)
                or  UDim2.new(0.5, -3, 0, 0)

            local ColFrame = Library:Create("Frame", {
                Name          = "Section_" .. tostring(Name),
                Parent        = PageScrolling,
                BackgroundColor3       = T.Surface,
                BackgroundTransparency = 0,
                BorderSizePixel        = 0,
                Size          = colW,
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            Library:Create("UICorner", { Parent = ColFrame, CornerRadius = UDim.new(0, 5) })
            Library:Create("UIStroke", { Parent = ColFrame, Color = T.Border, Thickness = 0.5 })
            Library:Create("UIListLayout", {
                Parent        = ColFrame,
                Padding       = UDim.new(0, 0),
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder     = Enum.SortOrder.LayoutOrder,
            })

            -- ── Header bar ───────────────────────────────────────────
            local Header = Library:Create("Frame", {
                Name             = "Header",
                Parent           = ColFrame,
                BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 0, 26),
            })
            Library:Create("UICorner", { Parent = Header, CornerRadius = UDim.new(0, 5) })
            Library:Create("UIListLayout", {
                Parent              = Header,
                Padding             = UDim.new(0, 5),
                FillDirection       = Enum.FillDirection.Horizontal,
                SortOrder           = Enum.SortOrder.LayoutOrder,
                VerticalAlignment   = Enum.VerticalAlignment.Center,
                HorizontalAlignment = (Side == "Right")
                    and Enum.HorizontalAlignment.Right
                    or  Enum.HorizontalAlignment.Left,
            })
            Library:Create("UIPadding", {
                Parent       = Header,
                PaddingLeft  = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            })

            -- Optional icon in header
            if Icon ~= nil then
                local HdrIcon = Library:Create("ImageLabel", {
                    Name                   = "Icon",
                    Parent                 = Header,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    LayoutOrder            = (Side == "Right") and 1 or -1,
                    Size                   = UDim2.new(0, 13, 0, 13),
                    Image                  = Library:Asset(Icon),
                    ImageColor3            = T.Accent,
                })
                Gradient(HdrIcon)
            end

            local HdrLbl = Library:Create("TextLabel", {
                Name                   = "Title",
                Parent                 = Header,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                LayoutOrder            = 0,
                Size                   = UDim2.new(0, 0, 0, 13),
                AutomaticSize          = Enum.AutomaticSize.X,
                Font                   = Enum.Font.GothamBold,
                RichText               = true,
                Text                   = Name,
                TextColor3             = T.Text,
                TextSize               = 12,
                TextStrokeTransparency = 0.7,
                TextXAlignment         = (Side == "Right")
                    and Enum.TextXAlignment.Right
                    or  Enum.TextXAlignment.Left,
            })
            Gradient(HdrLbl)

            -- ── Inner element list ────────────────────────────────────
            local InnerFrame = Library:Create("Frame", {
                Name                   = "Inner",
                Parent                 = ColFrame,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, 0),
                AutomaticSize          = Enum.AutomaticSize.Y,
            })
            Library:Create("UIListLayout", {
                Parent        = InnerFrame,
                Padding       = UDim.new(0, 5),
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder     = Enum.SortOrder.LayoutOrder,
            })
            Library:Create("UIPadding", {
                Parent        = InnerFrame,
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft   = UDim.new(0, 6),
                PaddingRight  = UDim.new(0, 6),
                PaddingTop    = UDim.new(0, 5),
            })

            -- ── Section sub-object ────────────────────────────────────
            -- All element methods on this object temporarily redirect
            -- activeContainer → InnerFrame, then restore it.
            local SectionObj = {}
            local elementMethods = {
                "Paragraph", "RightLabel", "Button", "Toggle",
                "Slider", "Input", "Dropdown", "Banner",
            }
            for _, method in ipairs(elementMethods) do
                SectionObj[method] = function(self, ...)
                    local prev   = activeContainer
                    activeContainer = InnerFrame
                    local result = Page[method](Page, ...)
                    activeContainer = prev
                    return result
                end
            end

            -- API
            function SectionObj:SetVisible(v) ColFrame.Visible = v end
            function SectionObj:SetTitle(t)   HdrLbl.Text      = tostring(t) end

            return SectionObj
        end

        -- ── Paragraph ────────────────────────────────────────────────
        --  Args: Title, Desc, Icon
        function Page:Paragraph(Args)
            local Title = Args.Title
            local Desc  = Args.Desc
            local Icon  = Args.Icon or Args.Image

            local Rows = Library:NewRows(activeContainer, Title, Desc, Icon)
            local L    = Rows.Vectorize.Left.Text

            local Data = { Title = Title, Desc = Desc, Instance = Rows }
            local API  = setmetatable({}, {
                __index    = function(_, k) return Data[k] end,
                __newindex = function(_, k, v)
                    rawset(Data, k, v)
                    if     k == "Title" then L.Title.Text = tostring(v)
                    elseif k == "Desc"  then L.Desc.Text  = tostring(v) end
                end,
            })
            function API:SetTitle(t)   L.Title.Text    = tostring(t) end
            function API:SetDesc(d)    L.Desc.Text     = tostring(d) end
            function API:SetVisible(v) Rows.Visible    = v end
            return API
        end

        -- ── RightLabel ───────────────────────────────────────────────
        --  Args: Title, Desc, Right, Icon
        function Page:RightLabel(Args)
            local Title     = Args.Title
            local Desc      = Args.Desc
            local RightText = Args.Right or "None"
            local Icon      = Args.Icon

            local Rows  = Library:NewRows(activeContainer, Title, Desc, Icon)
            local Right = Rows.Vectorize.Right
            local L     = Rows.Vectorize.Left.Text

            local lbl = Library:Create("TextLabel", {
                Name                   = "Title",
                Parent                 = Right,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                LayoutOrder            = -1,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, 0, 0, 13),
                Font                   = Enum.Font.GothamSemibold,
                RichText               = true,
                Text                   = RightText,
                TextColor3             = T.Text,
                TextSize               = 12,
                TextStrokeTransparency = 0.7,
                TextXAlignment         = Enum.TextXAlignment.Right,
            })
            Gradient(lbl)

            local Data = { Title = Title, Desc = Desc, Right = RightText, Instance = Rows }
            local API  = setmetatable({}, {
                __index    = function(_, k) return Data[k] end,
                __newindex = function(_, k, v)
                    rawset(Data, k, v)
                    if     k == "Title" then L.Title.Text = tostring(v)
                    elseif k == "Desc"  then L.Desc.Text  = tostring(v)
                    elseif k == "Right" then lbl.Text      = tostring(v) end
                end,
            })
            function API:Set(v)        lbl.Text        = tostring(v) end
            function API:SetTitle(t)   L.Title.Text    = tostring(t) end
            function API:SetDesc(d)    L.Desc.Text     = tostring(d) end
            function API:SetVisible(v) Rows.Visible    = v end
            return API
        end

        -- ── Button ───────────────────────────────────────────────────
        --  Args: Title, Desc, Icon, Text, Callback
        function Page:Button(Args)
            local Title    = Args.Title
            local Desc     = Args.Desc
            local Icon     = Args.Icon
            local BtnText  = Args.Text     or "Click"
            local Callback = Args.Callback

            local Rows  = Library:NewRows(activeContainer, Title, Desc, Icon)
            local L     = Rows.Vectorize.Left.Text
            local Right = Rows.Vectorize.Right

            local Btn = Library:Create("Frame", {
                Name             = "Button",
                Parent           = Right,
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Size             = UDim2.new(0, 75, 0, 25),
            })
            Library:Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 3) })
            AccentGrad(Btn)

            local BtnLbl = Library:Create("TextLabel", {
                Name                   = "Title",
                Parent                 = Btn,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, 0, 1, 0),
                Font                   = Enum.Font.GothamSemibold,
                RichText               = true,
                Text                   = BtnText,
                TextColor3             = T.Text,
                TextSize               = 11,
                TextStrokeTransparency = 0.7,
            })
            Btn.Size = UDim2.new(0, BtnLbl.TextBounds.X + 40, 0, 25)

            local BtnClick = Library:Button(Btn)
            BtnClick.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() then return end
                task.spawn(Library.Effect, BtnClick, Btn)
                if Callback then Callback() end
            end)

            local Data = { Title = Title, Desc = Desc, Text = BtnText, Instance = Rows }
            local API  = setmetatable({}, {
                __index    = function(_, k) return Data[k] end,
                __newindex = function(_, k, v)
                    rawset(Data, k, v)
                    if     k == "Title" then L.Title.Text = tostring(v)
                    elseif k == "Desc"  then L.Desc.Text  = tostring(v)
                    elseif k == "Text"  then BtnLbl.Text  = tostring(v) end
                end,
            })
            function API:SetText(t)    BtnLbl.Text     = tostring(t) end
            function API:SetTitle(t)   L.Title.Text    = tostring(t) end
            function API:SetDesc(d)    L.Desc.Text     = tostring(d) end
            function API:SetVisible(v) Rows.Visible    = v end
            function API:SetEnabled(v)
                BtnClick.Active                  = v
                Btn.BackgroundTransparency        = v and 0 or 0.5
            end
            return API
        end

        -- ── Toggle ───────────────────────────────────────────────────
        --  Args: Title, Desc, Icon, Value, Callback
        function Page:Toggle(Args)
            local Title     = Args.Title
            local Desc      = Args.Desc
            local Icon      = Args.Icon
            local Value     = Args.Value     or false
            local Callback  = Args.Callback  or function() end
            local ConfigKey = Args.ConfigKey

            local Rows     = Library:NewRows(activeContainer, Title, Desc, Icon)
            local L        = Rows.Vectorize.Left.Text
            local Right    = Rows.Vectorize.Right
            local TitleLbl = L.Title

            local BG = Library:Create("Frame", {
                Name             = "Background",
                Parent           = Right,
                BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                BorderSizePixel  = 0,
                Size             = UDim2.new(0, 20, 0, 20),
            })
            local StrokeUI = Library:Create("UIStroke", {
                Parent    = BG,
                Color     = T.Border,
                Thickness = 0.5,
            })
            Library:Create("UICorner", { Parent = BG, CornerRadius = UDim.new(0, 5) })

            local Highlight = Library:Create("Frame", {
                Name             = "Highlight",
                Parent           = BG,
                AnchorPoint      = Vector2.new(0.5, 0.5),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0.5, 0, 0.5, 0),
                Size             = UDim2.new(0, 20, 0, 20),
            })
            Library:Create("UICorner", { Parent = Highlight, CornerRadius = UDim.new(0, 5) })
            AccentGrad(Highlight)

            local CheckImg = Library:Create("ImageLabel", {
                Parent                 = Highlight,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(0.45, 0, 0.45, 0),
                Image                  = "rbxassetid://86682186031062",
            })

            local Click = Library:Button(BG)
            local Data  = { Title = Title, Desc = Desc, Value = Value }

            local function OnChanged(val)
                if val then
                    Callback(Data.Value)
                    TitleLbl.TextColor3 = T.Accent
                    Library:Tween({ v = Highlight, t = 0.5, s = "Exponential", d = "Out", g = { BackgroundTransparency = 0 } }):Play()
                    Library:Tween({ v = CheckImg,  t = 0.5, s = "Exponential", d = "Out", g = { ImageTransparency = 0 } }):Play()
                    Library:Tween({ v = CheckImg,  t = 0.3, s = "Exponential", d = "Out", g = { Size = UDim2.new(0.5, 0, 0.5, 0) } }):Play()
                    StrokeUI.Thickness = 0
                else
                    Callback(Data.Value)
                    TitleLbl.TextColor3 = T.Text
                    Library:Tween({ v = Highlight, t = 0.5, s = "Exponential", d = "Out", g = { BackgroundTransparency = 1 } }):Play()
                    Library:Tween({ v = CheckImg,  t = 0.5, s = "Exponential", d = "Out", g = { ImageTransparency = 1 } }):Play()
                    StrokeUI.Thickness = 0.5
                end
                if Library._AutoSave then pcall(Library.SaveConfig, Library) end
            end

            Click.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() then return end
                Data.Value = not Data.Value
                OnChanged(Data.Value)
            end)

            OnChanged(Data.Value)

            local API = setmetatable({}, {
                __index    = function(_, k) return Data[k] end,
                __newindex = function(_, k, v)
                    rawset(Data, k, v)
                    if     k == "Title" then TitleLbl.Text = tostring(v)
                    elseif k == "Desc"  then L.Desc.Text   = tostring(v)
                    elseif k == "Value" then Data.Value = v; OnChanged(v) end
                end,
            })
            function API:Set(v)        Data.Value = v; OnChanged(v) end
            function API:SetTitle(t)   TitleLbl.Text   = tostring(t) end
            function API:SetDesc(d)    L.Desc.Text     = tostring(d) end
            function API:SetVisible(v) Rows.Visible    = v end
            function API:SetEnabled(v)
                Click.Active                     = v
                BG.BackgroundTransparency        = v and 0 or 0.5
            end
            Library:_RegisterElement(ConfigKey,
                function() return Data.Value end,
                function(v) API:Set(v == true or v == "true") end
            )
            return API
        end

        -- ── Slider ───────────────────────────────────────────────────
        --  Args: Title, Icon, Min, Max, Rounding, Value, Callback
        function Page:Slider(Args)
            local Title     = Args.Title
            local Icon      = Args.Icon
            local Min       = Args.Min
            local Max       = Args.Max
            local Rounding  = Args.Rounding or 0
            local Value     = Args.Value    or Min
            local Callback  = Args.Callback or function() end
            local ConfigKey = Args.ConfigKey

            local SliderFrame = Library:Create("Frame", {
                Name             = "Slider",
                Parent           = activeContainer,
                BackgroundColor3 = T.Surface,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 0, 42),
                Selectable       = false,
            })
            Library:Create("UICorner", { Parent = SliderFrame, CornerRadius = UDim.new(0, 3) })
            Library:Create("UIStroke", { Parent = SliderFrame, Color = T.Border, Thickness = 0.5 })
            Library:Create("UIPadding", {
                Parent        = SliderFrame,
                PaddingBottom = UDim.new(0, 1),
                PaddingLeft   = UDim.new(0, 10),
                PaddingRight  = UDim.new(0, 10),
            })

            -- Optional icon (top-left of slider row)
            if Icon ~= nil then
                local SIcon = Library:Create("ImageLabel", {
                    Name                   = "Icon",
                    Parent                 = SliderFrame,
                    AnchorPoint            = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 10, 0.15, 0),
                    Size                   = UDim2.new(0, 13, 0, 13),
                    Image                  = Library:Asset(Icon),
                    ImageColor3            = T.Accent,
                    ZIndex                 = 2,
                })
                Gradient(SIcon)
            end

            local TextFrame = Library:Create("Frame", {
                Name                   = "Text",
                Parent                 = SliderFrame,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0, 0, 0.1, 0),
                Size                   = UDim2.new(0, 111, 0, 22),
                Selectable             = false,
            })
            Library:Create("UIListLayout", {
                Parent            = TextFrame,
                SortOrder         = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            })
            Library:Create("UIPadding", { Parent = TextFrame, PaddingBottom = UDim.new(0, 3) })

            local STitle = Library:Create("TextLabel", {
                Name                   = "Title",
                Parent                 = TextFrame,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                LayoutOrder            = -1,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, 0, 0, 13),
                Selectable             = false,
                Font                   = Enum.Font.GothamSemibold,
                RichText               = true,
                Text                   = Title,
                TextColor3             = T.Text,
                TextSize               = 12,
                TextStrokeTransparency = 0.7,
                TextXAlignment         = Enum.TextXAlignment.Left,
            })
            Gradient(STitle)

            local Scaling = Library:Create("Frame", {
                Name                   = "Scaling",
                Parent                 = SliderFrame,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 1, 0),
                Selectable             = false,
            })
            local Slide = Library:Create("Frame", {
                Name                   = "Slide",
                Parent                 = Scaling,
                AnchorPoint            = Vector2.new(0, 1),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0, 0, 1, 0),
                Size                   = UDim2.new(1, 0, 0, 23),
                Selectable             = false,
            })

            local Track = Library:Create("Frame", {
                Name             = "ColorBar",
                Parent           = Slide,
                AnchorPoint      = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                BorderSizePixel  = 0,
                Position         = UDim2.new(0.5, 0, 0.5, 0),
                Size             = UDim2.new(1, 0, 0, 5),
                Selectable       = false,
            })
            Library:Create("UICorner", { Parent = Track, CornerRadius = UDim.new(0, 3) })

            local Fill = Library:Create("Frame", {
                Name             = "Fill",
                Parent           = Track,
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Size             = UDim2.new(0, 0, 1, 0),
                Selectable       = false,
            })
            Library:Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(0, 3) })
            Library:Create("UIGradient", {
                Parent   = Fill,
                Rotation = 90,
                Color    = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(47,  47,  47 )),
                },
            })
            Library:Create("Frame", {
                Name             = "Circle",
                Parent           = Fill,
                AnchorPoint      = Vector2.new(1, 0.5),
                BackgroundColor3 = T.Text,
                BorderSizePixel  = 0,
                Position         = UDim2.new(1, 0, 0.5, 0),
                Size             = UDim2.new(0, 5, 0, 11),
                Selectable       = false,
            })

            local BoxVal = Library:Create("TextBox", {
                Name                   = "Boxvalue",
                Parent                 = Scaling,
                AnchorPoint            = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(1, -5, 0.449, -2),
                Size                   = UDim2.new(0, 60, 0, 15),
                ZIndex                 = 5,
                Font                   = Enum.Font.GothamMedium,
                RichText               = false,
                PlaceholderColor3      = Color3.fromRGB(178, 178, 178),
                Text                   = tostring(Value),
                TextColor3             = T.Text,
                TextSize               = 11,
                TextTransparency       = 0.5,
                TextTruncate           = Enum.TextTruncate.AtEnd,
                TextXAlignment         = Enum.TextXAlignment.Right,
            })

            local pink    = T.Accent
            local white   = T.Text
            local dragging = false

            local function Round(n, dec)
                local f = 10 ^ dec
                return math.floor(n * f + 0.5) / f
            end

            local function UpdateSlider(val)
                val = math.clamp(val, Min, Max)
                val = Round(val, Rounding)
                local ratio = (val - Min) / (Max - Min)
                Library:Tween({ v = Fill, t = 0.1, s = "Linear", d = "Out", g = { Size = UDim2.new(ratio, 0, 1, 0) } }):Play()
                BoxVal.Text = tostring(val)
                Callback(val)
                if Library._AutoSave then pcall(Library.SaveConfig, Library) end
                return val
            end

            local function GetValFromInput(input)
                local absX = Track.AbsolutePosition.X
                local absW = Track.AbsoluteSize.X
                return math.clamp((input.Position.X - absX) / absW, 0, 1) * (Max - Min) + Min
            end

            local function SetDragging(state)
                dragging = state
                if state then
                    Library:Tween({ v = BoxVal, t = 0.3, s = "Back",        d = "Out", g = { TextSize   = 15    } }):Play()
                    Library:Tween({ v = BoxVal, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = pink  } }):Play()
                    Library:Tween({ v = STitle, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = pink  } }):Play()
                else
                    Library:Tween({ v = BoxVal, t = 0.3, s = "Back",        d = "Out", g = { TextSize   = 11    } }):Play()
                    Library:Tween({ v = BoxVal, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = white } }):Play()
                    Library:Tween({ v = STitle, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = white } }):Play()
                end
            end

            local function SetFocused(state)
                if state then
                    Library:Tween({ v = BoxVal, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = pink  } }):Play()
                    Library:Tween({ v = STitle, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = pink  } }):Play()
                else
                    Library:Tween({ v = BoxVal, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = white } }):Play()
                    Library:Tween({ v = STitle, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = white } }):Play()
                end
            end

            local ClickBtn = Library:Button(SliderFrame)
            ClickBtn.InputBegan:Connect(function(i)
                if Library:IsDropdownOpen() then return end
                if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                    SetDragging(true)
                    UpdateSlider(GetValFromInput(i))
                end
            end)
            ClickBtn.InputEnded:Connect(function(i)
                if Library:IsDropdownOpen() then return end
                if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                    SetDragging(false)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if Library:IsDropdownOpen() then return end
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                    or i.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(GetValFromInput(i))
                end
            end)
            BoxVal.Focused:Connect(function()  SetFocused(true)  end)
            BoxVal.FocusLost:Connect(function()
                SetFocused(false)
                Value = UpdateSlider(tonumber(BoxVal.Text) or Value)
            end)

            UpdateSlider(Value)

            local Data = { Title = Title, Value = Value, Instance = SliderFrame }
            local API  = setmetatable({}, {
                __index    = function(_, k) return Data[k] end,
                __newindex = function(_, k, v)
                    rawset(Data, k, v)
                    if     k == "Title" then STitle.Text = tostring(v)
                    elseif k == "Value" then Value = UpdateSlider(v) end
                end,
            })
            function API:Set(v)        Value = UpdateSlider(v) end
            function API:SetTitle(t)   STitle.Text          = tostring(t) end
            function API:SetVisible(v) SliderFrame.Visible  = v end
            function API:SetEnabled(v) ClickBtn.Active      = v end
            Library:_RegisterElement(ConfigKey,
                function() return tonumber(BoxVal.Text) or Value end,
                function(v) API:Set(tonumber(v) or Value) end
            )
            return API
        end

        -- ── Input ────────────────────────────────────────────────────
        --  Args: Value, Callback
        function Page:Input(Args)
            local Value     = Args.Value     or ""
            local Callback  = Args.Callback  or function() end
            local ConfigKey = Args.ConfigKey

            local InputFrame = Library:Create("Frame", {
                Name                   = "Input",
                Parent                 = activeContainer,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, 30),
                Selectable             = false,
            })
            Library:Create("UIListLayout", {
                Parent            = InputFrame,
                Padding           = UDim.new(0, 5),
                FillDirection     = Enum.FillDirection.Horizontal,
                SortOrder         = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            })

            local Front = Library:Create("Frame", {
                Name             = "Front",
                Parent           = InputFrame,
                BackgroundColor3 = T.Surface,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, -35, 1, 0),
                Selectable       = false,
            })
            Library:Create("UICorner", { Parent = Front, CornerRadius = UDim.new(0, 2) })
            Library:Create("UIStroke", { Parent = Front, Color = T.Border, Thickness = 0.5 })

            local TB = Library:Create("TextBox", {
                Parent                 = Front,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, -20, 1, 0),
                Font                   = Enum.Font.GothamMedium,
                RichText               = false,
                PlaceholderColor3      = Color3.fromRGB(55, 55, 55),
                PlaceholderText        = "Paste your text input here.",
                Text                   = tostring(Value),
                TextColor3             = Color3.fromRGB(100, 100, 100),
                TextSize               = 11,
                TextXAlignment         = Enum.TextXAlignment.Left,
            })

            local Enter = Library:Create("Frame", {
                Name             = "Enter",
                Parent           = InputFrame,
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Size             = UDim2.new(0, 30, 0, 30),
                Selectable       = false,
            })
            Library:Create("UICorner", { Parent = Enter, CornerRadius = UDim.new(0, 3) })
            AccentGrad(Enter)

            local CopyImg = Library:Create("ImageLabel", {
                Name                   = "Asset",
                Parent                 = Enter,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(0, 15, 0, 15),
                Image                  = "rbxassetid://78020815235467",
            })
            local CopyClick = Library:Button(Enter)

            TB.FocusLost:Connect(function(enter)
                if enter and TB.Text ~= "" then Callback(TB.Text) end
            end)
            CopyClick.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() then return end
                pcall(setclipboard, Value)
                CopyImg.Image = "rbxassetid://121742282171603"
                delay(3, function() CopyImg.Image = "rbxassetid://78020815235467" end)
            end)

            local Data = { Value = Value, Instance = InputFrame }
            local API  = setmetatable({}, {
                __index    = function(_, k) return Data[k] end,
                __newindex = function(_, k, v)
                    rawset(Data, k, v)
                    if k == "Value" then TB.Text = tostring(v) end
                end,
            })
            function API:Set(v)        Data.Value = v; TB.Text = tostring(v) end
            function API:SetVisible(v) InputFrame.Visible    = v end
            function API:SetEnabled(v)
                CopyClick.Active    = v
                TB.TextEditable     = v
            end
            Library:_RegisterElement(ConfigKey,
                function() return TB.Text end,
                function(v) API:Set(tostring(v or "")) end
            )
            return API
        end

        -- ── Dropdown ─────────────────────────────────────────────────
        --  Args: Title, Icon, List, Value, Callback
        function Page:Dropdown(Args)
            local Title     = Args.Title
            local Icon      = Args.Icon
            local List      = Args.List
            local Value     = Args.Value
            local Callback  = Args.Callback
            local ConfigKey = Args.ConfigKey
            local IsMulti   = typeof(Value) == "table"

            local Rows  = Library:NewRows(activeContainer, Title, "N/A", Icon)
            local Right = Rows.Vectorize.Right
            local L     = Rows.Vectorize.Left.Text

            Library:Create("ImageLabel", {
                Parent                 = Right,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(0, 20, 0, 20),
                Image                  = "rbxassetid://132291592681506",
                ImageTransparency      = 0.5,
            })

            local Open = Library:Button(Rows.Vectorize)

            local function GetText()
                if IsMulti then return table.concat(Value, ", ") end
                return tostring(Value)
            end
            L.Desc.Text = GetText()

            local Dropdown = Library:Create("Frame", {
                Name             = "Dropdown",
                Parent           = Background_1,
                AnchorPoint      = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                BorderSizePixel  = 0,
                Position         = UDim2.new(0.5, 0, 0.3, 0),
                Size             = UDim2.new(0, 300, 0, 250),
                ZIndex           = 500,
                Selectable       = false,
                Visible          = false,
            })
            Library:Create("UICorner",  { Parent = Dropdown, CornerRadius = UDim.new(0, 3) })
            Library:Create("UIStroke",  { Parent = Dropdown, Color = Color3.fromRGB(30, 30, 30), Thickness = 0.5 })
            Library:Create("UIListLayout", {
                Parent              = Dropdown,
                Padding             = UDim.new(0, 5),
                SortOrder           = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            })
            Library:Create("UIPadding", {
                Parent        = Dropdown,
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft   = UDim.new(0, 10),
                PaddingRight  = UDim.new(0, 10),
                PaddingTop    = UDim.new(0, 10),
            })

            -- Dropdown header
            local DDHeader = Library:Create("Frame", {
                Name                   = "Text",
                Parent                 = Dropdown,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                LayoutOrder            = -5,
                Size                   = UDim2.new(1, 0, 0, 30),
                ZIndex                 = 500,
                Selectable             = false,
            })
            Library:Create("UIListLayout", {
                Parent              = DDHeader,
                Padding             = UDim.new(0, 1),
                SortOrder           = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment   = Enum.VerticalAlignment.Center,
            })

            local DDTitle = Library:Create("TextLabel", {
                Name                   = "Title",
                Parent                 = DDHeader,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                LayoutOrder            = -1,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, 0, 0, 13),
                ZIndex                 = 500,
                Font                   = Enum.Font.GothamSemibold,
                RichText               = true,
                Text                   = Title,
                TextColor3             = T.Accent,
                TextSize               = 14,
                TextStrokeTransparency = 0.7,
                TextXAlignment         = Enum.TextXAlignment.Left,
            })
            Gradient(DDTitle)

            local DDDesc = Library:Create("TextLabel", {
                Name                   = "Desc",
                Parent                 = DDHeader,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, 0, 0, 10),
                ZIndex                 = 500,
                Font                   = Enum.Font.GothamMedium,
                RichText               = true,
                Text                   = GetText(),
                TextColor3             = T.Text,
                TextSize               = 10,
                TextStrokeTransparency = 0.7,
                TextTransparency       = 0.6,
                TextTruncate           = Enum.TextTruncate.AtEnd,
                TextXAlignment         = Enum.TextXAlignment.Left,
            })

            -- Search bar
            local SearchWrap = Library:Create("Frame", {
                Name                   = "Input",
                Parent                 = Dropdown,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                LayoutOrder            = -4,
                Size                   = UDim2.new(1, 0, 0, 25),
                ZIndex                 = 500,
                Selectable             = false,
            })
            Library:Create("UIListLayout", {
                Parent            = SearchWrap,
                Padding           = UDim.new(0, 5),
                FillDirection     = Enum.FillDirection.Horizontal,
                SortOrder         = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            })

            local SearchFront = Library:Create("Frame", {
                Name             = "Front",
                Parent           = SearchWrap,
                BackgroundColor3 = T.Surface,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 1, 0),
                ZIndex           = 500,
                Selectable       = false,
            })
            Library:Create("UICorner", { Parent = SearchFront, CornerRadius = UDim.new(0, 2) })
            Library:Create("UIStroke", { Parent = SearchFront, Color = T.Border, Thickness = 0.5 })

            local SearchBox = Library:Create("TextBox", {
                Name                   = "Search",
                Parent                 = SearchFront,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                CursorPosition         = -1,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, -20, 1, 0),
                ZIndex                 = 500,
                Font                   = Enum.Font.GothamMedium,
                RichText               = false,
                PlaceholderColor3      = Color3.fromRGB(55, 55, 55),
                PlaceholderText        = "Search",
                Text                   = "",
                TextColor3             = T.Text,
                TextSize               = 11,
                TextXAlignment         = Enum.TextXAlignment.Left,
            })

            -- Items list
            local ItemsList = Library:Create("ScrollingFrame", {
                Name                   = "List",
                Parent                 = Dropdown,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, 160),
                ZIndex                 = 500,
                ScrollBarThickness     = 0,
            })
            local ItemsLayout = Library:Create("UIListLayout", {
                Parent              = ItemsList,
                Padding             = UDim.new(0, 3),
                SortOrder           = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            })
            Library:Create("UIPadding", {
                Parent       = ItemsList,
                PaddingLeft  = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
            })
            ItemsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ItemsList.CanvasSize = UDim2.new(0, 0, 0, ItemsLayout.AbsoluteContentSize.Y + 15)
            end)

            local selectedValues = {}
            local selectedOrder  = 0

            local function isInTable(val, tbl)
                if type(tbl) ~= "table" then return false end
                for _, v in pairs(tbl) do if v == val then return true end end
                return false
            end

            local function Settext()
                local txt = IsMulti and table.concat(Value, ", ") or tostring(Value)
                DDDesc.Text    = txt
                L.Desc.Text    = txt
            end

            local isOpen = false
            UserInputService.InputBegan:Connect(function(A)
                if not isOpen then return end
                local M = LocalPlayer:GetMouse()
                local DBP, DBS = Dropdown.AbsolutePosition, Dropdown.AbsoluteSize
                if A.UserInputType == Enum.UserInputType.MouseButton1
                    or A.UserInputType == Enum.UserInputType.Touch then
                    if not (M.X >= DBP.X and M.X <= DBP.X + DBS.X
                        and M.Y >= DBP.Y and M.Y <= DBP.Y + DBS.Y) then
                        isOpen = false
                        Dropdown.Visible   = false
                        Dropdown.Position  = UDim2.new(0.5, 0, 0.3, 0)
                    end
                end
            end)

            Open.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() then return end
                isOpen = not isOpen
                if isOpen then
                    Dropdown.Visible = true
                    Library:Tween({ v = Dropdown, t = 0.3, s = "Back", d = "Out", g = { Position = UDim2.new(0.5, 0, 0.5, 0) } }):Play()
                else
                    Dropdown.Visible  = false
                    Dropdown.Position = UDim2.new(0.5, 0, 0.3, 0)
                end
            end)

            local Setting = {}
            function Setting:Clear(a)
                for _, v in ipairs(ItemsList:GetChildren()) do
                    if v:IsA("Frame") then
                        local shouldClear = a == nil
                            or (type(a) == "string" and v.Title.Text == a)
                            or (type(a) == "table"  and isInTable(v.Title.Text, a))
                        if shouldClear then v:Destroy() end
                    end
                end
                if a == nil then
                    Value          = nil
                    selectedValues = {}
                    selectedOrder  = 0
                    DDDesc.Text    = "None"
                    L.Desc.Text    = "None"
                end
            end

            function Setting:AddList(Name)
                local Row = Library:Create("Frame", {
                    Name                   = "NewList",
                    Parent                 = ItemsList,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    LayoutOrder            = 0,
                    Size                   = UDim2.new(1, 0, 0, 25),
                    ZIndex                 = 500,
                    Selectable             = false,
                })
                Library:Create("UICorner", { Parent = Row, CornerRadius = UDim.new(0, 2) })

                local RowTitle = Library:Create("TextLabel", {
                    Name                   = "Title",
                    Parent                 = Row,
                    AnchorPoint            = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    LayoutOrder            = -1,
                    Position               = UDim2.new(0.5, 0, 0.5, 0),
                    Size                   = UDim2.new(1, -15, 1, 0),
                    ZIndex                 = 500,
                    Selectable             = false,
                    Font                   = Enum.Font.GothamSemibold,
                    RichText               = true,
                    Text                   = tostring(Name),
                    TextColor3             = T.Text,
                    TextSize               = 11,
                    TextStrokeTransparency = 0.7,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                })
                Gradient(RowTitle)

                local function OnValue(val)
                    RowTitle.TextColor3 = val and T.Accent or T.Text
                    Library:Tween({
                        v = Row, t = 0.2, s = "Linear", d = "Out",
                        g = { BackgroundTransparency = val and 0.85 or 1 },
                    }):Play()
                end

                local RowClick = Library:Button(RowTitle)
                local function OnSelected()
                    if IsMulti then
                        if selectedValues[Name] then
                            selectedValues[Name] = nil
                            Row.LayoutOrder = 0
                            OnValue(false)
                        else
                            selectedOrder = selectedOrder - 1
                            selectedValues[Name] = selectedOrder
                            Row.LayoutOrder = selectedOrder
                            OnValue(true)
                        end
                        local sl = {}
                        for i in pairs(selectedValues) do table.insert(sl, i) end
                        if #sl > 0 then
                            table.sort(sl)
                            Value = sl
                            Settext()
                        else
                            DDDesc.Text = "N/A"
                            L.Desc.Text = "N/A"
                        end
                        pcall(Callback, sl)
                    else
                        for _, v in pairs(ItemsList:GetChildren()) do
                            if v:IsA("Frame") and v.Name == "NewList" then
                                v.Title.TextColor3 = T.Text
                                Library:Tween({ v = v, t = 0.2, s = "Linear", d = "Out", g = { BackgroundTransparency = 1 } }):Play()
                            end
                        end
                        OnValue(true)
                        Value = Name
                        Settext()
                        pcall(Callback, Value)
                    end
                end

                delay(0, function()
                    if IsMulti then
                        if isInTable(Name, Value) then
                            selectedOrder = selectedOrder - 1
                            selectedValues[Name] = selectedOrder
                            Row.LayoutOrder = selectedOrder
                            OnValue(true)
                            local sl = {}
                            for i in pairs(selectedValues) do table.insert(sl, i) end
                            if #sl > 0 then table.sort(sl); Settext()
                            else DDDesc.Text = "N/A"; L.Desc.Text = "N/A" end
                            pcall(Callback, sl)
                        end
                    else
                        if Name == Value then OnValue(true); Settext(); pcall(Callback, Value) end
                    end
                end)

                RowClick.MouseButton1Click:Connect(OnSelected)
            end

            SearchBox.Changed:Connect(function()
                local s = string.lower(SearchBox.Text)
                for _, v in pairs(ItemsList:GetChildren()) do
                    if v:IsA("Frame") and v.Name == "NewList" then
                        v.Visible = string.find(string.lower(v.Title.Text), s, 1, true) ~= nil
                    end
                end
            end)

            for _, name in ipairs(List) do Setting:AddList(name) end

            local Data = { Title = Title, Value = Value, Instance = Rows, Setting = Setting }
            local API  = setmetatable({}, {
                __index    = function(_, k) return Data[k] end,
                __newindex = function(_, k, v)
                    rawset(Data, k, v)
                    if k == "Title" then L.Title.Text = tostring(v) end
                end,
            })
            function API:Set(v)      Value = v; Settext(); pcall(Callback, v) end
            function API:SetVisible(v) Rows.Visible = v end
            function API:AddList(name) Setting:AddList(name) end
            function API:Clear(a)      Setting:Clear(a) end
            Library:_RegisterElement(ConfigKey,
                function() return Value end,
                function(v) API:Set(v) end
            )
            return API
        end

        -- ── AddSettingTab ─────────────────────────────────────────────
        --  Appends a pre-built "⚙ Settings" panel to this page.
        --  Contains:  UI controls (opacity, accent, scale)
        --             Config manager (save / load / delete / list)
        --
        --  Usage:
        --    local page = Window:NewPage({ Title = "Settings", ... })
        --    page:AddSettingTab()
        function Page:AddSettingTab()
            local T = Library.Theme

            -- ── Left: UI Controls ─────────────────────────────────────
            local uiCol  = Page:Section("Interface",      "Left",  nil)
            local cfgCol = Page:Section("Config Manager", "Right", nil)

            -- Opacity
            uiCol:Slider({
                Title    = "Window Opacity",
                Desc     = "Background transparency",
                Min      = 0, Max = 0.95, Rounding = 2, Value = 0,
                ConfigKey = "__xova_opacity",
                Callback  = function(v) Library:SetTransparency(v) end,
            })

            -- Accent colour
            local accentList = { "Default Pink", "Green", "Blue", "Orange", "Purple", "White", "Red" }
            local accentMap  = {
                ["Default Pink"] = Color3.fromRGB(255, 0,   127),
                Green            = Color3.fromRGB(48,  255, 106),
                Blue             = Color3.fromRGB(0,   120, 255),
                Orange           = Color3.fromRGB(255, 130, 0  ),
                Purple           = Color3.fromRGB(140, 0,   255),
                White            = Color3.fromRGB(220, 220, 220),
                Red              = Color3.fromRGB(255, 40,  40 ),
            }
            uiCol:Dropdown({
                Title     = "Accent Colour",
                List      = accentList,
                Value     = "Default Pink",
                ConfigKey = "__xova_accent",
                Callback  = function(v)
                    if accentMap[v] then Library:SetTheme({ Accent = accentMap[v] }) end
                end,
            })

            -- Random accent button
            uiCol:Button({
                Title    = "Random Accent",
                Desc     = "Roll a random accent colour",
                Text     = "🎲 Random",
                Callback = function()
                    Library:SetTheme({ Accent = Library:Utility("Random", "HSV") })
                end,
            })

            -- ── Right: Config Manager ─────────────────────────────────
            cfgCol:Paragraph({
                Title = "Config Manager",
                Desc  = Library._ConfigPath
                    and ("Folder: " .. Library._ConfigPath)
                    or  "No ConfigPath set in Window({})",
            })

            local configNameInput = cfgCol:Input({
                Value     = "default",
                ConfigKey = nil,  -- never save the config-name field itself
                Callback  = function() end,
            })

            cfgCol:Button({
                Title    = "Save Config",
                Desc     = "Write current values to file",
                Text     = "💾 Save",
                Callback = function()
                    local name = configNameInput.Value ~= "" and configNameInput.Value or "default"
                    local ok   = Library:SaveConfig(name)
                    print("[Xova] SaveConfig(" .. name .. ") → " .. tostring(ok))
                end,
            })

            cfgCol:Button({
                Title    = "Load Config",
                Desc     = "Read values from file",
                Text     = "📂 Load",
                Callback = function()
                    local name = configNameInput.Value ~= "" and configNameInput.Value or "default"
                    local ok   = Library:LoadConfig(name)
                    print("[Xova] LoadConfig(" .. name .. ") → " .. tostring(ok))
                end,
            })

            cfgCol:Button({
                Title    = "Delete Config",
                Desc     = "Remove the config file",
                Text     = "🗑 Delete",
                Callback = function()
                    local name = configNameInput.Value ~= "" and configNameInput.Value or "default"
                    local ok   = Library:DeleteConfig(name)
                    print("[Xova] DeleteConfig(" .. name .. ") → " .. tostring(ok))
                end,
            })

            -- Saved configs list (refreshes on open – we do it with RightLabel)
            local savedLabel = cfgCol:RightLabel({
                Title = "Saved Configs",
                Desc  = "Files in config folder",
                Right = "—",
            })

            cfgCol:Button({
                Title    = "Refresh List",
                Desc     = "Update saved configs display",
                Text     = "↻ Refresh",
                Callback = function()
                    local list = Library:ListConfigs()
                    savedLabel:Set(#list > 0 and table.concat(list, ", ") or "none")
                end,
            })

            -- ── Full-width: Script Info ───────────────────────────────
            local infoSec = Page:Section("Script Info", nil, nil)

            infoSec:RightLabel({
                Title = "Library",
                Desc  = "UI framework",
                Right = "Xova v3 Enhanced",
            })

            infoSec:RightLabel({
                Title = "Load Time",
                Desc  = "Script init time",
                Right = string.format("%.3f s", os.clock() - Library._LoadTick),
            })

            infoSec:RightLabel({
                Title = "Registered Keys",
                Desc  = "Elements tracked by config",
                Right = (function()
                    local n = 0
                    for _ in pairs(Library._Registry) do n = n + 1 end
                    return tostring(n)
                end)(),
            })

            infoSec:RightLabel({
                Title = "AutoSave",
                Desc  = "Save on every value change",
                Right = Library._AutoSave and "On" or "Off",
            })

            infoSec:RightLabel({
                Title = "ConfigPath",
                Desc  = "Save folder",
                Right = Library._ConfigPath or "Not set",
            })
        end

        -- ── Banner ───────────────────────────────────────────────────
        function Page:Banner(Assets)
            local img = Library:Create("ImageLabel", {
                Name                   = "NewBanner",
                Parent                 = activeContainer,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, 235),
                Image                  = Library:Asset(Assets),
                ScaleType              = Enum.ScaleType.Crop,
            })
            Library:Create("UICorner", { Parent = img, CornerRadius = UDim.new(0, 3) })
            return img
        end

        TabClick.MouseButton1Click:Connect(OnChangePage)
        return Page
    end

    -- ── Booting up ───────────────────────────────────────────────────
    do
        PageService:JumpTo(Home_1)
        Library:Draggable(Background_1)

        PageService.HorizontalAlignment     = Enum.HorizontalAlignment.Left
        PageService.EasingStyle             = Enum.EasingStyle.Exponential
        PageService.TweenTime               = 0.5
        PageService.GamepadInputEnabled     = false
        PageService.ScrollWheelInputEnabled = false
        PageService.TouchInputEnabled       = false

        Library.PageService = PageService
        Scale_1.ClipsDescendants = true

        local ReturnBtn = Library:Button(Return_1)
        local function OnReturn()
            Return_1.Visible = false
            Library:Tween({
                v = HeadScale_1, t = 0.3, s = "Exponential", d = "Out",
                g = { Size = UDim2.new(1, 0, 1, 0) },
            }):Play()
            PageService:JumpTo(Home_1)
        end
        ReturnBtn.MouseButton1Click:Connect(OnReturn)

        -- Toggle / pillow button
        do
            local ToggleScreen = Library:Create("ScreenGui", {
                Name           = "Xova",
                Parent         = Library:Parent(),
                ZIndexBehavior = Enum.ZIndexBehavior.Global,
                IgnoreGuiInset = true,
            })
            local Pillow = Library:Create("TextButton", {
                Name             = "Pillow",
                Parent           = ToggleScreen,
                BackgroundColor3 = Color3.fromRGB(11, 11, 11),
                BorderSizePixel  = 0,
                Position         = UDim2.new(0.06, 0, 0.15, 0),
                Size             = UDim2.new(0, 50, 0, 50),
                Text             = "",
            })
            Library:Create("UICorner", { Parent = Pillow, CornerRadius = UDim.new(1, 0) })
            Library:Create("ImageLabel", {
                Name                   = "Logo",
                Parent                 = Pillow,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(0.5, 0, 0.5, 0),
                Image                  = "rbxassetid://104055321996495",
            })
            Library:Draggable(Pillow)
            Pillow.MouseButton1Click:Connect(function()
                Background_1.Visible = not Background_1.Visible
            end)
            UserInputService.InputBegan:Connect(function(Input, Processed)
                if Processed then return end
                if Input.KeyCode == Enum.KeyCode.LeftControl then
                    Background_1.Visible = not Background_1.Visible
                end
            end)
        end

        -- UIScale + helpers
        do
            local WindowSize = 1.45
            local Scaler = Library:Create("UIScale", {
                Parent = Xova,
                Scale  = if Mobile then 1 else WindowSize,
            })
            function Library:SizeSlider(Page, Plugins)
                return Plugins:Slider(Page, "Interface Scaler", { 1, 2, 2 }, "Interface Scaler", function(v)
                    Scaler.Scale = v
                end)
            end
            function Library:SetTimeValue(val)
                THETIME.Text = val
            end
        end

        -- Auto-load default config after all elements have registered
        if _doAutoLoad then
            task.delay(0.15, function()
                Library:LoadConfig("default")
            end)
        end
    end

    return Window
end

return Library
