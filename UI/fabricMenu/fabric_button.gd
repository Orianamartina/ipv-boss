extends TextureButton

signal selected(id)

@export var button_id: String

func _pressed():
	selected.emit(button_id)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		_pressed()
