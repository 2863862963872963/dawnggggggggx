-- /// Load libraries \\\ --
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))()
local ConfigManager = Compkiller:ConfigManager({Directory = "K4yo Hub", Config = "Example-Configs"})
local Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/2863862963872963/dawnggggggggx/refs/heads/main/Compilerr.inc"))()
local Class, translate, Configs, Funcs, Default = unpack(Module)

-- /// Services \\\ --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Game = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--/// Functions/Table/ \\\--
local Remote = {
    BridgeNet2 = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")
}

local Config = {
    ["Farm Config"] = {
	    Distance = 10,
	    Angles = 0,
        WeaphonSelected = nil,
        AutoFarmLevel = false,
        IgnoreBossQuest = false,
        AutoBoradQuest = false,
    }
}

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

local Islands = {
	Starter = {
		Position = Vector3.new(-1062.5, 43.0600, 417.033);
		Range = 625;
		Levels = 1;
	};
	Jungle = {
		Position = Vector3.new(471.113, 33.9049, 1774.81);
		Range = 625;
		Levels = 100;
	};
	Desert = {
		Position = Vector3.new(341.740, 49.4550, -1346.5);
		Range = 625;
		Levels = 250;
	};
	["Brock Town"] = {
		Position = Vector3.new(2268.56, 59.6160, 82.8000);
		Range = 700;
		Levels = 350;
	};
}

function tp(cf)
	if not HumanoidRootPart or not cf then return end
	local targetCF
	if typeof(cf) == "CFrame" then
		targetCF = cf
	elseif typeof(cf) == "Vector3" then
		targetCF = CFrame.new(cf)
	elseif typeof(cf) == "Instance" and cf:IsA("BasePart") then
		targetCF = cf.CFrame
	else
		return
	end
	HumanoidRootPart.CFrame = targetCF
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

local function GetQuestObjective()
	for i, v in pairs(Player.Quests:GetChildren()) do
		return v:GetAttribute("Island"), v:GetAttribute("Objective")
	end
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
            tp(QuestPos)
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

--/// Borad Quest \\\--
local function GetBoradQuest()
	temps = {}
	for i, v in pairs(Player.PlayerGui.ShopUI["Borad Quest"].Main.Base.Base.QuestList:GetChildren()) do
		if v.Name == "Temp" then
			table.insert(temps, v)
		end
	end

	if #temps > 0 then
		RandomCard = temps[math.random(1, #temps)]
		QuestName = RandomCard.Base.Base.Title.text
		AcceptButton = RandomCard.Base.Base.Accept
		return QuestName, AcceptButton
	end
end
		
local function AutoGetBoradQuest()
	QuestName, AcceptButton = GetBoradQuest()
	QuestList = Player.PlayerGui.ShopUI["Borad Quest"].Main.Base.Base.QuestList
	QuestData = Player.Quests
	BoradQuest = workspace.Interact["Borad Quest"]
	TalkF = Player.PlayerGui.InteractUI.Main.ButtonFrame

	
	if QuestData:FindFirstChild(QuestName) then return end

	if not QuestData:FindFirstChild(QuestName) then
		AbandonQuest()
		tp(BoradQuest.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5))
		task.wait(0.5)
		if not TalkF:FindFirstChild("Yes") then
			Class:Click()
		end
		if TalkF:FindFirstChild("Yes") then
			firesignal(TalkF.Yes.Button.MouseButton1Click)
		end
		if Player.PlayerGui.ShopUI["Borad Quest"].Visible == true and AcceptButton then
			firesignal(AcceptButton.MouseButton1Click)
		end
	end
end

local function AutoBoradQuest()
	AccptQuest = AutoGetBoradQuest()
	if AccptQuest then
		Class:Equip(Config["Farm Config"].WeaphonSelected)
		QuestIsland, Mon = GetQuestObjective()
		local MobFound = false

		for i, v in pairs(workspace.Monster:GetDescendants()) do
			if v.Name == Mon and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
				MobFound = true
				local hrp = v.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(Config["Farm Config"].Angles), 0, 0) * CFrame.new(0, 0, Config["Farm Config"].Distance)
				tp(hrp)
                M1()
			end
		end
		if not MobFound and Islands[QuestIsland] then
			tp(Islands[QuestIsland].Position + Vector3.new(0, 5, 0))
		end
	end
end



