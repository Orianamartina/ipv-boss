extends Node2D
const id = "remera"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pattern_pressed() -> void:
	Global.set_pattern(id)
	get_tree().change_scene_to_file("res://UI/FabricMenu.tscn")
