extends HBoxContainer

const MUSIC_ON  := preload("res://Assets/UI/sound-menu/music-on.png")
const MUSIC_OFF := preload("res://Assets/UI/sound-menu/music-off.png")
const FX_ON     := preload("res://Assets/UI/sound-menu/fx-on.png")
const FX_OFF    := preload("res://Assets/UI/sound-menu/fx-off.png")

const FOCUSED_MODULATE   := Color(1.6, 1.6, 1.6)
const UNFOCUSED_MODULATE := Color(1.0, 1.0, 1.0)

@onready var music_btn: TextureButton = $TextureButton
@onready var fx_btn:    TextureButton = $TextureButton2

var music_on: bool = true
var fx_on:    bool = true


func _ready() -> void:
	music_btn.focus_mode = Control.FOCUS_ALL
	fx_btn.focus_mode = Control.FOCUS_ALL
	music_btn.pressed.connect(_on_music_pressed)
	fx_btn.pressed.connect(_on_fx_pressed)
	music_btn.focus_entered.connect(func(): music_btn.modulate = FOCUSED_MODULATE)
	music_btn.focus_exited.connect(func(): music_btn.modulate = UNFOCUSED_MODULATE)
	fx_btn.focus_entered.connect(func(): fx_btn.modulate = FOCUSED_MODULATE)
	fx_btn.focus_exited.connect(func(): fx_btn.modulate = UNFOCUSED_MODULATE)
	# Sincroniza las texturas con el estado real del AudioServer
	music_on = not AudioServer.is_bus_mute(AudioServer.get_bus_index("Music"))
	fx_on    = not AudioServer.is_bus_mute(AudioServer.get_bus_index("FX"))
	music_btn.texture_normal = MUSIC_ON if music_on else MUSIC_OFF
	fx_btn.texture_normal    = FX_ON    if fx_on    else FX_OFF


func _on_music_pressed() -> void:
	music_on = !music_on
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), !music_on)
	music_btn.texture_normal = MUSIC_ON if music_on else MUSIC_OFF


func _on_fx_pressed() -> void:
	fx_on = !fx_on
	AudioServer.set_bus_mute(AudioServer.get_bus_index("FX"), !fx_on)
	fx_btn.texture_normal = FX_ON if fx_on else FX_OFF
