--[[
    WebhookModule.lua
    Discord webhook integration for notifications and logging
    
    Features:
    - Send messages to Discord
    - Rich embeds with colors, fields, images
    - Rate limiting protection
    - Queue system
    - Template system
    - Error handling
    
    Usage:
        local Webhook = require(game.ReplicatedStorage.WebhookModule)
        Webhook.SetURL("your_webhook_url_here")
        Webhook.Send("Hello from Roblox!")
        
    NOTE: Webhooks only work on the SERVER side (ServerScriptService)
]]

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local WebhookModule = {}

-- Configuration
local webhookURL = ""
local defaultUsername = "Roblox Bot"
local defaultAvatar = ""
local rateLimitDelay = 2 -- Seconds between requests
local maxRetries = 3

-- Queue system
local messageQueue = {}
local lastSendTime = 0
local isSending = false

-- Templates
local templates = {}

--[[
    ========================================
    CONFIGURATION
    ========================================
]]

--[[
    SetURL - Sets the webhook URL
    
    @param url - Discord webhook URL
]]
function WebhookModule.SetURL(url)
    webhookURL = url
end

--[[
    SetDefaultUsername - Sets default bot username
    
    @param username - Username to display
]]
function WebhookModule.SetDefaultUsername(username)
    defaultUsername = username
end

--[[
    SetDefaultAvatar - Sets default avatar URL
    
    @param url - Avatar image URL
]]
function WebhookModule.SetDefaultAvatar(url)
    defaultAvatar = url
end

--[[
    SetRateLimit - Sets rate limit delay
    
    @param seconds - Seconds between sends
]]
function WebhookModule.SetRateLimit(seconds)
    rateLimitDelay = seconds
end

--[[
    ========================================
    BASIC SENDING
    ========================================
]]

--[[
    Send - Sends a simple message
    
    @param content - Message text
    @param options - Optional table:
        - Username: string
        - AvatarURL: string
        - TTS: boolean
    @return boolean - Success
]]
function WebhookModule.Send(content, options)
    if not webhookURL or webhookURL == "" then
        warn("WebhookModule: No webhook URL set")
        return false
    end
    
    options = options or {}
    
    local data = {
        content = content,
        username = options.Username or defaultUsername,
        avatar_url = options.AvatarURL or defaultAvatar,
        tts = options.TTS or false
    }
    
    return WebhookModule._SendRequest(data)
end

--[[
    SendEmbed - Sends a rich embed message
    
    @param embed - Embed data table:
        - Title: string
        - Description: string
        - Color: number (decimal color)
        - Fields: table of {name, value, inline}
        - Footer: {text, icon_url}
        - Thumbnail: {url}
        - Image: {url}
        - Author: {name, url, icon_url}
        - URL: string
        - Timestamp: boolean (adds current time)
    @param content - Optional message content
    @param options - Optional username/avatar
    @return boolean - Success
]]
function WebhookModule.SendEmbed(embed, content, options)
    if not webhookURL or webhookURL == "" then
        warn("WebhookModule: No webhook URL set")
        return false
    end
    
    options = options or {}
    
    local embedData = {
        title = embed.Title,
        description = embed.Description,
        color = embed.Color,
        url = embed.URL,
        fields = embed.Fields or {},
    }
    
    -- Add footer
    if embed.Footer then
        embedData.footer = {
            text = embed.Footer.text or embed.Footer.Text,
            icon_url = embed.Footer.icon_url or embed.Footer.IconURL
        }
    end
    
    -- Add thumbnail
    if embed.Thumbnail then
        embedData.thumbnail = {
            url = embed.Thumbnail.url or embed.Thumbnail.URL
        }
    end
    
    -- Add image
    if embed.Image then
        embedData.image = {
            url = embed.Image.url or embed.Image.URL
        }
    end
    
    -- Add author
    if embed.Author then
        embedData.author = {
            name = embed.Author.name or embed.Author.Name,
            url = embed.Author.url or embed.Author.URL,
            icon_url = embed.Author.icon_url or embed.Author.IconURL
        }
    end
    
    -- Add timestamp
    if embed.Timestamp then
        embedData.timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
    end
    
    local data = {
        content = content,
        username = options.Username or defaultUsername,
        avatar_url = options.AvatarURL or defaultAvatar,
        embeds = {embedData}
    }
    
    return WebhookModule._SendRequest(data)
