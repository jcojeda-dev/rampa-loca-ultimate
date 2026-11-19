--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterConfig = require(ReplicatedStorage.Shared.Config.CharacterConfig)

local MovementService = {}
MovementService.__index = MovementService

type MovementState = {
    IsSprinting: boolean,
    IsCrouching: boolean,
    IsSliding: boolean,
}

type MovementServiceInstance = {
    Name: string,
    Init: (self: MovementServiceInstance) -> (),
    Start: (self: MovementServiceInstance) -> (),
    Destroy: (self: MovementServiceInstance) -> (),
    GetDesiredSpeed: (self: MovementServiceInstance, state: MovementState) -> number,
    ApplyGroundFriction: (self: MovementServiceInstance, velocity: Vector3, dt: number) -> Vector3,
    ApplyAirControl: (self: MovementServiceInstance, currentVelocity: Vector3, desiredDirection: Vector3, dt: number) -> Vector3,
    UpdateVelocity: (self: MovementServiceInstance, currentVelocity: Vector3, desiredDirection: Vector3, state: MovementState, dt: number, isGrounded: boolean) -> Vector3,
}

function MovementService.new(): MovementServiceInstance
    local self = setmetatable({
        Name = "MovementService",
    }, MovementService)

    return self
end

function MovementService:Init(): ()
end

function MovementService:Start(): ()
end

function MovementService:Destroy(): ()
end

function MovementService:GetDesiredSpeed(state: MovementState): number
    assert(type(state) == "table", "Movement state must be a table")

    local baseSpeed = CharacterConfig.Movement.WalkSpeed
    if state.IsSliding then
        return baseSpeed * CharacterConfig.Movement.SlideSpeedMultiplier
    end
    if state.IsSprinting then
        return CharacterConfig.Movement.SprintSpeed
    end
    if state.IsCrouching then
        return baseSpeed * CharacterConfig.Movement.CrouchSpeedMultiplier
    end

    return baseSpeed
end

function MovementService:ApplyGroundFriction(velocity: Vector3, dt: number): Vector3
    assert(type(velocity) == "userdata", "Velocity must be a Vector3")
    assert(type(dt) == "number" and dt >= 0, "Delta time must be non-negative")

    local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
    local speed = horizontal.Magnitude
    if speed <= 0 then
        return Vector3.new(0, velocity.Y, 0)
    end

    local drop = math.max(speed, CharacterConfig.Movement.GroundFriction * dt)
    local newSpeed = math.max(0, speed - drop)
    local direction = horizontal.Unit

    return direction * newSpeed + Vector3.new(0, velocity.Y, 0)
end

function MovementService:ApplyAirControl(currentVelocity: Vector3, desiredDirection: Vector3, dt: number): Vector3
    assert(type(currentVelocity) == "userdata", "Velocity must be a Vector3")
    assert(type(desiredDirection) == "userdata", "Direction must be a Vector3")
    assert(type(dt) == "number" and dt >= 0, "Delta time must be non-negative")

    if desiredDirection.Magnitude <= 0 then
        return currentVelocity
    end

    local horizontal = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
    local target = desiredDirection.Unit * math.min(horizontal.Magnitude, CharacterConfig.Movement.MaxAirSpeed)
    local delta = target - horizontal
    local control = math.clamp(CharacterConfig.Movement.AirControl * dt, 0, 1)
    local corrected = horizontal + delta * control

    return Vector3.new(corrected.X, currentVelocity.Y, corrected.Z)
end

function MovementService:UpdateVelocity(currentVelocity: Vector3, desiredDirection: Vector3, state: MovementState, dt: number, isGrounded: boolean): Vector3
    assert(type(currentVelocity) == "userdata", "Velocity must be a Vector3")
    assert(type(desiredDirection) == "userdata", "Direction must be a Vector3")
    assert(type(state) == "table", "Movement state must be a table")
    assert(type(dt) == "number" and dt >= 0, "Delta time must be non-negative")

    local horizontal = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
    local targetSpeed = self:GetDesiredSpeed(state)
    local desiredVelocity = Vector3.new(0, 0, 0)

    if desiredDirection.Magnitude > 0 then
        desiredVelocity = desiredDirection.Unit * targetSpeed
    end

    if isGrounded then
        local currentSpeed = horizontal.Magnitude
        local speedDelta = targetSpeed - currentSpeed
        local acceleration = CharacterConfig.Movement.MaxAcceleration * dt
        local change = math.clamp(speedDelta, -acceleration, acceleration)
        local newSpeed = currentSpeed + change
        local newDirection = desiredDirection.Magnitude > 0 and desiredDirection.Unit or (currentSpeed > 0 and horizontal.Unit or Vector3.new())
        horizontal = newDirection * newSpeed
        if desiredDirection.Magnitude <= 0 then
            horizontal = self:ApplyGroundFriction(horizontal, dt)
        end
    else
        horizontal = self:ApplyAirControl(horizontal, desiredDirection, dt)
    end

    return Vector3.new(horizontal.X, currentVelocity.Y, horizontal.Z)
end

return MovementService
