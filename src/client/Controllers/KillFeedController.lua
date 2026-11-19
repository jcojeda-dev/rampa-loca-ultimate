--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Game = require(ReplicatedStorage.Shared.Core.Game)
local HUDEvents = require(ReplicatedStorage.Shared.Events.HUDEvents)

local KillFeedController = {}
KillFeedController.__index = KillFeedController

function KillFeedController.new()
    local self = setmetatable({
        Name = "KillFeedController",
        _player = Players.LocalPlayer,
        _playerGui = nil,
        _screenGui = nil,
        _feedFrame = nil,
    }, KillFeedController)

    return self
end

function KillFeedController:Init()
    assert(self._player ~= nil, "LocalPlayer required")
    self._playerGui = self._player:WaitForChild("PlayerGui")
    self:_buildUI()
end

function KillFeedController:Start()
    local remoteRegistry = Game:GetRemoteRegistry()
    local hudRemote = remoteRegistry:GetEvent("HUDUpdate")
    if hudRemote then
        hudRemote.OnClientEvent:Connect(function(message)
            if type(message) == "table" and message.Event == HUDEvents.KillFeedEntry then
                self:_appendKillFeed(message.Payload)
            end
        end)
    end
end

function KillFeedController:Destroy()
    if self._screenGui then
        self._screenGui:Destroy()
        self._screenGui = nil
    end
end

function KillFeedController:_buildUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KillFeed"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self._playerGui

    local feedFrame = Instance.new("Frame")
    feedFrame.Name = "FeedFrame"
    feedFrame.AnchorPoint = Vector2.new(1, 0)
    feedFrame.Position = UDim2.new(0.98, 0, 0.02, 0)
    feedFrame.Size = UDim2.new(0.24, 0, 0.26, 0)
    feedFrame.BackgroundTransparency = 0.4
    feedFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    feedFrame.BorderSizePixel = 0
    feedFrame.Parent = screenGui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = feedFrame

    self._feedFrame = feedFrame
    self._screenGui = screenGui
end

function KillFeedController:_appendKillFeed(entry)
    if not self._feedFrame or type(entry) ~= "table" then
        return
    end

    local text = string.format("%s eliminó a %s", tostring(entry.Attacker or "?"), tostring(entry.Victim or "?"))
    local label = Instance.new("TextLabel")
    label.Name = "KillFeedEntry"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 24)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Right
    label.Parent = self._feedFrame

    task.delay(5, function()
        if label and label.Parent then
            label:Destroy()
        end
    end)
end

return KillFeedController
