class_name ResultPanel
extends CanvasLayer

signal continue_pressed
signal retry_pressed

@onready var title_label: Label = $TitleLabel
@onready var score_label: Label = $ScoreLabel
@onready var continue_button: Button = $ContinueButton
@onready var retry_button: Button = $RetryButton


func _ready() -> void:
	continue_button.pressed.connect(func(): continue_pressed.emit())
	retry_button.pressed.connect(func(): retry_pressed.emit())
	continue_button.focus_mode = Control.FOCUS_ALL
	retry_button.focus_mode = Control.FOCUS_ALL


func _process(_delta: float) -> void:
	if not visible:
		return

	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		if continue_button.has_focus():
			retry_button.grab_focus()
		else:
			continue_button.grab_focus()

	if Input.is_action_just_pressed("enter"):
		if continue_button.has_focus():
			continue_pressed.emit()
		elif retry_button.has_focus():
			retry_pressed.emit()


func setup(title: String, continue_text: String, retry_text: String = "Reintentar") -> void:
	title_label.text = title
	continue_button.text = continue_text
	retry_button.text = retry_text


func show_result(score_text: String) -> void:
	score_label.text = score_text
	visible = true
	continue_button.grab_focus()
