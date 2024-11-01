extends CharacterBody2D

@export var speed = 400
@onready var _animated_sprite = $AnimatedSprite2D
var direction_right = true

func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
	
	var new_position = global_position
	# Aplicar a nova posição corrigida
	
	new_position.x = clamp(new_position.x, 0, 1920)
	new_position.y = clamp(new_position.y, 0, 1080)

	global_position = new_position
	var is_sprinting = Input.is_action_pressed("Sprint")
	
	if is_sprinting == true:
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
