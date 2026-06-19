extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cutting_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()
	
func initialize() -> void:
	animation_player.stop()
	cutting_audio.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Verificamos si el botón de corte está siendo presionado
	if Input.is_action_pressed("cut"):
		# Solo iniciamos la animación si no se está reproduciendo actualmente
		if not animation_player.is_playing():
			animation_player.play("opened")
		if not cutting_audio.playing:
			cutting_audio.play()
	else:
		# Si se suelta el botón, detenemos la animación
		if animation_player.is_playing():
			animation_player.stop()
		if cutting_audio.playing:
			cutting_audio.stop()
