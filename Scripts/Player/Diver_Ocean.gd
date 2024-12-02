extends CharacterBody2D

@export var max_speed = 400
@export var acceleration = 200
@export var deceleration = 300
@export var sprint_multiplier = 1.5

@onready var _animated_sprite = $AnimatedSprite2D
@onready var oxygen_cylinder = get_node("/root/Ocean/HUD/CanvasLayer/TextureRect/TextEdit")

var current_speed = 0
var velocity_direction = Vector2.ZERO
var oxygen = 100
var oxygen_decrease_timer = Timer.new()
var mensagem_label = null

func _ready():
	add_child(oxygen_decrease_timer)
	oxygen_decrease_timer.wait_time = 3.0
	oxygen_decrease_timer.one_shot = false
	oxygen_decrease_timer.connect("timeout", Callable(self, "_on_oxygen_decrease"))
	oxygen_decrease_timer.start()

	mensagem_label = Label.new()
	mensagem_label.visible = false
	mensagem_label.add_theme_font_size_override("font_size", 16)
	add_child(mensagem_label)

func _on_oxygen_decrease():
	oxygen -= 10
	if oxygen < 0:
		oxygen = 0
	update_oxygen_cylinder()
	
	if oxygen <= 0:
		print("Você morre afogado!")
		oxygen_decrease_timer.stop()

func update_oxygen_cylinder():
	oxygen_cylinder.text = str(int(oxygen)) + "%"

func exibir_mensagem(texto):
	mensagem_label.text = texto
	mensagem_label.visible = true
	mensagem_label.modulate = Color(1, 1, 1, 1)
	mensagem_label.position = Vector2(-80, -50)
	mensagem_label.add_theme_font_size_override("font_size", 12)
	var tween = get_tree().create_tween()
	tween.tween_property(mensagem_label, "modulate:a", 0, 2.0).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(Callable(self, "_on_mensagem_desaparecer"))

func _on_mensagem_desaparecer():
	mensagem_label.visible = false

func _physics_process(delta):
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	
	# Ajuste da velocidade com aceleração e desaceleração
	if input_direction != Vector2.ZERO:
		velocity_direction = input_direction.normalized()
		current_speed = min(current_speed + acceleration * delta, max_speed)
	else:
		current_speed = max(current_speed - deceleration * delta, 0)
	
	# Sprint
	if Input.is_action_pressed("Sprint"):
		current_speed = min(current_speed + acceleration * delta, max_speed * sprint_multiplier)

	# Atualiza a velocidade e aplica movimento
	velocity = velocity_direction * current_speed
	move_and_slide()

	# Limites do movimento no mundo
	global_position.x = clamp(global_position.x, 0, 1920)
	global_position.y = clamp(global_position.y, 0, 1080)

	# Animações
	update_animation(input_direction)

func update_animation(input_direction):
	var is_moving = input_direction != Vector2.ZERO
	var is_sprinting = Input.is_action_pressed("Sprint")
	
	if is_moving:
		# Define a rotação e orientação horizontal da sprite
		if input_direction.x > 0 and input_direction.y < 0:
			_animated_sprite.rotation = -PI / 4  # Direita para cima
			_animated_sprite.flip_h = false
		elif input_direction.x > 0 and input_direction.y > 0:
			_animated_sprite.rotation = PI / 4  # Direita para baixo
			_animated_sprite.flip_h = false
		elif input_direction.x < 0 and input_direction.y < 0:
			_animated_sprite.rotation = PI / 4  # Esquerda para cima
			_animated_sprite.flip_h = true
		elif input_direction.x < 0 and input_direction.y > 0:
			_animated_sprite.rotation = -PI / 4  # Esquerda para baixo
			_animated_sprite.flip_h = true
		elif input_direction.x > 0:
			_animated_sprite.rotation = 0  # Direita
			_animated_sprite.flip_h = false
		elif input_direction.x < 0:
			_animated_sprite.rotation = 0  # Esquerda
			_animated_sprite.flip_h = true
		elif input_direction.y < 0:
			# Para cima, ajustando a rotação conforme a direção horizontal
			if _animated_sprite.flip_h:
				_animated_sprite.rotation = PI / 2  # Para cima (esquerda)
			else:
				_animated_sprite.rotation = -PI / 2  # Para cima (direita)
		elif input_direction.y > 0:
			# Para baixo, ajustando a rotação conforme a direção horizontal
			if _animated_sprite.flip_h:
				_animated_sprite.rotation = -PI / 2  # Para baixo (esquerda)
			else:
				_animated_sprite.rotation = PI / 2  # Para baixo (direita)

		# Escolhe a animação correta
		if is_sprinting:
			_animated_sprite.play("Sprint")
		else:
			_animated_sprite.play("Swimming")
	else:
		# Reseta a rotação e animação para o estado idle
		_animated_sprite.rotation = 0
		_animated_sprite.play("Idle")
