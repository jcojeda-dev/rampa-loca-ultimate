--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Game = require(ReplicatedStorage.Shared.Core.Game)
local HUDEvents = require(ReplicatedStorage.Shared.Events.HUDEvents)

local CrosshairController = {}
CrosshairController.__index = CrosshairController

function CrosshairController.new()
    local self = setmetatable({
        Name = "CrosshairController",
        _player = Players.LocalPlayer,
        _playerGui = nil,
        _screenGui = nil,
        _crosshairLines = {},
        _spread = 0,
    }, CrosshairController)

    return self
end

function CrosshairController:Init()
    assert(self._player ~= nil, "LocalPlayer required")
    self._playerGui = self._player:WaitForChild("PlayerGui")
    self:_buildUI()
end

function CrosshairController:Start()
    local remoteRegistry = Game:GetRemoteRegistry()
    local hudRemote = remoteRegistry:GetEvent("HUDUpdate")
    if hudRemote then
        hudRemote.OnClientEvent:Connect(function(message)
            if type(message) == "table" and message.Event == HUDEvents.CrosshairSpreadUpdated then
                self:_setSpread(message.Payload.Spread or 0)
            end
        end)
    end
end

function CrosshairController:Destroy()
    if self._screenGui then
        self._screenGui:Destroy()
        self._screenGui = nil
    end
end

function CrosshairController:_buildUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Crosshair"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self._playerGui

    local center = UDim2.new(0.5, 0, 0.5, 0)
    local length = 12
    local thickness = 2
    local offset = 20

    local function createLine(name, rotation)
        local line = Instance.new("Frame")
        line.Name = name
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.Size = UDim2.new(0, length, 0, thickness)
        line.Position = center
        line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        line.BorderSizePixel = 0
        line.Rotation = rotation
        line.Parent = screenGui
        return line
    end

    self._crosshairLines = {
        createLine("CrosshairTop", 0),
        createLine("CrosshairRight", 90),
        createLine("CrosshairBottom", 180),
        createLine("CrosshairLeft", 270),
    }

    self._screenGui = screenGui
    self:_updateCrosshairPosition()
end

function CrosshairController:_setSpread(spread)
    self._spread = math.clamp(spread, 0, 50)
    self:_updateCrosshairPosition()
end

function CrosshairController:_updateCrosshairPosition()
    local baseOffset = 14
    local offset = baseOffset + self._spread
    for index, line in ipairs(self._crosshairLines) do
        local direction = (index - 1) * 90
        if direction == 0 then
            line.Position = UDim2.new(0.5, 0, 0.5, -offset)
        elseif direction == 90 then
            line.Position = UDim2.new(0.5, 0 + offset, 0.5, 0)
        elseif direction == 180 then
            line.Position = UDim2.new(0.5, 0, 0.5, offset)
        elseif direction == 270 then
            line.Position = UDim2.new(0.5, -offset, 0.5, 0)
        end
    end
end

return CrosshairController
