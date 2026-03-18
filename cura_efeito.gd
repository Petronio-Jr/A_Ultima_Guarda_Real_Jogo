extends Node2D
class_name CuraEfeito

@export var anim: AnimationPlayer

func _ready():
	anim.play("efeito_cura")
	await anim.animation_finished
	queue_free()
