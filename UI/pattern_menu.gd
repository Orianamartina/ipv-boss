extends Control

const PATTERNS_DIR := "res://patterns/"

const BTN_SCRIPT := preload("res://UI/pattern_btn.gd")

func _ready() -> void:
	_load_patterns()


func _load_patterns() -> void:
	var container := $ButtonsContainer
	var first_button := true

	var dir := DirAccess.open(PATTERNS_DIR)
	if not dir:
		push_error("PatternMenu: no se pudo abrir la carpeta de patrones: " + PATTERNS_DIR)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var pattern_data: PatternData = load(PATTERNS_DIR + file_name)
			if pattern_data is PatternData:
				var btn := TextureButton.new()
				btn.set_script(BTN_SCRIPT)
				btn.ignore_texture_size = true
				btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
				btn.custom_minimum_size = Vector2(380, 380)
				container.add_child(btn)
				# Asignar después de add_child para que el setter pueda acceder al árbol si lo necesita
				btn.pattern_data = pattern_data
				btn.focus_mode = Control.FOCUS_ALL
				btn.selected.connect(_on_button_selected)

				if first_button:
					btn.grab_focus()
					first_button = false

		file_name = dir.get_next()
	dir.list_dir_end()


func _on_button_selected(pattern_data: PatternData) -> void:
	Global.set_pattern(pattern_data)
	get_tree().change_scene_to_file("res://UI/fabricMenu/FabricMenu.tscn")
