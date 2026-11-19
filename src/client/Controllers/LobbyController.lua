--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ReplicatedStorage.Shared.Core.Game)

local LobbyController = {}
LobbyController.__index = LobbyController

function LobbyController.new()
    local self = setmetatable({
        Name = "LobbyController",
        _player = Players.LocalPlayer,
        _playerGui = nil,
        _screenGui = nil,
        _queueController = nil,
        _teamSelectionController = nil,
    }, LobbyController)

    return self
end

function LobbyController:Init()
    assert(self._player ~= nil, "LocalPlayer required")
    self._playerGui = self._player:WaitForChild("PlayerGui")
    self:_buildUI()
end

function LobbyController:Start()
    self._queueController = Game:GetController("QueueController")
    self._teamSelectionController = Game:GetController("TeamSelectionController")
end

function LobbyController:Destroy()
    if self._screenGui then
        self._screenGui:Destroy()
        self._screenGui = nil
    end
end

function LobbyController:ShowLobby()
    if self._screenGui then
        self._screenGui.Enabled = true
    end
end

function LobbyController:_buildUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LobbyMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self._playerGui
    screenGui.Enabled = false

    local frame = Instance.new("Frame")
    frame.Name = "LobbyFrame"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = UDim2.new(0, 400, 0, 360)
    frame.BackgroundTransparency = 0.25
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "Lobby"
    title.Parent = frame

    local queueButton = Instance.new("TextButton")
    queueButton.Name = "FindMatchButton"
    queueButton.AnchorPoint = Vector2.new(0.5, 0)
    queueButton.Position = UDim2.new(0.5, 0, 0, 80)
    queueButton.Size = UDim2.new(0.72, 0, 0, 48)
    queueButton.Font = Enum.Font.GothamBold
    queueButton.TextSize = 20
    queueButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    queueButton.BackgroundColor3 = Color3.fromRGB(70, 120, 190)
    queueButton.BorderSizePixel = 0
    queueButton.Text = "Buscar partida"
    queueButton.Parent = frame

    local teamButton = Instance.new("TextButton")
    teamButton.Name = "TeamSelectButton"
    teamButton.AnchorPoint = Vector2.new(0.5, 0)
    teamButton.Position = UDim2.new(0.5, 0, 0, 150)
    teamButton.Size = UDim2.new(0.72, 0, 0, 48)
    teamButton.Font = Enum.Font.GothamBold
    teamButton.TextSize = 20
    teamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teamButton.BackgroundColor3 = Color3.fromRGB(170, 90, 60)
    teamButton.BorderSizePixel = 0
    teamButton.Text = "Seleccionar equipo"
    teamButton.Parent = frame

    local backButton = Instance.new("TextButton")
    backButton.Name = "BackButton"
    backButton.AnchorPoint = Vector2.new(0.5, 0)
    backButton.Position = UDim2.new(0.5, 0, 0, 220)
    backButton.Size = UDim2.new(0.72, 0, 0, 48)
    backButton.Font = Enum.Font.GothamBold
    backButton.TextSize = 20
    backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    backButton.BorderSizePixel = 0
    backButton.Text = "Volver"
    backButton.Parent = frame

    queueButton.MouseButton1Click:Connect(function()
        if self._queueController then
            self._queueController:ShowQueueMenu()
        end
    end)

    teamButton.MouseButton1Click:Connect(function()
        if self._teamSelectionController then
            self._teamSelectionController:ShowTeamSelection()
        end
    end)

    backButton.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)

    self._screenGui = screenGui
end

return LobbyController
