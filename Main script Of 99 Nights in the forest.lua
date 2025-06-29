-- Load libraries
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))()
local ConfigManager = Compkiller:ConfigManager({Directory = "K4yo Hub", Config = "Example-Configs"})
local Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/2863862963872963/dawnggggggggx/refs/heads/main/Compiler.inc"))()

-- Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Module unpack
local Class, translate, Configs, Funcs, Default = unpack(Module)
local Game = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)

-- Remote reference
local Remote = {
    BridgeNet2 = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")
}

-- Config
local Config = {
    ["Farm Config"] = {
        WeaphonSelected = nil,
        AutoFarmLevel = false,
        IgnoreBossQuest = false,
        
    }
}

-- Quest list logic
local QuestList = {
    {Level = 1,   Name = "Quest 1",  IsBoss = false},
    {Level = 25,  Name = "Quest 2",  IsBoss = false},
    {Level = 50,  Name = "Quest 3",  IsBoss = true},
    {Level = 100, Name = "Quest 4",  IsBoss = false},
    {Level = 150, Name = "Quest 5",  IsBoss = false},
    {Level = 200, Name = "Quest 6",  IsBoss = true},
    {Level = 250, Name = "Quest 7",  IsBoss = false},
    {Level = 300, Name = "Quest 8",  IsBoss = false},
    {Level = 350, Name = "Quest 9",  IsBoss = true},
    {Level = 400, Name = "Quest 10", IsBoss = false},
    {Level = 450, Name = "Quest 11", IsBoss = false},
    {Level = 500, Name = "Quest 12", IsBoss = true},
}

local function GetQuest(allowBoss)
    local Levels = Player.Data:GetAttribute("Levels") or 0
    local selected = nil

    for i = #QuestList, 1, -1 do
        local quest = QuestList[i]
        if Levels >= quest.Level then
            if allowBoss or not quest.IsBoss then
                selected = quest
                break
            end
        end
    end

    if selected then
        return selected.Name, selected.IsBoss
    end
    return nil, false
end

-- Teleport
function tp(cf)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and cf then
        hrp.CFrame = cf
    end
end

local function GetEnemyQuest()
    local allowBoss = not Config["Farm Config"].IgnoreBossQuest
    local Namc = GetQuest(allowBoss)
    for _, quest in pairs(Player.Quests:GetChildren()) do
        if quest.Name == Namc and quest:GetAttribute("Objective") then
            return quest.Name, quest:GetAttribute("Objective")
        end
    end
    return nil, nil
end

local function AbandonQuest()
    local QuestBar = Player.PlayerGui.Main.QuesList
    local InfoLabel = Player.PlayerGui.Main.QuestInfo

    if InfoLabel.Visible ~= true then
        firesignal(QuestBar.Temp.Main.TextButton.MouseButton1Click)
    end
    if InfoLabel.Visible == true then
        firesignal(InfoLabel.Main.Base.Abandon.MouseButton1Click)
    end
end
    
local function AcceptQuest(QuestN)
    if Player.Quests:FindFirstChild(QuestN) then return end
    for i, v in pairs(Player.Quests:GetChildren()) do
        if v.Name ~= QuestN then
            AbandonQuest()
        end
    end
    local QuestId = string.gsub(QuestN, " ", "")
    local QuestUi = Player.PlayerGui:WaitForChild("InteractUI"):WaitForChild("Main")
    
    for _, v in pairs(workspace.Interact.Quest:GetChildren()) do
        if v:IsA("Model") and v.Name == QuestId then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            local QuestPos = hrp.CFrame * CFrame.new(0, 0, -5)
            Class:tween(QuestPos)
            task.wait(0.5)
            Class:Click()
            if QuestUi.ButtonFrame:FindFirstChild("Yes") then
                firesignal(QuestUi.ButtonFrame.Yes.Button.MouseButton1Click)
            else
                Class:Click()
            end
        end
    end
end

