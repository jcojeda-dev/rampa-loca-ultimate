--!strict

local CountdownService = {}
CountdownService.__index = CountdownService

type CountdownServiceInstance = {
	Name: string,
	_active: boolean,
	_duration: number,
	_remaining: number,
	_onTick: ((number) -> ())?,
	_onComplete: (() -> ())?,
	Init: (self: CountdownServiceInstance) -> (),
	Start: (self: CountdownServiceInstance, duration: number, onTick: ((number) -> ())?, onComplete: (() -> ())?) -> (),
	Stop: (self: CountdownServiceInstance) -> (),
	Update: (self: CountdownServiceInstance, dt: number) -> (),
	GetRemaining: (self: CountdownServiceInstance) -> number,
	IsActive: (self: CountdownServiceInstance) -> boolean,
}

function CountdownService.new(): CountdownServiceInstance
	local self = setmetatable({
		Name = "CountdownService",
		_active = false,
		_duration = 0,
		_remaining = 0,
		_onTick = nil,
		_onComplete = nil,
	}, CountdownService)

	return self
end

function CountdownService:Init(): ()
	self._active = false
end

function CountdownService:Start(duration: number, onTick: ((number) -> ())?, onComplete: (() -> ())?): ()
	assert(type(duration) == "number" and duration >= 0, "Duration must be a non-negative number")

	self._duration = duration
	self._remaining = duration
	self._active = true
	self._onTick = onTick
	self._onComplete = onComplete
end

function CountdownService:Stop(): ()
	self._active = false
	self._onTick = nil
	self._onComplete = nil
end

function CountdownService:Update(dt: number): ()
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

function CountdownService:GetRemaining(): number
	return self._remaining
end

function CountdownService:IsActive(): boolean
	return self._active
end

return CountdownService
