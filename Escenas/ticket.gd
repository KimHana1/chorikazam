extends Control

@onready var label_pedido = $LabelPedido
@onready var comida_cocinada = $ComidaCocinada
@onready var pasos_container = $PasosContainer
@onready var color = $Color
@onready var paciencia_cliente = $PacienciaCliente

var comidas_cocinadas = {
	"Choripán": preload("res://Sprites/cocinado/choripan.png"),
	"Ensalada": preload("res://Sprites/cocinado/ensaladapatoma.png")
}

var iconos_pasos = {
	"cortar": preload("res://Sprites/pasos/cortar_icon.png"),
	"pelar": preload("res://Sprites/pasos/pelar_icon.png"),
	"cocinar": preload("res://Sprites/pasos/calentar_icon.png")
}

func _ready():
	var pedido_prueba = {
		"nombre": "Choripán",
		"pasos": ["cortar", "cocinar"],
		"paciencia": 80
	}

	cargar_ticket(pedido_prueba)

func cargar_ticket(datos):
	label_pedido.text = datos["nombre"]

	limpiar_contenedor(comida_cocinada)
	limpiar_contenedor(pasos_container)

	if datos["nombre"] in comidas_cocinadas:
		var icono_comida = TextureRect.new()
		icono_comida.texture = comidas_cocinadas[datos["nombre"]]
		icono_comida.custom_minimum_size = Vector2(15, 14)
		comida_cocinada.add_child(icono_comida)

	for paso in datos["pasos"]:
		if paso in iconos_pasos:
			var icono = TextureRect.new()
			icono.texture = iconos_pasos[paso]
			icono.custom_minimum_size = Vector2(15, 15)
			pasos_container.add_child(icono)

	paciencia_cliente.value = datos["paciencia"]

func limpiar_contenedor(contenedor):
	for hijo in contenedor.get_children():
		hijo.queue_free()
