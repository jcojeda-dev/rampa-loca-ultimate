#!/usr/bin/env python3
"""Tests for the Weapon Domain modules."""

import os

TEST_DIR = os.path.dirname(os.path.abspath(__file__))
WORKSPACE_ROOT = os.path.dirname(TEST_DIR)
SRC_DIR = os.path.join(WORKSPACE_ROOT, "src")


def test_weapon_domain_modules_exist():
    modules = [
        "Shared/Config/WeaponConfig.lua",
        "Shared/Enums/FireMode.lua",
        "Shared/Events/WeaponEvents.lua",
        "Server/Services/WeaponRepository.lua",
        "Server/Services/WeaponFactory.lua",
        "Server/Services/WeaponService.lua",
        "Server/Services/HitScanService.lua",
        "Server/Services/AmmoService.lua",
        "Server/Services/ReloadService.lua",
        "Server/Services/RecoilService.lua",
        "Server/Services/SpreadService.lua",
        "Server/Services/FireModeService.lua",
        "Server/Services/RaycastService.lua",
        "Server/Domains/Weapon/WeaponSignals.lua",
    ]

    for module in modules:
        path = os.path.join(SRC_DIR, module)
        assert os.path.exists(path), f"Missing module: {module}"
        assert os.path.getsize(path) > 0, f"Empty module: {module}"


def test_weapon_config_contains_weapons():
    config_path = os.path.join(SRC_DIR, "Shared/Config/WeaponConfig.lua")
    with open(config_path, "r", encoding="utf-8") as handle:
        content = handle.read()

    assert "Pistol" in content, "WeaponConfig should define Pistol"
    assert "Sniper" in content, "WeaponConfig should define Sniper"
    assert "FireMode" in content, "WeaponConfig should reference FireMode definitions"


def test_weapon_service_lifecycle_methods():
    service_path = os.path.join(SRC_DIR, "Server/Services/WeaponService.lua")
    with open(service_path, "r", encoding="utf-8") as handle:
        content = handle.read()

    assert "function WeaponService:Init" in content, "WeaponService missing Init method"
    assert "function WeaponService:Start" in content, "WeaponService missing Start method"
    assert "function WeaponService:Destroy" in content, "WeaponService missing Destroy method"


if __name__ == "__main__":
    test_weapon_domain_modules_exist()
    test_weapon_config_contains_weapons()
    test_weapon_service_lifecycle_methods()
    print("✅ Weapon domain tests passed")
