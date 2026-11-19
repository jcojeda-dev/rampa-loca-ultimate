#!/usr/bin/env python3
"""Tests for the combat domain modules."""

import os

TEST_DIR = os.path.dirname(os.path.abspath(__file__))
WORKSPACE_ROOT = os.path.dirname(TEST_DIR)
SRC_DIR = os.path.join(WORKSPACE_ROOT, "src")


def test_combat_domain_modules_exist():
    modules = [
        "Shared/Config/CombatConfig.lua",
        "Shared/Events/CombatEvents.lua",
        "Server/Domains/Combat/CombatSignals.lua",
        "Server/Services/CombatService.lua",
        "Server/Services/DamageService.lua",
        "Server/Services/HealthService.lua",
        "Server/Services/DeathService.lua",
        "Server/Services/RespawnService.lua",
        "Server/Services/KillService.lua",
        "Server/Services/AssistService.lua",
        "Server/Services/KillStreakService.lua",
        "Server/Services/HeadshotService.lua",
        "Server/Services/SpectatorService.lua",
    ]

    for module in modules:
        path = os.path.join(SRC_DIR, module)
        assert os.path.exists(path), f"Missing module: {module}"
        assert os.path.getsize(path) > 0, f"Empty module: {module}"


def test_combat_config_keys_exist():
    path = os.path.join(SRC_DIR, "Shared/Config/CombatConfig.lua")
    with open(path, "r", encoding="utf-8") as handle:
        content = handle.read()

    for key in ["HeadshotMultiplier", "FriendlyFire", "TeamDamage", "SpawnProtection", "AssistTimeWindow", "RespawnDelay", "SpectatorEnabled"]:
        assert key in content, f"Missing config key {key}"


def test_combat_events_are_registered():
    path = os.path.join(SRC_DIR, "Shared/Events/CombatEvents.lua")
    with open(path, "r", encoding="utf-8") as handle:
        content = handle.read()

    for event in ["DamageApplied", "DamageBlocked", "PlayerKilled", "PlayerDied", "PlayerAssisted", "PlayerHeadshotted", "Respawned", "SpectatorEntered", "SpectatorExited", "CombatEvent"]:
        assert event in content, f"Missing combat event {event}"


if __name__ == "__main__":
    test_combat_domain_modules_exist()
    test_combat_config_keys_exist()
    test_combat_events_are_registered()
    print("All combat domain tests passed")
