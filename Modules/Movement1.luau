-- MovementModule.luau
-- A simplified, reliable movement system for Roblox

local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local MovementModule = {}
local activeMovements = {}

-- Internal function to stop any existing movement for a character
local function stopCurrentMovement(character)
	if activeMovements[character] then
		activeMovements[character]:Disconnect()
		activeMovements[character] = nil
	end
end

-- Teleport instantly
function MovementModule.Teleport(character, target)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return warn("No HumanoidRootPart found!") end
	
	stopCurrentMovement(character)
	
	local targetCFrame = typeof(target) == "Vector3" and CFrame.new(target) or target
	rootPart.CFrame = targetCFrame
end

-- Walk to a destination using Pathfinding
function MovementModule.WalkTo(character, targetPosition)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	
	if not humanoid or not rootPart then return warn("Invalid Character for walking") end
	
	stopCurrentMovement(character)
	
	-- Create Path
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
	})
	
	local success, errorMessage = pcall(function()
		path:ComputeAsync(rootPart.Position, targetPosition)
	end)
	
	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		local currentWaypointIndex = 2 -- Skip the starting point
		
		local connection
		connection = RunService.Heartbeat:Connect(function()
			if not character.Parent or humanoid.Health <= 0 then
				connection:Disconnect()
				return
			end
			
			if currentWaypointIndex <= #waypoints then
				local waypoint = waypoints[currentWaypointIndex]
				humanoid:MoveTo(waypoint.Position)
				
				if waypoint.Action == Enum.PathfindingWaypointAction.Jump then
					humanoid.Jump = true
				end
				
				-- Check if reached waypoint
				if (rootPart.Position - waypoint.Position).Magnitude < 3 then
					currentWaypointIndex += 1
				end
			else
				connection:Disconnect()
				activeMovements[character] = nil
			end
		end)
		
		activeMovements[character] = connection
	else
		warn("Pathfinding failed: " .. (errorMessage or "Unknown error"))
		-- Fallback to basic MoveTo if pathfinding fails
		humanoid:MoveTo(targetPosition)
	end
end

return MovementModule
