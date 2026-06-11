extends Control

const BTN_SCRIPT := preload("res://UI/pattern_btn.gd")

const PATTERNS: Array[String] = [
	"res://patterns/shirt.tres",
	"res://patterns/pants.tres",
]

func _ready() -> void:
	_load_patterns()


func _load_patterns() -> void:
	var container := $ButtonsContainer
	var first_button := true

	for path in PATTERNS:
		var pattern_data: PatternData = load(path)
		if not pattern_data is PatternData:
			push_error("PatternMenu: no se pudo cargar el patron: " + path)
			continue

		var btn := TextureButton.new()
		btn.set_script(BTN_SCRIPT)
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.custom_minimum_size = Vector2(380, 380)
		container.add_child(btn)
		btn.pattern_data = pattern_data
		btn.focus_mode = Control.FOCUS_ALL
		btn.selected.connect(_on_button_selected)

		if first_button:
			btn.grab_focus()
			first_button = false


func _on_button_selected(pattern_data: PatternData) -> void:
	Global.set_pattern(pattern_data)
	get_tree().change_scene_to_file("res://UI/fabricMenu/FabricMenu.tscn")
