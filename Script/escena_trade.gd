extends Node

# ======================================================
# PRECIOS
# ======================================================

@export var precio_carne := 30.0
@export var precio_salchicha := 20.0
@export var precio_pan := 15.0
@export var precio_papa := 10.0
@export var precio_tomate := 10.0

# ======================================================
# CONFIG
# ======================================================

@export var porcentaje_descuento := 10.0

@export var aumento_fallo_click := 1.0

@export var monedas_iniciales_jugador := 300.0
@export var monedas_iniciales_vendedor := 100.0

@export var duracion_cooldown := 20.0

# ======================================================
# REFERENCIAS
# ======================================================

@onready var root = get_parent()

@onready var flecha = \
root.get_node(
	"BarraComercio/Flecha"
)

@onready var barra_comercio = \
root.get_node(
	"BarraComercio"
)

@onready var boton_comercio = \
root.get_node(
	"UI/BotonComercio"
)

@onready var info_jugador = \
root.get_node(
	"UI/InfoJugador"
)

@onready var info_vendedor = \
root.get_node(
	"UI/InfoVendedor"
)

@onready var info_total = \
root.get_node(
	"UI/InfoTotal"
)

@onready var label_cooldown = \
root.get_node(
	"UI/Cooldown"
)

# ======================================================
# VARIABLES
# ======================================================

var monedas_jugador := 0.0
var monedas_vendedor := 0.0

var total_actual := 0.0

var multiplicador_precios := 1.0

var cantidad_fallos_click := 0

var cooldown := 0.0

var cooldown_activo := false

var carrito := {
	"carne": 0,
	"salchicha": 0,
	"pan": 0,
	"papa": 0,
	"tomate": 0
}

# ======================================================
# READY
# ======================================================

func _ready():

	boton_comercio.comercio_iniciado.connect(
		iniciar_comercio
	)

	monedas_jugador = \
	monedas_iniciales_jugador

	monedas_vendedor = \
	monedas_iniciales_vendedor

	flecha.desactivar()

	actualizar_ui()

# ======================================================
# PROCESS
# ======================================================

func _process(delta):

	actualizar_cooldown(delta)

	actualizar_ui()

# ======================================================
# INPUT
# ======================================================

func _input(event):

	if not flecha.activa:
		return

	if event is InputEventMouseButton:

		if event.pressed:

			procesar_click()

# ======================================================
# INICIAR COMERCIO
# ======================================================

func iniciar_comercio():

	if cooldown_activo:
		return

	flecha.activar()

	barra_comercio.randomizar_botones()

	cooldown_activo = true

	cooldown = duracion_cooldown

# ======================================================
# PROCESAR CLICK
# ======================================================

func procesar_click():

	var objetivo = \
	flecha.obtener_objetivo()

	if objetivo == null:

		registrar_fallo_click()

		return

	match objetivo.tipo_boton:

		objetivo.TipoBoton.CARNE:
			agregar_item(
				"carne",
				precio_carne
			)

		objetivo.TipoBoton.SALCHICHA:
			agregar_item(
				"salchicha",
				precio_salchicha
			)

		objetivo.TipoBoton.PAN:
			agregar_item(
				"pan",
				precio_pan
			)

		objetivo.TipoBoton.PAPA:
			agregar_item(
				"papa",
				precio_papa
			)

		objetivo.TipoBoton.TOMATE:
			agregar_item(
				"tomate",
				precio_tomate
			)

		objetivo.TipoBoton.DESCUENTO:
			aplicar_descuento()

		objetivo.TipoBoton.TRATO:
			confirmar_compra()

	objetivo.reducir_tamano()

	barra_comercio.randomizar_botones()

# ======================================================
# AGREGAR ITEM
# ======================================================

func agregar_item(
	nombre_item,
	precio_base
):

	var precio_final = \
	precio_base * multiplicador_precios

	if monedas_jugador < \
	total_actual + precio_final:
		return

	carrito[nombre_item] += 1

	total_actual += precio_final

# ======================================================
# DESCUENTO
# ======================================================

func aplicar_descuento():

	total_actual *= \
	1.0 - (
		porcentaje_descuento / 100.0
	)

# ======================================================
# CONFIRMAR COMPRA
# ======================================================

func confirmar_compra():

	if monedas_jugador < total_actual:
		return

	monedas_jugador -= total_actual

	monedas_vendedor += total_actual

	total_actual = 0

	for key in carrito.keys():

		carrito[key] = 0

	flecha.desactivar()

# ======================================================
# FALLOS CLICK
# ======================================================

func registrar_fallo_click():

	cantidad_fallos_click += 1

	if cantidad_fallos_click >= 3:

		multiplicador_precios += \
		aumento_fallo_click / 100.0

# ======================================================
# COOLDOWN
# ======================================================

func actualizar_cooldown(delta):

	if cooldown_activo:

		cooldown -= delta

		label_cooldown.text = \
		"Cooldown: " + \
		str(round(cooldown))

		if cooldown <= 0:

			cooldown_activo = false

			label_cooldown.text = ""

# ======================================================
# UI
# ======================================================

func actualizar_ui():

	info_jugador.text = \
	"Jugador: $" + \
	str(round(monedas_jugador))

	info_vendedor.text = \
	"Vendedor: $" + \
	str(round(monedas_vendedor))

	info_total.text = \
	"TOTAL: $" + \
	str(round(total_actual))
