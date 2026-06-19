extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()
	
func initialize() -> void:
	animation_player.stop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Verificamos si el botón de corte está siendo presionado
	if Input.is_action_pressed("cut"):
		# Solo iniciamos la animación si no se está reproduciendo actualmente
		if not animation_player.is_playing():
			animation_player.play("opened")
	else:
		# Si se suelta el botón, detenemos la animación
		animation_player.stop()
