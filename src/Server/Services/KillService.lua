--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatConfig = require(ReplicatedStorage.Shared.Config.CombatConfig)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local KillService = {}
KillService.__index = KillService

type KillServiceInstance = {
    Name: string,
    _killStreakService: any,
    _headshotService: any,
    Init: (self: KillServiceInstance) -> (),
    Start: (self: KillServiceInstance) -> (),
    Destroy: (self: KillServiceInstance) -> (),
    SetDependencies: (self: KillServiceInstance, killStreakService: any, headshotService: any) -> (),
    RegisterKill: (self: KillServiceInstance, attacker: Player, victim: Player, weaponName: string?, isHeadshot: boolean) -> (),
}

function KillService.new(): KillServiceInstance
    local self = setmetatable({
        Name = "KillService",
        _killStreakService = nil,
        _headshotService = nil,
    }, KillService)

    return self
end

function KillService:Init(): ()
end

function KillService:Start(): ()
end

function KillService:Destroy(): ()
end

function KillService:SetDependencies(killStreakService: any, headshotService: any): ()
    self._killStreakService = killStreakService
    self._headshotService = headshotService
end

function KillService:RegisterKill(attacker: Player, victim: Player, weaponName: string?, isHeadshot: boolean): ()
    assert(attacker ~= nil, "Attacker cannot be nil")
    assert(victim ~= nil, "Victim cannot be nil")

    if self._killStreakService ~= nil then
        self._killStreakService:RecordKill(attacker)
    end

    if self._headshotService ~= nil and isHeadshot then
        self._headshotService:RecordHeadshot(attacker)
    end
end

return KillService
