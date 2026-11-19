--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local EconomyConstants = require(ReplicatedStorage.Shared.Constants.EconomyConstants)

local SessionManager = {}
SessionManager.__index = SessionManager

type SessionManagerInstance = {
	_sessions: {[number]: PlayerTypes.Session},
	CreateSession: (self: SessionManagerInstance, userId: number, playerId: number) -> PlayerTypes.Session,
	GetSession: (self: SessionManagerInstance, userId: number) -> PlayerTypes.Session?,
	UpdateActivity: (self: SessionManagerInstance, userId: number) -> (),
	DestroySession: (self: SessionManagerInstance, userId: number) -> (),
	IsSessionActive: (self: SessionManagerInstance, userId: number) -> boolean,
	Cleanup: (self: SessionManagerInstance) -> (),
	LockSession: (self: SessionManagerInstance, userId: number) -> (),
	UnlockSession: (self: SessionManagerInstance, userId: number) -> (),
	Destroy: (self: SessionManagerInstance) -> (),
}

function SessionManager.new(): SessionManagerInstance
	local self = setmetatable({
		_sessions = {},
	}, SessionManager)

	return self
end

function SessionManager:CreateSession(userId: number, playerId: number): PlayerTypes.Session
	assert(type(userId) == "number" and userId > 0, "Invalid userId")
	assert(type(playerId) == "number" and playerId > 0, "Invalid playerId")

	local session: PlayerTypes.Session = {
		PlayerId = playerId,
		UserId = userId,
		StartTime = os.time(),
		LastActivity = os.time(),
		Locked = false,
	}

	self._sessions[userId] = session
	return session
end

function SessionManager:GetSession(userId: number): PlayerTypes.Session?
	return self._sessions[userId]
end

function SessionManager:UpdateActivity(userId: number): ()
	local session = self._sessions[userId]
	if session ~= nil then
		session.LastActivity = os.time()
	end
end

function SessionManager:DestroySession(userId: number): ()
	self._sessions[userId] = nil
end

function SessionManager:IsSessionActive(userId: number): boolean
	local session = self._sessions[userId]
	if session == nil then
		return false
	end

	local elapsed = os.time() - session.LastActivity
	return elapsed < EconomyConstants.SESSION_TIMEOUT
end

function SessionManager:Cleanup(): ()
	local now = os.time()
	for userId, session in pairs(self._sessions) do
		local elapsed = now - session.LastActivity
		if elapsed > EconomyConstants.SESSION_TIMEOUT then
			self._sessions[userId] = nil
		end
	end
end

function SessionManager:LockSession(userId: number): ()
	local session = self._sessions[userId]
	if session ~= nil then
		session.Locked = true
	end
end

function SessionManager:UnlockSession(userId: number): ()
	local session = self._sessions[userId]
	if session ~= nil then
		session.Locked = false
	end
end

function SessionManager:Destroy(): ()
	self._sessions = {}
end

return SessionManager
