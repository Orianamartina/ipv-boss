extends Node

@onready var mainMenu = $MainMenu
@onready var nameMenu = $NameMenu
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mainMenu.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
