--!strict

local MatchConfig = {}

MatchConfig.MaxPlayers = 8

MatchConfig.MinPlayers = 2

MatchConfig.RoundTime = 300

MatchConfig.WarmupTime = 15

MatchConfig.Intermission = 10

MatchConfig.CountdownTime = 5

MatchConfig.RespawnTime = 1

MatchConfig.SpawnTypes = {
    Lobby = "Lobby",
    Red = "Red",
    Blue = "Blue",
    Spectator = "Spectator",
}

MatchConfig.GameModes = {

FFA = {

Players = 8

},

OneVsOne = {

Players = 2

},

FourVsFour = {

Players = 8,

Teams = 2

}

}

return MatchConfig