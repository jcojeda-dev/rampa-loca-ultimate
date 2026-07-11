# Arquitectura del Proyecto

## Visión general

El proyecto sigue una arquitectura modular orientada a capas para Roblox, con separación entre:

- Cliente
- Servidor
- Compartido
- Replicado

La idea central es evitar lógica dispersa y mantener cada responsabilidad en un módulo específico.

## Capa Cliente

Responsabilidades:

- inicialización del cliente,
- controladores de entrada y experiencia,
- consumo de remotas,
- interacción con la interfaz y la cámara.

Actualmente la capa cliente cuenta con un arranque básico y un registro de controladores, pero aún no ha sido ampliada con módulos funcionales.

## Capa Servidor

Responsabilidades:

- servicios de negocio,
- gestión de perfiles y datos,
- lógica de economía,
- eventos del servidor,
- coordinación de estado global.

El servidor ya tiene servicios base como DataService, EconomyService, PlayerService y NotificationService, lo que ofrece una base correcta para escalar.

## Capa Compartida

Responsabilidades:

- configuración centralizada,
- constantes globales,
- utilidades compartidas,
- tipos y módulos reutilizables,
- núcleo del juego.

Aquí se ubican archivos como Game.lua, Logger.lua, GameConfig.lua, EconomyConfig.lua y los módulos Promise/Signal.

## Capa Replicada

Responsabilidades:

- definición de remotes,
- activos compartidos,
- recursos de comunicación entre cliente y servidor.

Actualmente está preparada para extenderse con remotes y recursos replicados.

## Flujo de arranque

1. El script cliente inicia el núcleo compartido.
2. El script servidor inicia el núcleo compartido.
3. El núcleo registra servicios y controladores.
4. Cada módulo puede inicializarse con Init y arrancarse con Start.

## Principios de diseño

- ninguna capa debe depender directamente de otra de forma implícita,
- la lógica del servidor debe vivir en servicios,
- la lógica del cliente debe vivir en controladores,
- la comunicación cliente-servidor debe pasar por remotes,
- la configuración debe ser central y reutilizable.

## Observación

La arquitectura actual es correcta para un proyecto escalable, pero debe consolidarse con convenciones más estrictas y con la incorporación de dependencias explícitas entre servicios y controladores.
