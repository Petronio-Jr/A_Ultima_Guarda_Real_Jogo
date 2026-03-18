extends Node2D

var jogo_iniciado := false

var personagens: Array = []      # lista de personagens
var ativo_index: int = 0       # índice do personagem ativo

@export var mortos: int
var total_personagens: int

@export var guerreiro: CharacterBase
@export var arqueiro: Arqueiro
@export var timer_reset: Timer
@export var tela_morte: Panel
@export var texto_morte: Sprite2D
@export var botao_restart: Button

@export var menu: TextureRect
@export var botao_iniciar: Button
@export var botao_sair: Button
@export var botao_pausa: Button
@export var botao_despausa: Button

@export var tela_fim: Panel

@export var decoration: Node2D

signal kills_mudou
var kill_count: int = 0

@export var enemy_scene: PackedScene 
@export var spawn_timer: Timer
var area_spawn : Rect2

@export var spawn_area: SpawnArea

@export var max_inimigos := 10
var inimigos_ativos := 0

var pode_spawnar := false

func _ready() -> void:
	menu.visible = true
	jogo_iniciado = false

	botao_iniciar.pressed.connect(_on_botao_iniciar_pressed)

# ======================================================
#		Mecanicas do jogo
# ======================================================

func iniciar_jogo():
	
	conectar_inimigos_existentes()
	
	personagens.clear()
	seleciona_personagens(self)
	
	total_personagens = personagens.size()
	mortos = 0
	
	guerreiro.morreu.connect(_on_personagem_morreu)
	arqueiro.morreu.connect(_on_personagem_morreu)
	
	guerreiro.reviveu.connect(_on_personagem_reviveu)
	arqueiro.reviveu.connect(_on_personagem_reviveu)
	
	if personagens.size() > 0:
		personagens[ativo_index].set_as_active(true)

	area_spawn = Rect2(Vector2(0,0), get_viewport_rect().size)
	spawn_timer.start()

# ======================================================
#		Inimigos
# ======================================================

func conectar_inimigos_existentes() -> void:
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy is EnemyBase:
			enemy.morreu.connect(_on_enemy_morreu)

func _on_enemy_spawn_timer_timeout() -> void:
	if inimigos_ativos >= max_inimigos:
		return
	var ativo = personagens[ativo_index]
	if not spawn_area.ativo_esta_dentro(ativo):
		return
	spawn_inimigo()

func spawn_inimigo() -> void:
	var player_pos = personagens[ativo_index].global_position
	var spawn_position = player_pos + Vector2(
		randf_range(-700, 700),
		randf_range(-400, 400)
	)
	inimigos_ativos += 1
	
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.global_position = spawn_position
	decoration.add_child(enemy_instance)
	
	enemy_instance.morreu.connect(_on_enemy_morreu)

func _on_enemy_morreu() -> void:
	inimigos_ativos -= 1
	kill_count += 1
	kills_mudou.emit(kill_count)

# ======================================================
#		Troca de personagens
# ======================================================

func seleciona_personagens(node: Node) -> void:
	for child in node.get_children():
		if child is CharacterBase or child is Arqueiro:
			personagens.append(child)
		
		seleciona_personagens(child)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("trocar_personagem"):
		troca_personagem()

func troca_personagem() -> void:
	if personagens.size() <= 1:
		return
		
	# Desativa o personagem atual e sua câmera
	personagens[ativo_index].set_as_active(false)
	desativar_camera(ativo_index)
	# Vai para o próximo personagem
	ativo_index = (ativo_index + 1) % personagens.size()
	# Ativa o novo personagem e sua câmera
	personagens[ativo_index].set_as_active(true)
	ativar_camera(ativo_index)

# Função para ativar a câmera do personagem ativo
func ativar_camera(index: int) -> void:
	var camera = personagens[index].get_node("Camera2D")
	camera.make_current()  

# Função para desativar a câmera do personagem anterior
func desativar_camera(index: int) -> void:
	var _camera = personagens[index].get_node("Camera2D")

# ======================================================
#		Conferindo quantos personagens mortos
# ======================================================

func _on_personagem_reviveu() -> void:
	mortos -= 1

func _on_personagem_morreu() -> void:
	mortos += 1
	if mortos >= total_personagens:
		timer_reset.start()

# ======================================================
#		Botões apertaveis 
# ======================================================

# INICIAR JOGO
func _on_botao_iniciar_pressed() -> void:
	menu.visible = false
	jogo_iniciado = true
	botao_pausa.visible = true
	iniciar_jogo()

# TELA DE MORTE
func _on_timer_reset_timeout() -> void:
		tela_morte.visible = true
		texto_morte.visible = true
		botao_restart.visible = true

# BOTÃO DE RESTART
func _on_button_pressed() -> void:
	restart()

func restart() -> void:
	get_tree().reload_current_scene()

# BOTÃO DE SAIR
func _on_botao_sair_pressed() -> void:
	get_tree().quit()

# BOTÃO DE PAUSE
func _on_pause_pressed() -> void:
	get_tree().paused = true
	botao_pausa.visible = false
	botao_despausa.visible = true
	
# BOTÃO DE DESPAUSE
func _on_unpause_pressed() -> void:
	get_tree().paused = false
	botao_pausa.visible = true
	botao_despausa.visible = false

# BOTÃO DE VOLTAR (FIM DE JOGO)
func _on_voltar_pressed() -> void:
	tela_fim.visible = false

# BOTÃO DE SAIR (FIM DE JOGO)
func _on_sair_pressed() -> void:
	get_tree().quit()
