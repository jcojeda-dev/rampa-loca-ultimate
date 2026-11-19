--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Game = require(ReplicatedStorage.Shared.Core.Game)
local HUDEvents = require(ReplicatedStorage.Shared.Events.HUDEvents)

local HUDController = {}
HUDController.__index = HUDController

function HUDController.new()
    local self = setmetatable({
        Name = "HUDController",
        _player = Players.LocalPlayer,
        _playerGui = nil,
        _screenGui = nil,
        _lifeLabel = nil,
        _ammoLabel = nil,
        _coinsLabel = nil,
        _timeLabel = nil,
        _stateLabel = nil,
        _teamLabel = nil,
        _killsLabel = nil,
    }, HUDController)

    return self
end

function HUDController:Init()
    assert(self._player ~= nil, "LocalPlayer required")
    self._playerGui = self._player:WaitForChild("PlayerGui")
    self:_buildUI()
end

function HUDController:Start()
    local remoteRegistry = Game:GetRemoteRegistry()
    local hudRemote = remoteRegistry:GetEvent("HUDUpdate")
    if hudRemote then
        hudRemote.OnClientEvent:Connect(function(message)
            self:_handleRemote(message)
        end)
    end
end

function HUDController:Destroy()
    if self._screenGui then
        self._screenGui:Destroy()
        self._screenGui = nil
    end
end

function HUDController:_buildUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self._playerGui

    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsFrame"
    statsFrame.AnchorPoint = Vector2.new(0, 0)
    statsFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
    statsFrame.Size = UDim2.new(0.32, 0, 0.18, 0)
    statsFrame.BackgroundTransparency = 0.4
    statsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = screenGui

    local function createLabel(name, position)
        local label = Instance.new("TextLabel")
        label.Name = name
        label.BackgroundTransparency = 1
        label.Position = position
        label.Size = UDim2.new(1, 0, 0.14, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 18
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = ""
        label.Parent = statsFrame
        return label
    end

    self._lifeLabel = createLabel("LifeLabel", UDim2.new(0, 0, 0, 0))
    self._ammoLabel = createLabel("AmmoLabel", UDim2.new(0, 0, 0.16, 0))
    self._coinsLabel = createLabel("CoinsLabel", UDim2.new(0, 0, 0.32, 0))
    self._timeLabel = createLabel("TimeLabel", UDim2.new(0, 0, 0.48, 0))
    self._stateLabel = createLabel("StateLabel", UDim2.new(0, 0, 0.64, 0))
    self._teamLabel = createLabel("TeamLabel", UDim2.new(0, 0, 0.80, 0))
    self._killsLabel = createLabel("KillsLabel", UDim2.new(0, 0, 0.96, 0))

    self._screenGui = screenGui
end

function HUDController:_handleRemote(message)
    if type(message) ~= "table" then
        return
    end

    local event = message.Event
    local payload = message.Payload

    if event == HUDEvents.PlayerStatsUpdated then
        self:_updatePlayerStats(payload)
    elseif event == HUDEvents.MatchStateUpdated then
        self:_updateMatchState(payload)
    end
end

function HUDController:_updatePlayerStats(stats)
    if self._lifeLabel and stats.Health ~= nil then
        self._lifeLabel.Text = string.format("Vida: %d", stats.Health)
    end

    if self._ammoLabel and stats.Ammo ~= nil then
        self._ammoLabel.Text = string.format("Munición: %d / %d", stats.Ammo.Current, stats.Ammo.Max)
    end

    if self._coinsLabel and stats.Coins ~= nil then
        self._coinsLabel.Text = string.format("Monedas: %d", stats.Coins)
    end

    if self._killsLabel and stats.Kills ~= nil then
        self._killsLabel.Text = string.format("Eliminaciones: %d", stats.Kills)
    end
end

function HUDController:_updateMatchState(state)
    if self._timeLabel and state.TimeRemaining ~= nil then
        self._timeLabel.Text = string.format("Tiempo restante: %d", math.max(0, state.TimeRemaining))
    end

    if self._stateLabel and state.MatchState ~= nil then
        self._stateLabel.Text = string.format("Estado: %s", state.MatchState)
    end

    if self._teamLabel and state.TeamName ~= nil then
        self._teamLabel.Text = string.format("Equipo: %s", state.TeamName)
    end
end

return HUDController
