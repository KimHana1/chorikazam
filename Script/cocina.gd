extends Control

@onready var plato = $Plato
@onready var soga_nodo = $soga
@onready var visor_grande = $VisorTicketGrande
@onready var ticket_imagen = $VisorTicketGrande/ImagenTicket
@onready var paciencia_cliente = $VisorTicketGrande/PacienciaCliente
@onready var identificador_color = $VisorTicketGrande/IdentificadorColor
@onready var inventario = $"UI Inventario Global"

var ingrediente_actual_enfocado: Node = null

var ticket_scene = preload("res://Escenas/ticket.tscn")
var ingredientes_en_plato := []
var centro_emplatar: Vector2 = Vector2.ZERO
var line
var escena_comercio ="res://Comercio/comer/EscenasComercio/Comercio.tscn"
var escena_cliente = "res://Escenas/cliente.tscn"
var escena_final="res://Escenas/entrega.tscn"
var pasos_completados = {}
var listo_para_entregar: bool = false
var estilo_barra = StyleBoxFlat.new()
var paciencia_actual: float = 100.0
var velocidad_paciencia: float = 1.0

var tickets_grandes = {
	"Choripán": preload("res://Sprites/Tickets/TickectChoripan.png"),
	"Ensalada": preload("res://Sprites/Tickets/TickectEnsalada.png"),
	"Papa Frita": preload("res://Sprites/Tickets/TickectPapasFritas.png"),
	"carne con papas": preload("res://Sprites/Tickets/TickectCarnePapas.png")
}

func _ready():
	pasos_completados.clear()
	ingredientes_en_plato.clear()
	listo_para_entregar = false
	
	if inventario:
		inventario.visible = true
		inventario.actualizar_inventario()
		
	if visor_grande:
		visor_grande.visible = false
		
	configurar_barra()
	
	await get_tree().process_frame
	
	var pedido = PedidoManager.pedido_actual
	if pedido.is_empty():
		print("No hay pedido activo en PedidoManager")
		return
		
	for nodo_ingrediente in get_tree().get_nodes_in_group("ingredientes"):
		if "nombre_ingrediente" in nodo_ingrediente:
			var nombre_limpio = nodo_ingrediente.nombre_ingrediente.to_lower().strip_edges()
			if nombre_limpio.ends_with("2") or nombre_limpio.ends_with("3"):
				nombre_limpio = nombre_limpio.left(-1)
				
			if Global.tiene_ingrediente(nombre_limpio, 1):
				nodo_ingrediente.show()
				if "congelado" in nodo_ingrediente:
					nodo_ingrediente.congelado = false
				if nodo_ingrediente is Area2D:
					nodo_ingrediente.monitorable = true
			else:
				nodo_ingrediente.hide()
				if "congelado" in nodo_ingrediente:
					nodo_ingrediente.congelado = true
				if nodo_ingrediente is Area2D:
					nodo_ingrediente.monitorable = false
					
	if not hay_ingredientes_para_pedido():
		print("No tenes ingredientes suficientes")
		return
		
	paciencia_actual = pedido.get("paciencia_actual", pedido.get("paciencia", 100.0))
	PedidoManager.pedido_actual["paciencia_actual"] = paciencia_actual
	mostrar_ticket_chiquito()

func descontar_ingredientes_del_pedido():
	var pedido = PedidoManager.pedido_actual
	if pedido.is_empty() or not pedido.has("ingredientes"):
		return
		
	for ingrediente in pedido["ingredientes"].keys():
		var nombre = ingrediente.to_lower().strip_edges()

		if nombre.ends_with("2") or nombre.ends_with("3"):
			nombre = nombre.left(-1)
			
		Global.quitar_ingrediente(nombre, 1)
		
	for nodo_ingrediente in get_tree().get_nodes_in_group("ingredientes"):
		if "nombre_ingrediente" in nodo_ingrediente:
			var nombre_limpio = nodo_ingrediente.nombre_ingrediente.to_lower().strip_edges()
			if nombre_limpio.ends_with("2") or nombre_limpio.ends_with("3"):
				nombre_limpio = nombre_limpio.left(-1)
				
			if not Global.tiene_ingrediente(nombre_limpio, 1):
				nodo_ingrediente.hide()
				if "congelado" in nodo_ingrediente:
					nodo_ingrediente.congelado = true
				if nodo_ingrediente is Area2D:
					nodo_ingrediente.monitorable = false
					
	if inventario:
		inventario.actualizar_inventario()

func obtener_nodo_ingrediente(nombre_ingrediente: String):
	var nombre_buscado = nombre_ingrediente.to_lower().strip_edges()
	
	# Cambiamos las condiciones para que busque una coincidencia 100% exacta
	for nodo in get_tree().get_nodes_in_group("ingredientes"):
		if "nombre_ingrediente" in nodo:
			var nombre_nodo = nodo.nombre_ingrediente.to_lower().strip_edges()
			if nombre_nodo == nombre_buscado:
				return nodo
				
	var nodo_directo = get_node_or_null(nombre_buscado)
	if nodo_directo:
		return nodo_directo
	return get_node_or_null(nombre_buscado.capitalize())

