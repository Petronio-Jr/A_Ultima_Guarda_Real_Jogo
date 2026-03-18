extends StaticBody2D
class_name Arvore_coletavel

const PARTICULAS_HIT: PackedScene = preload("res://A Ultima Guarda Real/efeitos/hit.tscn")
const MADEIRA_COLETAVEL: PackedScene = preload("res://A Ultima Guarda Real/Coletaveis/madeira.tscn")
var morto = false

@export_category("Variaveis")
@export var vida: int = 50
@export var madeira_min: int = 1
@export var madeira_max: int = 5

@export_category("Objetos")
@export var anim: AnimationPlayer

func _ready() -> void:
	pass
	
func update_vida(escala_dano: Array) -> void: # [20,40]
	if morto:
		return
		
	vida -= randi_range(
		escala_dano[0], #20
		escala_dano[1] #40
	)
	
	spawn_particulas()
	
	if vida <= 0:
		spaw_madeira()
		morto = true
		queue_free()
		return

func spawn_particulas() -> void:
	var hit = PARTICULAS_HIT.instantiate()
	hit.global_position = global_position
	hit.emitting = true
	get_tree().root.call_deferred("add_child", hit)

func spaw_madeira() -> void:
	var quant_madeira: int = randi_range(madeira_min, madeira_max)
	for i in quant_madeira:
		var madeira: Coletaveis = MADEIRA_COLETAVEL.instantiate()
		madeira.global_position = global_position + Vector2(
			randi_range(-32, 32), randi_range(-32, 32)
		)
		get_parent().call_deferred("add_child", madeira)

func _on_animacao_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "dano":
		anim.play("idle")
