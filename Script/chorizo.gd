extends Area2D

@export var nombre_ingrediente: String = ""
@export var velocidad: float = 180.0
@export var limite_izq: float = 1107.0
@export var limite_der: float = 1107
@export var limite_arriba: float = 133.0
@export var limite_abajo: float = 1016.0

@onready var sprite = $Sprite2D

var direccion: Vector2 = Vector2.ZERO
var terminado: bool = false
var congelado: bool = false
var puede_congelarse: bool = true

func _ready():
	add_to_group("ingredientes")
	input_pickable = true
	reiniciar_direccion_aleatoria()

func _process(delta):
	if terminado or congelado:
		return

	position += direccion * velocidad * delta

	if position.x <= limite_izq:
		direccion.x = abs(direccion.x)
	elif position.x >= limite_der:
		direccion.x = -abs(direccion.x)

	if position.y <= limite_arriba:
		direccion.y = abs(direccion.y)
	elif position.y >= limite_abajo:
		direccion.y = -abs(direccion.y)

func reiniciar_direccion_aleatoria():
	direccion = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized()

	if direccion == Vector2.ZERO:
		direccion = Vector2(1, 1).normalized()

func aplicar_hechizo(paso: String):
	var cocina = get_tree().current_scene

	if cocina.has_method("verificar_ingrediente"):
		cocina.verificar_ingrediente(nombre_ingrediente, paso)

func correcto():
	if terminado:
		return

	terminado = true
	congelado = true

	direccion = Vector2.ZERO
	velocidad = 0

	var cocina = get_tree().current_scene

	if cocina.has_method("mover_ingrediente_al_plato"):
		cocina.mover_ingrediente_al_plato(self, nombre_ingrediente)

	sprite.modulate = Color.GREEN

func incorrecto():
	if terminado:
		return

	sprite.modulate = Color.RED

	get_tree().create_timer(0.4).timeout.connect(func():
		if not terminado:
			sprite.modulate = Color.WHITE
	)

func _on_mouse_entered():
	if terminado or congelado:
		return

	if not puede_congelarse:
		return

	congelado = true
	puede_congelarse = false
	sprite.scale = Vector2(1.15, 1.15)

	get_tree().create_timer(1.0).timeout.connect(_on_descongelar)

func _on_descongelar():
	if terminado:
		return

	congelado = false
	sprite.scale = Vector2.ONE
	reiniciar_direccion_aleatoria()

	get_tree().create_timer(2.0).timeout.connect(_on_cooldown_terminado)

func _on_cooldown_terminado():
	puede_congelarse = true
