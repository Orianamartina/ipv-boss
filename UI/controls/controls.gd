@tool
extends Control

@export var image_a: Texture2D:
	set(value):
		image_a = value
		var rect := get_node_or_null("Image")
		if rect:
			rect.texture = value

@export var image_b: Texture2D
@export var interval: float = 0.6

@onready var texture_rect: TextureRect = $Image
@onready var timer: Timer = $Timer

var showing_a := true


func _ready() -> void:
	texture_rect.texture = image_a
	if Engine.is_editor_hint():
		return
	timer.wait_time = interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()


func _on_timer_timeout() -> void:
	if image_b == null:
		print("Controls: image_b is null, skipping")
		return
	showing_a = !showing_a
	var tex := image_a if showing_a else image_b
	print("Controls: showing ", "A" if showing_a else "B", " — ", tex.resource_path if tex else "null")
	texture_rect.texture = tex
