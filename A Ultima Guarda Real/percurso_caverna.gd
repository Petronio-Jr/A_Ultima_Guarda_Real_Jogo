extends Area2D
class_name Caverna

func _on_body_entered(_body: Node2D) -> void:
	if _body is CharacterBase or _body is Arqueiro:
		_body.update_collision_layer_mask("Entrando")
		_body.z_index = -1
		if _body is Arqueiro:
			_body.braco.pode_atacar = false

func _on_body_exited(_body: Node2D) -> void:
	if _body is CharacterBase or _body is Arqueiro:
		_body.update_collision_layer_mask("Saindo")
		_body.z_index = 0
		if _body is Arqueiro:
			_body.braco.pode_atacar = true
