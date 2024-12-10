extends Camera2D

@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0
@export var min_time: float = 20.00
@export var max_time: float = 30.00
@export var shake_duration: float = 5.00
@export var max_shake_strength: float = 10.0

@export var original_texture_path: String = "res://Sprites/Background/Good_ocean.png"
@export var modified_texture_path: String = "res://Sprites/Background/Bad_ocean.png"
@export var original_color: Color = Color("#3e79dd")
@export var modified_color: Color = Color("#6C1414")

@onready var color_rect_with_shader = $Glitch
@onready var sprite_to_change = get_node("/root/Ocean/Sprite2D")

var rng = RandomNumberGenerator.new()

var shake_Strength: float = 0.0
var is_shaking: bool = false

func _ready() -> void:
	if color_rect_with_shader:
		color_rect_with_shader.hide()
	start_random_shake_timer()

func start_random_shake_timer() -> void:
	var random_time = rng.randf_range(min_time, max_time)
	
	var shake_timer = Timer.new()
	shake_timer.wait_time = random_time
	shake_timer.one_shot = true
	shake_timer.timeout.connect(Callable(self, "_on_shake_to_modified"))
	add_child(shake_timer)
	shake_timer.start()

func _on_shake_to_modified() -> void:
	apply_shake(randomStrength)
	var shake_timer = Timer.new()
	shake_timer.wait_time = shake_duration
	shake_timer.one_shot = true
	shake_timer.timeout.connect(Callable(self, "_on_shake_end_to_modified"))
	add_child(shake_timer)
	shake_timer.start()

func _on_shake_end_to_modified() -> void:
	is_shaking = false
	deactivate_shader()

	if sprite_to_change:
		var new_texture = load(modified_texture_path) as Texture2D
		if new_texture:
			sprite_to_change.texture = new_texture

		var color_rect = sprite_to_change.get_node("ColorRect")
		if color_rect and color_rect is ColorRect:
			color_rect.color = modified_color
		GlobalSignals.emit_signal("background_changed_to_modified")

	var wait_timer = Timer.new()
	wait_timer.wait_time = 15.0
	wait_timer.one_shot = true
	wait_timer.timeout.connect(Callable(self, "_on_wait_to_original_shake"))
	add_child(wait_timer)
	wait_timer.start()

func _on_wait_to_original_shake() -> void:
	apply_shake(randomStrength)
	var shake_timer = Timer.new()
	shake_timer.wait_time = shake_duration
	shake_timer.one_shot = true
	shake_timer.timeout.connect(Callable(self, "_on_shake_end_to_original"))
	add_child(shake_timer)
	shake_timer.start()

func _on_shake_end_to_original() -> void:
	is_shaking = false
	deactivate_shader()

	if sprite_to_change:
		var original_texture = load(original_texture_path) as Texture2D
		if original_texture:
			sprite_to_change.texture = original_texture

		var color_rect = sprite_to_change.get_node("ColorRect")
		if color_rect and color_rect is ColorRect:
			color_rect.color = original_color

		GlobalSignals.emit_signal("background_changed_to_original")

	start_random_shake_timer()

func apply_shake(intensity: float) -> void:
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

# Nova função para resetar timers e restaurar o cenário
func reset_shake_timers():
	# Para todos os timers filhos do nó, removendo-os
	for child in get_children():
		if child is Timer:
			child.queue_free()

	# Garante que não está tremendo
	is_shaking = false
	shake_Strength = 0.0
	deactivate_shader()

	# Volta o oceano para a versão boa (caso já não esteja)
	if sprite_to_change:
		var original_texture = load(original_texture_path) as Texture2D
		if original_texture:
			sprite_to_change.texture = original_texture

		var color_rect = sprite_to_change.get_node("ColorRect")
		if color_rect and color_rect is ColorRect:
			color_rect.color = original_color

	# Não chama start_random_shake_timer aqui, pois queremos que comece "zerado"
	# Deixe para iniciar novamente se necessário, mais tarde.
