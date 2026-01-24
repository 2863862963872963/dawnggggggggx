--[[
    MovementModule.lua
    Comprehensive movement system with pathfinding, tweening, and teleportation
    
    Usage:
        local MovementModule = require(game.ReplicatedStorage.MovementModule)
        MovementModule.PathfindTo(character, targetPosition, options)
        MovementModule.TweenTo(character, targetPosition, options)
        MovementModule.Teleport(character, targetPosition, options)
]]

local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

local MovementModule = {}

-- Store active movements per character
local activeMovements = {}

-- Helper to clone options so we don't modify the user's table
local function cloneTable(t)
    local new = {}
    if t then
        for k, v in pairs(t) do new[k] = v end
    end
    return new
end

--[[
    ========================================
    PATHFINDING MOVEMENT
    ========================================
]]

--[[
    PathfindTo - Moves a character using pathfinding with obstacle avoidance
    
    @param character - Model with Humanoid and HumanoidRootPart
    @param targetPosition - Vector3 destination
    @param options - Optional table with:
        - Costs: table of cost values {Water = 10, Lava = math.huge}
        - AgentRadius: number (default 2)
        - AgentHeight: number (default 5)
        - AgentCanJump: boolean (default true)
        - AgentCanClimb: boolean (default false)
        - WaypointSpacing: number (default 4)
        - OnWaypoint: function(index, waypoint, total)
        - OnComplete: function()
        - OnFailed: function(reason)
        - MaxRetries: number (default 3) -- New option to prevent infinite loops
    
    @return boolean - true if path completed, false if failed/cancelled
]]
function MovementModule.PathfindTo(character, targetPosition, options)
    -- Clone options to safely track internal state like retries
    options = cloneTable(options)
    options.Retries = options.Retries or 0
    local maxRetries = options.MaxRetries or 3
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        warn("MovementModule: Character missing Humanoid or HumanoidRootPart")
        if options.OnFailed then 
            options.OnFailed("Missing character components") 
        end
        return false
    end
    
    -- Check if character is dead
    if humanoid.Health <= 0 then
        if options.OnFailed then options.OnFailed("Character is dead") end
        return false
    end
    
    -- Cancel any existing movement for this character
    MovementModule.Stop(character)
    
    -- Create new movement tracker
    local movementData = {
        cancelled = false,
        startTime = tick(),
        type = "pathfind"
    }
    activeMovements[character] = movementData
    
    -- Create path with parameters
    local path = PathfindingService:CreatePath({
        AgentRadius = options.AgentRadius or 2,
        AgentHeight = options.AgentHeight or 5,
        AgentCanJump = options.AgentCanJump ~= false,
        AgentCanClimb = options.AgentCanClimb or false,
        WaypointSpacing = options.WaypointSpacing or 4,
        Costs = options.Costs or {}
    })
    
    -- Compute path
    local success, errorMessage = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)
    
    if not success then
        warn("MovementModule: Path computation error:", errorMessage)
        activeMovements[character] = nil
        if options.OnFailed then 
            options.OnFailed(errorMessage) 
        end
        return false
    end
    
    if path.Status ~= Enum.PathStatus.Success then
        -- Don't retry immediately if no path found, just fail
        warn("MovementModule: No valid path found")
        activeMovements[character] = nil
        if options.OnFailed then 
            options.OnFailed("No valid path") 
        end
        return false
    end
    
    local waypoints = path:GetWaypoints()
    
    -- Handle path blocked (recompute if blocked)
    local blockedConnection
    blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)
        if movementData.cancelled then
            blockedConnection:Disconnect()
            return
        end
        
        -- Path blocked, attempt to recompute
        blockedConnection:Disconnect()
        
        -- Check retry limit for blocked paths too
        if options.Retries >= maxRetries then
            if options.OnFailed then options.OnFailed("Path blocked and max retries exceeded") end
            return
        end
        
        options.Retries = options.Retries + 1
        MovementModule.PathfindTo(character, targetPosition, options)
    end)
    
    -- Move through waypoints
    for i, waypoint in pairs(waypoints) do
        -- Check if movement was cancelled
        if movementData.cancelled then
            blockedConnection:Disconnect()
            return false
        end
        
        -- Check if character died during movement
        if humanoid.Health <= 0 then
            blockedConnection:Disconnect()
            return false
        end
        
        -- Handle jump waypoints
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        
        -- Move to waypoint
        humanoid:MoveTo(waypoint.Position)
        
        -- Callback for each waypoint
        if options.OnWaypoint then
            options.OnWaypoint(i, waypoint, #waypoints)
        end
        
        -- Wait for movement to complete
        -- FIX: Removed incorrect timeout argument '1'
        local reachedWaypoint = humanoid.MoveToFinished:Wait()
        
        -- Check again after waiting
        if movementData.cancelled then
            blockedConnection:Disconnect()
            return false
        end
        
        -- If stuck or interrupted (e.g. player walked), try to recompute path
        if not reachedWaypoint then
            blockedConnection:Disconnect()
            
            -- FIX: Infinite recursion check
            if options.Retries >= maxRetries then
                warn("MovementModule: Movement failed (Max retries exceeded)")
                activeMovements[character] = nil
                if options.OnFailed then
                    options.OnFailed("Interrupted or Stuck")
                end
                return false
            end
            
            -- Add a small delay to prevent hot loops if the player is holding a key
            task.wait(0.2)
            
            -- Increase retry count and recurse
            options.Retries = options.Retries + 1
            return MovementModule.PathfindTo(character, targetPosition, options)
        end
    end
    
    -- Clean up
    blockedConnection:Disconnect()
    activeMovements[character] = nil
    
    -- Success callback
    if options.OnComplete then
        options.OnComplete()
    end
    
    return true
end

--[[
    ========================================
    TWEEN MOVEMENT
    ========================================
]]

--[[
    TweenTo - Smoothly tweens a character to a position (ignores obstacles)
    
    @param character - Model with HumanoidRootPart
    @param targetPosition - Vector3 destination OR CFrame
    @param options - Optional table with:
        - Duration: number (default 1)
        - EasingStyle: Enum.EasingStyle (default Linear)
        - EasingDirection: Enum.EasingDirection (default Out)
        - RotateToTarget: boolean (default false) - face the target
        - TargetOrientation: CFrame (optional) - specific rotation
        - OnComplete: function()
        - OnCancelled: function()
    
    @return Tween - the tween instance (can be used to cancel)
]]
function MovementModule.TweenTo(character, target, options)
    options = options or {}
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then
        warn("MovementModule: Character missing HumanoidRootPart")
        return nil
    end
    
    -- Cancel any existing movement
    MovementModule.Stop(character)
    
    -- Determine target CFrame
    local targetCFrame
    if typeof(target) == "Vector3" then
        if options.RotateToTarget then
            -- Face the target direction
            local direction = (target - rootPart.Position).Unit
            -- Prevent NaN if target is same as current position
            if direction.Magnitude > 0 then
                targetCFrame = CFrame.new(target, target + direction)
            else
                targetCFrame = CFrame.new(target) * (rootPart.CFrame - rootPart.CFrame.Position)
            end
        elseif options.TargetOrientation then
            targetCFrame = options.TargetOrientation
        else
            -- Keep current rotation
            targetCFrame = CFrame.new(target) * (rootPart.CFrame - rootPart.CFrame.Position)
        end
    elseif typeof(target) == "CFrame" then
        targetCFrame = target
    else
        warn("MovementModule: Invalid target type, must be Vector3 or CFrame")
        return nil
    end
    
    -- Create tween info
    local tweenInfo = TweenInfo.new(
        options.Duration or 1,
        options.EasingStyle or Enum.EasingStyle.Linear,
        options.EasingDirection or Enum.EasingDirection.Out,
        0, -- RepeatCount
        false, -- Reverses
        0 -- DelayTime
    )
    
    -- Create tween
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    
    -- Track movement
    local movementData = {
        cancelled = false,
        startTime = tick(),
        type = "tween",
        tween = tween
    }
    activeMovements[character] = movementData
    
    -- Handle completion
    tween.Completed:Connect(function(playbackState)
        if activeMovements[character] == movementData then
            activeMovements[character] = nil
        end
        
        if playbackState == Enum.PlaybackState.Completed then
            if options.OnComplete then
                options.OnComplete()
            end
        elseif playbackState == Enum.PlaybackState.Cancelled then
            if options.OnCancelled then
                options.OnCancelled()
            end
        end
    end)
    
    -- Play tween
    tween:Play()
    
    return tween
end

--[[
    TweenModel - Tweens an entire model (not just HumanoidRootPart)
    Useful for moving platforms, vehicles, etc.
    
    @param model - Model to tween
    @param targetCFrame - CFrame destination
    @param options - Same as TweenTo
]]
function MovementModule.TweenModel(model, targetCFrame, options)
    options = options or {}
    
    local primaryPart = model.PrimaryPart
    if not primaryPart then
        warn("MovementModule: Model has no PrimaryPart set")
        return nil
    end
    
    -- Create tween info
    local tweenInfo = TweenInfo.new(
        options.Duration or 1,
        options.EasingStyle or Enum.EasingStyle.Linear,
        options.EasingDirection or Enum.EasingDirection.Out
    )
    
    -- Tween using PivotTo for smooth model movement
    local tween = TweenService:Create(primaryPart, tweenInfo, {CFrame = targetCFrame})
    
    tween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            if options.OnComplete then
                options.OnComplete()
            end
        end
    end)
    
    tween:Play()
    return tween
