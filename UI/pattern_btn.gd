extends TextureButton

signal selected(pattern_data: PatternData)

## Asignar este recurso setea automáticamente las texturas del botón.
@export var pattern_data: PatternData:
	set(value):
		pattern_data = value
		if value:
			if value.button_texture:
				texture_normal = value.button_texture
			if value.button_focus_texture:
				texture_focused = value.button_focus_texture

func _pressed() -> void:
	selected.emit(pattern_data)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		_pressed()
