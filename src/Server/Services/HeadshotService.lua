--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatConfig = require(ReplicatedStorage.Shared.Config.CombatConfig)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local HeadshotService = {}
HeadshotService.__index = HeadshotService

type HeadshotServiceInstance = {
    Name: string,
    _playerService: any,
    _combatService: any,
    Init: (self: HeadshotServiceInstance) -> (),
    Start: (self: HeadshotServiceInstance) -> (),
    Destroy: (self: HeadshotServiceInstance) -> (),
    SetDependencies: (self: HeadshotServiceInstance, playerService: any, combatService: any) -> (),
    ProcessHit: (self: HeadshotServiceInstance, attacker: Player, victim: Player, bodyPart: string, damage: number) -> boolean,
    RecordHeadshot: (self: HeadshotServiceInstance, attacker: Player) -> (),
}

function HeadshotService.new(): HeadshotServiceInstance
    local self = setmetatable({
        Name = "HeadshotService",
        _playerService = nil,
        _combatService = nil,
    }, HeadshotService)

    return self
end

function HeadshotService:Init(): ()
end

function HeadshotService:Start(): ()
end

function HeadshotService:Destroy(): ()
end

function HeadshotService:SetDependencies(playerService: any, combatService: any): ()
    self._playerService = playerService
    self._combatService = combatService
end

function HeadshotService:ProcessHit(attacker: Player, victim: Player, bodyPart: string, damage: number): boolean
    local isHeadshot = type(bodyPart) == "string" and bodyPart:lower() == "head"
    if isHeadshot and self._playerService then
        self:RecordHeadshot(attacker)
    end

    return isHeadshot
end

function HeadshotService:RecordHeadshot(attacker: Player): ()
    assert(attacker ~= nil, "Attacker cannot be nil")

    if self._playerService then
        local profile = self._playerService:GetProfile(attacker.UserId)
        if profile then
            profile.Stats.Headshots += 1
            profile.Statistics.Headshots = profile.Stats.Headshots
            if self._combatService then
                self._combatService._signals.PlayerHeadshotted:Fire(attacker)
            end
        end
    end
end

return HeadshotService
