--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local EconomyConstants = require(ReplicatedStorage.Shared.Constants.EconomyConstants)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local ProfileTemplate = require(ReplicatedStorage.Shared.Domains.Player.ProfileTemplate)
local Utilities = require(ReplicatedStorage.Shared.Utilities.Utilities)
local EconomyConstants = require(ReplicatedStorage.Shared.Constants.EconomyConstants)

local ProfileValidator = {}
ProfileValidator.__index = ProfileValidator

function ProfileValidator.new()
	local self = setmetatable({}, ProfileValidator)
	return self
end

function ProfileValidator:ValidateProfile(profile: any): (boolean, string?)
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
		return false, "Invalid Coins"
	end

	if not self:_ValidateXP(profile.XP) then
		return false, "Invalid XP"
	end

	if not self:_ValidateLevel(profile.Level) then
		return false, "Invalid Level"
	end

	if type(profile.Rank) ~= "string" or profile.Rank == "" then
		return false, "Invalid Rank"
	end

	if not self:_ValidateStats(profile.Stats) then
		return false, "Invalid Stats"
	end

	if not self:_ValidateStats(profile.Statistics) then
		return false, "Invalid Statistics"
	end

	if not self:_ValidateInventory(profile.Inventory) then
		return false, "Invalid Inventory"
	end

	if not self:_ValidateLoadout(profile.Loadout) then
		return false, "Invalid Loadout"
	end

	if not self:_ValidateSettings(profile.Settings) then
		return false, "Invalid Settings"
	end

	if not self:_ValidateBattlePass(profile.BattlePass) then
		return false, "Invalid BattlePass"
	end

	if not self:_ValidateDailyRewards(profile.DailyRewards) then
		return false, "Invalid DailyRewards"
	end

	if not self:_ValidateMap(profile.Missions) then
		return false, "Invalid Missions"
	end

	if not self:_ValidateMap(profile.Achievements) then
		return false, "Invalid Achievements"
	end

	return true, nil
end

function ProfileValidator:_ValidateCoins(value: any): boolean
	return type(value) == "number" and value >= 0 and value <= EconomyConstants.MaxValues.Coins
end

function ProfileValidator:_ValidateXP(value: any): boolean
	return type(value) == "number" and value >= 0 and value <= EconomyConstants.MaxValues.XP
end

function ProfileValidator:_ValidateLevel(value: any): boolean
	return type(value) == "number" and value >= 1 and value <= EconomyConstants.MaxValues.Level
end

function ProfileValidator:_ValidateStats(value: any): boolean
	if type(value) ~= "table" then
		return false
	end

	local requiredFields = {"Kills", "Deaths", "Assists", "Headshots", "LongestKillStreak", "Accuracy", "Wins", "Losses", "PlayTime"}
	for _, field in ipairs(requiredFields) do
		if type(value[field]) ~= "number" or value[field] < 0 then
			return false
		end
	end

	return true
end

function ProfileValidator:_ValidateInventory(value: any): boolean
	if type(value) ~= "table" then
		return false
	end

	local requiredFields = {"Weapons", "Knives", "Skins", "Trails", "Effects", "Emotes"}
	for _, field in ipairs(requiredFields) do
		if type(value[field]) ~= "table" then
			return false
		end
	end

	return true
end

function ProfileValidator:_ValidateLoadout(value: any): boolean
	if type(value) ~= "table" then
		return false
	end

	local requiredFields = {"Primary", "Secondary", "Knife"}
	for _, field in ipairs(requiredFields) do
		if type(value[field]) ~= "string" or value[field] == "" then
			return false
		end
	end

	if value.Trail ~= nil and type(value.Trail) ~= "string" then
		return false
	end

	if value.KillEffect ~= nil and type(value.KillEffect) ~= "string" then
		return false
	end

	return true
end

