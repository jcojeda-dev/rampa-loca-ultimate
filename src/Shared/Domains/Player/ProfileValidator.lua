--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local EconomyConstants = require(ReplicatedStorage.Shared.Constants.EconomyConstants)

local ProfileValidator = {}
ProfileValidator.__index = ProfileValidator

function ProfileValidator.new()
	local self = setmetatable({}, ProfileValidator)
	return self
end

function ProfileValidator:ValidateProfile(profile: PlayerTypes.ProfileData): (boolean, string?)
	if type(profile) ~= "table" then
		return false, "Profile must be a table"
	end

	if type(profile.UserId) ~= "number" or profile.UserId <= 0 then
		return false, "Invalid UserId"
	end

	if type(profile.Version) ~= "number" or profile.Version <= 0 then
		return false, "Invalid version"
	end

	if not self:_ValidateCoins(profile.Coins) then
		return false, "Invalid coins value"
	end

	if not self:_ValidateXP(profile.XP) then
		return false, "Invalid XP value"
	end

	if not self:_ValidateLevel(profile.Level) then
		return false, "Invalid level value"
	end

	if type(profile.Stats) ~= "table" then
		return false, "Stats must be a table"
	end

	if not self:_ValidateStats(profile.Stats) then
		return false, "Invalid stats"
	end

	if type(profile.Inventory) ~= "table" then
		return false, "Inventory must be a table"
	end

	if type(profile.Loadout) ~= "table" then
		return false, "Loadout must be a table"
	end

	return true, nil
end

function ProfileValidator:_ValidateCoins(coins: any): boolean
	if type(coins) ~= "number" then
		return false
	end

	return coins >= 0 and coins <= EconomyConstants.MaxValues.Coins
end

function ProfileValidator:_ValidateXP(xp: any): boolean
	if type(xp) ~= "number" then
		return false
	end

	return xp >= 0 and xp <= EconomyConstants.MaxValues.XP
end

function ProfileValidator:_ValidateLevel(level: any): boolean
	if type(level) ~= "number" then
		return false
	end

	return level >= 1 and level <= EconomyConstants.MaxValues.Level
end

function ProfileValidator:_ValidateStats(stats: any): boolean
	if type(stats) ~= "table" then
		return false
	end

	local requiredFields = { "Kills", "Deaths", "Assists", "Headshots", "Wins", "Losses", "PlayTime" }
	for _, field in ipairs(requiredFields) do
		if type(stats[field]) ~= "number" or stats[field] < 0 then
			return false
		end
	end

	return true
end

function ProfileValidator:Sanitize(profile: PlayerTypes.ProfileData): PlayerTypes.ProfileData
	if type(profile) ~= "table" then
		return profile
	end

	profile.Coins = math.max(0, math.min(profile.Coins or 0, EconomyConstants.MaxValues.Coins))
	profile.XP = math.max(0, math.min(profile.XP or 0, EconomyConstants.MaxValues.XP))
	profile.Level = math.max(1, math.min(profile.Level or 1, EconomyConstants.MaxValues.Level))

	if type(profile.Stats) == "table" then
		profile.Stats.Kills = math.max(0, profile.Stats.Kills or 0)
		profile.Stats.Deaths = math.max(0, profile.Stats.Deaths or 0)
		profile.Stats.Assists = math.max(0, profile.Stats.Assists or 0)
		profile.Stats.Headshots = math.max(0, profile.Stats.Headshots or 0)
		profile.Stats.Wins = math.max(0, profile.Stats.Wins or 0)
		profile.Stats.Losses = math.max(0, profile.Stats.Losses or 0)
		profile.Stats.PlayTime = math.max(0, profile.Stats.PlayTime or 0)
	end

	return profile
end

return ProfileValidator
