extends CharacterBody2D

@onready var plato_preparado = $PlatoPreparado
@onready var caja_registradora = $CajaRegistradora
@onready var sprite = $Sprite2D
@onready var boton_tomar_pedido = $ButtonTomarPedido
@onready var boton_cocinar = $ButtonCocinar

@onready var globo_pedido = $GloboPedido
@onready var label_globo = $GloboPedido/LabelPedido
@onready var icono_comida = $GloboPedido/IconoComida
@onready var boton_ticket = $GloboPedido/ButtonTicket
@onready var barra_tiempo = $CanvasLayer/BarraTiempo
@onready var label_dia = $CanvasLayer/LabelDia

var dia_finalizado := false

var cocina_scene = preload("res://Escenas/cocina.tscn")
var ticket_scene = preload("res://Escenas/ticket.tscn")

var cliente_actual = ""
var pedido_actual = {}
var ticket_abierto = false
var tween_idle

var comidas_cocinadas = {
	"Choripán": preload("res://Sprites/cocinado/choripan.png"),
	"Ensalada": preload("res://Sprites/cocinado/ensaladapatoma.png"),
	"Papa Frita": preload("res://Sprites/cocinado/papa frita.png")
}

var clientes = {
	"mujer": {
		"enojada": preload("res://Sprites/clientes/Mujer/enojada.png"),
		"feliz": preload("res://Sprites/clientes/Mujer/feliz.png"),
		"medio": preload("res://Sprites/clientes/Mujer/medio.png"),
		"principal": preload("res://Sprites/clientes/Mujer/principal.png"),
		"color": Color.BROWN
	},
	"hombre": {
		"enojado": preload("res://Sprites/clientes/Hombre/enojado.png"),
		"feliz": preload("res://Sprites/clientes/Hombre/feliz.png"),
		"medio": preload("res://Sprites/clientes/Hombre/medio.png"),
		"principal": preload("res://Sprites/clientes/Hombre/principal.png"),
		"color": Color.GRAY
	}
}

var pedidos = [
	{
		"nombre": "Choripán",
		"ingredientes": {
			"pan": ["cortar"],
			"chorizo": ["calentar"]
		},
		"paciencia": 85
	},
	{
		"nombre": "Ensalada",
		"ingredientes": {
			"papa": ["cortar"],
			"tomate": ["cortar"]
		},
		"paciencia": 80
	},
	{
		"nombre": "Papa Frita",
		"ingredientes": {
			"papa": ["pelar", "cortar", "calentar"]
		},
		"paciencia": 95
	}
]

func _ready():
	randomize()

	plato_preparado.visible = false
	caja_registradora.visible = false
	globo_pedido.visible = false
	boton_cocinar.visible = false

	iniciar_idle_cliente()

	if GameManager.tiempo_restante <= 0 or GameManager.clientes_restantes <= 0:
		GameManager.iniciar_dia()

	if PedidoManager.pedido_completado:
		mostrar_resultado_cliente()
	else:
		generar_cliente()

func iniciar_idle_cliente():
	if tween_idle:
		tween_idle.kill()

	var y_original = sprite.position.y

	tween_idle = create_tween()
	tween_idle.set_loops()
	tween_idle.set_trans(Tween.TRANS_SINE)
	tween_idle.set_ease(Tween.EASE_IN_OUT)

	tween_idle.tween_property(sprite, "position:y", y_original - 5, 0.8)
	tween_idle.tween_property(sprite, "position:y", y_original, 0.8)

func generar_cliente():
	if GameManager.clientes_restantes <= 0:
		return

	GameManager.clientes_restantes -= 1

	ticket_abierto = false
	globo_pedido.visible = false
	plato_preparado.visible = false
	caja_registradora.visible = false

	var lista_clientes = clientes.keys()
	cliente_actual = lista_clientes[randi() % lista_clientes.size()]

	sprite.modulate = Color.WHITE
	sprite.texture = clientes[cliente_actual]["principal"]

	var pedido_random = pedidos[randi() % pedidos.size()]
	pedido_actual = pedido_random.duplicate(true)

	pedido_actual["color"] = clientes[cliente_actual]["color"]
	pedido_actual["paciencia_actual"] = pedido_actual["paciencia"]

	PedidoManager.cliente_actual = cliente_actual
	PedidoManager.pedido_actual = pedido_actual
	PedidoManager.pedidos_activos.append(pedido_actual.duplicate(true))
	PedidoManager.pedido_completado = false
	PedidoManager.resultado_cliente = "normal"

	boton_tomar_pedido.visible = true
	boton_cocinar.visible = false
	
func mostrar_globo_pedido():
	if pedido_actual.is_empty() or not pedido_actual.has("nombre"):
		return

	globo_pedido.visible = true
	label_globo.text = "Quiero " + pedido_actual["nombre"]

	if comidas_cocinadas.has(pedido_actual["nombre"]):
		icono_comida.texture = comidas_cocinadas[pedido_actual["nombre"]]

func abrir_ticket():
	if ticket_abierto:
		return

	ticket_abierto = true
	globo_pedido.visible = false
	
	boton_cocinar.visible = true 

	var ticket = ticket_scene.instantiate()
	get_tree().current_scene.add_child(ticket)

	if ticket.has_method("cargar_ticket"):
		ticket.cargar_ticket(pedido_actual)

	if ticket.has_signal("ticket_minimizado"):
		ticket.ticket_minimizado.connect(_on_ticket_minimizado)
func _on_ticket_minimizado():
	boton_cocinar.visible = true

func mostrar_resultado_cliente():
	ticket_abierto = false
	globo_pedido.visible = false

	pedido_actual = PedidoManager.pedido_actual
	cliente_actual = PedidoManager.cliente_actual

	if cliente_actual == "" or not clientes.has(cliente_actual):
		cliente_actual = "mujer"

	var resultado = PedidoManager.resultado_cliente

	if not clientes[cliente_actual].has(resultado):
		resultado = "medio"

	sprite.modulate = Color.WHITE
	sprite.texture = clientes[cliente_actual][resultado]

	if pedido_actual.has("nombre"):
		var nombre_plato = pedido_actual["nombre"]

		if comidas_cocinadas.has(nombre_plato):
			plato_preparado.texture = comidas_cocinadas[nombre_plato]
			plato_preparado.visible = true

	caja_registradora.visible = true

	boton_tomar_pedido.visible = false
	boton_cocinar.visible = false

	await get_tree().create_timer(1.5).timeout

	generar_cliente()

func _on_button_tomar_pedido_pressed():
	boton_tomar_pedido.visible = false
	mostrar_globo_pedido()

func _on_button_ticket_pressed():
	abrir_ticket()

func _on_button_cocinar_pressed():
	if pedido_actual.is_empty():
		return

	PedidoManager.pedido_actual = pedido_actual
	PedidoManager.cliente_actual = cliente_actual
	PedidoManager.pedido_completado = false
	PedidoManager.resultado_cliente = "normal"

	get_tree().change_scene_to_packed(cocina_scene)

func _process(delta):
	GameManager.tiempo_restante -= delta

	if GameManager.tiempo_restante < 0:
		GameManager.tiempo_restante = 0

	barra_tiempo.max_value = GameManager.duracion_dia
	barra_tiempo.value = GameManager.tiempo_restante

	label_dia.text = "Día " + str(GameManager.dia_actual)

	if GameManager.tiempo_restante <= 0:
		finalizar_dia()

func finalizar_dia():
	if dia_finalizado:
		return

	dia_finalizado = true

	print("Fin del día")

	GameManager.siguiente_dia()

	get_tree().reload_current_scene()
