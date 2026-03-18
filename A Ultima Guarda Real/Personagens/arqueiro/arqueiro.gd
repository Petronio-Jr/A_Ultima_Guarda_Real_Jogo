extends CharacterBody2D
class_name Arqueiro

var morto: bool = false

signal morreu

@onready var sprite: Sprite2D = get_node("Textura")
@onready var anim: AnimationPlayer = get_node("Animacao")
@onready var braco: Node2D = get_node("braco")

@export_category("Variaveis")
@export var velocidade: float = 256.0

@export_category("Objetos")
@export var poeira: CPUParticles2D

@export var area_colisao: CollisionShape2D

@export var quant_ouro: int = 0
@export var quant_madeira: int = 0

var cont: int = 1

# ======================================================
#		Sinal pra barra de vida do HUD
# ======================================================

signal vida_mudou()
@export var vida: float = 100.0 :
	set(value):
		vida = value

func _physics_process(_delta: float) -> void:
	
	if morto:
		velocity = Vector2.ZERO
		return
		
	if not is_in_group("player_active"):
		return
		
	movimentos()
	move_and_slide()
	animacao()
	braco.animacao(pega_direcao(), pega_posicao_mouse(), false)

# ======================================================
#		Funções básicas
# ======================================================

func movimentos() ->void:
	var direcao = Vector2.ZERO
	direcao.x = Input.get_action_strength("direita") - Input.get_action_strength("esquerda")
	direcao.y = Input.get_action_strength("baixo") - Input.get_action_strength("cima")
	direcao = direcao.normalized()
	velocity = direcao * velocidade

func animacao() -> void:
	if pega_direcao().x > 0:
		sprite.flip_h = false
	if pega_direcao().x < 0:
		sprite.flip_h = true
		
	if velocity != Vector2.ZERO:
		anim.play("andando")
		poeira.emitting = true
	else:
		anim.play("idle")
		poeira.emitting = false

func _ready():
	add_to_group("Character")

# ======================================================
#		A flecha vai na direção do mouse
# ======================================================

func pega_direcao() -> Vector2:
	return global_position.direction_to(pega_posicao_mouse())
	
func pega_posicao_mouse() -> Vector2:
	return get_global_mouse_position()

# ======================================================
#		Mecanica pra ptrocar o personagem
# ======================================================

func set_as_active(active: bool) -> void:
	if active:
		add_to_group("player_active")
	else:
		remove_from_group("player_active")

# ======================================================
#		Atualizando a vida
# ======================================================

func update_vida(escala_dano: Array) -> void: # [20,40]
	if morto:
		velocity = Vector2.ZERO
		return
		
	vida -= randi_range(
		escala_dano[0], #20
		escala_dano[1] #40
	)
	vida_mudou.emit()
	
	if vida <= 0:
		morto = true
		braco.visible = false
		braco.pode_atacar = false
		velocity = Vector2.ZERO
		area_colisao.disabled = true

		anim.stop()
		anim.play("morte")

		emit_signal("morreu")
		return

# ======================================================
#		Mecanica de reviver e curar
# ======================================================

signal reviveu

func reviver():
	morto = false
	vida = 100
	vida_mudou.emit()
	
	braco.visible = true
	braco.pode_atacar = true
	area_colisao.disabled = false
	
	anim.stop()
	anim.play("idle")
	
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
