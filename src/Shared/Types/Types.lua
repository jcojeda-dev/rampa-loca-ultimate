--!strict

--[[
	Types defines shared Luau type aliases used by the core modules.
]]

local Types = {}

export type Lifecycle = {
    Init: (any) -> (),
    Start: (any) -> (),
    Destroy: (any) -> (),
}

export type ServiceInstance = Lifecycle & {
    Name: string?,
}

export type ControllerInstance = Lifecycle & {
    Name: string?,
}

export type EventHandler = (...any) -> ()

export type Connection = {
    Disconnect: (Connection) -> (),
    Destroy: (Connection) -> (),
}

export type TaskHandle = {
    Id: number,
    Active: boolean,
}

return Types
