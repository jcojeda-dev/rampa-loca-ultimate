--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local EconomyConstants = require(ReplicatedStorage.Shared.Constants.EconomyConstants)
local Utilities = require(ReplicatedStorage.Shared.Utilities.Utilities)

local ProfileTemplate = {}

function ProfileTemplate.Create(userId: number): PlayerTypes.ProfileData
	local now = os.time()
	local baseStats = {
		Kills = 0,
		Deaths = 0,
		Assists = 0,
		Headshots = 0,
		LongestKillStreak = 0,
		Accuracy = 0,
		Wins = 0,
		Losses = 0,
		PlayTime = 0,
	}

	local profile = {
		UserId = userId,
		Version = EconomyConstants.PROFILE_VERSION,
		Coins = 0,
		XP = 0,
		Level = 1,
		Rank = EconomyConstants.DefaultRank,
		Stats = Utilities.DeepCopy(baseStats),
		Inventory = {
			Weapons = {},
			Knives = {},
			Skins = {},
			Trails = {},
			Effects = {},
			Emotes = {},
		},
		Loadout = {
			Primary = "Default",
			Secondary = "Pistol",
			Knife = "Knife",
			Trail = nil,
			KillEffect = nil,
		},
		Settings = {
			Music = true,
			SFX = true,
			Sensitivity = 1,
			FOV = 80,
		},
		BattlePass = {
			Active = false,
			Level = 0,
			Progress = 0,
		},
		DailyRewards = {
			LastClaimTime = 0,
			ConsecutiveDays = 0,
			ClaimedToday = false,
		},
		Missions = {},
		Achievements = {},
		CreatedAt = now,
		LastModified = now,
		LastLogin = now,
	}

	profile.Statistics = profile.Stats
	return profile
end

return ProfileTemplate
