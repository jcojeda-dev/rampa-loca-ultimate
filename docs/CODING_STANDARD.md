# Estándar de Código

## Principios generales

Todo el código nuevo debe cumplir con:

- tipado Luau cuando sea posible,
- documentación breve y clara,
- manejo de errores explícito,
- uso de task.wait() en lugar de wait(),
- uso de task.spawn() en lugar de spawn(),
- separación clara entre servicios, controladores y módulos compartidos.

## Convenciones de nombres

- Los archivos deben tener nombres descriptivos y consistentes.
- Los servicios deben usar sufijo Service.
- Los controladores deben usar sufijo Controller.
- Los módulos compartidos deben tener nombres claros y reutilizables.

## Estructura de archivos

- Los scripts de arranque deben mantenerse mínimos.
- Los módulos de negocio deben evitar depender de lógica de UI directa.
- Los módulos compartidos deben ser puros, reutilizables y sin efectos secundarios innecesarios.

## Calidad y seguridad de código

- usar --!strict en módulos principales,
- evitar variables globales,
- mantener funciones pequeñas y de propósito único,
- centralizar constantes y configuraciones,
- evitar lógica duplicada.

## Organización de servicios y controladores

- los servicios deben encapsular lógica de servidor,
- los controladores deben encapsular lógica de cliente,
- la comunicación entre capas debe pasar por remotes o servicios bien definidos,
- los módulos deben ser inyectables cuando sea necesario para pruebas o evolución.

## Formato

- usar StyLua como referencia,
- mantener indentación con espacios,
- evitar sentencias largas y confusas,
- mantener consistencia en el estilo de tablas, funciones y comentarios.

## Recomendación

El proyecto debe seguir estas reglas desde el inicio para que la escalabilidad no se vea afectada por deuda técnica.
