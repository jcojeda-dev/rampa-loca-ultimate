# Estructura del Proyecto

## Vista general

La estructura base del proyecto sigue una organización clásica para proyectos Roblox:

```text
src/
├── client/
│   └── Controllers/
├── Server/
│   └── Services/
├── Shared/
│   ├── Config/
│   ├── Core/
│   ├── Enums/
│   ├── Modules/
│   └── Utilities/
├── Replicated/
│   ├── Animations/
│   ├── Assets/
│   ├── Remotes/
│   └── Sounds/
└── UI/
```

## Carpetas principales

### src/client

Contiene los scripts de arranque del cliente, el cargador de controladores y la carpeta de controladores.

### src/Server

Contiene el arranque del servidor, el cargador de servicios y la carpeta de servicios.

### src/Shared

Contiene configuración, constantes, módulos reutilizables, tipos, utilidades y núcleo del juego.

### src/Replicated

Está destinada a recursos y remotes compartidos entre cliente y servidor.

## Módulos core añadidos

- Shared/Core/Game.lua: orquesta el arranque y el ciclo de vida del proyecto.
- Shared/Core/ServiceContainer.lua: gestiona servicios con Init/Start/Destroy.
- Shared/Core/ControllerContainer.lua: gestiona controladores con Init/Start/Destroy.
- Shared/Core/EventBus.lua: centraliza eventos y suscriptores.
- Shared/Core/ResourceCleaner.lua: gestiona limpieza de recursos.
- Shared/Core/TaskScheduler.lua: gestiona tareas y timers.
- Shared/Core/RemoteRegistry.lua: centraliza la creación de remotes.
- Shared/Constants/GameConstants.lua: concentra constantes del juego.
- Shared/Types/Types.lua: define tipos Luau reutilizables.
- Shared/Utilities/Utilities.lua: aporta utilidades compartidas.

## Archivos principales

- default.project.json: configuración de Rojo para Roblox Studio.
- aftman.toml: herramientas del entorno.
- wally.toml: dependencias externas del proyecto.
- selene.toml: reglas de linting.
- stylua.toml: estilo de código.

## Estado actual de carpetas

- Algunas carpetas ya existen con estructura base.
- Otras carpetas de soporte están preparadas para futuras implementaciones.
- El proyecto aún no ha expandido la capa de assets, remotes y UI de forma completa.

## Recomendación de organización

Se recomienda mantener el árbol actual y completar progresivamente cada carpeta con módulos especializados para evitar la proliferación de scripts genéricos.
