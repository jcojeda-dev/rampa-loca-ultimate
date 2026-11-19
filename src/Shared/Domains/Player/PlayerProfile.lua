--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileTemplate = require(ReplicatedStorage.Shared.Domains.Player.ProfileTemplate)
local ProfileValidator = require(ReplicatedStorage.Shared.Domains.Player.ProfileValidator)
local Utilities = require(ReplicatedStorage.Shared.Utilities.Utilities)
local EconomyConstants = require(ReplicatedStorage.Shared.Constants.EconomyConstants)
local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)

local PlayerProfile = {}
PlayerProfile.__index = PlayerProfile

local DEFAULT_PROFILE = ProfileTemplate.Create(0)

local function copyNumberField(target: table, source: table, key: string, defaultValue: number)
    local value = source[key]
    if type(value) == "number" then
        target[key] = value
    else
        target[key] = defaultValue
    end
end

local function copyStringField(target: table, source: table, key: string, defaultValue: string)
    local value = source[key]
    if type(value) == "string" and value ~= "" then
        target[key] = value
    else
        target[key] = defaultValue
    end
end

local function copyBooleanField(target: table, source: table, key: string, defaultValue: boolean)
    local value = source[key]
    if type(value) == "boolean" then
        target[key] = value
    else
        target[key] = defaultValue
    end
end

local function normalizeStats(profile: table, legacyStats: table?): table
    local stats = {}
    local defaultStats = DEFAULT_PROFILE.Stats

    stats.Kills = type(legacyStats and legacyStats.Kills or profile.Kills) == "number" and math.max(0, legacyStats.Kills or profile.Kills) or defaultStats.Kills
    stats.Deaths = type(legacyStats and legacyStats.Deaths or profile.Deaths) == "number" and math.max(0, legacyStats.Deaths or profile.Deaths) or defaultStats.Deaths
    stats.Assists = type(legacyStats and legacyStats.Assists or profile.Assists) == "number" and math.max(0, legacyStats.Assists or profile.Assists) or defaultStats.Assists
    stats.Headshots = type(legacyStats and legacyStats.Headshots or profile.Headshots) == "number" and math.max(0, legacyStats.Headshots or profile.Headshots) or defaultStats.Headshots
    stats.Wins = type(legacyStats and legacyStats.Wins or profile.Wins) == "number" and math.max(0, legacyStats.Wins or profile.Wins) or defaultStats.Wins
    stats.Losses = type(legacyStats and legacyStats.Losses or profile.Losses) == "number" and math.max(0, legacyStats.Losses or profile.Losses) or defaultStats.Losses
    stats.PlayTime = type(legacyStats and legacyStats.PlayTime or profile.PlayTime) == "number" and math.max(0, legacyStats.PlayTime or profile.PlayTime) or defaultStats.PlayTime

    return stats
end

local function normalizeInventory(source: table?): table
    local defaultInventory = Utilities.DeepCopy(DEFAULT_PROFILE.Inventory)
    if type(source) ~= "table" then
        return defaultInventory
    end

    for _, key in ipairs({"Weapons", "Knives", "Skins", "Trails", "Effects", "Emotes"}) do
        if type(source[key]) == "table" then
            defaultInventory[key] = Utilities.DeepCopy(source[key])
        end
    end

    return defaultInventory
end

local function normalizeLoadout(source: table?): table
    local defaultLoadout = Utilities.DeepCopy(DEFAULT_PROFILE.Loadout)
    if type(source) ~= "table" then
        return defaultLoadout
    end

    copyStringField(defaultLoadout, source, "Primary", defaultLoadout.Primary)
    copyStringField(defaultLoadout, source, "Secondary", defaultLoadout.Secondary)
    copyStringField(defaultLoadout, source, "Knife", defaultLoadout.Knife)

    if type(source.Trail) == "string" and source.Trail ~= "" then
        defaultLoadout.Trail = source.Trail
    end

    if type(source.KillEffect) == "string" and source.KillEffect ~= "" then
        defaultLoadout.KillEffect = source.KillEffect
    end

    return defaultLoadout
end

