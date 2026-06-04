extends Node

@export var precio_carne := 30.0
@export var precio_salchicha := 20.0
@export var precio_pan := 15.0
@export var precio_papa := 10.0
@export var precio_tomate := 10.0

@export var porcentaje_descuento := 10.0
@export var aumento_fallo_click := 1.0


@export var monedas_iniciales_jugador :=100.0
@export var monedas_iniciales_vendedor := 100.0

@export var costo_base_comercio := 10.0
@export var multiplicador_costo_comercio := 1.5

@export var duracion_cooldown := 20.0
@onready var font = preload("res://fuente/Vanilla Caramel.otf")


@onready var barra_comercio = $BarraComercio
@onready var flecha = $BarraComercio/Flecha

@onready var boton_comercio = $UI/BotonComercio
@onready var ui = $UI
@onready var info_jugador = $UI/InfoJugador
@onready var info_vendedor = $UI/InfoVendedor
@onready var info_total = $UI/InfoTotal

@onready var label_cooldown = $UI/Cooldown


var total_actual := 0.0
var multiplicador_precios := 1.0
var cantidad_fallos_click := 0
var cooldown := 0.0
var cooldown_activo := false
var usos_comercio := 0
var primer_comercio := true

var carrito := {
	"carne": 0,
	"chorizo": 0,
	"pan": 0,
	"papa": 0,
	"tomate": 0
}


func _ready():
	
	var labels = get_tree().get_nodes_in_group("UI_Fonts")


	for label in labels:

		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 30)
		label.add_theme_color_override("font_color", Color.BLACK)
	boton_comercio.comercio_iniciado.connect(iniciar_comercio)



	flecha.desactivar()
	actualizar_ui()

func _process(delta):
	actualizar_cooldown(delta)


func _input(event):
	if not flecha.activa:
		return

	if event is InputEventMouseButton:
		if event.pressed:
			procesar_click()


func iniciar_comercio():
	if cooldown_activo:
		return

	var costo := 0.0

	if not primer_comercio:
		costo = costo_base_comercio * pow(multiplicador_costo_comercio, usos_comercio)
		if not Global.tiene_monedas_jugador(costo):
			return
		Global.quitar_monedas_jugador(costo)

	primer_comercio = false
	usos_comercio += 1

#Ubicando botones
	barra_comercio.randomizar_botones()
	flecha.activar()

	cooldown_activo = true
	cooldown = duracion_cooldown


# Click

func procesar_click():
	var objetivo = flecha.obtener_objetivo()

	if objetivo == null:
		print("No clickeo Boton")
		registrar_fallo_click()
		return

	print("Clickeo : ", objetivo.name)

	match objetivo.tipo_boton:
		objetivo.TipoBoton.CARNE:
			agregar_item("carne", precio_carne)
		objetivo.TipoBoton.SALCHICHA:
			agregar_item("chorizo", precio_salchicha)
		objetivo.TipoBoton.PAN:
			agregar_item("pan", precio_pan)
		objetivo.TipoBoton.PAPA:
			agregar_item("papa", precio_papa)
		objetivo.TipoBoton.TOMATE:
			agregar_item("tomate", precio_tomate)
		objetivo.TipoBoton.DESCUENTO:
			aplicar_descuento()
		objetivo.TipoBoton.TRATO:
			confirmar_compra()

	objetivo.reducir_tamano()

	if objetivo.tipo_boton != objetivo.TipoBoton.TRATO:
		print("Reubica ingrediente")
		# Llamamos a la nueva función de la barra pasándole el botón clicado
		barra_comercio.reubicar_un_solo_boton(objetivo)
	else:
		print("Boton Trato esta quieto")

	actualizar_ui()


func agregar_item(nombre_item, precio_base):

	var precio_final = precio_base * multiplicador_precios

	print("-------")
	print("Sumar Item")
	print("Item: ", nombre_item)
	print("Precio base: ", precio_base)
	print("Precio final: ", precio_final)
	print("Total antes: ", total_actual)

	if Global.monedas_jugador < total_actual + precio_final:

		print("No Hay plata")
		return

	carrito[nombre_item] += 1

	total_actual += precio_final

	print("Total despues: ", total_actual)
	print("Carrito: ", carrito)

	actualizar_ui()

func aplicar_descuento():
	total_actual *= (1.0 - porcentaje_descuento / 100.0)

#Compra
func confirmar_compra():
	
	print("-Compro-")
	print("Total compra: ", total_actual)
	print("Monedas jugador antes: ", Global.monedas_jugador)

	if not Global.tiene_monedas_jugador(total_actual):

		print("No hay plata diria el presi")
		return
	flecha.velocidad = 500
	Global.quitar_monedas_jugador(total_actual)

	print("Monedas jugador despues: ", Global.monedas_jugador)

	Global.agregar_monedas_vendedor(total_actual)

	print("Monedas vendedor despues: ", Global.monedas_vendedor)

	for item in carrito.keys():

		if carrito[item] > 0:

			print(
				"Guardando ",
				item,
				" x",
				carrito[item]
			)

			Global.agregar_ingrediente(
				item,
				carrito[item]
			)

	total_actual = 0

	for key in carrito.keys():

		carrito[key] = 0

	flecha.desactivar()

	actualizar_ui()

func registrar_fallo_click():
	cantidad_fallos_click += 1
	flecha.velocidad *=1.36
	if cantidad_fallos_click >= 3:
		multiplicador_precios += aumento_fallo_click / 100.0


func actualizar_cooldown(delta):
	
	if not cooldown_activo:
		return

	cooldown -= delta

	ui.actualizar_cooldown(
		cooldown
	)

	if cooldown <= 0:

		cooldown_activo = false

		cooldown = 0

		ui.limpiar_cooldown()

#UI
func actualizar_ui():

	print("-Actualizando UI-")
	print("Monedas jugador: ", Global.monedas_jugador)
	print("Monedas vendedor: ", Global.monedas_vendedor)
	print("Total actual: ", total_actual)

	ui.actualizar_datos(
		Global.monedas_jugador,
		Global.monedas_vendedor,
		total_actual
	)
	ui.actualizar_carrito(carrito)

	
