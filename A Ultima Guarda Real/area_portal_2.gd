extends Area2D

@export var jogador: CharacterBase
@export var arqueiro: Arqueiro

@export var tela_fim: Panel

func _on_body_entered(body: Node2D) -> void:
	tela_fim.visible = true
	if body is CharacterBase or body is Arqueiro:
		jogador.global_position = Vector2(1842.0, 624.0)
		arqueiro.global_position = Vector2(2006.0, 578.0)
