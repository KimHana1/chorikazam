extends Control

@onready var slots_contenedor = $Slots
<<<<<<< HEAD

@onready var ingredientes_nodo = get_tree().current_scene.find_child(
	"Ingredientes",
	true,
	false
)

func _ready():

	await get_tree().process_frame

	randomizar_botones()

func randomizar_botones():

	var posiciones_slots = obtener_posiciones_de_slots()

	if posiciones_slots.is_empty():
		print("No hay slots")
		return

	if ingredientes_nodo == null:
		print("No encontre Ingredientes")
		return

	if ingredientes_nodo.has_method("ubicar_todos_los_botones"):

		ingredientes_nodo.ubicar_todos_los_botones(
			posiciones_slots
		)

func reubicar_un_solo_boton(
	boton_cliqueado: Area2D
):

	var posiciones_slots = obtener_posiciones_de_slots()

	if posiciones_slots.is_empty():
		return

	if ingredientes_nodo == null:
		return

	if ingredientes_nodo.has_method(
		"mover_boton_a_slot_vacio"
	):

		ingredientes_nodo.mover_boton_a_slot_vacio(
			boton_cliqueado,
			posiciones_slots
		)

func obtener_posiciones_de_slots() -> Array[Vector2]:

	var posiciones: Array[Vector2] = []

	for slot in slots_contenedor.get_children():

		if slot is Marker2D:

			posiciones.append(
				slot.global_position
			)

=======
@onready var ingredientes_nodo = $Ingredientes 

func _ready():
	await get_tree().process_frame
	randomizar_botones()

func randomizar_botones():
	var posiciones_slots = obtener_posiciones_de_slots()
	if posiciones_slots.is_empty(): return

	if ingredientes_nodo and ingredientes_nodo.has_method("ubicar_todos_los_botones"):
		ingredientes_nodo.ubicar_todos_los_botones(posiciones_slots)

func reubicar_un_solo_boton(boton_cliqueado: Area2D):
	var posiciones_slots = obtener_posiciones_de_slots()
	if posiciones_slots.is_empty(): return

	if ingredientes_nodo and ingredientes_nodo.has_method("mover_boton_a_slot_vacio"):
		ingredientes_nodo.mover_boton_a_slot_vacio(boton_cliqueado, posiciones_slots)


func obtener_posiciones_de_slots() -> Array[Vector2]:
	var posiciones: Array[Vector2] = []
	for slot in slots_contenedor.get_children():
		if slot is Marker2D:
			posiciones.append(slot.global_position)
	
	if posiciones.is_empty():
		print("error")
>>>>>>> 2d643843303f7eeb55e10825c0207415adcb00a4
	return posiciones
