--[[
    LoopManager.lua
    Advanced loop management system for controlling multiple loops
    
    Features:
    - Start/Stop/Pause/Resume loops
    - Named loops for easy management
    - Priority system
    - Error handling
    - Performance monitoring
    - Conditional loops
    
    Usage:
        local LoopManager = require(game.ReplicatedStorage.LoopManager)
        
        LoopManager.CreateLoop("FarmLoop", function()
            print("Farming...")
        end, {Interval = 1, Priority = 1})
        
        LoopManager.Start("FarmLoop")
        LoopManager.Stop("FarmLoop")
]]

local RunService = game:GetService("RunService")

local LoopManager = {}

-- Store all loops
local loops = {}
local loopThreads = {}
local loopStats = {}

--[[
    ========================================
    LOOP CREATION & MANAGEMENT
    ========================================
]]

--[[
    CreateLoop - Creates a new managed loop
    
    @param name - Unique loop identifier
    @param func - Function to execute
    @param options - Optional table:
        - Interval: number (seconds between executions, default 1)
        - Priority: number (higher = executes first, default 0)
        - Enabled: boolean (auto-start, default false)
        - Condition: function (return true to continue, optional)
        - OnError: function (error handler, optional)
        - MaxIterations: number (stop after N iterations, optional)
        - UseHeartbeat: boolean (use Heartbeat instead of wait, default false)
]]
function LoopManager.CreateLoop(name, func, options)
    if loops[name] then
        warn("LoopManager: Loop '" .. name .. "' already exists")
        return false
    end
    
    options = options or {}
    
    loops[name] = {
        name = name,
        func = func,
        interval = options.Interval or 1,
        priority = options.Priority or 0,
        enabled = options.Enabled or false,
        condition = options.Condition,
        onError = options.OnError,
        maxIterations = options.MaxIterations,
        useHeartbeat = options.UseHeartbeat or false,
        paused = false,
        iterations = 0,
        lastRunTime = 0,
        totalRunTime = 0
    }
    
    loopStats[name] = {
        executions = 0,
        errors = 0,
        avgExecutionTime = 0,
        totalExecutionTime = 0,
        lastError = nil
    }
    
    if options.Enabled then
        LoopManager.Start(name)
    end
    
    return true
end

--[[
    Start - Starts a loop
    
    @param name - Loop name
]]
function LoopManager.Start(name)
    local loop = loops[name]
    if not loop then
        warn("LoopManager: Loop '" .. name .. "' not found")
        return false
    end
    
    if loop.enabled then
        warn("LoopManager: Loop '" .. name .. "' already running")
        return false
    end
    
    loop.enabled = true
    loop.paused = false
    loop.iterations = 0
    
    -- Create thread for this loop
    loopThreads[name] = task.spawn(function()
        while loop.enabled do
            -- Check if paused
            if not loop.paused then
                -- Check condition
                if loop.condition and not loop.condition() then
                    task.wait(loop.interval)
                    continue
                end
                
                -- Check max iterations
                if loop.maxIterations and loop.iterations >= loop.maxIterations then
                    LoopManager.Stop(name)
                    break
                end
                
                -- Execute function
                local startTime = tick()
                local success, errorMsg = pcall(loop.func)
                local executionTime = tick() - startTime
                
                -- Update stats
                loop.iterations = loop.iterations + 1
                loop.lastRunTime = executionTime
                loop.totalRunTime = loop.totalRunTime + executionTime
                
                local stats = loopStats[name]
                stats.executions = stats.executions + 1
                stats.totalExecutionTime = stats.totalExecutionTime + executionTime
                stats.avgExecutionTime = stats.totalExecutionTime / stats.executions
                
                -- Handle errors
                if not success then
                    stats.errors = stats.errors + 1
                    stats.lastError = errorMsg
                    
                    if loop.onError then
                        loop.onError(errorMsg)
                    else
                        warn("LoopManager: Error in loop '" .. name .. "':", errorMsg)
                    end
                end
            end
            
            -- Wait for interval
            if loop.useHeartbeat then
                RunService.Heartbeat:Wait()
            else
                task.wait(loop.interval)
            end
        end
    end)
    
    return true
end

--[[
    Stop - Stops a loop
    
    @param name - Loop name
]]
function LoopManager.Stop(name)
    local loop = loops[name]
    if not loop then
        warn("LoopManager: Loop '" .. name .. "' not found")
        return false
    end
    
    loop.enabled = false
    loop.paused = false
    
    if loopThreads[name] then
        task.cancel(loopThreads[name])
        loopThreads[name] = nil
    end
    
    return true
