--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ReplicatedStorage.Shared.Core.Game)

local TeamSelectionController = {}
TeamSelectionController.__index = TeamSelectionController

function TeamSelectionController.new()
    local self = setmetatable({
        Name = "TeamSelectionController",
        _player = Players.LocalPlayer,
        _playerGui = nil,
        _screenGui = nil,
        _infoLabel = nil,
        _chooseTeamRemote = nil,
    }, TeamSelectionController)

    return self
end

function TeamSelectionController:Init()
    assert(self._player ~= nil, "LocalPlayer required")
    self._playerGui = self._player:WaitForChild("PlayerGui")
    self:_buildUI()
end

function TeamSelectionController:Start()
    local remoteRegistry = Game:GetRemoteRegistry()
    self._chooseTeamRemote = remoteRegistry:GetFunction("ChooseTeam")
end

function TeamSelectionController:Destroy()
    if self._screenGui then
        self._screenGui:Destroy()
        self._screenGui = nil
    end
end

function TeamSelectionController:ShowTeamSelection()
    if self._screenGui then
        self._screenGui.Enabled = true
    end
end

function TeamSelectionController:_buildUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeamSelection"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self._playerGui
    screenGui.Enabled = false

    local frame = Instance.new("Frame")
    frame.Name = "TeamFrame"
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
    title.Text = "Selecciona tu equipo"
    title.Parent = frame

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.BackgroundTransparency = 1
    infoLabel.Position = UDim2.new(0, 0, 0, 70)
    infoLabel.Size = UDim2.new(1, 0, 0, 32)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 18
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.Text = "Elige Red o Blue para empezar"
    infoLabel.Parent = frame
    self._infoLabel = infoLabel

    local redButton = Instance.new("TextButton")
    redButton.Name = "RedButton"
    redButton.AnchorPoint = Vector2.new(0.5, 0)
    redButton.Position = UDim2.new(0.5, 0, 0, 110)
    redButton.Size = UDim2.new(0.7, 0, 0, 44)
    redButton.Font = Enum.Font.GothamBold
    redButton.TextSize = 20
    redButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    redButton.BackgroundColor3 = Color3.fromRGB(190, 70, 70)
    redButton.BorderSizePixel = 0
    redButton.Text = "Equipo Rojo"
    redButton.Parent = frame

    local blueButton = Instance.new("TextButton")
    blueButton.Name = "BlueButton"
    blueButton.AnchorPoint = Vector2.new(0.5, 0)
    blueButton.Position = UDim2.new(0.5, 0, 0, 170)
    blueButton.Size = UDim2.new(0.7, 0, 0, 44)
    blueButton.Font = Enum.Font.GothamBold
    blueButton.TextSize = 20
    blueButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    blueButton.BackgroundColor3 = Color3.fromRGB(70, 110, 190)
    blueButton.BorderSizePixel = 0
    blueButton.Text = "Equipo Azul"
    blueButton.Parent = frame

    redButton.MouseButton1Click:Connect(function()
        self:_chooseTeam("Red")
    end)

    blueButton.MouseButton1Click:Connect(function()
        self:_chooseTeam("Blue")
    end)

    self._screenGui = screenGui
end

function TeamSelectionController:_chooseTeam(teamName: string)
    if self._chooseTeamRemote and self._player then
        local success = self._chooseTeamRemote:InvokeServer(teamName)
        if success then
            self._infoLabel.Text = "Equipo seleccionado: " .. teamName
            self._screenGui.Enabled = false
        else
            self._infoLabel.Text = "Error al elegir equipo"
        end
    else
        self._infoLabel.Text = "No se puede seleccionar equipo"
    end
end

return TeamSelectionController
