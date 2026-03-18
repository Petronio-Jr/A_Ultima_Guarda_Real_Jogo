extends CanvasLayer
class_name HUD

@export_category("Objetos")
@export var HUD_ouro: Label
@export var HUD_madeira: Label
@export var HUD_kills: Label
@export var guerreiro: CharacterBase
@export var arqueiro: Arqueiro
@export var game: Node2D

func _ready() -> void:
	# Supondo que guerreiro e arqueiro já estejam definidos via export
	guerreiro.ouro_mudou.connect(_on_ouro_mudou)
	arqueiro.ouro_mudou.connect(_on_ouro_mudou)
	
	guerreiro.madeira_mudou.connect(_on_madeira_mudou)
	arqueiro.madeira_mudou.connect(_on_madeira_mudou)
	
	game.kills_mudou.connect(_on_kills_mudou)
	
	update_valores()  # Inicializa

# ======================================================
#		Atualiza numeros no HUD
# ======================================================

func _on_ouro_mudou(novo_valor: int) -> void:
	update_valores()

func _on_madeira_mudou(novo_valor: int) -> void:
	update_valores()

func _on_kills_mudou(novo_valor: int) -> void:
		HUD_kills.text = str(novo_valor)  
	
func update_valores() -> void:
	var quant_ouro = guerreiro.quant_ouro + arqueiro.quant_ouro
	var quant_madeira = guerreiro.quant_madeira + arqueiro.quant_madeira
	
	HUD_ouro.text = str(quant_ouro)
	HUD_madeira.text = str(quant_madeira)
