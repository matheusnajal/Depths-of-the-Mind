extends Node

@export var max_mobs: int = 5
@export var mob_scenes: Array = [
	preload("res://Scenes/Fishs/good_fish1.tscn"),
	preload("res://Scenes/Fishs/good_fish2.tscn"),
	preload("res://Scenes/Fishs/good_fish3.tscn")
]
var mobs_atual: int = 0
# Carrega a cena do lixo corretamente
var LixoScene = preload("res://Scenes/World/trash.tscn")

@export var qtdLixos: int = 5  # Variável para controlar a quantidade de lixos

var dinheiro: int = 0  # Dinheiro atual do jogador

# Variáveis para o sistema de aprimoramento
var nivel_item_limpeza: int = 1
var tempo_limpeza_base: float = 2.0
var tempo_limpeza_atual: float = tempo_limpeza_base
var lixos_ativos = []

@onready var spawn_timer = Timer.new()
@onready var hud = $HUD  # Certifique-se de que o caminho está correto
@onready var jogador = $Player/CharacterBody2D  # Ajuste o caminho conforme necessário

func _ready():
	add_child(spawn_timer)
	gerar_lixos()
	spawn_timer.wait_time = 2.0
	spawn_timer.one_shot = false    
	spawn_timer.start()
	spawn_timer.timeout.connect(spawn_mob)
	hud.update_lixos_restantes(qtdLixos)
	hud.update_dinheiro(dinheiro)        # Inicializa o HUD com o dinheiro inicial (0)
	hud.update_nivel_item(nivel_item_limpeza)  # Inicializa o HUD com o nível do item


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

func gerar_lixos():
	var random = RandomNumberGenerator.new()
	random.randomize()
	for i in range(qtdLixos):
		var lixo_instance = LixoScene.instantiate()
		# Defina a posição aleatória dentro dos limites do mar
		var pos_x = random.randf_range(0, 1920)
		var pos_y = random.randf_range(0, 1080)
		lixo_instance.position = Vector2(pos_x, pos_y)
		# Escolha uma sprite aleatória
		var sprite_index = randi() % 7 + 1
		var sprite_path = "res://Sprites/Trash/lixo%d.png" % sprite_index
		var sprite_node = lixo_instance.get_node("Sprite2D")
		sprite_node.texture = load(sprite_path)
		# Ajuste a escala do sprite
		sprite_node.scale = Vector2(0.1, 0.1)
		# Defina o tempo de limpeza atual
		lixo_instance.tempo_para_limpar = tempo_limpeza_atual
		# Conecta o sinal 'lixo_limpo' ao método '_on_lixo_limpo'
		lixo_instance.connect("lixo_limpo", Callable(self, "_on_lixo_limpo"))
		# Conecta ao sinal 'tree_exited' para remover o lixo da lista quando for limpo
		lixo_instance.connect("tree_exited", Callable(self, "_on_lixo_removido").bind(lixo_instance))
		add_child(lixo_instance)
		lixos_ativos.append(lixo_instance)
		hud.update_lixos_restantes(qtdLixos)

func _on_lixo_limpo():
	dinheiro += 5  # Incrementa o dinheiro do jogador
	hud.update_dinheiro(dinheiro)  # Atualiza o HUD com o novo valor de dinheiro
	qtdLixos -= 1  # Decrementa a quantidade de lixos restantes
	hud.update_lixos_restantes(qtdLixos)  # Atualiza o HUD com a nova quantidade
	if qtdLixos == 0:
		print("Todos os lixos foram limpos!")


func _on_lixo_removido(lixo_instance):
	if lixo_instance in lixos_ativos:
		lixos_ativos.erase(lixo_instance)
