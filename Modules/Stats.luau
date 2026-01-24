--[[
    StatsModule.lua
    Session statistics tracking and analytics
    
    Features:
    - Track any numeric stat
    - Calculate averages, totals, rates
    - Session timing
    - Export/import stats
    - Real-time rate calculation
    
    Usage:
        local Stats = require(game.ReplicatedStorage.StatsModule)
        Stats.Increment("CoinsCollected", 10)
        Stats.Set("Level", 5)
        print(Stats.Get("CoinsCollected")) -- 10
        print(Stats.GetRate("CoinsCollected")) -- coins per hour
]]

local FormatModule = require(script.Parent.FormatModule)

local StatsModule = {}

-- Storage
local stats = {}
local sessionStart = tick()
local snapshots = {}

--[[
    ========================================
    BASIC STAT OPERATIONS
    ========================================
]]

--[[
    Set - Sets a stat value
    
    @param name - Stat name
    @param value - Value to set
]]
function StatsModule.Set(name, value)
    if not stats[name] then
        stats[name] = {
            value = value,
            startValue = value,
            peak = value,
            changes = 0,
            lastChanged = tick()
        }
    else
        stats[name].value = value
        stats[name].changes = stats[name].changes + 1
        stats[name].lastChanged = tick()
        
        if value > stats[name].peak then
            stats[name].peak = value
        end
    end
end

--[[
    Get - Gets a stat value
    
    @param name - Stat name
    @return number - Current value (or 0 if not found)
]]
function StatsModule.Get(name)
    return stats[name] and stats[name].value or 0
end

--[[
    Increment - Increases stat value
    
    @param name - Stat name
    @param amount - Amount to add (default 1)
    @return number - New value
]]
function StatsModule.Increment(name, amount)
    amount = amount or 1
    local current = StatsModule.Get(name)
    StatsModule.Set(name, current + amount)
    return current + amount
end

--[[
    Decrement - Decreases stat value
    
    @param name - Stat name
    @param amount - Amount to subtract (default 1)
    @return number - New value
]]
function StatsModule.Decrement(name, amount)
    amount = amount or 1
    return StatsModule.Increment(name, -amount)
end

--[[
    Reset - Resets a stat to 0
    
    @param name - Stat name
]]
function StatsModule.Reset(name)
    if stats[name] then
        stats[name].value = 0
        stats[name].startValue = 0
        stats[name].lastChanged = tick()
    end
end

--[[
    ResetAll - Resets all stats
]]
function StatsModule.ResetAll()
    for name, _ in pairs(stats) do
        StatsModule.Reset(name)
    end
    sessionStart = tick()
end

--[[
    ========================================
    CALCULATED STATS
    ========================================
]]

--[[
    GetGain - Gets the total gain for a stat
    
    @param name - Stat name
    @return number - Total gain since session start
]]
function StatsModule.GetGain(name)
    if not stats[name] then return 0 end
    return stats[name].value - stats[name].startValue
end

--[[
    GetPeak - Gets the peak value
    
    @param name - Stat name
    @return number - Peak value
]]
function StatsModule.GetPeak(name)
    return stats[name] and stats[name].peak or 0
end

--[[
    GetRate - Gets rate per hour
    
    @param name - Stat name
    @return number - Rate per hour
]]
function StatsModule.GetRate(name)
    local gain = StatsModule.GetGain(name)
    local elapsed = StatsModule.GetSessionTime()
    
    if elapsed == 0 then return 0 end
    
    return (gain / elapsed) * 3600 -- Per hour
end

--[[
    GetRateFormatted - Gets formatted rate
    
    @param name - Stat name
    @param suffix - Suffix to add (default "/hr")
    @return string - Formatted rate
]]
function StatsModule.GetRateFormatted(name, suffix)
    suffix = suffix or "/hr"
    local rate = StatsModule.GetRate(name)
    return FormatModule.Number(rate, 2) .. suffix
end

--[[
    GetAverage - Gets average value per change
    
    @param name - Stat name
    @return number - Average
]]
function StatsModule.GetAverage(name)
    if not stats[name] or stats[name].changes == 0 then return 0 end
    return stats[name].value / stats[name].changes
end

--[[
    ========================================
    SESSION MANAGEMENT
    ========================================
]]

--[[
    GetSessionTime - Gets elapsed session time in seconds
    
    @return number - Seconds since session start
]]
function StatsModule.GetSessionTime()
    return tick() - sessionStart
end

--[[
    GetSessionTimeFormatted - Gets formatted session time
    
    @param format - Format type (default "short")
    @return string - Formatted time
]]
function StatsModule.GetSessionTimeFormatted(format)
    return FormatModule.Time(StatsModule.GetSessionTime(), format)
end

--[[
    CreateSnapshot - Creates a snapshot of current stats
    
    @param name - Snapshot name
]]
function StatsModule.CreateSnapshot(name)
    snapshots[name] = {
        time = tick(),
        stats = {}
    }
    
    for statName, statData in pairs(stats) do
        snapshots[name].stats[statName] = statData.value
    end
end

--[[
    CompareToSnapshot - Compares current stats to snapshot
    
    @param name - Snapshot name
    @return table - Differences
]]
function StatsModule.CompareToSnapshot(name)
    if not snapshots[name] then
        warn("StatsModule: Snapshot '" .. name .. "' not found")
        return {}
    end
    
    local differences = {}
    local snapshot = snapshots[name]
    
    for statName, currentData in pairs(stats) do
        local snapshotValue = snapshot.stats[statName] or 0
        local diff = currentData.value - snapshotValue
        
        if diff ~= 0 then
            differences[statName] = {
                previous = snapshotValue,
                current = currentData.value,
                difference = diff,
                percentChange = snapshotValue > 0 and (diff / snapshotValue) * 100 or 0
            }
        end
    end
    
    return differences
