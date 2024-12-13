extends Label

var time_passed: float = 0.0

# Velocidade da transição de cores (ajuste conforme desejado)
const COLOR_SPEED: float = 2.0

func _process(delta: float) -> void:
	# Incrementa o tempo com base no delta (tempo entre frames)
	time_passed += delta * COLOR_SPEED
	
	# Calcula valores RGB com base em uma onda senoidal para criar a transição suave
	var r: float = 0.5 + 0.5 * sin(time_passed)
	var g: float = 0.5 + 0.5 * sin(time_passed + PI / 2)
	var b: float = 0.5 + 0.5 * sin(time_passed + PI)
	
	# Atualiza a cor do Label
	modulate = Color(r, g, b, 1.0)
