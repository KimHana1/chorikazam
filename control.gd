extends Control

@onready var line: Line2D = $"Line2D"

var puntos: Array[Vector2] = []
var dibujando: bool = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			iniciar_dibujo()
		else:
			finalizar_dibujo()

	if event is InputEventMouseMotion and dibujando:
		var pos = get_local_mouse_position()
		agregar_punto(pos)

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
		print("hechizo:", hechizo)
		desvanecer(true)
	else:
		print("fallo")
		desvanecer(false)

func agregar_punto(pos: Vector2):
	if puntos.is_empty() or puntos[-1].distance_to(pos) > 6:
		puntos.append(pos)
		line.add_point(pos)

func detectar_hechizo(p: Array) -> String:
	if p.size() < 10:
		return "error"

	var puntos_s = simplificar_puntos(p)
	var cambios = contar_cambios_direccion(puntos_s, 0.7)
	var cerrado = puntos_s[0].distance_to(puntos_s[-1]) < 60 

	var ancho = obtener_rango_x(puntos_s)
	var alto = obtener_rango_y(puntos_s)
	var proporcion = ancho / max(alto, 0.001)

	if cerrado:
		if es_triangulo(puntos_s):
			return "triangulo"
		if es_circulo(puntos_s):
			return "circulo"

	if es_rayo(puntos_s) and not cerrado:
		return "rayo"

	if cambios <= 1:
		if proporcion > 2.0:
			return "linea_horizontal"
		elif proporcion < 0.5:
			return "linea_vertical"

	return "error"

func es_triangulo(p: Array) -> bool:
	if p.size() < 6:
		return false
	var vertices = []
	var umbral = 0.3
	for i in range(1, p.size() - 1):
		var v1 = (p[i] - p[i - 1]).normalized()
		var v2 = (p[i + 1] - p[i]).normalized()
		if v1.dot(v2) < umbral:
			vertices.append(p[i])
	var filtrados = []
	var min_dist = 30
	for v in vertices:
		var agregar = true
		for f in filtrados:
			if v.distance_to(f) < min_dist:
				agregar = false
				break
		if agregar:
			filtrados.append(v)
	if filtrados.size() != 3:
		return false
	var d1 = filtrados[0].distance_to(filtrados[1])
	var d2 = filtrados[1].distance_to(filtrados[2])
	var d3 = filtrados[2].distance_to(filtrados[0])
	var promedio = (d1 + d2 + d3) / 3.0
	if abs(d1 - promedio) > promedio * 0.7:
		return false
	if abs(d2 - promedio) > promedio * 0.7:
		return false
	if abs(d3 - promedio) > promedio * 0.7:
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
	if desviacion > promedio * 0.2: 
		return false
	var ancho = obtener_rango_x(p)
	var alto = obtener_rango_y(p)
	var proporcion = ancho / max(alto, 0.001)
	if proporcion < 0.6 or proporcion > 1.4:
		return false
	return true

func es_rayo(p: Array) -> bool:
	var cambios = contar_cambios_direccion(p, 0.6)
	return cambios >= 2 and cambios <= 10

func simplificar_puntos(original: Array) -> Array:
	var resultado = []
	var paso = 5
	for i in range(0, original.size(), paso):
		resultado.append(original[i])
	if original.size() % paso != 0:
		resultado.append(original[-1])
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