end

--[[
    ========================================
    BULK OPERATIONS
    ========================================
]]

--[[
    GetAll - Gets all stats
    
    @return table - All stats and their values
]]
function StatsModule.GetAll()
    local allStats = {}
    
    for name, data in pairs(stats) do
        allStats[name] = data.value
    end
    
    return allStats
end

--[[
    GetAllDetailed - Gets all stats with detailed info
    
    @return table - Detailed stat information
]]
function StatsModule.GetAllDetailed()
    local detailed = {}
    
    for name, data in pairs(stats) do
        detailed[name] = {
            value = data.value,
            gain = data.value - data.startValue,
            peak = data.peak,
            rate = StatsModule.GetRate(name),
            changes = data.changes,
            lastChanged = data.lastChanged
        }
    end
    
    return detailed
end

--[[
    Exists - Check if stat exists
    
    @param name - Stat name
    @return boolean
]]
function StatsModule.Exists(name)
    return stats[name] ~= nil
end

--[[
    ========================================
    EXPORT/IMPORT
    ========================================
]]

--[[
    Export - Exports stats to table
    
    @return table - Exportable stats data
]]
function StatsModule.Export()
    return {
        stats = stats,
        sessionStart = sessionStart,
        snapshots = snapshots,
        exportTime = tick()
    }
end

--[[
    Import - Imports stats from table
    
    @param data - Data to import
]]
function StatsModule.Import(data)
    if data.stats then
        stats = data.stats
    end
    if data.sessionStart then
        sessionStart = data.sessionStart
    end
    if data.snapshots then
        snapshots = data.snapshots
    end
end

--[[
    ExportJSON - Exports stats as JSON string
    
    @return string - JSON data
]]
function StatsModule.ExportJSON()
    local HttpService = game:GetService("HttpService")
    return HttpService:JSONEncode(StatsModule.Export())
end

--[[
    ImportJSON - Imports stats from JSON string
    
    @param json - JSON string
]]
function StatsModule.ImportJSON(json)
    local HttpService = game:GetService("HttpService")
    local data = HttpService:JSONDecode(json)
    StatsModule.Import(data)
end

--[[
    ========================================
    DISPLAY & FORMATTING
    ========================================
]]

--[[
    Print - Prints all stats to console
]]
function StatsModule.Print()
    print("=== Session Stats ===")
    print("Session Time:", StatsModule.GetSessionTimeFormatted())
    print()
    
    for name, data in pairs(stats) do
        local gain = data.value - data.startValue
        local rate = StatsModule.GetRate(name)
        
        print(string.format(
            "%s: %s (Gain: %s | Rate: %s/hr | Peak: %s)",
            name,
            FormatModule.Number(data.value),
            FormatModule.Number(gain),
            FormatModule.Number(rate, 2),
            FormatModule.Number(data.peak)
        ))
    end
    
    print("====================")
end

--[[
    GetSummary - Gets formatted summary
    
    @return string - Summary text
]]
function StatsModule.GetSummary()
    local lines = {}
    table.insert(lines, "Session Time: " .. StatsModule.GetSessionTimeFormatted())
    table.insert(lines, "")
    
    for name, data in pairs(stats) do
        local line = string.format(
            "%s: %s (+%s)",
            name,
            FormatModule.Number(data.value),
            FormatModule.Number(data.value - data.startValue)
        )
        table.insert(lines, line)
    end
    
    return table.concat(lines, "\n")
end

--[[
    ========================================
    ADVANCED TRACKING
    ========================================
]]

--[[
    Track - Tracks a value over time (adds to history)
    
    @param name - Stat name
    @param value - Value to track
]]
function StatsModule.Track(name, value)
    if not stats[name] then
        stats[name] = {
            value = value,
            startValue = value,
            peak = value,
            changes = 0,
            lastChanged = tick(),
            history = {}
        }
    end
    
    if not stats[name].history then
        stats[name].history = {}
    end
    
    table.insert(stats[name].history, {
        value = value,
        time = tick()
    })
    
    StatsModule.Set(name, value)
end

--[[
    GetHistory - Gets history for a stat
    
    @param name - Stat name
    @param limit - Max entries to return (optional)
    @return table - History entries
]]
function StatsModule.GetHistory(name, limit)
    if not stats[name] or not stats[name].history then
        return {}
    end
    
    local history = stats[name].history
    
    if limit and #history > limit then
        local start = #history - limit + 1
        local limited = {}
        for i = start, #history do
            table.insert(limited, history[i])
        end
        return limited
    end
    
    return history
end

--[[
    GetTrend - Calculates trend direction
    
    @param name - Stat name
    @param samples - Number of samples to analyze (default 10)
    @return string - "increasing", "decreasing", or "stable"
]]
function StatsModule.GetTrend(name, samples)
    samples = samples or 10
    local history = StatsModule.GetHistory(name, samples)
    
    if #history < 2 then return "stable" end
    
    local increases = 0
    local decreases = 0
    
    for i = 2, #history do
        if history[i].value > history[i-1].value then
            increases = increases + 1
        elseif history[i].value < history[i-1].value then
            decreases = decreases + 1
        end
    end
    
    if increases > decreases * 1.5 then
        return "increasing"
    elseif decreases > increases * 1.5 then
        return "decreasing"
    else
        return "stable"
    end
end

return StatsModule
