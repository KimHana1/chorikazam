extends PanelContainer

@export var ingrediente_stringname : String

@onready var label = $MarginContainer/Label


func _ready():
	actualizar_info()

func actualizar_info() -> void:
	if Global.ingredientes.has(ingrediente_stringname):
		label.text = " x"+ str( Global.ingredientes[ingrediente_stringname] )
	else: print("No existe el elemento: " + str(ingrediente_stringname))
