extends Camera2D

@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0
@export var min_time: float = 15.00
@export var max_time: float = 45.00
@export var shake_duration: float = 5.00
@export var max_shake_strength: float = 10.0

@onready var color_rect_with_shader = $Glitch

var rng = RandomNumberGenerator.new()

var shake_Strength: float = 0.0
var has_shaken: bool = false
var is_shaking: bool = false

func _ready() -> void:
	if color_rect_with_shader:
		color_rect_with_shader.hide()
	start_random_shake_timer()

func start_random_shake_timer():
	var random_time = rng.randf_range(min_time, max_time)
	
	# Configura um Timer para o shake
	var shake_timer = Timer.new()
	shake_timer.wait_time = random_time
	shake_timer.one_shot = true
	shake_timer.connect("timeout", Callable(self, "_on_shake_timeout"))
	add_child(shake_timer)
	shake_timer.start()

func _on_shake_timeout():
	if not has_shaken:
		apply_shake(randomStrength)
		has_shaken = true
		
		var duration_timer = Timer.new()
		duration_timer.wait_time = shake_duration
		duration_timer.one_shot = true
		duration_timer.connect("timeout", Callable(self, "_on_shake_end"))
		add_child(duration_timer)
		duration_timer.start()

func apply_shake(intensity: float):
	shake_Strength = clamp(intensity, 0, max_shake_strength)
	is_shaking = true
	activate_shader()

func adjust_shake_intensity(new_intensity: float):
	shake_Strength = clamp(new_intensity, 0, max_shake_strength)

func _on_shake_end():
	is_shaking = false
	deactivate_shader()
	
	
	get_tree().change_scene_to_file("res://Scenes/World/bad_ocean.tscn")

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
