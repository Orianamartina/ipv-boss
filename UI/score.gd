extends CanvasLayer

@onready var score_label: Label = $HBoxContainer/ScoreLabel

var max_score: int = 5000
var last_milestone: int = 0
var score_tween: Tween


func setup(p_max_score: int) -> void:
	max_score = p_max_score
	last_milestone = 0
	score_label.scale = Vector2.ONE
	score_label.modulate = Color.WHITE
	score_label.text = "0 / %d" % max_score


func update_score(current: float, color: Color = Color.WHITE) -> void:
	score_label.modulate = color
	score_label.text = "%d / %d" % [int(current), max_score]

	var milestone := int(current) / 1000
	if milestone > last_milestone:
		last_milestone = milestone
		if score_tween:
			score_tween.kill()
		score_label.pivot_offset = score_label.size / 2.0
		score_tween = create_tween()
		score_tween.tween_property(score_label, "scale", Vector2(1.6, 1.6), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		score_tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
