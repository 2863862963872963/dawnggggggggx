local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Yen = LocalPlayer.GameData.Yen
local UnitSlots = LocalPlayer.PlayerGui.Main.UnitsFrame.UnitsSlot

local PlaceRemote = ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("spawnunit")
local ManageUnits = ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("ManageUnits")

local macro = { Data = { Actions = {}, Map = Workspace.GameSettings.Stages.Value or "Unknown" } }
local currentStep = 1
local uniqueIDCounter = 0
local isRecording = false
local isPlaying = false
local FILE_NAME = "macro_record.json"

Workspace.Ground.unitClient.ChildAdded:Connect(function(unit)
	if not unit:IsA("Model") then return end
	if unit:GetAttribute("UniqueID") then return end
	if unit:GetAttribute("Owner") ~= LocalPlayer.Name then return end
	uniqueIDCounter += 1
	unit:SetAttribute("UniqueID", uniqueIDCounter)
end)

function StartRecording()
	macro.Data = { Actions = {}, Map = Workspace.GameSettings.Stages.Value or "Unknown" }
	currentStep = 1
	uniqueIDCounter = 0
	isRecording = true
end

function StopRecording()
	isRecording = false
	pcall(function()
		writefile(FILE_NAME, HttpService:JSONEncode(macro))
	end)
end

function findUnitByID(id)
	for _, u in ipairs(Workspace.Ground.unitClient:GetChildren()) do
		if u:GetAttribute("UniqueID") == id then
			return u
		end
	end
	return nil
end

function GetUnitCost(unitName)
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

print(GetUnitCost("Subaro"))

function GetUnitUUID(unitName)
	for _, desc in pairs(UnitSlots:GetDescendants()) do
		if desc:IsA("StringValue") and desc.Name == unitName then
			return desc.Value
		end
	end
	return nil
end

function PlayMacro(file)
	if isPlaying then return end
	if not isfile(file) then return end
	isPlaying = true
	uniqueIDCounter = 0
	local success, result = pcall(function()
		local raw = readfile(file)
		if not raw or raw == "" then return end
		local data = HttpService:JSONDecode(raw)
		if type(data) ~= "table" or type(data.Data) ~= "table" or type(data.Data.Actions) ~= "table" then return end
		table.sort(data.Data.Actions, function(a, b)
			return a.Step < b.Step
		end)
		for _, action in ipairs(data.Data.Actions) do
			repeat task.wait(0.2) until Yen.Value >= (action.Cost or 0)
			if action.Action == "Place" then
				local cf = CFrame.new(action.CFrame.X, action.CFrame.Y, action.CFrame.Z)
				local uuid = GetUnitUUID(action.Unit)
				if uuid then
					PlaceRemote:InvokeServer({ action.Unit, cf, action.Cost or 0 }, uuid)
				end
			elseif action.Action == "Sell" then
				local unit = findUnitByID(action.UniqueID)
				if unit then
					ManageUnits:InvokeServer("Selling", unit.Name)
				end
			end
		end
	end)
	isPlaying = false
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = { ... }
	local method = getnamecallmethod()
	if not checkcaller() and isRecording then
		if tostring(self) == "spawnunit" and method == "InvokeServer" then
			if type(args[1]) == "table" and args[1][1] and args[1][2] then
				local unitName = args[1][1]
				local unitCost = GetUnitCost(tostring(unitName))
				table.insert(macro.Data.Actions, {
					Step = currentStep,
					Unit = unitName,
					CFrame = {
						X = args[1][2].X,
						Y = args[1][2].Y,
						Z = args[1][2].Z,
					},
					Action = "Place",
					Cost = unitCost or 0
				})
				currentStep += 1
			end
		elseif tostring(self) == "ManageUnits" and method == "InvokeServer" then
			local actionType, unitName = args[1], args[2]
			if actionType == "Upgrade" or actionType == "Selling" then
				local unit = Workspace.Ground.unitClient:FindFirstChild(unitName)
				local id = unit and unit:GetAttribute("UniqueID")
				if id then
					table.insert(macro.Data.Actions, {
						Step = currentStep,
						Unit = unitName,
						UniqueID = id,
						Action = actionType == "Selling" and "Sell" or actionType,
						Cost = 0
					})
					currentStep += 1
				end
			end
		end
	end
	return oldNamecall(self, unpack(args))
end))

StartRecording()
task.wait(20)
StopRecording()