function M1()
    if Player.Character then
        Remote.BridgeNet2:FireServer({{"M1", CFrame.new(), CFrame.new()}, "\4"})
    end
end

function AutoFarmLevel()
    local allowBoss = not Config["Farm Config"].IgnoreBossQuest
    local Quest, IsBossQuest = GetQuest(allowBoss)
    if not Quest then return end

    AcceptQuest(Quest)

    local ActiveQuestName, Enemy = GetEnemyQuest()
    if ActiveQuestName ~= Quest then return end  -- Ensure quest was accepted
    local MobFound = false
    for _, v in pairs(workspace.Monster:GetDescendants()) do
        if v.Name == Enemy and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            MobFound = true
            local hrp = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
            Class:tween(hrp)
            M1()
        end
    end
    if not MobFound then
        for i, v in pairs(workspace.Interact.Quest:GetChildren()) do
            if v:IsA("Model") and v.Name == string.gsub(Quest, " ", "") then
                Class:tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5))
            end
        end
    end
end


RunService.Heartbeat:Connect(function()
    if Config["Farm Config"].AutoFarmLevel then
        AutoFarmLevel()
    end
end)



local Window = Compkiller.new({
    Name = "Aozora Hub",
    Keybind = "LeftAlt",
    Logo = "rbxassetid://120245531583106",
    TextSize = 15,
})

local Watermark = Window:Watermark()
local Time = Watermark:AddText({Icon = "timer", Text = "TIME"})
spawn(function()
    while true do
        task.wait()
        Time:SetText(Compkiller:GetTimeNow())
    end
end)

local FarmTabs = Window:DrawContainerTab({ Name = "Farm", Icon = "contact" })
local FarmLevelTab = FarmTabs:DrawTab({ Name = "Level Farm", Type = "Single", EnableScrolling = true })

--//////\\\\\\
--//////\\\\\\
--//////\\\\\\

local FarmLevelSection = FarmLevelTab:DrawSection({ Name = "Farm Level", Position = 'left' })

local AutoFarmLevelTog = FarmLevelSection:AddToggle({
    Name = "Auto Farm Level",
    Default = false,
    Callback = function(State)
        Config["Farm Config"].AutoFarmLevel = State
    end,
})

local FarmLevelOption = AutoFarmLevelTog.Link:AddOption()
FarmLevelOption:AddToggle({
    Name = "Ignore Boss Quest",
    Callback = function(State)
        Config["Farm Config"].IgnoreBossQuest = State
    end,
})

FarmLevelOption:AddToggle({
    Name = "Safe Farm",
    Callback = function(State)
        -- Future safe farm logic
    end,
})

local function GetBackpack()
    local Backpack = Player:FindFirstChild("Backpack")
    if not Backpack then return {} end

    local items = {}
    for _, item in ipairs(Backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(items, item.Name)
        end
    end

    return items
end

local BBDD = FarmLevelOption:AddDropdown({
	Name = "Weapon",
	Flag = "Weapon_Dropdown",
	Values = GetBackpack(),
	Callback = function(tool)
        Config["Farm Config"].WeaponSelected = tool 
    end,
})

FarmLevelOption:AddButton({
	Name = "🔄 Refresh Weapons",
	Callback = function()
		BBDD:Refersh()
	end,
})

-- Theme tab
local ThemeTab = Window:DrawTab({ Icon = "paintbrush", Name = "Themes", Type = "Single" })
ThemeTab:DrawSection({ Name = "UI Themes" }):AddDropdown({
    Name = "Select Theme",
    Default = "Default",
    Values = {"Default", "Dark Green", "Dark Blue", "Purple Rose", "Skeet"},
    Callback = function(v)
        Compkiller:SetTheme(v)
    end,
})

-- Config saving
local ConfigUI = Window:DrawConfig({
    Name = "Config",
    Icon = "folder",
    Config = ConfigManager
})
ConfigUI:Init()
