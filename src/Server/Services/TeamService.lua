--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MatchConfig = require(ReplicatedStorage.Shared.Config.MatchConfig)
local MatchResult = require(ReplicatedStorage.Shared.Enums.MatchResult)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)
local Game = require(ReplicatedStorage.Shared.Core.Game)

local TeamService = {}
TeamService.__index = TeamService

type TeamServiceInstance = {
	Name: string,
	_teams: {[string]: {Player}},
	_selectedTeams: {[number]: string},
	Init: (self: TeamServiceInstance) -> (),
	Start: (self: TeamServiceInstance) -> (),
	Destroy: (self: TeamServiceInstance) -> (),
	AssignTeams: (self: TeamServiceInstance, players: {Player}, mode: string) -> {[string]: {Player}},
	GetTeams: (self: TeamServiceInstance) -> {[string]: {Player}},
	GetTeamMembers: (self: TeamServiceInstance, teamName: string) -> {Player},
	GetTeamForPlayer: (self: TeamServiceInstance, player: Player) -> string?,
	ChooseTeam: (self: TeamServiceInstance, player: Player, teamName: string) -> boolean,
	GetSelectedTeam: (self: TeamServiceInstance, player: Player) -> string?,
	ResetTeams: (self: TeamServiceInstance) -> (),
	GetWinner: (self: TeamServiceInstance, scores: {[string]: number}) -> string,
}

function TeamService.new(): TeamServiceInstance
	local self = setmetatable({
		Name = "TeamService",
		_teams = {},
		_selectedTeams = {},
	}, TeamService)

	return self
end

function TeamService:Init(): ()
	self:ResetTeams()
	Logger:Info("Initializing TeamService")

	local remoteRegistry = Game:GetRemoteRegistry()
	if remoteRegistry then
		local chooseTeamFunction = remoteRegistry:RegisterFunction("ChooseTeam")
		chooseTeamFunction.OnServerInvoke = function(player, teamName)
			return self:ChooseTeam(player, teamName)
		end
	end
end

function TeamService:Start(): ()
	Logger:Info("Starting TeamService")
end

function TeamService:Destroy(): ()
	self:ResetTeams()
end

function TeamService:AssignTeams(players: {Player}, mode: string): {[string]: {Player}}
	assert(type(mode) == "string" and mode ~= "", "Mode must be a non-empty string")
	self:ResetTeams()

	local teamNames = {"Red", "Blue"}
	local teamSize = 1
	if mode == "4v4" then
		teamSize = 4
	end

	local teamIndex = 1
	for _, player in ipairs(players) do
		if self._teams[teamNames[teamIndex]] == nil then
			self._teams[teamNames[teamIndex]] = {}
		end

		table.insert(self._teams[teamNames[teamIndex]], player)
		teamIndex = teamIndex + 1
		if teamIndex > #teamNames then
			teamIndex = 1
		end
	end

	return self._teams
end

function TeamService:GetTeams(): {[string]: {Player}}
	return self._teams
end

function TeamService:GetTeamMembers(teamName: string): {Player}
	assert(type(teamName) == "string" and teamName ~= "", "Team name must be a non-empty string")
	return self._teams[teamName] or {}
end

function TeamService:GetTeamForPlayer(player: Player): string?
	assert(player ~= nil, "Player cannot be nil")
	for teamName, players in pairs(self._teams) do
		for _, member in ipairs(players) do
			if member == player then
				return teamName
			end
		end
	end

	return nil
end

function TeamService:ResetTeams(): ()
	self._teams = {
		Red = {},
		Blue = {},
	}
end

function TeamService:ChooseTeam(player: Player, teamName: string): boolean
	assert(player ~= nil, "Player cannot be nil")
	assert(type(teamName) == "string" and teamName ~= "", "Team name must be a valid string")

	local normalized = teamName
	if normalized ~= "Red" and normalized ~= "Blue" then
		return false
	end

	self._selectedTeams[player.UserId] = normalized
	return true
end

function TeamService:GetSelectedTeam(player: Player): string?
	assert(player ~= nil, "Player cannot be nil")
	return self._selectedTeams[player.UserId]
end

function TeamService:GetWinner(scores: {[string]: number}): string
	local redScore = scores.Red or 0
	local blueScore = scores.Blue or 0
	if redScore > blueScore then
		return MatchResult.Red
	end
	if blueScore > redScore then
		return MatchResult.Blue
	end
	return MatchResult.Draw
end

return TeamService
