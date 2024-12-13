extends Node

@export var qtd_peixes_iniciais: int = 20

@export var peixes_paths: Array = [
	"res://Scenes/Fishs/good_fish1.tscn",
	"res://Scenes/Fishs/good_fish2.tscn",
	"res://Scenes/Fishs/good_fish3.tscn"
]

@export var screen_size: Vector2 = Vector2(1920,1080)  # Resolução compacta

# Chamado quando o nó entra na cena pela primeira vez
func _ready() -> void:
	$VBoxContainer/MenuButton.grab_focus()

	# Gerar os peixes iniciais garantindo variedade
	_spawn_varied_peixes(qtd_peixes_iniciais)

# Função para spawnar múltiplos peixes variados
func _spawn_varied_peixes(peixe_count: int):
	var peixes_indices = [0, 1, 2]  # Índices das cenas de peixes
	var random = RandomNumberGenerator.new()
	random.randomize()

	for i in range(peixe_count):
		# Seleciona um tipo de peixe de forma cíclica para garantir variedade
		var peixe_index = peixes_indices[i % peixes_indices.size()]
		var peixe_path = peixes_paths[peixe_index]
		var peixe_scene = load(peixe_path)
		if not peixe_scene:
			print("Erro: Falha ao carregar a cena de peixe no caminho: ", peixe_path)
			continue
		
		var peixe_instance = peixe_scene.instantiate()
		if not peixe_instance:
			print("Erro: Falha ao instanciar a cena de peixe.")
			continue

		# Definir posição aleatória na área centralizada
		var random_x = random.randf_range(0, screen_size.x)
		var random_y = random.randf_range(0, screen_size.y)
		peixe_instance.position = Vector2(random_x, random_y)

		# Adicionar à árvore de cena
		add_child(peixe_instance)
		print("Peixe spawnado em: ", peixe_instance.position)

# Botão para retornar ao menu principal
func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn")

# Botão para sair do jogo
func _on_exit_button_pressed() -> void:
	get_tree().quit()
