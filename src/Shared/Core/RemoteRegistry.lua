--!strict

--[[
	RemoteRegistry creates and tracks Remotes under ReplicatedStorage.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utilities = require(script.Parent.Parent.Utilities.Utilities)

local RemoteRegistry = {}
RemoteRegistry.__index = RemoteRegistry

type RemoteRegistryInstance = {
	_folder: Folder,
	_events: {[string]: RemoteEvent},
	_functions: {[string]: RemoteFunction},
	RegisterEvent: (self: RemoteRegistryInstance, name: string) -> RemoteEvent,
	RegisterFunction: (self: RemoteRegistryInstance, name: string) -> RemoteFunction,
	GetEvent: (self: RemoteRegistryInstance, name: string) -> RemoteEvent?,
	GetFunction: (self: RemoteRegistryInstance, name: string) -> RemoteFunction?,
	Destroy: (self: RemoteRegistryInstance) -> (),
}

function RemoteRegistry.new(parent: Instance?): RemoteRegistryInstance
	local self = setmetatable({
		_folder = Utilities.CreateFolder(parent or ReplicatedStorage, "Remotes"),
		_events = {},
		_functions = {},
	}, RemoteRegistry)

	return self
end

function RemoteRegistry:RegisterEvent(name: string): RemoteEvent
	assert(type(name) == "string" and name ~= "", "Remote event name must be a non-empty string")
	local existing = self._events[name]
	if existing ~= nil then
		return existing
	end

	local found = self._folder:FindFirstChild(name)
	if found ~= nil and found:IsA("RemoteEvent") then
		self._events[name] = found
		return found
	end

	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = self._folder
	self._events[name] = remoteEvent
	return remoteEvent
end

function RemoteRegistry:RegisterFunction(name: string): RemoteFunction
	assert(type(name) == "string" and name ~= "", "Remote function name must be a non-empty string")
	local existing = self._functions[name]
	if existing ~= nil then
		return existing
	end

	local found = self._folder:FindFirstChild(name)
	if found ~= nil and found:IsA("RemoteFunction") then
		self._functions[name] = found
		return found
	end

	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = name
	remoteFunction.Parent = self._folder
	self._functions[name] = remoteFunction
	return remoteFunction
end

function RemoteRegistry:GetEvent(name: string): RemoteEvent?
	local event = self._events[name]
	if event ~= nil then
		return event
	end

	local found = self._folder:FindFirstChild(name)
	if found ~= nil and found:IsA("RemoteEvent") then
		self._events[name] = found
		return found
	end

	return nil
end

function RemoteRegistry:GetFunction(name: string): RemoteFunction?
	local fn = self._functions[name]
	if fn ~= nil then
		return fn
	end

	local found = self._folder:FindFirstChild(name)
	if found ~= nil and found:IsA("RemoteFunction") then
		self._functions[name] = found
		return found
	end

	return nil
end

function RemoteRegistry:Destroy(): ()
	for _, remote in pairs(self._events) do
		remote:Destroy()
	end

	for _, remote in pairs(self._functions) do
		remote:Destroy()
	end

	self._events = {}
	self._functions = {}
	self._folder:Destroy()
end

return RemoteRegistry
