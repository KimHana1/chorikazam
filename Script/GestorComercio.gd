extends Node

var volver_a_cocina = "res://Escenas/cocina.tscn"

@export var precio_carne := 30.0
@export var precio_chorizo := 20.0
@export var precio_pan := 15.0
@export var precio_papa := 10.0
@export var precio_tomate := 10.0

@export var porcentaje_descuento := 10.0
@export var aumento_fallo_click := 1.0

@export var costo_base_comercio := 10.0
@export var multiplicador_costo_comercio := 1.5
@export var duracion_cooldown := 20.0

@onready var barra_comercio = $BarraComercio
@onready var flecha = $BarraComercio/Flecha
@onready var boton_comercio = $UI/BotonComercio
@onready var ui = $UI
@onready var ui_inventario_global = $"../UI  Inventario Global"

var total_actual := 0.0
var multiplicador_precios := 1.0
var cantidad_fallos_click := 0
var cooldown := 0.0
var cooldown_activo := false
var usos_comercio := 0
var primer_comercio := true

var carrito: Dictionary = {
	"carne": 0,
	"chorizo": 0,
	"pan": 0,
	"papa": 0,
	"tomate": 0
}

var precios: Dictionary = {}

func _ready():

	precios = {
		"carne": precio_carne,
		"chorizo": precio_chorizo,
		"pan": precio_pan,
		"papa": precio_papa,
		"tomate": precio_tomate
	}

	if not boton_comercio.comercio_iniciado.is_connected(iniciar_comercio):
		boton_comercio.comercio_iniciado.connect(iniciar_comercio)

	flecha.desactivar()
	actualizar_ui()

func _process(delta):
	actualizar_cooldown(delta)

func _input(event):

	if not flecha.activa:
		return

	if event is InputEventMouseButton and event.pressed:
		procesar_click()

func iniciar_comercio():

	if cooldown_activo:
		print("Comercio en cooldown")
		return

	var costo := 0.0

	if not primer_comercio:

		costo = costo_base_comercio * pow(
			multiplicador_costo_comercio,
			usos_comercio
		)

		if not Global.tiene_monedas_jugador(costo):
			print("No hay monedas para iniciar comercio")
			return

		Global.quitar_monedas_jugador(costo)

	primer_comercio = false
	usos_comercio += 1
	cantidad_fallos_click = 0
	multiplicador_precios = 1.0

	barra_comercio.randomizar_botones()
	flecha.activar()

	cooldown_activo = true
	cooldown = duracion_cooldown

	actualizar_ui()

func procesar_click():

	var objetivo = flecha.obtener_objetivo()

	if objetivo == null:
		registrar_fallo_click()
		actualizar_ui()
		return

	if not "tipo_boton" in objetivo:
		print("El objetivo no es boton de comercio")
		registrar_fallo_click()
		actualizar_ui()
		return

	match objetivo.tipo_boton:

		objetivo.TipoBoton.CARNE:
			agregar_item("carne")

		objetivo.TipoBoton.SALCHICHA:
			agregar_item("chorizo")

		objetivo.TipoBoton.PAN:
			agregar_item("pan")

		objetivo.TipoBoton.PAPA:
			agregar_item("papa")

		objetivo.TipoBoton.TOMATE:
			agregar_item("tomate")

		objetivo.TipoBoton.DESCUENTO:
			aplicar_descuento()

		objetivo.TipoBoton.TRATO:
			confirmar_compra()

	if objetivo.has_method("reducir_tamano"):
		objetivo.reducir_tamano()

	if objetivo.tipo_boton != objetivo.TipoBoton.TRATO:
		barra_comercio.reubicar_un_solo_boton(objetivo)

	actualizar_ui()

func agregar_item(nombre_item: String):

	if not precios.has(nombre_item):
		print("No existe precio para: ", nombre_item)
		return

	var precio_final = precios[nombre_item] * multiplicador_precios

	if Global.monedas_jugador < total_actual + precio_final:
		print("No hay monedas suficientes")
		return

	carrito[nombre_item] += 1
	total_actual += precio_final

	print("Agregado: ", nombre_item)

func aplicar_descuento():

	total_actual *= 1.0 - porcentaje_descuento / 100.0

	print("Descuento aplicado")

func confirmar_compra():

	if total_actual <= 0:
		print("Carrito vacio")
		return

	if not Global.tiene_monedas_jugador(total_actual):
		print("No hay monedas para confirmar")
		return

	Global.quitar_monedas_jugador(total_actual)
	Global.agregar_monedas_vendedor(total_actual)

	for item in carrito.keys():

		if carrito[item] > 0:
			Global.agregar_ingrediente(
				item,
				carrito[item]
			)

	limpiar_carrito()

	flecha.desactivar()
	actualizar_ui()

	if ui_inventario_global != null:

		if ui_inventario_global.has_method(
			"actualizar_inventario"
		):

			ui_inventario_global.actualizar_inventario()

func limpiar_carrito():

	total_actual = 0.0

	for key in carrito.keys():
		carrito[key] = 0

func registrar_fallo_click():

	cantidad_fallos_click += 1

	flecha.velocidad *= 1.36

	if cantidad_fallos_click >= 3:
		multiplicador_precios += aumento_fallo_click / 100.0

	print("Fallo click")

func actualizar_cooldown(delta):

	if not cooldown_activo:
		return

	cooldown -= delta

	if ui.has_method("actualizar_cooldown"):
		ui.actualizar_cooldown(cooldown)

	if cooldown <= 0:

		cooldown_activo = false
		cooldown = 0

		if ui.has_method("limpiar_cooldown"):
			ui.limpiar_cooldown()

func actualizar_ui():

	if ui.has_method("actualizar_datos"):

		ui.actualizar_datos(
			Global.monedas_jugador,
			Global.monedas_vendedor,
			total_actual
		)

	if ui.has_method("actualizar_carrito"):
		ui.actualizar_carrito(carrito)

func _on_boton_volver_pressed() -> void:

	print("Volviendo a cocina")

	get_tree().change_scene_to_file(
		volver_a_cocina
	)
