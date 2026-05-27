extends Node

var player_name: String = ""
var current_pattern: PatternData = null
var current_fabric: FabricData = null
var score: int = 0

signal player_name_changed(new_name: String)

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func set_player_name(new_name: String) -> void:
	player_name = new_name
	player_name_changed.emit(new_name)

func set_pattern(pattern: PatternData) -> void:
	current_pattern = pattern

func set_fabric(fabric: FabricData) -> void:
	current_fabric = fabric

func add_score(new_score: int) -> void:
	score += new_score
