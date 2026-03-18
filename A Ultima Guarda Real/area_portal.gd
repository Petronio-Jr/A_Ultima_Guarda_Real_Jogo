extends Area2D

@export var jogador: CharacterBase
@export var arqueiro: Arqueiro

func _on_body_entered(body: Node2D) -> void:
	if body == jogador or body == arqueiro:
		respawn_personagens()

#==============================================================================
# Função que garante que ambos os personagens estejam vivos pra BossFight
#==============================================================================

func respawn_personagens() -> void:
	
	jogador.global_position += Vector2(0, -50)
	arqueiro.global_position += Vector2(0, -50)
	
	await get_tree().process_frame
	
	jogador.global_position = Vector2(3584, 3433)
	arqueiro.global_position = Vector2(4700, 3250)
	
	if jogador.morto:
		jogador.reviver()
	else:
		jogador.curar_total()

	if arqueiro.morto:
		arqueiro.reviver()
	else:
		arqueiro.curar_total()