end

--[[
    Pause - Pauses a loop (keeps thread alive)
    
    @param name - Loop name
]]
function LoopManager.Pause(name)
    local loop = loops[name]
    if not loop then
        warn("LoopManager: Loop '" .. name .. "' not found")
        return false
    end
    
    if not loop.enabled then
        warn("LoopManager: Loop '" .. name .. "' is not running")
        return false
    end
    
    loop.paused = true
    return true
end

--[[
    Resume - Resumes a paused loop
    
    @param name - Loop name
]]
function LoopManager.Resume(name)
    local loop = loops[name]
    if not loop then
        warn("LoopManager: Loop '" .. name .. "' not found")
        return false
    end
    
    if not loop.enabled then
        warn("LoopManager: Loop '" .. name .. "' is not running")
        return false
    end
    
    loop.paused = false
    return true
end

--[[
    Remove - Completely removes a loop
    
    @param name - Loop name
]]
function LoopManager.Remove(name)
    LoopManager.Stop(name)
    loops[name] = nil
    loopStats[name] = nil
    return true
end

--[[
    ========================================
    BULK OPERATIONS
    ========================================
]]

--[[
    StartAll - Starts all loops
]]
function LoopManager.StartAll()
    for name, _ in pairs(loops) do
        LoopManager.Start(name)
    end
end

--[[
    StopAll - Stops all loops
]]
function LoopManager.StopAll()
    for name, _ in pairs(loops) do
        LoopManager.Stop(name)
    end
end

--[[
    PauseAll - Pauses all running loops
]]
function LoopManager.PauseAll()
    for name, loop in pairs(loops) do
        if loop.enabled then
            LoopManager.Pause(name)
        end
    end
end

--[[
    ResumeAll - Resumes all paused loops
]]
function LoopManager.ResumeAll()
    for name, loop in pairs(loops) do
        if loop.enabled and loop.paused then
            LoopManager.Resume(name)
        end
    end
end

--[[
    RemoveAll - Removes all loops
]]
function LoopManager.RemoveAll()
    for name, _ in pairs(loops) do
        LoopManager.Remove(name)
    end
end

--[[
    ========================================
    QUERY & STATUS
    ========================================
]]

--[[
    IsRunning - Check if a loop is running
    
    @param name - Loop name
    @return boolean
]]
function LoopManager.IsRunning(name)
    local loop = loops[name]
    return loop and loop.enabled and not loop.paused
end

--[[
    IsPaused - Check if a loop is paused
    
    @param name - Loop name
    @return boolean
]]
function LoopManager.IsPaused(name)
    local loop = loops[name]
    return loop and loop.enabled and loop.paused
end

--[[
    Exists - Check if a loop exists
    
    @param name - Loop name
    @return boolean
]]
function LoopManager.Exists(name)
    return loops[name] ~= nil
end

--[[
    GetStatus - Get detailed loop status
    
    @param name - Loop name
    @return table - {enabled, paused, iterations, lastRunTime, etc}
]]
function LoopManager.GetStatus(name)
    local loop = loops[name]
    if not loop then return nil end
    
    return {
        name = loop.name,
        enabled = loop.enabled,
        paused = loop.paused,
        iterations = loop.iterations,
        lastRunTime = loop.lastRunTime,
        totalRunTime = loop.totalRunTime,
        priority = loop.priority,
        interval = loop.interval
    }
end

--[[
    GetStats - Get performance statistics
    
    @param name - Loop name
    @return table - {executions, errors, avgExecutionTime, etc}
]]
function LoopManager.GetStats(name)
    return loopStats[name]
end

--[[
    GetAllLoops - Get list of all loop names
    
    @return table - Array of loop names
]]
function LoopManager.GetAllLoops()
    local names = {}
    for name, _ in pairs(loops) do
        table.insert(names, name)
    end
    return names
end

--[[
    GetRunningLoops - Get list of running loop names
    
    @return table - Array of running loop names
]]
function LoopManager.GetRunningLoops()
    local running = {}
    for name, loop in pairs(loops) do
        if loop.enabled and not loop.paused then
            table.insert(running, name)
        end
    end
    return running
end

--[[
    ========================================
    CONFIGURATION
    ========================================
]]

