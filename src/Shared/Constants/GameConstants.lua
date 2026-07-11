--!strict

--[[
	GameConstants stores shared constants for the game core and future gameplay systems.
]]

local GameConstants = {}

GameConstants.GameName = "Rampa Loca Ultimate"
GameConstants.Version = "3.0.0"
GameConstants.MaxPlayers = 8
GameConstants.MinPlayers = 2
GameConstants.RoundTime = 300
GameConstants.WarmupTime = 15
GameConstants.Intermission = 10
GameConstants.RespawnTime = 1
GameConstants.AutoSaveInterval = 60
GameConstants.EnableAnalytics = true
GameConstants.EnableAntiCheat = true
GameConstants.EnableBattlePass = true
GameConstants.EnableDailyRewards = true

GameConstants.GameModes = {
	ONE_VS_ONE = "1v1",
	FOUR_VS_FOUR = "4v4",
}

GameConstants.Rewards = {
	Kill = 200,
	Headshot = 50,
	Participation = 100,
	Win1v1 = 500,
	Win4v4 = 600,
}

GameConstants.XP = {
	Kill = 25,
	Headshot = 10,
	Victory = 100,
	Participation = 20,
}

return GameConstants
