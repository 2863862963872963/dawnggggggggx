local WebhookModule = {}


function WebhookModule:Send(webhookUrl, data)
    local request = (syn and syn.request) or (http and http.request) or http_request or request
    if not request then
        warn("Your executor does not support HTTP requests.")
        return
    end

    local payload = {
        username = data.username,
        avatar_url = data.avatar,
        content = data.content or nil,
        embeds = {
            {
                title = data.title or nil,
                description = data.description or nil,
                color = tonumber(data.color) or 16777215, 
                fields = data.fields or nil,
                image = data.image and { url = data.image } or nil,
                thumbnail = data.thumbnail and { url = data.thumbnail } or nil,
                footer = data.footer and { text = data.footer } or nil,
                author = data.author and { name = data.author } or nil,
                timestamp = data.timestamp and os.date("!%Y-%m-%dT%H:%M:%SZ") or nil
            }
        }
    }

    request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = game:GetService("HttpService"):JSONEncode(payload)
    })
end

return WebhookModule
