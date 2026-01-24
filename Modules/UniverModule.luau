--[[
    UniversalModule.lua
    Universal game interaction module for Roblox
    
    Features:
    - Virtual Input (keyboard, mouse)
    - Click Detection (ClickDetectors, ProximityPrompts)
    - GUI Interaction (buttons, frames)
    - Tool Management
    - Remote Firing
    
    Usage:
        local Universal = require(game.ReplicatedStorage.UniversalModule)
        Universal.PressKey("W", 2) -- Hold W for 2 seconds
        Universal.ClickButton(gui.Frame.Button)
        Universal.FireClickDetector(workspace.Button.ClickDetector)
]]

local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local UniversalModule = {}

local player = Players.LocalPlayer
local mouse = player:GetMouse()

--[[
    ========================================
    VIRTUAL INPUT - KEYBOARD
    ========================================
]]

--[[
    PressKey - Simulates a key press
    
    @param key - KeyCode enum or string (e.g., "W", Enum.KeyCode.W)
    @param duration - Optional hold duration in seconds
]]
function UniversalModule.PressKey(key, duration)
    -- Convert string to KeyCode if needed
    local keyCode = key
    if typeof(key) == "string" then
        keyCode = Enum.KeyCode[key]
    end
    
    if not keyCode then
        warn("UniversalModule: Invalid key code")
        return
    end
    
    -- Press key down
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    
    if duration and duration > 0 then
        task.wait(duration)
        -- Release key
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end
end

--[[
    ReleaseKey - Releases a held key
    
    @param key - KeyCode enum or string
]]
function UniversalModule.ReleaseKey(key)
    local keyCode = key
    if typeof(key) == "string" then
        keyCode = Enum.KeyCode[key]
    end
    
    if keyCode then
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end
end

--[[
    TypeText - Types a string of text
    
    @param text - String to type
    @param delay - Optional delay between characters (default 0.05)
]]
function UniversalModule.TypeText(text, delay)
    delay = delay or 0.05
    
    for i = 1, #text do
        local char = text:sub(i, i)
        local keyCode = Enum.KeyCode[char:upper()]
        
        if keyCode then
            UniversalModule.PressKey(keyCode, 0.05)
            task.wait(delay)
        end
    end
end

--[[
    HoldKeys - Hold multiple keys simultaneously
    
    @param keys - Table of key codes/strings
    @param duration - How long to hold
    
    Example: HoldKeys({"W", "Shift"}, 3)
]]
function UniversalModule.HoldKeys(keys, duration)
    -- Press all keys
    for _, key in pairs(keys) do
        UniversalModule.PressKey(key, 0)
    end
    
    -- Wait
    if duration then
        task.wait(duration)
    end
    
    -- Release all keys
    for _, key in pairs(keys) do
        UniversalModule.ReleaseKey(key)
    end
end

--[[
    ========================================
    VIRTUAL INPUT - MOUSE
    ========================================
]]

--[[
    ClickMouse - Simulates a mouse click at current position
    
    @param button - 0 for left, 1 for right, 2 for middle (default 0)
]]
function UniversalModule.ClickMouse(button)
    button = button or 0
    
    VirtualInputManager:SendMouseButtonEvent(0, 0, button, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, button, false, game, 0)
end

