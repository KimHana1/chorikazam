extends Control

var ingredientes_completados: Array[String] = []

func _ready():
	ingredientes_completados.clear()

	if PedidoManager.pedido_actual.is_empty():
		print("No hay pedido activo")
	else:
		print("Pedido activo: ", PedidoManager.pedido_actual["nombre"])
		print("Ingredientes pedidos: ", PedidoManager.pedido_actual["ingredientes"])

func verificar_ingrediente(nombre_ingrediente: String, hechizo: String):
	var pedido = PedidoManager.pedido_actual

	if pedido.is_empty():
		print("No hay pedido")
		return

	if not pedido.has("ingredientes"):
		print("El pedido no tiene ingredientes")
		return

	if not pedido["ingredientes"].has(nombre_ingrediente):
		print("Ingrediente incorrecto: ", nombre_ingrediente)
		return

	var hechizo_necesario = pedido["ingredientes"][nombre_ingrediente]

	if hechizo == hechizo_necesario:
		if nombre_ingrediente not in ingredientes_completados:
			ingredientes_completados.append(nombre_ingrediente)

		print(nombre_ingrediente, " correcto")
		print("Completados: ", ingredientes_completados)
		verificar_pedido_completo()
	else:
		print("Hechizo incorrecto para ", nombre_ingrediente)
		print("Necesitaba: ", hechizo_necesario)
		print("Hiciste: ", hechizo)

func verificar_pedido_completo():
	var pedido = PedidoManager.pedido_actual
	var ingredientes_necesarios = pedido["ingredientes"].keys()

	for ingrediente in ingredientes_necesarios:
		if ingrediente not in ingredientes_completados:
			print("Falta: ", ingrediente)
			return

	var paciencia = pedido.get("paciencia_actual", pedido.get("paciencia", 100))

	if paciencia >= 70:
		PedidoManager.resultado_cliente = "feliz"
	elif paciencia >= 35:
		PedidoManager.resultado_cliente = "medio"
	else:
		PedidoManager.resultado_cliente = "enojado"

	PedidoManager.pedido_completado = true

	print("Pedido completado")
	print("Resultado cliente: ", PedidoManager.resultado_cliente)

	get_tree().change_scene_to_file("res://Escenas/cliente.tscn")
