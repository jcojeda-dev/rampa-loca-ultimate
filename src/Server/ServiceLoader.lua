--!strict

--[[
	ServiceLoader discovers server-side module scripts and registers them into the shared container.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServiceLoader = {}
ServiceLoader.__index = ServiceLoader

type ServiceContainer = typeof(require(ReplicatedStorage.Shared.Core.ServiceContainer).new())

type ServiceLoaderInstance = {
	_container: ServiceContainer,
	_game: any,
	Load: (self: ServiceLoaderInstance, folder: Instance) -> {any},
}

function ServiceLoader.new(container: ServiceContainer, game: any): ServiceLoaderInstance
	local self = setmetatable({
		_container = container,
		_game = game,
	}, ServiceLoader)

	return self
end

function ServiceLoader:Load(folder: Instance): {any}
	assert(folder ~= nil, "Service folder is required")

	local loaded = {}
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("ModuleScript") then
			local service = require(child)
			if type(service) == "table" then
				local name = service.Name or child.Name
				self._container:Register(name, service)
				if self._game ~= nil and type(self._game.RegisterService) == "function" then
					self._game:RegisterService(name, service)
				end
				table.insert(loaded, service)
			end
		end
	end

	return loaded
end

return ServiceLoader