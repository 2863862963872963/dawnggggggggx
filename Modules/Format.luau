--[[
    FormatModule.lua
    Text formatting and number utilities
    
    Features:
    - Number abbreviation (1000 -> 1K, 1000000 -> 1M)
    - Time formatting (seconds to readable format)
    - Currency formatting
    - Percentage formatting
    - String utilities
    - Color formatting
    
    Usage:
        local Format = require(game.ReplicatedStorage.FormatModule)
        print(Format.Number(1234567)) -- "1.23M"
        print(Format.Time(3665)) -- "1h 1m 5s"
]]

local FormatModule = {}

--[[
    ========================================
    NUMBER FORMATTING
    ========================================
]]

--[[
    Number - Abbreviates large numbers
    
    @param number - Number to format
    @param decimals - Decimal places (default 2)
    @return string - Formatted number
    
    Examples:
        1234 -> "1.23K"
        1234567 -> "1.23M"
        1234567890 -> "1.23B"
]]
function FormatModule.Number(number, decimals)
    decimals = decimals or 2
    
    local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}
    local suffixIndex = 1
    
    while number >= 1000 and suffixIndex < #suffixes do
        number = number / 1000
        suffixIndex = suffixIndex + 1
    end
    
    if suffixIndex == 1 then
        return tostring(math.floor(number))
    else
        return string.format("%." .. decimals .. "f%s", number, suffixes[suffixIndex])
    end
end

--[[
    NumberWithCommas - Adds commas to numbers
    
    @param number - Number to format
    @return string - Number with commas
    
    Example: 1234567 -> "1,234,567"
]]
function FormatModule.NumberWithCommas(number)
    local formatted = tostring(math.floor(number))
    local k
    
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    
    return formatted
end

--[[
    Percentage - Formats a number as percentage
    
    @param value - Number to format (0-1 or 0-100)
    @param decimals - Decimal places (default 1)
    @param fromDecimal - If true, expects 0-1 range (default true)
    @return string - Formatted percentage
    
    Examples:
        0.75 -> "75.0%"
        0.333 -> "33.3%"
]]
function FormatModule.Percentage(value, decimals, fromDecimal)
    decimals = decimals or 1
    fromDecimal = fromDecimal ~= false
    
    if fromDecimal then
        value = value * 100
    end
    
    return string.format("%." .. decimals .. "f%%", value)
end

--[[
    Currency - Formats a number as currency
    
    @param amount - Amount to format
    @param symbol - Currency symbol (default "$")
    @param decimals - Decimal places (default 2)
    @return string - Formatted currency
    
    Example: 1234.5 -> "$1,234.50"
]]
function FormatModule.Currency(amount, symbol, decimals)
    symbol = symbol or "$"
    decimals = decimals or 2
    
    local formatted = string.format("%." .. decimals .. "f", amount)
    local k
    
    -- Add commas
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    
    return symbol .. formatted
end

--[[
    ScientificNotation - Converts to scientific notation
    
    @param number - Number to format
    @param decimals - Decimal places (default 2)
    @return string - Scientific notation
    
    Example: 1234567 -> "1.23e6"
]]
function FormatModule.ScientificNotation(number, decimals)
    decimals = decimals or 2
    return string.format("%." .. decimals .. "e", number)
end

--[[
    ========================================
    TIME FORMATTING
    ========================================
]]

--[[
    Time - Converts seconds to readable time format
    
    @param seconds - Seconds to format
    @param format - Format type: "short", "long", "clock" (default "short")
    @return string - Formatted time
    
    Examples:
        3665, "short" -> "1h 1m 5s"
        3665, "long" -> "1 hour 1 minute 5 seconds"
        3665, "clock" -> "01:01:05"
]]
function FormatModule.Time(seconds, format)
    format = format or "short"
    seconds = math.floor(seconds)
    
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if format == "clock" then
        if days > 0 then
            return string.format("%dd %02d:%02d:%02d", days, hours, minutes, secs)
        elseif hours > 0 then
            return string.format("%02d:%02d:%02d", hours, minutes, secs)
        else
            return string.format("%02d:%02d", minutes, secs)
        end
        
    elseif format == "long" then
        local parts = {}
        
        if days > 0 then
            table.insert(parts, days .. (days == 1 and " day" or " days"))
        end
        if hours > 0 then
            table.insert(parts, hours .. (hours == 1 and " hour" or " hours"))
        end
        if minutes > 0 then
            table.insert(parts, minutes .. (minutes == 1 and " minute" or " minutes"))
        end
        if secs > 0 or #parts == 0 then
            table.insert(parts, secs .. (secs == 1 and " second" or " seconds"))
        end
        
        return table.concat(parts, " ")
        
    else -- short format
        local parts = {}
        
        if days > 0 then
            table.insert(parts, days .. "d")
        end
        if hours > 0 then
            table.insert(parts, hours .. "h")
        end
        if minutes > 0 then
            table.insert(parts, minutes .. "m")
        end
        if secs > 0 or #parts == 0 then
            table.insert(parts, secs .. "s")
        end
        
        return table.concat(parts, " ")
    end
end

