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