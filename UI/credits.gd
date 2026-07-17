extends Control

@onready var title_label = $TitleLabel
@onready var name1 = $Name1
@onready var name2 = $Name2
@onready var role1 = $Role1
@onready var role2 = $Role2
@onready var thanks_label = $ThanksLabel
@onready var back_button = $BackButton
@onready var click_sound = $AudioStreamPlayer2D
@onready var green_flower = $GreenFlower
@onready var pink_star = $PinkStar

func _ready() -> void:
	var all_text = [title_label, name1, name2, role1, role2, thanks_label]
	var initial_ys = []
	for node in all_text:
		initial_ys.append(node.position.y)
		node.modulate.a = 0.0
		node.position.y += 30

	var d := 0.6
	var tween = create_tween().set_parallel(false)

	$ColorRect.modulate.a = 0.0
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.3)

	tween.tween_property(title_label, "modulate:a", 1.0, d).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(title_label, "position:y", initial_ys[0], d).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.tween_interval(0.25)
	tween.tween_property(name1, "modulate:a", 1.0, d).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(name1, "position:y", initial_ys[1], d).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.tween_interval(0.25)
	tween.tween_property(name2, "modulate:a", 1.0, d).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(name2, "position:y", initial_ys[2], d).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.tween_interval(0.2)
	tween.tween_property(role1, "modulate:a", 1.0, d * 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(role1, "position:y", initial_ys[3], d * 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.tween_interval(0.15)
	tween.tween_property(role2, "modulate:a", 1.0, d * 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(role2, "position:y", initial_ys[4], d * 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.tween_interval(0.3)
	var thanks_scale = thanks_label.scale
	thanks_label.scale = Vector2(0.3, 0.3)
	tween.tween_property(thanks_label, "modulate:a", 1.0, d * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(thanks_label, "position:y", initial_ys[5], d * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(thanks_label, "scale", thanks_scale, d * 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_interval(0.4)
	tween.tween_callback(func():
		var btn_initial = back_button.scale
		var btn_max = btn_initial * 1.08
		var pulse = create_tween().set_loops()
		pulse.tween_property(back_button, "scale", btn_max, 1.0).set_trans(Tween.TRANS_SINE)
		pulse.tween_property(back_button, "scale", btn_initial, 1.0).set_trans(Tween.TRANS_SINE)
	)

	green_flower.modulate.a = 0.0
	pink_star.modulate.a = 0.0

	animate_rotation(green_flower, 5.0)
	animate_rotation(pink_star, -4.0)

	var deco_tween = create_tween().set_parallel(true)
	deco_tween.tween_interval(1.2)
	deco_tween.tween_property(green_flower, "modulate:a", 1.0, 0.6)
	deco_tween.tween_property(pink_star, "modulate:a", 1.0, 0.6)


func animate_rotation(node: Control, angle: float) -> void:
	var tween = create_tween().set_loops()
	var rad = deg_to_rad(angle)
	tween.tween_property(node, "rotation", rad, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation", -rad, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		_on_back_button_pressed()

func _on_back_button_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")
