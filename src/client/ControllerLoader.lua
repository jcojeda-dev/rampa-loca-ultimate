--!strict

--[[
	ControllerLoader discovers client-side module scripts and registers them into the shared controller container.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ControllerContainer = require(ReplicatedStorage.Shared.Core.ControllerContainer)

local ControllerLoader = {}
ControllerLoader.__index = ControllerLoader

type ControllerContainerInstance = typeof(ControllerContainer.new())

type LoaderResult = {any}

function ControllerLoader.new(container: ControllerContainerInstance, game: any)
	local self = setmetatable({
		_container = container,
		_game = game,
	}, ControllerLoader)

	return self
end

function ControllerLoader:Load(folder: Instance): LoaderResult
	assert(folder ~= nil, "Controller folder is required")

	local loaded = {}
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("ModuleScript") then
			local controller = require(child)
			if type(controller) == "table" then
				local name = controller.Name or child.Name
				self._container:Register(name, controller)
				table.insert(loaded, controller)
			end
		end
	end

	return loaded
end

return ControllerLoader