function AutoFarmLevel()
    local allowBoss = not Config["Farm Config"].IgnoreBossQuest
    local Quest, IsBossQuest = GetQuest(allowBoss)
    if not Quest then return end

    AcceptQuest(Quest)
    Class:Equip(Config["Farm Config"].WeaphonSelected)
    local ActiveQuestName, Enemy = GetEnemyQuest()
    if ActiveQuestName ~= Quest then return end  
    local MobFound = false
    for _, v in pairs(workspace.Monster:GetDescendants()) do
        if v.Name == Enemy and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            MobFound = true
            local hrp = v.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(Config["Farm Config"].Angles), 0, 0) * CFrame.new(0, 0, Config["Farm Config"].Distance)
            tp(hrp)
            M1()
        end
    end
    if not MobFound then
        for i, v in pairs(workspace.Interact.Quest:GetChildren()) do
            if v:IsA("Model") and v.Name == string.gsub(Quest, " ", "") then
                tp(v.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5))
            end
        end
    end
end


RunService.Heartbeat:Connect(function()
    if Config["Farm Config"].AutoFarmLevel then
        AutoFarmLevel()
    end
	if Config["Farm Config"].AutoBoradQuest then
        AutoBoradQuest()
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

local FarmTabs = Window:DrawContainerTab({ Name = "Main/Farm", Icon = "contact" })

local ConfigFarmLevelTab = FarmTabs:DrawTab({ Name = "Config / Level Farm", Type = "Single", EnableScrolling = true })
local BoradQuestTab = FarmTabs:DrawTab({ Name = "Borad Quest", Type = "Single", EnableScrolling = true })
	
local TravelTabs = Window:DrawContainerTab({ Name = "Shop/Islands", Icon = "contact" })

local TravelShopTab = TravelTabs:DrawTab({ Name = "Travel / Shop", Type = "Single", EnableScrolling = true })

--//////\\\\\\--
local ConfigSection = ConfigFarmLevelTab:DrawSection({ Name = "Config", Position = 'left' })
local FarmLevelSection = ConfigFarmLevelTab:DrawSection({ Name = "Farm Level", Position = 'left' })

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
local WeaphonDD = ConfigSection:AddDropdown({
	Name = "Weaphon",
	Values = GetBackpack(),
	Callback = function(Value) Config["Farm Config"].WeaphonSelected = Value end,
})
ConfigSection:AddButton({
	Name = "Refresh",
	Callback = function()
		WeaphonDD:SetValues(GetBackpack())
	end,
})

ConfigSection:AddParagraph({
	Title = "Note ♥️",
	Content = "Never forget choose weaphon before farm lol !"
})

ConfigSection:AddSlider({
	Name = "Distance",
	Min = 0,
	Max = 100,
	Default = Config["Farm Config"].Distance or 10,
	Round = 1,
	Callback = function(Num) Config["Farm Config"].Distance = Num end,
});

ConfigSection:AddSlider({
	Name = "Angles",
	Min = 0,
	Max = 360,
	Default = Config["Farm Config"].Angles or 0,
	Round = 1,
	Callback = function(Num) Config["Farm Config"].Angles = Num end,
});

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

--/// Borad Quest \\\--
local BoradQuestSection = BoradQuestTab:DrawSection({ Name = "Borad Quest", Position = 'left' })
local BoradValue = Player.PlayerGui.ShopUI["Borad Quest"].Main.Base.Base.QuestValue.Text
local BoradQuestValue =  BoradQuestSection:AddParagraph({Title = BoradValue, Conten = "Complate 35 Borad Quest to spawn boss"})
spawn(function() while true and task.wait() do BoradQuestValue:SetTitle(`Borad Quest Progress {BoradValue}`) end end)

local BoradQuestTog = BoradQuestSection:AddToggle({
    Name = "Auto Borad Quest",
    Default = false,
    Callback = function(State)
        Config["Farm Config"].AutoBoradQuest = State
    end,
})

--/// Travel/Shop/Esp \\\--
local TravelSection = TravelShopTab:DrawSection({ Name = "Travel", Position = 'left' })

local function getIslandNames()
	local names = {}
	for name in pairs(Islands) do
		table.insert(names, name)
	end
	return names
end

local SelectedIsland 
local IslandDD = TravelSection:AddDropdown({
	Name = "Island ",
	Values = getIslandNames(),
	Callback = function(Value) SelectedIsland = Value end,
})
TravelSection:AddButton({
	Name = "Travel !",
	Callback = function()
		tp(Islands[SelectedIsland].Position)
	end,
})

local ShopSection = TravelShopTab:DrawSection({ Name = "Shop/Npc", Position = 'left' })

local function getNpcNames()
	local Npcs = {}
	for _, npc in pairs(workspace.Interact.ShopItem:GetChildren()) do
		table.insert(Npcs, npc.Name)
	end
	return Npcs
end

local SelectedNpc
local IslandDD = ShopSection:AddDropdown({
	Name = "Npc ",
	Values = getNpcNames(),
	Callback = function(Value) SelectedNpc = Value end,
})
ShopSection:AddButton({
	Name = "Travel !",
	Callback = function()
		local Npc = workspace.Interact.ShopItem:FindFirstChild(SelectedNpc)
		tp(Npc.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
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