--[[
    ClickPosition - Clicks at a specific screen position
    
    @param x - X coordinate
    @param y - Y coordinate
    @param button - Mouse button (default 0)
]]
function UniversalModule.ClickPosition(x, y, button)
    button = button or 0
    
    VirtualInputManager:SendMouseButtonEvent(x, y, button, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(x, y, button, false, game, 0)
end

--[[
    ScrollMouse - Simulates mouse scroll
    
    @param amount - Positive for up, negative for down
]]
function UniversalModule.ScrollMouse(amount)
    VirtualInputManager:SendMouseWheelEvent(0, 0, amount > 0, game)
end

--[[
    ========================================
    CLICK DETECTORS
    ========================================
]]

--[[
    FireClickDetector - Activates a ClickDetector
    
    @param clickDetector - The ClickDetector instance
    @param distance - Optional distance (default 0)
]]
function UniversalModule.FireClickDetector(clickDetector, distance)
    if not clickDetector or not clickDetector:IsA("ClickDetector") then
        warn("UniversalModule: Invalid ClickDetector")
        return false
    end
    
    distance = distance or 0
    
    -- Fire the click detector
    local success = pcall(function()
        fireclickdetector(clickDetector, distance)
    end)
    
    if not success then
        -- Fallback method
        local oldParent = clickDetector.Parent
        local oldMaxDist = clickDetector.MaxActivationDistance
        
        clickDetector.MaxActivationDistance = math.huge
        clickDetector.Parent = player.Character.HumanoidRootPart
        
        task.wait()
        
        clickDetector.MaxActivationDistance = oldMaxDist
        clickDetector.Parent = oldParent
    end
    
    return true
end

--[[
    FireAllClickDetectors - Fires all ClickDetectors in a parent
    
    @param parent - Parent instance to search (e.g., workspace)
    @param nameFilter - Optional name filter
]]
function UniversalModule.FireAllClickDetectors(parent, nameFilter)
    local count = 0
    
    for _, descendant in pairs(parent:GetDescendants()) do
        if descendant:IsA("ClickDetector") then
            if not nameFilter or descendant.Parent.Name:match(nameFilter) then
                UniversalModule.FireClickDetector(descendant)
                count = count + 1
                task.wait(0.1)
            end
        end
    end
    
    return count
end

--[[
    ========================================
    PROXIMITY PROMPTS
    ========================================
]]

--[[
    FireProximityPrompt - Activates a ProximityPrompt
    
    @param proximityPrompt - The ProximityPrompt instance
]]
function UniversalModule.FireProximityPrompt(proximityPrompt)
    if not proximityPrompt or not proximityPrompt:IsA("ProximityPrompt") then
        warn("UniversalModule: Invalid ProximityPrompt")
        return false
    end
    
    local success = pcall(function()
        fireproximityprompt(proximityPrompt)
    end)
    
    if not success then
        -- Fallback: trigger manually
        proximityPrompt:InputHoldBegin()
        task.wait(proximityPrompt.HoldDuration or 0.5)
        proximityPrompt:InputHoldEnd()
    end
    
    return true
end

--[[
    FireAllProximityPrompts - Fires all ProximityPrompts in range
    
    @param parent - Parent to search
    @param maxDistance - Maximum distance (default 20)
]]
function UniversalModule.FireAllProximityPrompts(parent, maxDistance)
    maxDistance = maxDistance or 20
    local count = 0
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return 0 end
    
    for _, descendant in pairs(parent:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            local promptParent = descendant.Parent
            if promptParent and promptParent:IsA("BasePart") then
                local distance = (rootPart.Position - promptParent.Position).Magnitude
                
                if distance <= maxDistance then
                    UniversalModule.FireProximityPrompt(descendant)
                    count = count + 1
                    task.wait(0.1)
                end
            end
        end
    end
    
    return count
end

--[[
    ========================================
    GUI INTERACTION
    ========================================
]]

--[[
    ClickButton - Clicks a GUI button
    
    @param button - TextButton or ImageButton instance
]]
function UniversalModule.ClickButton(button)
    if not button or not (button:IsA("TextButton") or button:IsA("ImageButton")) then
        warn("UniversalModule: Invalid button")
        return false
    end
    
    -- Method 1: Fire MouseButton1Click
    local connections = getconnections or get_signal_cons
    if connections then
        for _, connection in pairs(connections(button.MouseButton1Click)) do
            connection:Fire()
        end
        return true
    end
    
    -- Method 2: Simulate click position
    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize
    local centerX = absPos.X + absSize.X / 2
    local centerY = absPos.Y + absSize.Y / 2
    
    UniversalModule.ClickPosition(centerX, centerY)
    return true
end

--[[
    FindAndClickButton - Finds and clicks a button by name/text
    
    @param gui - GUI to search in
    @param searchText - Text or name to search for
    @param exact - Exact match (default false)
]]
function UniversalModule.FindAndClickButton(gui, searchText, exact)
    for _, descendant in pairs(gui:GetDescendants()) do
        if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
            local text = descendant.Text or descendant.Name
            
            if exact then
                if text == searchText then
                    return UniversalModule.ClickButton(descendant)
                end
            else
                if text:lower():match(searchText:lower()) then
                    return UniversalModule.ClickButton(descendant)
                end
            end
        end
    end
    
    return false
end

--[[
    ========================================
    TOOL MANAGEMENT
    ========================================
]]

--[[
    EquipTool - Equips a tool from backpack
    
    @param toolName - Name of tool (or Tool instance)
]]
function UniversalModule.EquipTool(toolName)
    local character = player.Character
    if not character then return false end
    
    local tool
    
    if typeof(toolName) == "Instance" and toolName:IsA("Tool") then
        tool = toolName
    else
        tool = player.Backpack:FindFirstChild(toolName)
    end
    
    if tool then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(tool)
            return true
        end
    end
    
    return false
end

--[[
    UnequipTools - Unequips all tools
]]
function UniversalModule.UnequipTools()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:UnequipTools()
    end
end

--[[
    UseTool - Activates currently equipped tool
]]
function UniversalModule.UseTool()
    local character = player.Character
    if not character then return false end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
        return true
    end
    
    return false
end

--[[
    EquipAndUseTool - Equips and uses a tool
    
    @param toolName - Tool name
    @param duration - How long to use (optional)
]]
function UniversalModule.EquipAndUseTool(toolName, duration)
    if UniversalModule.EquipTool(toolName) then
        task.wait(0.1)
        
        local character = player.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        
        if tool then
            tool:Activate()
            
            if duration then
                task.wait(duration)
                tool:Deactivate()
            end
            
            return true
        end
    end
    
    return false
end

--[[
    ========================================
    REMOTE EVENTS/FUNCTIONS
    ========================================
]]

--[[
    FireRemote - Fires a RemoteEvent or RemoteFunction
    
    @param remote - RemoteEvent or RemoteFunction
    @param args - Arguments to pass (table)
]]
function UniversalModule.FireRemote(remote, ...)
    if not remote then
        warn("UniversalModule: Invalid remote")
        return nil
    end
    
    if remote:IsA("RemoteEvent") then
        remote:FireServer(...)
        return true
    elseif remote:IsA("RemoteFunction") then
        return remote:InvokeServer(...)
    end
    
    return nil
end

--[[
    FindAndFireRemote - Finds and fires a remote by name
    
    @param remoteName - Name to search for
    @param args - Arguments to pass
]]
function UniversalModule.FindAndFireRemote(remoteName, ...)
    local remote = game:GetDescendants()
    
    for _, obj in pairs(remote) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and obj.Name == remoteName then
            return UniversalModule.FireRemote(obj, ...)
        end
    end
    
    return false
end

--[[
    ========================================
    UTILITY FUNCTIONS
    ========================================
]]

--[[
    WaitForChild - Safe WaitForChild with timeout
    
    @param parent - Parent instance
    @param childName - Child name
    @param timeout - Timeout in seconds (default 5)
]]
function UniversalModule.WaitForChild(parent, childName, timeout)
    timeout = timeout or 5
    local startTime = tick()
    
    while not parent:FindFirstChild(childName) do
        if tick() - startTime > timeout then
            return nil
        end
        task.wait()
    end
    
    return parent:FindFirstChild(childName)
end

--[[
    IsInGame - Check if player is fully loaded
]]
function UniversalModule.IsInGame()
    return player.Character 
        and player.Character:FindFirstChild("HumanoidRootPart") 
        and player.Character:FindFirstChildOfClass("Humanoid")
end

--[[
    GetClosestObject - Find closest object from a table
    
    @param objects - Table of instances with Position
    @param maxDistance - Maximum distance (optional)
]]
function UniversalModule.GetClosestObject(objects, maxDistance)
    local character = player.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local closest = nil
    local closestDist = maxDistance or math.huge
    
    for _, obj in pairs(objects) do
        local pos = obj.Position or (obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position)
        
        if pos then
            local dist = (rootPart.Position - pos).Magnitude
            
            if dist < closestDist then
                closest = obj
                closestDist = dist
            end
        end
    end
    
    return closest, closestDist
end

--[[
    RandomWait - Wait a random amount of time (humanization)
    
    @param min - Minimum wait time
    @param max - Maximum wait time
]]
function UniversalModule.RandomWait(min, max)
    local waitTime = math.random(min * 100, max * 100) / 100
    task.wait(waitTime)
end

return UniversalModule