--[[
    SetInterval - Change loop interval
    
    @param name - Loop name
    @param interval - New interval in seconds
]]
function LoopManager.SetInterval(name, interval)
    local loop = loops[name]
    if loop then
        loop.interval = interval
        return true
    end
    return false
end

--[[
    SetPriority - Change loop priority
    
    @param name - Loop name
    @param priority - New priority
]]
function LoopManager.SetPriority(name, priority)
    local loop = loops[name]
    if loop then
        loop.priority = priority
        return true
    end
    return false
end

--[[
    SetCondition - Change loop condition
    
    @param name - Loop name
    @param condition - Function that returns boolean
]]
function LoopManager.SetCondition(name, condition)
    local loop = loops[name]
    if loop then
        loop.condition = condition
        return true
    end
    return false
end

--[[
    ========================================
    ADVANCED FEATURES
    ========================================
]]

--[[
    CreateTimedLoop - Create a loop that runs for a specific duration
    
    @param name - Loop name
    @param func - Function to execute
    @param duration - How long to run (seconds)
    @param interval - Interval between executions
]]
function LoopManager.CreateTimedLoop(name, func, duration, interval)
    local startTime = tick()
    
    return LoopManager.CreateLoop(name, func, {
        Interval = interval or 1,
        Condition = function()
            return (tick() - startTime) < duration
        end,
        Enabled = true
    })
end

--[[
    CreateConditionalLoop - Create a loop that runs until condition is false
    
    @param name - Loop name
    @param func - Function to execute
    @param condition - Function that returns boolean
    @param interval - Interval between executions
]]
function LoopManager.CreateConditionalLoop(name, func, condition, interval)
    return LoopManager.CreateLoop(name, func, {
        Interval = interval or 1,
        Condition = condition,
        Enabled = true
    })
end

--[[
    CreateCountLoop - Create a loop that runs N times
    
    @param name - Loop name
    @param func - Function to execute
    @param count - Number of iterations
    @param interval - Interval between executions
]]
function LoopManager.CreateCountLoop(name, func, count, interval)
    return LoopManager.CreateLoop(name, func, {
        Interval = interval or 1,
        MaxIterations = count,
        Enabled = true
    })
end

--[[
    CreateHeartbeatLoop - Create a loop that runs every frame
    
    @param name - Loop name
    @param func - Function to execute
]]
function LoopManager.CreateHeartbeatLoop(name, func)
    return LoopManager.CreateLoop(name, func, {
        Interval = 0,
        UseHeartbeat = true,
        Enabled = true
    })
end

--[[
    ========================================
    UTILITIES
    ========================================
]]

--[[
    ResetStats - Reset statistics for a loop
    
    @param name - Loop name
]]
function LoopManager.ResetStats(name)
    if loopStats[name] then
        loopStats[name] = {
            executions = 0,
            errors = 0,
            avgExecutionTime = 0,
            totalExecutionTime = 0,
            lastError = nil
        }
        return true
    end
    return false
end

--[[
    PrintStatus - Print status of all loops
]]
function LoopManager.PrintStatus()
    print("=== Loop Manager Status ===")
    for name, loop in pairs(loops) do
        local status = loop.enabled and (loop.paused and "PAUSED" or "RUNNING") or "STOPPED"
        local stats = loopStats[name]
        
        print(string.format(
            "[%s] %s | Interval: %.2fs | Iterations: %d | Avg Time: %.4fs | Errors: %d",
            status,
            name,
            loop.interval,
            loop.iterations,
            stats.avgExecutionTime,
            stats.errors
        ))
    end
    print("==========================")
end

--[[
    GetTotalStats - Get combined stats for all loops
    
    @return table - Combined statistics
]]
function LoopManager.GetTotalStats()
    local total = {
        totalLoops = 0,
        runningLoops = 0,
        pausedLoops = 0,
        totalExecutions = 0,
        totalErrors = 0
    }
    
    for name, loop in pairs(loops) do
        total.totalLoops = total.totalLoops + 1
        
        if loop.enabled then
            if loop.paused then
                total.pausedLoops = total.pausedLoops + 1
            else
                total.runningLoops = total.runningLoops + 1
            end
        end
        
        local stats = loopStats[name]
        total.totalExecutions = total.totalExecutions + stats.executions
        total.totalErrors = total.totalErrors + stats.errors
    end
    
    return total
end

return LoopManager
