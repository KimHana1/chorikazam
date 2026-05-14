extends Control

@onready var label_pedido = $VBoxContainer/LabelPedido
@onready var comida_cocinada = $VBoxContainer/ComidaCocinada
@onready var ingredientes_container = $VBoxContainer/PasosContainer
@onready var identificador_color = $VBoxContainer/IdentificadorColor
@onready var paciencia_cliente = $VBoxContainer/PacienciaCliente

var paciencia_actual: float = 100.0
var velocidad_paciencia: float = 1.0

var color_verde = Color(0.65, 0.95, 0.72)
var color_amarillo = Color(1.0, 0.92, 0.55)
var color_rojo = Color(1.0, 0.55, 0.55)

var estilo_barra = StyleBoxFlat.new()

var comidas_cocinadas = {
	"Choripán": preload("res://Sprites/cocinado/choripan.png"),
	"Ensalada": preload("res://Sprites/cocinado/ensaladapatoma.png")
}

var iconos_ingredientes = {
	"pan": preload("res://Sprites/ingredientes/pan.png"),
	"papa": preload("res://Sprites/ingredientes/papa.png"),
	"chorizo": preload("res://Sprites/ingredientes/chorizo.png"),
	"carne": preload("res://Sprites/ingredientes/carne.png")
}

func _ready():
	configurar_barra()

	if not PedidoManager.pedido_actual.is_empty():
		cargar_ticket(PedidoManager.pedido_actual)

func configurar_barra():
	paciencia_cliente.show_percentage = false
	paciencia_cliente.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	paciencia_cliente.custom_minimum_size = Vector2(18, 90)

	estilo_barra.corner_radius_top_left = 8
	estilo_barra.corner_radius_top_right = 8
	estilo_barra.corner_radius_bottom_left = 8
	estilo_barra.corner_radius_bottom_right = 8

	paciencia_cliente.add_theme_stylebox_override("fill", estilo_barra)

func cargar_ticket(datos):
	label_pedido.text = datos["nombre"]

	limpiar_contenedor(comida_cocinada)
	limpiar_contenedor(ingredientes_container)

	if datos.has("color"):
		identificador_color.color = datos["color"]

	if datos["nombre"] in comidas_cocinadas:
		var icono_comida = crear_texture_rect(35)
		icono_comida.texture = comidas_cocinadas[datos["nombre"]]
		comida_cocinada.add_child(icono_comida)

	if datos.has("ingredientes"):
		for ingrediente in datos["ingredientes"]:
			crear_icono_ingrediente(ingrediente)

	paciencia_actual = datos.get("paciencia_actual", datos.get("paciencia", 100.0))
	paciencia_cliente.max_value = 100
	paciencia_cliente.value = paciencia_actual
	actualizar_color_barra()

func crear_icono_ingrediente(nombre_ingrediente: String):
	var icono = crear_texture_rect(35)

	if iconos_ingredientes.has(nombre_ingrediente):
		icono.texture = iconos_ingredientes[nombre_ingrediente]

	ingredientes_container.add_child(icono)

func crear_texture_rect(tamano: int) -> TextureRect:
	var icono = TextureRect.new()
	icono.custom_minimum_size = Vector2(tamano, tamano)
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return icono

func _process(delta):
	if paciencia_actual > 0:
		paciencia_actual -= velocidad_paciencia * delta
		paciencia_actual = max(paciencia_actual, 0)
		paciencia_cliente.value = paciencia_actual

		if not PedidoManager.pedido_actual.is_empty():
			PedidoManager.pedido_actual["paciencia_actual"] = paciencia_actual

		actualizar_color_barra()

func actualizar_color_barra():
	var porcentaje = paciencia_actual / 100.0

	if porcentaje > 0.5:
		var t = (porcentaje - 0.5) / 0.5
		estilo_barra.bg_color = color_amarillo.lerp(color_verde, t)
	else:
		var t = porcentaje / 0.5
		estilo_barra.bg_color = color_rojo.lerp(color_amarillo, t)

	paciencia_cliente.add_theme_stylebox_override("fill", estilo_barra)

func limpiar_contenedor(contenedor):
	for hijo in contenedor.get_children():
		hijo.queue_free()

func _on_button_cerrar_pressed():
	queue_free()
