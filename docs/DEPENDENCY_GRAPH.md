# Grafo de Dependencias

## Resumen

El proyecto actual tiene un grafo de dependencias relativamente simple y limpio, con una estructura orientada a módulos y servicios.

## Dependencias internas

```text
Bootstrap.server.lua
  -> Shared.Core.Game
  -> Shared.Core.Logger
  -> Shared.Core.ServiceContainer
  -> Server/ServiceLoader.lua

ServiceLoader.lua
  -> Shared.Core.ServiceContainer
  -> Services/*

Bootstrap.client.lua
  -> Shared.Core.Game
  -> Shared.Core.ControllerContainer
  -> client/ControllerLoader.lua

Shared.Core.Game
  -> Shared.Core.ServiceContainer
  -> Shared.Core.ControllerContainer
  -> Shared.Core.EventBus
  -> Shared.Core.ResourceCleaner
  -> Shared.Core.TaskScheduler
  -> Shared.Core.RemoteRegistry

Shared.Core.EventBus
  -> Shared.Modules.Signal

Shared.Core.RemoteRegistry
  -> Shared.Utilities.Utilities

Server.Services.DataService
  -> Shared.Config.ProfileTemplate

Server.Services.RewardService
  -> Shared.Constants.GameConstants

Shared.Config.*
  -> constantes y plantillas compartidas

Shared.Modules.Promise
  -> módulo base de sincronización

Shared.Modules.Signal
  -> módulo base de eventos
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