local function normalizeSettings(source: table?): table
    local defaultSettings = Utilities.DeepCopy(DEFAULT_PROFILE.Settings)
    if type(source) ~= "table" then
        return defaultSettings
    end

    copyBooleanField(defaultSettings, source, "Music", defaultSettings.Music)
    copyBooleanField(defaultSettings, source, "SFX", defaultSettings.SFX)
    copyNumberField(defaultSettings, source, "Sensitivity", defaultSettings.Sensitivity)
    copyNumberField(defaultSettings, source, "FOV", defaultSettings.FOV)

    return defaultSettings
end

local function normalizeBattlePass(source: table?): table
    local defaultBattlePass = Utilities.DeepCopy(DEFAULT_PROFILE.BattlePass)
    if type(source) ~= "table" then
        return defaultBattlePass
    end

    copyBooleanField(defaultBattlePass, source, "Active", defaultBattlePass.Active)
    copyNumberField(defaultBattlePass, source, "Level", defaultBattlePass.Level)
    copyNumberField(defaultBattlePass, source, "Progress", defaultBattlePass.Progress)

    return defaultBattlePass
end

local function normalizeDailyRewards(source: table?): table
    local defaultDailyRewards = Utilities.DeepCopy(DEFAULT_PROFILE.DailyRewards)
    if type(source) ~= "table" then
        return defaultDailyRewards
    end

    copyNumberField(defaultDailyRewards, source, "LastClaimTime", defaultDailyRewards.LastClaimTime)
    copyNumberField(defaultDailyRewards, source, "ConsecutiveDays", defaultDailyRewards.ConsecutiveDays)
    copyBooleanField(defaultDailyRewards, source, "ClaimedToday", defaultDailyRewards.ClaimedToday)

    return defaultDailyRewards
end

local function normalizeNestedMap(source: table?, defaultValue: table): table
    if type(source) ~= "table" then
        return Utilities.DeepCopy(defaultValue)
    end

    local result = {}
    for key, value in pairs(source) do
        if type(key) == "string" and type(value) == "table" then
            result[key] = Utilities.DeepCopy(value)
        end
    end

    return result
end

function PlayerProfile.Create(userId: number): PlayerTypes.ProfileData
    return ProfileTemplate.Create(userId)
end

function PlayerProfile.Migrate(profile: any): PlayerTypes.ProfileData
    local userId = type(profile) == "table" and type(profile.UserId) == "number" and profile.UserId or 0
    local migrated = ProfileTemplate.Create(userId)

    if type(profile) ~= "table" then
        return migrated
    end

    migrated.UserId = userId
    migrated.Version = type(profile.Version) == "number" and profile.Version or 0
    migrated.Coins = type(profile.Coins) == "number" and math.max(0, profile.Coins) or migrated.Coins
    migrated.XP = type(profile.XP) == "number" and math.max(0, profile.XP) or migrated.XP
    migrated.Level = type(profile.Level) == "number" and math.max(1, profile.Level) or migrated.Level
    migrated.Rank = type(profile.Rank) == "string" and profile.Rank or migrated.Rank
    migrated.Stats = normalizeStats(profile, profile.Stats)
    migrated.Statistics = migrated.Stats
    migrated.Inventory = normalizeInventory(profile.Inventory)
    migrated.Loadout = normalizeLoadout(profile.Loadout)
    migrated.Settings = normalizeSettings(profile.Settings)
    migrated.BattlePass = normalizeBattlePass(profile.BattlePass)
    migrated.DailyRewards = normalizeDailyRewards(profile.DailyRewards)
    migrated.Missions = normalizeNestedMap(profile.Missions, migrated.Missions)
    migrated.Achievements = normalizeNestedMap(profile.Achievements, migrated.Achievements)
    migrated.CreatedAt = type(profile.CreatedAt) == "number" and profile.CreatedAt or migrated.CreatedAt
    migrated.LastModified = type(profile.LastModified) == "number" and profile.LastModified or migrated.LastModified
    migrated.LastLogin = type(profile.LastLogin) == "number" and profile.LastLogin or migrated.LastLogin

    migrated.Version = EconomyConstants.PROFILE_VERSION
    return migrated
end

function PlayerProfile.UpdateLastLogin(profile: PlayerTypes.ProfileData): PlayerTypes.ProfileData
    profile.LastLogin = os.time()
    profile.LastModified = os.time()
    return profile
end

function PlayerProfile.MarkModified(profile: PlayerTypes.ProfileData): PlayerTypes.ProfileData
    profile.LastModified = os.time()
    return profile
end

return PlayerProfile
