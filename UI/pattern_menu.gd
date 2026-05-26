extends Control

var patterns: Array = []
var current_index: int = 0
var last_axis_value: float = 0.0

func _ready() -> void:
	# Obtener todos los PatternPreview children
	patterns = get_children().filter(func(child): return child is Node2D and child.has_method("set_selected"))
	
	if patterns.is_empty():
		push_error("No patterns found in PatternMenu")
		return
	
	# Seleccionar el primer patrón
	patterns[current_index].set_selected(true)
	
	var first_button = true
	for child in get_children():
		if child is TextureButton:
			child.selected.connect(_on_button_selected)
			child.focus_mode = Control.FOCUS_ALL
			
			if first_button:
				child.grab_focus()
				first_button = false

func _process(_delta: float) -> void:
	var axis_value = Input.get_axis("ui_left", "ui_right")
	
	# Solo cambiar si hay un cambio significativo en el eje
	if axis_value != 0.0 and last_axis_value == 0.0:
		if axis_value < 0:
			_select_previous()
		else:
			_select_next()
	
	last_axis_value = axis_value
	
func _on_button_selected(fabric):
	Global.set_pattern(fabric)
	get_tree().change_scene_to_file("res://gameplay/FabricMenu.tscn")

func _select_next() -> void:
	patterns[current_index].set_selected(false)
	current_index = (current_index + 1) % patterns.size()
	patterns[current_index].set_selected(true)

func _select_previous() -> void:
	patterns[current_index].set_selected(false)
	current_index = (current_index - 1) % patterns.size()
	patterns[current_index].set_selected(true)
