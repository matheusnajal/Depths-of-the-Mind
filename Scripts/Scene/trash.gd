extends Area2D

signal lixo_limpo

var tempo_para_limpar: float = 2.0
var tempo_acumulado: float = 0.0
var sendo_limpo: bool = false
var escala_inicial: Vector2

var amplitude = 5.0
var velocidade = 2.0
var tempo = 0.0
var posicao_inicial
var amplitude_rotacao = 5.0

@onready var sprite = $Sprite2D

func _ready():
	escala_inicial = sprite.scale
	posicao_inicial = position

func _on_body_entered(body):
	if body.is_in_group("Jogador"):
		sendo_limpo = true

func _on_body_exited(body):
	if body.is_in_group("Jogador"):
		sendo_limpo = false
		if tempo_acumulado > 0.0:
			tempo_acumulado = 0.0
			sprite.scale = escala_inicial

func _process(delta):
	tempo += delta
	var deslocamento_y = amplitude * sin(velocidade * tempo)
	position.y = posicao_inicial.y + deslocamento_y

	var rotacao = deg_to_rad(amplitude_rotacao) * sin(velocidade * tempo)
	rotation = rotacao

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
