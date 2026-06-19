extends TextureButton

signal selected(fabric_data: FabricData)

var grayscale_shader = preload("res://UI/fabricMenu/grayscale.gdshader")

@export var fabric_data: FabricData:
	set(value):
		fabric_data = value
		if value and value.texture:
			texture_normal = value.texture
			texture_focused = null

func _ready() -> void:
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
	
	material = ShaderMaterial.new()
	material.shader = grayscale_shader
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	_on_focus_exited()

func _on_focus_entered() -> void:
	if material and material is ShaderMaterial:
		material.set_shader_parameter("grayscale_amount", 0.0)
	modulate = Color(1.25, 1.25, 1.25)

func _on_focus_exited() -> void:
	# Pierde el foco = Se pone gris (1.0) y vuelve a su brillo base
	if material and material is ShaderMaterial:
		material.set_shader_parameter("grayscale_amount", 1.0)
	modulate = Color(1.0, 1.0, 1.0)

func _pressed() -> void:
	selected.emit(fabric_data)

func _process(_delta: float) -> void:
	if has_focus() and Input.is_action_just_pressed("enter"):
		_pressed()
