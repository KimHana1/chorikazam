extends CharacterBody2D

const ESTADO_PRINCIPAL = "principal"
const ESTADO_FELIZ = "feliz"
const ESTADO_MEDIO = "medio"
const ESTADO_ENOJADO = "enojado"

#@onready var boton_ticket = $GloboPedido/ButtonTicket
@onready var plato_preparado = $PlatoPreparado
@onready var caja_registradora = $CajaRegistradora
@onready var sprite = $Sprite2D
@onready var boton_tomar_pedido = $ButtonTomarPedido
@onready var boton_cocinar = $ButtonCocinar

@onready var globo_pedido = $GloboPedido
@onready var label_globo = $GloboPedido/LabelPedido
@onready var icono_comida = $GloboPedido/IconoComida
@onready var barra_tiempo = $CanvasLayer/BarraTiempo
@onready var label_dia = $CanvasLayer/LabelDia


var dia_finalizado := false
var cocina_scene = preload("res://Escenas/cocina.tscn")

var id_pedido_actual: int = -1
var cliente_actual_tipo = ""
var tween_idle

var comidas_cocinadas = {
	"Choripán": preload("res://Sprites/cocinado/choripan.png"),
	"Ensalada": preload("res://Sprites/cocinado/ensaladapatoma.png"),
	"Papa Frita": preload("res://Sprites/cocinado/papa frita.png")
}

var clientes = {
	"mujer": {
		ESTADO_ENOJADO: preload("res://Sprites/clientes/Mujer/enojada.png"),
		ESTADO_FELIZ: preload("res://Sprites/clientes/Mujer/feliz.png"),
		ESTADO_MEDIO: preload("res://Sprites/clientes/Mujer/medio.png"),
		ESTADO_PRINCIPAL: preload("res://Sprites/clientes/Mujer/principal.png"),
		"color": Color.BROWN
	},
	"hombre": {
		ESTADO_ENOJADO: preload("res://Sprites/clientes/Hombre/enojado.png"),
		ESTADO_FELIZ: preload("res://Sprites/clientes/Hombre/feliz.png"),
		ESTADO_MEDIO: preload("res://Sprites/clientes/Hombre/medio.png"),
		ESTADO_PRINCIPAL: preload("res://Sprites/clientes/Hombre/principal.png"),
		"color": Color.GRAY
	}
}

var pedidos = [
	{
		"nombre": "Choripán",
		"ingredientes": {"pan": ["cortar"], "chorizo": ["calentar"]},
		"paciencia": 85
	},
	{
		"nombre": "Ensalada",
		"ingredientes": {"papa": ["cortar"], "tomate": ["cortar"]},
		"paciencia": 80
	},
	{
		"nombre": "Papa Frita",
		"ingredientes": {"papa": ["pelar", "cortar", "calentar"]},
		"paciencia": 95
	}
]

func _ready():
	randomize()
	ocultar_toda_la_ui()
	iniciar_idle_cliente()

	if GameManager.tiempo_restante <= 0 or GameManager.clientes_restantes <= 0:
		GameManager.iniciar_dia()

	if PedidoManager.pedido_completado:
		mostrar_resultado_cliente()
	else:
		flujo_nuevo_cliente()

func ocultar_toda_la_ui():
	plato_preparado.visible = false
	caja_registradora.visible = false
	globo_pedido.visible = false
	boton_cocinar.visible = false

func cambiar_sprite_cliente(estado: String):
	print("Cliente actual:", cliente_actual_tipo)
	print("Estado:", estado)

	if clientes.has(cliente_actual_tipo):
		print("Existe cliente")

		if clientes[cliente_actual_tipo].has(estado):
			print("Existe textura")

			sprite.modulate = Color.WHITE
			sprite.texture = clientes[cliente_actual_tipo][estado]
		else:
			print("NO existe estado")
	else:
		print("NO existe cliente")

func iniciar_idle_cliente():
	if tween_idle: tween_idle.kill()
	var y_original = sprite.position.y
	tween_idle = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_idle.tween_property(sprite, "position:y", y_original - 5, 0.8)
	tween_idle.tween_property(sprite, "position:y", y_original, 0.8)

func flujo_nuevo_cliente():
	if GameManager.clientes_restantes <= 0: return
	GameManager.clientes_restantes -= 1
	ocultar_toda_la_ui()
	
	var lista_tipos = clientes.keys()
	cliente_actual_tipo = lista_tipos[randi() % lista_tipos.size()]
	PedidoManager.cliente_actual_tipo = cliente_actual_tipo
	cambiar_sprite_cliente(ESTADO_PRINCIPAL)
	

	var receta_random = pedidos[randi() % pedidos.size()]
	var nuevo_pedido = PedidoManager.registrar_nuevo_pedido(receta_random, clientes[cliente_actual_tipo]["color"])
	id_pedido_actual = nuevo_pedido["id"]

	boton_tomar_pedido.visible = true

func mostrar_globo_pedido():
	var pedido = PedidoManager.obtener_pedido_por_id(id_pedido_actual)
	if not pedido: return
	
	globo_pedido.visible = true
	label_globo.text = "Quiero " + pedido["nombre"]

	if comidas_cocinadas.has(pedido["nombre"]):
		icono_comida.texture = comidas_cocinadas[pedido["nombre"]]

func abrir_ticket():
	var pedido = PedidoManager.obtener_pedido_por_id(id_pedido_actual)

	if pedido == null:
		return

	var ticket = preload("res://Escenas/ticket.tscn").instantiate()

	get_tree().current_scene.add_child(ticket)

	if ticket.has_method("cargar_ticket"):
		ticket.cargar_ticket(pedido)

func _on_button_tomar_pedido_pressed():
	boton_tomar_pedido.visible = false
	mostrar_globo_pedido()
	boton_cocinar.visible = true

func _on_button_cocinar_pressed():

	if id_pedido_actual == -1:
		return

	var pedido = PedidoManager.obtener_pedido_por_id(id_pedido_actual)

	if pedido == null:
		print("No encontré el pedido")
		return

	PedidoManager.pedido_actual = pedido

	print("Pedido enviado a cocina:")
	print(PedidoManager.pedido_actual)

	get_tree().change_scene_to_packed(cocina_scene)

func mostrar_resultado_cliente():
	ocultar_toda_la_ui()

	cliente_actual_tipo = PedidoManager.cliente_actual_tipo

	var resultado = PedidoManager.resultado_cliente

	cambiar_sprite_cliente(resultado)

	caja_registradora.visible = true

	await get_tree().create_timer(1.5).timeout

	flujo_nuevo_cliente()

func _process(delta):
	GameManager.tiempo_restante -= delta
	if GameManager.tiempo_restante < 0: GameManager.tiempo_restante = 0
	barra_tiempo.max_value = GameManager.duracion_dia
	barra_tiempo.value = GameManager.tiempo_restante
	label_dia.text = "Día " + str(GameManager.dia_actual)
	if GameManager.tiempo_restante <= 0: finalizar_dia()

func finalizar_dia():
	if dia_finalizado: return
	dia_finalizado = true
	GameManager.siguiente_dia()
	get_tree().reload_current_scene()
	
func mostrar_resultado_cliiente():
	print("ENTRO A mostrar_resultado_cliente")
	print("resultado =", PedidoManager.resultado_cliente)
	print("cliente_actual_tipo =", cliente_actual_tipo)
