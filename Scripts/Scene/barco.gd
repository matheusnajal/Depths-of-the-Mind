extends Area2D

var jogador_proximo = false

# Dados dos aprimoramentos
var niveis = [10, 30, 50, 70]  # Custos para os níveis 2 a 5
var reducoes = [0.9, 0.7, 0.5, 0.3]  # Fatores multiplicativos do tempo de limpeza
var nivel_maximo = 5  # Nível máximo do item de limpeza

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Jogador"):
		jogador_proximo = true
		mostrar_mensagem_aprimoramento()

func _on_body_exited(body):
	if body.is_in_group("Jogador"):
		jogador_proximo = false
		ocultar_mensagem_aprimoramento()

func _process(delta):
	if jogador_proximo and Input.is_action_just_pressed("Interagir"):
		tentar_aprimorar()

func mostrar_mensagem_aprimoramento():
	var principal = get_node("/root/Ocean")  # Ajuste o caminho conforme necessário
	var nivel_atual = principal.nivel_item_limpeza
	if nivel_atual < nivel_maximo:
		var custo = niveis[nivel_atual - 1]
		principal.hud.mostrar_mensagem("Aperte E para aprimorar item por %d reais" % custo)
	else:
		principal.hud.mostrar_mensagem("Item de limpeza já está no nível máximo.")

func ocultar_mensagem_aprimoramento():
	var principal = get_node("/root/Ocean")  # Ajuste o caminho conforme necessário
	principal.hud.ocultar_mensagem()

func tentar_aprimorar():
	var principal = get_node("/root/Ocean")  # Ajuste o caminho conforme necessário
	var nivel_atual = principal.nivel_item_limpeza
	if nivel_atual >= nivel_maximo:
		exibir_mensagem_jogador("Item já está no nível máximo.")
		return
	var custo = niveis[nivel_atual - 1]
	if principal.dinheiro >= custo:
		# Deduz o dinheiro
		principal.dinheiro -= custo
		# Atualiza o HUD
		principal.hud.update_dinheiro(principal.dinheiro)
		# Incrementa o nível do item de limpeza
		principal.nivel_item_limpeza += 1
		# Atualiza o tempo de limpeza
		var reducao = reducoes[nivel_atual - 1]
		principal.tempo_limpeza_atual = principal.tempo_limpeza_base * reducao
		# Atualiza os lixos ativos
		for lixo in principal.lixos_ativos:
			lixo.tempo_para_limpar = principal.tempo_limpeza_atual
		# Atualiza o HUD com o novo nível do item
		principal.hud.update_nivel_item(principal.nivel_item_limpeza)
		# Exibe mensagem de sucesso acima do jogador
		exibir_mensagem_jogador("Aprimoramento comprado")
		# Atualiza a mensagem de aprimoramento
		mostrar_mensagem_aprimoramento()
	else:
		# Exibe mensagem de erro acima do jogador
		exibir_mensagem_jogador("Você não tem dinheiro suficiente")

func exibir_mensagem_jogador(texto):
	var principal = get_node("/root/Ocean")  # Ajuste o caminho conforme necessário
	principal.jogador.exibir_mensagem(texto)
