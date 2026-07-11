# Deuda Técnica

## Resumen

La base del proyecto es válida, pero aún presenta deuda técnica propia de un scaffolding inicial. La prioridad es reducirla antes de crecer el desarrollo funcional.

## Riesgos detectados

1. El proyecto no tiene aún una implementación completa de servicios de negocio y controladores.
2. No existe una capa de validación de remotes suficiente para producción.
3. Hay módulos con lógica muy básica o incompleta.
4. No existe una estrategia formal de carga de dependencias ni de resolución de orden.
5. La organización de carpetas está definida, pero aún no está totalmente poblada con responsabilidades concretas.

## Problemas de mantenimiento

- Hay riesgo de duplicación si cada módulo implementa su propia lógica de estado.
- El registro actual de servicios y controladores es muy simple y debe evolucionar.
- La arquitectura debe evitar que el código se disperse entre carpetas y scripts.

## Prioridades de reducción de deuda

- consolidar un sistema de registro de servicios y controladores,
- definir contratos de datos y remotes,
- separar claramente lógica de presentación y lógica de negocio,
- documentar decisiones de diseño que impacten el proyecto a medio plazo.
