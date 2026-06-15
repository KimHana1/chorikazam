extends CanvasLayer

signal ticket_minimizado

@onready var ticket_mini = $TicketMini
@onready var ticket_grande = $TicketGrande
@onready var ticket_imagen = $TicketGrande/ImagenTicket
@onready var ok1 = $TicketGrande/Ok1
@onready var ok2 = $TicketGrande/Ok2
@onready var ok3 = $TicketGrande/Ok3
@onready var paciencia_cliente = $TicketGrande/PacienciaCliente
@onready var identificador_color = $TicketGrande/IdentificadorColor

var paciencia_actual: float = 100.0
var velocidad_paciencia: float = 1.0

var estilo_barra = StyleBoxFlat.new()
var color_verde = Color(0.65, 0.95, 0.72)
var color_amarillo = Color(1.0, 0.92, 0.55)
var color_rojo = Color(1.0, 0.55, 0.55)

var tickets_grandes = {
	"Choripán": preload("res://Sprites/Tickets/TickectChoripan.png"),
	"Ensalada": preload("res://Sprites/Tickets/TickectEnsalada.png"),
	"Papa Frita": preload("res://Sprites/Tickets/TickectPapasFritas.png")
}

var tickets_bebe = {
	"Choripán": preload("res://ticketBebe/ticketBebeChoripan.png"),
	"Ensalada": preload("res://ticketBebe/ticketBebeEnsalada.png"),
	"Papa Frita": preload("res://ticketBebe/ticketBebePapasFritas.png")
}

func _ready():
	ticket_mini.visible = true
	ticket_grande.visible = false

	ok1.visible = false
	ok2.visible = false
	ok3.visible = false

	configurar_barra()

	if PedidoManager.pedido_actual and not PedidoManager.pedido_actual.is_empty():
		cargar_ticket(PedidoManager.pedido_actual)

func configurar_barra():
	paciencia_cliente.visible = true
	paciencia_cliente.show_percentage = false
	paciencia_cliente.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	paciencia_cliente.min_value = 0
	paciencia_cliente.max_value = 100
	paciencia_cliente.custom_minimum_size = Vector2(14, 90)

	estilo_barra.corner_radius_top_left = 8
	estilo_barra.corner_radius_top_right = 8
	estilo_barra.corner_radius_bottom_left = 8
	estilo_barra.corner_radius_bottom_right = 8

	paciencia_cliente.add_theme_stylebox_override("fill", estilo_barra)

func cargar_ticket(datos):
	if datos == null or not datos.has("nombre"):
		return

	if tickets_grandes.has(datos["nombre"]):
		ticket_imagen.texture = tickets_grandes[datos["nombre"]]

	if tickets_bebe.has(datos["nombre"]):
		ticket_mini.texture_normal = tickets_bebe[datos["nombre"]]

	if datos.has("color"):
		identificador_color.color = datos["color"]

	paciencia_actual = datos.get("paciencia_actual", datos.get("paciencia", 100.0))
	paciencia_cliente.value = paciencia_actual
	actualizar_color_barra()

func _process(delta):
	if paciencia_actual > 0:
		paciencia_actual -= velocidad_paciencia * delta
		paciencia_actual = max(paciencia_actual, 0)
		paciencia_cliente.value = paciencia_actual

		if PedidoManager.pedido_actual and not PedidoManager.pedido_actual.is_empty():
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

func _on_ticket_mini_pressed():
	ticket_grande.visible = true

func _on_button_cerrar_pressed():
	ticket_grande.visible = false
	ticket_minimizado.emit()

func marcar_ok(nombre_ingrediente: String):
	match nombre_ingrediente:
		"pan":
			ok1.visible = true
		"chorizo":
			ok2.visible = true
		"papa":
			ok1.visible = true
		"carne":
			ok2.visible = true
		"tomate":
			ok3.visible = true

func actualizar_paciencia(valor: float):
	paciencia_cliente.value = valor
