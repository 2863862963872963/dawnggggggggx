--[[
    MovementModule with Blacklist Avoidance
    Tránh các vật cản trong blacklist khi di chuyển
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local MovementModule = {}

-- Store active movements
local activeWalks = {}

-- Blacklist settings
local blacklist = {
    parts = {},      -- Specific parts to avoid
    names = {},      -- Part names to avoid
    models = {},     -- Specific models to avoid
    classes = {},    -- Class names to avoid (e.g., "TrussPart")
    materials = {},  -- Materials to avoid (e.g., Enum.Material.Lava)
    tags = {}        -- CollectionService tags to avoid
}

local avoidanceDistance = 5 -- Distance to keep from blacklisted objects

--[[
    ========================================
    BLACKLIST MANAGEMENT
    ========================================
]]

--[[
    AddToBlacklist - Adds an object or pattern to blacklist
    
    @param item - Part, Model, string (name), Enum (material), etc.
    @param type - "part", "name", "model", "class", "material", "tag" (auto-detect if nil)
]]
function MovementModule.AddToBlacklist(item, type)
    if not type then
        -- Auto-detect type
        if typeof(item) == "Instance" then
            if item:IsA("Model") then
                type = "model"
            else
                type = "part"
            end
        elseif typeof(item) == "string" then
            type = "name"
        elseif typeof(item) == "EnumItem" then
            type = "material"
        end
    end
    
    if type == "part" then
        table.insert(blacklist.parts, item)
    elseif type == "name" then
        table.insert(blacklist.names, item)
    elseif type == "model" then
        table.insert(blacklist.models, item)
    elseif type == "class" then
        table.insert(blacklist.classes, item)
    elseif type == "material" then
        table.insert(blacklist.materials, item)
    elseif type == "tag" then
        table.insert(blacklist.tags, item)
    end
end

--[[
    RemoveFromBlacklist - Removes from blacklist
    
    @param item - Item to remove
    @param type - Blacklist type
]]
function MovementModule.RemoveFromBlacklist(item, type)
    local list = blacklist[type .. "s"] or blacklist[type]
    
    if list then
        for i, v in pairs(list) do
            if v == item then
                table.remove(list, i)
                return true
            end
        end
    end
    
    return false
end

--[[
    ClearBlacklist - Clears entire blacklist or specific type
    
    @param type - Optional type to clear (nil = clear all)
]]
function MovementModule.ClearBlacklist(type)
    if type then
        blacklist[type .. "s"] = {}
    else
        blacklist = {
            parts = {},
            names = {},
            models = {},
            classes = {},
            materials = {},
            tags = {}
        }
    end
end

--[[
    SetAvoidanceDistance - Sets how far to stay from blacklisted objects
    
    @param distance - Distance in studs
]]
function MovementModule.SetAvoidanceDistance(distance)
    avoidanceDistance = distance
end

--[[
    IsBlacklisted - Checks if a part is blacklisted
    
    @param part - Part to check
    @return boolean
]]
function MovementModule.IsBlacklisted(part)
    if not part or not part:IsA("BasePart") then
        return false
    end
    
    -- Check specific parts
    for _, blacklistedPart in pairs(blacklist.parts) do
        if part == blacklistedPart then
            return true
        end
    end
    
    -- Check names
    for _, name in pairs(blacklist.names) do
        if part.Name:lower():match(name:lower()) then
            return true
        end
    end
    
    -- Check parent models
    local model = part.Parent
    if model and model:IsA("Model") then
        for _, blacklistedModel in pairs(blacklist.models) do
            if model == blacklistedModel then
                return true
            end
        end
    end
    
    -- Check class
    for _, className in pairs(blacklist.classes) do
        if part:IsA(className) then
            return true
        end
    end
    
    -- Check material
    for _, material in pairs(blacklist.materials) do
        if part.Material == material then
            return true
        end
    end
    
    -- Check tags (CollectionService)
    local CollectionService = game:GetService("CollectionService")
    for _, tag in pairs(blacklist.tags) do
        if CollectionService:HasTag(part, tag) then
            return true
        end
    end
    
    return false
end

--[[
    ========================================
    AVOIDANCE DETECTION
    ========================================
]]

--[[
    GetNearbyBlacklistedObjects - Gets blacklisted objects near a position
    
    @param position - Vector3 position
    @param radius - Search radius
    @return table - Array of {part, distance}
]]
function MovementModule.GetNearbyBlacklistedObjects(position, radius)
    radius = radius or avoidanceDistance * 2
    local nearby = {}
    
    local region = Region3.new(
        position - Vector3.new(radius, radius, radius),
        position + Vector3.new(radius, radius, radius)
    )
    region = region:ExpandToGrid(4)
    
    local parts = workspace:FindPartsInRegion3(region, nil, math.huge)
    
    for _, part in pairs(parts) do
        if MovementModule.IsBlacklisted(part) then
            local distance = (part.Position - position).Magnitude
            
            if distance <= radius then
                table.insert(nearby, {
                    part = part,
                    distance = distance
                })
            end
        end
    end
    
    -- Sort by distance
    table.sort(nearby, function(a, b)
        return a.distance < b.distance
    end)
    
    return nearby
end

--[[
    IsSafePosition - Checks if a position is safe (no blacklisted objects nearby)
    
    @param position - Vector3 position
    @param checkRadius - Optional radius (default: avoidanceDistance)
    @return boolean, table - isSafe, nearbyThreats
]]
function MovementModule.IsSafePosition(position, checkRadius)
    checkRadius = checkRadius or avoidanceDistance
    local nearby = MovementModule.GetNearbyBlacklistedObjects(position, checkRadius)
    
    return #nearby == 0, nearby
end

--[[
    GetSafeDirection - Gets a safe direction away from blacklisted objects
    
    @param position - Current position
    @param targetDirection - Desired direction (Unit vector)
    @return Vector3 - Safe direction (or original if safe)
]]
function MovementModule.GetSafeDirection(position, targetDirection)
    local nearby = MovementModule.GetNearbyBlacklistedObjects(position, avoidanceDistance * 2)
    
    if #nearby == 0 then
        return targetDirection
    end
    
    -- Calculate avoidance vector
    local avoidanceVector = Vector3.new(0, 0, 0)
    
    for _, threat in pairs(nearby) do
        local directionAway = (position - threat.part.Position).Unit
        local strength = 1 - (threat.distance / (avoidanceDistance * 2))
        
        avoidanceVector = avoidanceVector + (directionAway * strength)
    end
    
    -- Blend target direction with avoidance
    local blendedDirection = (targetDirection + avoidanceVector).Unit
    
    return blendedDirection
end

--[[
    ========================================
    WALKING WITH AVOIDANCE
    ========================================
]]

--[[
    WalkTo - Walks to position while avoiding blacklisted objects
    
    @param character - Character model
    @param targetPosition - Vector3 destination
    @param options - Optional table:
        - Timeout: number
        - StopDistance: number
        - AvoidBlacklist: boolean (default true)
        - StuckThreshold: number
        - AutoRetry: boolean
        - OnReached: function()
        - OnFailed: function()
        - OnStuck: function()
        - OnAvoidance: function(threat) - Called when avoiding
]]
function MovementModule.WalkTo(character, targetPosition, options)
    options = options or {}
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        warn("MovementModule: Missing Humanoid or HumanoidRootPart")
        if options.OnFailed then
            options.OnFailed("Missing components")
        end
        return false
    end
    
    MovementModule.StopWalk(character)
    
    local walkData = {
        cancelled = false,
        startTime = tick(),
        timeout = options.Timeout,
        lastPosition = rootPart.Position,
        stuckTime = 0,
        stuckThreshold = options.StuckThreshold or 3,
        stopDistance = options.StopDistance or 4,
        autoRetry = options.AutoRetry ~= false,
        avoidBlacklist = options.AvoidBlacklist ~= false
    }
    activeWalks[character] = walkData
    
    humanoid:MoveTo(targetPosition)
    
    task.spawn(function()
        local moveConnection
        local timeoutConnection
        
        -- Timeout handler
        if walkData.timeout then
            timeoutConnection = task.delay(walkData.timeout, function()
                if activeWalks[character] == walkData then
                    activeWalks[character] = nil
                    
                    if moveConnection then
                        moveConnection:Disconnect()
                    end
                    
                    if options.OnTimeout then
                        options.OnTimeout()
                    end
                end
            end)
        end
        
        -- Movement completion
        moveConnection = humanoid.MoveToFinished:Connect(function(reached)
            if activeWalks[character] ~= walkData then
                return
            end
            
            activeWalks[character] = nil
            
            if timeoutConnection then
                task.cancel(timeoutConnection)
            end
            
            moveConnection:Disconnect()
            
            if reached then
                if options.OnReached then
                    options.OnReached()
                end
            else
                if options.OnFailed then
                    options.OnFailed("Did not reach destination")
                end
            end
        end)
        
        -- Main loop with avoidance
        local lastCheckTime = tick()
        
        while activeWalks[character] == walkData and rootPart do
            local currentPos = rootPart.Position
            local distance = (currentPos - targetPosition).Magnitude
            
            -- Check if reached
            if distance <= walkData.stopDistance then
                activeWalks[character] = nil
                
                if moveConnection then
                    moveConnection:Disconnect()
                end
                if timeoutConnection then
                    task.cancel(timeoutConnection)
                end
                
                if options.OnReached then
                    options.OnReached()
                end
                break
            end
            
            -- Blacklist avoidance
            if walkData.avoidBlacklist then
                local isSafe, threats = MovementModule.IsSafePosition(currentPos, avoidanceDistance)
                
                if not isSafe then
                    -- Get safe direction
                    local targetDirection = (targetPosition - currentPos).Unit
                    local safeDirection = MovementModule.GetSafeDirection(currentPos, targetDirection)
                    
                    -- Move in safe direction
                    local safePosition = currentPos + (safeDirection * 10)
                    humanoid:MoveTo(safePosition)
                    
                    if options.OnAvoidance then
                        options.OnAvoidance(threats[1])
                    end
                else
                    -- Re-target if we diverted
                    humanoid:MoveTo(targetPosition)
                end
            end
            
            -- Stuck detection
            local timeDelta = tick() - lastCheckTime
            local positionDelta = (currentPos - walkData.lastPosition).Magnitude
            
            if positionDelta < 0.5 then
                walkData.stuckTime = walkData.stuckTime + timeDelta
                
                if walkData.stuckTime >= walkData.stuckThreshold then
                    if walkData.autoRetry then
                        humanoid.Jump = true
                        task.wait(0.5)
                        humanoid:MoveTo(targetPosition)
                        walkData.stuckTime = 0
                    else
                        activeWalks[character] = nil
                        
                        if moveConnection then
                            moveConnection:Disconnect()
                        end
                        if timeoutConnection then
                            task.cancel(timeoutConnection)
                        end
                        
                        if options.OnStuck then
                            options.OnStuck()
                        elseif options.OnFailed then
                            options.OnFailed("Character stuck")
                        end
                        break
                    end
                end
            else
                walkData.stuckTime = 0
            end
            
            walkData.lastPosition = currentPos
            lastCheckTime = tick()
            
            task.wait(0.3)
        end
    end)
    
    return true
end

--[[
    StopWalk - Stops walking
]]
function MovementModule.StopWalk(character)
    if activeWalks[character] then
        activeWalks[character].cancelled = true
        activeWalks[character] = nil
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        humanoid:MoveTo(rootPart.Position)
    end
end

--[[
    IsWalking - Check if walking
]]
function MovementModule.IsWalking(character)
    return activeWalks[character] ~= nil
end

--[[
    GetDistance - Get distance to target
]]
function MovementModule.GetDistance(character, target)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local targetPos
    
    if typeof(target) == "Vector3" then
        targetPos = target
    elseif typeof(target) == "Instance" then
        if target:IsA("Model") then
            local targetPart = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart")
            targetPos = targetPart and targetPart.Position
        elseif target:IsA("BasePart") then
            targetPos = target.Position
        end
    end
    
    if targetPos then
        return (rootPart.Position - targetPos).Magnitude
    end
    
    return nil
end

return MovementModule
