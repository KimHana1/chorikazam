extends CharacterBody2D

const ESTADO_PRINCIPAL = "principal"
const ESTADO_FELIZ = "feliz"
const ESTADO_MEDIO = "medio"
const ESTADO_ENOJADO = "enojado"

@onready var plato_preparado = $PlatoPreparado
@onready var caja_registradora = $CajaRegistradora
@onready var sprite = $Sprite2D

@onready var inventario = $CanvasLayer/"UI Inventario Global"

@onready var boton_tomar_pedido = $CanvasLayer/ButtonTomarPedido
@onready var boton_cocinar = $CanvasLayer/ButtonCocinar
@onready var globo_pedido = $GloboPedido
@onready var label_globo =$GloboPedido/LabelPedido
@onready var icono_comida = $GloboPedido/IconoComida

@onready var barra_tiempo = $CanvasLayer/BarraTiempo
@onready var label_dia = $CanvasLayer/LabelDia

@onready var pos_mostrador = $FilaClientes/Pos1
@onready var posiciones_espera = [
	$FilaClientes/Pos2,
	$FilaClientes/Pos3,
	$FilaClientes/Pos4,
	$FilaClientes/Pos5
]
var escena_cliente_fila = preload("res://Escenas/cliente_fila.tscn")
var fila_visual = []
var timer_spawn: float = 0.0
var atendiendo: bool = false

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
	sprite.visible = false 
	iniciar_idle_cliente()

	if GameManager.tiempo_restante <= 0 or GameManager.clientes_restantes <= 0:
		GameManager.iniciar_dia()

	if PedidoManager.pedido_completado:
		atendiendo = true
		sprite.visible = true
		mostrar_resultado_cliente()
	else:
		atendiendo = false

func ocultar_toda_la_ui():
	if plato_preparado: plato_preparado.visible = false
	if caja_registradora: caja_registradora.visible = false
	if globo_pedido: globo_pedido.visible = false
	if boton_cocinar: boton_cocinar.visible = false
	if boton_tomar_pedido: boton_tomar_pedido.visible = false

func cambiar_sprite_cliente(estado: String):
	if clientes.has(cliente_actual_tipo):
		if clientes[cliente_actual_tipo].has(estado):
			sprite.modulate = Color.WHITE
			sprite.texture = clientes[cliente_actual_tipo][estado]

func iniciar_idle_cliente():
	if tween_idle: tween_idle.kill()
	var y_original = sprite.position.y
	tween_idle = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_idle.tween_property(sprite, "position:y", y_original - 5, 0.8)
	tween_idle.tween_property(sprite, "position:y", y_original, 0.8)

func _process(delta):
	GameManager.tiempo_restante -= delta
	if GameManager.tiempo_restante < 0: GameManager.tiempo_restante = 0
	if barra_tiempo:
		barra_tiempo.max_value = GameManager.duracion_dia
		barra_tiempo.value = GameManager.tiempo_restante
	if label_dia:
		label_dia.text = "Día " + str(GameManager.dia_actual)
	if GameManager.tiempo_restante <= 0: finalizar_dia()
	
	if fila_visual.size() < posiciones_espera.size() and not dia_finalizado:
		timer_spawn += delta
		if timer_spawn >= 2.5: 
			timer_spawn = 0.0
			spawnear_en_fila()

func spawnear_en_fila():
	var nuevo_cliente = escena_cliente_fila.instantiate()
	add_child(nuevo_cliente)
	
	var tipos = ["hombre", "mujer"]
	var tipo_elegido = tipos[randi() % tipos.size()]
	
	var nodo_sprite = nuevo_cliente.get_node_or_null("Sprite2D")
	if nodo_sprite: 
		nodo_sprite.texture = clientes[tipo_elegido][ESTADO_PRINCIPAL]
		var tween_espera = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween_espera.tween_property(nodo_sprite, "position:y", nodo_sprite.position.y - 5, 0.8)
		tween_espera.tween_property(nodo_sprite, "position:y", nodo_sprite.position.y, 0.8)
	
	var nodo_globo = nuevo_cliente.get_node_or_null("GloboPedido")
	if nodo_globo: nodo_globo.visible = false
	
	nuevo_cliente.z_index = 5
	var indice = fila_visual.size()
	nuevo_cliente.global_position = posiciones_espera[indice].global_position
	fila_visual.append({"nodo": nuevo_cliente, "tipo": tipo_elegido})
	
	if not atendiendo:
		llamar_al_siguiente()

