--!strict

local CombatEvents = table.freeze({
    DamageApplied = "DamageApplied",
    DamageBlocked = "DamageBlocked",
    PlayerKilled = "PlayerKilled",
    PlayerDied = "PlayerDied",
    PlayerAssisted = "PlayerAssisted",
    PlayerHeadshotted = "PlayerHeadshotted",
    Respawned = "Respawned",
    SpawnProtected = "SpawnProtected",
    SpectatorEntered = "SpectatorEntered",
    SpectatorExited = "SpectatorExited",
    CombatEvent = "CombatEvent",
})

return CombatEvents
