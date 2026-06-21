extends TextureButton

signal selected(fabric_data: FabricData)

@export var fabric_data: FabricData:
	set(value):
		fabric_data = value
		if value:
			texture_normal = value.button_texture if value.button_texture else value.texture
			texture_focused = null

func _ready() -> void:
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _on_focus_entered() -> void:
	if fabric_data and fabric_data.button_focus_texture:
		texture_normal = fabric_data.button_focus_texture

func _on_focus_exited() -> void:
	if fabric_data:
		texture_normal = fabric_data.button_texture if fabric_data.button_texture else fabric_data.texture

func _pressed() -> void:
	selected.emit(fabric_data)

func _process(_delta: float) -> void:
	if has_focus() and Input.is_action_just_pressed("enter"):
		_pressed()
