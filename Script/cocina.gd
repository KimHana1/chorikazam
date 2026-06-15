extends Control

@onready var plato = $Plato
@onready var soga_contenedor = $soga/HBoxContainer

var ingredientes_en_plato := []
var escena_comercio = "res://Comercio/comer/EscenasComercio/Comercio.tscn"
var escena_cliente = "res://Escenas/cliente.tscn"

var pasos_completados = {}
var listo_para_entregar: bool = false

var ticket_scene = preload("res://Escenas/ticket.tscn")
var ticket_actual = null

var paciencia_actual: float = 100.0
var velocidad_paciencia: float = 1.0

func _ready():
	pasos_completados.clear()
	ingredientes_en_plato.clear()
	listo_para_entregar = false

	var pedido = PedidoManager.pedido_actual

	if pedido.is_empty():
		print("No hay pedido activo en PedidoManager")
		return

	if not hay_ingredientes_para_pedido():
		print("No tenes ingredientes suficientes")
		return

	paciencia_actual = pedido.get("paciencia_actual", pedido.get("paciencia", 100.0))
	PedidoManager.pedido_actual["paciencia_actual"] = paciencia_actual

	mostrar_ticket_chiquito()

	print("Platillos")
	print("Plato: ", pedido["nombre"])

	if pedido.has("ingredientes"):
		for ingrediente in pedido["ingredientes"]:
			print("Ingrediente: ", ingrediente, " | Pasos: ", pedido["ingredientes"][ingrediente])

	print("-")

func _process(delta):
	if paciencia_actual > 0:
		paciencia_actual -= velocidad_paciencia * delta
		paciencia_actual = max(paciencia_actual, 0)

		if not PedidoManager.pedido_actual.is_empty():
			PedidoManager.pedido_actual["paciencia_actual"] = paciencia_actual

		if ticket_actual != null and ticket_actual.has_method("actualizar_paciencia"):
			ticket_actual.actualizar_paciencia(paciencia_actual)

func hay_ingredientes_para_pedido() -> bool:
	var pedido = PedidoManager.pedido_actual

	if pedido.is_empty() or not pedido.has("ingredientes"):
		return false

	for ingrediente in pedido["ingredientes"].keys():
		var nombre = ingrediente.to_lower()

		if not Global.tiene_ingrediente(nombre, 1):
			print("Falta ingrediente: ", nombre)
			return false

	return true

func descontar_ingredientes_del_pedido():
	var pedido = PedidoManager.pedido_actual

	if pedido.is_empty() or not pedido.has("ingredientes"):
		return

	for ingrediente in pedido["ingredientes"].keys():
		var nombre = ingrediente.to_lower()
		Global.quitar_ingrediente(nombre, 1)

func mostrar_ticket_chiquito():

	if soga_contenedor == null:
		print("No encontre HBoxContainer")
		return

	for child in soga_contenedor.get_children():
		child.queue_free()

	for pedido in PedidoManager.pedidos_activos:

		var ticket = ticket_scene.instantiate()

		soga_contenedor.add_child(ticket)
		print("Ticket agregado")
		print(ticket)
		print(ticket.size)

		if ticket.has_method("cargar_ticket"):
			ticket.cargar_ticket(pedido)

func verificar_ingrediente(nombre_ingrediente: String, paso: String):
	nombre_ingrediente = nombre_ingrediente.to_lower()
	paso = paso.to_lower()

	if listo_para_entregar:
		print("La receta ya esta lista. Hace un circulo para emplatar.")
		return

	var pedido = PedidoManager.pedido_actual

	print("Llegó a cocina")
	print("Ingrediente tocado: ", nombre_ingrediente)
	print("Paso usado: ", paso)

	if pedido.is_empty():
		print("No hay pedido")
		return

	if not pedido.has("ingredientes"):
		print("El pedido no tiene ingredientes")
		return

	if not pedido["ingredientes"].has(nombre_ingrediente):
		print("Ingrediente no pertenece al pedido")
		marcar_ingrediente_incorrecto(nombre_ingrediente)
		return

	var pasos_necesarios = pedido["ingredientes"][nombre_ingrediente]

	if paso in pasos_necesarios:
		if not pasos_completados.has(nombre_ingrediente):
			pasos_completados[nombre_ingrediente] = []

		if paso not in pasos_completados[nombre_ingrediente]:
			pasos_completados[nombre_ingrediente].append(paso)
			print(nombre_ingrediente, " paso correcto: ", paso)

			if ingrediente_terminado(nombre_ingrediente):
				marcar_ingrediente_correcto(nombre_ingrediente)
				marcar_ok_ticket(nombre_ingrediente)

		verificar_progreso()
	else:
		print("Paso incorrecto para ", nombre_ingrediente)
		print("Usaste: ", paso)
		print("Necesitaba: ", pasos_necesarios)
		marcar_ingrediente_incorrecto(nombre_ingrediente)

