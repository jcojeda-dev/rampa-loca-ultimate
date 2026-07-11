--!strict

--[[
	Logger centralizes project logging with configurable levels.
]]

local Logger = {}
Logger.__index = Logger

Logger.Enabled = true
Logger.Level = "Info"

local Levels = {
	Debug = 1,
	Info = 2,
	Warn = 3,
	Error = 4,
}

local function write(self, level: string, prefix: string, ...)
	if not self.Enabled then
		return
	end

	if Levels[level] < Levels[self.Level] then
		return
	end

	print(prefix, ...)
end

function Logger:SetEnabled(enabled: boolean)
	self.Enabled = enabled
end

function Logger:SetLevel(level: string)
	assert(Levels[level] ~= nil, `Unknown log level: {level}`)
	self.Level = level
end

function Logger:Debug(...)
	write(self, "Debug", "[DEBUG]", ...)
end

function Logger:Info(...)
	write(self, "Info", "[INFO]", ...)
end

function Logger:Warn(...)
	write(self, "Warn", "[WARN]", ...)
end

function Logger:Error(...)
	write(self, "Error", "[ERROR]", ...)
end

return Logger