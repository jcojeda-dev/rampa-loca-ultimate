# Grafo de Dependencias

## Resumen

El proyecto actual tiene un grafo de dependencias relativamente simple y limpio, con una estructura orientada a módulos y servicios.

## Dependencias internas

```text
Bootstrap.server.lua
  -> Shared.Core.Game
  -> Shared.Core.Logger

ServiceLoader.lua
  -> Services/*

Bootstrap.client.lua
  -> Shared.Core.Game

Shared.Core.Game
  -> Services registrados
  -> Controllers registrados

Server.Services.DataService
  -> Shared.Config.ProfileTemplate

Server.Services.RewardService
  -> Shared.Config.GameConstants

Server.Services.RemoteService
  -> ReplicatedStorage.Remotes

Shared.Config.*
  -> constantes y plantillas compartidas

Shared.Modules.Promise
  -> usado como módulo base de sincronización

Shared.Modules.Signal
  -> usado como módulo base de eventos
```

## Dependencias externas

El proyecto declara las siguientes dependencias vía Wally:

- Promise
- Signal
- Component
- Trove
- Comm
- ProfileStore
- TableUtil

## Observación importante

Actualmente el gráfico es bastante plano. Esto es positivo para empezar, pero la escalabilidad exigirá un sistema más explícito de inyección de dependencias y registro de módulos para evitar acoplamiento entre servicios.

## Recomendación

Mantener el grafo de dependencias simple, pero formalizarlo con:

- registro centralizado de servicios,
- contratos claros de interfaces,
- módulos de utilidad reutilizables,
- dependencia explícita en lugar de require disperso.
