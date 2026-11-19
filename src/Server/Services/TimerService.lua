--!strict

local TimerService = {}
TimerService.__index = TimerService

type TimerServiceInstance = {
	Name: string,
	_active: boolean,
	_duration: number,
	_remaining: number,
	_onTick: ((number) -> ())?,
	_onComplete: (() -> ())?,
	Init: (self: TimerServiceInstance) -> (),
	Start: (self: TimerServiceInstance, duration: number, onTick: ((number) -> ())?, onComplete: (() -> ())?) -> (),
	Stop: (self: TimerServiceInstance) -> (),
	Update: (self: TimerServiceInstance, dt: number) -> (),
	GetRemaining: (self: TimerServiceInstance) -> number,
	IsActive: (self: TimerServiceInstance) -> boolean,
	IsExpired: (self: TimerServiceInstance) -> boolean,
}

function TimerService.new(): TimerServiceInstance
	local self = setmetatable({
		Name = "TimerService",
		_active = false,
		_duration = 0,
		_remaining = 0,
		_onTick = nil,
		_onComplete = nil,
	}, TimerService)

	return self
end

function TimerService:Init(): ()
	self._active = false
end

function TimerService:Start(duration: number, onTick: ((number) -> ())?, onComplete: (() -> ())?): ()
	assert(type(duration) == "number" and duration >= 0, "Duration must be a non-negative number")

	self._duration = duration
	self._remaining = duration
	self._active = true
	self._onTick = onTick
	self._onComplete = onComplete
end

function TimerService:Stop(): ()
	self._active = false
	self._onTick = nil
	self._onComplete = nil
end

function TimerService:Update(dt: number): ()
	assert(type(dt) == "number" and dt >= 0, "Delta time must be a non-negative number")
	if not self._active then
		return
	end

	self._remaining = math.max(0, self._remaining - dt)
	if self._onTick ~= nil then
		self._onTick(self._remaining)
	end

	if self._remaining <= 0 then
		self._active = false
		if self._onComplete ~= nil then
			self._onComplete()
		end
	end
end

function TimerService:GetRemaining(): number
	return self._remaining
end

function TimerService:IsActive(): boolean
	return self._active
end

function TimerService:IsExpired(): boolean
	return self._remaining <= 0
end

return TimerService
