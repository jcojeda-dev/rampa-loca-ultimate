--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MatchConfig = require(ReplicatedStorage.Shared.Config.MatchConfig)
local MatchState = require(ReplicatedStorage.Shared.Enums.MatchState)
local MatchResult = require(ReplicatedStorage.Shared.Enums.MatchResult)
local GameMode = require(ReplicatedStorage.Shared.Enums.GameMode)
local MatchEvents = require(ReplicatedStorage.Shared.Events.MatchEvents)
local MatchSignals = require(ReplicatedStorage.Shared.Domains.Match.MatchSignals)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)
local Game = require(ReplicatedStorage.Shared.Core.Game)

local MatchService = {}
MatchService.__index = MatchService

type MatchServiceInstance = {
	Name: string,
	_mode: string,
	_queue: {Player},
	_stateService: any,
	_roundService: any,
	_teamService: any,
	_spawnService: any,
	_countdownService: any,
	_timerService: any,
	_signals: any,
	_running: boolean,
	Init: (self: MatchServiceInstance) -> (),
	Start: (self: MatchServiceInstance) -> (),
	Destroy: (self: MatchServiceInstance) -> (),
	SetDependencies: (self: MatchServiceInstance, stateService: any, roundService: any, teamService: any, spawnService: any, countdownService: any, timerService: any) -> (),
	SetMode: (self: MatchServiceInstance, mode: string) -> (),
	GetMode: (self: MatchServiceInstance) -> string,
	JoinQueue: (self: MatchServiceInstance, player: Player) -> boolean,
	LeaveQueue: (self: MatchServiceInstance, player: Player) -> boolean,
	GetQueuePlayers: (self: MatchServiceInstance) -> {Player},
	StartMatch: (self: MatchServiceInstance) -> (),
	BeginCountdown: (self: MatchServiceInstance) -> (),
	StartPlaying: (self: MatchServiceInstance) -> (),
	EndMatch: (self: MatchServiceInstance, result: string) -> (),
	RestartMatch: (self: MatchServiceInstance) -> (),
	Update: (self: MatchServiceInstance, dt: number) -> (),
	GetSignals: (self: MatchServiceInstance) -> any,
}

function MatchService.new(): MatchServiceInstance
	local self = setmetatable({
		Name = "MatchService",
		_mode = "1v1",
		_queue = {},
		_stateService = nil,
		_roundService = nil,
		_teamService = nil,
		_spawnService = nil,
		_countdownService = nil,
		_timerService = nil,
		_signals = MatchSignals.new(),
		_running = false,
	}, MatchService)

	return self
end

function MatchService:Init(): ()
	Logger:Info("Initializing MatchService")

	local remoteRegistry = Game:GetRemoteRegistry()
	if remoteRegistry then
		local joinQueueFunction = remoteRegistry:RegisterFunction("JoinQueue")
		joinQueueFunction.OnServerInvoke = function(player)
			return self:JoinQueue(player)
		end

		local leaveQueueFunction = remoteRegistry:RegisterFunction("LeaveQueue")
		leaveQueueFunction.OnServerInvoke = function(player)
			return self:LeaveQueue(player)
		end
	end
end

