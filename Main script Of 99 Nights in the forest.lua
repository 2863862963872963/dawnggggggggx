local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Yen = LocalPlayer.GameData.Yen
local UnitSlots = LocalPlayer.PlayerGui.Main.UnitsFrame.UnitsSlot

local PlaceRemote = ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("spawnunit")
local ManageUnits = ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("ManageUnits")

-- Macro data
local macro = { Data = { Actions = {}, Map = Workspace.GameSettings.Stages.Value or "Unknown" } }
local currentStep = 1
local uniqueIDCounter = 0
local isRecording = false
local isPlaying = false
local FILE_NAME = "macro_record.json"

-- Gán UniqueID khi unit xuất hiện
Workspace.Ground.unitClient.ChildAdded:Connect(function(unit)
	if not unit:IsA("Model") then return end
	if unit:GetAttribute("UniqueID") then return end
	if unit:GetAttribute("Owner") ~= LocalPlayer.Name then return end

	uniqueIDCounter = uniqueIDCounter + 1
	unit:SetAttribute("UniqueID", uniqueIDCounter)
	print("✅ UniqueID:", uniqueIDCounter, "cho unit", unit.Name)
end)

-- Recording
function StartRecording()
	macro.Data = { Actions = {}, Map = Workspace.GameSettings.Stages.Value or "Unknown" }
	currentStep = 1
	uniqueIDCounter = 0
	isRecording = true
	print("🔴 Start recording")
end

function StopRecording()
	isRecording = false
	local success, errorMsg = pcall(function()
		writefile(FILE_NAME, HttpService:JSONEncode(macro))
	end)
	if success then
		print("🟡 Saved to", FILE_NAME)
	else
		warn("❌ Failed to save macro:", errorMsg)
	end
end

-- Tìm unit theo UniqueID
function findUnitByID(id)
	for _, u in ipairs(Workspace.Ground.unitClient:GetChildren()) do
		if u:GetAttribute("UniqueID") == id then
			return u
		end
	end
	return nil
end

-- Get Unit Cost
function GetUnitCost(unitName)
	for _, desc in pairs(UnitSlots:GetDescendants()) do
		if desc:IsA("Frame") and desc.Name == unitName then
			local yenLabel = desc:FindFirstChild("yen")
			if yenLabel and yenLabel:IsA("TextLabel") then
				local cost = tonumber(string.match(yenLabel.Text, "%d+"))
				if cost then
					return cost
				else
					warn("❌ Cannot parse cost for unit:", unitName)
				end
			else
				warn("❌ Yen label not found for unit:", unitName)
			end
		end
	end
	warn("❌ Unit not found in UnitSlots:", unitName)
	return nil
end

-- Get Unit UUID
function GetUnitUUID(unitName)
	for _, desc in pairs(UnitSlots:GetDescendants()) do
		if desc:IsA("StringValue") and desc.Name == unitName then
			return desc.Value
		end
	end
	warn("❌ UUID not found for unit:", unitName)
	return nil
end

-- Playback
function PlayMacro(file)
	if isPlaying then
		warn("❌ Macro is already playing")
		return
	end
	if not isfile(file) then
		warn("❌ File not found:", file)
		return
	end

	isPlaying = true
	uniqueIDCounter = 0 -- Reset UniqueID

	local success, result = pcall(function()
		local raw = readfile(file)
		if not raw or raw == "" then
			error("❌ File is empty or corrupted")
		end
		local data = HttpService:JSONDecode(raw)
		if type(data) ~= "table" or type(data.Data) ~= "table" or type(data.Data.Actions) ~= "table" then
			error("❌ Macro format invalid or corrupted")
		end

		-- Kiểm tra map
		if data.Data.Map ~= Workspace.GameSettings.Stages.Value then
			warn("⚠️ Warning: Current map (" .. Workspace.GameSettings.Stages.Value .. ") does not match macro map (" .. data.Data.Map .. ")")
		end

       table.sort(data.Data.Actions, function(a, b)
			return a.Step < b.Step
		end)
		
		for _, action in ipairs(data.Data.Actions) do
			local cost = action.Cost or 0
			local timeout = 30 
			local startTime = tick()

			-- Chờ đủ Yen
			repeat
				task.wait(0.2)
				if tick() - startTime > timeout then
					warn("❌ Timeout waiting for Yen for unit:", action.Unit)
					isPlaying = false
					return
				end
			until Yen.Value >= cost

			if action.Action == "Place" then
				local cf = CFrame.new(action.CFrame.X, action.CFrame.Y, action.CFrame.Z)
				local uuid = GetUnitUUID(action.Unit)
				if uuid then
					local success, result = PlaceRemote:InvokeServer({ action.Unit, cf, 0 }, uuid)
					if not success then
						warn("❌ Failed to place unit:", action.Unit, "Error:", result)
					end
				else
					warn("❌ UUID not found for unit:", action.Unit)
				end

			elseif action.Action == "Sell" then
				local unit = findUnitByID(action.UniqueID)
				if unit then
					local success, result = ManageUnits:InvokeServer("Selling", unit.Name)
					if not success then
						warn("❌ Failed to sell unit:", unit.Name, "Error:", result)
					end
				else
					warn("❌ Unit not found by ID:", action.UniqueID, "Skipping sell action")
				end
			end
		end
	end)

	isPlaying = false
	if success then
		print("✅ Macro replay completed")
	else
		warn("❌ Error during macro:", result)
	end
end

-- Hook namecall
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = { ... }
	local method = getnamecallmethod()

	if not checkcaller() and isRecording then
		if tostring(self) == "spawnunit" and method == "InvokeServer" then
			if type(args[1]) == "table" and args[1][1] and args[1][2] then
				table.insert(macro.Data.Actions, {
					Step = currentStep,
					Unit = args[1][1],
					CFrame = { X = args[1][2].X, Y = args[1][2].Y, Z = args[1][2].Z },
					Action = "Place",
					Cost = GetUnitCost(args[1][1]) or 0
				})
				currentStep += 1
			else
				warn("❌ Invalid arguments for spawnunit:", args)
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
				else
					warn("❌ Unit not found for action:", actionType, unitName)
				end
			end
		end
	end
	return oldNamecall(self, unpack(args))
end))

print("✅ Macro system ready. Use StartRecording(), StopRecording(), PlayMacro('macro_record.json')")

-- Test
StartRecording()
task.wait(10)
StopRecording()
