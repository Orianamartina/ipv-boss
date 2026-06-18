extends Control

@onready var score_label = $ScoreLabel
@onready var detail_label = $DetailLabel
@onready var pattern_marker = $PatternMarker
@onready var stars_container = $StarsContainer
@onready var back_button = $BackButton

func _ready() -> void:
	score_label.text = "Puntaje total: 0"
	_setup_pattern_display()
	back_button.pressed.connect(_on_back_pressed)
	back_button.focus_mode = Control.FOCUS_ALL
	back_button.grab_focus()
	_animate_score_then_stars()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("enter") and back_button.has_focus():
		_on_back_pressed()


func _animate_score_then_stars() -> void:
	var tween := create_tween()
	tween.tween_method(_update_score_label, 0.0, float(Global.score), 1.5)
	tween.tween_callback(_animate_stars)


func _update_score_label(value: float) -> void:
	score_label.text = "Puntaje total: %d" % int(value)


func _animate_stars() -> void:
	var star_tex: Texture2D = load("res://Assets/UI/star.png")
	var star_disabled_tex: Texture2D = load("res://Assets/UI/star-disabled.png")
	var max_total := 10000
	if Global.current_pattern != null:
		max_total = Global.current_pattern.max_score * 2
	var star_count := maxi(1, clampi(roundi(float(Global.score) / float(max_total) * 5.0), 0, 5))

	var star_nodes := stars_container.get_children()
	for star in star_nodes:
		(star as TextureRect).texture = star_disabled_tex

	for i in star_count:
		var star := star_nodes[i] as TextureRect
		star.pivot_offset = star.size / 2.0
		var tween := create_tween()
		tween.tween_interval(float(i) * 0.35)
		tween.tween_callback(func(): star.texture = star_tex)
		tween.tween_property(star, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(star, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _setup_pattern_display() -> void:
	var cut_pattern_scene := preload("res://gameplay/CutPattern.tscn")
	var pattern_instance: Node2D = cut_pattern_scene.instantiate()
	add_child(pattern_instance)
	move_child(pattern_instance, 1)

	var sprite := pattern_instance.get_node_or_null("Sprite2D")
	if sprite:
		sprite.visible = false

	var pattern_line := pattern_instance.get_node_or_null("PatternLine")
	if pattern_line:
		pattern_line.visible = false

	# Calcular bounding box del path en espacio local
	var path: Path2D = pattern_instance.get_node("PatternPath")
	path.rotation_degrees = 0.0

	var pattern_position = pattern_marker.position
	pattern_instance.position = pattern_position
	pattern_instance.scale = Vector2(0.7, 0.7)

	_create_fabric_polygon(pattern_instance)

	if Global.current_pattern != null and Global.current_pattern.pattern_final_texture != null:
		var final_sprite := Sprite2D.new()
		final_sprite.texture = Global.current_pattern.pattern_final_texture
		var s := Global.current_pattern.texture_scale
		final_sprite.scale = Vector2(s, s)
		pattern_instance.add_child(final_sprite)


func _create_fabric_polygon(pattern_instance: Node2D) -> void:
	var path: Path2D = pattern_instance.get_node("PatternPath")
	var raw_points: PackedVector2Array = path.curve.get_baked_points()
	var points: PackedVector2Array = PackedVector2Array()
	for p in raw_points:
		points.append(path.transform * p)
	if points.size() > 1:
		var last := points[points.size() - 1]
		if points[0].distance_to(last) < 1.0:
			points = points.slice(0, points.size() - 1)

	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)
	for p in points:
		min_pos.x = minf(min_pos.x, p.x)
		min_pos.y = minf(min_pos.y, p.y)
		max_pos.x = maxf(max_pos.x, p.x)
		max_pos.y = maxf(max_pos.y, p.y)
	var poly_size: Vector2 = max_pos - min_pos

	var fabric_polygon := Polygon2D.new()
	fabric_polygon.polygon = points

	if Global.current_fabric != null and Global.current_fabric.texture != null:
		var tex: Texture2D = Global.current_fabric.texture
		var tex_size := Vector2(tex.get_width(), tex.get_height())
		var tile_size := 100.0
		var uvs := PackedVector2Array()
		for p in points:
			uvs.append((p - min_pos) / tile_size * tex_size)
		fabric_polygon.uv = uvs
		fabric_polygon.texture = tex
		fabric_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	else:
		fabric_polygon.color = Color(1.0, 0.7, 0.85, 1.0)

	pattern_instance.add_child(fabric_polygon)
	pattern_instance.move_child(fabric_polygon, 0)


func _on_back_pressed() -> void:
	Global.score = 0
	get_tree().change_scene_to_file("res://UI/PatternMenu.tscn")
