local RunService = game:GetService("RunService")

local LoopManager = {}
local ActiveLoops = {}

function LoopManager:Add(name, checkFlag, loopFn)
	if ActiveLoops[name] then return end

	if checkFlag() then
		ActiveLoops[name] = RunService.RenderStepped:Connect(function()
			if not checkFlag() then
				self:Remove(name)
			else
				loopFn()
			end
		end)
	end
end

function LoopManager:ForceStart(name, loopFn)
	if ActiveLoops[name] then return end
	ActiveLoops[name] = RunService.RenderStepped:Connect(loopFn)
end

function LoopManager:Remove(name)
	if ActiveLoops[name] then
		ActiveLoops[name]:Disconnect()
		ActiveLoops[name] = nil
	end
end

function LoopManager:Restart(name, checkFlag, loopFn)
	self:Remove(name)
	self:Add(name, checkFlag, loopFn)
end

_G.LoopManager = LoopManager 

