extends Control

var selected_pattern_id: String = ""

func _ready() -> void:
	var first_button = true
	for child in get_children():
		if child is TextureButton:
			child.focus_mode = Control.FOCUS_ALL
			child.selected.connect(_on_button_selected)
			
			if first_button:
				child.grab_focus()
				first_button = false

func _on_button_selected(pattern_id: String) -> void:
	selected_pattern_id = pattern_id
	Global.set_pattern(pattern_id)
	get_tree().change_scene_to_file("res://UI/fabricMenu/FabricMenu.tscn")
