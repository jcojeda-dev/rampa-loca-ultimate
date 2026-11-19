--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterConfig = require(ReplicatedStorage.Shared.Config.CharacterConfig)

local FOVService = {}
FOVService.__index = FOVService

type FOVState = {
    CurrentFOV: number,
    TargetFOV: number,
}

type FOVServiceInstance = {
    Name: string,
    _states: {[number]: FOVState},
    Init: (self: FOVServiceInstance) -> (),
    Start: (self: FOVServiceInstance) -> (),
    Destroy: (self: FOVServiceInstance) -> (),
    SetTargetFOV: (self: FOVServiceInstance, player: Player, targetFOV: number) -> (),
    ResetFOV: (self: FOVServiceInstance, player: Player) -> (),
    Update: (self: FOVServiceInstance, player: Player, dt: number) -> number,
}

function FOVService.new(): FOVServiceInstance
    local self = setmetatable({
        Name = "FOVService",
        _states = {},
    }, FOVService)

    return self
end

function FOVService:Init(): ()
end

function FOVService:Start(): ()
end

function FOVService:Destroy(): ()
    self._states = {}
end

function FOVService:_getState(player: Player): FOVState
    assert(player ~= nil, "Player cannot be nil")

    local state = self._states[player.UserId]
    if state == nil then
        state = {
            CurrentFOV = CharacterConfig.Camera.DefaultFOV,
            TargetFOV = CharacterConfig.Camera.DefaultFOV,
        }
        self._states[player.UserId] = state
    end

    return state
end

function FOVService:SetTargetFOV(player: Player, targetFOV: number): ()
    assert(player ~= nil, "Player cannot be nil")
    assert(type(targetFOV) == "number", "Target FOV must be a number")

    local state = self:_getState(player)
    state.TargetFOV = targetFOV
end

function FOVService:ResetFOV(player: Player): ()
    assert(player ~= nil, "Player cannot be nil")

    local state = self:_getState(player)
    state.TargetFOV = CharacterConfig.Camera.DefaultFOV
end

function FOVService:Update(player: Player, dt: number): number
    assert(player ~= nil, "Player cannot be nil")
    assert(type(dt) == "number" and dt >= 0, "Delta time must be non-negative")

    local state = self:_getState(player)
    local lerp = 1 - math.exp(-CharacterConfig.Camera.FOVLerpSpeed * dt)
    state.CurrentFOV = state.CurrentFOV + (state.TargetFOV - state.CurrentFOV) * lerp
    return state.CurrentFOV
end

return FOVService
