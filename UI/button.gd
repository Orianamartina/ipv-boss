extends Button

@export var font_size: int = 48:
	set(value):
		font_size = value
		add_theme_font_size_override("font_size", font_size)

func _ready() -> void:
	add_theme_font_size_override("font_size", font_size)
	mouse_entered.connect(func(): modulate = Color(1.08, 1.04, 0.95))
	mouse_exited.connect(func(): modulate = Color.WHITE)
	button_down.connect(func(): modulate = Color(0.85, 0.82, 0.78))
	button_up.connect(func(): modulate = Color(1.08, 1.04, 0.95) if is_hovered() else Color.WHITE)
