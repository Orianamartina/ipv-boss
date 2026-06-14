extends Node2D

@onready var path: Path2D = $PatternPath
@onready var line: Line2D = $PatternLine


func _ready() -> void:
	if Global.current_pattern != null and Global.current_pattern.path_scene != null:
		var shape_node = Global.current_pattern.path_scene.instantiate()
		if shape_node is Path2D:
			path.curve = shape_node.curve
		shape_node.queue_free()

	if Global.current_pattern != null:
		var s := Global.current_pattern.texture_scale
		path.scale = Vector2(s, s)
		line.scale = Vector2(s, s)

	line.points = path.curve.get_baked_points()

	if Global.current_pattern != null:
		var rot := Global.current_pattern.texture_rotation_degrees
		path.rotation_degrees = rot
		line.rotation_degrees = rot

	var sprite := get_node_or_null("Sprite2D")
	if sprite and Global.current_pattern != null and Global.current_pattern.pattern_texture != null:
		sprite.texture = Global.current_pattern.pattern_texture
		var s := Global.current_pattern.texture_scale
		sprite.scale = Vector2(s, s)
		sprite.rotation_degrees = Global.current_pattern.texture_rotation_degrees
