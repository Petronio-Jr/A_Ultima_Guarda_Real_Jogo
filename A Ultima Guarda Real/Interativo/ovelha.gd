extends CharacterBody2D
class_name Ovelha

const CARNE_COLETAVEL: PackedScene = preload("res://A Ultima Guarda Real/Coletaveis/carne.tscn")
const PARTICULAS_HIT: PackedScene = preload("res://A Ultima Guarda Real/efeitos/hit.tscn")

var tempo_espera: float
var tempo_espera_fuga: float
var direcao: Vector2

var morto: bool = false
var vida: int = 50 

var velocidade_padrao: float

@export_category("Variaveis")
@export var velocidade: float = 128.0

@export_category("Objetos")
@export var sprite: Sprite2D
@export var anim: AnimationPlayer
@export var tempo_andando: Timer
@export var tempo_fugindo: Timer
@export var poeira: CPUParticles2D

func _ready() -> void:
	velocidade_padrao = velocidade
	
	tempo_espera = randf_range(2.0, 5.0)
	tempo_espera_fuga = randf_range(1.0, 3.0)
	
	direcao = get_direction()
	tempo_andando.start()
	
func _physics_process(_delta: float) -> void:
	
	poeira.emitting = false
	if direcao:
		poeira.emitting = true
		
	velocity = direcao * velocidade
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		direcao = velocity.bounce(
			get_slide_collision(0).get_normal()
		).normalized()
		
	animacao()

func animacao() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
		
	if velocity.x < 0:
		sprite.flip_h = true
		
	if velocity:
		anim.play("andando")
		return
	
	anim.play("idle")

# ======================================================
#		Atualizando vida
# ======================================================

func update_vida(escala_dano: Array,) -> void: # [20,40]
	if morto:
		return
		
	vida -= randi_range(
		escala_dano[0], #20
		escala_dano[1] #40
	)
	
	spawn_particulas()
	
	if vida <= 0:
		spaw_carne()
		morto = true
		queue_free()
		return
		
	tempo_fugindo.start(tempo_espera_fuga)
	direcao = get_direction()
	velocidade *= 2
	
# ======================================================
#		Spawn de itens e particulas
# ======================================================

func spaw_carne() -> void:
	var carne: Coletaveis = CARNE_COLETAVEL.instantiate()
	carne.global_position = global_position + Vector2(
		randi_range(-32, 32), randi_range(-32, 32)
	)
		
	get_parent().call_deferred("add_child", carne)

func spawn_particulas() -> void:
	var hit = PARTICULAS_HIT.instantiate()
	hit.global_position = global_position
	hit.modulate = Color.RED
	hit.emitting = true
	
	get_tree().root.call_deferred("add_child", hit)

# ======================================================
#		Movimentação
# ======================================================

func get_direction() -> Vector2:
	return [
		Vector2(-1,0), Vector2(1,0), Vector2(-1,-1), Vector2(0,-1),
		Vector2(1,-1), Vector2(-1,1), Vector2(0,1), Vector2(1,1),
		Vector2.ZERO
	].pick_random().normalized()
	

func _on_timer_timeout() -> void:
	tempo_andando.start(tempo_espera)
	
	if direcao == Vector2.ZERO:
		direcao = get_direction()
		return
	
	direcao = Vector2.ZERO
	

func _on_timer_fugindo_timeout() -> void:
	velocidade = velocidade_padrao
