extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var boton_tomar_pedido = $ButtonTomarPedido
@onready var selector_color = $ColorPickerButton

var cocina_scene = preload("res://Escenas/cocina.tscn")
var ticket_scene = preload("res://Escenas/ticket.tscn")

var clientes = {
	"mujer": {
		"principal": preload("res://Sprites/clientes/mujer/principal.png"),
		"medio": preload("res://Sprites/clientes/mujer/medio.png"),
		"enojado": preload("res://Sprites/clientes/mujer/enojada.png"),
		"feliz": preload("res://Sprites/clientes/mujer/feliz.png"),
		"color": Color.BROWN
	},
	"hombre": {
		"principal": preload("res://Sprites/clientes/hombre/principal.png"),
		"medio": preload("res://Sprites/clientes/hombre/medio.png"),
		"enojado": preload("res://Sprites/clientes/hombre/enojado.png"),
		"feliz": preload("res://Sprites/clientes/hombre/feliz.png"),
		"color": Color.GRAY
	}
}

var pedidos = [
	{
		"nombre": "Choripán",
		"ingredientes": {
			"Pan": "linea_horizontal",
			"Chorizo": "triangulo"
		},
		"paciencia": 80
	},
	{
		"nombre": "Ensalada",
		"ingredientes": {
			"Papa": "linea_vertical",
			"Carne": "rayo"
		},
		"paciencia": 60
	}
]

var cliente_actual = ""
var pedido_actual = {}
var ticket_abierto = false

func _ready():
	randomize()

	if not selector_color.color_changed.is_connected(_on_color_picker_button_color_changed):
		selector_color.color_changed.connect(_on_color_picker_button_color_changed)

	if PedidoManager.pedido_completado:
		mostrar_resultado_cliente()
	else:
		generar_cliente()

func generar_cliente():
	ticket_abierto = false
	var lista_clientes = clientes.keys()
	cliente_actual = lista_clientes[randi() % lista_clientes.size()]

	sprite.modulate = Color.WHITE
	sprite.texture = clientes[cliente_actual]["principal"]

	var pedido_random = pedidos[randi() % pedidos.size()]
	pedido_actual = pedido_random.duplicate(true)

	pedido_actual["color"] = clientes[cliente_actual]["color"]
	pedido_actual["paciencia_actual"] = pedido_actual["paciencia"]

	selector_color.color = pedido_actual["color"]

	PedidoManager.cliente_actual = cliente_actual
	PedidoManager.pedido_actual = pedido_actual
	PedidoManager.pedido_completado = false
	PedidoManager.resultado_cliente = "normal"

	boton_tomar_pedido.visible = true
	selector_color.visible = true

func abrir_ticket():
	if ticket_abierto:
		return
	ticket_abierto = true
	var ticket = ticket_scene.instantiate()
	get_tree().current_scene.add_child(ticket)
	ticket.cargar_ticket(pedido_actual)

func mostrar_resultado_cliente():
	ticket_abierto = false
	cliente_actual = PedidoManager.cliente_actual
	if cliente_actual == "" or not clientes.has(cliente_actual):
		cliente_actual = "mujer"

	var resultado = PedidoManager.resultado_cliente
	if not clientes[cliente_actual].has(resultado):
		resultado = "medio"

	sprite.modulate = Color.WHITE
	sprite.texture = clientes[cliente_actual][resultado]
	boton_tomar_pedido.visible = false
	selector_color.visible = false

func _on_button_tomar_pedido_pressed():
	abrir_ticket()

func _on_color_picker_button_color_changed(nuevo_color):
	if pedido_actual.is_empty():
		return
	pedido_actual["color"] = nuevo_color
	PedidoManager.pedido_actual = pedido_actual
	sprite.modulate = nuevo_color

func _on_button_cocinar_pressed():
	if pedido_actual.is_empty():
		return
	PedidoManager.pedido_actual = pedido_actual
	PedidoManager.cliente_actual = cliente_actual
	PedidoManager.pedido_completado = false
	get_tree().change_scene_to_packed(cocina_scene)
