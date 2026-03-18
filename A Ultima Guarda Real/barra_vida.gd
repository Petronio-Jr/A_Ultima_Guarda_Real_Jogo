extends ProgressBar

@export var alvo: Node2D

func _ready() -> void:
	alvo.vida_mudou.connect(atualiza_vida)
	atualiza_vida()

func atualiza_vida():
	value = alvo.vida
