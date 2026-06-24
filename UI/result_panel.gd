class_name ResultPanel
extends CanvasLayer

signal continue_pressed
signal retry_pressed

@onready var title_label: Label = $TitleLabel
@onready var score_label: Label = $ScoreLabel
@onready var continue_button: Button = $ContinueButton
@onready var retry_button: Button = $RetryButton
@onready var click_sound: AudioStreamPlayer2D = $ClickSound
@onready var music_btn: TextureButton = $SoundMenu/TextureButton
@onready var fx_btn: TextureButton = $SoundMenu/TextureButton2


func _ready() -> void:
	continue_button.pressed.connect(
		func():
			click_sound.play()
			await click_sound.finished
			continue_pressed.emit()
	)
	retry_button.pressed.connect(
		func():
			click_sound.play()
			await click_sound.finished
			retry_pressed.emit()
	)
	continue_button.focus_mode = Control.FOCUS_ALL
	retry_button.focus_mode = Control.FOCUS_ALL


func _process(_delta: float) -> void:
	if not visible:
		return

	var cont_f := continue_button.has_focus()
	var retry_f := retry_button.has_focus()
	var music_f := music_btn.has_focus()
	var fx_f    := fx_btn.has_focus()

	# Left/Right: navega dentro de la fila
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		if cont_f:
			retry_button.grab_focus()
		elif retry_f:
			continue_button.grab_focus()
		elif music_f:
			fx_btn.grab_focus()
		elif fx_f:
			music_btn.grab_focus()

	# Up/Down: navega entre filas manteniendo la columna
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down"):
		if cont_f:
			music_btn.grab_focus()
		elif retry_f:
			fx_btn.grab_focus()
		elif music_f:
			continue_button.grab_focus()
		elif fx_f:
			retry_button.grab_focus()

	# Enter: activa el botón con focus
	if Input.is_action_just_pressed("enter"):
		if cont_f:
			continue_pressed.emit()
		elif retry_f:
			retry_pressed.emit()
		elif music_f:
			music_btn.pressed.emit()
		elif fx_f:
			fx_btn.pressed.emit()


func setup(title: String, continue_text: String, retry_text: String = "Reintentar") -> void:
	title_label.text = title
	continue_button.text = continue_text
	retry_button.text = retry_text


func show_result(score_text: String) -> void:
	score_label.text = score_text
	visible = true
	continue_button.grab_focus()
