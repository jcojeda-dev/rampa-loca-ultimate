--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterConfig = require(ReplicatedStorage.Shared.Config.CharacterConfig)

local CrouchService = {}
CrouchService.__index = CrouchService

type CrouchState = {
    IsCrouching: boolean,
    TransitionTime: number,
}

type CrouchServiceInstance = {
    Name: string,
    _state: {[number]: CrouchState},
    Init: (self: CrouchServiceInstance) -> (),
    Start: (self: CrouchServiceInstance) -> (),
    Destroy: (self: CrouchServiceInstance) -> (),
    ToggleCrouch: (self: CrouchServiceInstance, player: Player, isCrouching: boolean) -> boolean,
    IsCrouching: (self: CrouchServiceInstance, player: Player) -> boolean,
}

function CrouchService.new(): CrouchServiceInstance
    local self = setmetatable({
        Name = "CrouchService",
        _state = {},
    }, CrouchService)

    return self
end

function CrouchService:Init(): ()
end

function CrouchService:Start(): ()
end

function CrouchService:Destroy(): ()
    self._state = {}
end

function CrouchService:ToggleCrouch(player: Player, isCrouching: boolean): boolean
    assert(player ~= nil, "Player cannot be nil")
    assert(type(isCrouching) == "boolean", "Crouch value must be boolean")

    local state = self._state[player.UserId] or {IsCrouching = false, TransitionTime = 0}
    if state.IsCrouching == isCrouching then
        return false
    end

    state.IsCrouching = isCrouching
    state.TransitionTime = CharacterConfig.Movement.CrouchTransitionTime
    self._state[player.UserId] = state
    return true
end

function CrouchService:IsCrouching(player: Player): boolean
    local state = self._state[player.UserId]
    return state ~= nil and state.IsCrouching
end

return CrouchService
