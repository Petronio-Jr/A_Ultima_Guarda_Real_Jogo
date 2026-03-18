extends Area2D

@export var player: CharacterBase
@export var boss: BOSS
@export var game: Node2D

@export var tela_morte: Panel
@export var texto_morte: Sprite2D
@export var botao_restart_luta: Button

func _on_body_entered(_body: Node2D) -> void:
	if _body is CharacterBase:
		_body.morreu.connect(_on_body_morto_por_boss)

#===========================================================
#	Se o player morre pro boss
#===========================================================

func _on_body_morto_por_boss() -> void:
	restart_luta()

func restart_luta() -> void:
	tela_morte.visible = true
	texto_morte.visible = true
	botao_restart_luta.visible = true

func _on_botao_reinicio_boss_pressed() -> void:
	
	game.mortos -= 1
	
	player.reviver()
	player.global_position = Vector2(3584, 3433)
	
	boss.global_position = Vector2(5868.0, 3368.0)
	boss.vida = 1000
	boss.vida_mudou.emit()
	
	tela_morte.visible = false
	texto_morte.visible = false
	botao_restart_luta.visible = false

#===========================================================
#	Quando sai o respawn volta ao normal
#===========================================================

func _on_body_exited(_body: Node2D) -> void:
	if _body is CharacterBase and _body.morreu.is_connected(_on_body_morto_por_boss):
		_body.morreu.disconnect(_on_body_morto_por_boss)
