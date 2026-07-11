--!strict

--[[
	ControllerContainer manages client-side controllers with Init, Start and Destroy lifecycle hooks.
]]

local Types = require(script.Parent.Parent.Types.Types)

local ControllerContainer = {}
ControllerContainer.__index = ControllerContainer

type ControllerInstance = Types.ControllerInstance

type ControllerMap = {[string]: ControllerInstance}

type ControllerContainerInstance = {
	_controllers: ControllerMap,
	_order: {string},
	Register: (self: ControllerContainerInstance, name: string, controller: ControllerInstance) -> ControllerInstance,
	Get: (self: ControllerContainerInstance, name: string) -> ControllerInstance?,
	GetAll: (self: ControllerContainerInstance) -> {ControllerInstance},
	InitializeAll: (self: ControllerContainerInstance) -> (),
	StartAll: (self: ControllerContainerInstance) -> (),
	DestroyAll: (self: ControllerContainerInstance) -> (),
	Destroy: (self: ControllerContainerInstance) -> (),
}

function ControllerContainer.new(): ControllerContainerInstance
	local self = setmetatable({
		_controllers = {},
		_order = {},
	}, ControllerContainer)

	return self
end

function ControllerContainer:Register(name: string, controller: ControllerInstance): ControllerInstance
	assert(type(name) == "string" and name ~= "", "Controller name must be a non-empty string")
	assert(controller ~= nil, "Controller instance cannot be nil")
	assert(not self._controllers[name], `Controller {name} already registered`)

	self._controllers[name] = controller
	table.insert(self._order, name)
	return controller
end

function ControllerContainer:Get(name: string): ControllerInstance?
	return self._controllers[name]
end

function ControllerContainer:GetAll(): {ControllerInstance}
	local controllers = {}
	for _, name in ipairs(self._order) do
		table.insert(controllers, self._controllers[name])
	end

	return controllers
end

function ControllerContainer:InitializeAll(): ()
	for _, name in ipairs(self._order) do
		local controller = self._controllers[name]
		if controller and type(controller.Init) == "function" then
			controller:Init()
		end
	end
end

function ControllerContainer:StartAll(): ()
	for _, name in ipairs(self._order) do
		local controller = self._controllers[name]
		if controller and type(controller.Start) == "function" then
			task.spawn(function()
				controller:Start()
			end)
		end
	end
end

function ControllerContainer:DestroyAll(): ()
	for index = #self._order, 1, -1 do
		local name = self._order[index]
		local controller = self._controllers[name]
		if controller and type(controller.Destroy) == "function" then
			controller:Destroy()
		end
	end
end

function ControllerContainer:Destroy(): ()
	self:DestroyAll()
	self._controllers = {}
	self._order = {}
end

return ControllerContainer
