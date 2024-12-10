extends Node

@export var max_mobs: int = 5
@export var mob_scenes: Array = [
	preload("res://Scenes/Fishs/good_fish1.tscn"),
	preload("res://Scenes/Fishs/good_fish2.tscn"),
	preload("res://Scenes/Fishs/good_fish3.tscn")
]
var mobs_atual: int = 0

var LixoScene = preload("res://Scenes/World/trash.tscn")

@export var total_days: int = 3
var current_day: int = 1

@export var initial_qtdLixos: int = 5
var qtdLixos: int = initial_qtdLixos
var qtdLixosAtuais: int = qtdLixos
var dinheiro: int = 0

var nivel_item_limpeza: int = 1
var tempo_limpeza_base: float = 2.0
var tempo_limpeza_atual: float = tempo_limpeza_base
var lixos_ativos = []

@export var trash_increment_per_day: int = 10
@export var max_mobs_increment_per_day: int = 5
@export var surge_duration_decrement_per_day: float = 0.5
@export var surge_interval_decrement_per_day: float = 3.0

@export var min_surge_time_limit: float = 5.0
@export var max_surge_time_limit: float = 10.0

@onready var spawn_timer = Timer.new()
@onready var hud = $HUD
@onready var jogador = $Player/CharacterBody2D
@onready var camera = $Player/CharacterBody2D/Camera2D
@onready var music_player = $AudioStreamPlayer2D
@onready var modified_music = load("res://Musics/fear of the bottom of the sea.mp3") as AudioStream
@onready var original_music = load("res://Musics/Exploring the seabed.mp3") as AudioStream
@onready var player = $Player/CharacterBody2D
@onready var transition_rect = $HUD/CanvasLayer/FadeColorReact
@onready var boat = $Barco/TextureRect
@onready var collisionBoat = $Barco/CollisionShape2D
@onready var take_trash = $AudioStreamPlayer2D2

var in_modified_ocean: bool = false

var spawn_fish_index = 1  # Dia 1: peixe 2
var spawn_interval = 5.0  # Dia 1: a cada 5s

func _ready():
	add_child(spawn_timer)
	gerar_lixos()

	spawn_fish_index = 1
	spawn_interval = 5.0
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.start()
	spawn_timer.timeout.connect(spawn_mob)
	
	GlobalSignals.connect("background_changed_to_modified", Callable(self, "_on_background_changed_to_modified"))
	GlobalSignals.connect("background_changed_to_original", Callable(self, "_on_background_changed_to_original"))

	if hud != null:
		hud.update_lixos_restantes(qtdLixosAtuais)
		hud.update_dinheiro(dinheiro)
		hud.update_nivel_item(nivel_item_limpeza)
		hud.update_dia(current_day)

func spawn_mob():
	if mobs_atual >= max_mobs or in_modified_ocean:
		return

	var mob_scene = mob_scenes[spawn_fish_index]
	var mob_instance = mob_scene.instantiate()
	
	var random_x = randf() * 1920
	var random_y = randf() * 1080
	mob_instance.position = Vector2(random_x, random_y)
	
	add_child(mob_instance)
	mobs_atual += 1

	mob_instance.connect("tree_exited", Callable(self, "_on_mob_removed"))

func _on_mob_removed():
	mobs_atual -= 1

func gerar_lixos():
	clear_existing_trash()
	
	var random = RandomNumberGenerator.new()
	random.randomize()
	for i in range(qtdLixos):
		var lixo_instance = LixoScene.instantiate()
		var pos_x = random.randf_range(0, 1920)
		var pos_y = random.randf_range(0, 1080)
		lixo_instance.position = Vector2(pos_x, pos_y)
		var sprite_index = randi() % 7 + 1
		var sprite_path = "res://Sprites/Trash/lixo%d.png" % sprite_index
		var sprite_node = lixo_instance.get_node("Sprite2D")
		sprite_node.texture = load(sprite_path)
		sprite_node.scale = Vector2(0.1, 0.1)
		lixo_instance.tempo_para_limpar = tempo_limpeza_atual
		lixo_instance.connect("lixo_limpo", Callable(self, "_on_lixo_limpo"))
		lixo_instance.connect("tree_exited", Callable(self, "_on_lixo_removido").bind(lixo_instance))
		add_child(lixo_instance)
		lixos_ativos.append(lixo_instance)
	
	if hud != null:
		hud.update_lixos_restantes(qtdLixosAtuais)

