extends Node

@onready var line: Line2D = $"../Line2D"

var puntos: Array[Vector2] = []
var dibujando: bool = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			iniciar_dibujo()
		else:
			finalizar_dibujo()

	if event is InputEventMouseMotion and dibujando:
		agregar_punto(event.position)

func iniciar_dibujo():
	puntos.clear()
	line.clear_points()
	line.modulate = Color.WHITE
	line.modulate.a = 1.0
	dibujando = true

func finalizar_dibujo():
	dibujando = false

	var hechizo = detectar_hechizo(puntos)

	if hechizo != "error":
		print("Hechizo detectado: ", hechizo)

		var ingrediente = detectar_ingrediente()

		if ingrediente != null and ingrediente.has_method("aplicar_hechizo"):
			ingrediente.aplicar_hechizo(hechizo)

		desvanecer(true)
	else:
		print("Hechizo incorrecto")
		desvanecer(false)

func agregar_punto(pos: Vector2):
	if puntos.is_empty() or puntos[-1].distance_to(pos) > 6:
		puntos.append(pos)
		line.add_point(pos)

func detectar_ingrediente():
	if puntos.is_empty():
		return null

	var espacio = get_viewport().world_2d.direct_space_state
	var ultimo_punto = puntos[puntos.size() - 1]

	var query = PhysicsPointQueryParameters2D.new()
	query.position = ultimo_punto
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var resultado = espacio.intersect_point(query)

	if resultado.size() > 0:
		return resultado[0].collider

	return null

func detectar_hechizo(p: Array) -> String:
	if p.size() < 10:
		return "error"

	var puntos_s = simplificar_puntos(p)
	var cambios = contar_cambios_direccion(puntos_s, 0.7)
	var cerrado = puntos_s[0].distance_to(puntos_s[-1]) < 50

	var ancho = obtener_rango_x(puntos_s)
	var alto = obtener_rango_y(puntos_s)
	var proporcion = ancho / max(alto, 0.001)

	if cambios <= 1:
		if proporcion > 2.0:
			return "linea_horizontal"
		elif proporcion < 0.5:
			return "linea_vertical"

	if es_triangulo(puntos_s):
		return "triangulo"

	if cerrado and es_circulo(puntos_s):
		return "circulo"

	if es_rayo(puntos_s):
		return "rayo"

	return "error"

func es_triangulo(p: Array) -> bool:
	if p.size() < 5:
		return false

	var inicio = p[0]
	var fin = p[-1]
	var punto_mas_alto = p[0]

	for punto in p:
		if punto.y < punto_mas_alto.y:
			punto_mas_alto = punto

	var ancho = abs(fin.x - inicio.x)
	var alto = max(inicio.y, fin.y) - punto_mas_alto.y

	if ancho < 25:
		return false

	if alto < 20:
		return false

	if punto_mas_alto.x < min(inicio.x, fin.x):
		return false

	if punto_mas_alto.x > max(inicio.x, fin.x):
		return false

	var proporcion = ancho / max(alto, 0.001)

	if proporcion < 0.7 or proporcion > 3.5:
		return false

	return true

func es_circulo(p: Array) -> bool:
	if p.size() < 10:
		return false

	var centro = Vector2.ZERO

	for punto in p:
		centro += punto

	centro /= p.size()

	var radios = []

	for punto in p:
		radios.append(punto.distance_to(centro))

	var promedio = 0.0

	for r in radios:
		promedio += r

	promedio /= radios.size()

	var desviacion = 0.0

	for r in radios:
		desviacion += abs(r - promedio)

	desviacion /= radios.size()

	if desviacion > promedio * 0.15:
		return false

	var cambios = contar_cambios_direccion(p, 0.85)

	if cambios > 2:
		return false

	var ancho = obtener_rango_x(p)
	var alto = obtener_rango_y(p)
	var proporcion = ancho / max(alto, 0.001)

	if proporcion < 0.7 or proporcion > 1.3:
		return false

	return true

func es_rayo(p: Array) -> bool:
	if p.size() < 6:
		return false

	var cerrado = p[0].distance_to(p[-1]) < 50

	if cerrado:
		return false

	var cambios = contar_cambios_direccion(p, 0.6)

	if cambios < 3 or cambios > 6:
		return false

	var ancho = obtener_rango_x(p)
	var alto = obtener_rango_y(p)

	if alto < 40:
		return false

	var proporcion = ancho / max(alto, 0.001)

	if proporcion > 1.4:
		return false

	return true

func simplificar_puntos(original: Array) -> Array:
	var resultado = []
	var paso = 5

	for i in range(0, original.size(), paso):
		resultado.append(original[i])

	return resultado

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

func obtener_rango_x(p: Array) -> float:
	var min_x = p[0].x
	var max_x = p[0].x

	for punto in p:
		min_x = min(min_x, punto.x)
		max_x = max(max_x, punto.x)

	return max_x - min_x

func obtener_rango_y(p: Array) -> float:
	var min_y = p[0].y
	var max_y = p[0].y

	for punto in p:
		min_y = min(min_y, punto.y)
		max_y = max(max_y, punto.y)

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
