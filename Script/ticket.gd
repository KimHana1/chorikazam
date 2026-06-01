extends CanvasLayer

@onready var ticket_mini = $TicketMini
@onready var ticket_grande = $TicketGrande
@onready var ticket_imagen = $TicketGrande/ImagenTicket
@onready var ok1 = $TicketGrande/Ok1
@onready var ok2 = $TicketGrande/Ok2
@onready var ok3 = $TicketGrande/Ok3
@onready var paciencia_cliente = $TicketGrande/PacienciaCliente

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
	ticket_mini.visible = false
	ticket_grande.visible = false

	ticket_mini.position = Vector2(20, 20)
	ticket_mini.size = Vector2(90, 130)

	ticket_grande.position = Vector2(250, 60)

	ok1.visible = false
	ok2.visible = false
	ok3.visible = false

	if PedidoManager.pedido_actual and not PedidoManager.pedido_actual.is_empty():
		cargar_ticket(PedidoManager.pedido_actual)
func cargar_ticket(datos):
	if datos == null or not datos.has("nombre"):
		return

	if tickets_grandes.has(datos["nombre"]):
		ticket_imagen.texture = tickets_grandes[datos["nombre"]]

	if tickets_bebe.has(datos["nombre"]):
		ticket_mini.texture_normal = tickets_bebe[datos["nombre"]]

	ticket_grande.visible = true
	ticket_mini.visible = false

func _on_ticket_mini_pressed():
	ticket_grande.visible = true
	ticket_mini.visible = false

func _on_button_cerrar_pressed():
	ticket_grande.visible = false
	ticket_mini.visible = true

func mostrar_mini():
	ticket_grande.visible = false
	ticket_mini.visible = true
	ticket_mini.position = Vector2(20, 20)

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
