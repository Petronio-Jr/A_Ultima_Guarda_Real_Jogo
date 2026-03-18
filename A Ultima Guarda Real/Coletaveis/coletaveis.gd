extends Area2D
class_name Coletaveis

@export var tipo: String = ""

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBase or body is Arqueiro:
		# Chama o método no jogador para coletar
		body.coleta_item(tipo)
		queue_free()
