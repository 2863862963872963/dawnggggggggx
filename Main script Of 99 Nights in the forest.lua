local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
local ConfigManager = Compkiller:ConfigManager({Directory = "K4yo Hub", Config = "Example-Configs"});
local Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/2863862963872963/dawnggggggggx/refs/heads/main/Compiler.inc"))();

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Class, translate, Configs, Funcs, Default = unpack(Module)
local Game = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remote = {
	BridgeNet2 = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")
}
local Config = {
	["Farm Config"] = {
		AutoFarmLevel = false,
		BossAllow = false,
	}
}

local function GetQuest()
	local Levels = Player.Data:GetAttribute("Levels")
	local Quest = nil

	if Levels >= 1 and Levels < 25 then 
		Quest = "Quest 1"
	elseif Levels >= 25 and Levels < 50 then 
		Quest = "Quest 2"
	elseif Levels >= 50 and Levels < 100 then 
		Quest = "Quest 3"
	elseif Levels >= 100 and Levels < 150 then 
		Quest = "Quest 4"
	elseif Levels >= 150 and Levels < 200 then 
		Quest = "Quest 5"
	elseif Levels >= 200 and Levels < 250 then 
		Quest = "Quest 6"
	elseif Levels >= 250 and Levels < 300 then 
		Quest = "Quest 7"
	elseif Levels >= 300 and Levels < 350 then 
		Quest = "Quest 8"
	elseif Levels >= 350 and Levels < 400 then 
		Quest = "Quest 9"
	elseif Levels >= 400 and Levels < 450 then 
		Quest = "Quest 10"
	elseif Levels >= 450 then 
		Quest = "Quest 11"
	end

	return Quest
end

function tp(cf)
	local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if hrp and cf then
		hrp.CFrame = cf
	end
end

local function GetEnemyQuest()
	local QuestN = GetQuest()
	local Quests = Player.Quests

	if QuestN and Quests:FindFirstChild(QuestN) then
		local CurQuest = Quests:FindFirstChild(QuestN)
		return CurQuest:GetAttribute("Objective")
	end

	return nil
end

local function AcceptQuest(QuestN)
	local isQuesting = Player.Quests:FindFirstChild(QuestN)
	local Quest = string.gsub(QuestN, " ", "")
	local QuestUi = Player.PlayerGui:WaitForChild("InteractUI"):WaitForChild("Main")
	if not isQuesting then
		for _, v in pairs(workspace.Interact.Quest:GetChildren()) do
		   if v:IsA("Model") and v.Name == Quest then
				local hrp = v:FindFirstChild("HumanoidRootPart")
				QuestPos = hrp.CFrame * CFrame.new(0, 0, -5)
				Class:tween(QuestPos)
				task.wait(0.5)
				Class:Click()
				if not QuestUi.ButtonFrame:FindFirstChild("Yes") then
					Class:Click()
				elseif QuestUi.ButtonFrame:FindFirstChild("Yes") then
					firesignal(QuestUi.ButtonFrame.Yes.Button.MouseButton1Click)
				end
			end
		end
	end
end

local function M1()
	Remote.BridgeNet2:FireServer({{ "M1", CFrame.new(0, 0, 0), CFrame.new(0, 0, 0) }, "\4"})
end

local function FindEnemy()
	local targetName = GetEnemyQuest()
	for _, mob in pairs(workspace.Live:GetChildren()) do
		if mob.Name == targetName and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
			return mob
		end
	end
	return nil
end

function AutoFarmLevel()
	local Quest = GetQuest()
	AcceptQuest(Quest)

	local enemy = FindEnemy()
	if enemy then
		tp(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5))
		repeat
			if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
				M1()
			end
			task.wait(0.3)
		until not enemy or not enemy:FindFirstChild("Humanoid") or enemy.Humanoid.Health <= 0 or not Config["Farm Config"].AutoFarmLevel
	end
end

task.spawn(function()
	while true do
		task.wait(1)
		if Config["Farm Config"].AutoFarmLevel then
			AutoFarmLevel()
		end
	end
end)

local QuotesTable = {
	"A ghost of a memory.",
	"When the past whispers through the present.",
	"Echoes of another time.",
	"Moments suspended in time.",
	"Faded Polaroids in the mind.",
	"The scent of yesterday.",
	"Where time folded and memory slipped through.",
}
local Quotes = QuotesTable[math.random(1, #QuotesTable)]

local Window = Compkiller.new({
	Name = "Aozora Hub",
	Keybind = "LeftAlt",
	Logo = "rbxassetid://120245531583106",
	TextSize = 15,
})

local Watermark = Window:Watermark()
local Quote = Watermark:AddText({Icon = "pencil", Text = Quotes})
local Time = Watermark:AddText({Icon = "timer", Text = "TIME"})

task.spawn(function()
	while true do
		task.wait()
		Time:SetText(Compkiller:GetTimeNow())
	end
end)

local FarmTabs = Window:DrawContainerTab({
	Name = "Farm",
	Icon = "contact",
})

local FarmLevelTab = FarmTabs:DrawTab({
	Name = "Level Farm",
	Type = "Single",
	EnableScrolling = true, 
})

local FarmLevelSection = FarmLevelTab:DrawSection({
	Name = "Farm Level",
	Position = 'left'	
})

FarmLevelSection:AddButton({
	Name = "test",
	Callback = function()
		AutoFarmLevel()
	end,
})

local AutoFarmLevelTog = FarmLevelSection:AddToggle({
	Name = "Auto Farm Level",
	Default = false,
	Callback = function(State)
		Config["Farm Config"].AutoFarmLevel = State 
	end,
})

local FarmLevelOption = AutoFarmLevelTog.Link:AddOption()
FarmLevelOption:AddToggle({
	Name = "Boss Allow ?",
	Callback = function(State) 
		Config["Farm Config"].BossAllow = State 
	end,
})
FarmLevelOption:AddToggle({
	Name = "Safe Farm",
	Callback = function(State)
	end
})

local ThemeTab = Window:DrawTab({
	Icon = "paintbrush",
	Name = "Themes",
	Type = "Single"
})

ThemeTab:DrawSection({
	Name = "UI Themes"
}):AddDropdown({
	Name = "Select Theme",
	Default = "Default",
	Values = {
		"Default",
		"Dark Green",
		"Dark Blue",
		"Purple Rose",
		"Skeet"
	},
	Callback = function(v)
		Compkiller:SetTheme(v)
	end,
})

local ConfigUI = Window:DrawConfig({
	Name = "Config",
	Icon = "folder",
	Config = ConfigManager
})
ConfigUI:Init()
