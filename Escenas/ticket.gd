extends Control

@onready var label_pedido = $VBoxContainer/LabelPedido
@onready var comida_cocinada = $VBoxContainer/ComidaCocinada
@onready var pasos_container = $VBoxContainer/PasosContainer
@onready var identificador_color = $VBoxContainer/IdentificadorColor
@onready var paciencia_cliente = $VBoxContainer/PacienciaCliente

var paciencia_actual: float = 100.0
var velocidad_paciencia: float = 1.0

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
		"paciencia": 100,
		"color": Color.BROWN
	}

	cargar_ticket(pedido_prueba)

func cargar_ticket(datos):
	label_pedido.text = datos["nombre"]

	limpiar_contenedor(comida_cocinada)
	limpiar_contenedor(pasos_container)

	if datos.has("color"):
		identificador_color.color = datos["color"]

	if datos["nombre"] in comidas_cocinadas:
		var icono_comida = TextureRect.new()
		icono_comida.texture = comidas_cocinadas[datos["nombre"]]
		icono_comida.custom_minimum_size = Vector2(35, 35)
		icono_comida.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icono_comida.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		comida_cocinada.add_child(icono_comida)

	for paso in datos["pasos"]:
		if paso in iconos_pasos:
			var icono = TextureRect.new()
			icono.texture = iconos_pasos[paso]
			icono.custom_minimum_size = Vector2(35, 35)
			icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			pasos_container.add_child(icono)

	paciencia_actual = datos["paciencia"]

	paciencia_cliente.max_value = 100
	paciencia_cliente.value = paciencia_actual
	paciencia_cliente.custom_minimum_size = Vector2(50, 18)

func _process(delta):
	if paciencia_actual > 0:
		paciencia_actual -= velocidad_paciencia * delta
		paciencia_cliente.value = paciencia_actual

		if paciencia_actual <= 0:
			paciencia_actual = 0
			print("Cliente insatisfecho")

func limpiar_contenedor(contenedor):
	for hijo in contenedor.get_children():
		hijo.queue_free()
