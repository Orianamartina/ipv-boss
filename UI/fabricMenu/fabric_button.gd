extends TextureButton

signal selected(fabric_data: FabricData)

## Asignar este recurso setea automáticamente la textura del botón.
@export var fabric_data: FabricData:
	set(value):
		fabric_data = value
		if value and value.texture:
			texture_normal = value.texture
			texture_focused = value.texture  # misma textura; el foco se indica con brillo

func _ready() -> void:
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
	focus_entered.connect(func(): modulate = Color(1.25, 1.25, 1.25))
	focus_exited.connect(func(): modulate = Color(1.0, 1.0, 1.0))

func _pressed() -> void:
	selected.emit(fabric_data)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		_pressed()
