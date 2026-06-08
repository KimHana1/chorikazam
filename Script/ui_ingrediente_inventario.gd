<<<<<<< HEAD
extends Control

@export var nombre_ingrediente: String = ""

@onready var label_cantidad = $LabelCantidad if has_node("LabelCantidad") else null

func _ready():
	actualizar()

func actualizar():
	if label_cantidad == null:
		return

	var cantidad = Global.cantidad_ingrediente(nombre_ingrediente)
	label_cantidad.text = str(cantidad)
=======
extends PanelContainer

@export var ingrediente_stringname : String

@onready var label = $MarginContainer/Label


func _ready():
	actualizar_info()

func actualizar_info() -> void:
	if Global.ingredientes.has(ingrediente_stringname):
		label.text = " x"+ str( Global.ingredientes[ingrediente_stringname] )
	else: print("No existe el elemento: " + str(ingrediente_stringname))
>>>>>>> 2d643843303f7eeb55e10825c0207415adcb00a4
