## FabricData: recurso que define una tela.
## Creá un .tres nuevo en res://fabrics/ para agregar más telas.
class_name FabricData
extends Resource

## Identificador único de la tela (ej: "fabric-1", "denim", "linen")
@export var id: String = ""

## Nombre visible para el jugador (ej: "Tela floral", "Jean")
@export var display_name: String = ""

## Textura de la tela — se usa en el botón del menú y para rellenar el patrón en SewingScene.
@export var texture: Texture2D
