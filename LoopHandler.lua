--[[
	LoopHandler — Numeric Priority Loop Manager for Roblox
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	Priority is any number. LOWER number = runs FIRST.
	  e.g.  1 runs before 50, 50 runs before 100

	Features:
	  • Numeric priority (1–100, or any number)
	  • Min-heap queue → O(log n) insert, O(log n) remove, O(1) peek
	  • Frame-budget: tasks above DEFER_THRESHOLD are skipped when over budget
	  • Delta-time EMA smoothing
	  • Object pooling → near-zero GC at steady state
	  • One-shot tasks (RunOnce)
	  • SetPriority — change a task's priority at runtime
	  • Pause / Resume / Destroy

	Suggested conventions (you can use any numbers):
	  1  – 10   Critical  (input, anti-cheat)
	  11 – 30   High      (physics, movement)
	  31 – 60   Normal    (game logic)
	  61 – 85   Low       (UI updates, cosmetics)
	  86 – 100  Idle      (AI, particles — deferred when over budget)

	Usage:
	  local LoopHandler = require(path.to.LoopHandler)
	  local loop = LoopHandler.new()
	  loop:Start()

	  local id = loop:Add(function(dt, smoothDt)
	      -- do task   (priority 10 → runs first)
	  end, 10)

	  loop:Add(function(dt)
	      -- sell item (priority 50 → runs after)
	  end, 50)

	  loop:SetPriority(id, 5)   -- promote at runtime
	  loop:Remove(id)
	  loop:Destroy()
--]]

local RunService = game:GetService("RunService")

-- ── Config ────────────────────────────────────────────────────────────────────
local SMOOTH_FACTOR   = 0.12   -- EMA weight  (higher = reacts faster to spikes)
local DEFAULT_BUDGET  = 0.012  -- seconds; tasks at IDLE priority skip if exceeded
local DEFER_THRESHOLD = 86     -- priority >= this value may be deferred
local POOL_SIZE       = 64     -- pre-allocated task descriptor slots

-- ── Min-Heap helpers ──────────────────────────────────────────────────────────
-- heap[1] is always the lowest-priority-number task (i.e. the one that runs first)

local function _swap(heap, a, b)
	heap[a], heap[b] = heap[b], heap[a]
	heap[a]._idx = a
	heap[b]._idx = b
end

local function _up(heap, i)
	while i > 1 do
		local p = math.floor(i / 2)
		if heap[p].priority > heap[i].priority then
			_swap(heap, p, i)
			i = p
		else break end
	end
end

local function _down(heap, i)
	local n = #heap
	while true do
		local s, l, r = i, i * 2, i * 2 + 1
		if l <= n and heap[l].priority < heap[s].priority then s = l end
		if r <= n and heap[r].priority < heap[s].priority then s = r end
		if s == i then break end
		_swap(heap, i, s)
		i = s
	end
end

local function _push(heap, task)
	local i = #heap + 1
	heap[i] = task
	task._idx = i
	_up(heap, i)
end

local function _pop(heap)
	local n = #heap
	if n == 0 then return nil end
	local top = heap[1]
	heap[1] = heap[n]
	heap[1]._idx = 1
	heap[n] = nil
	if n > 1 then _down(heap, 1) end
	top._idx = nil
	return top
end

local function _removeAt(heap, i)
	local n = #heap
	if i == n then
		local t = heap[n]; heap[n] = nil; t._idx = nil; return t
	end
	_swap(heap, i, n)
	local removed = heap[n]; heap[n] = nil; removed._idx = nil
	_up(heap, i)
	_down(heap, i)
	return removed
end

-- ── Module ────────────────────────────────────────────────────────────────────
local LoopHandler = {}
LoopHandler.__index = LoopHandler

LoopHandler.Priority = {
	CRITICAL = 5,
	HIGH     = 20,
	NORMAL   = 50,
	LOW      = 70,
	IDLE     = 90,  -- deferred when frame is over budget
}

-- ── Constructor ───────────────────────────────────────────────────────────────
---@param event          string?  "Heartbeat" | "RenderStepped" | "Stepped"
---@param budgetSeconds  number?  frame budget in seconds before IDLE tasks are skipped
---@param deferThreshold number?  priority value at which tasks become deferrable
function LoopHandler.new(event, budgetSeconds, deferThreshold)
	local self = setmetatable({}, LoopHandler)
	self._event     = event          or "Heartbeat"
	self._budget    = budgetSeconds  or DEFAULT_BUDGET
	self._defer     = deferThreshold or DEFER_THRESHOLD
	self._running   = false
	self._conn      = nil
	self._nextId    = 1
	self._smoothDt  = 0
	self._heap      = {}     -- min-heap
	self._byId      = {}     -- id → task  (O(1) lookup)

	-- Object pool
	self._pool    = {}
	self._poolTop = 0
	for i = 1, POOL_SIZE do
		self._pool[i] = { id = 0, cb = nil, priority = 50, once = false, _idx = nil }
		self._poolTop = i
	end
	return self
