--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Shared.Modules.Signal)

local MatchSignals = {}
MatchSignals.__index = MatchSignals

local signalInstance = Signal.new()
type SignalType = typeof(signalInstance)

type MatchSignalsInstance = {
	StateChanged: SignalType,
	MatchStarted: SignalType,
	MatchEnded: SignalType,
	RoundStarted: SignalType,
	RoundEnded: SignalType,
	PlayerQueued: SignalType,
	PlayerDequeued: SignalType,
	PlayerRespawned: SignalType,
	CountdownTick: SignalType,
	TimerTick: SignalType,
	MatchRestarted: SignalType,
	Destroy: (self: MatchSignalsInstance) -> (),
}

function MatchSignals.new(): MatchSignalsInstance
	local self = setmetatable({
		StateChanged = Signal.new(),
		MatchStarted = Signal.new(),
		MatchEnded = Signal.new(),
		RoundStarted = Signal.new(),
		RoundEnded = Signal.new(),
		PlayerQueued = Signal.new(),
		PlayerDequeued = Signal.new(),
		PlayerRespawned = Signal.new(),
		CountdownTick = Signal.new(),
		TimerTick = Signal.new(),
		MatchRestarted = Signal.new(),
	}, MatchSignals)

	return self
end

function MatchSignals:Destroy(): ()
	self.StateChanged:Destroy()
	self.MatchStarted:Destroy()
	self.MatchEnded:Destroy()
	self.RoundStarted:Destroy()
	self.RoundEnded:Destroy()
	self.PlayerQueued:Destroy()
	self.PlayerDequeued:Destroy()
	self.PlayerRespawned:Destroy()
	self.CountdownTick:Destroy()
	self.TimerTick:Destroy()
	self.MatchRestarted:Destroy()
end

return MatchSignals
