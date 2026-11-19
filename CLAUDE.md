# Claude Project Rules

Este proyecto utiliza arquitectura modular.

Nunca crear lógica dentro de StarterGui.

Nunca crear lógica dentro de Workspace.

Toda lógica de servidor pertenece a Services.

Toda lógica del cliente pertenece a Controllers.

Toda configuración pertenece a Shared/Config.

Nunca duplicar código.

Nunca crear scripts con más de 400 líneas.

Si un archivo supera las 400 líneas deberá dividirse.

Toda comunicación Cliente ⇄ Servidor deberá pasar por Remotes.

No modificar directamente monedas.

Utilizar EconomyService.

No modificar directamente vida.

Utilizar CombatService.

Todo código nuevo deberá incluir:

tipado Luau

documentación

manejo de errores

optimización

Nunca utilizar wait()

Utilizar task.wait()

Nunca utilizar spawn()

Utilizar task.spawn()

\# Development Rules



\- Nunca crear servicios aislados si forman parte de un mismo flujo de negocio.

\- Implementar siempre por Features completas.

\- Todo Feature debe quedar funcional al finalizar el Sprint.

\- Cada Feature debe incluir:

&#x20; - código

&#x20; - tests

&#x20; - documentación

&#x20; - actualización de diagramas

&#x20; - eliminación de código muerto

\- Ningún commit debe romper el estado compilable del proyecto.



Toda nueva Feature debe ser completamente desacoplada.



Ningún dominio puede depender directamente de otro dominio.



La comunicación entre dominios deberá realizarse mediante:

\- EventBus

\- Signals

\- Interfaces

\- ServiceContainer



Nunca mediante llamadas circulares.



Al finalizar cada Feature:



\- El proyecto debe poder ejecutarse.

\- La Feature debe ser demostrable dentro de Roblox Studio.

\- Ningún Feature puede quedar parcialmente implementado.

\- Si una integración falla, debe corregirse antes de cerrar el Sprint.

