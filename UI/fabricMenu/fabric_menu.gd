extends Control

@onready var click_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

const BTN_SCRIPT := preload("res://UI/fabricMenu/fabric_button.gd")

const FABRICS: Array[String] = [
	"res://fabrics/fabric-1.tres",
	"res://fabrics/fabric-2.tres",
	"res://fabrics/fabric-3.tres",
]

var _buttons: Array = []

var is_transitioning := false

func _ready():
	_load_fabrics()

func _load_fabrics() -> void:
	var container := $ButtonsContainer
	var first := true

	for path in FABRICS:
		var fabric_data: FabricData = load(path)
		if not fabric_data is FabricData:
			push_error("FabricMenu: no se pudo cargar la tela: " + path)
			continue

		var btn := TextureButton.new()
		btn.set_script(BTN_SCRIPT)
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.custom_minimum_size = Vector2(300, 300)
		btn.focus_mode = Control.FOCUS_ALL
		container.add_child(btn)
		btn.fabric_data = fabric_data
		btn.selected.connect(_on_button_selected)

		if first:
			btn.grab_focus()
			first = false

	_buttons = container.get_children()


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
	if is_transitioning:
		return

	is_transitioning = true

	click_sound.play()
	Global.set_fabric(fabric_data)
	await click_sound.finished

	if get_tree():
		get_tree().change_scene_to_file("res://gameplay/CuttingScene.tscn")
