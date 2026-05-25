extends Control

@onready var score_label = $ScoreLabel
@onready var detail_label = $DetailLabel


func _ready() -> void:
	score_label.text = "Puntaje total: %d" % Global.score
