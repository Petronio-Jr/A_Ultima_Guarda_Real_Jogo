extends StaticBody2D

@export var chefe: BOSS
@export var colisao: CollisionShape2D

func _ready() -> void:
	chefe.boss_morreu.connect(_on_boss_morreu)

func _on_boss_morreu() -> void:
	colisao.set_deferred("disabled", true)