function ProfileValidator:_ValidateSettings(value: any): boolean
	if type(value) ~= "table" then
		return false
	end

	if type(value.Music) ~= "boolean" or type(value.SFX) ~= "boolean" then
		return false
	end

	if type(value.Sensitivity) ~= "number" or value.Sensitivity <= 0 then
		return false
	end

	if type(value.FOV) ~= "number" or value.FOV < 30 or value.FOV > 120 then
		return false
	end

	return true
end

function ProfileValidator:_ValidateBattlePass(value: any): boolean
	if type(value) ~= "table" then
		return false
	end

	if type(value.Active) ~= "boolean" then
		return false
	end

	if type(value.Level) ~= "number" or value.Level < 0 then
		return false
	end

	if type(value.Progress) ~= "number" or value.Progress < 0 then
		return false
	end

	return true
end

function ProfileValidator:_ValidateDailyRewards(value: any): boolean
	if type(value) ~= "table" then
		return false
	end

	if type(value.LastClaimTime) ~= "number" or value.LastClaimTime < 0 then
		return false
	end

	if type(value.ConsecutiveDays) ~= "number" or value.ConsecutiveDays < 0 then
		return false
	end

	if type(value.ClaimedToday) ~= "boolean" then
		return false
	end

	return true
end

function ProfileValidator:_ValidateMap(value: any): boolean
	if value == nil then
		return true
	end

	if type(value) ~= "table" then
		return false
	end

	for key, entry in pairs(value) do
		if type(key) ~= "string" or type(entry) ~= "table" then
			return false
		end
	end

	return true
end

function ProfileValidator:Sanitize(profile: any): PlayerTypes.ProfileData
	local sanitized = ProfileTemplate.Create(type(profile) == "table" and profile.UserId or 0)

	sanitized.UserId = type(profile.UserId) == "number" and profile.UserId or sanitized.UserId
	sanitized.Version = EconomyConstants.PROFILE_VERSION
	sanitized.Coins = math.max(0, math.min(type(profile.Coins) == "number" and profile.Coins or 0, EconomyConstants.MaxValues.Coins))
	sanitized.XP = math.max(0, math.min(type(profile.XP) == "number" and profile.XP or 0, EconomyConstants.MaxValues.XP))
	sanitized.Level = math.max(1, math.min(type(profile.Level) == "number" and profile.Level or 1, EconomyConstants.MaxValues.Level))
	sanitized.Rank = type(profile.Rank) == "string" and profile.Rank or sanitized.Rank
	sanitized.Stats = self:_SanitizeStats(profile.Stats, sanitized.Stats)
	sanitized.Statistics = sanitized.Stats
	sanitized.Inventory = self:_SanitizeInventory(profile.Inventory, sanitized.Inventory)
	sanitized.Loadout = self:_SanitizeLoadout(profile.Loadout, sanitized.Loadout)
	sanitized.Settings = self:_SanitizeSettings(profile.Settings, sanitized.Settings)
	sanitized.BattlePass = self:_SanitizeBattlePass(profile.BattlePass, sanitized.BattlePass)
	sanitized.DailyRewards = self:_SanitizeDailyRewards(profile.DailyRewards, sanitized.DailyRewards)
	sanitized.Missions = self:_SanitizeMap(profile.Missions, sanitized.Missions)
	sanitized.Achievements = self:_SanitizeMap(profile.Achievements, sanitized.Achievements)

	if type(profile.CreatedAt) == "number" and profile.CreatedAt > 0 then
		sanitized.CreatedAt = profile.CreatedAt
	end

	if type(profile.LastModified) == "number" and profile.LastModified > 0 then
		sanitized.LastModified = profile.LastModified
	end

	if type(profile.LastLogin) == "number" and profile.LastLogin > 0 then
		sanitized.LastLogin = profile.LastLogin
	end

	return sanitized
end

