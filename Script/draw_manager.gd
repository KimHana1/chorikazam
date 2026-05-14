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

		if hechizo == "circulo":
			if get_tree().current_scene.has_method("intentar_finalizar_pedido"):
				get_tree().current_scene.intentar_finalizar_pedido(hechizo)

			desvanecer(true)
			return

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
	if puntos.is_empty(): return null
	var espacio = get_viewport().world_2d.direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = puntos[-1]
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var resultado = espacio.intersect_point(query)
	return resultado[0].collider if resultado.size() > 0 else null


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

	var cambios_circulo = contar_cambios_direccion(puntos_s, 0.8)

	if cerrado and cambios_circulo > 5:
		if proporcion >= 0.7 and proporcion <= 1.3:
			return "circulo"

	var cambios_triangulo = contar_cambios_direccion(puntos_s, 0.3)

	if cerrado and cambios_triangulo == 2:
		return "triangulo"

	var cambios_rayo = contar_cambios_direccion(puntos_s, 0.3)

	if not cerrado and cambios_rayo == 2:
		return "rayo"

	return "error"
func contar_cambios_direccion(p: Array, umbral: float) -> int:
	if p.size() < 3: return 0
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
	var xs = p.map(func(v): return v.x)
	return xs.max() - xs.min()

func obtener_rango_y(p: Array) -> float:
	var ys = p.map(func(v): return v.y)
	return ys.max() - ys.min()

func desvanecer(correcto: bool):
	var tween = create_tween()
	if correcto:
		line.modulate = Color.GREEN
		tween.tween_property(line, "modulate:a", 0.0, 0.6)
	else:
		line.modulate = Color.RED
		tween.tween_property(line, "modulate:a", 0.0, 0.3)
	tween.tween_callback(line.clear_points) 
