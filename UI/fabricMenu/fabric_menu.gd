extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var first_button = true
	for child in get_children():
		if child is TextureButton:
			child.selected.connect(_on_button_selected)
			child.focus_mode = Control.FOCUS_ALL
			
			if first_button:
				child.grab_focus()
				first_button = false

func _on_button_selected(fabric):
	Global.set_fabric(fabric)
	get_tree().change_scene_to_file("res://gameplay/CuttingScene.tscn")
