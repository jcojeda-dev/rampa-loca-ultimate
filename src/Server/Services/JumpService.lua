--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterConfig = require(ReplicatedStorage.Shared.Config.CharacterConfig)

local JumpService = {}
JumpService.__index = JumpService

type JumpState = {
    LastGroundedTime: number,
    LastJumpRequestTime: number,
    JumpCount: number,
}

type JumpServiceInstance = {
    Name: string,
    _state: {[number]: JumpState},
    Init: (self: JumpServiceInstance) -> (),
    Start: (self: JumpServiceInstance) -> (),
    Destroy: (self: JumpServiceInstance) -> (),
    RequestJump: (self: JumpServiceInstance, player: Player) -> (),
    CanJump: (self: JumpServiceInstance, player: Player, isGrounded: boolean) -> boolean,
    ConsumeJump: (self: JumpServiceInstance, player: Player) -> boolean,
    UpdateGrounded: (self: JumpServiceInstance, player: Player, isGrounded: boolean) -> (),
    GetJumpPower: (self: JumpServiceInstance) -> number,
}

function JumpService.new(): JumpServiceInstance
    local self = setmetatable({
        Name = "JumpService",
        _state = {},
    }, JumpService)

    return self
end

function JumpService:Init(): ()
end

function JumpService:Start(): ()
end

function JumpService:Destroy(): ()
    self._state = {}
end

function JumpService:_getState(player: Player): JumpState
    assert(player ~= nil, "Player cannot be nil")

    local state = self._state[player.UserId]
    if state == nil then
        state = {
            LastGroundedTime = 0,
            LastJumpRequestTime = 0,
            JumpCount = 0,
        }
        self._state[player.UserId] = state
    end

    return state
end

function JumpService:RequestJump(player: Player): ()
    assert(player ~= nil, "Player cannot be nil")
    local state = self:_getState(player)
    state.LastJumpRequestTime = tick()
end

function JumpService:CanJump(player: Player, isGrounded: boolean): boolean
    assert(player ~= nil, "Player cannot be nil")

    local state = self:_getState(player)
    local now = tick()
    local buffered = now - state.LastJumpRequestTime <= CharacterConfig.Jump.BufferTime
    local coyote = isGrounded or (now - state.LastGroundedTime <= CharacterConfig.Jump.CoyoteTime)

    if buffered and coyote then
        return true
    end

    return false
end

function JumpService:ConsumeJump(player: Player): boolean
    assert(player ~= nil, "Player cannot be nil")

    local state = self:_getState(player)
    local now = tick()
    if now - state.LastJumpRequestTime <= CharacterConfig.Jump.BufferTime then
        state.LastJumpRequestTime = 0
        state.JumpCount = state.JumpCount + 1
        return true
    end

    return false
end

function JumpService:UpdateGrounded(player: Player, isGrounded: boolean): ()
    assert(player ~= nil, "Player cannot be nil")
    local state = self:_getState(player)

    if isGrounded then
        state.LastGroundedTime = tick()
        state.JumpCount = 0
    end
end

function JumpService:GetJumpPower(): number
    return CharacterConfig.Jump.Power
end

return JumpService
