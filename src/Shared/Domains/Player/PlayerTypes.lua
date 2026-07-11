--!strict

local PlayerTypes = {}

export type Coins = number
export type XP = number
export type Level = number
export type PlayTime = number

export type ProfileStats = {
	Kills: number,
	Deaths: number,
	Assists: number,
	Headshots: number,
	Wins: number,
	Losses: number,
	PlayTime: number,
}

export type Loadout = {
	Primary: string,
	Secondary: string,
	Knife: string,
	Trail: string?,
	KillEffect: string?,
}

export type Settings = {
	Music: boolean,
	SFX: boolean,
	Sensitivity: number,
	FOV: number,
}

export type Inventory = {
	Weapons: {string},
	Knives: {string},
	Skins: {string},
	Trails: {string},
	Effects: {string},
	Emotes: {string},
}

export type BattlePass = {
	Active: boolean,
	Level: number,
	Progress: number,
}

export type DailyRewards = {
	LastClaimTime: number,
	ConsecutiveDays: number,
	ClaimedToday: boolean,
}

export type Mission = {
	Id: string,
	Progress: number,
	Completed: boolean,
	Reward: number,
}

export type Achievement = {
	Id: string,
	Completed: boolean,
	UnlockedAt: number?,
}

export type ProfileData = {
	UserId: number,
	Version: number,
	Coins: Coins,
	XP: XP,
	Level: Level,
	Rank: string,
	Stats: ProfileStats,
	Inventory: Inventory,
	Loadout: Loadout,
	Settings: Settings,
	BattlePass: BattlePass,
	DailyRewards: DailyRewards,
	Missions: {[string]: Mission},
	Achievements: {[string]: Achievement},
	CreatedAt: number,
	LastModified: number,
	LastLogin: number,
}

export type Session = {
	PlayerId: number,
	UserId: number,
	StartTime: number,
	LastActivity: number,
	Locked: boolean,
}

export type RewardEvent = {
	Type: string,
	Amount: number,
	Reason: string,
	Timestamp: number,
}

return PlayerTypes
