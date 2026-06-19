extends Control

@onready var greetingLabel = $Greeting
@onready var titleSprite: Sprite2D = $Sprite2D

func _ready() -> void:
	Global.player_name_changed.connect(_on_player_name_changed)
	var vp := get_viewport_rect().size
	titleSprite.position = vp / 2.0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		_on_start_button_pressed()

func _on_player_name_changed(new_name: String) -> void:
	greetingLabel.text = "Hola, " + new_name + "!"
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/PatternMenu.tscn")
