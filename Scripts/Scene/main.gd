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

# Variáveis para controle de dias
@export var total_days: int = 3
var current_day: int = 1

# Configurações iniciais para o Dia 1
@export var initial_qtdLixos: int = 5
var qtdLixos: int = initial_qtdLixos
var qtdLixosAtuais: int = qtdLixos  # Inicializa com a quantidade total de lixos
var dinheiro: int = 0  # Dinheiro atual do jogador

# Variáveis para o sistema de aprimoramento
var nivel_item_limpeza: int = 1
var tempo_limpeza_base: float = 2.0
var tempo_limpeza_atual: float = tempo_limpeza_base
var lixos_ativos = []

# Incrementos por dia
@export var trash_increment_per_day: int = 10
@export var max_mobs_increment_per_day: int = 5
@export var surge_duration_decrement_per_day: float = 0.5
@export var surge_interval_decrement_per_day: float = 3.0

# Limites para os tempos de surto
@export var min_surge_time_limit: float = 5.0
@export var max_surge_time_limit: float = 10.0

@onready var spawn_timer = Timer.new()
@onready var hud = $HUD  # Certifique-se de que o caminho está correto
@onready var jogador = $Player/CharacterBody2D  # Ajuste o caminho conforme necessário
@onready var camera = $Player/CharacterBody2D/Camera2D  # Referência à câmera para ajustar surtos
@onready var victory_screen = $VictoryScreen  # Referência à tela de vitória

func _ready():
	add_child(spawn_timer)
	gerar_lixos()
	spawn_timer.wait_time = 2.0
	spawn_timer.one_shot = false    
	spawn_timer.start()
	spawn_timer.timeout.connect(spawn_mob)
	
	# Atualizar o HUD com lixos restantes
	if hud != null:
		hud.update_lixos_restantes(qtdLixosAtuais)
	else:
		print("Erro: Referência ao HUD é null!")
	
	# Atualizar o HUD com dinheiro
	if hud != null:
		hud.update_dinheiro(dinheiro)
	else:
		print("Erro: Referência ao HUD é null!")
	
	# Atualizar o HUD com nível do item
	if hud != null:
		hud.update_nivel_item(nivel_item_limpeza)
	else:
		print("Erro: Referência ao HUD é null!")
	
	# Atualizar o HUD com o dia atual
	if hud != null:
		hud.update_dia(current_day)
	else:
		print("Erro: Referência ao HUD é null!")
	
	# Depuração: Verificar se a câmera foi encontrada
	if camera == null:
		print("Erro: Câmera não encontrada! Verifique o caminho '$Player/CharacterBody2D/Camera2D'.")
	else:
		print("Câmera encontrada: ", camera)

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
	clear_existing_trash()
	
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
	
	if hud != null:
		hud.update_lixos_restantes(qtdLixosAtuais)
	else:
		print("Erro: Referência ao HUD é null!")

func _on_lixo_limpo():
	dinheiro += 5  # Incrementa o dinheiro do jogador
	if hud != null:
		hud.update_dinheiro(dinheiro)
	else:
		print("Erro: Referência ao HUD é null!")
	
	qtdLixosAtuais -= 1  # Decrementa a quantidade de lixos restantes
	if hud != null:
		hud.update_lixos_restantes(qtdLixosAtuais)
	else:
		print("Erro: Referência ao HUD é null!")
	
	if qtdLixosAtuais <= 0:
		advance_day()

func _on_lixo_removido(lixo_instance):
	if lixo_instance in lixos_ativos:
		lixos_ativos.erase(lixo_instance)

# Função para limpar os lixos ativos
func clear_existing_trash():
	for lixo in lixos_ativos:
		if lixo.is_inside_tree():
			lixo.queue_free()
	lixos_ativos.clear()

# Função para avançar para o próximo dia
func advance_day():
	if current_day < total_days:
		current_day += 1
		print("Dia " + str(current_day) + " iniciado!")

		# Incrementar lixos e mobs
		qtdLixos += trash_increment_per_day
		max_mobs += max_mobs_increment_per_day

		# Ajustar os tempos de surto na câmera
		if camera != null:
			# Ajustar os tempos de surto na câmera
			camera.min_time = max(camera.min_time - surge_interval_decrement_per_day, min_surge_time_limit)
			camera.max_time = max(camera.max_time - surge_interval_decrement_per_day, max_surge_time_limit)
			camera.shake_duration = max(camera.shake_duration - surge_duration_decrement_per_day, 1.0)
		else:
			print("Erro: Não foi possível ajustar os tempos de surto na câmera porque a referência está nula.")

		# Atualizar o HUD com o novo dia
		if hud != null:
			hud.update_dia(current_day)
		else:
			print("Erro: Referência ao HUD é null!")

		# Definir a nova quantidade de lixos restantes
		qtdLixosAtuais = qtdLixos
		if hud != null:
			hud.update_lixos_restantes(qtdLixosAtuais)
		else:
			print("Erro: Referência ao HUD é null!")

		# Gerar novos lixos
		gerar_lixos()
	else:
		end_game()

# Função para finalizar o jogo
func end_game():
	print("Parabéns! Você limpou todos os dias.")
	get_tree().paused = true  # Pausa o jogo
