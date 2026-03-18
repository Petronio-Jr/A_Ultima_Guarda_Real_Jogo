extends CharacterBody2D
class_name BOSS

const PARTICULAS_HIT: PackedScene = preload("res://A Ultima Guarda Real/efeitos/hit.tscn")
const OURO_COLETAVEL: PackedScene = preload("res://A Ultima Guarda Real/Coletaveis/ouro.tscn")

var morto = false
signal boss_morreu

var pode_atacar: bool = true
var tomando_dano: bool = false
var perseguir_forcado: bool = false

var dano_flecha_acumulado := 0
var nocauteado: bool = false

@export_category("Variaveis")
@export var ouro_drop: int = 50
@export var velocidade: float = 200.0
@export var dano_padrao: float = 30.0
@export var dano_critico: float = 50.0
@export var poeira: CPUParticles2D
@export var tempo_nocauteado: Timer

@export var distancia_x: float = 350
@export var distancia_y: float = 100

var alvo: Node2D = null

@export_category("Objetos")
@export var anim: AnimationPlayer
@export var sprite: Sprite2D
@export var area_colisao_flecha: CollisionShape2D
@export var area_colisao_espada: CollisionShape2D
@export var area_colisao_ataque: CollisionShape2D
@export var tempo_entre_ataques: Timer 
@export var barra_vida: ProgressBar
@export var capa_barra_vida: TextureRect
@export var nome_barra_vida: Label

signal vida_mudou()
@export var vida: int = 1000

func _ready() -> void:
	add_to_group("Enemies")
	tempo_entre_ataques.connect("timeout", Callable(self, "_on_tempo_entre_ataques_timeout"))

func _physics_process(_delta: float) -> void:
	if morto:
		return
		
	if tomando_dano:
		barra_vida.visible = true
		capa_barra_vida.visible = true
		nome_barra_vida.visible = true
		velocity = Vector2.ZERO
		return
		
	if perseguir_forcado or alvo:
		perseguicao(alvo)
	else:
		velocity = Vector2.ZERO
	
	if velocity.x < 0:
		sprite.flip_h = false
		area_colisao_ataque.position.x = -202.0
		
	if velocity.x > 0:
		sprite.flip_h = true
		area_colisao_ataque.position.x = 240.0
		
	move_and_slide()

# ======================================================
#		Mecanica pra perseguir o guerreiro
# ======================================================

func perseguicao(alvo: Node2D) -> void:
	if not alvo:
		return
		
	var dx = abs(alvo.global_position.x - global_position.x)
	var dy = abs(alvo.global_position.y - global_position.y)
	
	# Se está dentro do alcance X e Y
	if dx <= distancia_x and dy <= distancia_y:
		# Para de se mover e ataca
		velocity = Vector2.ZERO
		poeira.emitting = false
		
		if pode_atacar:
			atacar()
	else:
		# Ainda está longe → persegue
		var direcao: Vector2 = (alvo.global_position - global_position).normalized()
		velocity = direcao * velocidade
		anim.play("andando")
		poeira.emitting = true

func _on_area_perseguicao_body_entered(body: Node2D) -> void:
	if body is CharacterBase:
		alvo = body


# ======================================================
#		Função de ataque
# ======================================================

func atacar() -> void:
	pode_atacar = false
	anim.play("ataque_1")
	tempo_entre_ataques.start()

func _on_tempo_entre_ataques_timeout() -> void:
	pode_atacar = true

func _on_area_ataque_body_entered(_body: Node2D) -> void:
	if _body is CharacterBase or _body is Ovelha:
		_body.update_vida([dano_padrao, dano_critico])

func _on_animacao_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dano":
		tomando_dano = false
		
		if alvo and global_position.distance_to(alvo.global_position) > distancia_x:
			anim.play("andando")
		else:
			anim.play("idle")
		return
		
	if not morto:
		if anim_name == "ataque":
			anim.play("idle")

# ======================================================
#		Atualizando a vida
# ======================================================

func update_vida(escala_dano: Array, fonte: Node2D = null, tipo: String = "") -> void:
	if morto:
		return

	if tipo == "flecha" and nocauteado:
		return  
	
	if tipo == "espada" and not nocauteado:
		return 
	
	var dano : int
	
	if tipo == "flecha":
		dano = randi_range(escala_dano[0] - 10, escala_dano[1] - 15)
		anim.play("dano")
	else:
		dano = randi_range(escala_dano[0] - 10, escala_dano[1] - 10)
		spawn_particulas()
	
	vida -= dano
	vida_mudou.emit()
	
	if fonte != null:
		alvo = fonte
		perseguir_forcado = true
	
	if vida <= 0:
		morto = true
		anim.play("morte")
		boss_morreu.emit()
		await anim.animation_finished
		spaw_ouro()
		barra_vida.visible = false
		capa_barra_vida.visible = false
		nome_barra_vida.visible = false
		queue_free()
		return
	
	tomando_dano = true
	
	if tipo == "flecha":
		dano_flecha_acumulado += dano
		if dano_flecha_acumulado >= 60:
			entrar_noucaute()

func entrar_noucaute() -> void:
	nocauteado = true
	dano_flecha_acumulado = 0
	
	velocity = Vector2.ZERO
	pode_atacar = false
	tomando_dano = true
	
	area_colisao_flecha.set_deferred("disabled", true)
	
	area_colisao_espada.set_deferred("disabled", false)
	
	anim.play("nocauteado")
	tempo_nocauteado.start()

func _on_timer_nocauteado_timeout() -> void:
	nocauteado = false
	tomando_dano = false
	pode_atacar = true

	area_colisao_flecha.set_deferred("disabled", false)

	area_colisao_espada.set_deferred("disabled", true)

	if not morto:
		anim.play("idle")
		await anim.animation_finished

# ======================================================
#		Spawn de itens e particulas
# ======================================================

func spawn_particulas() -> void:
	var hit = PARTICULAS_HIT.instantiate()
	get_parent().add_child(hit) 
	hit.global_position = global_position
	hit.z_index = 5
	hit.modulate = Color.RED
	hit.emitting = true

func spaw_ouro() -> void:
	var quant_ouro: int = ouro_drop
	for i in quant_ouro:
		var ouro: Coletaveis = OURO_COLETAVEL.instantiate()
		ouro.global_position = global_position + Vector2(
			randi_range(-128, 128), randi_range(-128, 128)
		)
		get_parent().call_deferred("add_child", ouro)
