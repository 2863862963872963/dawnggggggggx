local RunService = game:GetService("RunService")

local SMOOTH_FACTOR = 0.12
local DEFAULT_BUDGET = 0.012
local DEFER_THRESHOLD = 86
local POOL_SIZE = 64

local function _swap(h, a, b)
	h[a], h[b] = h[b], h[a]
	h[a]._idx = a
	h[b]._idx = b
end

local function _up(h, i)
	while i > 1 do
		local p = i // 2
		if h[p].priority > h[i].priority then
			_swap(h, p, i)
			i = p
		else break end
	end
end

local function _down(h, i)
	local n = #h
	while true do
		local s, l, r = i, i*2, i*2+1
		if l <= n and h[l].priority < h[s].priority then s = l end
		if r <= n and h[r].priority < h[s].priority then s = r end
		if s == i then break end
		_swap(h, i, s)
		i = s
	end
end

local function _push(h, t)
	local i = #h + 1
	h[i] = t
	t._idx = i
	_up(h, i)
end

local function _pop(h)
	local n = #h
	if n == 0 then return nil end
	local top = h[1]
	h[1] = h[n]
	h[1]._idx = 1
	h[n] = nil
	if n > 1 then _down(h, 1) end
	top._idx = nil
	return top
end

local function _removeAt(h, i)
	local n = #h
	if i == n then
		local t = h[n]
		h[n] = nil
		t._idx = nil
		return t
	end
	_swap(h, i, n)
	local removed = h[n]
	h[n] = nil
	removed._idx = nil
	_up(h, i)
	_down(h, i)
	return removed
end

local LoopHandler = {}
LoopHandler.__index = LoopHandler

LoopHandler.Priority = {CRITICAL = 5, HIGH = 20, NORMAL = 50, LOW = 70, IDLE = 90}

function LoopHandler.new(event, budgetSeconds, deferThreshold)
	local self = setmetatable({}, LoopHandler)
	self._event = event or "Heartbeat"
	self._budget = budgetSeconds or DEFAULT_BUDGET
	self._defer = deferThreshold or DEFER_THRESHOLD
	self._running = false
	self._conn = nil
	self._nextId = 1
	self._smoothDt = 0
	self._heap = {}
	self._byId = {}
	self._pool = {}
	self._poolTop = 0
	for i = 1, POOL_SIZE do
		self._pool[i] = {id = 0, cb = nil, priority = 50, once = false, _idx = nil}
		self._poolTop = i
	end
	return self
end

function LoopHandler:_acquire(cb, priority, once)
	local task
	if self._poolTop > 0 then
		task = self._pool[self._poolTop]
		self._pool[self._poolTop] = nil
		self._poolTop -= 1
	else
		task = {}
	end
	task.id = self._nextId
	task.cb = cb
	task.priority = priority
	task.once = once
	task._idx = nil
	self._nextId += 1
	return task
end

function LoopHandler:_recycle(task)
	self._byId[task.id] = nil
	task.cb = nil
	task.id = 0
	task.priority = 50
	task.once = false
	task._idx = nil
	self._poolTop += 1
	self._pool[self._poolTop] = task
end

function LoopHandler:_tick(dt)
	local t0 = os.clock()
	local heap = self._heap
	self._smoothDt = self._smoothDt + SMOOTH_FACTOR * (dt - self._smoothDt)
	local sdt = self._smoothDt
	local snap = #heap
	local once_q = {}

	for _ = 1, snap do
		local task = heap[1]
		if not task then break end
		if task.priority >= self._defer and (os.clock() - t0) >= self._budget then
			break
		end

		_pop(heap)

		local ok, err = pcall(task.cb, dt, sdt)
		if not ok then
			warn(("[LoopHandler] id=" .. task.id .. " → " .. tostring(err)))
		end

		if task.once then
			once_q[#once_q + 1] = task
		else
			_push(heap, task)
		end
	end

	for _, t in ipairs(once_q) do
		self:_recycle(t)
	end
end

function LoopHandler:Add(cb, priority)
	if type(cb) ~= "function" then return end
	priority = priority or LoopHandler.Priority.NORMAL
	local task = self:_acquire(cb, priority, false)
	self._byId[task.id] = task
	_push(self._heap, task)
	return task.id
end

function LoopHandler:RunOnce(cb, priority)
	if type(cb) ~= "function" then return end
	priority = priority or LoopHandler.Priority.HIGH
	local task = self:_acquire(cb, priority, true)
	self._byId[task.id] = task
	_push(self._heap, task)
	return task.id
end

function LoopHandler:Remove(id)
	local task = self._byId[id]
	if not task or not task._idx then return false end
	_removeAt(self._heap, task._idx)
	self:_recycle(task)
	return true
end

function LoopHandler:SetPriority(id, newPriority)
	local task = self._byId[id]
	if not task or not task._idx then return false end
	_removeAt(self._heap, task._idx)
	task.priority = newPriority
	_push(self._heap, task)
	return true
end

function LoopHandler:Start()
	if self._running then return self end
	self._running = true
	self._conn = RunService[self._event]:Connect(function(dt)
		self:_tick(dt)
	end)
	return self
end

function LoopHandler:Pause()
	if not self._running then return self end
	self._running = false
	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end
	return self
end

function LoopHandler:Resume()
	return self:Start()
end

function LoopHandler:Destroy()
	self:Pause()
	for _, task in ipairs(self._heap) do
		self:_recycle(task)
	end
	self._heap = {}
	self._byId = {}
	self._pool = {}
	self._poolTop = 0
end

function LoopHandler:GetSmoothDelta()
	return self._smoothDt
end

function LoopHandler:TaskCount()
	return #self._heap
end

return LoopHandler
