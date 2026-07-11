--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServiceContainer = require(ReplicatedStorage.Shared.Core.ServiceContainer)

local Registry = {}
Registry.__index = Registry

function Registry.new()
	local self = setmetatable({
		_container = ServiceContainer.new(),
	}, Registry)

	return self
end

function Registry:Register(name: string, service)
	return self._container:Register(name, service)
end

function Registry:Get(name: string)
	return self._container:Get(name)
end

function Registry:Start()
	self._container:StartAll()
end

function Registry:Destroy()
	self._container:Destroy()
end

return Registry
