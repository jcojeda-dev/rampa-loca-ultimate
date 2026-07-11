--!strict

--[[
	TaskScheduler handles delayed and repeating tasks without using legacy wait/spawn patterns.
]]

local Types = require(script.Parent.Parent.Types.Types)

local TaskScheduler = {}
TaskScheduler.__index = TaskScheduler

type TaskHandle = Types.TaskHandle

type TaskSchedulerInstance = {
	_tasks: {[number]: TaskHandle},
	_counter: number,
	Schedule: (self: TaskSchedulerInstance, callback: () -> (), delay: number) -> TaskHandle,
	ScheduleRepeating: (self: TaskSchedulerInstance, callback: () -> (), interval: number) -> TaskHandle,
	Cancel: (self: TaskSchedulerInstance, handle: TaskHandle) -> (),
	Destroy: (self: TaskSchedulerInstance) -> (),
}

function TaskScheduler.new(): TaskSchedulerInstance
	local self = setmetatable({
		_tasks = {},
		_counter = 0,
	}, TaskScheduler)

	return self
end

function TaskScheduler:Schedule(callback: () -> (), delay: number): TaskHandle
	assert(type(callback) == "function", "Callback must be a function")
	assert(type(delay) == "number", "Delay must be a number")

	self._counter += 1
	local handle: TaskHandle = {
		Id = self._counter,
		Active = true,
	}

	task.spawn(function()
		task.wait(delay)
		if handle.Active then
			callback()
		end
	end)

	self._tasks[handle.Id] = handle
	return handle
end

function TaskScheduler:ScheduleRepeating(callback: () -> (), interval: number): TaskHandle
	assert(type(callback) == "function", "Callback must be a function")
	assert(type(interval) == "number", "Interval must be a number")

	self._counter += 1
	local handle: TaskHandle = {
		Id = self._counter,
		Active = true,
	}

	task.spawn(function()
		while handle.Active do
			task.wait(interval)
			if handle.Active then
				callback()
			end
		end
	end)

	self._tasks[handle.Id] = handle
	return handle
end

function TaskScheduler:Cancel(handle: TaskHandle): ()
	if handle ~= nil then
		handle.Active = false
		self._tasks[handle.Id] = nil
	end
end

function TaskScheduler:Destroy(): ()
	for _, handle in pairs(self._tasks) do
		self:Cancel(handle)
	end

	self._tasks = {}
end

return TaskScheduler