function MatchService:Start(): ()
	self._running = true
	Players.PlayerAdded:Connect(function(player)
		self:JoinQueue(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:LeaveQueue(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:JoinQueue(player)
	end

	task.spawn(function()
		while self._running do
			self:Update(0.25)
			task.wait(0.25)
		end
	end)
end

function MatchService:Destroy(): ()
	self._running = false
	self._signals:Destroy()
end

function MatchService:SetDependencies(stateService: any, roundService: any, teamService: any, spawnService: any, countdownService: any, timerService: any): ()
	self._stateService = stateService
	self._roundService = roundService
	self._teamService = teamService
	self._spawnService = spawnService
	self._countdownService = countdownService
	self._timerService = timerService
end

function MatchService:SetMode(mode: string): ()
	assert(type(mode) == "string" and mode ~= "", "Mode must be a non-empty string")
	self._mode = mode
	if self._stateService ~= nil then
		self._stateService:SetMode(mode)
	end
end

function MatchService:GetMode(): string
	return self._mode
end

function MatchService:JoinQueue(player: Player): boolean
	assert(player ~= nil, "Player cannot be nil")
	for _, queuedPlayer in ipairs(self._queue) do
		if queuedPlayer == player then
			return false
		end
	end

	table.insert(self._queue, player)
	self._signals.PlayerQueued:Fire(player)
	if self._stateService ~= nil then
		self._stateService:SetState(MatchState.Queue)
	end

	if self:_HasEnoughPlayers() then
		self:StartMatch()
	end

	return true
end

function MatchService:LeaveQueue(player: Player): boolean
	assert(player ~= nil, "Player cannot be nil")
	for index, queuedPlayer in ipairs(self._queue) do
		if queuedPlayer == player then
			table.remove(self._queue, index)
			self._signals.PlayerDequeued:Fire(player)
			if self._stateService ~= nil and self._stateService:IsState(MatchState.Queue) and #self._queue < MatchConfig.MinPlayers then
				self._stateService:SetState(MatchState.Waiting)
			end
			return true
		end
	end

	return false
end

function MatchService:GetQueuePlayers(): {Player}
	return self._queue
end

function MatchService:StartMatch(): ()
	if not self:_HasEnoughPlayers() then
		return
	end

	if self._stateService ~= nil and (self._stateService:IsState(MatchState.Playing) or self._stateService:IsState(MatchState.Warmup) or self._stateService:IsState(MatchState.Countdown)) then
		return
	end

	if self._stateService ~= nil then
		self._stateService:SetState(MatchState.Warmup)
	end

	self:_AssignTeams()
	self:_RespawnLobbyPlayers()
	self._roundService:BeginRound(self._mode)
	self._countdownService:Start(MatchConfig.WarmupTime, function(remaining)
		self._signals.CountdownTick:Fire(MatchState.Warmup, remaining)
	end, function()
		self:BeginCountdown()
	end)
	self._signals.MatchStarted:Fire(self._mode)
end

function MatchService:BeginCountdown(): ()
	if self._stateService ~= nil then
		self._stateService:SetState(MatchState.Countdown)
	end

	self._countdownService:Start(MatchConfig.CountdownTime, function(remaining)
		self._signals.CountdownTick:Fire(MatchState.Countdown, remaining)
	end, function()
		self:StartPlaying()
	end)
end

function MatchService:StartPlaying(): ()
	if self._stateService ~= nil then
		self._stateService:SetState(MatchState.Playing)
	end

	self:_RespawnMatchPlayers()
	self._timerService:Start(MatchConfig.RoundTime, function(remaining)
		self._signals.TimerTick:Fire(remaining)
	end, function()
		self:EndMatch(MatchResult.Draw)
	end)
end

function MatchService:EndMatch(result: string): ()
	if self._stateService ~= nil then
		self._stateService:SetState(MatchState.Ending)
	end
	if self._timerService ~= nil then
		self._timerService:Stop()
	end
	if self._roundService ~= nil then
		self._roundService:EndRound(result)
	end
	self._signals.MatchEnded:Fire(result)
	task.delay(MatchConfig.Intermission, function()
		self:RestartMatch()
	end)
end

function MatchService:RestartMatch(): ()
	if self._stateService ~= nil then
		self._stateService:SetState(MatchState.Restarting)
	end
	self._signals.MatchRestarted:Fire()
	if self._timerService ~= nil then
		self._timerService:Stop()
	end
	if self._countdownService ~= nil then
		self._countdownService:Stop()
	end
	self._queue = {}
	if self._teamService ~= nil then
		self._teamService:ResetTeams()
	end
	if self._stateService ~= nil then
		self._stateService:SetState(MatchState.Waiting)
	end
end

function MatchService:Update(dt: number): ()
	if self._countdownService ~= nil and self._countdownService:IsActive() then
		self._countdownService:Update(dt)
	end

	if self._timerService ~= nil and self._timerService:IsActive() then
		self._timerService:Update(dt)
	end
end

function MatchService:GetSignals(): any
	return self._signals
end

function MatchService:_HasEnoughPlayers(): boolean
	local requiredPlayers = MatchConfig.GameModes.OneVsOne.Players
	if self._mode == "4v4" then
		requiredPlayers = MatchConfig.GameModes.FourVsFour.Players
	end

	return #self._queue >= requiredPlayers
end

function MatchService:_AssignTeams(): ()
	if self._teamService ~= nil then
		self._teamService:AssignTeams(self._queue, self._mode)
	end
end

function MatchService:_RespawnLobbyPlayers(): ()
	if self._spawnService ~= nil then
		for _, player in ipairs(self._queue) do
			self._spawnService:RespawnPlayer(player, MatchConfig.SpawnTypes.Lobby)
		end
	end
end

function MatchService:_RespawnMatchPlayers(): ()
	if self._spawnService ~= nil and self._teamService ~= nil then
		for teamName, players in pairs(self._teamService:GetTeams()) do
			local spawnType = MatchConfig.SpawnTypes[teamName] or MatchConfig.SpawnTypes.Spectator
			self._spawnService:RespawnPlayers(players, spawnType, teamName)
		end
	end
end

return MatchService
