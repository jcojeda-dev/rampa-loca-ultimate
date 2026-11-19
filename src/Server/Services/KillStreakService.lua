--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatConfig = require(ReplicatedStorage.Shared.Config.CombatConfig)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local KillStreakService = {}
KillStreakService.__index = KillStreakService

type KillStreakServiceInstance = {
    Name: string,
    _streaks: {[number]: number},
    _longest: {[number]: number},
    Init: (self: KillStreakServiceInstance) -> (),
    Start: (self: KillStreakServiceInstance) -> (),
    Destroy: (self: KillStreakServiceInstance) -> (),
    RecordKill: (self: KillStreakServiceInstance, attacker: Player) -> (),
    ResetStreak: (self: KillStreakServiceInstance, player: Player) -> (),
    GetLongestStreak: (self: KillStreakServiceInstance, player: Player) -> number,
}

function KillStreakService.new(): KillStreakServiceInstance
    local self = setmetatable({
        Name = "KillStreakService",
        _streaks = {},
        _longest = {},
    }, KillStreakService)

    return self
end

function KillStreakService:Init(): ()
end

function KillStreakService:Start(): ()
end

function KillStreakService:Destroy(): ()
    self._streaks = {}
    self._longest = {}
end

function KillStreakService:RecordKill(attacker: Player): ()
    assert(attacker ~= nil, "Attacker cannot be nil")

    local userId = attacker.UserId
    self._streaks[userId] = (self._streaks[userId] or 0) + 1
    local current = self._streaks[userId]

    self._longest[userId] = math.max(self._longest[userId] or 0, current)
end

function KillStreakService:ResetStreak(player: Player): ()
    assert(player ~= nil, "Player cannot be nil")
    self._streaks[player.UserId] = 0
end

function KillStreakService:GetLongestStreak(player: Player): number
    assert(player ~= nil, "Player cannot be nil")
    return self._longest[player.UserId] or 0
end

return KillStreakService
