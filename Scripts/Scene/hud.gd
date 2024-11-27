extends CanvasLayer

@onready var dinheiro_label = $dinheiroLabel
@onready var mensagem_label = $MensagemLabel
@onready var lvl_item_label = $LvlItem
@onready var lixos_restantes_label = $LixosRestantesLabel  # Ajuste o caminho conforme necessário

func update_lixos_restantes(qtd):
	lixos_restantes_label.text = "Lixos restantes: %d" % qtd

func update_dinheiro(dinheiro):
	dinheiro_label.text = "%d" % dinheiro

func update_nivel_item(nivel):
	lvl_item_label.text = "Lvl: %d" % nivel

func mostrar_mensagem(texto):
	mensagem_label.text = texto
	mensagem_label.visible = true

func ocultar_mensagem():
	mensagem_label.visible = false
