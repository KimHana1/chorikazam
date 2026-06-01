extends Control

var pasos_completados = {}
var listo_para_entregar: bool = false

var ticket_scene = preload("res://Escenas/ticket.tscn")
var ticket_actual = null

func _ready():
	pasos_completados.clear()
	listo_para_entregar = false

	mostrar_ticket_chiquito()

	var pedido = PedidoManager.pedido_actual

	if pedido.is_empty():
		print("No hay pedido activo en PedidoManager")
		return

	print("Platillos")
	print("Plato: ", pedido["nombre"])

	if pedido.has("ingredientes"):
		for ingrediente in pedido["ingredientes"]:
			print("Ingrediente: ", ingrediente, " | Pasos: ", pedido["ingredientes"][ingrediente])

	print("-")

func mostrar_ticket_chiquito():
	if ticket_actual != null:
		return

	ticket_actual = ticket_scene.instantiate()
	get_tree().current_scene.add_child(ticket_actual)

	if ticket_actual.has_method("cargar_ticket"):
		ticket_actual.cargar_ticket(PedidoManager.pedido_actual)

	if ticket_actual.has_method("mostrar_mini"):
		ticket_actual.mostrar_mini()

func verificar_ingrediente(nombre_ingrediente: String, paso: String):
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
	if listo_para_entregar:
		finalizar_pedido()
	else:
		print("Pedido entregado mal")
		PedidoManager.resultado_cliente = "enojado"
		PedidoManager.pedido_completado = true
		get_tree().change_scene_to_file("res://Escenas/cliente.tscn")

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
	var paciencia = pedido.get("paciencia_actual", 100)

	print("Paciencia final: ", paciencia)

	if paciencia >= 70:
		PedidoManager.resultado_cliente = "feliz"
	elif paciencia >= 35:
		PedidoManager.resultado_cliente = "medio"
	else:
		PedidoManager.resultado_cliente = "enojado"

	print("Resultado cliente: ", PedidoManager.resultado_cliente)

	PedidoManager.pedido_completado = true
	get_tree().change_scene_to_file("res://Escenas/cliente.tscn")

func obtener_nodo_ingrediente(nombre_ingrediente: String):
	var nombre_nodo = nombre_ingrediente.capitalize()
	return get_node_or_null(nombre_nodo)

func marcar_ingrediente_correcto(nombre_ingrediente: String):
	var nodo = obtener_nodo_ingrediente(nombre_ingrediente)

	if nodo != null and nodo.has_method("correcto"):
		nodo.correcto()

func marcar_ingrediente_incorrecto(nombre_ingrediente: String):
	var nodo = obtener_nodo_ingrediente(nombre_ingrediente)

	if nodo != null and nodo.has_method("incorrecto"):
		nodo.incorrecto()
