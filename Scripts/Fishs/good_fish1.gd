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

	# Mantém o mob dentro dos limites da tela
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	# Rotaciona a sprite na direção do movimento, com correção para a esquerda
	var angle_degrees = direction.angle() * 180 / PI
	if direction.x < 0:
		animated_sprite.flip_h = true
		animated_sprite.rotation_degrees = angle_degrees + 180  # Inverte o ângulo para a esquerda
	else:
		animated_sprite.flip_h = false
		animated_sprite.rotation_degrees = angle_degrees

func _on_change_direction():
	# Define uma nova direção aleatória
	var angle = randf() * PI * 2  # Ângulo aleatório em radianos
	direction = Vector2(cos(angle), sin(angle)).normalized()  # Vetor de direção normalizado
