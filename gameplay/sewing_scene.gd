extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var score_hud = $Score
@onready var result_panel: ResultPanel = $ResultPanel
@onready var wood_background: Sprite2D = $WoodBackground
@onready var sewing_audio: AudioStreamPlayer2D = $Needle/SewingMachine

var player_line: Line2D
var pattern_instance: Node2D
var path: Path2D

const SCORE_RANGE := 50.0
const MAX_ADVANCE_SPEED := 300.0
const ROTATION_SPEED := 2.0
const POINT_DISTANCE := 5.0
const FINISH_DISTANCE := 40.0
const MIN_COMPLETION := 0.85
#const PENALTY_PER_SECOND := 100.0

var max_score: int = 5000
var score: float = 0.0
var sewing_active := true
var is_paused := false

var total_path_length: float = 0.0
var max_progress: float = 0.0
var last_line_point := Vector2.ZERO
var motor_audio_level: float = 0.0
var needle_time: float = 0.0
var needle_base_y: float = 0.0


func _ready() -> void:
	if Global.current_pattern != null:
		max_score = Global.current_pattern.max_score

	var cut_pattern_scene := preload("res://gameplay/CutPattern.tscn")
	pattern_instance = cut_pattern_scene.instantiate()
	pattern_instance.scale = Vector2(3, 3)
	add_child(pattern_instance)

	path = pattern_instance.get_node("PatternPath")
	total_path_length = path.curve.get_baked_length()

	score_hud.setup(max_score)

	var start_local: Vector2 = path.curve.get_baked_points()[0]
	var start_world: Vector2 = path.to_global(start_local)
	pattern_instance.global_position += camera.global_position - start_world

	if Global.current_pattern != null:
		var rot := deg_to_rad(Global.current_pattern.texture_rotation_degrees)
		_rotate_pattern_around_needle(-rot)

	var center := get_viewport_rect().size / 2.0
	$Needle/Sprite2D.position = center - Vector2(0, 100)
	$Needle/NeedleMarker.position = center - Vector2(5, 5)
	needle_base_y = $Needle/Sprite2D.position.y

	_create_fabric_polygon()

	player_line = Line2D.new()
	player_line.width = 12.0
	player_line.default_color = Color(1, 1, 1, 1)
	player_line.texture = preload("res://Assets/UI/sewing-scene/stiches.png")
	player_line.texture_mode = Line2D.LINE_TEXTURE_TILE
	player_line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	pattern_instance.add_child(player_line)

	result_panel.setup("Costura terminada!", "Ver resultado")
	result_panel.continue_pressed.connect(_on_continue_pressed)
	result_panel.retry_pressed.connect(_on_retry_pressed)


