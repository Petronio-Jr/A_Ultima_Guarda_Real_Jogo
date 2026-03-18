extends StaticBody2D
class_name  MinaOuro

const OURO: PackedScene = preload("res://A Ultima Guarda Real/Coletaveis/ouro.tscn")

var personagem: CharacterBase = null
var tempo_producao_atual: float = 0.0

var nivel_mina: int = 0

@export_category("Objetos")
@export var sprite: Sprite2D
@export var tempo_producao: Timer

@export_category("Variaveis")
@export var tempo_producao_padrao: float = 10.0
@export var tempo_producao_adicional: float = 15.0

func _on_area_mina_body_entered(_body: Node2D) -> void:
	if _body is CharacterBase:
		personagem = _body

func _on_area_mina_body_exited(_body: Node2D) -> void:
	if _body is CharacterBase:
		personagem = null

func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("interagir") and personagem != null:
		
		if personagem.quant_madeira < 0:
			personagem.quant_madeira = 0
			return
		# UPGRADE PARA NIVEL 1
		if personagem.quant_madeira >= 30 and nivel_mina == 0:
			nivel_mina = 1
			personagem.quant_madeira -= 30
			personagem.gasta_item("madeira")
			sprite.texture = load("res://A Ultima Guarda Real/Sprites/Tiny Swords/Tiny Swords (Update 010)/Resources/Gold Mine/GoldMine_Inactive.png")
		
		# UPGRADE PARA NIVEL 2 (ativa e começa produção)
		elif nivel_mina == 1:
			nivel_mina = 2
			sprite.texture = load("res://A Ultima Guarda Real/Sprites/Tiny Swords/Tiny Swords (Update 010)/Resources/Gold Mine/GoldMine_Active.png")
			tempo_producao.start(tempo_producao_padrao)
		
		# SE JÁ ESTIVER NO NÍVEL 2, AUMENTA TEMPO
		elif nivel_mina == 2 and personagem.quant_madeira >= 10:
			personagem.quant_madeira -= 10
			personagem.gasta_item("madeira")
			var restante = tempo_producao.time_left
			tempo_producao_atual = restante + tempo_producao_adicional
			sprite.texture = load("res://A Ultima Guarda Real/Sprites/Tiny Swords/Tiny Swords (Update 010)/Resources/Gold Mine/GoldMine_Active.png")
			tempo_producao.start(tempo_producao_atual)

func _on_timer_producao_timeout() -> void:
	nivel_mina = 1
	tempo_producao_atual = 0
	sprite.texture = load("res://A Ultima Guarda Real/Sprites/Tiny Swords/Tiny Swords (Update 010)/Resources/Gold Mine/GoldMine_Inactive.png",)

func _on_timer_spawn_timeout() -> void:
	if nivel_mina < 2:
		return
		
	var ouro: Coletaveis = OURO.instantiate()
	get_parent().call_deferred("add_child", ouro)
	ouro.global_position = global_position + Vector2(
		randi_range(-80, 80),
		randi_range(64, 96)
	)
	
	
