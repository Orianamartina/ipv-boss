extends Control

@onready var mainMenu = $"../MainMenu"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://gameplay/SewingScene.tscn")

	var new_name = $LineEdit.text.strip_edges()
	if new_name.length() > 0:
		Global.set_player_name(new_name)
		hide()
		mainMenu.show()
