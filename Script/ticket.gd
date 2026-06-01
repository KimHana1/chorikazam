extends Control

@onready var ticket_mini = $TicketMini
@onready var ticket_grande = $TicketGrande
@onready var ticket_imagen = $TicketGrande/ImagenTicket
@onready var ok1 = $TicketGrande/Ok1
@onready var ok2 = $TicketGrande/Ok2
@onready var ok3 = $TicketGrande/Ok3
@onready var paciencia_cliente = $TicketGrande/PacienciaCliente

var tickets = {
	"Choripán": preload("res://Sprites/Tickets/TickectChoripan.png"),
	"Ensalada": preload("res://Sprites/Tickets/TickectEnsalada.png"),
	"Papa Frita": preload("res://Sprites/Tickets/TickectPapasFritas.png")
}

func _ready():
	# El ticket empieza minimizado para no tapar la pantalla
	ticket_grande.visible = false
	ok1.visible = false
	ok2.visible = false
	ok3.visible = false

	# Si ya hay un pedido en el Manager, lo carga automáticamente
	if PedidoManager.pedido_actual and not PedidoManager.pedido_actual.is_empty():
		cargar_ticket(PedidoManager.pedido_actual)

func cargar_ticket(datos):
	# Evita errores si los datos vienen vacíos
	if datos == null or not datos.has("nombre"):
		return
		
	if tickets.has(datos["nombre"]):
		ticket_imagen.texture = tickets[datos["nombre"]]
		
	
	ticket_grande.visible = true

func _on_ticket_mini_pressed():
	ticket_grande.visible = true

func _on_button_cerrar_pressed():
	ticket_grande.visible = false
