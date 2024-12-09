extends CharacterBody2D

@export var speed: float = 100
@export var screen_size: Vector2 = Vector2(1920, 1080)
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var direction_timer = Timer.new()

var direction = Vector2.ZERO
var next_animation: String = "Swimming"
var is_transforming: bool = false

func _ready():
	collision_shape.disabled = true
	animated_sprite.play("Swimming")
	_change_direction()

	# Conecta os sinais globais
	GlobalSignals.connect("background_changed_to_modified", Callable(self, "_on_background_changed_to_modified"))
	GlobalSignals.connect("background_changed_to_original", Callable(self, "_on_background_changed_to_original"))

	# Configura o timer para mudar de direção
	add_child(direction_timer)
	direction_timer.wait_time = 1.5
	direction_timer.one_shot = false
	direction_timer.timeout.connect(Callable(self, "_change_direction"))
	direction_timer.start()

func _physics_process(delta: float) -> void:
	if is_transforming:
		return  # Não movimenta enquanto estiver transformando

	# Comportamento depende da animação atual
	if animated_sprite.animation == "Bad_Fish" and GlobalSignals.player:
		speed = 125  # Corrige a atribuição
		collision_shape.disabled = false  # Ativa a colisão
		direction = (GlobalSignals.player.global_position - global_position).normalized()
	else:
		speed = 100  # Retorna a velocidade padrão
		collision_shape.disabled = true  # Desativa a colisão
		if direction == Vector2.ZERO:
			_change_direction()  # Evita que fique parado

	# Aplica o movimento
	velocity = direction * speed
	move_and_slide()

	# Detecta colisões e inverte a direção
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			direction = -direction

	# Mantém o peixe dentro da tela
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)

	# Atualiza o flip com base na direção
	animated_sprite.flip_h = direction.x < 0

func _change_direction() -> void:
	# Define uma nova direção aleatória
	var angle = randf() * PI * 2
	direction = Vector2(cos(angle), sin(angle)).normalized()

func play_transform_animation() -> void:
	# Troca a animação com transição
	is_transforming = true
	speed = 0
	collision_shape.disabled = true  # Desativa a colisão durante a transformação
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
	# Finaliza a transformação
	animated_sprite.disconnect("animation_finished", Callable(self, "_on_transform_finished"))
	is_transforming = false
	animated_sprite.play(next_animation)
