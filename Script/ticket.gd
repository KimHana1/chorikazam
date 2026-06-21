extends Node2D

signal seleccionado(datos_pedido)

@onready var ticket_mini = $TicketMini
@onready var visor_grande = $VisorTicketGrande
@onready var imagen_grande = $VisorTicketGrande/ImagenTicket
@onready var identificador_color = $VisorTicketGrande/IdentificadorColor
@onready var paciencia_cliente = $VisorTicketGrande/PacienciaCliente

var id_pedido: int = -1
var datos_actuales = {}

var estilo_barra = StyleBoxFlat.new()

var tickets_bebe = {
	"Choripán": preload("res://ticketBebe/ticketBebeChoripan.png"),
	"Ensalada": preload("res://ticketBebe/ticketBebeEnsalada.png"),
	"Papa Frita": preload("res://ticketBebe/ticketBebePapasFritas.png")
}

var tickets_grandes = {
	"Choripán": preload("res://Sprites/Tickets/TickectChoripan.png"),
	"Ensalada": preload("res://Sprites/Tickets/TickectEnsalada.png"),
	"Papa Frita": preload("res://Sprites/Tickets/TickectPapasFritas.png")
}

func _ready():
	ticket_mini.visible = true
	if visor_grande:
		visor_grande.visible = false
		visor_grande.offset = Vector2(1065, 300)
		
	configurar_barra()

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

func cargar_ticket(datos):
	if datos == null or not datos.has("id"):
		return

	id_pedido = datos["id"]
	datos_actuales = datos

	if tickets_bebe.has(datos["nombre"]):
		ticket_mini.texture_normal = tickets_bebe[datos["nombre"]]
		
	if tickets_grandes.has(datos["nombre"]) and imagen_grande:
		imagen_grande.texture = tickets_grandes[datos["nombre"]]
		
	if datos.has("color") and identificador_color:
		identificador_color.color = datos["color"]
		
	if datos.has("paciencia_actual"):
		paciencia_cliente.value = datos["paciencia_actual"]
		actualizar_color_barra(datos["paciencia_actual"])
	
	ticket_mini.visible = true

func _process(_delta):
	# Solo actualizamos la UI si el visor gigante está abierto para ahorrar recursos
	if visor_grande and visor_grande.visible and datos_actuales.has("paciencia_actual"):
		paciencia_cliente.value = datos_actuales["paciencia_actual"]
		actualizar_color_barra(datos_actuales["paciencia_actual"])

func actualizar_color_barra(paciencia):
	var porcentaje = paciencia / 100.0
	if porcentaje > 0.5:
		# De Verde a Amarillo
		var t = (porcentaje - 0.5) / 0.5
		estilo_barra.bg_color = Color(1.0, 0.92, 0.55).lerp(Color(0.65, 0.95, 0.72), t)
	else:
		# De Amarillo a Rojo
		var t = porcentaje / 0.5
		estilo_barra.bg_color = Color(1.0, 0.55, 0.55).lerp(Color(1.0, 0.92, 0.55), t)
		
	paciencia_cliente.add_theme_stylebox_override("fill", estilo_barra)

func _on_ticket_mini_pressed():
	print("✅ ¡Clic detectado por el botón! ID: ", id_pedido)
	
	if visor_grande:
		visor_grande.visible = true
		visor_grande.offset = Vector2(1065, 300)
		
	PedidoManager.pedido_actual = datos_actuales
	emit_signal("seleccionado", datos_actuales)

func _on_button_cerrar_pressed():
	if visor_grande:
		visor_grande.visible = false