--[[
    Countdown - Formats time remaining for countdown
    
    @param targetTime - Target unix timestamp
    @return string - Time remaining
]]
function FormatModule.Countdown(targetTime)
    local remaining = targetTime - os.time()
    
    if remaining <= 0 then
        return "Expired"
    end
    
    return FormatModule.Time(remaining, "short")
end

--[[
    ========================================
    STRING UTILITIES
    ========================================
]]

--[[
    Truncate - Truncates string to max length
    
    @param str - String to truncate
    @param maxLength - Maximum length
    @param suffix - Suffix to add (default "...")
    @return string - Truncated string
    
    Example: "Hello World", 8 -> "Hello..."
]]
function FormatModule.Truncate(str, maxLength, suffix)
    suffix = suffix or "..."
    
    if #str <= maxLength then
        return str
    end
    
    return string.sub(str, 1, maxLength - #suffix) .. suffix
end

--[[
    PadLeft - Pads string on the left
    
    @param str - String to pad
    @param length - Target length
    @param char - Padding character (default " ")
    @return string - Padded string
    
    Example: "5", 3, "0" -> "005"
]]
function FormatModule.PadLeft(str, length, char)
    char = char or " "
    str = tostring(str)
    
    while #str < length do
        str = char .. str
    end
    
    return str
end

--[[
    PadRight - Pads string on the right
    
    @param str - String to pad
    @param length - Target length
    @param char - Padding character (default " ")
    @return string - Padded string
]]
function FormatModule.PadRight(str, length, char)
    char = char or " "
    str = tostring(str)
    
    while #str < length do
        str = str .. char
    end
    
    return str
end

--[[
    Capitalize - Capitalizes first letter of each word
    
    @param str - String to capitalize
    @return string - Capitalized string
    
    Example: "hello world" -> "Hello World"
]]
function FormatModule.Capitalize(str)
    return string.gsub(str, "(%a)([%w_']*)", function(first, rest)
        return string.upper(first) .. string.lower(rest)
    end)
end

--[[
    CamelCase - Converts to camelCase
    
    @param str - String to convert
    @return string - camelCase string
    
    Example: "hello world" -> "helloWorld"
]]
function FormatModule.CamelCase(str)
    str = string.gsub(str, "[^%w]", " ")
    str = FormatModule.Capitalize(str)
    str = string.gsub(str, "%s+", "")
    return string.lower(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

--[[
    ========================================
    COLOR FORMATTING
    ========================================
]]

--[[
    RGBToHex - Converts RGB to hex color
    
    @param r - Red (0-255)
    @param g - Green (0-255)
    @param b - Blue (0-255)
    @return string - Hex color (#RRGGBB)
]]
function FormatModule.RGBToHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

--[[
    Color3ToHex - Converts Color3 to hex
    
    @param color - Color3 value
    @return string - Hex color
]]
function FormatModule.Color3ToHex(color)
    return FormatModule.RGBToHex(
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

--[[
    ColorText - Wraps text in rich text color tags
    
    @param text - Text to color
    @param color - Color3 or hex string
    @return string - Colored text
]]
function FormatModule.ColorText(text, color)
    local hex
    
    if typeof(color) == "Color3" then
        hex = FormatModule.Color3ToHex(color)
    else
        hex = color
    end
    
    -- Remove # if present
    hex = string.gsub(hex, "#", "")
    
    return '<font color="#' .. hex .. '">' .. text .. '</font>'
end

--[[
    ========================================
    MISC UTILITIES
    ========================================
]]

--[[
    Ordinal - Converts number to ordinal (1st, 2nd, 3rd)
    
    @param number - Number to convert
    @return string - Ordinal number
]]
function FormatModule.Ordinal(number)
    local suffix = "th"
    local lastDigit = number % 10
    local lastTwoDigits = number % 100
    
    if lastTwoDigits >= 11 and lastTwoDigits <= 13 then
        suffix = "th"
    elseif lastDigit == 1 then
        suffix = "st"
    elseif lastDigit == 2 then
        suffix = "nd"
    elseif lastDigit == 3 then
        suffix = "rd"
    end
    
    return tostring(number) .. suffix
end

--[[
    Plural - Returns singular or plural form
    
    @param count - Count
    @param singular - Singular form
    @param plural - Plural form (optional, adds 's' if not provided)
    @return string - Appropriate form
    
    Example: Plural(5, "apple") -> "apples"
]]
function FormatModule.Plural(count, singular, plural)
    if count == 1 then
        return singular
    else
        return plural or (singular .. "s")
    end
end

--[[
    FileSize - Formats bytes to readable file size
    
    @param bytes - Number of bytes
    @param decimals - Decimal places (default 2)
    @return string - Formatted size
    
    Example: 1536 -> "1.50 KB"
]]
function FormatModule.FileSize(bytes, decimals)
    decimals = decimals or 2
    
    local sizes = {"B", "KB", "MB", "GB", "TB"}
    local index = 1
    
    while bytes >= 1024 and index < #sizes do
        bytes = bytes / 1024
        index = index + 1
    end
    
    return string.format("%." .. decimals .. "f %s", bytes, sizes[index])
end

return FormatModule
