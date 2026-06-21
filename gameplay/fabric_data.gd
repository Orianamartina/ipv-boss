## FabricData: recurso que define una tela.
## Creá un .tres nuevo en res://fabrics/ para agregar más telas.
class_name FabricData
extends Resource

## Identificador único de la tela (ej: "fabric-1", "denim", "linen")
@export var id: String = ""

## Nombre visible para el jugador (ej: "Tela floral", "Jean")
@export var display_name: String = ""

## Textura de la tela — se usa para rellenar el patrón en SewingScene.
@export var texture: Texture2D

## Textura del botón en el menú de telas (estado normal).
@export var button_texture: Texture2D

## Textura del botón en el menú de telas (estado enfocado/seleccionado).
@export var button_focus_texture: Texture2D

## Color de la línea del patrón en la escena de corte — elegir un color que contraste con esta tela.
@export var line_color: Color = Color(1, 0, 1, 1)
