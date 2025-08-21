islclosure, getgc, hookfunction, getrenv = islclosure, getgc, hookfunction, getrenv
getgenv, identifyexecutor, setclipboard, makefolder, isfolder = getgenv, identifyexecutor, setclipboard, makefolder, isfolder
writefile, isfile, readfile, delfile, sethiddenproperty, getnilinstances = writefile, isfile, readfile, delfile, sethiddenproperty, getnilinstances
cloneref, getconnections, getsenv, fireclickdetector, fireproximityprompt, firetouchinterest =
cloneref, getconnections, getsenv, fireclickdetector, fireproximityprompt, firetouchinterest

--// Services
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

--// Locals
local PlaceId = game.PlaceId
local JobId = game.JobId
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Backpack = LocalPlayer:WaitForChild("Backpack")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local Name = LocalPlayer.Name
local DisplayName = LocalPlayer.DisplayName
local PlayerId = LocalPlayer.UserId
local Team = tostring(LocalPlayer.Team)
local Folder = "AscentLib/Config/" .. PlayerId .. "/" .. PlaceId .. ".json"
local Executor = string.upper(identifyexecutor())
local Blacklist_Executor = table.find({"SOLARA", "XENO"}, Executor)

-- Auto-update character references
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Backpack = LocalPlayer:WaitForChild("Backpack")
end)

-- Anti-AFK
task.spawn(function()
    pcall(function()
        if getconnections then
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do
                if v.Disable then v.Disable(v)
                elseif v.Disconnect then v.Disconnect(v) end
            end
        else
            LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
end)

--// Library
local Lib = {}
Lib.Functions = {}

-- Debug Hello
function Lib.Functions:Hello()
    print("Hello from AscentLib!")
end

-- Find Part/Model by config
-- Config = {Path = Instance, Name = "string", Pos = Vector3/Instance, Dis = number, Exact = bool}
function Lib.Functions:Get(config)
    local path = config.Path or workspace
    local name = config.Name
    local pos = config.Pos
    local dis = config.Dis or math.huge
    local exact = config.Exact or false

    if typeof(pos) == "Instance" then
        pos = pos.Position
    end

    local best, bestDist

    for _, inst in ipairs(path:GetDescendants()) do
        if inst:IsA("BasePart") then
            local match = false
            if not name then
                match = true
            elseif exact then
                match = inst.Name == name
            else
                match = inst.Name:sub(1, #name) == name
            end

            if match then
                local dist = pos and (inst.Position - pos).Magnitude or 0
                if dist <= dis and (not bestDist or dist < bestDist) then
                    best = inst
                    bestDist = dist
                end
            end
        end
    end

    return best or false
end

-- Tween to a position
function Lib.Functions:Tween(part, goalCFrame, speed)
    local tweenInfo = TweenInfo.new(speed or 1, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(part, tweenInfo, {CFrame = goalCFrame})
    tween:Play()
    return tween
end

-- Get HumanoidRootPart of player safely
function Lib.Functions:GetHRP(plr)
    plr = plr or LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        return plr.Character.HumanoidRootPart
    end
    return nil
end

-- Get closest player
function Lib.Functions:GetClosestPlayer(maxDistance)
    local closest, dist = nil, maxDistance or math.huge
    local myHRP = self:GetHRP(LocalPlayer)
    if not myHRP then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local d = (plr.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
            if d < dist then
                closest, dist = plr, d
            end
        end
    end
    return closest
end

return Lib
