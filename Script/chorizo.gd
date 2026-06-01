extends Area2D

@export var nombre_ingrediente: String = ""
@export var velocidad: float = 180.0
@export var limite_izq: float = 6.0
@export var limite_der: float = 921.0
@export var limite_arriba: float = 39.0
@export var limite_abajo: float = 629.0
@export var posicion_final: Vector2 = Vector2(600, 680)

@onready var sprite = $Sprite2D

var direccion: Vector2 = Vector2.ZERO
var terminado: bool = false

var congelado := false
var cooldown_congelacion := false

func _ready():
	randomize()

	add_to_group("ingredientes")

	direccion = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized()

	if direccion == Vector2.ZERO:
		direccion = Vector2(1, 1).normalized()

func _process(delta):

	if terminado:
		return

	if congelado:
		return

	position += direccion * velocidad * delta

	if position.x <= limite_izq or position.x >= limite_der:
		direccion.x *= -1

	if position.y <= limite_arriba or position.y >= limite_abajo:
		direccion.y *= -1

func aplicar_hechizo(paso: String):
	var cocina = get_tree().current_scene

	if cocina.has_method("verificar_ingrediente"):
		cocina.verificar_ingrediente(nombre_ingrediente, paso)

func correcto():
	terminado = true

	sprite.modulate = Color.GREEN

	var tween = create_tween()
	tween.tween_property(
		self,
		"position",
		posicion_final,
		0.5
	)

func incorrecto():
	sprite.modulate = Color.RED

	await get_tree().create_timer(0.4).timeout

	if not terminado:
		sprite.modulate = Color.WHITE

func _on_mouse_entered():

	if terminado or congelado or cooldown_congelacion:
		return

	congelado = true
	cooldown_congelacion = true

	sprite.scale = Vector2(1.15, 1.15)

	await get_tree().create_timer(1.0).timeout

	congelado = false
	sprite.scale = Vector2.ONE

	await get_tree().create_timer(2.0).timeout

	cooldown_congelacion = false
