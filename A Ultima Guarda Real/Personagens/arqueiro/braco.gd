extends Node2D

const FLECHA: PackedScene = preload("res://A Ultima Guarda Real/Personagens/arqueiro/flecha.tscn")

@onready var arco: Sprite2D = get_node("arco")
@onready var anim: AnimationPlayer = get_node("Animacao_arco")

@export var pode_atacar: bool = true
@export var atacando: bool = false
var morreu: bool = false

func _physics_process(_delta: float) -> void:
	if morreu:
		anim.play("morte")
		return
		
	if Input.is_action_just_pressed("flechada") and pode_atacar:
		anim.play("ataque")
		atacando = true
	
func spawn_flecha() -> void:
	var flecha = FLECHA.instantiate()
	flecha.global_position = global_position
	flecha.set_shooter(self) # passa quem atirou
	get_tree().current_scene.add_child(flecha)
	
	var dir = global_position.direction_to(get_global_mouse_position())
	flecha.setup(dir)

func animacao(direcao_ataque: Vector2, direcao: Vector2, morto: bool) -> void:
	if morto:
		morreu = true
		return
		
	if direcao_ataque.x > 0:
		arco.flip_v = false
		
	if direcao_ataque.x < 0:
		arco.flip_v = true
		
	look_at(direcao)

func _on_animacao_arco_animation_finished(_anim_name: StringName) -> void:
	atacando = false
	pass # Replace with function body.
