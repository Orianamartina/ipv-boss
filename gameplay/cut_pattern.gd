extends Node2D

@onready var path = $PatternPath
@onready var line = $PatternLine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line.points = path.curve.get_baked_points()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
