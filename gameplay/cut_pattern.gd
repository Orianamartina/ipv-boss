extends Node2D

@onready var path: Path2D = $PatternPath
@onready var line: Line2D = $PatternLine


func _ready() -> void:
	# Cargar la curva desde la escena de shape del patrón seleccionado.
	# La escena debe tener un Path2D como nodo raíz.
	if Global.current_pattern != null and Global.current_pattern.path_scene != null:
		var shape_node = Global.current_pattern.path_scene.instantiate()
		if shape_node is Path2D:
			path.curve = shape_node.curve
		shape_node.queue_free()  # ya copiamos la curva, liberamos el nodo temporal

	line.points = path.curve.get_baked_points()
