--!strict

--[[
	Signal provides a typed event emitter with connection management and cleanup support.
]]

local Types = require(script.Parent.Parent.Types.Types)

local Signal = {}
Signal.__index = Signal

type Connection = Types.Connection

type Handler = Types.EventHandler

function Signal.new()
	local self = setmetatable({
		_connections = {},
	}, Signal)
	return self
end

function Signal:Connect(callback: Handler): Connection
	assert(type(callback) == "function", "Signal callback must be a function")

	local connection = {}
	local active = true

	local function Disconnect()
		if not active then
			return
		end

		active = false
		for index = #self._connections, 1, -1 do
			local entry = self._connections[index]
			if entry and entry.connection == connection then
				table.remove(self._connections, index)
				break
			end
		end
	end

	connection.Disconnect = Disconnect
	connection.Destroy = Disconnect
	table.insert(self._connections, {
		callback = callback,
		connection = connection,
	})

	return connection
end

function Signal:Once(callback: Handler): Connection
	assert(type(callback) == "function", "Signal callback must be a function")

	local connection
	connection = self:Connect(function(...)
		callback(...)
		if connection ~= nil then
			connection:Disconnect()
		end
	end)

	return connection
end

function Signal:Fire(...)
	for index = #self._connections, 1, -1 do
		local entry = self._connections[index]
		if entry ~= nil then
			task.spawn(entry.callback, ...)
		end
	end
end

function Signal:Destroy()
	self._connections = {}
end

return Signal