end

--[[
    ========================================
    TELEPORTATION
    ========================================
]]

--[[
    Teleport - Instantly teleports a character to a position
    
    @param character - Model with HumanoidRootPart
    @param target - Vector3 or CFrame destination
    @param options - Optional table with:
        - PreserveMomentum: boolean (default false)
        - FadeEffect: boolean (default false)
        - FadeDuration: number (default 0.3)
        - Sound: Sound instance or sound ID
        - OnComplete: function()
    
    @return boolean - success
]]
function MovementModule.Teleport(character, target, options)
    options = options or {}
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not rootPart then
        warn("MovementModule: Character missing HumanoidRootPart")
        return false
    end
    
    -- Cancel any existing movement
    MovementModule.Stop(character)
    
    -- Store velocity if preserving momentum
    local velocity = nil
    if options.PreserveMomentum and rootPart:IsA("BasePart") then
        velocity = rootPart.AssemblyLinearVelocity
    end
    
    -- Fade effect
    if options.FadeEffect and humanoid then
        local fadeDuration = options.FadeDuration or 0.3
        
        -- Fade out
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                TweenService:Create(part, TweenInfo.new(fadeDuration), {
                    Transparency = 1
                }):Play()
            end
        end
        
        task.wait(fadeDuration)
    end
    
    -- Perform teleport
    if typeof(target) == "Vector3" then
        rootPart.CFrame = CFrame.new(target)
    elseif typeof(target) == "CFrame" then
        rootPart.CFrame = target
    else
        warn("MovementModule: Invalid target type for teleport")
        return false
    end
    
    -- Restore velocity
    if velocity then
        rootPart.AssemblyLinearVelocity = velocity
    end
    
    -- Play sound
    if options.Sound then
        local sound
        if typeof(options.Sound) == "Instance" and options.Sound:IsA("Sound") then
            sound = options.Sound:Clone()
        elseif typeof(options.Sound) == "number" or typeof(options.Sound) == "string" then
            sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://" .. tostring(options.Sound)
        end
        
        if sound then
            sound.Parent = rootPart
            sound:Play()
            game:GetService("Debris"):AddItem(sound, sound.TimeLength + 0.1)
        end
    end
    
    -- Fade back in
    if options.FadeEffect and humanoid then
        local fadeDuration = options.FadeDuration or 0.3
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                local originalTransparency = 0
                if part.Name == "HumanoidRootPart" then
                    originalTransparency = 1
                end
                
                TweenService:Create(part, TweenInfo.new(fadeDuration), {
                    Transparency = originalTransparency
                }):Play()
            elseif part:IsA("Decal") then
                TweenService:Create(part, TweenInfo.new(fadeDuration), {
                    Transparency = 0
                }):Play()
            end
        end
    end
    
    -- Complete callback
    if options.OnComplete then
        options.OnComplete()
    end
    
    return true
