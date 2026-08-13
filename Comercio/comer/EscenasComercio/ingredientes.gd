extends Node2D

func ubicar_todos_los_botones(slots_disponibles: Array[Vector2]):
	var slots_mezclados = slots_disponibles.duplicate()
	slots_mezclados.shuffle()

	var indice_slot = 0

	for hijo in get_children():
		if not hijo is Area2D: continue
		if hijo.name in ["Flecha", "BotonIzq", "BotonDer"]: continue
		if indice_slot >= slots_mezclados.size(): break

		hijo.global_position = slots_mezclados[indice_slot]
		indice_slot += 1

func mover_boton_a_slot_vacio(boton_cliqueado: Area2D, todos_los_slots: Array[Vector2]):
	var posiciones_ocupadas: Array[Vector2] = []
	
	for hijo in get_children():
		if not hijo is Area2D: continue
		if hijo == boton_cliqueado: continue 
		if hijo.name in ["Flecha", "BotonIzq", "BotonDer"]: continue
			
		posiciones_ocupadas.append(hijo.global_position)

	
	var slots_vacios: Array[Vector2] = []
	for slot_pos in todos_los_slots:
		var esta_ocupado := false
		
		for pos_ocupada in posiciones_ocupadas:
			if slot_pos.is_equal_approx(pos_ocupada):
				esta_ocupado = true
				break
				
		if not esta_ocupado:
			slots_vacios.append(slot_pos)

	if not slots_vacios.is_empty():
		slots_vacios.shuffle()
		boton_cliqueado.global_position = slots_vacios[0]
		print("[Movimiento permitido] ", boton_cliqueado.name, " movido a slot libre: ", boton_cliqueado.global_position)
