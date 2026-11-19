--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterConfig = require(ReplicatedStorage.Shared.Config.CharacterConfig)

local SlideService = {}
SlideService.__index = SlideService

type SlideState = {
    IsSliding: boolean,
    RemainingTime: number,
    Cooldown: number,
}

type SlideServiceInstance = {
    Name: string,
    _state: {[number]: SlideState},
    Init: (self: SlideServiceInstance) -> (),
    Start: (self: SlideServiceInstance) -> (),
    Destroy: (self: SlideServiceInstance) -> (),
    StartSlide: (self: SlideServiceInstance, player: Player) -> boolean,
    EndSlide: (self: SlideServiceInstance, player: Player) -> boolean,
    IsSliding: (self: SlideServiceInstance, player: Player) -> boolean,
    Update: (self: SlideServiceInstance, dt: number) -> (),
}

function SlideService.new(): SlideServiceInstance
    local self = setmetatable({
        Name = "SlideService",
        _state = {},
    }, SlideService)

    return self
end

function SlideService:Init(): ()
end

function SlideService:Start(): ()
end

function SlideService:Destroy(): ()
    self._state = {}
end

function SlideService:StartSlide(player: Player): boolean
    assert(player ~= nil, "Player cannot be nil")

    local state = self._state[player.UserId] or {IsSliding = false, RemainingTime = 0, Cooldown = 0}
    if state.IsSliding or state.Cooldown > 0 then
        return false
    end

    state.IsSliding = true
    state.RemainingTime = CharacterConfig.Movement.SlideDuration
    state.Cooldown = CharacterConfig.Movement.SlideCooldown
    self._state[player.UserId] = state
    return true
end

function SlideService:EndSlide(player: Player): boolean
    assert(player ~= nil, "Player cannot be nil")

    local state = self._state[player.UserId]
    if state == nil or not state.IsSliding then
        return false
    end

    state.IsSliding = false
    state.RemainingTime = 0
    self._state[player.UserId] = state
    return true
end

function SlideService:IsSliding(player: Player): boolean
    local state = self._state[player.UserId]
    return state ~= nil and state.IsSliding
end

function SlideService:Update(dt: number): ()
    assert(type(dt) == "number" and dt >= 0, "Delta time must be non-negative")

    for userId, state in pairs(self._state) do
        if state.RemainingTime > 0 then
            state.RemainingTime = math.max(0, state.RemainingTime - dt)
            if state.RemainingTime <= 0 then
                state.IsSliding = false
            end
        end

        if state.Cooldown > 0 then
            state.Cooldown = math.max(0, state.Cooldown - dt)
        end

        self._state[userId] = state
    end
end

return SlideService
