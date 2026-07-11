--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local EconomyConstants = require(ReplicatedStorage.Shared.Constants.EconomyConstants)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local RewardService = {}
RewardService.__index = RewardService

type RewardServiceInstance = {
	Name: string,
	Init: (self: RewardServiceInstance) -> (),
	Start: (self: RewardServiceInstance) -> (),
	Destroy: (self: RewardServiceInstance) -> (),
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