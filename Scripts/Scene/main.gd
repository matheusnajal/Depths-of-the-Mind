extends Node

@export var max_mobs: int = 5
@export var mob_scenes: Array = [preload("res://Scenes/Fishs/good_fish1.tscn"), preload("res://Scenes/Fishs/good_fish2.tscn"), preload("res://Scenes/Fishs/good_fish3.tscn")]
var mobs_atual: int = 0

@onready var spawn_timer = Timer.new()

func _ready():
	add_child(spawn_timer)
	spawn_timer.wait_time = 2.0
	spawn_timer.one_shot = false
	spawn_timer.start()
	spawn_timer.timeout.connect(spawn_mob)

func spawn_mob():
	if mobs_atual >= max_mobs:
		return

	var mob_scene = mob_scenes[randi() % mob_scenes.size()]
	var mob_instance = mob_scene.instantiate()
	
	var random_x = randf() * 1920
	var random_y = randf() * 1080
	mob_instance.position = Vector2(random_x, random_y)
	
	add_child(mob_instance)
	mobs_atual += 1

	mob_instance.connect("tree_exited", Callable(self, "_on_mob_removed"))

func _on_mob_removed():
	mobs_atual -= 1