end

-- ── Private ───────────────────────────────────────────────────────────────────
function LoopHandler:_acquire(cb, priority, once)
	local task
	if self._poolTop > 0 then
		task = self._pool[self._poolTop]
		self._pool[self._poolTop] = nil
		self._poolTop -= 1
	else
		task = {}
	end
	task.id       = self._nextId
	task.cb       = cb
	task.priority = priority
	task.once     = once
	task._idx     = nil
	self._nextId  += 1
	return task
end

function LoopHandler:_recycle(task)
	self._byId[task.id] = nil
	task.cb = nil; task.id = 0; task.priority = 50; task.once = false; task._idx = nil
	self._poolTop += 1
	self._pool[self._poolTop] = task
end

function LoopHandler:_tick(dt)
	local t0   = os.clock()
	local heap = self._heap

	-- EMA smooth delta
	self._smoothDt = self._smoothDt + SMOOTH_FACTOR * (dt - self._smoothDt)
	local sdt = self._smoothDt

	-- Snapshot size so tasks added mid-frame run next frame
	local snap    = #heap
	local once_q  = {}

	for _ = 1, snap do
		local task = heap[1]
		if not task then break end

		-- Defer idle-priority tasks if we're over budget
		if task.priority >= self._defer and (os.clock() - t0) >= self._budget then
			break
		end

		_pop(heap)

		local ok, err = pcall(task.cb, dt, sdt)
		if not ok then
			warn(("[LoopHandler] id=%d priority=%d → %s"):format(task.id, task.priority, tostring(err)))
		end

		if task.once then
			once_q[#once_q + 1] = task
		else
			_push(heap, task)   -- re-insert persistent task
		end
	end

	for _, t in ipairs(once_q) do
		self:_recycle(t)
	end
end

-- ── Public API ────────────────────────────────────────────────────────────────

---Add a persistent callback.
---@param cb       fun(dt:number, smoothDt:number)
---@param priority number  Lower number = runs first. Default 50.
---@return number id
function LoopHandler:Add(cb, priority)
	assert(type(cb) == "function", "LoopHandler:Add — cb must be a function")
	priority = priority or LoopHandler.Priority.NORMAL
	local task = self:_acquire(cb, priority, false)
	self._byId[task.id] = task
	_push(self._heap, task)
	return task.id
end

---Add a one-shot callback (auto-removed after first run).
---@param cb fun(dt:number, smoothDt:number)
---@param priority number
---@return number id
function LoopHandler:RunOnce(cb, priority)
	assert(type(cb) == "function", "LoopHandler:RunOnce — cb must be a function")
	priority = priority or LoopHandler.Priority.HIGH
	local task = self:_acquire(cb, priority, true)
	self._byId[task.id] = task
	_push(self._heap, task)
	return task.id
end

---Remove a task by id.
---@param id number
---@return boolean removed
function LoopHandler:Remove(id)
	local task = self._byId[id]
	if not task or not task._idx then return false end
	_removeAt(self._heap, task._idx)
	self:_recycle(task)
	return true
end

---Change the priority of a live task (re-sorts the heap automatically).
---@param id          number
---@param newPriority number
---@return boolean
function LoopHandler:SetPriority(id, newPriority)
	local task = self._byId[id]
	if not task or not task._idx then return false end
	_removeAt(self._heap, task._idx)
	task.priority = newPriority
	_push(self._heap, task)
	return true
end

---Start (or resume) the loop.
function LoopHandler:Start()
	if self._running then return self end
	self._running = true
	self._conn = RunService[self._event]:Connect(function(dt)
		self:_tick(dt)
	end)
	return self
end

---Pause — tasks are preserved, just not called.
function LoopHandler:Pause()
	if not self._running then return self end
	self._running = false
	if self._conn then self._conn:Disconnect(); self._conn = nil end
	return self
end

---Resume after Pause.
function LoopHandler:Resume()
	return self:Start()
end

---Destroy — disconnect and release all resources.
function LoopHandler:Destroy()
	self:Pause()
	for _, task in ipairs(self._heap) do self:_recycle(task) end
	self._heap = {}; self._byId = {}; self._pool = {}; self._poolTop = 0
end

---EMA-smoothed delta time (seconds).
function LoopHandler:GetSmoothDelta() return self._smoothDt end

---Total number of registered tasks.
function LoopHandler:TaskCount() return #self._heap end

return LoopHandler
