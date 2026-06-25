extends Control

@onready var sprite_cliente = $SpriteCliente
@onready var icono_comida = $IconoComida
@onready var label_resultado = $LabelResultado

@onready var label_ganancia = $LabelGanancia

var escena_cliente = "res://Escenas/cliente.tscn"

var comidas_cocinadas = {
	"Choripán": preload("res://Sprites/cocinado/choripan.png"),
	"Ensalada": preload("res://Sprites/cocinado/ensaladapatoma.png"),
	"papitas fritas": preload("res://Sprites/cocinado/papa frita.png"),
	"carne con papas": preload("res://Sprites/ComidaCocinada/papaCarneCocinada.png")
}

var clientes = {
	"mujer": {
		"enojado": preload("res://Sprites/clientes/Mujer/enojada.png"),
		"feliz": preload("res://Sprites/clientes/Mujer/feliz.png"),
		"medio": preload("res://Sprites/clientes/Mujer/medio.png")
	},
	"hombre": {
		"enojado": preload("res://Sprites/clientes/Hombre/enojado.png"),
		"feliz": preload("res://Sprites/clientes/Hombre/feliz.png"),
		"medio": preload("res://Sprites/clientes/Hombre/medio.png")
	},
	"niña": {
		"enojado": preload("res://Sprites/clientes/niña/enojada.png"),
		"feliz": preload("res://Sprites/clientes/niña/NiñaFeliz.png"),
		"medio": preload("res://Sprites/clientes/niña/NiñaMedio.png"),
		
		"color": Color.DARK_RED}
}

func _ready():
	var pedido = PedidoManager.pedido_actual
	var tipo = PedidoManager.cliente_actual_tipo
	var resultado = PedidoManager.resultado_cliente

	if icono_comida and pedido.has("nombre") and comidas_cocinadas.has(pedido["nombre"]):
		icono_comida.texture = comidas_cocinadas[pedido["nombre"]]

	if sprite_cliente and clientes.has(tipo) and clientes[tipo].has(resultado):
		sprite_cliente.texture = clientes[tipo][resultado]

	
	var pago = 0
	
	if resultado == "feliz":
		pago = 50
		if label_resultado:
			label_resultado.text = "¡Capx!"
			label_resultado.modulate = Color.GREEN
		if label_ganancia:
			label_ganancia.text = "+$" + str(pago)
			label_ganancia.modulate = Color.GREEN
			
	elif resultado == "medio":
		pago = 25
		if label_resultado:
			label_resultado.text = "Zafa, pero tardaste bastante bro"
			label_resultado.modulate = Color.YELLOW
		if label_ganancia:
			label_ganancia.text = "+$" + str(pago)
			label_ganancia.modulate = Color.YELLOW
			
	else:
		pago = 5
		if label_resultado:
			label_resultado.text = "Mi perro cocina mejor"
			label_resultado.modulate = Color.RED
		if label_ganancia:
			label_ganancia.text = "+$10"
			label_ganancia.modulate = Color.RED

	Global.monedas_jugador += pago
	get_tree().call_group("hud_monedas", "actualizar_info")


func _on_boton_continuar_pressed() -> void:
	PedidoManager.eliminar_pedido_por_id(PedidoManager.pedido_actual["id"])
	PedidoManager.pedido_completado = false
	
	get_tree().change_scene_to_file(escena_cliente)
