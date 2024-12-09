extends Camera2D

@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0
@export var min_time: float = 5.00
@export var max_time: float = 10.00
@export var shake_duration: float = 5.00
@export var max_shake_strength: float = 10.0

@export var original_texture_path: String = "res://Sprites/Background/Good_ocean.png"
@export var modified_texture_path: String = "res://Sprites/Background/Bad_ocean.png"
@export var original_color: Color = Color("#3e79dd")  # Cor original do ColorRect
@export var modified_color: Color = Color("#6C1414")  # Cor modificada do ColorRect

@onready var color_rect_with_shader = $Glitch
@onready var sprite_to_change = get_node("/root/Ocean/Sprite2D")  # Caminho absoluto para o Sprite2D

var rng = RandomNumberGenerator.new()

var shake_Strength: float = 0.0
var is_shaking: bool = false

func _ready() -> void:
	if color_rect_with_shader:
		color_rect_with_shader.hide()
	start_random_shake_timer()

func start_random_shake_timer():
	var random_time = rng.randf_range(min_time, max_time)
	
	# Configura um Timer para o shake inicial
	var shake_timer = Timer.new()
	shake_timer.wait_time = random_time
	shake_timer.one_shot = true
	shake_timer.timeout.connect(_on_shake_to_modified)
	add_child(shake_timer)
	shake_timer.start()

# Shake inicial para trocar para a nova sprite e cor
func _on_shake_to_modified():
	apply_shake(randomStrength)
	var shake_timer = Timer.new()
	shake_timer.wait_time = shake_duration
	shake_timer.one_shot = true
	shake_timer.timeout.connect(_on_shake_end_to_modified)
	add_child(shake_timer)
	shake_timer.start()

# Finaliza o shake e troca para a nova sprite e cor
func _on_shake_end_to_modified():
	is_shaking = false
	deactivate_shader()

	# Troca para a nova sprite e cor
	if sprite_to_change:
		var new_texture = load(modified_texture_path) as Texture2D
		if new_texture:
			sprite_to_change.texture = new_texture

		var color_rect = sprite_to_change.get_node("ColorRect")
		if color_rect and color_rect is ColorRect:
			color_rect.color = modified_color

	# Espera 15 segundos antes de voltar ao estado original
	var wait_timer = Timer.new()
	wait_timer.wait_time = 15.0
	wait_timer.one_shot = true
	wait_timer.timeout.connect(_on_wait_to_original_shake)
	add_child(wait_timer)
	wait_timer.start()

# Após 15 segundos, inicia o shake para voltar ao original
func _on_wait_to_original_shake():
	apply_shake(randomStrength)
	var shake_timer = Timer.new()
	shake_timer.wait_time = shake_duration
	shake_timer.one_shot = true
	shake_timer.timeout.connect(_on_shake_end_to_original)
	add_child(shake_timer)
	shake_timer.start()

# Finaliza o shake e troca de volta para a sprite original
func _on_shake_end_to_original():
	is_shaking = false
	deactivate_shader()

	# Restaura a sprite e cor originais
	if sprite_to_change:
		var original_texture = load(original_texture_path) as Texture2D
		if original_texture:
			sprite_to_change.texture = original_texture

		var color_rect = sprite_to_change.get_node("ColorRect")
		if color_rect and color_rect is ColorRect:
			color_rect.color = original_color

	# Reinicia o ciclo de shake
	start_random_shake_timer()

func apply_shake(intensity: float):
	shake_Strength = clamp(intensity, 0, max_shake_strength)
	is_shaking = true
	activate_shader()

func _process(delta: float) -> void:
	if is_shaking:
		offset = randomOffset()
	elif shake_Strength > 0:
		shake_Strength = lerpf(shake_Strength, 0, shakeFade * delta)
		offset = randomOffset()

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_Strength, shake_Strength), rng.randf_range(-shake_Strength, shake_Strength))

func activate_shader() -> void:
	if color_rect_with_shader:
		color_rect_with_shader.show()

func deactivate_shader() -> void:
	if color_rect_with_shader:
		color_rect_with_shader.hide()
