extends Node2D

@onready var scissors: Node2D = $ScissorsCursor
@onready var player_line: Line2D = $PlayerLine
@onready var score_label: Label = $Score/ScoreLabel
@onready var result_panel: ResultPanel = $ResultPanel
@onready var fabric_bg: Sprite2D = $Fabric

var pattern: Node2D
var path: Path2D

const SCORE_AREA_HEIGHT := 80.0
const FABRIC_TILE_SCALE := 0.35

const PERFECT_RANGE := 40.0
const MAX_SPEED := 200.0
const MAX_SPEED_CUTTING := 100.0
const ACCELERATION := 8.0
const POINT_DISTANCE := 5.0
const OVERLAP_DISTANCE := 10.0
const PENALTY_PER_STEP := 5.0

var max_score: int = 5000
var score: float = 0.0
var total_path_length: float = 0.0
var cutting_active := true
var cut_initialized := false
var accumulated_offset: float = 0.0
var max_accumulated: float = 0.0
var prev_raw_offset: float = 0.0
var scissors_position := Vector2.ZERO
var velocity := Vector2.ZERO
var last_point := Vector2.ZERO
var cutting_direction: float = 0.0


func _ready() -> void:
	if Global.current_pattern != null:
		max_score = Global.current_pattern.max_score

	var cut_pattern_scene := preload("res://gameplay/CutPattern.tscn")
	pattern = cut_pattern_scene.instantiate()
	pattern.position = Vector2(567, 350)
	pattern.scale = Vector2(1, 1)
	add_child(pattern)
	move_child(pattern, 3)

	path = pattern.get_node("PatternPath")
	total_path_length = path.curve.get_baked_length()

	_setup_fabric_background()

	var start_local: Vector2 = path.curve.get_baked_points()[0]
	scissors_position = path.to_global(start_local)
	scissors.global_position = scissors_position
	last_point = scissors_position
	score_label.text = "Score: 0 / %d" % max_score

	result_panel.setup("Corte terminado!", "Continuar")
	result_panel.continue_pressed.connect(_on_continue_pressed)
	result_panel.retry_pressed.connect(_on_retry_pressed)


func _setup_fabric_background() -> void:
	if Global.current_fabric == null or Global.current_fabric.texture == null:
		return

	var tex: Texture2D = Global.current_fabric.texture
	var vp := get_viewport_rect().size
	var region_w: float = vp.x / FABRIC_TILE_SCALE
	var region_h: float = (vp.y - SCORE_AREA_HEIGHT) / FABRIC_TILE_SCALE

	fabric_bg.texture = tex
	fabric_bg.centered = false
	fabric_bg.position = Vector2(0.0, SCORE_AREA_HEIGHT)
	fabric_bg.scale = Vector2(FABRIC_TILE_SCALE, FABRIC_TILE_SCALE)
	fabric_bg.region_enabled = true
	fabric_bg.region_rect = Rect2(0.0, 0.0, region_w, region_h)
	fabric_bg.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED


func _process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var current_max_speed := MAX_SPEED_CUTTING if Input.is_action_pressed("cut") else MAX_SPEED
	velocity = velocity.lerp(input_vector * current_max_speed, ACCELERATION * delta)
	scissors_position += velocity * delta
	scissors.global_position = scissors_position

	if input_vector.length() > 0.1:
		scissors.rotation = input_vector.angle()

	if not cutting_active:
		return

	if Input.is_action_just_pressed("cut"):
		last_point = scissors_position
		return

	if Input.is_action_pressed("cut"):
		if scissors_position.distance_to(last_point) > POINT_DISTANCE:

			if _touches_existing_line(scissors_position):
				_finish_cut()
				return

			var local_scissors: Vector2 = path.to_local(scissors_position)
			var closest_point: Vector2 = path.curve.get_closest_point(local_scissors)
			var distance: float = local_scissors.distance_to(closest_point)
			var accuracy: float = 1.0 - clamp(distance / PERFECT_RANGE, 0.0, 1.0)
			var current_offset: float = path.curve.get_closest_offset(local_scissors)

			if not cut_initialized:
				if accuracy > 0.0:
					cut_initialized = true
					prev_raw_offset = current_offset
					accumulated_offset = 0.0
					max_accumulated = 0.0
					cutting_direction = 0.0
				player_line.add_point(scissors_position)
				last_point = scissors_position
				return

			# Progreso relativo: detecta cruce del nudo (salto grande en offset)
			var raw_delta: float = current_offset - prev_raw_offset
			if raw_delta < -total_path_length * 0.5:
				raw_delta += total_path_length
			elif raw_delta > total_path_length * 0.5:
				raw_delta -= total_path_length
			prev_raw_offset = current_offset

			if cutting_direction == 0.0 and abs(raw_delta) > 0.5:
				cutting_direction = sign(raw_delta)

			var progress_delta: float = raw_delta * cutting_direction
			if progress_delta > 0.0:
				accumulated_offset = minf(accumulated_offset + progress_delta, total_path_length)
			var prev_max: float = max_accumulated
			max_accumulated = maxf(max_accumulated, accumulated_offset)
			var offset_advance: float = max_accumulated - prev_max

			if accuracy > 0.0 and offset_advance > 0.0:
				var score_delta: float = (offset_advance / total_path_length) * float(max_score) * accuracy
				score = minf(float(max_score), score + score_delta)
			elif accuracy == 0.0:
				score = maxf(0.0, score - PENALTY_PER_STEP)

			player_line.add_point(scissors_position)
			last_point = scissors_position
			score_label.text = "Score: %d / %d" % [int(score), max_score]


func _touches_existing_line(pos: Vector2) -> bool:
	var points: PackedVector2Array = player_line.points
	var check_up_to: int = points.size() - 20
	if check_up_to < 2:
		return false
	for i in range(check_up_to - 1):
		var closest := Geometry2D.get_closest_point_to_segment(pos, points[i], points[i + 1])
		if pos.distance_to(closest) < OVERLAP_DISTANCE:
			return true
	return false


func _finish_cut() -> void:
	cutting_active = false
	player_line.add_point(player_line.points[0])
	scissors.visible = false
	var percentage := int(score / float(max_score) * 100.0)
	result_panel.show_result("%d / %d  (%d%%)" % [int(score), max_score, percentage])


func _on_continue_pressed() -> void:
	Global.add_score(int(score))
	get_tree().change_scene_to_file("res://gameplay/SewingScene.tscn")


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
