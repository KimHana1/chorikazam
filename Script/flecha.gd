extends Area2D

@export var velocidad := 500.0

var activa := false
var direccion := 1

var altura_fija := 604.0

@onready var marker_izq = \
get_parent().get_node("MarkerIzquierdo")

@onready var marker_der = \
get_parent().get_node("MarkerDerecho")

func _ready():

	print("=== FLECHA READY ===")

	print(
		"Marker Izq X = ",
		marker_izq.position.x
	)

	print(
		"Marker Der X = ",
		marker_der.position.x
	)

func _process(delta):

	if not activa:
		return

	position.y = altura_fija

	position.x += \
	velocidad * direccion * delta

	if position.x >= marker_der.position.x:

		position.x = \
		marker_der.position.x

		direccion = -1

		print("REBOTE DERECHO")

	if position.x <= marker_izq.position.x:

		position.x = \
		marker_izq.position.x

		direccion = 1

		print("REBOTE IZQUIERDO")

func activar():

	position.x = \
	marker_izq.position.x

	position.y = \
	altura_fija

	direccion = 1

	activa = true

	print("flecha desactivada")

func desactivar():

	activa = false

	print("Flecha activa")

func obtener_objetivo():

	var areas = \
	get_overlapping_areas()

	if areas.is_empty():
		return null

	return areas[0]

func _al_entrar_area(area):

	print(
		"toca a: ",
		area.name
	)
