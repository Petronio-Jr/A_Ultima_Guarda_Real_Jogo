extends CharacterBody2D
class_name Monge

@export_category("Personagens")
@export var guerreiro: CharacterBase
@export var arqueiro: Arqueiro

@export_category("Objetos")
@export var anim: AnimatedSprite2D
@export var cura_efeito_scene: PackedScene

var pode_interagir := false

func _on_area_interacao_body_entered(_body: Node2D) -> void:
	if _body is CharacterBase or _body is Arqueiro:
		pode_interagir = true

func _on_area_interacao_body_exited(_body: Node2D) -> void:
	if _body is CharacterBase or _body is Arqueiro:
		pode_interagir = false

func _process(_delta: float) -> void:
	
	if not pode_interagir:
		return
		
	if Input.is_action_just_pressed("interagir"):
		tentar_curar()

func tentar_curar() -> void:
	var ouro_total = guerreiro.quant_ouro + arqueiro.quant_ouro
	
	if guerreiro.morto or arqueiro.morto:
		if ouro_total >= 500:
			guerreiro.quant_ouro -= 500
			guerreiro.gasta_item("ouro")
			if guerreiro.morto:
				guerreiro.reviver()
				aplicar_efeito_cura(guerreiro)
			if arqueiro.morto:
				arqueiro.reviver()
				aplicar_efeito_cura(arqueiro)
			
			anim.play("cura")
		return
	
	if ouro_total >= 300:
		guerreiro.quant_ouro -= 300
		guerreiro.gasta_item("ouro")
		guerreiro.curar_total()
		aplicar_efeito_cura(guerreiro)
		arqueiro.curar_total()
		aplicar_efeito_cura(arqueiro)

		anim.play("cura")
		
	return

func aplicar_efeito_cura(alvo: Node2D) -> void:
	var efeito = cura_efeito_scene.instantiate()
	efeito.global_position = alvo.global_position
	get_tree().current_scene.add_child(efeito)


func _on_textura_animation_finished() -> void:
	anim.play("idle")
