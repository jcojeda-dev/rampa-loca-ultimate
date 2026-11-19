--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local EconomyConstants = require(ReplicatedStorage.Shared.Constants.EconomyConstants)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local RewardService = {}
RewardService.__index = RewardService

type RewardServiceInstance = {
	Name: string,
	_economyService: any,
	Init: (self: RewardServiceInstance) -> (),
	Start: (self: RewardServiceInstance) -> (),
	Destroy: (self: RewardServiceInstance) -> (),
	SetEconomyService: (self: RewardServiceInstance, economyService: any) -> (),
	AwardKill: (self: RewardServiceInstance, profile: PlayerTypes.ProfileData) -> (),
	AwardHeadshot: (self: RewardServiceInstance, profile: PlayerTypes.ProfileData) -> (),
	AwardParticipation: (self: RewardServiceInstance, profile: PlayerTypes.ProfileData) -> (),
	AwardVictory: (self: RewardServiceInstance, profile: PlayerTypes.ProfileData, gameMode: string) -> (),
	GetKillReward: (self: RewardServiceInstance) -> number,
	GetHeadshotReward: (self: RewardServiceInstance) -> number,
	GetParticipationReward: (self: RewardServiceInstance) -> number,
	GetVictoryReward: (self: RewardServiceInstance, gameMode: string) -> number,
	GetKillXP: (self: RewardServiceInstance) -> number,
	GetHeadshotXP: (self: RewardServiceInstance) -> number,
	GetVictoryXP: (self: RewardServiceInstance) -> number,
	GetParticipationXP: (self: RewardServiceInstance) -> number,
}

function RewardService.new(): RewardServiceInstance
	local self = setmetatable({
		Name = "RewardService",
	}, RewardService)

	return self
end

function RewardService:Init(): ()
	Logger:Info("Initializing RewardService")
end

function RewardService:Start(): ()
	Logger:Info("Starting RewardService")
end

function RewardService:Destroy(): ()
	Logger:Info("Destroying RewardService")
end

function RewardService:SetEconomyService(economyService: any): ()
	self._economyService = economyService
end

function RewardService:_ApplyReward(profile: PlayerTypes.ProfileData, coins: number, xp: number, reason: string): ()
	assert(self._economyService ~= nil, "EconomyService must be configured")
	self._economyService:AddCoins(profile, coins, reason)
	self._economyService:AddXP(profile, xp, reason)
	self._economyService:CheckLevelUp(profile)
end

function RewardService:AwardKill(profile: PlayerTypes.ProfileData): ()
	assert(profile ~= nil, "Profile cannot be nil")
	profile.Stats.Kills += 1
	profile.Statistics.Kills = profile.Stats.Kills
	self:_ApplyReward(profile, self:GetKillReward(), self:GetKillXP(), "KillReward")
end

function RewardService:AwardHeadshot(profile: PlayerTypes.ProfileData): ()
	assert(profile ~= nil, "Profile cannot be nil")
	profile.Stats.Headshots += 1
	profile.Statistics.Headshots = profile.Stats.Headshots
	self:_ApplyReward(profile, self:GetHeadshotReward(), self:GetHeadshotXP(), "HeadshotReward")
end

function RewardService:AwardParticipation(profile: PlayerTypes.ProfileData): ()
	assert(profile ~= nil, "Profile cannot be nil")
	self:_ApplyReward(profile, self:GetParticipationReward(), self:GetParticipationXP(), "ParticipationReward")
end

function RewardService:AwardVictory(profile: PlayerTypes.ProfileData, gameMode: string): ()
	assert(profile ~= nil, "Profile cannot be nil")
	assert(type(gameMode) == "string" and gameMode ~= "", "Game mode must be a non-empty string")
	local coins = self:GetVictoryReward(gameMode)
	self:_ApplyReward(profile, coins, self:GetVictoryXP(), "VictoryReward")
end

function RewardService:GetKillReward(): number
	return EconomyConstants.Rewards.Kill
end

function RewardService:GetHeadshotReward(): number
	return EconomyConstants.Rewards.Headshot
end

function RewardService:GetParticipationReward(): number
	return EconomyConstants.Rewards.Participation
end

function RewardService:GetVictoryReward(gameMode: string): number
	assert(type(gameMode) == "string", "Game mode must be a string")

	if gameMode == "1v1" then
		return EconomyConstants.Rewards.Win1v1
	end

	return EconomyConstants.Rewards.Win4v4
end

function RewardService:GetKillXP(): number
	return EconomyConstants.XP.Kill
end

function RewardService:GetHeadshotXP(): number
	return EconomyConstants.XP.Headshot
end

function RewardService:GetVictoryXP(): number
	return EconomyConstants.XP.Victory
end

function RewardService:GetParticipationXP(): number
	return EconomyConstants.XP.Participation
end

return RewardService