func llamar_al_siguiente():
	if fila_visual.is_empty() or atendiendo:
		return
		
	atendiendo = true
	var primer_cliente = fila_visual.pop_front()
	var nodo_dummy = primer_cliente["nodo"]
	cliente_actual_tipo = primer_cliente["tipo"] 
	
	var tween = create_tween()
	tween.tween_property(nodo_dummy, "global_position", pos_mostrador.global_position, 0.5)
	avanzar_fila()
	await tween.finished
	
	nodo_dummy.queue_free()
	sprite.visible = true
	flujo_nuevo_cliente()

func avanzar_fila():
	for i in range(fila_visual.size()):
		var datos = fila_visual[i]
		var nodo = datos["nodo"]
		var nueva_pos = posiciones_espera[i].global_position
		var tween = create_tween()
		tween.tween_property(nodo, "global_position", nueva_pos, 0.5)

func flujo_nuevo_cliente():
	if GameManager.clientes_restantes <= 0: return
	GameManager.clientes_restantes -= 1
	ocultar_toda_la_ui()
	
	PedidoManager.cliente_actual_tipo = cliente_actual_tipo
	cambiar_sprite_cliente(ESTADO_PRINCIPAL)
	
	var receta_random = pedidos[randi() % pedidos.size()]
	var nuevo_pedido = PedidoManager.registrar_nuevo_pedido(receta_random, clientes[cliente_actual_tipo]["color"])
	id_pedido_actual = nuevo_pedido["id"]

	if boton_tomar_pedido:
		boton_tomar_pedido.visible = true

func _on_button_tomar_pedido_pressed() -> void:
	boton_tomar_pedido.visible = false

	mostrar_globo_pedido()

	label_globo.text = "Quiero " + PedidoManager.obtener_pedido_por_id(id_pedido_actual)["nombre"]

	await get_tree().create_timer(1.0).timeout

	boton_cocinar.visible = true

func mostrar_globo_pedido():
	var pedido = PedidoManager.obtener_pedido_por_id(id_pedido_actual)
	if not pedido: return
	
	if globo_pedido: globo_pedido.visible = true
	if label_globo: label_globo.text = "Quiero " + pedido["nombre"]
	if icono_comida and comidas_cocinadas.has(pedido["nombre"]):
		icono_comida.texture = comidas_cocinadas[pedido["nombre"]]

func _on_button_cocinar_pressed():
	if id_pedido_actual == -1: return
	var pedido = PedidoManager.obtener_pedido_por_id(id_pedido_actual)
	if pedido == null: return
	PedidoManager.pedido_actual = pedido
	get_tree().change_scene_to_packed(cocina_scene)

func mostrar_resultado_cliente():
	ocultar_toda_la_ui()
	cliente_actual_tipo = PedidoManager.cliente_actual_tipo
	var resultado = PedidoManager.resultado_cliente
	cambiar_sprite_cliente(resultado)
	if caja_registradora: caja_registradora.visible = true

	await get_tree().create_timer(1.5).timeout
	
	sprite.visible = false
	if caja_registradora: caja_registradora.visible = false
	atendiendo = false
	PedidoManager.pedido_completado = false
	llamar_al_siguiente()

func finalizar_dia():
	if dia_finalizado: return
	dia_finalizado = true
	GameManager.siguiente_dia()
	get_tree().reload_current_scene()