end

--[[
    ========================================
    QUEUE SYSTEM
    ========================================
]]

--[[
    Queue - Adds message to queue (with rate limiting)
    
    @param content - Message or embed
    @param isEmbed - If true, content is embed data
    @param options - Additional options
]]
function WebhookModule.Queue(content, isEmbed, options)
    table.insert(messageQueue, {
        content = content,
        isEmbed = isEmbed,
        options = options or {}
    })
    
    WebhookModule._ProcessQueue()
end

--[[
    _ProcessQueue - Internal queue processor
]]
function WebhookModule._ProcessQueue()
    if isSending or #messageQueue == 0 then
        return
    end
    
    local timeSinceLastSend = tick() - lastSendTime
    if timeSinceLastSend < rateLimitDelay then
        task.delay(rateLimitDelay - timeSinceLastSend, WebhookModule._ProcessQueue)
        return
    end
    
    isSending = true
    local message = table.remove(messageQueue, 1)
    
    if message.isEmbed then
        WebhookModule.SendEmbed(message.content, nil, message.options)
    else
        WebhookModule.Send(message.content, message.options)
    end
    
    lastSendTime = tick()
    isSending = false
    
    if #messageQueue > 0 then
        task.delay(rateLimitDelay, WebhookModule._ProcessQueue)
    end
end

--[[
    ClearQueue - Clears the message queue
]]
function WebhookModule.ClearQueue()
    messageQueue = {}
end

--[[
    GetQueueLength - Gets number of queued messages
    
    @return number - Queue length
]]
function WebhookModule.GetQueueLength()
    return #messageQueue
end

--[[
    ========================================
    TEMPLATES
    ========================================
]]

--[[
    CreateTemplate - Creates a reusable message template
    
    @param name - Template name
    @param data - Template data (can include {{variables}})
]]
function WebhookModule.CreateTemplate(name, data)
    templates[name] = data
end

--[[
    SendTemplate - Sends a message using a template
    
    @param name - Template name
    @param variables - Table of variable replacements
    @return boolean - Success
]]
function WebhookModule.SendTemplate(name, variables)
    local template = templates[name]
    if not template then
        warn("WebhookModule: Template '" .. name .. "' not found")
        return false
    end
    
    variables = variables or {}
    
    -- Deep copy template
    local data = HttpService:JSONDecode(HttpService:JSONEncode(template))
    
    -- Replace variables
    local function replaceVars(obj)
        if type(obj) == "string" then
            for key, value in pairs(variables) do
                obj = string.gsub(obj, "{{" .. key .. "}}", tostring(value))
            end
            return obj
        elseif type(obj) == "table" then
            for k, v in pairs(obj) do
                obj[k] = replaceVars(v)
            end
            return obj
        end
        return obj
    end
    
    data = replaceVars(data)
    
    if data.embeds then
        return WebhookModule.SendEmbed(data.embeds[1], data.content, data)
    else
        return WebhookModule.Send(data.content, data)
    end
end

--[[
    ========================================
    PRESET MESSAGES
    ========================================
]]

--[[
    SendSuccess - Sends a success message
    
    @param title - Title
    @param description - Description
]]
function WebhookModule.SendSuccess(title, description)
    return WebhookModule.SendEmbed({
        Title = "✅ " .. title,
        Description = description,
        Color = 0x00FF00, -- Green
        Timestamp = true
    })
end

--[[
    SendError - Sends an error message
    
    @param title - Title
    @param description - Description
]]
function WebhookModule.SendError(title, description)
    return WebhookModule.SendEmbed({
        Title = "❌ " .. title,
        Description = description,
        Color = 0xFF0000, -- Red
        Timestamp = true
    })
end

--[[
    SendWarning - Sends a warning message
    
    @param title - Title
    @param description - Description
]]
function WebhookModule.SendWarning(title, description)
    return WebhookModule.SendEmbed({
        Title = "⚠️ " .. title,
        Description = description,
        Color = 0xFFA500, -- Orange
        Timestamp = true
    })
end

--[[
    SendInfo - Sends an info message
    
    @param title - Title
    @param description - Description
]]
function WebhookModule.SendInfo(title, description)
    return WebhookModule.SendEmbed({
        Title = "ℹ️ " .. title,
        Description = description,
        Color = 0x0099FF, -- Blue
        Timestamp = true
    })
