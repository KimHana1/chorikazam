extends Area2D

@export var velocidad: float = 100.0
@export var limite_abajo: float = 750.0
@export var volver_arriba_y: float = -100.0
@export var ancho_pantalla: float = 1280.0

func _ready():
	add_to_group("ingredientes")
	randomize()
	position.x = randf_range(80, ancho_pantalla - 80)
	position.y = randf_range(-300, -50)

func _process(delta):
	position.y += velocidad * delta

	if position.y > limite_abajo:
		position.y = volver_arriba_y
		position.x = randf_range(80, ancho_pantalla - 80)

func pausar_movimiento():
	set_process(false)

func reanudar_movimiento():
	set_process(true)
