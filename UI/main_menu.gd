extends Control

@onready var el = $El
@onready var taller = $Taller
@onready var de = $De
@onready var los = $Los
@onready var retazos = $Retazos

@onready var start_button = $StartButton
@onready var green_flower = $GreenFlower
@onready var pink_star = $PinkStar
@onready var scissors = $Scissors

@onready var click_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var titleSprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# --- 1. APARICIÓN DEL TÍTULO (SECUENCIAL) ---
	var title_words = [el, taller, de, los, retazos]
	var title_tween = create_tween()
	var duration := 0.8
	var displacement := 25.0

	for word in title_words:
		var final_pos = word.position
		word.modulate.a = 0.0
		word.position.y += displacement

		title_tween.tween_property(word, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		title_tween.parallel().tween_property(word, "position", final_pos, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# --- 2. BOTÓN DE EMPEZAR (LATIDO INFINITO) ---
	# Guardamos la escala original del botón (0.5, 0.5)
	var btn_initial_scale = start_button.scale
	# Calculamos la escala máxima multiplicándola por 1.1 (un 10% más grande)
	var btn_max_scale = btn_initial_scale * 1.1

	var pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(start_button, "scale", btn_max_scale, 1.0).set_trans(Tween.TRANS_SINE)
	pulse_tween.tween_property(start_button, "scale", btn_initial_scale, 1.0).set_trans(Tween.TRANS_SINE)

	# --- 3. DECORACIONES (ROTACIÓN INFINITA) ---
	# El pivote ahora se lee directamente de lo que configuraste en el inspector
	animate_rotation(green_flower, 5.0)
	animate_rotation(pink_star, -4.0)
	animate_rotation(scissors, 6.0)

# Función auxiliar limpia para gestionar el balanceo cosmético
func animate_rotation(node: Control, angle: float) -> void:
	var tween = create_tween().set_loops()
	var rad = deg_to_rad(angle)
	tween.tween_property(node, "rotation", rad, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation", -rad, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_start_button_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	get_tree().change_scene_to_file("res://UI/PatternMenu.tscn")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		_on_start_button_pressed()
