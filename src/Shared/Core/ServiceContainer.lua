--!strict

--[[
	ServiceContainer manages server-side services with Init, Start and Destroy lifecycle hooks.
]]

local Types = require(script.Parent.Parent.Types.Types)

local ServiceContainer = {}
ServiceContainer.__index = ServiceContainer

type ServiceInstance = Types.ServiceInstance

type ServiceMap = {[string]: ServiceInstance}

type ServiceContainerInstance = {
	_services: ServiceMap,
	_order: {string},
	Register: (self: ServiceContainerInstance, name: string, service: ServiceInstance) -> ServiceInstance,
	Get: (self: ServiceContainerInstance, name: string) -> ServiceInstance?,
	GetAll: (self: ServiceContainerInstance) -> {ServiceInstance},
	InitializeAll: (self: ServiceContainerInstance) -> (),
	StartAll: (self: ServiceContainerInstance) -> (),
	DestroyAll: (self: ServiceContainerInstance) -> (),
	Destroy: (self: ServiceContainerInstance) -> (),
}

function ServiceContainer.new(): ServiceContainerInstance
	local self = setmetatable({
		_services = {},
		_order = {},
	}, ServiceContainer)

	return self
end

function ServiceContainer:Register(name: string, service: ServiceInstance): ServiceInstance
	assert(type(name) == "string" and name ~= "", "Service name must be a non-empty string")
	assert(service ~= nil, "Service instance cannot be nil")
	assert(not self._services[name], `Service {name} already registered`)

	self._services[name] = service
	table.insert(self._order, name)
	return service
end

function ServiceContainer:Get(name: string): ServiceInstance?
	return self._services[name]
end

function ServiceContainer:GetAll(): {ServiceInstance}
	local services = {}
	for _, name in ipairs(self._order) do
		table.insert(services, self._services[name])
	end

	return services
end

function ServiceContainer:InitializeAll(): ()
	for _, name in ipairs(self._order) do
		local service = self._services[name]
		if service and type(service.Init) == "function" then
			service:Init()
		end
	end
end

function ServiceContainer:StartAll(): ()
	for _, name in ipairs(self._order) do
		local service = self._services[name]
		if service and type(service.Start) == "function" then
			task.spawn(function()
				service:Start()
			end)
		end
	end
end

function ServiceContainer:DestroyAll(): ()
	for index = #self._order, 1, -1 do
		local name = self._order[index]
		local service = self._services[name]
		if service and type(service.Destroy) == "function" then
			service:Destroy()
		end
	end
end

function ServiceContainer:Destroy(): ()
	self:DestroyAll()
	self._services = {}
	self._order = {}
end

return ServiceContainer
