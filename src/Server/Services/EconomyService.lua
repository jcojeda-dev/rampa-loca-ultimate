--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local EconomyConstants = require(ReplicatedStorage.Shared.Constants.EconomyConstants)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local EconomyService = {}
EconomyService.__index = EconomyService

type EconomyServiceInstance = {
	Name: string,
	Init: (self: EconomyServiceInstance) -> (),
	Start: (self: EconomyServiceInstance) -> (),
	Destroy: (self: EconomyServiceInstance) -> (),
	AddCoins: (self: EconomyServiceInstance, profile: PlayerTypes.ProfileData, amount: number, reason: string) -> (),
	RemoveCoins: (self: EconomyServiceInstance, profile: PlayerTypes.ProfileData, amount: number, reason: string) -> boolean,
	SetCoins: (self: EconomyServiceInstance, profile: PlayerTypes.ProfileData, amount: number) -> (),
	GetCoins: (self: EconomyServiceInstance, profile: PlayerTypes.ProfileData) -> number,
	AddXP: (self: EconomyServiceInstance, profile: PlayerTypes.ProfileData, amount: number, reason: string?) -> (boolean),
	CheckLevelUp: (self: EconomyServiceInstance, profile: PlayerTypes.ProfileData) -> boolean,
	GetLevelXPRequirement: (self: EconomyServiceInstance, profile: PlayerTypes.ProfileData) -> number,
}

function EconomyService.new(): EconomyServiceInstance
	local self = setmetatable({
		Name = "EconomyService",
	}, EconomyService)

	return self
end

function EconomyService:Init(): ()
	Logger:Info("Initializing EconomyService")
end

function EconomyService:Start(): ()
	Logger:Info("Starting EconomyService")
end

function EconomyService:Destroy(): ()
	Logger:Info("Destroying EconomyService")
end

function EconomyService:AddCoins(profile: PlayerTypes.ProfileData, amount: number, reason: string): ()
	assert(profile ~= nil, "Profile cannot be nil")
	assert(type(amount) == "number" and amount >= 0, "Amount must be a positive number")

	profile.Coins = math.min(profile.Coins + amount, EconomyConstants.MaxValues.Coins)
	Logger:Debug(`Added {amount} coins to player {profile.UserId} - Reason: {reason}`)
end

function EconomyService:RemoveCoins(profile: PlayerTypes.ProfileData, amount: number, reason: string): boolean
	assert(profile ~= nil, "Profile cannot be nil")
	assert(type(amount) == "number" and amount >= 0, "Amount must be a positive number")

	if profile.Coins < amount then
		return false
	end

	profile.Coins = profile.Coins - amount
	Logger:Debug(`Removed {amount} coins from player {profile.UserId} - Reason: {reason}`)
	return true
end

function EconomyService:SetCoins(profile: PlayerTypes.ProfileData, amount: number): ()
	assert(profile ~= nil, "Profile cannot be nil")
	assert(type(amount) == "number" and amount >= 0, "Amount must be a positive number")

	profile.Coins = math.min(amount, EconomyConstants.MaxValues.Coins)
end

function EconomyService:GetCoins(profile: PlayerTypes.ProfileData): number
	assert(profile ~= nil, "Profile cannot be nil")
	return profile.Coins
end

function EconomyService:AddXP(profile: PlayerTypes.ProfileData, amount: number, reason: string?): (boolean)
	assert(profile ~= nil, "Profile cannot be nil")
	assert(type(amount) == "number" and amount >= 0, "Amount must be a non-negative number")

	profile.XP = math.min(profile.XP + amount, EconomyConstants.MaxValues.XP)
	Logger:Debug(`Added {amount} XP to player {profile.UserId} - Reason: {reason or "XP"}`)

	return self:CheckLevelUp(profile)
end

function EconomyService:GetLevelXPRequirement(profile: PlayerTypes.ProfileData): number
	assert(profile ~= nil, "Profile cannot be nil")
	return 100 * profile.Level
end

function EconomyService:CheckLevelUp(profile: PlayerTypes.ProfileData): boolean
	assert(profile ~= nil, "Profile cannot be nil")

	local leveledUp = false
	local requiredXP = self:GetLevelXPRequirement(profile)

	while profile.XP >= requiredXP and profile.Level < EconomyConstants.MaxValues.Level do
		profile.XP = profile.XP - requiredXP
		profile.Level = profile.Level + 1
		leveledUp = true
		requiredXP = self:GetLevelXPRequirement(profile)
	end

	return leveledUp
end

function EconomyService:AwardReward(profile: PlayerTypes.ProfileData, rewardType: string, amount: number): ()
	assert(profile ~= nil, "Profile cannot be nil")
	assert(type(rewardType) == "string", "Reward type must be a string")
	assert(type(amount) == "number" and amount >= 0, "Amount must be a non-negative number")

	self:AddCoins(profile, amount, rewardType)
end

return EconomyService