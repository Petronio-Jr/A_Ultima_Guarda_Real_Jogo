extends Node2D
class_name Decoracao

@export_category("Variaveis")
@export var lista_texturas: Array[String]

func _ready() -> void:
	for children in get_children():
		if children is Sprite2D:
			children.texture = load(
				lista_texturas.pick_random()
			)