func ingrediente_terminado(nombre_ingrediente: String) -> bool:
	nombre_ingrediente = nombre_ingrediente.to_lower()

	var pedido = PedidoManager.pedido_actual

	if pedido.is_empty():
		return false

	if not pedido["ingredientes"].has(nombre_ingrediente):
		return false

	if not pasos_completados.has(nombre_ingrediente):
		return false

	var pasos_necesarios = pedido["ingredientes"][nombre_ingrediente]

	for paso in pasos_necesarios:
		if paso not in pasos_completados[nombre_ingrediente]:
			return false

	return true

func marcar_ok_ticket(nombre_ingrediente: String):
	if ticket_actual == null:
		return

	if ticket_actual.has_method("marcar_ok"):
		ticket_actual.marcar_ok(nombre_ingrediente)

func intentar_finalizar_pedido():
	if listo_para_entregar and todos_en_plato():
		finalizar_pedido()
	else:
		print("Pedido entregado mal")
		print("Listo para entregar: ", listo_para_entregar)
		print("Ingredientes en plato: ", ingredientes_en_plato)

		PedidoManager.resultado_cliente = "enojado"
		PedidoManager.pedido_completado = true
		get_tree().change_scene_to_file(escena_cliente)

func todos_en_plato() -> bool:
	var pedido = PedidoManager.pedido_actual

	if pedido.is_empty() or not pedido.has("ingredientes"):
		return false

	for ingrediente in pedido["ingredientes"].keys():
		if ingrediente.to_lower() not in ingredientes_en_plato:
			return false

	return true

func verificar_progreso():
	var pedido = PedidoManager.pedido_actual

	if pedido.is_empty():
		return

	var todos_listos = true

	for ingrediente in pedido["ingredientes"]:
		var pasos_necesarios = pedido["ingredientes"][ingrediente]

		if not pasos_completados.has(ingrediente):
			todos_listos = false
			print("Falta ingrediente: ", ingrediente)
			continue

		for paso in pasos_necesarios:
			if paso not in pasos_completados[ingrediente]:
				todos_listos = false
				print("Falta paso: ", paso, " en ", ingrediente)

	if todos_listos:
		listo_para_entregar = true
		print("Listo. Dibuja un circulo para emplatar")

func finalizar_pedido():
	var pedido = PedidoManager.pedido_actual
	var paciencia = pedido.get("paciencia_actual", paciencia_actual)

	print("Paciencia final: ", paciencia)

	if paciencia >= 70:
		PedidoManager.resultado_cliente = "feliz"
	elif paciencia >= 35:
		PedidoManager.resultado_cliente = "medio"
	else:
		PedidoManager.resultado_cliente = "enojado"

	print("Resultado cliente: ", PedidoManager.resultado_cliente)

	descontar_ingredientes_del_pedido()

	PedidoManager.pedido_completado = true
	get_tree().change_scene_to_file(escena_cliente)

func obtener_nodo_ingrediente(nombre_ingrediente: String):
	nombre_ingrediente = nombre_ingrediente.to_lower()

	var nodo = get_node_or_null(nombre_ingrediente)
	if nodo != null:
		return nodo

	nodo = get_node_or_null(nombre_ingrediente.capitalize())
	if nodo != null:
		return nodo

	print("No encontre nodo ingrediente: ", nombre_ingrediente)
	return null

func marcar_ingrediente_correcto(nombre_ingrediente: String):
	var nodo = obtener_nodo_ingrediente(nombre_ingrediente)

	if nodo != null and nodo.has_method("correcto"):
		nodo.correcto()

func marcar_ingrediente_incorrecto(nombre_ingrediente: String):
	var nodo = obtener_nodo_ingrediente(nombre_ingrediente)

	if nodo != null and nodo.has_method("incorrecto"):
		nodo.incorrecto()

func mover_ingrediente_al_plato(ingrediente, nombre_ingrediente):
	nombre_ingrediente = nombre_ingrediente.to_lower()

	print("MOVIENDO AL PLATO: ", nombre_ingrediente)

	if plato == null:
		print("ERROR: no encontre el nodo Plato")
		return

	ingrediente.terminado = true
	ingrediente.congelado = true

	var offset = Vector2(
		randf_range(-30, 30),
		randf_range(-15, 15)
	)

	var tween = create_tween()
	tween.tween_property(
		ingrediente,
		"global_position",
		plato.global_position + offset,
		0.4
	)

	if nombre_ingrediente not in ingredientes_en_plato:
		ingredientes_en_plato.append(nombre_ingrediente)

	print("LISTO, fue al plato")

func _on_botoncompra_pressed() -> void:
	get_tree().change_scene_to_file(escena_comercio)

func _on_boton_atencion_pressed() -> void:
	get_tree().change_scene_to_file(escena_cliente)
