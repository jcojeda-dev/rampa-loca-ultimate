--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MatchState = require(ReplicatedStorage.Shared.Enums.MatchState)
local MatchSignals = require(ReplicatedStorage.Shared.Domains.Match.MatchSignals)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local GameStateService = {}
GameStateService.__index = GameStateService

type GameStateServiceInstance = {
	Name: string,
	_state: string,
	_mode: string,
	_signals: any,
	Init: (self: GameStateServiceInstance) -> (),
	Start: (self: GameStateServiceInstance) -> (),
	Destroy: (self: GameStateServiceInstance) -> (),
	SetState: (self: GameStateServiceInstance, state: string) -> boolean,
	GetState: (self: GameStateServiceInstance) -> string,
	SetMode: (self: GameStateServiceInstance, mode: string) -> (),
	GetMode: (self: GameStateServiceInstance) -> string,
	IsState: (self: GameStateServiceInstance, state: string) -> boolean,
	GetSignals: (self: GameStateServiceInstance) -> any,
}

function GameStateService.new(): GameStateServiceInstance
	local self = setmetatable({
		Name = "GameStateService",
		_state = MatchState.Waiting,
		_mode = "1v1",
		_signals = MatchSignals.new(),
	}, GameStateService)

	return self
end

function GameStateService:Init(): ()
	Logger:Info("Initializing GameStateService")
end

function GameStateService:Start(): ()
	Logger:Info("Starting GameStateService")
end

function GameStateService:Destroy(): ()
	self._signals:Destroy()
end

function GameStateService:SetState(state: string): boolean
	assert(type(state) == "string" and state ~= "", "State must be a non-empty string")

	if self._state == state then
		return false
	end

	local previousState = self._state
	self._state = state
	self._signals.StateChanged:Fire(previousState, self._state)
	Logger:Debug(`Transitioned from {previousState} to {self._state}`)
	return true
end

function GameStateService:GetState(): string
	return self._state
end

function GameStateService:SetMode(mode: string): ()
	assert(type(mode) == "string" and mode ~= "", "Mode must be a non-empty string")
	self._mode = mode
end

function GameStateService:GetMode(): string
	return self._mode
end

function GameStateService:IsState(state: string): boolean
	return self._state == state
end

function GameStateService:GetSignals(): any
	return self._signals
end

return GameStateService
