--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Game = require(ReplicatedStorage.Shared.Core.Game)
local HUDEvents = require(ReplicatedStorage.Shared.Events.HUDEvents)

local MatchHUDController = {}
MatchHUDController.__index = MatchHUDController

function MatchHUDController.new()
    local self = setmetatable({
        Name = "MatchHUDController",
        _player = Players.LocalPlayer,
        _playerGui = nil,
        _screenGui = nil,
        _statusLabel = nil,
        _timerLabel = nil,
    }, MatchHUDController)

    return self
end

function MatchHUDController:Init()
    assert(self._player ~= nil, "LocalPlayer required")
    self._playerGui = self._player:WaitForChild("PlayerGui")
    self:_buildUI()
end

function MatchHUDController:Start()
    local remoteRegistry = Game:GetRemoteRegistry()
    local hudRemote = remoteRegistry:GetEvent("HUDUpdate")
    if hudRemote then
        hudRemote.OnClientEvent:Connect(function(message)
            if type(message) ~= "table" then
                return
            end

            if message.Event == HUDEvents.MatchStateUpdated then
                self:_updateMatchHUD(message.Payload)
            end
        end)
    end
end

function MatchHUDController:Destroy()
    if self._screenGui then
        self._screenGui:Destroy()
        self._screenGui = nil
    end
end

function MatchHUDController:_buildUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MatchHUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self._playerGui

    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.AnchorPoint = Vector2.new(0.5, 0)
    statusFrame.Position = UDim2.new(0.5, 0, 0.02, 0)
    statusFrame.Size = UDim2.new(0.28, 0, 0.08, 0)
    statusFrame.BackgroundTransparency = 0.4
    statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = screenGui

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 20
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.Text = "Estado: Esperando"
    statusLabel.Parent = statusFrame

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "TimerLabel"
    timerLabel.BackgroundTransparency = 1
    timerLabel.Position = UDim2.new(0, 0, 0.5, 0)
    timerLabel.Size = UDim2.new(1, 0, 0.5, 0)
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.TextSize = 18
    timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timerLabel.Text = "Tiempo restante: 0"
    timerLabel.Parent = statusFrame

    self._statusLabel = statusLabel
    self._timerLabel = timerLabel
    self._screenGui = screenGui
end

function MatchHUDController:_updateMatchHUD(payload)
    if self._statusLabel and payload.MatchState ~= nil then
        self._statusLabel.Text = string.format("Estado: %s", tostring(payload.MatchState))
    end

    if self._timerLabel and payload.TimeRemaining ~= nil then
        self._timerLabel.Text = string.format("Tiempo restante: %d", math.max(0, payload.TimeRemaining))
    end
end

return MatchHUDController
