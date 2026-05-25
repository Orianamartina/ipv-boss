extends Node

var player_name: String = ""
var current_pattern: String = ""
var current_fabric: String = ""
var score: int = 0

signal player_name_changed(new_name: String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_player_name(new_name: String) -> void:
	player_name = new_name
	player_name_changed.emit(new_name)

func set_pattern(pattern: String) -> void:
	current_pattern = pattern

func set_fabric(fabric: String) -> void:
	current_fabric = fabric
	
func add_score(new_score:int) -> void:
	score += new_score
