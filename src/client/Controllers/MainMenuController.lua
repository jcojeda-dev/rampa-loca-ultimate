--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ReplicatedStorage.Shared.Core.Game)

local MainMenuController = {}
MainMenuController.__index = MainMenuController

function MainMenuController.new()
    local self = setmetatable({
        Name = "MainMenuController",
        _player = Players.LocalPlayer,
        _playerGui = nil,
        _screenGui = nil,
        _buttons = {},
    }, MainMenuController)

    return self
end

function MainMenuController:Init()
    assert(self._player ~= nil, "LocalPlayer required")
    self._playerGui = self._player:WaitForChild("PlayerGui")
    self:_buildUI()
end

function MainMenuController:Start()
end

function MainMenuController:Destroy()
    if self._screenGui then
        self._screenGui:Destroy()
        self._screenGui = nil
    end
end

function MainMenuController:_buildUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MainMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self._playerGui

    local menuFrame = Instance.new("Frame")
    menuFrame.Name = "MenuFrame"
    menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    menuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    menuFrame.Size = UDim2.new(0, 360, 0, 420)
    menuFrame.BackgroundTransparency = 0.25
    menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    menuFrame.BorderSizePixel = 0
    menuFrame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 30
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "Rampa Loca"
    title.Parent = menuFrame

    local buttonNames = {"Play", "Configurar", "Salir"}
    for index, labelText in ipairs(buttonNames) do
        local button = Instance.new("TextButton")
        button.Name = labelText
        button.AnchorPoint = Vector2.new(0.5, 0)
        button.Position = UDim2.new(0.5, 0, 0, 80 + (index - 1) * 90)
        button.Size = UDim2.new(0.8, 0, 0, 52)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 22
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        button.BorderSizePixel = 0
        button.Text = labelText
        button.Parent = menuFrame

        button.MouseButton1Click:Connect(function()
            self:_onButtonPressed(labelText)
        end)

        self._buttons[labelText] = button
    end

    self._screenGui = screenGui
end

function MainMenuController:_onButtonPressed(action: string)
    if action == "Play" then
        self._screenGui.Enabled = false
        local lobbyController = Game:GetController("LobbyController")
        if lobbyController then
            lobbyController:ShowLobby()
        end
    elseif action == "Configurar" then
        self:_openSettingsDialog()
    elseif action == "Salir" then
        if self._player then
            self._player:Kick("Salir")
        end
    end
end

function MainMenuController:_openSettingsDialog()
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsFrame"
    settingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    settingsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    settingsFrame.Size = UDim2.new(0, 340, 0, 300)
    settingsFrame.BackgroundTransparency = 0.2
    settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Parent = self._screenGui.MenuFrame

    local title = Instance.new("TextLabel")
    title.Name = "SettingsTitle"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 26
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "Configuración"
    title.Parent = settingsFrame

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.AnchorPoint = Vector2.new(0.5, 1)
    closeButton.Position = UDim2.new(0.5, 0, 1, -18)
    closeButton.Size = UDim2.new(0.5, 0, 0, 36)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Cerrar"
    closeButton.Parent = settingsFrame
    closeButton.MouseButton1Click:Connect(function()
        settingsFrame:Destroy()
    end)
end

return MainMenuController
