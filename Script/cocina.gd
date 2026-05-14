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
				print("Ingrediente: ", ingrediente, " | Hechizo: ", hechizo_necesario)
		
		print("-----------------------------")
	else:
		print("Error: No hay un pedido activo en PedidoManager")

func verificar_ingrediente(nombre_ingrediente: String, hechizo: String):
	var pedido = PedidoManager.pedido_actual
	
	if pedido.is_empty(): 
		return

	if hechizo == "circulo":
		if listo_para_entregar:
			finalizar_pedido()
		else:
			print("Intentando finalizar con: circulo")
			print("Completados: ", ingredientes_completados)
			print("Necesarios: ", pedido["ingredientes"].keys())
			print("Todavia faltan ingredientes")
		return

	if pedido["ingredientes"].has(nombre_ingrediente):
		var hechizo_necesario = pedido["ingredientes"][nombre_ingrediente]
		
		if hechizo == hechizo_necesario:
			if nombre_ingrediente not in ingredientes_completados:
				ingredientes_completados.append(nombre_ingrediente)
				print(nombre_ingrediente, " CORRECTO")
			verificar_progreso()
		else:
			print("Hechizo INCORRECTO para ", nombre_ingrediente, ". Usaste: ", hechizo, " | Necesitas: ", hechizo_necesario)

func verificar_progreso():
	var pedido = PedidoManager.pedido_actual
	var necesarios = pedido["ingredientes"].keys()
	
	var todos_listos = true
	for ing in necesarios:
		if ing not in ingredientes_completados:
			todos_listos = false
			break
			
	if todos_listos:
		listo_para_entregar = true
		print("¡TODOS LOS INGREDIENTES LISTOS! Dibuja un circulo para entregar.")

func finalizar_pedido():
	var pedido = PedidoManager.pedido_actual
	var paciencia = pedido.get("paciencia_actual", 100)

	if paciencia >= 70:
		PedidoManager.resultado_cliente = "feliz"
	elif paciencia >= 35:
		PedidoManager.resultado_cliente = "medio"
	else:
		PedidoManager.resultado_cliente = "enojado"

	PedidoManager.pedido_completado = true
	get_tree().change_scene_to_file("res://Escenas/cliente.tscn")
