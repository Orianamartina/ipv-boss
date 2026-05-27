## Panel de resultado reutilizable para CuttingScene y SewingScene.
## Cada escena lo configura con setup() y lo muestra con show_result().
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


## Configura los textos fijos del panel según la escena que lo usa.
## Llamar en _ready() de la escena padre antes de que termine el juego.
func setup(title: String, continue_text: String, retry_text: String = "Reintentar") -> void:
	title_label.text = title
	continue_button.text = continue_text
	retry_button.text = retry_text


## Muestra el panel con el texto de puntaje ya formateado.
func show_result(score_text: String) -> void:
	score_label.text = score_text
	visible = true
