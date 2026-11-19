--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MatchSignals = require(ReplicatedStorage.Shared.Domains.Match.MatchSignals)
local MatchResult = require(ReplicatedStorage.Shared.Enums.MatchResult)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local RoundService = {}
RoundService.__index = RoundService

type RoundServiceInstance = {
	Name: string,
	_roundNumber: number,
	_active: boolean,
	_scores: {[string]: number},
	_signals: any,
	Init: (self: RoundServiceInstance) -> (),
	Start: (self: RoundServiceInstance) -> (),
	Destroy: (self: RoundServiceInstance) -> (),
	BeginRound: (self: RoundServiceInstance, mode: string) -> (),
	EndRound: (self: RoundServiceInstance, result: string) -> (),
	AddScore: (self: RoundServiceInstance, teamName: string, amount: number) -> (),
	GetScores: (self: RoundServiceInstance) -> {[string]: number},
	GetRoundNumber: (self: RoundServiceInstance) -> number,
	IsActive: (self: RoundServiceInstance) -> boolean,
	GetSignals: (self: RoundServiceInstance) -> any,
}

function RoundService.new(): RoundServiceInstance
	local self = setmetatable({
		Name = "RoundService",
		_roundNumber = 0,
		_active = false,
		_scores = {
			Red = 0,
			Blue = 0,
		},
		_signals = MatchSignals.new(),
	}, RoundService)

	return self
end

function RoundService:Init(): ()
	Logger:Info("Initializing RoundService")
end

function RoundService:Start(): ()
	Logger:Info("Starting RoundService")
end

function RoundService:Destroy(): ()
	self._signals:Destroy()
end

function RoundService:BeginRound(mode: string): ()
	assert(type(mode) == "string" and mode ~= "", "Mode must be a non-empty string")
	self._roundNumber = self._roundNumber + 1
	self._active = true
	self._scores = {Red = 0, Blue = 0}
	self._signals.RoundStarted:Fire(self._roundNumber, mode)
	Logger:Info(`Starting round {self._roundNumber} in {mode}`)
end

function RoundService:EndRound(result: string): ()
	self._active = false
	self._signals.RoundEnded:Fire(self._roundNumber, result)
	Logger:Info(`Ending round {self._roundNumber} with result {result}`)
end

function RoundService:AddScore(teamName: string, amount: number): ()
	assert(type(teamName) == "string" and teamName ~= "", "Team name must be a non-empty string")
	assert(type(amount) == "number" and amount >= 0, "Amount must be a non-negative number")
	self._scores[teamName] = (self._scores[teamName] or 0) + amount
end

function RoundService:GetScores(): {[string]: number}
	return self._scores
end

function RoundService:GetRoundNumber(): number
	return self._roundNumber
end

function RoundService:IsActive(): boolean
	return self._active
end

function RoundService:GetSignals(): any
	return self._signals
end

return RoundService
