extends Area2D

var direcao: Vector2 = Vector2.ZERO
var dano_padrao: float = 15.0
var dano_critico: float = 25.0

var atirador: Node2D = null 

func set_shooter(player: Node2D) -> void:
	atirador = player
	
func _ready() -> void:
	var angulo = direcao.angle()
	rotation_degrees = rad_to_deg(angulo)

func setup(dir: Vector2) -> void:
	direcao = dir.normalized()
	rotation = direcao.angle()

func _physics_process(delta: float) -> void:
	translate(direcao * delta * 512.0)

func _on_body_entered(_body: Node2D) -> void:
	if _body is EnemyBase:
		_body.update_vida([dano_padrao, dano_critico], atirador)
		queue_free() 
	elif _body is Ovelha:
		_body.update_vida([dano_padrao, dano_critico])
		queue_free() 
	elif _body is BOSS:
		_body.update_vida([dano_padrao, dano_critico], null, "flecha")
		queue_free() 
		
