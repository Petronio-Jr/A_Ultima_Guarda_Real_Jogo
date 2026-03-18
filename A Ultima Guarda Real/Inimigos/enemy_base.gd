extends CharacterBody2D
class_name EnemyBase

const OURO_COLETAVEL: PackedScene = preload("res://A Ultima Guarda Real/Coletaveis/ouro.tscn")
var morto = false

signal morreu

var pode_atacar: bool = true
var tomando_dano: bool = false
var perseguir_forcado: bool = false

@export_category("Variaveis")
@export var vida: int = 80
@export var ouro_min: int = 1
@export var ouro_max: int = 3
@export var velocidade: float = 200.0
@export var distancia_ataque: float = 80.0
@export var dano_padrao: float = 10.0
@export var dano_critico: float = 20.0
@export var poeira: CPUParticles2D

var alvo: Node2D = null

@export_category("Objetos")
@export var anim: AnimationPlayer
@export var sprite: Sprite2D
@export var area_colisao_ataque: CollisionShape2D
@export var tempo_entre_ataques: Timer 


func _ready() -> void:
	add_to_group("Enemies")

func _physics_process(_delta: float) -> void:
	if morto:
		return
	
	if tomando_dano:
		velocity = Vector2.ZERO
		return
		
	if perseguir_forcado or alvo:
		perseguicao(alvo)
	else:
		velocity = Vector2.ZERO
	
	if velocity.x > 0:
		sprite.flip_h = false
		area_colisao_ataque.position.x = 47.5
		
	if velocity.x < 0:
		sprite.flip_h = true
		area_colisao_ataque.position.x = -47.5
		
	move_and_slide()

# ======================================================
#		Mecanica de perseguição
# ======================================================

func perseguicao(alvo: Node2D) -> void:
	
	if alvo:
		var distancia = global_position.distance_to(alvo.global_position)
		if distancia > distancia_ataque:
			var direcao: Vector2 = (alvo.global_position - global_position).normalized()
			velocity = direcao * velocidade
			anim.play("andando")
			poeira.emitting = true
		else:
			poeira.emitting = false
			velocity = Vector2.ZERO
			
			if pode_atacar:
				atacar()

func _on_area_perseguicao_body_entered(body: Node2D) -> void:
	if body is CharacterBase or body is Arqueiro :
		alvo = body

func _on_area_perseguicao_body_exited(_body: Node2D) -> void:
	if _body == alvo:
		alvo = null

# ======================================================
#		Ataque
# ======================================================

func atacar() -> void:
	pode_atacar = false
	anim.play("ataque")
	tempo_entre_ataques.start()

func _on_tempo_entre_ataques_timeout() -> void:
	pode_atacar = true

func _on_area_ataque_body_entered(_body: Node2D) -> void:
	if _body is CharacterBase or _body is Arqueiro:
		_body.update_vida([dano_padrao, dano_critico])

func _on_animacao_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dano":
		tomando_dano = false
		
		if alvo and global_position.distance_to(alvo.global_position) > distancia_ataque:
			anim.play("andando")
		else:
			anim.play("idle")
		return
		
	if anim_name == "ataque":
		anim.play("idle")

# ======================================================
#		Atualizando vida
# ======================================================

func update_vida(escala_dano: Array, fonte: Node2D = null) -> void: # [20,40]
	if morto:
		return
		
	vida -= randi_range(
		escala_dano[0], #20
		escala_dano[1] #40
	)
	
	if fonte != null:
		alvo = fonte
		perseguir_forcado = true
	
	if vida <= 0:
		morto = true
		morreu.emit()
		anim.play("morte")
		await anim.animation_finished
		spaw_ouro()
		queue_free()
		return
	
	tomando_dano = true
	anim.play("dano")

# ======================================================
#		Spawn de itens
# ======================================================

func spaw_ouro() -> void:
	var quant_ouro: int = randi_range(ouro_min, ouro_max)
	for i in quant_ouro:
		var ouro: Coletaveis = OURO_COLETAVEL.instantiate()
		ouro.global_position = global_position + Vector2(
			randi_range(-32, 32), randi_range(-32, 32)
		)
	
		get_parent().call_deferred("add_child", ouro)
