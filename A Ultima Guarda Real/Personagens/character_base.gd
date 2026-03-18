extends CharacterBody2D
class_name CharacterBase

var pode_atacar: bool = true

var atacando: bool = false
var bloqueando: bool = false

var nome_animacao_ataque: String = ""
var morto: bool = false

signal morreu

@export_category("Variaveis")
@export var velocidade: float = 250.0
@export var nome_ataque_1: String = ""
@export var nome_ataque_2: String = ""
@export var dano_padrao: int = 20
@export var dano_critico: int = 40
@export var poeira: CPUParticles2D

@export_category("Objetos")
@export var sprite : Sprite2D
@export var anim: AnimationPlayer
@export var area_colisao: CollisionShape2D
@export var area_colisao_ataque: CollisionShape2D

@export var quant_ouro: int = 0
@export var quant_madeira: int = 0

var cont: int = 1

# ======================================================
#		Sinal pra barra de vida do HUD
# ======================================================
signal vida_mudou()
@export var vida: float = 100.0


func _physics_process(_delta: float) -> void:
	
	if morto:
		velocity = Vector2.ZERO
		return
	
	if not is_in_group("player_active"):
		return
		
	bloqueando = Input.is_action_pressed("defesa") and pode_atacar
	
	if bloqueando:
		velocity = Vector2.ZERO
		anim.play("guarda")
		return
			 
	if atacando:
		return
		
	movimentos()
	checar_ataque()
	animacao()

# ======================================================
#		Funções básicas
# ======================================================

func movimentos() -> void:
	var direcao: Vector2 = Input.get_vector("esquerda","direita","cima","baixo")
	
	poeira.emitting = false
	if direcao:
		poeira.emitting = true
		
	velocity = direcao * velocidade
	move_and_slide()

func animacao() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
		area_colisao_ataque.position.x = 47.5
		
	if velocity.x < 0:
		sprite.flip_h = true
		area_colisao_ataque.position.x = -47.5
		
	if atacando:
		anim.play(nome_animacao_ataque)
		return
	
	if Input.is_action_pressed("defesa") and pode_atacar:
		anim.play("guarda")
		bloqueando = true
		return
		
	if velocity:
		anim.play("andando")
		return
	
	anim.play("idle")

# ======================================================
#		Ataque
# ======================================================

func checar_ataque() -> void:
	if Input.is_action_just_pressed("ataque") and pode_atacar:
		iniciar_ataque(nome_ataque_1)
	elif Input.is_action_just_pressed("contra_ataque") and pode_atacar:
		iniciar_ataque(nome_ataque_2)

func iniciar_ataque(anim_name: String) -> void:
	pode_atacar = false
	atacando = true
	nome_animacao_ataque = anim_name
	anim.play(anim_name)

func _on_animacao_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "ataque_1" or _anim_name == "ataque_2":
		atacando = false
		pode_atacar = true

# ======================================================
#		Atualizando a vida
# ======================================================

func update_vida(escala_dano: Array) -> void: # [20,40]
	if morto:
		velocity = Vector2.ZERO
		return
	
	var dano: int
	
	if bloqueando:
		dano = randi_range(
			escala_dano[0] - 10, #20
			escala_dano[1] - 15 #40
		)
	else:
		dano = randi_range(
			escala_dano[0], #20
			escala_dano[1] #40
		) 
	
	vida -= dano
	
	vida = clamp(vida, 0, 100)
	
	vida_mudou.emit()
	
	if vida <= 0:
		morto = true
		velocity = Vector2.ZERO
		area_colisao.disabled = true
		
		anim.stop()
		anim.play("morte")
		
		emit_signal("morreu")
		return


func _on_area_ataque_body_entered(_body: Node2D) -> void:
	if _body is EnemyBase or _body is Ovelha or _body is Arvore_coletavel:
		_body.update_vida([dano_padrao, dano_critico])
	if _body is BOSS:
		_body.update_vida([dano_padrao, dano_critico], self, "espada")

# ======================================================
#		Mecanica de trocar personagem
# ======================================================

func set_as_active(active: bool) -> void:
	if active:
		add_to_group("player_active")
	else:
		remove_from_group("player_active")

# ======================================================
#		Mecanica de reviver e curar
# ======================================================

signal reviveu 

func reviver():
	morto = false
	vida = 100
	vida_mudou.emit()

	area_colisao.disabled = false
	anim.stop()
	anim.play("idle")

	pode_atacar = true
	atacando = false
	bloqueando = false

	reviveu.emit() 

func curar_total():
	vida = 100
	vida_mudou.emit()
	
# ======================================================
#		Mecanica pra ponte e caverna
# ======================================================

func update_collision_layer_mask(tipo: String) -> void:
	if tipo == "Entrando":
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, true)
		
		set_collision_mask_value(1, false)
		set_collision_mask_value(2, true)
		
	if tipo == "Saindo":
		set_collision_layer_value(1, true)
		set_collision_layer_value(2, false)
		
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, false)

# ======================================================
#		Mecanica de coletar os itens
# ======================================================

signal ouro_mudou(novo_valor: int)
signal madeira_mudou(novo_valor: int)

func coleta_item(tipo: String) -> void:
	match tipo:
		"ouro":
			quant_ouro += 20
			emit_signal("ouro_mudou", quant_ouro)
		"madeira":
			quant_madeira += 15
			emit_signal("madeira_mudou", quant_madeira)
		"carne":
			vida += 50
			vida = clamp(vida, 0, 100)
			vida_mudou.emit()

func gasta_item(tipo: String) -> void:
	if tipo == "madeira":
		emit_signal("madeira_mudou", quant_madeira)
	if tipo == "ouro":
		emit_signal("ouro_mudou", quant_ouro)