func _create_fabric_polygon() -> void:
	var sprite := pattern_instance.get_node_or_null("Sprite2D")
	if sprite:
		sprite.visible = false

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


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and sewing_active:
		_toggle_pause()
		return

	if is_paused:
		return

	if not sewing_active:
		return

	var throttle := Input.get_action_strength("accelerate")
	var speed := throttle * MAX_ADVANCE_SPEED
	
	if throttle > 0.1:
		# Sube rápido hacia el nivel del acelerador
		motor_audio_level = move_toward(motor_audio_level, throttle, delta * 5.0)
	else:
		# Baja lentamente cuando sueltas el botón
		motor_audio_level = move_toward(motor_audio_level, 0.0, delta * 2.0)
		
	if motor_audio_level > 0.01:
		if not sewing_audio.playing:
			sewing_audio.play()
		
		# UN SOLO LERP DE VOLUMEN: ajusta el -25 y el -10 si lo quieres más fuerte o suave
		sewing_audio.volume_db = lerp(-18.0, -2.0, motor_audio_level)
		
		# UN SOLO PITCH: Se calcula desde 1.0 (normal) hasta 1.2 (acelerado)
		# Usamos motor_audio_level para que el pitch también baje suavemente al soltar
		sewing_audio.pitch_scale = 1.0 + (motor_audio_level * 0.2)
		
	else:
		if sewing_audio.playing:
			sewing_audio.stop()

	needle_time += throttle * 20.0 * delta
	$Needle/Sprite2D.position.y = needle_base_y + sin(needle_time) * 30.0 * throttle

	pattern_instance.global_position += Vector2.DOWN * speed * delta

	var rot_input := Input.get_axis("move_left", "move_right")
	if abs(rot_input) > 0.1:
		_rotate_pattern_around_needle(rot_input * ROTATION_SPEED * delta)
	if throttle <= 0.1:
		score_hud.update_score(score, Color.YELLOW)
		return

	var local_pos := pattern_instance.to_local(camera.global_position)
	if last_line_point == Vector2.ZERO:
		player_line.add_point(local_pos)
		last_line_point = local_pos
	elif local_pos.distance_to(last_line_point) > 5.0:
		player_line.add_point(local_pos)
		last_line_point = local_pos

	var local_cam: Vector2 = path.to_local(camera.global_position)
	var closest: Vector2 = path.curve.get_closest_point(local_cam)
	var distance: float = local_cam.distance_to(closest)
	var accuracy: float = 1.0 - clamp(distance / SCORE_RANGE, 0.0, 1.0)

	var current_offset: float = path.curve.get_closest_offset(local_cam)
	if current_offset > max_progress + total_path_length * 0.05:
		current_offset = max_progress
	var prev_progress: float = max_progress
	max_progress = maxf(max_progress, current_offset)
	var offset_advance: float = max_progress - prev_progress

	var hud_color := Color.WHITE
	if offset_advance > 0.0:
		if accuracy > 0.0:
			var score_delta: float = (offset_advance / total_path_length) * float(max_score) * accuracy
			score = minf(float(max_score), score + score_delta)
			hud_color = Color.GREEN
		else:
			var penalty: float = (offset_advance / total_path_length) * float(max_score) * 0.2
			score = maxf(0.0, score - penalty)
			hud_color = Color.RED
	score_hud.update_score(score, hud_color)

	var start_global: Vector2 = path.to_global(path.curve.get_baked_points()[0])
	var completion: float = max_progress / total_path_length
	var dist_to_start: float = camera.global_position.distance_to(start_global)
	if completion >= MIN_COMPLETION and dist_to_start < FINISH_DISTANCE:
		_finish_sewing()


func _rotate_pattern_around_needle(angle: float) -> void:
	var pivot := camera.global_position
	var offset := pattern_instance.global_position - pivot
	pattern_instance.global_position = pivot + offset.rotated(angle)
	pattern_instance.rotation += angle



func _finish_sewing() -> void:
	sewing_active = false
	if sewing_audio.playing:
		sewing_audio.stop()

	var pattern_center := pattern_instance.global_position

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(camera, "global_position", pattern_center, 1.5)
	tween.parallel().tween_property(camera, "zoom", Vector2(0.3, 0.3), 1.5)
	tween.parallel().tween_property(pattern_instance, "rotation", 0.0, 1.5)
	tween.parallel().tween_property(wood_background, "rotation", 0.0, 1.5)
	tween.tween_callback(_show_result_panel)


func _show_result_panel() -> void:
	result_panel.setup("Costura terminada!", "Ver resultado")
	var percentage := int(score / float(max_score) * 100.0)
	result_panel.show_result("%d / %d  (%d%%)" % [int(score), max_score, percentage])


func _toggle_pause() -> void:
	is_paused = true
	result_panel.setup("Pausa", "Reanudar", "Reintentar")
	result_panel.show_result("Puntaje: %d" % int(score))


func _on_continue_pressed() -> void:
	if is_paused:
		is_paused = false
		result_panel.visible = false
		return
	Global.add_score(int(score))
	get_tree().change_scene_to_file("res://UI/ResultScene.tscn")


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
