#!/usr/bin/env python3
"""Tests for the core gameplay loop feature."""

import os

TEST_DIR = os.path.dirname(os.path.abspath(__file__))
WORKSPACE_ROOT = os.path.dirname(TEST_DIR)
SRC_DIR = os.path.join(WORKSPACE_ROOT, "src")


def test_match_loop_modules_exist():
    modules = [
        "Server/Services/GameStateService.lua",
        "Server/Services/MatchService.lua",
        "Server/Services/RoundService.lua",
        "Server/Services/TeamService.lua",
        "Server/Services/SpawnService.lua",
        "Server/Services/CountdownService.lua",
        "Server/Services/TimerService.lua",
        "Server/Domains/Match/MatchSignals.lua",
        "Shared/Events/MatchEvents.lua",
    ]

    for module in modules:
        path = os.path.join(SRC_DIR, module)
        assert os.path.exists(path), f"Missing module: {module}"
        assert os.path.getsize(path) > 0, f"Empty module: {module}"


def test_match_states_are_defined():
    path = os.path.join(SRC_DIR, "Shared/Enums/MatchState.lua")
    with open(path, "r", encoding="utf-8") as handle:
        content = handle.read()

    for state in ["Waiting", "Queue", "Warmup", "Countdown", "Playing", "Ending", "Restarting"]:
        assert state in content, f"Missing state {state}"


def test_match_modes_and_config_exist():
    config_path = os.path.join(SRC_DIR, "Shared/Config/MatchConfig.lua")
    with open(config_path, "r", encoding="utf-8") as handle:
        content = handle.read()

    for key in ["WarmupTime", "RoundTime", "RespawnTime", "MinPlayers", "MaxPlayers"]:
        assert key in content, f"Missing config key {key}"

    for mode in ["OneVsOne", "FourVsFour"]:
        assert mode in content, f"Missing game mode {mode}"


def test_match_events_are_registered():
    path = os.path.join(SRC_DIR, "Shared/Events/MatchEvents.lua")
    with open(path, "r", encoding="utf-8") as handle:
        content = handle.read()

    for name in ["StateChanged", "MatchStarted", "MatchEnded", "RoundStarted", "RoundEnded"]:
        assert name in content, f"Missing event name {name}"


if __name__ == "__main__":
    test_match_loop_modules_exist()
    test_match_states_are_defined()
    test_match_modes_and_config_exist()
    test_match_events_are_registered()
    print("All match loop tests passed")
