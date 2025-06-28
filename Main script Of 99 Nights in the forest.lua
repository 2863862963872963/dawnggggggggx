local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Yen = LocalPlayer.GameData.Yen
local UnitSlots = LocalPlayer.PlayerGui.Main.UnitsFrame.UnitsSlot

local PlaceRemote = ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("spawnunit")
local ManageUnits = ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("ManageUnits")

local Macro = {}
local currentId = 1
local isRecording = false
local isPlaying = false
local FILE_NAME = "macro_record.json"

local function GetUnitCost(unitName)
	for _, desc in pairs(UnitSlots:GetDescendants()) do
		if desc:IsA("Frame") and desc.Name:lower() == unitName:lower() then
			local yenLabel = desc:FindFirstChild("yen")
			if yenLabel and yenLabel:IsA("TextLabel") then
				local cost = tonumber(string.match(yenLabel.Text, "%d+"))
				if cost then
					return cost
				end
			end
		end
	end
	return 0
end

local function recordAction(actionType, unitName, cf, spent)
	local actionData = {
		type = actionType,
		unit = unitName,
		money = spent or GetUnitCost(unitName)
	}
	if cf then
		local components = { cf:GetComponents() }
		actionData.cframe = table.concat(components, ", ")
	end
	Macro[tostring(currentId)] = actionData
	currentId += 1
end

function StartRecording()
	Macro = {}
	currentId = 1
	isRecording = true
end

function StopRecording()
	isRecording = false
	pcall(function()
		writefile(FILE_NAME, HttpService:JSONEncode(Macro))
	end)
end

function parseCFrame(str)
	local parts = {}
	for num in string.gmatch(str, "-?%d+%.?%d*") do
		table.insert(parts, tonumber(num))
	end
	if #parts == 12 then
		return CFrame.new(unpack(parts))
	end
	return nil
end

function PlayMacro(file)
	if isPlaying then return end
	if not isfile(file) then return end
	isPlaying = true
	local success, result = pcall(function()
		local raw = readfile(file)
		if not raw or raw == "" then return end
		local data = HttpService:JSONDecode(raw)
		for i = 1, math.huge do
			local action = data[tostring(i)]
			if not action then break end
			repeat task.wait(0.2) until Yen.Value >= (action.money or 0)
			if action.type == "SpawnUnit" and action.cframe then
				local cf = parseCFrame(action.cframe)
				local uuid = GetUnitUUID(action.unit)
				if uuid and cf then
					PlaceRemote:InvokeServer({ action.unit, cf, 0 }, uuid)
				end
			elseif action.type == "Selling" or action.type == "Upgrade" then
				local unit = Workspace.Ground.unitClient:FindFirstChild(action.unit)
				if unit then
					ManageUnits:InvokeServer(action.type, unit.Name)
				end
			end
		end
	end)
	isPlaying = false
end

function GetUnitUUID(unitName)
	for _, desc in pairs(UnitSlots:GetDescendants()) do
		if desc:IsA("StringValue") and desc.Name == unitName then
			return desc.Value
		end
	end
	return nil
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = { ... }
	local method = getnamecallmethod()
	if not checkcaller() and isRecording then
		if tostring(self) == "spawnunit" and method == "InvokeServer" then
			local unitName = args[1][1]
			local cf = args[1][2]
			task.delay(0.3, function()
				recordAction("SpawnUnit", unitName, cf, nil)
			end)
	end
	return oldNamecall(self, unpack(args))
end))

StartRecording()
task.wait(20)
StopRecording()
