--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ReplicatedStorage.Shared.Core.Game)

local QueueController = {}
QueueController.__index = QueueController

function QueueController.new()
    local self = setmetatable({
        Name = "QueueController",
        _player = Players.LocalPlayer,
        _playerGui = nil,
        _screenGui = nil,
        _queueButton = nil,
        _cancelButton = nil,
        _statusLabel = nil,
        _joinQueueRemote = nil,
        _leaveQueueRemote = nil,
    }, QueueController)

    return self
end

function QueueController:Init()
    assert(self._player ~= nil, "LocalPlayer required")
    self._playerGui = self._player:WaitForChild("PlayerGui")
    self:_buildUI()
end

function QueueController:Start()
    local remoteRegistry = Game:GetRemoteRegistry()
    self._joinQueueRemote = remoteRegistry:GetFunction("JoinQueue")
    self._leaveQueueRemote = remoteRegistry:GetFunction("LeaveQueue")
end

function QueueController:Destroy()
    if self._screenGui then
        self._screenGui:Destroy()
        self._screenGui = nil
    end
end

function QueueController:ShowQueueMenu()
    if self._screenGui then
        self._screenGui.Enabled = true
    end
end

function QueueController:_buildUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "QueueMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self._playerGui
    screenGui.Enabled = false

    local frame = Instance.new("Frame")
    frame.Name = "QueueFrame"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = UDim2.new(0, 340, 0, 260)
    frame.BackgroundTransparency = 0.25
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "Buscar partida"
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Name = "StatusLabel"
    status.BackgroundTransparency = 1
    status.Position = UDim2.new(0, 0, 0, 70)
    status.Size = UDim2.new(1, 0, 0, 40)
    status.Font = Enum.Font.Gotham
    status.TextSize = 18
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.Text = "Presiona jugar para comenzar"
    status.Parent = frame
    self._statusLabel = status

    local playButton = Instance.new("TextButton")
    playButton.Name = "PlayButton"
    playButton.AnchorPoint = Vector2.new(0.5, 0)
    playButton.Position = UDim2.new(0.5, 0, 0, 120)
    playButton.Size = UDim2.new(0.8, 0, 0, 48)
    playButton.Font = Enum.Font.GothamBold
    playButton.TextSize = 20
    playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    playButton.BackgroundColor3 = Color3.fromRGB(70, 120, 190)
    playButton.BorderSizePixel = 0
    playButton.Text = "Buscar partida"
    playButton.Parent = frame

    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.AnchorPoint = Vector2.new(0.5, 0)
    cancelButton.Position = UDim2.new(0.5, 0, 0, 180)
    cancelButton.Size = UDim2.new(0.8, 0, 0, 48)
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.TextSize = 20
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "Cancelar búsqueda"
    cancelButton.Parent = frame

    playButton.MouseButton1Click:Connect(function()
        self:_startQueue()
    end)

    cancelButton.MouseButton1Click:Connect(function()
        self:_cancelQueue()
    end)

    self._queueButton = playButton
    self._cancelButton = cancelButton
    self._screenGui = screenGui
end

function QueueController:_startQueue()
    if self._joinQueueRemote and self._player then
        local success = self._joinQueueRemote:InvokeServer()
        if success then
            self._statusLabel.Text = "Buscando partida..."
        else
            self._statusLabel.Text = "Ya estás en cola"
        end
    else
        self._statusLabel.Text = "No se puede iniciar la cola"
    end
end

function QueueController:_cancelQueue()
    if self._leaveQueueRemote and self._player then
        local success = self._leaveQueueRemote:InvokeServer()
        if success then
            self._statusLabel.Text = "Búsqueda cancelada"
        else
            self._statusLabel.Text = "No estás en cola"
        end
    else
        self._statusLabel.Text = "No se puede cancelar la cola"
    end
end

return QueueController
