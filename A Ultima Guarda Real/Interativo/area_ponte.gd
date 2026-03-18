extends Area2D
class_name AreaPonte

func _on_body_entered(_body: Node2D) -> void:
	if _body is CharacterBase or _body is Arqueiro:
		_body.update_collision_layer_mask("Entrando")

func _on_body_exited(_body: Node2D) -> void:
	if _body is CharacterBase or _body is Arqueiro:
		_body.update_collision_layer_mask("Saindo")
