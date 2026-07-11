# Plan de Seguridad

## Objetivos

Proteger el proyecto desde el inicio, especialmente en lo relacionado con datos, remotes y lógica del servidor.

## Recomendaciones principales

- validar toda entrada proveniente del cliente,
- no confiar en datos enviados por remotes,
- usar funciones del servidor para modificar estado crítico,
- centralizar lógica de economía y perfiles,
- evitar exponer información sensible innecesariamente.

## Datos y perfiles

- usar servicios dedicados para manejar perfiles y economía,
- evitar modificaciones directas de estado en múltiples puntos,
- proteger el acceso a DataStore y operaciones persistentes.

## Remotes

- registrar remotes con nombres claros y versionados si es necesario,
- validar los parámetros recibidos antes de ejecutar lógica,
- mantener la lógica crítica exclusivamente en el servidor.

## Seguridad operativa

- mantener logs de errores y eventos críticos,
- usar el sistema de logging compartido,
- revisar cambios que afecten a información de jugadores,
- aplicar reglas de validación en todo el pipeline de datos.

## Recomendación

La seguridad debe considerarse parte de la arquitectura, no una capa adicional al final del desarrollo.
