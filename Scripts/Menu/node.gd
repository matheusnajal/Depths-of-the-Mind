extends Node


@export var qtd_peixes_iniciais: int = 20
@export var qtd_lixos_iniciais: int = 10

@export var peixes_paths: Array = [
	"res://Scenes/Fishs/good_fish1.tscn",
	"res://Scenes/Fishs/good_fish2.tscn",
	"res://Scenes/Fishs/good_fish3.tscn"
]

@export var lixo_path: String = "res://Scenes/World/trash.tscn"

@export var screen_size: Vector2 = Vector2(1920,1080)  # Resolução compacta

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/MenuButton.grab_focus()
	for i in range(qtd_lixos_iniciais):
		_spawn_lixo()

	# Gerar os peixes iniciais garantindo variedade
	_spawn_varied_peixes(qtd_peixes_iniciais)

func _spawn_lixo():
	if not lixo_path:
		print("Erro: Caminho para a cena de lixo não está configurado.")
		return
	
	# Tentar carregar a cena de lixo
	var lixo_scene = load(lixo_path)
	if not lixo_scene:
		print("Erro: Falha ao carregar a cena de lixo no caminho: ", lixo_path)
		return
	
	# Instanciar e adicionar à cena
	var lixo_instance = lixo_scene.instantiate()
	if not lixo_instance:
		print("Erro: Falha ao instanciar a cena de lixo.")
		return
	
	# Definir posição aleatória na área centralizada
	var random_x = randf() * screen_size.x
	var random_y = randf() * screen_size.y
	lixo_instance.position = Vector2(random_x, random_y)

	# Adicionar à árvore de cena
	add_child(lixo_instance)
	print("Lixo spawnado em: ", lixo_instance.position)

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
