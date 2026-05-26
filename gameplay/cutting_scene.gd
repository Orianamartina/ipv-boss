extends Node2D

@onready var scissors = $ScissorsCursor
@onready var player_line = $PlayerLine
@onready var pattern = $CutPattern
@onready var path = pattern.get_node("PatternPath")
@onready var score_label = $Score/ScoreLabel
@onready var result_panel = $ResultPanel
@onready var result_score_label = $ResultPanel/ScoreLabel

# CURSOR
var scissors_position := Vector2.ZERO
var velocity := Vector2.ZERO

const MAX_SPEED := 500.0
const ACCELERATION := 8.0
const POINT_DISTANCE := 5.0

var last_point := Vector2.ZERO

# GAMEPLAY
const PERFECT_RANGE := 100.0
const OVERLAP_DISTANCE := 10.0  # distancia para detectar cierre del loop
const MIN_POINTS_TO_CLOSE := 30 # puntos minimos antes de poder cerrar

var score := 0
var max_score := 0
var cutting_active := true


func _ready() -> void:
	scissors_position = scissors.global_position
	last_point = scissors_position
	max_score = _calculate_max_score()
	score_label.text = "Score: 0 / %d" % max_score


func _calculate_max_score() -> int:
	var baked_length = path.curve.get_baked_length()
	# get_baked_length() es espacio local del path
	# hay que multiplicar por la escala global para obtener la distancia real en pantalla
	var screen_scale = path.global_transform.get_scale().x
	var screen_length = baked_length * screen_scale
	var num_points = screen_length / POINT_DISTANCE
	return int(num_points * 3.0)  # 3.0 = puntos por corte perfecto


func _process(delta: float) -> void:

	# INPUT ANALOGICO
	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	# MOVIMIENTO SUAVE
	velocity = velocity.lerp(
		input_vector * MAX_SPEED,
		ACCELERATION * delta
	)
	
	scissors_position += velocity * delta

	# MOVER TIJERA
	scissors.global_position = scissors_position

	# ROTAR CURSOR hacia la direccion del joystick
	if input_vector.length() > 0.1:
		scissors.rotation = input_vector.angle()

	if not cutting_active:
		return

	# CORTAR - inicio de cada corte
	if Input.is_action_just_pressed("cut"):
		last_point = scissors_position
		return

	# CORTAR - mientras se mantiene X
	if Input.is_action_pressed("cut"):
		if scissors_position.distance_to(last_point) > POINT_DISTANCE:

			# DETECTAR CIERRE: si toca un segmento ya dibujado → loop cerrado
			if _touches_existing_line(scissors_position):
				_finish_cut()
				return

			# convertir posicion global al espacio local del PatternPath
			var local_scissors = path.to_local(scissors_position)
			var closest_point = path.curve.get_closest_point(local_scissors)
			var distance = local_scissors.distance_to(closest_point)

			player_line.add_point(scissors_position)

			# SCORE SEGUN DISTANCIA AL PATH
			var normalized = clamp(distance / PERFECT_RANGE, 0.0, 1.0)
			score = maxi(0, score + lerp(3.0, -2.0, normalized))

			last_point = scissors_position
			score_label.text = "Score: %d / %d" % [score, max_score]


# Devuelve true si pos toca cualquier segmento ya dibujado
# (ignora los ultimos puntos para no bloquear el dibujo actual)
func _touches_existing_line(pos: Vector2) -> bool:
	var points = player_line.points
	var check_up_to = points.size() - 20
	if check_up_to < 2:
		return false
	for i in range(check_up_to - 1):
		var closest = Geometry2D.get_closest_point_to_segment(pos, points[i], points[i + 1])
		if pos.distance_to(closest) < OVERLAP_DISTANCE:
			return true
	return false


func _finish_cut() -> void:
	cutting_active = false
	player_line.add_point(player_line.points[0])  # cerrar visualmente la linea
	scissors.visible = false
	var percentage = int(float(score) / float(max_score) * 100.0)
	result_score_label.text = "%d / %d  (%d%%)" % [score, max_score, percentage]
	result_panel.visible = true


func _on_continue_pressed() -> void:
	Global.add_score(score)
	get_tree().change_scene_to_file("res://gameplay/SewingScene.tscn")


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
