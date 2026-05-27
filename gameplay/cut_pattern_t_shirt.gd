extends Node2D

@onready var path = $Path2D
@onready var line = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line.points = path.curve.get_baked_points()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
