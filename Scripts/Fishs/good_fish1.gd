extends CharacterBody2D

@export var speed: float = 100  # Velocidade do mob
@export var screen_size: Vector2 = Vector2(1920, 1080)  # Resolução da tela

@onready var animated_sprite = $AnimatedSprite2D
@onready var direction_timer = Timer.new()  # Timer para mudar a direção
var direction = Vector2.ZERO  # Direção de movimento

func _ready():
	# Inicia a animação
	animated_sprite.play("Swimming")
	
	# Configura o timer para mudar a direção
	add_child(direction_timer)
	direction_timer.wait_time = 1.5  # Tempo para mudar de direção
	direction_timer.one_shot = false
	direction_timer.start()
	direction_timer.timeout.connect(_on_change_direction)

func _physics_process(delta):
	# Aplica a movimentação com a direção e velocidade
	velocity = direction * speed
	move_and_slide()

	# Verifica colisões
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			# Inverte a direção ao colidir
			direction = -direction

	# Mantém o mob dentro dos limites da tela
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)

	# Ajusta apenas o flip horizontal
	animated_sprite.flip_h = direction.x < 0

func _on_change_direction():
	# Define uma nova direção aleatória
	var angle = randf() * PI * 2  # Ângulo aleatório em radianos
	direction = Vector2(cos(angle), sin(angle)).normalized()  # Vetor de direção normalizado
