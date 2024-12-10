extends Node

@export var qtd_lixos_iniciais: int = 50  # Quantidade inicial de lixos para a tela de Game Over
@export var lixo_path: String = "res://Scenes/World/trash.tscn"
@export var screen_size: Vector2 = Vector2(1920, 1080)  # Resolução da tela
@export var sprite_count: int = 7  # Número total de sprites diferentes para os lixos

# Chamado quando o nó entra na cena pela primeira vez
func _ready() -> void:
	$VBoxContainer/MenuButton.grab_focus()
	_spawn_lixos(qtd_lixos_iniciais)  # Espalhar lixos pela tela

# Função para spawnar múltiplos lixos
func _spawn_lixos(lixo_count: int):
	if not lixo_path:
		print("Erro: Caminho para a cena de lixo não está configurado.")
		return

	var random = RandomNumberGenerator.new()
	random.randomize()

	for i in range(lixo_count):
		var lixo_scene = load(lixo_path)
		if not lixo_scene:
			print("Erro: Falha ao carregar a cena de lixo.")
			continue

		var lixo_instance = lixo_scene.instantiate()
		if not lixo_instance:
			print("Erro: Falha ao instanciar a cena de lixo.")
			continue

		# Configurar posição aleatória na tela
		var pos_x = random.randf_range(0, screen_size.x)
		var pos_y = random.randf_range(0, screen_size.y)
		lixo_instance.position = Vector2(pos_x, pos_y)

		# Configurar sprite aleatório para o lixo
		var sprite_index = randi() % sprite_count + 1
		var sprite_path = "res://Sprites/Trash/lixo%d.png" % sprite_index
		var sprite_node = lixo_instance.get_node("Sprite2D")
		if sprite_node:
			sprite_node.texture = load(sprite_path)
			sprite_node.scale = Vector2(0.1, 0.1)  # Escala ajustada para visualização adequada

		# Adicionar o lixo à cena
		add_child(lixo_instance)
		print("Lixo spawnado em: ", lixo_instance.position)

# Botão para retornar ao menu principal
func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn")

# Botão para sair do jogo
func _on_exit_button_pressed() -> void:
	get_tree().quit()
