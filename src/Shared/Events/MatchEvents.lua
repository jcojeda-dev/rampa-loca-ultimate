--!strict

local MatchEvents = table.freeze({
	StateChanged = "StateChanged",
	MatchStarted = "MatchStarted",
	MatchEnded = "MatchEnded",
	RoundStarted = "RoundStarted",
	RoundEnded = "RoundEnded",
	PlayerQueued = "PlayerQueued",
	PlayerDequeued = "PlayerDequeued",
	PlayerRespawned = "PlayerRespawned",
	CountdownTick = "CountdownTick",
	TimerTick = "TimerTick",
	MatchRestarted = "MatchRestarted",
})

return MatchEvents