end

--[[
    SendPlayerJoin - Sends player join notification
    
    @param player - Player instance
]]
function WebhookModule.SendPlayerJoin(player)
    return WebhookModule.SendEmbed({
        Title = "Player Joined",
        Description = player.Name .. " joined the game",
        Color = 0x00FF00,
        Thumbnail = {
            URL = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150"
        },
        Fields = {
            {name = "User ID", value = tostring(player.UserId), inline = true},
            {name = "Account Age", value = player.AccountAge .. " days", inline = true}
        },
        Timestamp = true
    })
end

--[[
    SendPlayerLeave - Sends player leave notification
    
    @param player - Player instance
]]
function WebhookModule.SendPlayerLeave(player)
    return WebhookModule.SendEmbed({
        Title = "Player Left",
        Description = player.Name .. " left the game",
        Color = 0xFF0000,
        Thumbnail = {
            URL = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150"
        },
        Timestamp = true
    })
end

--[[
    SendStats - Sends statistics report
    
    @param stats - Table of statistics
    @param title - Optional title (default "Statistics Report")
]]
function WebhookModule.SendStats(stats, title)
    local fields = {}
    
    for name, value in pairs(stats) do
        table.insert(fields, {
            name = name,
            value = tostring(value),
            inline = true
        })
    end
    
    return WebhookModule.SendEmbed({
        Title = title or "📊 Statistics Report",
        Color = 0x9B59B6, -- Purple
        Fields = fields,
        Timestamp = true
    })
end

--[[
    SendLog - Sends a log message
    
    @param logType - "INFO", "WARN", "ERROR", "DEBUG"
    @param message - Log message
    @param details - Optional details table
]]
function WebhookModule.SendLog(logType, message, details)
    local colors = {
        INFO = 0x0099FF,
        WARN = 0xFFA500,
        ERROR = 0xFF0000,
        DEBUG = 0x808080
    }
    
    local emoji = {
        INFO = "ℹ️",
        WARN = "⚠️",
        ERROR = "❌",
        DEBUG = "🐛"
    }
    
    local fields = {}
    if details then
        for key, value in pairs(details) do
            table.insert(fields, {
                name = key,
                value = tostring(value),
                inline = true
            })
        end
    end
    
    return WebhookModule.SendEmbed({
        Title = emoji[logType] .. " " .. logType,
        Description = message,
        Color = colors[logType],
        Fields = fields,
        Timestamp = true
    })
end

--[[
    ========================================
    INTERNAL FUNCTIONS
    ========================================
]]

--[[
    _SendRequest - Internal function to send HTTP request
    
    @param data - Data to send
    @return boolean - Success
]]
function WebhookModule._SendRequest(data)
    if not RunService:IsServer() then
        warn("WebhookModule: Webhooks can only be sent from server")
        return false
    end
    
    local success, response
    local attempt = 0
    
    repeat
        attempt = attempt + 1
        
        success, response = pcall(function()
            return HttpService:PostAsync(
                webhookURL,
                HttpService:JSONEncode(data),
                Enum.HttpContentType.ApplicationJson
            )
        end)
        
        if not success then
            warn("WebhookModule: Send failed (Attempt " .. attempt .. "/" .. maxRetries .. "):", response)
            
            if attempt < maxRetries then
                task.wait(1)
            end
        end
        
    until success or attempt >= maxRetries
    
    return success
end

--[[
    ========================================
    UTILITY FUNCTIONS
    ========================================
]]

--[[
    ColorFromRGB - Converts RGB to Discord color
    
    @param r - Red (0-255)
    @param g - Green (0-255)
    @param b - Blue (0-255)
    @return number - Discord color value
]]
function WebhookModule.ColorFromRGB(r, g, b)
    return r * 65536 + g * 256 + b
end

--[[
    ColorFromColor3 - Converts Color3 to Discord color
    
    @param color - Color3 value
    @return number - Discord color value
]]
function WebhookModule.ColorFromColor3(color)
    return WebhookModule.ColorFromRGB(
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

--[[
    IsConfigured - Check if webhook is configured
    
    @return boolean
]]
function WebhookModule.IsConfigured()
    return webhookURL ~= "" and webhookURL ~= nil
end

return WebhookModule
