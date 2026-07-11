--!strict

--[[
	ResourceCleaner stores and destroys tracked instances or cleanup callbacks safely.
]]

local Types = require(script.Parent.Parent.Types.Types)

local ResourceCleaner = {}
ResourceCleaner.__index = ResourceCleaner

type ResourceCleanerInstance = {
	_items: {any},
	Track: (self: ResourceCleanerInstance, item: any) -> (),
	Add: (self: ResourceCleanerInstance, item: any) -> (),
	Remove: (self: ResourceCleanerInstance, item: any) -> (),
	Cleanup: (self: ResourceCleanerInstance) -> (),
	Destroy: (self: ResourceCleanerInstance) -> (),
}

function ResourceCleaner.new(): ResourceCleanerInstance
	local self = setmetatable({
		_items = {},
	}, ResourceCleaner)
	return self
end

function ResourceCleaner:Track(item: any): ()
	if item ~= nil then
		table.insert(self._items, item)
	end
end

function ResourceCleaner:Add(item: any): ()
	self:Track(item)
end

function ResourceCleaner:Remove(item: any): ()
	for index = #self._items, 1, -1 do
		if self._items[index] == item then
			table.remove(self._items, index)
		end
	end
end

function ResourceCleaner:Cleanup(): ()
	for index = #self._items, 1, -1 do
		local item = self._items[index]
		if item and type(item) == "table" and type(item.Destroy) == "function" then
			item:Destroy()
		elseif item and typeof(item) == "Instance" then
			item:Destroy()
		end
		table.remove(self._items, index)
	end
end

function ResourceCleaner:Destroy(): ()
	self:Cleanup()
	self._items = {}
end

return ResourceCleaner
