--!strict

--[[
	EventBus provides a lightweight publish/subscribe layer for cross-module communication.
]]

local Signal = require(script.Parent.Parent.Modules.Signal)
local Types = require(script.Parent.Parent.Types.Types)

local EventBus = {}
EventBus.__index = EventBus

type SignalInstance = typeof(Signal.new())
type EventHandler = Types.EventHandler

type EventBusInstance = {
	_events: {[string]: SignalInstance},
	Connect: (self: EventBusInstance, eventName: string, handler: EventHandler) -> Types.Connection,
	Once: (self: EventBusInstance, eventName: string, handler: EventHandler) -> Types.Connection,
	Fire: any,
	Disconnect: (self: EventBusInstance, eventName: string) -> (),
	Destroy: (self: EventBusInstance) -> (),
}

function EventBus.new(): EventBusInstance
	local self = setmetatable({
		_events = {},
	}, EventBus)

	return self
end

function EventBus:_GetSignal(eventName: string): SignalInstance
	local signal = self._events[eventName]
	if signal == nil then
		signal = Signal.new()
		self._events[eventName] = signal
	end

	return signal
end

function EventBus:Connect(eventName: string, handler: EventHandler): Types.Connection
	assert(type(eventName) == "string" and eventName ~= "", "Event name must be a non-empty string")
	assert(type(handler) == "function", "Handler must be a function")
	return self:_GetSignal(eventName):Connect(handler)
end

function EventBus:Once(eventName: string, handler: EventHandler): Types.Connection
	assert(type(eventName) == "string" and eventName ~= "", "Event name must be a non-empty string")
	assert(type(handler) == "function", "Handler must be a function")
	return self:_GetSignal(eventName):Once(handler)
end

function EventBus:Fire(eventName: string, ...)
	assert(type(eventName) == "string" and eventName ~= "", "Event name must be a non-empty string")
	local signal = self._events[eventName]
	if signal ~= nil then
		signal:Fire(...)
	end
end

function EventBus:Disconnect(eventName: string): ()
	self._events[eventName] = nil
end

function EventBus:Destroy(): ()
	for eventName, signal in pairs(self._events) do
		signal:Destroy()
		self._events[eventName] = nil
	end
end

return EventBus