end

--[[
    ========================================
    UTILITY FUNCTIONS
    ========================================
]]

--[[
    Stop - Stops any active movement for a character
    
    @param character - The character to stop
]]
function MovementModule.Stop(character)
    if activeMovements[character] then
        local movementData = activeMovements[character]
        movementData.cancelled = true
        
        -- If it's a tween, cancel it
        if movementData.type == "tween" and movementData.tween then
            movementData.tween:Cancel()
        end
        
        activeMovements[character] = nil
    end
    
    -- Stop humanoid movement
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            humanoid:MoveTo(rootPart.Position)
        end
    end
end

--[[
    IsMoving - Check if a character is currently moving
    
    @param character - The character to check
    @return boolean - true if currently moving
]]
function MovementModule.IsMoving(character)
    return activeMovements[character] ~= nil
end

--[[
    GetMovementType - Get the type of movement currently active
    
    @param character - The character to check
    @return string|nil - "pathfind", "tween", or nil
]]
function MovementModule.GetMovementType(character)
    if activeMovements[character] then
        return activeMovements[character].type
    end
    return nil
end

--[[
    GetMovementTime - Get how long a character has been moving
    
    @param character - The character to check
    @return number|nil - seconds elapsed, or nil if not moving
]]
function MovementModule.GetMovementTime(character)
    if activeMovements[character] then
        return tick() - activeMovements[character].startTime
    end
    return nil
end

--[[
    GetDistance - Calculate distance between character and target
    
    @param character - The character
    @param target - Vector3 or Model with PrimaryPart/HumanoidRootPart
    @return number|nil - distance in studs
]]
function MovementModule.GetDistance(character, target)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local targetPos
    if typeof(target) == "Vector3" then
        targetPos = target
    elseif typeof(target) == "Instance" then
        local targetPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("PrimaryPart") or target.PrimaryPart
        if targetPart then
            targetPos = targetPart.Position
        end
    end
    
    if targetPos then
        return (rootPart.Position - targetPos).Magnitude
    end
    
    return nil
end

return MovementModule