function ProfileValidator:_SanitizeStats(value: any, defaultStats: table): table
	local stats = Utilities.DeepCopy(defaultStats)
	if type(value) ~= "table" then
		return stats
	end

	for _, field in ipairs({"Kills", "Deaths", "Assists", "Headshots", "LongestKillStreak", "Accuracy", "Wins", "Losses", "PlayTime"}) do
		if type(value[field]) == "number" and value[field] >= 0 then
			stats[field] = value[field]
		end
	end

	return stats
end

function ProfileValidator:_SanitizeInventory(value: any, defaultInventory: table): table
	local inventory = Utilities.DeepCopy(defaultInventory)
	if type(value) ~= "table" then
		return inventory
	end

	for _, field in ipairs({"Weapons", "Knives", "Skins", "Trails", "Effects", "Emotes"}) do
		if type(value[field]) == "table" then
			inventory[field] = Utilities.DeepCopy(value[field])
		end
	end

	return inventory
end

function ProfileValidator:_SanitizeLoadout(value: any, defaultLoadout: table): table
	local loadout = Utilities.DeepCopy(defaultLoadout)
	if type(value) ~= "table" then
		return loadout
	end

	loadout.Primary = type(value.Primary) == "string" and value.Primary or loadout.Primary
	loadout.Secondary = type(value.Secondary) == "string" and value.Secondary or loadout.Secondary
	loadout.Knife = type(value.Knife) == "string" and value.Knife or loadout.Knife
	loadout.Trail = type(value.Trail) == "string" and value.Trail or nil
	loadout.KillEffect = type(value.KillEffect) == "string" and value.KillEffect or nil

	return loadout
end

function ProfileValidator:_SanitizeSettings(value: any, defaultSettings: table): table
	local settings = Utilities.DeepCopy(defaultSettings)
	if type(value) ~= "table" then
		return settings
	end

	settings.Music = type(value.Music) == "boolean" and value.Music or settings.Music
	settings.SFX = type(value.SFX) == "boolean" and value.SFX or settings.SFX
	settings.Sensitivity = type(value.Sensitivity) == "number" and value.Sensitivity > 0 and value.Sensitivity or settings.Sensitivity
	settings.FOV = type(value.FOV) == "number" and value.FOV >= 30 and value.FOV <= 120 and value.FOV or settings.FOV

	return settings
end

function ProfileValidator:_SanitizeBattlePass(value: any, defaultBattlePass: table): table
	local battlePass = Utilities.DeepCopy(defaultBattlePass)
	if type(value) ~= "table" then
		return battlePass
	end

	battlePass.Active = type(value.Active) == "boolean" and value.Active or battlePass.Active
	battlePass.Level = type(value.Level) == "number" and value.Level >= 0 and value.Level or battlePass.Level
	battlePass.Progress = type(value.Progress) == "number" and value.Progress >= 0 and value.Progress or battlePass.Progress

	return battlePass
end

function ProfileValidator:_SanitizeDailyRewards(value: any, defaultDailyRewards: table): table
	local dailyRewards = Utilities.DeepCopy(defaultDailyRewards)
	if type(value) ~= "table" then
		return dailyRewards
	end

	dailyRewards.LastClaimTime = type(value.LastClaimTime) == "number" and value.LastClaimTime >= 0 and value.LastClaimTime or dailyRewards.LastClaimTime
	dailyRewards.ConsecutiveDays = type(value.ConsecutiveDays) == "number" and value.ConsecutiveDays >= 0 and value.ConsecutiveDays or dailyRewards.ConsecutiveDays
	dailyRewards.ClaimedToday = type(value.ClaimedToday) == "boolean" and value.ClaimedToday or dailyRewards.ClaimedToday

	return dailyRewards
end

function ProfileValidator:_SanitizeMap(value: any, defaultMap: table): table
	local result = Utilities.DeepCopy(defaultMap)
	if type(value) ~= "table" then
		return result
	end

	for key, entry in pairs(value) do
		if type(key) == "string" and type(entry) == "table" then
			result[key] = Utilities.DeepCopy(entry)
		end
	end

	return result
end

return ProfileValidator