func _process(delta):
	for pedido in PedidoManager.pedidos_activos:
		if pedido.has("paciencia_actual") and pedido["paciencia_actual"] > 0:
			pedido["paciencia_actual"] -= velocidad_paciencia * delta
			pedido["paciencia_actual"] = max(pedido["paciencia_actual"], 0)
			
		if PedidoManager.pedido_actual.get("id") == pedido.get("id"):
			paciencia_actual = pedido["paciencia_actual"]
			
	if visor_grande and visor_grande.visible:
		paciencia_cliente.value = paciencia_actual
		actualizar_color_barra(paciencia_actual)

func configurar_barra():
	if not paciencia_cliente:
		return
	paciencia_cliente.show_percentage = false
	paciencia_cliente.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	paciencia_cliente.min_value = 0
	paciencia_cliente.max_value = 100
	estilo_barra.corner_radius_top_left = 8
	estilo_barra.corner_radius_top_right = 8
	estilo_barra.corner_radius_bottom_left = 8
	estilo_barra.corner_radius_bottom_right = 8
	paciencia_cliente.add_theme_stylebox_override("fill", estilo_barra)

func actualizar_color_barra(paciencia):
	var porcentaje = paciencia / 100.0
	if porcentaje > 0.5:
		var t = (porcentaje - 0.5) / 0.5
		estilo_barra.bg_color = Color(1.0, 0.92, 0.55).lerp(Color(0.65, 0.95, 0.72), t)
	else:
		var t = porcentaje / 0.5
		estilo_barra.bg_color = Color(1.0, 0.55, 0.55).lerp(Color(1.0, 0.92, 0.55), t)
	paciencia_cliente.add_theme_stylebox_override("fill", estilo_barra)

func mostrar_ticket_chiquito():
	for child in soga_nodo.get_children():
		if child.is_in_group("tickets_instanciados"):
			child.queue_free()
			
	var nodo_posiciones = soga_nodo.get_node_or_null("PosicionesTickets")
	if not nodo_posiciones:
		print("ERROR CRÍTICO: No se encontró el nodo 'PosicionesTickets' dentro de 'soga'.")
		return
		
	var posiciones = [
		nodo_posiciones.get_node_or_null("Pos1"),
		nodo_posiciones.get_node_or_null("Pos2"),
		nodo_posiciones.get_node_or_null("Pos3"),
		nodo_posiciones.get_node_or_null("Pos4"),
		nodo_posiciones.get_node_or_null("Pos5")
	]
	
	var indice = 0
	for pedido in PedidoManager.pedidos_activos:
		if indice >= posiciones.size() or posiciones[indice] == null:
			break
			
		var ticket = ticket_scene.instantiate()
		ticket.add_to_group("tickets_instanciados")
		add_child(ticket)
		
		ticket.global_position = posiciones[indice].global_position
		ticket.z_index = 100
		ticket.visible = true
		
		if ticket.has_method("cargar_ticket"):
			ticket.cargar_ticket(pedido)
			
		if ticket.has_signal("seleccionado"):
			ticket.seleccionado.connect(_on_ticket_seleccionado)
			
		indice += 1

func _on_ticket_seleccionado(datos_pedido):
	print("¡La cocina recibió la señal del ticket! Datos: ", datos_pedido)
	if visor_grande == null:
		return
		
	PedidoManager.pedido_actual = datos_pedido
	paciencia_actual = datos_pedido.get("paciencia_actual", 100.0)
	
	if tickets_grandes.has(datos_pedido["nombre"]):
		ticket_imagen.texture = tickets_grandes[datos_pedido["nombre"]]
		
	if datos_pedido.has("color"):
		identificador_color.color = datos_pedido["color"]
		
	paciencia_cliente.value = paciencia_actual
	actualizar_color_barra(paciencia_actual)
	
	if visor_grande is CanvasLayer:
		ticket_imagen.position = Vector2(864, 558)
	else:
		visor_grande.position = Vector2(864, 558)
	visor_grande.visible = true

func _on_button_cerrar_pressed():
	if visor_grande:
		visor_grande.visible = false

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