func _on_lixo_limpo():
	dinheiro += 5
	if hud != null:
		hud.update_dinheiro(dinheiro)
	
	qtdLixosAtuais -= 1
	if hud != null:
		hud.update_lixos_restantes(qtdLixosAtuais)
	
	if qtdLixosAtuais <= 0 and not in_modified_ocean:
		# Se for o ultimo dia (dia 3) significa que o jogo terminou com sucesso
		if current_day == total_days:
			await end_game()
		else:
			await transition_to_next_day()

func _on_lixo_removido(lixo_instance):
	if lixo_instance in lixos_ativos:
		take_trash.play()
		lixos_ativos.erase(lixo_instance)

func clear_existing_trash():
	for lixo in lixos_ativos:
		if lixo.is_inside_tree():
			lixo.queue_free()
	lixos_ativos.clear()
	

func advance_day():
	if current_day < total_days:
		current_day += 1
		qtdLixos += trash_increment_per_day
		max_mobs += max_mobs_increment_per_day

		if camera != null:
			camera.min_time = max(camera.min_time - surge_interval_decrement_per_day, min_surge_time_limit)
			camera.max_time = max(camera.max_time - surge_interval_decrement_per_day, max_surge_time_limit)
			camera.shake_duration = max(camera.shake_duration - surge_duration_decrement_per_day, 1.0)

		if hud != null:
			hud.update_dia(current_day)

		qtdLixosAtuais = qtdLixos
		if hud != null:
			hud.update_lixos_restantes(qtdLixosAtuais)

		gerar_lixos()
		reset_oxygen()
		reset_health()

		match current_day:
			1:
				pass
			2:
				spawn_fish_index = 0
				spawn_interval = 10.0
			3:
				spawn_fish_index = 2
				spawn_interval = 15.0

		spawn_timer.wait_time = spawn_interval
	else:
		# Se chegou além do total de dias, tela de vitória
		await end_game()

func reset_oxygen():
	player.oxygen = 99
	player.update_oxygen_cylinder()

func reset_health():
	player.current_health = player.max_health
	player.update_health_display()

func _on_background_changed_to_modified() -> void:
	in_modified_ocean = true
	if music_player:
		music_player.stream = modified_music
		music_player.play()
	boat.visible = false
	collisionBoat.disabled = true
	toggle_lixos_visibility(false)

func _on_background_changed_to_original() -> void:
	in_modified_ocean = false
	if music_player:
		music_player.stream = original_music
		music_player.play()
	boat.visible = true
	collisionBoat.disabled = false
	toggle_lixos_visibility(true)

func toggle_lixos_visibility(visible: bool) -> void:
	for lixo in lixos_ativos:
		lixo.visible = visible
		lixo.set_process(visible)

# Função chamada quando passa pro próximo dia
func transition_to_next_day():
	await fade_in_black_screen()
	advance_day()
	camera.reset_shake_timers()
	await fade_out_black_screen()
	camera.start_random_shake_timer()

func end_game():
	await transition_to_screen("res://Scenes/Menu/Vitoria.tscn")

func game_over():
	await transition_to_screen("res://Scenes/Menu/game_over.tscn")

func transition_to_screen(scene_path: String):
	await fade_in_black_screen(2.0)
	get_tree().change_scene_to_file(scene_path)

func fade_in_black_screen(duration := 2.0):
	transition_rect.visible = true
	transition_rect.modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(transition_rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_out_black_screen(duration := 2.0):
	var tween = get_tree().create_tween()
	tween.tween_property(transition_rect, "modulate:a", 0.0, duration)
	await tween.finished
	transition_rect.visible = false
