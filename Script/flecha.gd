extends Area2D

@export var velocidad := 500.0

<<<<<<< HEAD
var velocidad_base := 500.0
var activa := false
var direccion := 1
var altura_fija := 604.0

@onready var marker_izq = get_parent().get_node("MarkerIzquierdo")
@onready var marker_der = get_parent().get_node("MarkerDerecho")

func _ready():
	velocidad_base = velocidad
	desactivar()

func _process(delta):
=======
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

>>>>>>> 2d643843303f7eeb55e10825c0207415adcb00a4
	if not activa:
		return

	position.y = altura_fija
<<<<<<< HEAD
	position.x += velocidad * direccion * delta

	if position.x >= marker_der.position.x:
		position.x = marker_der.position.x
		direccion = -1

	if position.x <= marker_izq.position.x:
		position.x = marker_izq.position.x
		direccion = 1

func activar():
	position.x = marker_izq.position.x
	position.y = altura_fija
	direccion = 1
	velocidad = velocidad_base
	activa = true

func desactivar():
	activa = false

func obtener_objetivo():
	var areas = get_overlapping_areas()

	for area in areas:
		if "tipo_boton" in area:
			return area

	return null
=======

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
>>>>>>> 2d643843303f7eeb55e10825c0207415adcb00a4
