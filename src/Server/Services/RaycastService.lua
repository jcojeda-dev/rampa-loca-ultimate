--!strict

local Workspace = game:GetService("Workspace")

local RaycastService = {}
RaycastService.__index = RaycastService

type RaycastHitResult = {
    Instance: Instance?,
    Position: Vector3,
    Normal: Vector3,
    Distance: number,
}

type RaycastServiceInstance = {
    Name: string,
    Init: (self: RaycastServiceInstance) -> (),
    Start: (self: RaycastServiceInstance) -> (),
    Destroy: (self: RaycastServiceInstance) -> (),
    Raycast: (self: RaycastServiceInstance, origin: Vector3, direction: Vector3, range: number, ignoreList: {Instance}?) -> RaycastHitResult?,
}

function RaycastService.new(): RaycastServiceInstance
    local self = setmetatable({
        Name = "RaycastService",
    }, RaycastService)

    return self
end

function RaycastService:Init(): ()
end

function RaycastService:Start(): ()
end

function RaycastService:Destroy(): ()
end

function RaycastService:Raycast(origin: Vector3, direction: Vector3, range: number, ignoreList: {Instance}?)
    assert(type(origin) == "userdata", "Origin must be a Vector3")
    assert(type(direction) == "userdata", "Direction must be a Vector3")
    assert(type(range) == "number" and range > 0, "Range must be a positive number")

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    if type(ignoreList) == "table" then
        raycastParams.FilterDescendantsInstances = ignoreList
    end

    local result = Workspace:Raycast(origin, direction.Unit * range, raycastParams)
    if result == nil then
        return nil
    end

    return {
        Instance = result.Instance,
        Position = result.Position,
        Normal = result.Normal,
        Distance = (origin - result.Position).Magnitude,
    }
end

return RaycastService
