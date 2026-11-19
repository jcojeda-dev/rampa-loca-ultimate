--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterConfig = require(ReplicatedStorage.Shared.Config.CharacterConfig)

local SprintService = {}
SprintService.__index = SprintService

type SprintServiceInstance = {
    Name: string,
    _runningState: {[number]: boolean},
    Init: (self: SprintServiceInstance) -> (),
    Start: (self: SprintServiceInstance) -> (),
    Destroy: (self: SprintServiceInstance) -> (),
    CanSprint: (self: SprintServiceInstance, player: Player, state: table) -> boolean,
    StartSprint: (self: SprintServiceInstance, player: Player) -> boolean,
    StopSprint: (self: SprintServiceInstance, player: Player) -> boolean,
    IsSprinting: (self: SprintServiceInstance, player: Player) -> boolean,
}

function SprintService.new(): SprintServiceInstance
    local self = setmetatable({
        Name = "SprintService",
        _runningState = {},
    }, SprintService)

    return self
end

function SprintService:Init(): ()
end

function SprintService:Start(): ()
end

function SprintService:Destroy(): ()
    self._runningState = {}
end

function SprintService:CanSprint(player: Player, state: table): boolean
    assert(player ~= nil, "Player cannot be nil")
    assert(type(state) == "table", "State must be a table")

    if state.IsSliding or state.IsCrouching then
        return false
    end

    return true
end

function SprintService:StartSprint(player: Player): boolean
    assert(player ~= nil, "Player cannot be nil")

    if self._runningState[player.UserId] then
        return false
    end

    self._runningState[player.UserId] = true
    return true
end

function SprintService:StopSprint(player: Player): boolean
    assert(player ~= nil, "Player cannot be nil")

    if not self._runningState[player.UserId] then
        return false
    end

    self._runningState[player.UserId] = false
    return true
end

function SprintService:IsSprinting(player: Player): boolean
    return self._runningState[player.UserId] == true
end

return SprintService
