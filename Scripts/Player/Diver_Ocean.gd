extends CharacterBody2D

@export var speed = 400
@onready var _animated_sprite = $AnimatedSprite2D
@onready var oxygen_cylinder = get_node("/root/Ocean/HUD/CanvasLayer/TextureRect/TextEdit")
var direction_right = true
var oxygen = 100
var oxygen_decrease_timer = Timer.new()

var mensagem_label = null  # Referência ao Label que exibirá a mensagem acima do jogador

func _ready():
	add_child(oxygen_decrease_timer)
	oxygen_decrease_timer.wait_time = 3.0
	oxygen_decrease_timer.one_shot = false
	oxygen_decrease_timer.connect("timeout", Callable(self, "_on_oxygen_decrease"))
	oxygen_decrease_timer.start()

	# Cria um Label para exibir a mensagem acima do jogador
	mensagem_label = Label.new()
	mensagem_label.visible = false
	mensagem_label.add_theme_font_size_override("font_size", 16)  # Ajuste o tamanho da fonte se necessário
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
	# Atualiza o texto do cilindro de oxigênio com base no nível de oxigênio
	oxygen_cylinder.text = str(int(oxygen)) + "%"

func exibir_mensagem(texto):
	mensagem_label.text = texto
	mensagem_label.visible = true
	mensagem_label.modulate = Color(1, 1, 1, 1)  # Resetar a transparência
	mensagem_label.position = Vector2(-80, -50)  # Ajuste a posição acima do jogador
	# Diminuir o tamanho da fonte da mensagem
	mensagem_label.add_theme_font_size_override("font_size", 12)  # Ajuste o tamanho para um valor menor
	# Criar um Tween para fazer a mensagem desaparecer após um tempo
	var tween = get_tree().create_tween()
	tween.tween_property(mensagem_label, "modulate:a", 0, 2.0).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(Callable(self, "_on_mensagem_desaparecer"))


func _on_mensagem_desaparecer():
	mensagem_label.visible = false

func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()

	var new_position = global_position

	new_position.x = clamp(new_position.x, 0, 1920)
	new_position.y = clamp(new_position.y, 0, 1080)

	global_position = new_position
	var is_sprinting = Input.is_action_pressed("Sprint")

	if is_sprinting:
		speed = 600
	else:
		speed = 400

	if Input.is_action_pressed("Right") and Input.is_action_pressed("Up"):
		direction_right = true
		_animated_sprite.flip_h = false
		_animated_sprite.rotation = -PI / 4
		if is_sprinting:
			_animated_sprite.play("Sprint")
		else:
			_animated_sprite.play("Swimming")
	elif Input.is_action_pressed("Right") and Input.is_action_pressed("Down"):
		direction_right = true
		_animated_sprite.flip_h = false
		_animated_sprite.rotation = PI / 4
		if is_sprinting:
			_animated_sprite.play("Sprint")
		else:
			_animated_sprite.play("Swimming")
	elif Input.is_action_pressed("Left") and Input.is_action_pressed("Up"):
		direction_right = false
		_animated_sprite.flip_h = true
		_animated_sprite.rotation = PI / 4
		if is_sprinting:
			_animated_sprite.play("Sprint")
		else:
			_animated_sprite.play("Swimming")
	elif Input.is_action_pressed("Left") and Input.is_action_pressed("Down"):
		direction_right = false
		_animated_sprite.flip_h = true
		_animated_sprite.rotation = -PI / 4
		if is_sprinting:
			_animated_sprite.play("Sprint")
		else:
			_animated_sprite.play("Swimming")
	elif Input.is_action_pressed("Right"):
		direction_right = true
		_animated_sprite.flip_h = false
		_animated_sprite.rotation = 0
		if is_sprinting:
			_animated_sprite.play("Sprint")
		else:
			_animated_sprite.play("Swimming")
	elif Input.is_action_pressed("Left"):
		direction_right = false
		_animated_sprite.flip_h = true
		_animated_sprite.rotation = 0
		if is_sprinting:
			_animated_sprite.play("Sprint")
		else:
			_animated_sprite.play("Swimming")
	elif Input.is_action_pressed("Up"):
		if direction_right:
			_animated_sprite.flip_h = false
			_animated_sprite.rotation = -PI / 2
		else:
			_animated_sprite.flip_h = true
			_animated_sprite.rotation = PI / 2
		if is_sprinting:
			_animated_sprite.play("Sprint")
		else:
			_animated_sprite.play("Swimming")
	elif Input.is_action_pressed("Down"):
		if direction_right:
			_animated_sprite.flip_h = false
			_animated_sprite.rotation = PI / 2
		else:
			_animated_sprite.flip_h = true
			_animated_sprite.rotation = -PI / 2
		if is_sprinting:
			_animated_sprite.play("Sprint")
		else:
			_animated_sprite.play("Swimming")
	else:
		_animated_sprite.rotation = 0
		_animated_sprite.play("Idle")
