--!strict

local CombatConfig = {}

CombatConfig.HeadshotMultiplier = 2

CombatConfig.FriendlyFire = {
    Enabled = false,
    DamageMultiplier = 0.0,
}

CombatConfig.TeamDamage = {
    Enabled = false,
    DamageMultiplier = 0.0,
}

CombatConfig.SpawnProtection = {
    Enabled = true,
    Duration = 3,
}

CombatConfig.AssistTimeWindow = 8
CombatConfig.RespawnDelay = 2
CombatConfig.SpectatorEnabled = true
CombatConfig.KillStreak = {
    TrackLongest = true,
}

return CombatConfig
