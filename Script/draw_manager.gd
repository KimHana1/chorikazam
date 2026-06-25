extends Node

@onready var line: Line2D = $"../Line2D"
@onready var particulas: GPUParticles2D = $"../GPUParticles2D"

var puntos_linea: Array[Vector2] = []
var puntos_mundo: Array[Vector2] = []
var dibujando: bool = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			iniciar_dibujo()
		else:
			finalizar_dibujo()

	if event is InputEventMouseMotion and dibujando:
		agregar_punto_mouse()

func iniciar_dibujo():
	puntos_linea.clear()
	puntos_mundo.clear()
	line.clear_points()
	line.modulate = Color.WHITE
	line.modulate.a = 1.0
	dibujando = true

	agregar_punto_mouse()
func lanzar_particulas_trazo():

	for i in range(0, puntos_linea.size(), 2):

		particulas.global_position = line.to_global(puntos_linea[i])

		particulas.restart()

		await get_tree().create_timer(0.03).timeout
		particulas.emitting = false
func lanzar_particulas():

	particulas.global_position = line.to_global(obtener_centro_dibujo())
	particulas.restart()
	particulas.emitting = true
func configurar_particulas_hechizo(hechizo:String):

	var material := particulas.process_material as ParticleProcessMaterial

	match hechizo:

		"linea_horizontal":
			material.scale_min = 4.0
			material.scale_max = 8.0
			particulas.modulate = Color.GREEN

		"linea_vertical":
			material.scale_min = 5.0
			material.scale_max = 9.0
			particulas.modulate = Color.NAVY_BLUE

		"triangulo":
			material.scale_min = 5.0
			material.scale_max = 7.0
			particulas.modulate = Color.ORANGE

		"rayo":
			material.scale_min = 4.0
			material.scale_max = 10.0
			particulas.modulate = Color.YELLOW

func finalizar_dibujo():
	dibujando = false

	var hechizo = detectar_hechizo(puntos_linea)
	var paso = convertir_hechizo_a_paso(hechizo)

	if paso == "error":
		print("Hechizo incorrecto")
		desvanecer(false)
		return

	print("Paso detectado: ", paso)


	if paso == "emplatar":
		if get_tree().current_scene.has_method("intentar_finalizar_pedido"):
			get_tree().current_scene.centro_emplatar = line.to_global(obtener_centro_dibujo())
			get_tree().current_scene.intentar_finalizar_pedido()
			desvanecer(true)
		else:
			desvanecer(false)
		return

	var ingrediente = detectar_ingrediente()

	if ingrediente != null and ingrediente.has_method("aplicar_hechizo"):
		ingrediente.aplicar_hechizo(paso)
		configurar_particulas_hechizo(hechizo)
		await lanzar_particulas_trazo()

		desvanecer(true)
	else:
		print("No tocaste ningun ingrediente")
		desvanecer(false)
func obtener_centro_dibujo() -> Vector2:

	if puntos_linea.is_empty():
		return Vector2.ZERO

	var centro := Vector2.ZERO

	for p in puntos_linea:
		centro += p

	return centro / puntos_linea.size()
func agregar_punto_mouse():
	var mouse_mundo = get_viewport().get_camera_2d().get_global_mouse_position() if get_viewport().get_camera_2d() != null else get_viewport().get_mouse_position()
	var mouse_linea = line.to_local(mouse_mundo)

	if puntos_linea.is_empty() or puntos_linea[-1].distance_to(mouse_linea) > 6:
		puntos_linea.append(mouse_linea)
		puntos_mundo.append(mouse_mundo)
		line.add_point(mouse_linea)

func detectar_ingrediente():
	if puntos_mundo.is_empty():
		return null

	var espacio = get_viewport().world_2d.direct_space_state

	for punto in puntos_mundo:
		var query = PhysicsPointQueryParameters2D.new()
		query.position = punto
		query.collide_with_areas = true
		query.collide_with_bodies = false

		var resultado = espacio.intersect_point(query)

		for item in resultado:
			var collider = item.collider

			if collider != null and collider.has_method("aplicar_hechizo"):
				return collider

	return null

func detectar_hechizo(p: Array) -> String:
	if p.size() < 10:
		return "error"

	var puntos_s = simplificar_puntos(p)
	var cerrado = puntos_s[0].distance_to(puntos_s[-1]) < 60
	var ancho = obtener_rango_x(puntos_s)
	var alto = obtener_rango_y(puntos_s)
	var proporcion = ancho / max(alto, 0.001)

	var cambios_suaves = contar_cambios_direccion(puntos_s, 0.95)

	if cambios_suaves <= 1:
		if proporcion > 3.0:
			return "linea_horizontal"
		if proporcion < 0.33:
			return "linea_vertical"

	var cambios_triangulo = contar_cambios_direccion(puntos_s, 0.3)

	if cerrado and cambios_triangulo == 2:
		return "triangulo"

	# Si es una figura cerrada y no clasificó como triángulo, ahora es un "círculo" directamente
	if cerrado:
		return "circulo"

	var cambios_rayo = contar_cambios_direccion(puntos_s, 0.3)

	if not cerrado and cambios_rayo == 2:
		return "rayo"

	return "error"

func convertir_hechizo_a_paso(hechizo: String) -> String:
	if hechizo == "linea_horizontal":
		return "cortar"
	elif hechizo == "linea_vertical":
		return "pelar"
	elif hechizo == "triangulo" or hechizo == "rayo":
		return "calentar"
	elif hechizo == "circulo":
		return "emplatar"

	return "error"

func contar_cambios_direccion(p: Array, umbral: float) -> int:
	if p.size() < 3:
		return 0

	var cambios = 0
	var dir_anterior = (p[1] - p[0]).normalized()

	for i in range(2, p.size()):
		var dir_actual = (p[i] - p[i - 1]).normalized()

		if dir_anterior.dot(dir_actual) < umbral:
			cambios += 1
			dir_anterior = dir_actual

	return cambios

func simplificar_puntos(original: Array) -> Array:
	var resultado = []
	var paso = 4

	for i in range(0, original.size(), paso):
		resultado.append(original[i])

	if original.size() % paso != 0:
		resultado.append(original[-1])

	return resultado

func obtener_rango_x(p: Array) -> float:
	var min_x = p[0].x
	var max_x = p[0].x

	for punto in p:
		if punto.x < min_x:
			min_x = punto.x
		if punto.x > max_x:
			max_x = punto.x

	return max_x - min_x

func obtener_rango_y(p: Array) -> float:
	var min_y = p[0].y
	var max_y = p[0].y

	for punto in p:
		if punto.y < min_y:
			min_y = punto.y
		if punto.y > max_y:
			max_y = punto.y

	return max_y - min_y

func desvanecer(correcto: bool):
	var tween = create_tween()

	if correcto:
		line.modulate = Color.GREEN
		tween.tween_property(line, "modulate:a", 0.0, 0.6)
	else:
		line.modulate = Color.RED
		tween.tween_property(line, "modulate:a", 0.0, 0.3)

	tween.tween_callback(line.clear_points)
