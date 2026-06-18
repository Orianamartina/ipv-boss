extends Control

var _buttons: Array = []

func _ready():
	for child in get_children():
		if child is TextureButton:
			_buttons.append(child)
			child.selected.connect(_on_button_selected)
			child.focus_mode = Control.FOCUS_ALL

	if _buttons.size() > 0:
		_buttons[0].grab_focus()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_left"):
		_move_focus(-1)
	elif Input.is_action_just_pressed("move_right"):
		_move_focus(1)


func _move_focus(direction: int) -> void:
	for i in _buttons.size():
		if _buttons[i].has_focus():
			var next := clampi(i + direction, 0, _buttons.size() - 1)
			_buttons[next].grab_focus()
			return


func _on_button_selected(fabric_data: FabricData) -> void:
	Global.set_fabric(fabric_data)
	get_tree().change_scene_to_file("res://gameplay/CuttingScene.tscn")
