--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerContainer = require(ReplicatedStorage.Shared.Core.ControllerContainer)

local Registry = {}
Registry.__index = Registry

function Registry.new()
	local self = setmetatable({
		_container = ControllerContainer.new(),
	}, Registry)

	return self
end

function Registry:Register(name: string, controller)
	return self._container:Register(name, controller)
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
