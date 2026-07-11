# Plan de Rendimiento

## Objetivos

Mantener un rendimiento estable en servidor y cliente mientras el proyecto crece, especialmente en sesiones con varios jugadores.

## Recomendaciones de rendimiento

- evitar crear instancias innecesarias en el ciclo de actualización,
- usar eventos de Roblox de forma eficiente,
- limitar el uso de tareas repetitivas en Heartbeat,
- evitar operaciones costosas dentro de loops de alta frecuencia,
- reducir la cantidad de objetos y conexiones activas.

## Servidor

- mantener los servicios ligeros y con responsabilidades claras,
- centralizar operaciones costosas,
- evitar lecturas y escrituras repetitivas a DataStore sin control,
- separar operaciones de sincronización de lógica de negocio.

## Cliente

- no ejecutar lógica pesada en el arranque si no es imprescindible,
- cargar recursos de forma progresiva,
- limitar actualizaciones de UI innecesarias,
- mantener los controladores con una carga inicial mínima.

## Networking

- priorizar remotes con payloads pequeños,
- evitar enviar datos redundantes,
- documentar qué eventos deben ser server-to-client y cuáles client-to-server,
- validar de forma estricta los datos entrantes.

## Métricas recomendadas

- tiempo de arranque del servidor,
- latencia de remotes,
- número de conexiones activas,
- uso de memoria y CPU en sesiones de prueba.
