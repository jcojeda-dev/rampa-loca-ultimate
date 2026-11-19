--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Shared.Modules.Signal)

local PlayerSignals = {}
PlayerSignals.__index = PlayerSignals

local signalInstance = Signal.new()
type SignalType = typeof(signalInstance)

type PlayerSignalsInstance = {
	ProfileLoaded: SignalType,
	ProfileSaved: SignalType,
	SessionCreated: SignalType,
	SessionEnded: SignalType,
	SessionLocked: SignalType,
	SessionUnlocked: SignalType,
	CoinsChanged: SignalType,
	XPChanged: SignalType,
	LevelChanged: SignalType,
	StatsUpdated: SignalType,
	Destroy: (self: PlayerSignalsInstance) -> (),
}

function PlayerSignals.new(): PlayerSignalsInstance
	local self = setmetatable({
		ProfileLoaded = Signal.new(),
		ProfileSaved = Signal.new(),
		SessionCreated = Signal.new(),
		SessionEnded = Signal.new(),
		SessionLocked = Signal.new(),
		SessionUnlocked = Signal.new(),
		CoinsChanged = Signal.new(),
		XPChanged = Signal.new(),
		LevelChanged = Signal.new(),
		StatsUpdated = Signal.new(),
	}, PlayerSignals)

	return self
end

function PlayerSignals:Destroy(): ()
	self.ProfileLoaded:Destroy()
	self.ProfileSaved:Destroy()
	self.SessionCreated:Destroy()
	self.SessionEnded:Destroy()
	self.SessionLocked:Destroy()
	self.SessionUnlocked:Destroy()
	self.CoinsChanged:Destroy()
	self.XPChanged:Destroy()
	self.LevelChanged:Destroy()
	self.StatsUpdated:Destroy()
end

return PlayerSignals
