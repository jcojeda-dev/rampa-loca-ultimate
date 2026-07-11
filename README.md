# Rampa Loca Ultimate

Framework FPS profesional para Roblox.

## Arquitectura

El proyecto está dividido en cuatro capas.

Client

Server

Shared

Replicated

Nunca acceder directamente entre capas.

Toda comunicación deberá realizarse mediante Services o Remotes.

---

## Reglas

No crear Scripts llamados:

Script

LocalScript

ModuleScript

Todos los archivos deberán tener nombres descriptivos.

---

## Convenciones

Services

PlayerService

WeaponService

EconomyService

RewardService

RoundService

Controllers

CameraController

HUDController

UIController

Modules

Signal

Promise

Cleaner

ObjectPool

Nunca acceder directamente a leaderstats.

Siempre utilizar EconomyService.

Nunca modificar Humanoid.Health directamente.

Siempre utilizar CombatService.

Nunca modificar DataStores directamente.

Siempre utilizar DataService.