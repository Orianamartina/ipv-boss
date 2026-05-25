extends TextureButton

signal selected(id)

@export var button_id: String

func _pressed():
	selected.emit(button_id)
