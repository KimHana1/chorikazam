extends Control

var ingredientes_completados: Array[String] = []
var listo_para_entregar: bool = false

func _ready():
	ingredientes_completados.clear()
	listo_para_entregar = false

	var pedido = PedidoManager.pedido_actual

	if not pedido.is_empty():
		print("--- NUEVO PEDIDO RECIBIDO ---")
		print("Plato: ", pedido["nombre"])

		if pedido.has("ingredientes"):
			for ingrediente in pedido["ingredientes"]:
				var hechizo_necesario = pedido["ingredientes"][ingrediente]

				print(
					"Ingrediente: ",
					ingrediente,
					" | Hechizo: ",
					hechizo_necesario
				)

		print("-----------------------------")
	else:
		print("Error: No hay un pedido activo en PedidoManager")

func verificar_ingrediente(nombre_ingrediente: String, hechizo: String):
	var pedido = PedidoManager.pedido_actual

	print("Llegó a cocina")
	print("Ingrediente tocado: ", nombre_ingrediente)
	print("Hechizo usado: ", hechizo)

	if pedido.is_empty():
		print("No hay pedido")
		return

	if hechizo == "circulo":
		if listo_para_entregar:
			print("Pedido entregado")
			finalizar_pedido()
		else:
			print("Todavia faltan ingredientes")
			print("Completados: ", ingredientes_completados)
			print("Necesarios: ", pedido["ingredientes"].keys())

		return

	if not pedido.has("ingredientes"):
		print("El pedido no tiene ingredientes")
		return

	if not pedido["ingredientes"].has(nombre_ingrediente):
		print("Ingrediente no pertenece al pedido")
		return

	var hechizo_necesario = pedido["ingredientes"][nombre_ingrediente]

	print("Necesita: ", hechizo_necesario)

	if hechizo == hechizo_necesario:
		if nombre_ingrediente not in ingredientes_completados:
			ingredientes_completados.append(nombre_ingrediente)

			print(nombre_ingrediente, " CORRECTO")

		verificar_progreso()
	else:
		print(
			"Hechizo INCORRECTO para ",
			nombre_ingrediente,
			" | Usaste: ",
			hechizo,
			" | Necesitas: ",
			hechizo_necesario
		)

func verificar_progreso():
	var pedido = PedidoManager.pedido_actual

	if pedido.is_empty():
		return

	var necesarios = pedido["ingredientes"].keys()

	print("Ingredientes completados: ", ingredientes_completados)
	print("Ingredientes necesarios: ", necesarios)

	var todos_listos = true

	for ing in necesarios:
		if ing not in ingredientes_completados:
			todos_listos = false
			print("Falta ingrediente: ", ing)

	if todos_listos:
		listo_para_entregar = true

		print("¡TODOS LOS INGREDIENTES LISTOS!")
		print("Dibuja un circulo para entregar")

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
