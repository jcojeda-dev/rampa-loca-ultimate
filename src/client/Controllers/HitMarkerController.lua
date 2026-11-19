--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Game = require(ReplicatedStorage.Shared.Core.Game)
local HUDEvents = require(ReplicatedStorage.Shared.Events.HUDEvents)

local HitMarkerController = {}
HitMarkerController.__index = HitMarkerController

function HitMarkerController.new()
    local self = setmetatable({
        Name = "HitMarkerController",
        _player = Players.LocalPlayer,
        _playerGui = nil,
        _screenGui = nil,
        _marker = nil,
    }, HitMarkerController)

    return self
end

function HitMarkerController:Init()
    assert(self._player ~= nil, "LocalPlayer required")
    self._playerGui = self._player:WaitForChild("PlayerGui")
    self:_buildUI()
end

function HitMarkerController:Start()
    local remoteRegistry = Game:GetRemoteRegistry()
    local hudRemote = remoteRegistry:GetEvent("HUDUpdate")
    if hudRemote then
        hudRemote.OnClientEvent:Connect(function(message)
            if type(message) == "table" and message.Event == HUDEvents.HitMarker then
                self:_playHitMarker()
            end
        end)
    end
end

function HitMarkerController:Destroy()
    if self._screenGui then
        self._screenGui:Destroy()
        self._screenGui = nil
    end
end

function HitMarkerController:_buildUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HitMarker"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self._playerGui

    local marker = Instance.new("Frame")
    marker.Name = "HitMarker"
    marker.AnchorPoint = Vector2.new(0.5, 0.5)
    marker.Position = UDim2.new(0.5, 0, 0.5, 0)
    marker.Size = UDim2.new(0, 30, 0, 30)
    marker.BackgroundTransparency = 1
    marker.BorderSizePixel = 0
    marker.Parent = screenGui

    local function createSegment(rotation)
        local segment = Instance.new("Frame")
        segment.Name = "Segment"
        segment.AnchorPoint = Vector2.new(0.5, 0.5)
        segment.Size = UDim2.new(0, 2, 0, 10)
        segment.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        segment.BorderSizePixel = 0
        segment.Rotation = rotation
        segment.Position = UDim2.new(0.5, 0, 0.5, 0)
        segment.Parent = marker
        return segment
    end

    createSegment(0)
    createSegment(90)
    createSegment(180)
    createSegment(270)

    self._marker = marker
    self._screenGui = screenGui
    marker.Visible = false
end

function HitMarkerController:_playHitMarker()
    if not self._marker then
        return
    end

    self._marker.Visible = true
    self._marker.BackgroundTransparency = 1

    task.spawn(function()
        local elapsed = 0
        local duration = 0.25
        while elapsed < duration do
            task.wait(0.03)
            elapsed = elapsed + 0.03
        end
        if self._marker then
            self._marker.Visible = false
        end
    end)
end

return HitMarkerController
