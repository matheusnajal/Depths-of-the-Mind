extends CharacterBody2D

@export var max_speed = 200
@export var acceleration = 250
@export var deceleration = 1000
@export var hit_deceleration = 300
@export var sprint_multiplier = 1.5
@onready var transition_rect = $"../../HUD/CanvasLayer/FadeColorReact"
@onready var hit_sound = $AudioStreamPlayer2D

@export var max_health = 3
var current_health = max_health

@onready var _animated_sprite = $AnimatedSprite2D
@onready var oxygen_cylinder = get_node("/root/Ocean/HUD/CanvasLayer/OxigenioBar/TextEdit")
@onready var heart_container = get_node("/root/Ocean/HUD/HeartContainer")

var current_speed = 0
var velocity_direction = Vector2.ZERO
var oxygen = 99

var is_invincible = false
var is_hit_animation_playing = false

@onready var oxygen_decrease_timer = Timer.new()  
@onready var invincibility_timer = Timer.new()

var mensagem_label = null

func _ready():
	GlobalSignals.player = self

	# Configura o timer de oxigênio
	add_child(oxygen_decrease_timer)
	oxygen_decrease_timer.one_shot = false
	update_oxygen_rate(1)
	oxygen_decrease_timer.connect("timeout", Callable(self, "_on_oxygen_decrease"))
	oxygen_decrease_timer.start()

	# Configura o timer de invencibilidade
	add_child(invincibility_timer)
	invincibility_timer.wait_time = 3.0
	invincibility_timer.one_shot = true
	invincibility_timer.connect("timeout", Callable(self, "_end_invincibility"))

	mensagem_label = Label.new()
	mensagem_label.visible = false
	mensagem_label.add_theme_font_size_override("font_size", 16)
	add_child(mensagem_label)

	update_health_display()

func update_oxygen_rate(level):
	var tempo = 1.0
	if level >= 3 and level < 5:
		tempo = 2.0
	elif level >= 5:
		tempo = 3.0
	
	oxygen_decrease_timer.wait_time = tempo

func _on_oxygen_decrease():
	oxygen -= 1
	update_oxygen_cylinder()
	
	if oxygen <= 0:
		oxygen = 0
		oxygen_decrease_timer.stop()
		# Chama a tela de game over via o oceano
		var ocean = get_node("/root/Ocean")
		await ocean.game_over()

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
	if is_hit_animation_playing:
		current_speed = max(current_speed - hit_deceleration * delta, 0)
		velocity = velocity_direction * current_speed
		move_and_slide()
		return

	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	
	if input_direction != Vector2.ZERO:
		velocity_direction = input_direction.normalized()
		current_speed = min(current_speed + acceleration * delta, max_speed)
	else:
		current_speed = max(current_speed - deceleration * delta, 0)
	
	if Input.is_action_pressed("Sprint"):
		current_speed = min(current_speed + acceleration * delta, max_speed * sprint_multiplier)

	velocity = velocity_direction * current_speed
	move_and_slide()

	global_position.x = clamp(global_position.x, 0, 1920)
	global_position.y = clamp(global_position.y, 0, 1080)

	update_animation(input_direction)

func update_animation(input_direction):
	var is_moving = input_direction != Vector2.ZERO
	var is_sprinting = Input.is_action_pressed("Sprint")
	
	if is_moving:
		if input_direction.x > 0 and input_direction.y < 0:
			_animated_sprite.rotation = -PI / 4
			_animated_sprite.flip_h = false
		elif input_direction.x > 0 and input_direction.y > 0:
			_animated_sprite.rotation = PI / 4
			_animated_sprite.flip_h = false
		elif input_direction.x < 0 and input_direction.y < 0:
			_animated_sprite.rotation = PI / 4
			_animated_sprite.flip_h = true
		elif input_direction.x < 0 and input_direction.y > 0:
			_animated_sprite.rotation = -PI / 4
			_animated_sprite.flip_h = true
		elif input_direction.x > 0:
			_animated_sprite.rotation = 0
			_animated_sprite.flip_h = false
		elif input_direction.x < 0:
			_animated_sprite.rotation = 0
			_animated_sprite.flip_h = true
		elif input_direction.y < 0:
			if _animated_sprite.flip_h:
				_animated_sprite.rotation = PI / 2
			else:
				_animated_sprite.rotation = -PI / 2
		elif input_direction.y > 0:
			if _animated_sprite.flip_h:
				_animated_sprite.rotation = -PI / 2
			else:
				_animated_sprite.rotation = PI / 2

		if is_sprinting:
			_animated_sprite.play("Sprint")
		else:
			_animated_sprite.play("Swimming")
	else:
		_animated_sprite.rotation = 0
		_animated_sprite.play("Idle")

func take_damage():
	if is_invincible or current_health <= 0 or is_hit_animation_playing:
		return

	hit_sound.play()
	current_health -= 1
	update_health_display()

	is_hit_animation_playing = true
	_animated_sprite.play("Hit")

	var hit_timer = Timer.new()
	add_child(hit_timer)
	hit_timer.wait_time = 1.0
	hit_timer.one_shot = true
	hit_timer.connect("timeout", Callable(self, "_on_hit_animation_finished"))
	hit_timer.start()

	is_invincible = true
	invincibility_timer.start()

	if current_health == 0:
		await player_died()

func _on_hit_animation_finished():
	is_hit_animation_playing = false

func _end_invincibility():
	is_invincible = false

func update_health_display():
	for i in range(max_health):
		var heart = heart_container.get_node("Heart%d" % (i + 1))
		if heart:
			heart.visible = i < current_health

func player_died():
	# Quando o jogador morre chamamos o game over via o oceano
	var ocean = get_node("/root/Ocean")
	await ocean.game_over()
