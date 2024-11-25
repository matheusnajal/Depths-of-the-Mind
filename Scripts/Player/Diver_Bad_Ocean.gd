extends CharacterBody2D

@export var speed = 400
@onready var _animated_sprite = $AnimatedSprite2D
@onready var oxygen_cylinder = get_node("/root/BadOcean/CanvasLayer/TextureRect/TextEdit")
var direction_right = true
var oxygen = 100
var oxygen_decrease_timer = Timer.new()

func _ready():
	add_child(oxygen_decrease_timer)
	oxygen_decrease_timer.wait_time = 3.0
	oxygen_decrease_timer.one_shot = false
	oxygen_decrease_timer.connect("timeout", Callable(self, "_on_oxygen_decrease"))
	oxygen_decrease_timer.start()

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

func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()

	var new_position = global_position

	new_position.x = clamp(new_position.x, 0, 1920)
	new_position.y = clamp(new_position.y, -100, 1080)

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
