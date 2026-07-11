--!strict

local EconomyConstants = {}

EconomyConstants.PROFILE_VERSION = 1

EconomyConstants.MAX_PROFILE_SIZE = 100000

EconomyConstants.AUTO_SAVE_INTERVAL = 60

EconomyConstants.SESSION_TIMEOUT = 600

EconomyConstants.Rewards = {
	Kill = 200,
	Headshot = 50,
	Participation = 100,
	Win1v1 = 500,
	Win4v4 = 600,
}

EconomyConstants.XP = {
	Kill = 25,
	Headshot = 10,
	Victory = 100,
	Participation = 20,
}

EconomyConstants.MaxValues = {
	Coins = 999999999,
	Level = 999,
	XP = 999999999,
}

EconomyConstants.DefaultRank = "Recruit"

EconomyConstants.Ranks = {
	"Recruit",
	"Private",
	"Corporal",
	"Sergeant",
	"Lieutenant",
	"Captain",
	"Major",
	"Colonel",
	"General",
}

return EconomyConstants
