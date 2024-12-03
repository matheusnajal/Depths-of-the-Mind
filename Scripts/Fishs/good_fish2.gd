extends CharacterBody2D

@export var speed: float = 100
@export var screen_size: Vector2 = Vector2(1920, 1080)

@onready var animated_sprite = $AnimatedSprite2D
@onready var direction_timer = Timer.new()
var direction = Vector2.ZERO
var next_animation: String = "Swimming"

func _ready():
	animated_sprite.play("Swimming")
	GlobalSignals.connect("background_changed_to_modified", Callable(self, "_on_background_changed_to_modified"))
	GlobalSignals.connect("background_changed_to_original", Callable(self, "_on_background_changed_to_original"))
	
	add_child(direction_timer)
	direction_timer.wait_time = 1.5
	direction_timer.one_shot = false
	direction_timer.start()
	direction_timer.timeout.connect(Callable(self, "_on_change_direction"))

func _physics_process(delta: float) -> void:
	velocity = direction * speed
	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			direction = -direction

	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)

	animated_sprite.flip_h = direction.x < 0

func _on_change_direction() -> void:
	var angle = randf() * PI * 2
	direction = Vector2(cos(angle), sin(angle)).normalized()

func play_transform_animation() -> void:
	animated_sprite.play("Transform")
	animated_sprite.connect("animation_finished", Callable(self, "_on_transform_finished"))

func _on_background_changed_to_modified() -> void:
	print("Sinal de fundo modificado recebido!")
	next_animation = "Bad_Fish"
	play_transform_animation()

func _on_background_changed_to_original() -> void:
	print("Sinal de fundo original recebido!")
	next_animation = "Swimming"
	play_transform_animation()

func _on_transform_finished() -> void:
	animated_sprite.disconnect("animation_finished", Callable(self, "_on_transform_finished"))
	animated_sprite.play(next_animation)
