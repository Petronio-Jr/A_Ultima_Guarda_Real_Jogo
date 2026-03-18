extends Area2D
class_name SpawnArea

signal player_entrou
signal player_saiu

var bodies_dentro: Array[Node2D] = []

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBase or body is Arqueiro:
		bodies_dentro.append(body)
		player_entrou.emit()

func _on_body_exited(body: Node2D) -> void:
	if body in bodies_dentro:
		bodies_dentro.erase(body)
		player_saiu.emit()

func ativo_esta_dentro(ativo: Node2D) -> bool:
	return ativo in bodies_dentro
