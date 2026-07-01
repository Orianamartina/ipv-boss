@tool
extends CanvasLayer

@export var image_a: Texture2D:
	set(value):
		image_a = value
		var rect := get_node_or_null("Image")
		if rect:
			rect.texture = value
			
@export var image_b: Texture2D
@export var steps : Texture2D
@export var interval: float = 0.6
@export var title: String

@onready var texture_rect: TextureRect = $Image
@onready var steps_image: TextureRect = $Steps
@onready var timer: Timer = $Timer
@onready var title_label = $Title
@onready var skip_button: Button = $SkipButton
var showing_a := true


func _ready() -> void:
	texture_rect.texture = image_a
	steps_image.texture = steps
	title_label.text = title
	if Engine.is_editor_hint():
		return
	skip_button.grab_focus()
	timer.wait_time = interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

	var hide_timer := get_tree().create_timer(10.0)
	hide_timer.timeout.connect(_fade_out)


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)


func _on_timer_timeout() -> void:
	if image_b == null:
		return
	showing_a = !showing_a
	var tex := image_a if showing_a else image_b
	texture_rect.texture = tex

func _on_skip_button_pressed() -> void:
	_fade_out()