func verificar_ingrediente(nombre_ingrediente: String, paso: String):
	var nombre_original_con_numero = nombre_ingrediente.to_lower()
	paso = paso.to_lower()
	
	if listo_para_entregar:
		print("La receta ya esta lista. Hace un circulo para emplatar.")
		return
		
	var pedido = PedidoManager.pedido_actual
	var nombre_base = nombre_original_con_numero
	if nombre_base.ends_with("2") or nombre_base.ends_with("3"):
		nombre_base = nombre_base.left(-1)
		
	print("Llegó a cocina - Nodo Real:", nombre_original_con_numero, " | Evaluando como:", nombre_base, " | Paso:", paso)
	
	if pedido.is_empty() or not pedido.has("ingredientes"):
		return
		
	if not pedido["ingredientes"].has(nombre_base):
		marcar_ingrediente_incorrecto(nombre_original_con_numero)
		return
		
	var pasos_necesarios = pedido["ingredientes"][nombre_base]

	if paso in pasos_necesarios:
		if not pasos_completados.has(nombre_base):
			pasos_completados[nombre_base] = []
			
		if paso not in pasos_completados[nombre_base]:
			pasos_completados[nombre_base].append(paso)
			print(nombre_base, " paso correcto: ", paso)
			
			if ingrediente_terminado(nombre_base):
				
				marcar_ingrediente_correcto(nombre_original_con_numero)
			verificar_progreso()

	else:
		print("Paso incorrecto para ", nombre_base)
		marcar_ingrediente_incorrecto(nombre_original_con_numero)

func ingrediente_terminado(nombre_ingrediente: String) -> bool:
	nombre_ingrediente = nombre_ingrediente.to_lower()
	var pedido = PedidoManager.pedido_actual
	var nombre_base = nombre_ingrediente
	if nombre_base.ends_with("2") or nombre_base.ends_with("3"):
		nombre_base = nombre_base.left(-1)
		
	if pedido.is_empty() or not pedido.has("ingredientes") or not pedido["ingredientes"].has(nombre_base):
		return false
		
	if not pasos_completados.has(nombre_base):
		return false
		
	var pasos_necesarios = pedido["ingredientes"][nombre_base]
	var pasos_hechos = pasos_completados[nombre_base]
	for p in pasos_necesarios:
		if p not in pasos_hechos:
			return false
	return true

func marcar_ingrediente_correcto(nombre_ingrediente: String):
	var nodo = obtener_nodo_ingrediente(nombre_ingrediente)
	if nodo != null:
		if nodo.has_method("correcto"):
			nodo.correcto()
		mover_ingrediente_al_plato(nodo, nombre_ingrediente)

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
	var offset = Vector2(randf_range(-30, 30), randf_range(-15, 15))
	var tween = create_tween()
	tween.tween_property(ingrediente, "global_position", plato.global_position + offset, 0.4)
	
	if nombre_ingrediente not in ingredientes_en_plato:
		ingredientes_en_plato.append(nombre_ingrediente)
	print("LISTO, fue al plato")

func verificar_progreso():
	var pedido = PedidoManager.pedido_actual
	if pedido.is_empty():
		return

	var todos_listos = true
	for ingrediente in pedido["ingredientes"]:
		var pasos_necesarios = pedido["ingredientes"][ingrediente]
		if not pasos_completados.has(ingrediente):
			todos_listos = false
			continue
			
		for paso in pasos_necesarios:
			if paso not in pasos_completados[ingrediente]:
				todos_listos = false
				
	if todos_listos:
		listo_para_entregar = true
		print("Listo. Dibuja un circulo para emplatar")

func todos_en_plato() -> bool:
	var pedido = PedidoManager.pedido_actual
	if pedido.is_empty() or not pedido.has("ingredientes"):
		return false
	for ingrediente in pedido["ingredientes"].keys():
		if ingrediente.to_lower() not in ingredientes_en_plato:
			return false
	return true

func intentar_finalizar_pedido():
	if listo_para_entregar:
		finalizar_pedido()
	else:
		print("Pedido entregado mal: faltaron pasos de cocción")
		PedidoManager.resultado_cliente = "enojado"
		PedidoManager.pedido_completado = true
		get_tree().change_scene_to_file(escena_final)

func finalizar_pedido():
	var pedido = PedidoManager.pedido_actual
	var paciencia = pedido.get("paciencia_actual", paciencia_actual)
	
	if paciencia >= 70:
		PedidoManager.resultado_cliente = "feliz"
	elif paciencia >= 35:
		PedidoManager.resultado_cliente = "medio"
	else:
		PedidoManager.resultado_cliente = "enojado"
		
	descontar_ingredientes_del_pedido()
	PedidoManager.eliminar_pedido_por_id(PedidoManager.pedido_actual["id"])
	PedidoManager.pedido_completado = true
	print("¡Emplatado exitoso! Cambiando a escena de entrega. Resultado: ", PedidoManager.resultado_cliente)
	get_tree().call_deferred("change_scene_to_file", escena_final)

func _on_boton_atencion_pressed() -> void:
	get_tree().change_scene_to_file(escena_cliente)
func _on_botoncompra_pressed() -> void:
	print("Botón presionado: cambiando a comercio...")
	get_tree().call_deferred("change_scene_to_file", escena_comercio)
