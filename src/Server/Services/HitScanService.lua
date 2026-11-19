--!strict

local Players = game:GetService("Players")

local HitScanService = {}
HitScanService.__index = HitScanService

type HitScanServiceInstance = {
    Name: string,
    _raycastService: any,
    _combatService: any,
    Init: (self: HitScanServiceInstance) -> (),
    Start: (self: HitScanServiceInstance) -> (),
    Destroy: (self: HitScanServiceInstance) -> (),
    SetDependencies: (self: HitScanServiceInstance, raycastService: any, combatService: any) -> (),
    FireHitScan: (self: HitScanServiceInstance, attacker: Player, origin: Vector3, direction: Vector3, weapon: table, bodyPartMap: {[string]: string?}) -> boolean,
}

function HitScanService.new(): HitScanServiceInstance
    local self = setmetatable({
        Name = "HitScanService",
        _raycastService = nil,
        _combatService = nil,
    }, HitScanService)

    return self
end

function HitScanService:Init(): ()
end

function HitScanService:Start(): ()
end

function HitScanService:Destroy(): ()
end

function HitScanService:SetDependencies(raycastService: any, combatService: any): ()
    self._raycastService = raycastService
    self._combatService = combatService
end

function HitScanService:FireHitScan(attacker: Player, origin: Vector3, direction: Vector3, weapon: table, bodyPartMap: {[string]: string?})
    assert(attacker ~= nil, "Attacker cannot be nil")
    assert(type(origin) == "userdata", "Origin must be a Vector3")
    assert(type(direction) == "userdata", "Direction must be a Vector3")
    assert(type(weapon) == "table", "Weapon must be a table")

    if self._raycastService == nil or self._combatService == nil then
        return false
    end

    bodyPartMap = bodyPartMap or {}
    local hit = self._raycastService:Raycast(origin, direction, weapon.Range, {attacker.Character})
    if hit == nil or hit.Instance == nil then
        return false
    end

    local target = hit.Instance:FindFirstAncestorWhichIsA("Model")
    if target == nil then
        return false
    end

    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if humanoid == nil then
        return false
    end

    local victim = Players:GetPlayerFromCharacter(target)
    if victim == nil then
        return false
    end

    local bodyPart = bodyPartMap[hit.Instance.Name] or "Torso"
    self._combatService:ApplyDamage(attacker, victim, bodyPart, weapon.Damage, weapon.Name)
    return true
end

return HitScanService
