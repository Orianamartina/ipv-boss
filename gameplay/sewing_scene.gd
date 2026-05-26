extends Node2D

@onready var camera = $Camera2D
@onready var path = $Pattern.get_node("PatternPath")
@onready var score_label = $Score/ScoreLabel
@onready var result_panel = $ResultPanel
@onready var result_score_label = $ResultPanel/ScoreLabel
var player_line: Line2D

const MAX_ADVANCE_SPEED := 300.0
const ROTATION_SPEED := 2.0
const SCORE_RANGE := 10.0
const POINT_DISTANCE := 5.0
const FINISH_DISTANCE := 40.0   # distancia a start para considerar que cerro el loop
const MIN_COMPLETION := 0.85    # debe recorrer al menos el 85% del path antes de poder terminar

var score := 0.0
var max_score := 0.0
var sewing_active := true

var total_path_length := 0.0
var max_progress := 0.0             # el offset mas lejano alcanzado sobre el path
var last_line_point := Vector2.ZERO


func _ready() -> void:
	total_path_length = path.curve.get_baked_length()
	max_score = _calculate_max_score()
	score_label.text = "Score: 0 / %d" % int(max_score)

	# la camara arranca en el primer punto del path
	var start_local = path.curve.get_baked_points()[0]
	camera.global_position = path.to_global(start_local)

	# crear la linea como hija del patron para que rote con el mapa
	player_line = Line2D.new()
	player_line.width = 3.0
	player_line.default_color = Color(0.2, 0.2, 0.8, 0.8)
	$Pattern.add_child(player_line)


func _process(delta: float) -> void:
	if not sewing_active:
		return

	# VELOCIDAD - R2 controla la intensidad (0.0 sin presionar, 1.0 a fondo)
	var throttle = Input.get_action_strength("accelerate")
	var speed = throttle * MAX_ADVANCE_SPEED

	# AVANCE - la camara siempre va hacia arriba
	camera.global_position += Vector2.UP * speed * delta

	# ROTACION DEL MAPA - joystick izquierdo gira el patron alrededor de la camara
	var rot_input = Input.get_axis("move_left", "move_right")
	if abs(rot_input) > 0.1:
		_rotate_pattern_around_needle(rot_input * ROTATION_SPEED * delta)

	# TRAZAR LINEA DEL JUGADOR - solo mientras R2 este presionado
	# los puntos se guardan en espacio local del patron para que roten con el mapa
	if throttle > 0.1:
		var local_pos = $Pattern.to_local(camera.global_position)
		if last_line_point == Vector2.ZERO:
			player_line.add_point(local_pos)
			last_line_point = local_pos
		elif local_pos.distance_to(last_line_point) > 5.0:
			player_line.add_point(local_pos)
			last_line_point = local_pos

	# color amarillo cuando R2 no esta presionado
	if throttle <= 0.1:
		score_label.modulate = Color.YELLOW

	# SCORE y PROGRESO - solo se cuentan mientras R2 este presionado
	if throttle > 0.1:
		var local_cam = path.to_local(camera.global_position)
		var current_offset = path.curve.get_closest_offset(local_cam)
		var prev_progress = max_progress
		max_progress = maxf(max_progress, current_offset)
		var offset_advance = max_progress - prev_progress

		# score proporcional a cuanto se avanzó sobre el path
		# evita que movimiento lateral o framerate afecten el puntaje
		if offset_advance > 0:
			var closest = path.curve.get_closest_point(local_cam)
			var distance = local_cam.distance_to(closest)
			var normalized = clamp(distance / SCORE_RANGE, 0.0, 1.0)
			# escalar por offset_advance para que 3 pts equivalga a POINT_DISTANCE de avance
			var local_point_dist = POINT_DISTANCE / path.global_transform.get_scale().x
			var score_delta = lerp(3.0, -2.0, normalized) * (offset_advance / local_point_dist)
			score = maxf(0.0, score + score_delta)
			score_label.text = "Score: %d / %d" % [int(score), int(max_score)]
			score_label.modulate = Color.GREEN if score_delta > 0 else Color.RED

		# DETECTAR FIN - volvio al inicio habiendo recorrido suficiente del path
		# el punto de inicio se recalcula cada frame porque el patron puede haber rotado
		var start_global = path.to_global(path.curve.get_baked_points()[0])
		var completion = max_progress / total_path_length
		var dist_to_start = camera.global_position.distance_to(start_global)
		if completion >= MIN_COMPLETION and dist_to_start < FINISH_DISTANCE:
			_finish_sewing()


# Gira el patron alrededor de la aguja (posicion de la camara)
func _rotate_pattern_around_needle(angle: float) -> void:
	var pivot = camera.global_position
	var offset = $Pattern.global_position - pivot
	$Pattern.global_position = pivot + offset.rotated(angle)
	$Pattern.rotation += angle


func _finish_sewing() -> void:
	sewing_active = false
	
	# Calcular el centro del patrón
	var pattern_center = $Pattern.global_position
	
	# Animar zoom out, centrado y derecho
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# Animar simultáneamente: cámara al centro, zoom out, y rotación a 0
	tween.tween_property(camera, "global_position", pattern_center, 1.5)
	tween.parallel().tween_property(camera, "zoom", Vector2(0.3, 0.3), 1.5)
	tween.parallel().tween_property($Pattern, "rotation", 0.0, 1.5)
	tween.tween_callback(_show_result_panel)


func _show_result_panel() -> void:
	var percentage = int(score / max_score * 100.0)
	result_score_label.text = "%d / %d  (%d%%)" % [int(score), int(max_score), percentage]
	result_panel.visible = true


func _on_continue_pressed() -> void:
	Global.add_score(int(score))
	get_tree().change_scene_to_file("res://UI/ResultScene.tscn")


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()


func _calculate_max_score() -> float:
	var baked_length = path.curve.get_baked_length()
	var screen_scale = path.global_transform.get_scale().x
	return (baked_length * screen_scale / 5.0) * 3.0
