extends Area2D

signal lixo_limpo  # Sinal para indicar que o lixo foi limpo

var tempo_para_limpar: float = 2.0  # Tempo total necessário para limpar o lixo
var tempo_acumulado: float = 0.0    # Tempo que o jogador já gastou limpando
var sendo_limpo: bool = false       # Indica se o lixo está sendo limpo no momento
var escala_inicial: Vector2         # Escala original do sprite do lixo

var amplitude = 5.0    # A altura do movimento de flutuação
var velocidade = 2.0   # A velocidade do movimento de flutuação
var tempo = 0.0        # Tempo acumulado para a flutuação
var posicao_inicial    # Posição inicial do lixo
var amplitude_rotacao = 5.0  # Amplitude da rotação em graus

@onready var sprite = $Sprite2D     # Referência ao Sprite do lixo

func _ready():
	escala_inicial = sprite.scale
	posicao_inicial = position
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Jogador"):
		sendo_limpo = true

func _on_body_exited(body):
	if body.is_in_group("Jogador"):
		sendo_limpo = false
		# Reseta o tempo acumulado e a escala quando o jogador sai
		if tempo_acumulado > 0.0:
			tempo_acumulado = 0.0
			sprite.scale = escala_inicial

func _process(delta):
	tempo += delta
	# Movimento de flutuação
	var deslocamento_y = amplitude * sin(velocidade * tempo)
	position.y = posicao_inicial.y + deslocamento_y

	# Oscilação de rotação
	var rotacao = deg_to_rad(amplitude_rotacao) * sin(velocidade * tempo)
	rotation = rotacao

	# Lógica de limpeza
	if sendo_limpo and Input.is_action_pressed("Interagir"):
		tempo_acumulado += delta
		var proporcao_limpeza = tempo_acumulado / tempo_para_limpar
		proporcao_limpeza = clamp(proporcao_limpeza, 0.0, 1.0)
		sprite.scale = escala_inicial * (1.0 - proporcao_limpeza)
		if proporcao_limpeza >= 1.0:
			emit_signal("lixo_limpo")
			queue_free()
	else:
		if tempo_acumulado > 0.0:
			tempo_acumulado = 0.0
			sprite.scale = escala_inicial
