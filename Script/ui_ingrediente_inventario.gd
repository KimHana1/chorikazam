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
